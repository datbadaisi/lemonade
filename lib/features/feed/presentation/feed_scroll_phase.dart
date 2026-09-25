import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// High-level scroll activity for feed media/ad budget (not letterbox blur).
enum FeedScrollPhase { idle, dragging, flinging }

/// Process-wide phase for **Home** feed only.
///
/// [HomeScreen] is the sole writer (via [FeedScrollPhaseController]). In-feed
/// Feed widgets use this listenable. Secondary surfaces pass their **own**
/// [ValueNotifier] into [FeedScrollPhaseController] — never this global.
///
/// **Not** a Riverpod provider — cards must not mass-rebuild on phase flips.
final ValueNotifier<FeedScrollPhase> feedScrollPhaseListenable =
    ValueNotifier<FeedScrollPhase>(FeedScrollPhase.idle);

/// Converts [ScrollNotification]s into phase edges with hysteresis.
///
/// - → flinging when |velocity| > [flingVelocity] or large scroll delta
/// - → idle after [idleHysteresis] with near-zero velocity
///
/// Prefer constructing with an explicit [listenable]. Home passes
/// [feedScrollPhaseListenable]; other surfaces use a private notifier.
final class FeedScrollPhaseController {
  FeedScrollPhaseController({
    this.flingVelocity = 1000,
    // Slightly longer than a single frame lull so proxy→full upgrades do not
    // fire on micro-pauses mid-drag (felt like periodic hitches).
    this.idleHysteresis = const Duration(milliseconds: 220),
    ValueNotifier<FeedScrollPhase>? listenable,
  }) : listenable = listenable ?? feedScrollPhaseListenable;

  final double flingVelocity;
  final Duration idleHysteresis;
  final ValueNotifier<FeedScrollPhase> listenable;

  Timer? _idleTimer;
  bool _disposed = false;

  void dispose() {
    _disposed = true;
    _idleTimer?.cancel();
    _idleTimer = null;
    if (listenable.value != FeedScrollPhase.idle) {
      listenable.value = FeedScrollPhase.idle;
    }
  }

  /// Call from [ScrollController] listener (coarse; notifications refine phase).
  void onScrollMetrics(ScrollPosition position) {
    if (_disposed) return;
    if (position.isScrollingNotifier.value) {
      _cancelIdle();
      if (listenable.value == FeedScrollPhase.idle) {
        _set(FeedScrollPhase.dragging);
      }
    }
  }

  bool onNotification(ScrollNotification notification) {
    if (_disposed) return false;

    if (notification is ScrollStartNotification) {
      _cancelIdle();
      _set(FeedScrollPhase.dragging);
    } else if (notification is ScrollUpdateNotification) {
      _cancelIdle();
      final delta = notification.scrollDelta?.abs() ?? 0.0;
      // Large per-frame delta ≈ fling; small delta = drag.
      if (delta > 28) {
        _set(FeedScrollPhase.flinging);
      } else if (listenable.value != FeedScrollPhase.flinging) {
        _set(FeedScrollPhase.dragging);
      }
    } else if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.idle) {
        _scheduleIdle();
      }
    } else if (notification is ScrollEndNotification) {
      _scheduleIdle();
    }
    return false;
  }

  void _set(FeedScrollPhase phase) {
    if (listenable.value != phase) {
      listenable.value = phase;
    }
  }

  void _cancelIdle() {
    _idleTimer?.cancel();
    _idleTimer = null;
  }

  void _scheduleIdle() {
    _cancelIdle();
    _idleTimer = Timer(idleHysteresis, () {
      if (_disposed) return;
      _set(FeedScrollPhase.idle);
    });
  }
}
