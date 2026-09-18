import 'package:flutter/material.dart';

import 'package:bluerum/app/theme/app_bar_chrome.dart';

/// Shared chrome state for [BluerumShell]: hides the bottom tab bar while a
/// nested page / modal is open so it cannot cover chat, sheets, etc., and
/// restores the bar when the stack returns to a tab root.
///
/// Scroll hide is continuous (1:1 with finger travel): [hidePixels] rises as
/// the user scrolls down and falls as they scroll up — no snap / ease curve.
final class ShellChrome {
  ShellChrome._();
  static final ShellChrome instance = ShellChrome._();

  /// Content height of the home header and bottom tab bar (both [AppBarChrome.height]).
  static const double chromeHeight = AppBarChrome.height;

  /// Navigator keys for each [StatefulShellBranch] (search, home, notifs, profile).
  final branchNavigatorKeys = List<GlobalKey<NavigatorState>>.generate(
    4,
    (i) => GlobalKey<NavigatorState>(debugLabel: 'shell-branch-$i'),
  );

  /// Root-route observer so full-screen go_router pushes / root modals hide the bar.
  final routeObserver = RouteObserver<ModalRoute<void>>();

  /// One observer per branch navigator (a single observer cannot attach to many).
  late final List<NavigatorObserver> branchObservers =
      List<NavigatorObserver>.generate(
    4,
    (_) => _BranchNavigatorObserver(_recompute),
  );

  int _currentBranchIndex = 0;

  /// True when something is covering the tab chrome (nested route or root overlay).
  final ValueNotifier<bool> suppressed = ValueNotifier<bool>(false);

  /// How far chrome has slid away: `0` = fully shown, [chromeHeight] = fully hidden.
  final ValueNotifier<double> hidePixels = ValueNotifier<double>(0);

  /// Bumped when the Home tab is double-tapped: feed should scroll to top + refresh.
  final ValueNotifier<int> homeScrollAndRefresh = ValueNotifier<int>(0);

  /// True while a root-level route/modal sits above the shell.
  bool _rootCovered = false;

  void requestHomeScrollAndRefresh() {
    homeScrollAndRefresh.value++;
  }

  /// Reset chrome to fully visible (tab switch, return from nested route, etc.).
  void resetHide() {
    if (hidePixels.value != 0) {
      hidePixels.value = 0;
    }
  }

  /// Apply a vertical scroll delta 1:1. Positive [delta] = scroll down = hide.
  void applyScrollDelta({
    required double delta,
    required double scrollPixels,
  }) {
    if (suppressed.value) return;

    // At / near the top of the list, always fully show.
    if (scrollPixels <= 0) {
      resetHide();
      return;
    }

    // 1:1 with finger: no threshold, no animation curve.
    var next = (hidePixels.value + delta).clamp(0.0, chromeHeight);
    // Never hide more than the distance scrolled from the top.
    if (next > scrollPixels) {
      next = scrollPixels.clamp(0.0, chromeHeight);
    }
    if (next != hidePixels.value) {
      hidePixels.value = next;
    }
  }

  void setCurrentBranch(int index) {
    if (_currentBranchIndex == index) {
      _recompute();
      return;
    }
    _currentBranchIndex = index;
    _recompute();
  }

  void setRootCovered(bool covered) {
    if (_rootCovered == covered) return;
    _rootCovered = covered;
    _recompute();
  }

  void _recompute() {
    final branchNav = branchNavigatorKeys[
            _currentBranchIndex.clamp(0, branchNavigatorKeys.length - 1)]
        .currentState;
    final nested = branchNav?.canPop() ?? false;
    final next = nested || _rootCovered;
    if (suppressed.value != next) {
      suppressed.value = next;
    }
  }
}

final class _BranchNavigatorObserver extends NavigatorObserver {
  _BranchNavigatorObserver(this._onChange);

  final VoidCallback _onChange;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      // Defer so NavigatorState.canPop is up to date after the push.
      WidgetsBinding.instance.addPostFrameCallback((_) => _onChange());

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      WidgetsBinding.instance.addPostFrameCallback((_) => _onChange());

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      WidgetsBinding.instance.addPostFrameCallback((_) => _onChange());

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      WidgetsBinding.instance.addPostFrameCallback((_) => _onChange());
}
