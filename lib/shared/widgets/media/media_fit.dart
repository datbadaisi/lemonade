import 'package:flutter/material.dart';

/// Fit [aspect] (width/height) inside [maxW]×[maxH], preserving the full image.
///
/// Social “show the whole picture” layout (scale-to-fit / aspect-fit /
/// CSS `object-fit: contain`):
/// - landscape → uses full [maxW], shorter height
/// - portrait → may **narrow** width so the whole height still fits [maxH]
/// - small images → **scale up** until one side hits the box
///
/// Never crops. Never forces a fixed 16:9 frame.
Size fitCommentMediaSize({
  required double aspect,
  required double maxW,
  required double maxH,
}) {
  var r = aspect;
  if (r <= 0 || !r.isFinite) r = 16 / 9;
  // Clamp extremes so one pathological pixel-ratio cannot dominate the list.
  r = r.clamp(0.2, 5.0);

  final byWidth = Size(maxW, maxW / r);
  if (byWidth.height <= maxH + 0.5) {
    return Size(byWidth.width.clamp(1.0, maxW), byWidth.height);
  }
  // Height-capped: shrink width so the full image still fits.
  final w = (maxH * r).clamp(1.0, maxW);
  return Size(w, maxH);
}
