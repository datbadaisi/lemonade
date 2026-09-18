import 'package:flutter/material.dart';

/// Canonical navigator route for [PostDetailScreen].
///
/// Uses the platform default [MaterialPageRoute] transition (no custom slide).
Route<T> postDetailRoute<T extends Object?>({
  required WidgetBuilder builder,
  RouteSettings? settings,
}) {
  return MaterialPageRoute<T>(
    settings: settings,
    builder: builder,
  );
}
