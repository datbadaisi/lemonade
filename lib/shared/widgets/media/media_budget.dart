import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:bluerum/shared/widgets/media/concurrent_job_queue.dart';
import 'package:bluerum/shared/widgets/media/media_precache.dart';
import 'package:bluerum/shared/widgets/media/video_thumbnail_cache.dart';

/// Quiet window after a page push/pop before re-arming list media / heavy UI.
///
/// Slightly longer than a typical Material push (~280ms) so settle and feed
/// re-arm land after the transition frames, not during them.
const Duration mediaRouteTransitionQuiet = Duration(milliseconds: 320);

/// Bumped when decode/paint/video queues are flushed so list tiles can re-arm.
///
/// Widgets that already started a request would otherwise stay on the gray
/// placeholder until dispose/remount.
final class MediaBudgetEpoch {
  MediaBudgetEpoch._();

  static final ValueNotifier<int> listenable = ValueNotifier<int>(0);

  static Timer? _deferredBumpTimer;

  static void bump() => listenable.value++;

  /// Re-arm after [mediaRouteTransitionQuiet] (or [delay]).
  static void bumpDeferred({Duration delay = mediaRouteTransitionQuiet}) {
    _deferredBumpTimer?.cancel();
    _deferredBumpTimer = Timer(delay, () {
      _deferredBumpTimer = null;
      bump();
    });
  }

  /// Cancel a pending [bumpDeferred] (e.g. user opened detail again quickly).
  static void cancelDeferredBump() {
    _deferredBumpTimer?.cancel();
    _deferredBumpTimer = null;
  }
}

/// Canonical recovery for hung decode/paint/video-thumb work.
///
/// Prefer this over hand-rolling partial clears in feature screens.
///
/// - [abandonInFlight]: `true` → free decode slot (PTR / hang). `false` →
///   drop queued decode only (sheet dismiss under live list).
/// - [clearVideoPending]: drop queued MediaCodec extracts.
/// - [clearVideoRam]: drop in-memory video stills (deep jump only).
void recoverMediaBudgets({
  bool notify = true,
  bool abandonInFlight = true,
  bool clearVideoPending = true,
  bool clearVideoRam = false,
}) {
  if (abandonInFlight) {
    ImageDecodeBudget.reset(notify: false);
  } else {
    ImageDecodeBudget.clearPending(notify: false);
  }
  ImagePaintBudget.clearPending(notify: false);
  if (clearVideoPending) {
    VideoThumbnailCache.clearPending();
  }
  if (clearVideoRam) {
    VideoThumbnailCache.clear();
  }
  if (notify) MediaBudgetEpoch.bump();
}

/// PTR / full-list refresh protocol: abandon hung slot, run [work], then re-arm.
Future<void> runWithMediaBudgetRecovery(
  Future<void> Function() work, {
  required bool Function() isMounted,
}) async {
  recoverMediaBudgets(notify: false);
  try {
    await work();
  } finally {
    if (isMounted()) MediaBudgetEpoch.bump();
  }
}

/// Free decode/paint/video work left by a disposed route **without** an
/// immediate feed re-arm (which fights the next open transition).
void softRecoverMediaBudgets({bool reArmFeedWhenIdle = true}) {
  recoverMediaBudgets(notify: false, abandonInFlight: true);
  if (reArmFeedWhenIdle) {
    MediaBudgetEpoch.bumpDeferred();
  }
}

/// Caps concurrent image **decodes** so settle does not stampede the UI isolate.
///
/// Process-wide (feed + detail + comments). Built on [ConcurrentJobQueue].
final class ImageDecodeBudget {
  ImageDecodeBudget._();

  /// One at a time on mid-range Android — two concurrent still hitch.
  static const int maxConcurrent = 1;

  static Duration get jobTimeout => _jobTimeout;
  static Duration _jobTimeout = mediaPrecacheTimeout;

  static final ConcurrentJobQueue _queue = ConcurrentJobQueue(
    maxConcurrent: maxConcurrent,
    jobTimeout: () => _jobTimeout,
  );

  /// Run [job] when a slot is free. Call [done] exactly once (use `finally`).
  static void schedule(void Function(void Function() done) job) =>
      _queue.schedule(job);

  /// Drop **queued** jobs only — in-flight keeps the slot.
  static void clearPending({bool notify = true}) {
    _queue.clearPending();
    if (notify) MediaBudgetEpoch.bump();
  }

  /// Drop queue **and** abandon in-flight (frees the global slot).
  static void reset({bool notify = true}) {
    _queue.reset();
    if (notify) MediaBudgetEpoch.bump();
  }

  static int get pendingCount => _queue.pendingCount;
  static int get inFlightCount => _queue.inFlightCount;
  static int get queueLength => _queue.queueLength;

  @visibleForTesting
  static int get debugEpoch => _queue.epoch;

  @visibleForTesting
  static set debugJobTimeout(Duration value) => _jobTimeout = value;

  @visibleForTesting
  static void debugRestoreDefaults() {
    _jobTimeout = mediaPrecacheTimeout;
    reset(notify: false);
  }
}

/// Caps how many images may flip placeholder → painted **per frame**.
final class ImagePaintBudget {
  ImagePaintBudget._();

  static const int maxPerFrame = 1;
  static int _paintedThisFrame = 0;
  static bool _frameScheduled = false;
  static final Queue<void Function()> _queue = Queue<void Function()>();

  static void schedule(void Function() paint) {
    _queue.add(paint);
    _pump();
  }

  static void _pump() {
    if (_queue.isEmpty) return;

    if (_paintedThisFrame >= maxPerFrame) {
      _scheduleNextFrame();
      return;
    }

    _paintedThisFrame++;
    final job = _queue.removeFirst();
    try {
      job();
    } catch (_) {
      // Caller must be resilient.
    }

    if (_queue.isNotEmpty) {
      _scheduleNextFrame();
    }
  }

  static void _scheduleNextFrame() {
    if (_frameScheduled) return;
    _frameScheduled = true;
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      _frameScheduled = false;
      _paintedThisFrame = 0;
      _pump();
    });
    SchedulerBinding.instance.scheduleFrame();
  }

  static void clearPending({bool notify = true}) {
    _queue.clear();
    if (notify) MediaBudgetEpoch.bump();
  }

  static int get queueLength => _queue.length;

  @visibleForTesting
  static void debugResetForTest() {
    _queue.clear();
    _paintedThisFrame = 0;
    _frameScheduled = false;
  }
}

/// True while any ancestor [Scrollable] is dragging **or** ballistic (fling).
bool scrollActivityBusy(BuildContext context) {
  final scrollable = Scrollable.maybeOf(context);
  if (scrollable == null) return false;
  try {
    return scrollable.position.isScrollingNotifier.value;
  } catch (_) {
    return false;
  }
}

/// Resume [onIdle] once ancestor scroll activity stops (or next frame if none).
///
/// **Never** invokes [onIdle] synchronously.
void whenScrollActivityIdle(BuildContext context, VoidCallback onIdle) {
  final scrollable = Scrollable.maybeOf(context);
  if (scrollable == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) onIdle();
    });
    return;
  }

  ValueNotifier<bool> scrolling;
  try {
    scrolling = scrollable.position.isScrollingNotifier;
  } catch (_) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) onIdle();
    });
    return;
  }

  late final void Function() armListener;

  void fireIdle() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      if (scrolling.value) {
        armListener();
        return;
      }
      onIdle();
    });
  }

  armListener = () {
    if (!scrolling.value) {
      fireIdle();
      return;
    }
    late final VoidCallback listener;
    listener = () {
      if (!scrolling.value) {
        scrolling.removeListener(listener);
        fireIdle();
      }
    };
    scrolling.addListener(listener);
  };

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    armListener();
  });
}
