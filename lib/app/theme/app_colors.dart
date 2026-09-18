import 'package:flutter/material.dart';

abstract final class AppColors {
  /// OLED pure black — icons, primary text, filled CTAs (add post, etc.).
  static const accent = Color(0xFF000000);
  static const canvas = Color(0xFFFFFFFF);
  static const card = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF000000);
  /// Meta / secondary — same as PostCard feed system.
  static const textSecondary = Color(0xFF525252);
  static const border = Color(0xFFE0E0E0);
  static const danger = Color(0xFFE53935);

  /// Interactive blue app-wide (Full Post, links, subscribe, upvote, etc.).
  static const action = Color(0xFF24A0ED);

  /// Active downvote — warm orange complementary to [action] blue.
  static const downvote = Color(0xFFFF8700);

  /// OP (original poster) username only — not used for other UI.
  static const op = Color(0xFF0079D3);
}
