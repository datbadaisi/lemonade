import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Frosted-glass blurred image background.
/// Used when images are letterboxed/pillarboxed to replace plain black backgrounds
/// with a modern, colorful blurred version of the image itself.
///
/// With [ambientMode] (YouTube-style), the blur is softer, more scaled-up, and a
/// radial vignette makes color appear to radiate from the center.
class BlurredImageBackground extends StatelessWidget {
  final String imageUrl;
  final double blurSigma;
  final double darkenOpacity;

  /// YouTube ambient-mode look: stronger center glow, darker edges.
  final bool ambientMode;

  const BlurredImageBackground({
    super.key,
    required this.imageUrl,
    this.blurSigma = 50,
    this.darkenOpacity = 0.25,
    this.ambientMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final sigma = ambientMode ? (blurSigma < 60 ? 80.0 : blurSigma) : blurSigma;
    final scale = ambientMode ? 2.2 : 1.5;
    final darken = ambientMode
        ? (darkenOpacity < 0.35 ? 0.45 : darkenOpacity)
        : darkenOpacity;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base black so letterbox / load failure never flashes another color
        const ColoredBox(color: Colors.black),
        // Scaled-up blurred image — scale prevents edge artifacts from blur
        ClipRect(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: sigma,
              sigmaY: sigma,
              tileMode: TileMode.decal,
            ),
            child: Transform.scale(
              scale: scale,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                // Low res is enough once heavily blurred; keeps memory cheap
                memCacheWidth: ambientMode ? 160 : 100,
                fadeInDuration: Duration.zero,
                fadeOutDuration: Duration.zero,
                errorWidget: (_, _, _) => const ColoredBox(color: Colors.black),
                placeholder: (_, _) =>
                    const ColoredBox(color: Color(0xFF000000)),
              ),
            ),
          ),
        ),
        // Darken so foreground media stays readable
        ColoredBox(color: Colors.black.withValues(alpha: darken)),
        // Radial vignette: color blooms from center, edges fall off to black
        if (ambientMode)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.05,
                colors: [
                  Color(0x00000000),
                  Color(0x66000000),
                  Color(0xCC000000),
                ],
                stops: [0.15, 0.55, 1.0],
              ),
            ),
          ),
      ],
    );
  }
}
