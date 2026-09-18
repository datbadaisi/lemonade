import 'dart:async';
import 'dart:collection';

/// Process-wide (or scoped) FIFO of work with a hard concurrency cap.
///
/// Shared by still decode and video-thumb extract so both get the same hang
/// safety: [done] exactly once, optional wall-clock watchdog, [clearPending]
/// vs [reset] (abandon in-flight via epoch).
final class ConcurrentJobQueue {
  ConcurrentJobQueue({
    required this.maxConcurrent,
    required Duration Function() jobTimeout,
  }) : _jobTimeout = jobTimeout;

  final int maxConcurrent;
  final Duration Function() _jobTimeout;

  int _inFlight = 0;
  int _epoch = 0;
  final Queue<void Function()> _queue = Queue<void Function()>();

  /// Run [job] when a slot is free. Call [done] exactly once (use `finally`).
  void schedule(void Function(void Function() done) job) {
    void run() {
      final slotEpoch = _epoch;
      _inFlight++;
      var finished = false;
      Timer? watchdog;

      void done() {
        if (finished) return;
        finished = true;
        watchdog?.cancel();
        if (slotEpoch != _epoch) return;
        _inFlight--;
        _pump();
      }

      watchdog = Timer(_jobTimeout(), done);

      try {
        job(done);
      } catch (_) {
        done();
      }
    }

    if (_inFlight < maxConcurrent) {
      run();
    } else {
      _queue.add(run);
    }
  }

  void _pump() {
    while (_inFlight < maxConcurrent && _queue.isNotEmpty) {
      _queue.removeFirst()();
    }
  }

  /// Drop **queued** jobs only — in-flight keeps the slot.
  void clearPending() => _queue.clear();

  /// Drop queue **and** abandon in-flight (frees all slots).
  void reset() {
    _queue.clear();
    _epoch++;
    _inFlight = 0;
  }

  int get pendingCount => _inFlight + _queue.length;
  int get inFlightCount => _inFlight;
  int get queueLength => _queue.length;

  /// Exposed for [ImageDecodeBudget.debugEpoch] / tests.
  int get epoch => _epoch;
}
