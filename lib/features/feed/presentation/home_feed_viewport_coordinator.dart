import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/features/shell/presentation/shell_chrome.dart';
import 'package:bluerum/shared/widgets/media/scroll_stable_network_image.dart';
import 'package:bluerum/shared/widgets/post_list/post_list_idle_precache.dart';
import 'package:bluerum/shared/widgets/post_list/post_list_memory.dart';

import 'feed_controller.dart';

/// Single owner for Home jump / settle / media-trim / PTR / filter pipelines.
///
/// Double-tap Home and sort/type changes used to duplicate the same deep-jump
/// hazard handling. One coordinator keeps that behavior and deletes the fork.
final class HomeFeedViewportCoordinator {
  HomeFeedViewportCoordinator({
    required this.scrollController,
    required this.memoryPolicy,
    required this.idlePrecache,
    required this.isMounted,
    required this.setState,
    required this.refreshIndicatorKey,
  });

  final ScrollController scrollController;
  final PostListMemoryPolicy memoryPolicy;
  final PostListIdlePrecache idlePrecache;
  final bool Function() isMounted;
  final void Function(VoidCallback fn) setState;
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;

  /// Offset above this is "far from top" — jump first, then reload/refresh.
  static const double farFromTopThreshold = 48.0;

  bool programmaticRefreshRunning = false;
  bool filterChangeRunning = false;

  /// Locks list physics only during the jump phase of double-tap Home.
  /// Must be false before [RefreshIndicatorState.show] so overscroll works.
  bool lockScrollDuringJump = false;

  String? _pendingFilterSort;
  String? _pendingFilterType;

  bool get isBusy => programmaticRefreshRunning || filterChangeRunning;

  void cancelPaginationPressure({required VoidCallback onCancelLoadMore}) {
    onCancelLoadMore();
  }

  void clearListCaches() {
    idlePrecache.clear();
  }

  void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  /// Drop queued media work and (optionally) ImageCache contents so jump /
  /// refresh do not pile on top of bitmaps from deep scroll.
  ///
  /// [notifyBudgetFlush]: when false, dropped jobs do not ask mounted tiles
  /// to re-request (use before a jump that disposes them).
  void trimFeedRuntimeMemory({
    required bool aggressive,
    bool notifyBudgetFlush = true,
  }) {
    recoverMediaBudgets(
      notify: notifyBudgetFlush,
      clearVideoRam: aggressive,
    );
    idlePrecache.clear();
    if (aggressive) {
      final cache = PaintingBinding.instance.imageCache;
      cache.clear();
      cache.clearLiveImages();
    }
  }

  Future<void> waitForListJumpSettle() async {
    await WidgetsBinding.instance.endOfFrame;
    if (!isMounted()) return;
    await WidgetsBinding.instance.endOfFrame;
    if (!isMounted()) return;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (!isMounted()) return;
    await WidgetsBinding.instance.endOfFrame;
  }

  Future<void> _setLockScroll(bool locked) async {
    if (lockScrollDuringJump == locked) return;
    if (isMounted()) {
      setState(() => lockScrollDuringJump = locked);
    } else {
      lockScrollDuringJump = locked;
    }
    await WidgetsBinding.instance.endOfFrame;
  }

  /// Shared deep/near-top viewport reset used by PTR and filter changes.
  Future<void> resetViewportForReload({
    required bool awaitSheetDismiss,
    required bool lockPhysicsForJump,
    required bool bumpMediaEpochAfterDeepJump,
  }) async {
    if (awaitSheetDismiss) {
      // Modal bottom sheet dismiss is ~200–250ms; do not clear keep-alives
      // or replace the list until that paint work is done.
      await WidgetsBinding.instance.endOfFrame;
      if (!isMounted()) return;
      await WidgetsBinding.instance.endOfFrame;
      if (!isMounted()) return;
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (!isMounted()) return;
    }

    final needsJump = scrollController.hasClients &&
        scrollController.offset > farFromTopThreshold;

    if (needsJump) {
      memoryPolicy.clear();
      // notify:false — deep tiles unmount on jump; avoid re-queue stampede.
      trimFeedRuntimeMemory(aggressive: true, notifyBudgetFlush: false);
      if (lockPhysicsForJump) {
        await _setLockScroll(true);
        if (!isMounted()) return;
      } else {
        await WidgetsBinding.instance.endOfFrame;
        if (!isMounted()) return;
      }
      scrollToTop();
      await waitForListJumpSettle();
      if (!isMounted()) return;
      // Top tiles just mounted — re-arm any decode that lost a race.
      if (bumpMediaEpochAfterDeepJump && isMounted()) {
        MediaBudgetEpoch.bump();
      }
    } else if (scrollController.hasClients && scrollController.offset > 0) {
      if (lockPhysicsForJump) {
        await _setLockScroll(true);
        if (!isMounted()) return;
      }
      scrollToTop();
      await WidgetsBinding.instance.endOfFrame;
      if (!isMounted()) return;
    }
  }

  /// Double-tap Home: scroll to top then refresh with the same PTR chrome as
  /// a finger pull — staggered, like major apps.
  Future<void> runProgrammaticPullRefresh({
    required WidgetRef ref,
    required VoidCallback cancelLoadMore,
  }) async {
    if (!isMounted() || isBusy) return;
    programmaticRefreshRunning = true;
    cancelLoadMore();
    ShellChrome.instance.resetHide();

    try {
      final needsJump = scrollController.hasClients &&
          scrollController.offset > farFromTopThreshold;

      if (needsJump) {
        trimFeedRuntimeMemory(aggressive: true, notifyBudgetFlush: false);
        memoryPolicy.clear();
        await _setLockScroll(true);
        if (!isMounted()) return;
        scrollToTop();
        await waitForListJumpSettle();
        if (!isMounted()) return;
      } else {
        // Near top: keep ImageCache so visible photos do not flash gray.
        recoverMediaBudgets(notify: false, clearVideoRam: false);
        idlePrecache.clear();
        if (scrollController.hasClients && scrollController.offset > 0) {
          await _setLockScroll(true);
          if (!isMounted()) return;
          scrollToTop();
          await WidgetsBinding.instance.endOfFrame;
          if (!isMounted()) return;
        }
      }

      // Unlock so RefreshIndicator can drive overscroll chrome.
      if (lockScrollDuringJump) {
        await _setLockScroll(false);
        if (!isMounted()) return;
      }

      final indicator = refreshIndicatorKey.currentState;
      if (indicator != null) {
        await indicator.show();
      } else {
        unawaited(HapticFeedback.mediumImpact());
        await ref.read(feedControllerProvider.notifier).refresh();
      }

      if (isMounted()) MediaBudgetEpoch.bump();
    } finally {
      lockScrollDuringJump = false;
      if (isMounted()) {
        setState(() => programmaticRefreshRunning = false);
      } else {
        programmaticRefreshRunning = false;
      }
    }
  }

  /// Shared path for sort + type changes (sheet or swipe).
  Future<void> applyFeedFilter({
    required WidgetRef ref,
    required VoidCallback cancelLoadMore,
    required void Function(String type) onTypeAnimating,
    String? sort,
    String? type,
    bool awaitSheetDismiss = true,
  }) async {
    if (sort == null && type == null) return;

    final feed = ref.read(feedControllerProvider);
    final nextSort = sort ?? feed.sort;
    final nextType = type ?? feed.type;
    if (nextSort == feed.sort && nextType == feed.type) return;

    // Coalesce rapid taps into the latest intent while a run is in flight.
    if (filterChangeRunning) {
      if (sort != null) _pendingFilterSort = sort;
      if (type != null) {
        _pendingFilterType = type;
        if (type != feed.type) onTypeAnimating(type);
      }
      return;
    }

    if (type != null && type != feed.type) {
      onTypeAnimating(type);
    }

    filterChangeRunning = true;
    cancelLoadMore();

    try {
      var applySort = sort;
      var applyType = type;
      var waitSheet = awaitSheetDismiss;

      while (isMounted()) {
        await resetViewportForReload(
          awaitSheetDismiss: waitSheet,
          lockPhysicsForJump: false,
          bumpMediaEpochAfterDeepJump: true,
        );
        if (!isMounted()) return;

        if (_pendingFilterSort != null) {
          applySort = _pendingFilterSort;
          _pendingFilterSort = null;
        }
        if (_pendingFilterType != null) {
          applyType = _pendingFilterType;
          _pendingFilterType = null;
        }

        final current = ref.read(feedControllerProvider);
        final wantSort = applySort ?? current.sort;
        final wantType = applyType ?? current.type;
        if (wantSort == current.sort && wantType == current.type) break;

        await ref.read(feedControllerProvider.notifier).applyFilter(
              sort: applySort != null ? wantSort : null,
              type: applyType != null ? wantType : null,
            );

        if (_pendingFilterSort == null && _pendingFilterType == null) break;
        applySort = _pendingFilterSort;
        applyType = _pendingFilterType;
        waitSheet = false;
        _pendingFilterSort = null;
        _pendingFilterType = null;
      }
    } finally {
      filterChangeRunning = false;
      if (!isMounted()) {
        _pendingFilterSort = null;
        _pendingFilterType = null;
      }
    }
  }
}
