import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import 'package:bluerum/shared/widgets/media/media_precache.dart';
import 'package:bluerum/shared/widgets/media/network_media_image.dart';
import 'package:bluerum/shared/widgets/media/scroll_stable_network_image.dart';
import 'package:bluerum/shared/widgets/skeleton/skeleton.dart';

/// Post-card still with proxy↔origin fallback and optional progressive full-res.
///
/// List path ([listDecode]): fixed-frame [ScrollStableNetworkImage] only.
/// Detail path may progressive dual-layer when [allowProgressiveFullRes].
class PostStillImage extends StatefulWidget {
  const PostStillImage({
    super.key,
    required this.url,
    this.fullResUrl,
    this.fallbackUrl,
    required this.altText,
    this.fit = BoxFit.cover,
    this.listDecode = false,
    this.memCacheWidth,
    this.allowProgressiveFullRes = true,
    this.placeholderColor = const Color(0xFFE8E8E8),
  });

  final String url;
  final String? fullResUrl;

  /// Tried automatically when [url] fails (e.g. image_proxy ↔ origin CDN).
  final String? fallbackUrl;
  final String altText;
  final BoxFit fit;

  /// Feed / list: LayoutBuilder → ScrollStable, solid gray placeholder.
  final bool listDecode;
  final int? memCacheWidth;

  /// Progressive dual-layer full-res (detail only; off on feed).
  final bool allowProgressiveFullRes;

  final Color placeholderColor;

  @override
  State<PostStillImage> createState() => _PostStillImageState();
}

class _PostStillImageState extends State<PostStillImage> {
  int _retryKey = 0;

  /// 0 = primary [url], 1 = [fallbackUrl] after a load/decode error.
  int _urlIndex = 0;

  static const Color _textSecondary = Color(0xFF525252);

  @override
  void didUpdateWidget(covariant PostStillImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        oldWidget.fallbackUrl != widget.fallbackUrl) {
      _urlIndex = 0;
      _retryKey++;
    }
  }

  String get _activeUrl {
    if (_urlIndex > 0 &&
        widget.fallbackUrl != null &&
        widget.fallbackUrl!.isNotEmpty &&
        widget.fallbackUrl != widget.url) {
      return widget.fallbackUrl!;
    }
    return widget.url;
  }

  void _retry() {
    if (!mounted) return;
    setState(() {
      _urlIndex = 0;
      _retryKey++;
    });
  }

  void _onLoadError() {
    if (!mounted) return;
    final fallback = widget.fallbackUrl;
    if (_urlIndex == 0 &&
        fallback != null &&
        fallback.isNotEmpty &&
        fallback != widget.url) {
      setState(() {
        _urlIndex = 1;
        _retryKey++;
      });
    }
  }

  bool get _hasUsableFallback =>
      _urlIndex == 0 &&
      widget.fallbackUrl != null &&
      widget.fallbackUrl!.isNotEmpty &&
      widget.fallbackUrl != widget.url;

  Widget _buildErrorWidget() {
    return GestureDetector(
      onTap: _retry,
      child: ColoredBox(
        color: widget.placeholderColor,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                MingCuteIcons.mgc_pic_2_line,
                size: 32,
                color: _textSecondary,
              ),
              SizedBox(height: 8),
              Text(
                'Tap to retry',
                style: TextStyle(fontSize: 12, color: _textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorDuringBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _onLoadError());
    if (_hasUsableFallback) {
      return const ShimmerPlaceholder.fill();
    }
    return _buildErrorWidget();
  }

  @override
  Widget build(BuildContext context) {
    final activeUrl = _activeUrl;
    final cacheWidth =
        widget.memCacheWidth ?? inPageMediaMemCacheWidth(context);
    final hasFullRes =
        widget.allowProgressiveFullRes &&
        widget.fullResUrl != null &&
        widget.fullResUrl != activeUrl &&
        widget.fullResUrl!.isNotEmpty;

    if (!hasFullRes) {
      if (widget.listDecode) {
        return Semantics(
          image: true,
          label: widget.altText,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              if (!w.isFinite || !h.isFinite || w <= 0 || h <= 0) {
                return ColoredBox(
                  color: widget.placeholderColor,
                  child: _errorDuringBuild(),
                );
              }
              return ScrollStableNetworkImage(
                key: ValueKey('img_${activeUrl}_$_retryKey'),
                imageUrl: activeUrl,
                memCacheWidth: cacheWidth,
                fit: widget.fit,
                width: w,
                height: h,
                placeholderColor: widget.placeholderColor,
                semanticLabel: widget.altText,
                errorWidget: (_) => _errorDuringBuild(),
              );
            },
          ),
        );
      }

      return Semantics(
        image: true,
        label: widget.altText,
        child: NetworkMediaImage(
          key: ValueKey('img_${activeUrl}_$_retryKey'),
          imageUrl: activeUrl,
          fit: widget.fit,
          memCacheWidth: cacheWidth,
          errorWidget: (_) => _errorDuringBuild(),
        ),
      );
    }

    // Progressive: thumbnail bottom layer, full-res fades in on top (detail).
    return Semantics(
      image: true,
      label: widget.altText,
      child: Stack(
        fit: StackFit.expand,
        children: [
          NetworkMediaImage(
            key: ValueKey('thumb_${activeUrl}_$_retryKey'),
            imageUrl: activeUrl,
            fit: widget.fit,
            memCacheWidth: cacheWidth,
            errorWidget: (_) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _onLoadError(),
              );
              if (_hasUsableFallback) {
                return const ShimmerPlaceholder.fill();
              }
              return _buildErrorWidget();
            },
          ),
          Positioned.fill(
            child: NetworkMediaImage(
              key: ValueKey('full_${widget.fullResUrl}_$_retryKey'),
              imageUrl: widget.fullResUrl!,
              fit: widget.fit,
              memCacheWidth: cacheWidth,
              placeholder: (_) => const SizedBox.shrink(),
              errorWidget: (_) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
