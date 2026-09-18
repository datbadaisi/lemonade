import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:bluerum/features/ads/ads_bootstrap.dart';
import 'package:bluerum/features/ads/domain/ads_config.dart';
import 'package:bluerum/features/feed/presentation/feed_scroll_phase.dart';
import 'package:bluerum/shared/widgets/media/scroll_stable_network_image.dart';

/// Where the native ad is shown — picks template size + unit id later.
enum InFeedAdPlacement {
  homeFeed,
  commentList,
}

/// In-feed native ad card using AdMob native templates.
///
/// Lifecycle (AdWidget-safe — no NativeAd reuse across slots):
/// - Reserves fixed height while loading (and on fail when [keepHeightOnFailure]).
/// - **Prefetch**: start [NativeAd.load] as soon as the slot is *approaching*
///   the viewport (even mid-fling) so fill rate is not killed by "idle-only".
/// - **Attach**: mount [AdWidget] only when scroll is idle (platform view mid-
///   fling is the FPS hitch near ad slots).
/// - Optional far-dispose frees platform views; request is restarted when near
///   again (height stays reserved).
class InFeedNativeAd extends StatefulWidget {
  const InFeedNativeAd({
    super.key,
    required this.placement,
    required this.slot,
    this.deferUntilNearViewport = false,
    this.keepHeightOnFailure = false,
    this.scrollPhaseListenable,
    this.farDisposeWhenOffscreen = false,
  });

  final InFeedAdPlacement placement;
  final int slot;

  /// When true, wait until the slot is approaching the viewport before load.
  /// Load itself may start while scrolling; [AdWidget] still waits for idle.
  final bool deferUntilNearViewport;

  /// When true, never collapse to zero height on fail (product / layout stable).
  final bool keepHeightOnFailure;

  /// Optional phase source (post-detail uses a **local** notifier so home feed
  /// phase is not polluted). Defaults to [feedScrollPhaseListenable].
  final ValueListenable<FeedScrollPhase>? scrollPhaseListenable;

  /// When true, dispose the platform-view ad after it scrolls far away
  /// (frees RAM; slot keeps reserved height). Used for comment list.
  final bool farDisposeWhenOffscreen;

  @override
  State<InFeedNativeAd> createState() => _InFeedNativeAdState();
}

class _InFeedNativeAdState extends State<InFeedNativeAd> {
  NativeAd? _ad;
  /// Network + SDK filled a [NativeAd] instance.
  bool _sdkReady = false;
  /// [AdWidget] is mounted (only when idle — avoids fling hitch).
  bool _attached = false;
  bool _failed = false;
  bool _loadStarted = false;
  Timer? _farDisposeTimer;
  Timer? _retryTimer;
  int _loadAttempts = 0;
  static const int _maxLoadAttempts = 3;
  /// Cap live platform-view ads app-wide. Multiple medium NativeAds OOMs
  /// mid-range Android far faster than post bitmaps.
  static int _liveAttachedAds = 0;
  static const int _maxLiveAttachedAds = 1;
  bool _listeningPhase = false;
  bool _scheduledEval = false;
  bool _waitingIdleAttach = false;
  ValueListenable<FeedScrollPhase>? _boundPhase;

  static const EdgeInsets _homePadding =
      EdgeInsets.symmetric(horizontal: 12, vertical: 10);
  static const EdgeInsets _commentPadding =
      EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  static const double _radius = 12;

  static bool get _supported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  bool get _isHome => widget.placement == InFeedAdPlacement.homeFeed;

  EdgeInsets get _padding => _isHome ? _homePadding : _commentPadding;

  ValueListenable<FeedScrollPhase> get _phase =>
      widget.scrollPhaseListenable ?? feedScrollPhaseListenable;

  String get _adUnitId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AdsConfig.iosNativeAdUnitId;
    }
    return AdsConfig.androidNativeAdUnitId;
  }

  TemplateType get _templateType =>
      _isHome ? TemplateType.medium : TemplateType.small;

  double get _adHeight => _isHome ? 300 : 112;

  bool get _scrollIdle {
    if (_phase.value != FeedScrollPhase.idle) return false;
    return !scrollActivityBusy(context);
  }

  @override
  void initState() {
    super.initState();
    if (!_supported) {
      _failed = true;
      return;
    }
    if (!widget.deferUntilNearViewport) {
      _startLoad();
    } else {
      _boundPhase = _phase;
      _boundPhase!.addListener(_onPhaseChanged);
      _listeningPhase = true;
      _scheduleEvaluate();
    }
  }

  @override
  void didUpdateWidget(covariant InFeedNativeAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.deferUntilNearViewport || !_listeningPhase) return;
    final next = _phase;
    if (!identical(_boundPhase, next)) {
      _boundPhase?.removeListener(_onPhaseChanged);
      _boundPhase = next;
      _boundPhase!.addListener(_onPhaseChanged);
    }
  }

  @override
  void dispose() {
    _farDisposeTimer?.cancel();
    _retryTimer?.cancel();
    if (_listeningPhase) {
      _boundPhase?.removeListener(_onPhaseChanged);
    }
    _disposeAd();
    super.dispose();
  }

  void _onPhaseChanged() {
    if (!mounted) return;
    if (_phase.value == FeedScrollPhase.idle) {
      _scheduleEvaluate();
      _tryAttachWhenIdle();
    }
  }

  void _scheduleEvaluate() {
    if (_scheduledEval || !mounted) return;
    _scheduledEval = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduledEval = false;
      if (mounted) _evaluateViewport();
    });
  }

  void _evaluateViewport() {
    if (!mounted || !_supported || _failed) return;
    final ro = context.findRenderObject();
    if (ro is! RenderBox || !ro.hasSize) {
      _scheduleEvaluate();
      return;
    }

    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) {
      if (!_loadStarted) _startLoad();
      return;
    }

    final viewport = RenderAbstractViewport.maybeOf(ro);
    if (viewport == null) {
      if (!_loadStarted) _startLoad();
      return;
    }

    final offset = viewport.getOffsetToReveal(ro, 0.0).offset;
    final vpDim = scrollable.position.viewportDimension;
    final pixels = scrollable.position.pixels;
    final topInViewport = offset - pixels;
    final height = ro.size.height;

    // Prefetch band: ~0.75 screen (was 1.5 — too many concurrent NativeAd loads).
    final approaching = topInViewport < vpDim * 0.75 &&
        topInViewport + height > -vpDim * 0.25;
    // Near: visible or just about to be.
    final near = topInViewport < vpDim * 1.05 &&
        topInViewport + height > -vpDim * 0.15;
    // Far sooner so platform views die while scrolling away.
    final far = topInViewport > vpDim * 1.5 ||
        topInViewport + height < -vpDim * 1.5;

    if (approaching && !_loadStarted && !_sdkReady) {
      _farDisposeTimer?.cancel();
      _farDisposeTimer = null;
      // FPS-first: do not start NativeAd.load mid-fling (SDK + platform work
      // still hits the UI isolate). Drag/idle may load; AdWidget still idle-only.
      if (_phase.value != FeedScrollPhase.flinging) {
        _startLoad();
      }
    }

    if (near && _sdkReady && !_attached) {
      _tryAttachWhenIdle();
    }

    if (far &&
        widget.keepHeightOnFailure &&
        (_sdkReady || _loadStarted || _attached) &&
        (widget.farDisposeWhenOffscreen || _isHome)) {
      // Home: free platform views quickly — reverse-fling thrash < OOM crash.
      final delay = _isHome
          ? const Duration(milliseconds: 900)
          : const Duration(seconds: 4);
      _farDisposeTimer ??= Timer(delay, () {
        if (!mounted) return;
        _disposeAd();
        setState(() {
          _sdkReady = false;
          _loadStarted = false;
          _waitingIdleAttach = false;
          // Keep attempt counter so we don't infinite-retry bad units forever,
          // but allow a fresh load when the user returns.
          if (_loadAttempts >= _maxLoadAttempts) {
            _loadAttempts = 0;
          }
        });
      });
    } else if (!far) {
      _farDisposeTimer?.cancel();
      _farDisposeTimer = null;
    }
  }

  void _tryAttachWhenIdle() {
    if (!mounted || !_sdkReady || _attached || _ad == null) return;
    if (!_scrollIdle) {
      if (_waitingIdleAttach) return;
      _waitingIdleAttach = true;
      whenScrollActivityIdle(context, () {
        _waitingIdleAttach = false;
        if (!mounted) return;
        _tryAttachWhenIdle();
      });
      return;
    }
    _attachAdWidget();
  }

  void _attachAdWidget() {
    if (_attached || _ad == null) return;
    if (_liveAttachedAds >= _maxLiveAttachedAds) {
      if (_waitingIdleAttach) return;
      _waitingIdleAttach = true;
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        _waitingIdleAttach = false;
        if (mounted) _tryAttachWhenIdle();
      });
      return;
    }
    _liveAttachedAds++;
    setState(() => _attached = true);
  }

  void _releaseAttachSlot() {
    if (!_attached) return;
    _attached = false;
    if (_liveAttachedAds > 0) _liveAttachedAds--;
  }

  void _startLoad() {
    if (_loadStarted || _failed || !_supported || _sdkReady) return;
    if (_loadAttempts >= _maxLoadAttempts) {
      _failed = true;
      if (mounted) setState(() {});
      return;
    }
    _loadStarted = true;
    _loadAttempts++;
    // Ads SDK is deferred past first paint — wait so NativeAd.load does not
    // race cold-start WebView/Dynamite with the first feed frame.
    unawaited(_loadAfterSdkReady());
  }

  Future<void> _loadAfterSdkReady() async {
    await initializeMobileAds();
    if (!mounted || _failed || _sdkReady) return;

    final ad = NativeAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          _retryTimer?.cancel();
          _ad = ad as NativeAd;
          _sdkReady = true;
          _failed = false;
          // Do not attach AdWidget mid-fling — that was the FPS drop near ads.
          if (_scrollIdle) {
            _attachAdWidget();
            if (!_attached && mounted) setState(() {});
          } else {
            setState(() {}); // keep placeholder; attach on idle
            _tryAttachWhenIdle();
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          if (kDebugMode) {
            debugPrint(
              'InFeedNativeAd failed (${widget.placement.name} #${widget.slot}) '
              'attempt $_loadAttempts/$_maxLoadAttempts: $error',
            );
          }
          // Fill rate is never 100%. Retry a few times before giving up so
          // slots don't randomly stay empty while neighbours fill.
          if (_loadAttempts < _maxLoadAttempts) {
            _releaseAttachSlot();
            setState(() {
              _sdkReady = false;
              _ad = null;
              _loadStarted = false;
              _failed = false;
            });
            _retryTimer?.cancel();
            _retryTimer = Timer(
              Duration(milliseconds: 800 * _loadAttempts),
              () {
                if (!mounted || _sdkReady || _failed) return;
                // Retry without requiring idle — improves fill / revenue.
                if (widget.deferUntilNearViewport) {
                  _scheduleEvaluate();
                } else {
                  _startLoad();
                }
              },
            );
            return;
          }
          _releaseAttachSlot();
          setState(() {
            _failed = true;
            _sdkReady = false;
            _ad = null;
            _loadStarted = false;
          });
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: _templateType,
        mainBackgroundColor: Colors.white,
        cornerRadius: _radius,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: const Color(0xFF000000),
          style: NativeTemplateFontStyle.bold,
          size: 14,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFF000000),
          style: NativeTemplateFontStyle.bold,
          size: 14,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFF525252),
          style: NativeTemplateFontStyle.normal,
          size: 12,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFF525252),
          style: NativeTemplateFontStyle.normal,
          size: 12,
        ),
      ),
    );
    ad.load();
  }

  void _disposeAd() {
    _releaseAttachSlot();
    _ad?.dispose();
    _ad = null;
  }

  Widget _shell({required Widget child}) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: child,
    );
  }

  Widget _adSurface({required Widget child, required double height}) {
    return Padding(
      padding: _padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: child,
        ),
      ),
    );
  }

  /// Card-like placeholder so empty slots still read as inventory, not a bug.
  Widget _placeholder({required String label}) {
    return ColoredBox(
      color: const Color(0xFFF3F3F3),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9E9E9E),
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_supported) {
      return const SizedBox.shrink();
    }

    if (_failed) {
      if (widget.keepHeightOnFailure) {
        return _shell(
          child: _adSurface(
            height: _adHeight,
            child: _placeholder(label: 'Ad'),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    if (!_attached || _ad == null) {
      return _shell(
        child: _adSurface(
          height: _adHeight,
          child: _placeholder(
            label: _sdkReady ? 'Ad' : 'Ad',
          ),
        ),
      );
    }

    return _shell(
      child: _adSurface(
        height: _adHeight,
        child: AdWidget(ad: _ad!),
      ),
    );
  }
}
