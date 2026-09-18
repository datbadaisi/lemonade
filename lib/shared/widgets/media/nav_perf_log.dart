import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'package:bluerum/shared/widgets/media/media_budget.dart';

/// Profile-mode navigation + media timing for home ↔ post-detail jank.
///
/// Enable with either define (same flag as feed for convenience):
/// ```
/// flutter run --profile --dart-define=FEED_PERF_LOG=true
/// flutter run --profile --dart-define=NAV_PERF_LOG=true
/// ```
///
/// Prefer route-boundary sessions ([beginSession]/[endSession]) over
/// sprinkling [mark] through product control flow.
///
/// Logcat: `adb logcat -s flutter nav_perf` or `findstr /i nav_perf`.
final class NavPerfLog {
  NavPerfLog._();

  static const bool enabled = bool.fromEnvironment(
        'NAV_PERF_LOG',
        defaultValue: false,
      ) ||
      bool.fromEnvironment(
        'FEED_PERF_LOG',
        defaultValue: false,
      );

  static const Duration _budget60Hz = Duration(microseconds: 16670);
  static const Duration _hardJank = Duration(milliseconds: 32);

  static bool _attached = false;
  static String? _session;
  static int _sessionStartUs = 0;
  static int _sessionFrames = 0;
  static int _sessionJanky = 0;
  static int _sessionHard = 0;
  static int _sessionWorstUs = 0;

  static final Stopwatch _clock = Stopwatch()..start();

  static int get _nowUs => _clock.elapsedMicroseconds;

  static void ensureAttached() {
    if (!enabled || kReleaseMode || _attached) return;
    _attached = true;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    _log(
      'ATTACHED budget60=${_budget60Hz.inMilliseconds}ms '
      'hardJank=${_hardJank.inMilliseconds}ms',
    );
  }

  /// Start a labeled window (e.g. open_post). Ends any prior session.
  static void beginSession(String name, {Map<String, Object?>? data}) {
    if (!enabled || kReleaseMode) return;
    ensureAttached();
    if (_session != null) {
      endSession(reason: 'superseded_by_$name');
    }
    _session = name;
    _sessionStartUs = _nowUs;
    _sessionFrames = 0;
    _sessionJanky = 0;
    _sessionHard = 0;
    _sessionWorstUs = 0;
    _log('SESSION_BEGIN $name${_fmt(data)} t0=0ms');
  }

  static void endSession({String reason = 'done'}) {
    if (!enabled || kReleaseMode || _session == null) return;
    final name = _session!;
    final elapsedMs = (_nowUs - _sessionStartUs) / 1000.0;
    final worstMs = _sessionWorstUs / 1000.0;
    _log(
      'SESSION_END $name reason=$reason '
      'elapsedMs=${elapsedMs.toStringAsFixed(1)} '
      'frames=$_sessionFrames janky=$_sessionJanky hard=$_sessionHard '
      'worstMs=${worstMs.toStringAsFixed(1)} '
      'decodeInFlight=${ImageDecodeBudget.inFlightCount} '
      'decodeQ=${ImageDecodeBudget.queueLength} '
      'paintQ=${ImagePaintBudget.queueLength}',
    );
    _session = null;
  }

  static void _onTimings(List<FrameTiming> timings) {
    for (final t in timings) {
      final buildUs = t.buildDuration.inMicroseconds;
      final rasterUs = t.rasterDuration.inMicroseconds;
      final totalUs = buildUs + rasterUs;
      final vsyncOverheadUs = t.vsyncOverhead.inMicroseconds;

      if (_session != null) {
        _sessionFrames++;
        if (totalUs > _sessionWorstUs) _sessionWorstUs = totalUs;
        if (totalUs > _budget60Hz.inMicroseconds) _sessionJanky++;
        if (totalUs > _hardJank.inMicroseconds) _sessionHard++;
      }

      final hard = totalUs > _hardJank.inMicroseconds;
      final mild = totalUs > _budget60Hz.inMicroseconds;
      if (!hard && !(_session != null && mild)) continue;

      final tag = hard ? 'HARD_JANK' : 'JANK';
      final tMs = _session != null
          ? (_nowUs - _sessionStartUs) / 1000.0
          : _nowUs / 1000.0;
      final session = _session ?? '-';
      _log(
        '$tag @$session +${tMs.toStringAsFixed(1)}ms '
        'totalMs=${(totalUs / 1000.0).toStringAsFixed(1)} '
        'buildMs=${(buildUs / 1000.0).toStringAsFixed(1)} '
        'rasterMs=${(rasterUs / 1000.0).toStringAsFixed(1)} '
        'vsyncOverheadMs=${(vsyncOverheadUs / 1000.0).toStringAsFixed(1)} '
        'decodeInFlight=${ImageDecodeBudget.inFlightCount} '
        'decodeQ=${ImageDecodeBudget.queueLength} '
        'paintQ=${ImagePaintBudget.queueLength}',
      );
    }
  }

  static String _fmt(Map<String, Object?>? data) {
    if (data == null || data.isEmpty) return '';
    final parts = data.entries.map((e) => '${e.key}=${e.value}').join(' ');
    return ' $parts';
  }

  static void _log(String message) {
    // print ensures logcat capture even when developer.log filtering varies.
    // ignore: avoid_print
    print('[nav_perf] $message');
    developer.log(message, name: 'nav_perf');
  }
}
