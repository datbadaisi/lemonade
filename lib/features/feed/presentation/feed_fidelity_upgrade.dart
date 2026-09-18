import 'package:flutter/scheduler.dart';

/// Budgets full-card mounts after a fling so idle settle does not stampede
/// the UI isolate (classic “finger lifts → hitch”).
///
/// Proxies enqueue an upgrade; at most [maxPerFrame] run per frame.
final class FeedFidelityUpgradeQueue {
  FeedFidelityUpgradeQueue._();

  /// One full-card mount per frame — pairing with image paint budget avoids
  /// “upgrade + 2 image uploads” spikes on the same settle tick.
  static const int maxPerFrame = 1;

  static final List<void Function()> _pending = <void Function()>[];
  static bool _scheduled = false;

  /// Schedule [upgrade] (typically a `setState` that swaps proxy → full card).
  static void enqueue(void Function() upgrade) {
    _pending.add(upgrade);
    _ensureScheduled();
  }

  /// Drop queued work (e.g. filter change / dispose host).
  static void clear() {
    _pending.clear();
    _scheduled = false;
  }

  static void _ensureScheduled() {
    if (_scheduled || _pending.isEmpty) return;
    _scheduled = true;
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      _scheduled = false;
      var n = 0;
      while (_pending.isNotEmpty && n < maxPerFrame) {
        final job = _pending.removeAt(0);
        try {
          job();
        } catch (_) {
          // Caller must be resilient; never block the queue.
        }
        n++;
      }
      if (_pending.isNotEmpty) {
        _ensureScheduled();
      }
    });
    SchedulerBinding.instance.scheduleFrame();
  }
}
