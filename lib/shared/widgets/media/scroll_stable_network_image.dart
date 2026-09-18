import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:bluerum/shared/widgets/media/media_budget.dart';
import 'package:bluerum/shared/widgets/media/media_precache.dart';

export 'package:bluerum/shared/widgets/media/media_budget.dart';

enum _ImgPhase { cold, loading, ready, failed }

/// Network image that **never changes layout size** and only paints after the
/// decode has finished (cache-then-paint).
///
/// Scroll policy ([gateOnScroll]):
/// - While the parent list is scrolling, **do no cache probes / decodes** unless
///   already painted — cold images stay solid placeholder (FPS first).
/// - On idle: cache-hit paints via [ImagePaintBudget]; uncached via
///   [ImageDecodeBudget] then paint budget.
///
/// Tiny list avatars use [NetworkAvatar] + CNI instead of this widget so they
/// never join the process-wide still FIFO.
class ScrollStableNetworkImage extends StatefulWidget {
  const ScrollStableNetworkImage({
    super.key,
    required this.imageUrl,
    required this.memCacheWidth,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.placeholderColor = const Color(0xFFE8E8E8),
    this.errorWidget,
    this.semanticLabel,
    this.filterQuality = FilterQuality.none,
    this.gateOnScroll = true,
  });

  final String imageUrl;
  final int memCacheWidth;
  final BoxFit fit;
  final Alignment alignment;
  final double? width;
  final double? height;
  final Color placeholderColor;
  final Widget Function(BuildContext context)? errorWidget;
  final String? semanticLabel;
  final FilterQuality filterQuality;
  final bool gateOnScroll;

  @override
  State<ScrollStableNetworkImage> createState() =>
      _ScrollStableNetworkImageState();
}

class _ScrollStableNetworkImageState extends State<ScrollStableNetworkImage> {
  _ImgPhase _phase = _ImgPhase.cold;
  ImageProvider? _provider;
  int _generation = 0;

  /// Soft deadline for cache probes (outside the decode slot).
  static const Duration _cacheProbeTimeout = Duration(seconds: 3);

  bool get _isReady => _phase == _ImgPhase.ready;
  bool get _isFailed => _phase == _ImgPhase.failed;

  @override
  void initState() {
    super.initState();
    MediaBudgetEpoch.listenable.addListener(_onMediaBudgetFlushed);
  }

  @override
  void dispose() {
    _generation++;
    MediaBudgetEpoch.listenable.removeListener(_onMediaBudgetFlushed);
    super.dispose();
  }

  void _onMediaBudgetFlushed() {
    if (!mounted || _isReady || _provider == null) return;
    _phase = _ImgPhase.cold;
    _requestDecode(_provider!);
  }

  void _retry() {
    if (!mounted) return;
    _generation++;
    setState(() {
      _phase = _ImgPhase.cold;
      _provider = null;
    });
    _syncProvider();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncProvider();
  }

  @override
  void didUpdateWidget(covariant ScrollStableNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.memCacheWidth != widget.memCacheWidth) {
      _generation++;
      _phase = _ImgPhase.cold;
      _provider = null;
      _syncProvider();
    }
  }

  void _syncProvider() {
    if (widget.imageUrl.isEmpty) {
      _phase = _ImgPhase.failed;
      return;
    }
    final provider = mediaImageProvider(
      widget.imageUrl,
      cacheWidth: widget.memCacheWidth,
    );
    _provider = provider;
    if (_isReady) return;
    _requestDecode(provider);
  }

  bool _stillCurrent(int gen) =>
      mounted && gen == _generation && _provider != null;

  bool _canContinue(int gen) =>
      _stillCurrent(gen) && !_isReady && !_isFailed;

  /// Single scroll-gate policy used by every stage of the still pipeline.
  ///
  /// Returns true when work was deferred to idle (caller must return).
  bool _deferIfScrolling(int gen) {
    if (!widget.gateOnScroll || !scrollActivityBusy(context)) return false;
    _phase = _ImgPhase.cold;
    whenScrollActivityIdle(context, () {
      if (_canContinue(gen) && _provider != null) {
        _requestDecode(_provider!);
      }
    });
    return true;
  }

  void _requestDecode(ImageProvider provider) {
    if (!mounted || _isReady || _isFailed) return;
    if (_phase == _ImgPhase.loading) return;
    _phase = _ImgPhase.loading;
    final gen = _generation;

    if (_deferIfScrolling(gen)) return;

    unawaited(() async {
      final painted = await _tryPaintIfCached(provider, gen);
      if (!_canContinue(gen)) return;
      if (painted) return;
      _enqueueUncached(provider, gen);
    }());
  }

  void _enqueueUncached(ImageProvider provider, int gen) {
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      if (!_canContinue(gen)) return;
      if (_deferIfScrolling(gen)) return;
      ImageDecodeBudget.schedule((done) {
        unawaited(() async {
          try {
            if (!_canContinue(gen)) return;

            final painted = await _tryPaintIfCached(provider, gen);
            if (!_canContinue(gen) || !mounted) return;
            if (painted) return;

            if (_deferIfScrolling(gen)) return;

            await _load(provider, gen);
          } finally {
            done();
          }
        }());
      });
    });
    SchedulerBinding.instance.scheduleFrame();
  }

  Future<bool> _tryPaintIfCached(ImageProvider provider, int gen) async {
    if (!mounted) return true;
    try {
      final config = createLocalImageConfiguration(context);
      final status = await provider
          .obtainCacheStatus(configuration: config)
          .timeout(_cacheProbeTimeout, onTimeout: () => null);
      if (!_stillCurrent(gen)) return true;
      if (status == null || !(status.keepAlive || status.live)) {
        return false;
      }

      if (!mounted) return true;
      if (_deferIfScrolling(gen)) return true;

      _markReadyBudgeted(gen);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _load(ImageProvider provider, int gen) async {
    if (!_canContinue(gen)) return;
    if (_deferIfScrolling(gen)) return;

    var hadError = false;
    try {
      if (!mounted) return;
      await precacheImage(
        provider,
        context,
        onError: (_, _) {
          hadError = true;
        },
      ).timeout(ImageDecodeBudget.jobTimeout);
    } on TimeoutException {
      if (_stillCurrent(gen) && !_isReady) {
        setState(() => _phase = _ImgPhase.failed);
      }
      return;
    } catch (_) {
      if (_stillCurrent(gen) && !_isReady) {
        setState(() => _phase = _ImgPhase.failed);
      }
      return;
    }

    if (!_stillCurrent(gen)) return;

    if (hadError) {
      setState(() => _phase = _ImgPhase.failed);
      return;
    }

    if (!mounted) return;
    if (_deferIfScrolling(gen)) return;

    _markReadyBudgeted(gen);
  }

  void _markReadyBudgeted(int gen) {
    ImagePaintBudget.schedule(() {
      if (!_stillCurrent(gen) || _isReady) return;
      if (_deferIfScrolling(gen)) return;
      setState(() => _phase = _ImgPhase.ready);
    });
  }

  void _onImageStreamError() {
    if (!mounted || _isFailed) return;
    setState(() => _phase = _ImgPhase.failed);
  }

  Widget _placeholderBox(double? w, double? h) {
    return SizedBox(
      width: w,
      height: h,
      child: ColoredBox(color: widget.placeholderColor),
    );
  }

  Widget _failureBox(double? w, double? h) {
    if (widget.errorWidget != null) {
      return SizedBox(
        width: w,
        height: h,
        child: widget.errorWidget!(context),
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _retry,
      child: SizedBox(
        width: w,
        height: h,
        child: ColoredBox(
          color: widget.placeholderColor,
          child: const Center(
            child: Icon(
              Icons.refresh_rounded,
              size: 28,
              color: Color(0xFF525252),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width;
    final h = widget.height;

    if (_isFailed) return _failureBox(w, h);

    if (_isReady && _provider != null) {
      return Image(
        image: _provider!,
        fit: widget.fit,
        alignment: widget.alignment,
        width: w,
        height: h,
        gaplessPlayback: true,
        filterQuality: widget.filterQuality,
        semanticLabel: widget.semanticLabel,
        errorBuilder: (context, _, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _onImageStreamError();
          });
          return _failureBox(w, h);
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return _placeholderBox(w, h);
        },
      );
    }

    return _placeholderBox(w, h);
  }
}
