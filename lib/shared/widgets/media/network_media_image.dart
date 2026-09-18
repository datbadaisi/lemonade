import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:bluerum/shared/widgets/media/media_precache.dart';
import 'package:bluerum/shared/widgets/media/scroll_stable_network_image.dart';

/// Network still for post media (images + video posters).
///
/// Prefer fixed-frame [ScrollStableNetworkImage] for lists. When [scrollStable]
/// is true, this widget resolves finite constraints (explicit [height] or
/// [LayoutBuilder]) so list/detail AspectRatio parents always hit the
/// budgeted path — no magic "height must be non-null" call-site folklore.
class NetworkMediaImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final int? memCacheWidth;
  final Alignment alignment;
  final double? width;
  final double? height;
  final String? semanticLabel;
  final Widget Function(BuildContext context)? placeholder;
  final Widget Function(BuildContext context)? errorWidget;
  final Duration fadeInDuration;

  /// When true (default), use cache-then-paint + scroll gate when a finite
  /// frame can be resolved.
  final bool scrollStable;

  const NetworkMediaImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.memCacheWidth,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.semanticLabel,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = Duration.zero,
    this.scrollStable = true,
  });

  @override
  Widget build(BuildContext context) {
    final cacheWidth = memCacheWidth ?? inPageMediaMemCacheWidth(context);

    if (!scrollStable) {
      return _flexibleCni(context, cacheWidth);
    }

    // Explicit height → direct scroll-stable.
    if (height != null) {
      return ScrollStableNetworkImage(
        imageUrl: imageUrl,
        memCacheWidth: cacheWidth,
        fit: fit,
        alignment: alignment,
        width: width ?? double.infinity,
        height: height,
        errorWidget: errorWidget,
        semanticLabel: semanticLabel,
      );
    }

    // AspectRatio / Expanded parents: resolve frame then scroll-stable.
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = (width != null && width!.isFinite)
            ? width!
            : (constraints.maxWidth.isFinite && constraints.maxWidth > 0
                ? constraints.maxWidth
                : double.infinity);
        final h = constraints.maxHeight;
        if (h.isFinite && h > 0) {
          return ScrollStableNetworkImage(
            imageUrl: imageUrl,
            memCacheWidth: cacheWidth,
            fit: fit,
            alignment: alignment,
            width: w,
            height: h,
            errorWidget: errorWidget,
            semanticLabel: semanticLabel,
          );
        }
        return _flexibleCni(context, cacheWidth);
      },
    );
  }

  Widget _flexibleCni(BuildContext context, int cacheWidth) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      alignment: alignment,
      width: width ?? double.infinity,
      height: height,
      memCacheWidth: cacheWidth,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      useOldImageOnUrlChange: true,
      placeholder: (_, _) =>
          placeholder?.call(context) ??
          const ColoredBox(color: Color(0xFFE8E8E8)),
      errorWidget: (_, _, _) =>
          errorWidget?.call(context) ?? const SizedBox.shrink(),
    );
  }
}
