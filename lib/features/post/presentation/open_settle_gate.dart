import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:bluerum/shared/widgets/media/media_budget.dart';

/// Wall-clock gate for “do not mount heavy UI until the push transition is quiet.”
///
/// Profile work showed [AnimationStatus.completed] firing far too early on our
/// custom route, so this uses [mediaRouteTransitionQuiet] rather than the route
/// animation status.
final class OpenSettleGate {
  OpenSettleGate({this.duration = mediaRouteTransitionQuiet});

  final Duration duration;

  bool _settled = false;
  Timer? _timer;
  Completer<void>? _completer;

  bool get settled => _settled;

  Future<void> get whenSettled {
    if (_settled) return Future.value();
    return (_completer ??= Completer<void>()).future;
  }

  /// Starts the quiet window. [onSettled] runs once when the timer fires.
  void schedule({
    required bool Function() isMounted,
    required VoidCallback onSettled,
  }) {
    _timer?.cancel();
    _timer = Timer(duration, () {
      if (!isMounted() || _settled) return;
      complete(onSettled: onSettled);
    });
  }

  /// Marks settled and runs [onSettled] if this is the first completion.
  void complete({VoidCallback? onSettled}) {
    if (_settled) return;
    _settled = true;
    _timer?.cancel();
    _timer = null;
    onSettled?.call();
    final c = _completer;
    _completer = null;
    if (c != null && !c.isCompleted) c.complete();
  }

  /// Cancels the timer and releases waiters without marking [settled].
  void dispose() {
    _timer?.cancel();
    _timer = null;
    final c = _completer;
    _completer = null;
    if (c != null && !c.isCompleted) c.complete();
  }
}
