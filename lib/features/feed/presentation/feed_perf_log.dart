import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Profile-mode frame timing helper for home-feed smoothness work.
///
/// Enable with:
/// `flutter run --profile --dart-define=FEED_PERF_LOG=true`
///
/// Logs UI/raster frame times; flags frames over ~16.7 ms (60 Hz budget).
final class FeedPerfLog {
  FeedPerfLog._();

  static const bool enabled = bool.fromEnvironment(
    'FEED_PERF_LOG',
    defaultValue: false,
  );

  static const Duration _budget60Hz = Duration(microseconds: 16670);

  static bool _attached = false;
  static int _frames = 0;
  static int _janky = 0;
  static int _worstUs = 0;

  /// Attach once (safe to call multiple times). No-op in release / when disabled.
  static void ensureAttached() {
    if (!enabled || kReleaseMode || _attached) return;
    _attached = true;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    developer.log(
      'FeedPerfLog attached (60 Hz budget ${_budget60Hz.inMicroseconds}µs)',
      name: 'feed_perf',
    );
  }

  static void resetSession() {
    _frames = 0;
    _janky = 0;
    _worstUs = 0;
  }

  static void _onTimings(List<FrameTiming> timings) {
    for (final t in timings) {
      final totalUs =
          t.buildDuration.inMicroseconds + t.rasterDuration.inMicroseconds;
      _frames++;
      if (totalUs > _worstUs) _worstUs = totalUs;
      if (totalUs > _budget60Hz.inMicroseconds) {
        _janky++;
      }
    }
    // Periodic summary every ~120 frames (~2s at 60 Hz).
    if (_frames > 0 && _frames % 120 == 0) {
      final pct = (_janky * 1000 ~/ _frames) / 10.0;
      developer.log(
        'frames=$_frames janky=$_janky ($pct%) worstMs=${_worstUs / 1000.0}',
        name: 'feed_perf',
      );
    }
  }

  /// Snapshot for PR descriptions / manual baseline tables.
  static String summary() {
    if (_frames == 0) return 'FeedPerfLog: no frames yet';
    final pct = (_janky * 1000 ~/ _frames) / 10.0;
    return 'FeedPerfLog: frames=$_frames janky=$_janky ($pct%) '
        'worstMs=${(_worstUs / 1000.0).toStringAsFixed(1)}';
  }
}
