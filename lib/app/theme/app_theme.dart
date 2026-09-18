import 'package:flutter/material.dart';

import 'app_bar_chrome.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.canvas,
    useMaterial3: true,
    fontFamily: 'NotoSans',
    colorScheme: const ColorScheme.light(
      primary: AppColors.accent,
      surface: AppColors.card,
      surfaceContainerHighest: Color(0xFFE8E8E8),
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border),
    textTheme: const TextTheme(
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3),
      bodySmall: TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
        height: 1.5),
      labelSmall: TextStyle(fontSize: 12, color: AppColors.textSecondary),
      labelMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary)),
    appBarTheme: const AppBarTheme(
      toolbarHeight: AppBarChrome.height,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: AppColors.card,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      // Material trailing: 4dp outer so more/action icons match post-detail.
      actionsPadding: AppBarChrome.actionsPadding,
      // Explicit 24 — global [iconTheme] is 18 for in-content icons.
      iconTheme: IconThemeData(
        size: AppBarChrome.iconSize,
        color: AppColors.textPrimary,
      ),
      actionsIconTheme: IconThemeData(
        size: AppBarChrome.iconSize,
        color: AppColors.textPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: .5)),
      margin: EdgeInsets.zero),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 0),
    iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 18),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)))));
}
