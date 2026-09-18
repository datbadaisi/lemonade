import 'package:flutter/material.dart';

/// Shared top-app-bar metrics for every screen with back / more chrome.
///
/// Matches Material mobile keylines used on post detail:
/// - toolbar content height 56
/// - leading slot 56 (48 [IconButton] + ~4 outer)
/// - trailing [actionsPadding] end 4 so the more icon sits ~16 from the edge
/// - glyph size 24 (do not inherit app-wide [IconTheme] 18)
abstract final class AppBarChrome {
  static const double height = kToolbarHeight; // 56
  static const double leadingWidth = 56;

  /// Material standard toolbar icon size (back, more, settings in chrome).
  static const double iconSize = 24;

  /// Outer pad after the trailing action (Material toolbar horizontal pad).
  static const EdgeInsetsGeometry actionsPadding =
      EdgeInsetsDirectional.only(end: 4);

  /// Start pad before a leading control in a custom (non-[AppBar]) row.
  static const double leadingOuterPad = 4;
}
