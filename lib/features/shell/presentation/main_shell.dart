import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import 'package:bluerum/app/router/routes.dart';
import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/features/feed/presentation/feed_controller.dart';
import 'package:bluerum/shared/models/post.dart';
import '../../auth/presentation/auth_controller.dart';
import 'shell_chrome.dart';

/// The routed tab shell. `StatefulNavigationShell` preserves each branch's
/// navigator and scroll state when switching tabs.
///
/// Bottom bar is a full-width standard bar that auto-hides on scroll down and
/// reappears on scroll up (scroll-aware bottom navigation). It is fully
/// suppressed while a nested page (e.g. chat) or modal sits above the tab root
/// so it cannot cover those surfaces, and is restored when returning.
final class BluerumShell extends ConsumerStatefulWidget {
  const BluerumShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<BluerumShell> createState() => _BluerumShellState();
}

final class _BluerumShellState extends ConsumerState<BluerumShell>
    with RouteAware {
  final _chrome = ShellChrome.instance;

  @override
  void initState() {
    super.initState();
    _chrome.setCurrentBranch(widget.navigationShell.currentIndex);
    _chrome.suppressed.addListener(_onSuppressChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      _chrome.routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    _chrome.suppressed.removeListener(_onSuppressChanged);
    _chrome.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant BluerumShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationShell.currentIndex !=
        widget.navigationShell.currentIndex) {
      _chrome.setCurrentBranch(widget.navigationShell.currentIndex);
    }
  }

  // Root navigator pushed something above the shell (full screen route / modal).
  @override
  void didPushNext() => _chrome.setRootCovered(true);

  // Returned to the shell from a root-level route/modal.
  @override
  void didPopNext() {
    _chrome.setRootCovered(false);
    _restoreBar();
  }

  void _onSuppressChanged() {
    if (!mounted) return;
    // Coming back to a tab root always restores the bar.
    if (!_chrome.suppressed.value) {
      _restoreBar();
    } else {
      setState(() {});
    }
  }

  void _restoreBar() {
    if (!mounted) return;
    _chrome.resetHide();
    setState(() {});
  }

  /// Home tab branch index (must match [appRouterProvider] branch order).
  static const _homeBranch = 1;

  DateTime? _lastHomeTapAt;

  void _goToBranch(int index) {
    // Double-tap Home: scroll feed to top + refresh.
    if (index == _homeBranch) {
      final now = DateTime.now();
      final isDoubleTap = _lastHomeTapAt != null &&
          now.difference(_lastHomeTapAt!) < const Duration(milliseconds: 400);
      _lastHomeTapAt = now;
      if (isDoubleTap &&
          widget.navigationShell.currentIndex == _homeBranch) {
        _restoreBar();
        // Only force initialLocation when Home has a nested route (e.g. post
        // detail). goBranch+refresh together on root remounts/rebuilds the
        // feed mid-jump and freezes mid-range devices.
        final homeNav = _chrome.branchNavigatorKeys[_homeBranch].currentState;
        final hasNested = homeNav?.canPop() ?? false;
        if (hasNested) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: true,
          );
          // Refresh after the pop settles so HomeScreen is stable.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _chrome.requestHomeScrollAndRefresh();
          });
        } else {
          _chrome.requestHomeScrollAndRefresh();
        }
        return;
      }
    } else {
      _lastHomeTapAt = null;
    }

    _restoreBar();
    _chrome.setCurrentBranch(index);
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  bool _onScroll(ScrollNotification notification) {
    // Nested pages / modals own the screen — ignore their scroll for tab chrome.
    if (_chrome.suppressed.value) return false;

    // Only react to vertical user scrolls from list content.
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification is! ScrollUpdateNotification) return false;
    final delta = notification.scrollDelta;
    if (delta == null || delta == 0) return false;

    // Race with branch RouteObserver: skip if current tab can already pop.
    // Use branch GlobalKeys — never Navigator.of(notification.context).
    // NestedScrollView rebuilds (e.g. profile tab swap) fire goIdle on a
    // deactivated scrollable; ancestor lookup on that context asserts.
    final keys = _chrome.branchNavigatorKeys;
    final branchIndex =
        widget.navigationShell.currentIndex.clamp(0, keys.length - 1);
    final branchNav = keys[branchIndex].currentState;
    if (branchNav != null && branchNav.canPop()) return false;

    // Ignore overscroll bounce (rubber-band) so the bar doesn't flash.
    final pixels = notification.metrics.pixels;
    final atEdge = pixels < notification.metrics.minScrollExtent ||
        pixels > notification.metrics.maxScrollExtent;
    if (atEdge) return false;

    // Continuous 1:1 slide — no threshold / snap animation.
    _chrome.applyScrollDelta(delta: delta, scrollPixels: pixels);

    return false; // let other listeners (e.g. pagination) keep working
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final suppressed = _chrome.suppressed.value;

    return Scaffold(
      // Content draws under the bar; screens already pad list bottoms.
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: widget.navigationShell,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ListenableBuilder(
              listenable: _chrome.hidePixels,
              builder: (context, _) {
                // 1:1 with scroll (same as home header). Collapse home-indicator
                // pad with the same progress so no strip is left when fully hidden.
                final hide = suppressed
                    ? ShellChrome.chromeHeight
                    : _chrome.hidePixels.value;
                final t = (hide / ShellChrome.chromeHeight).clamp(0.0, 1.0);
                final fullyHidden = t >= 1.0 - 0.01;
                return IgnorePointer(
                  ignoring: fullyHidden || suppressed,
                  child: Transform.translate(
                    offset: Offset(0, hide),
                    child: _StandardBottomBar(
                      currentIndex: widget.navigationShell.currentIndex,
                      unreadCount: auth.totalUnreadAll,
                      bottomInset: bottomInset * (1.0 - t),
                      onDestinationSelected: _goToBranch,
                      onCreatePost: () async {
                        final result = await context
                            .push<PostView>(AppRoutes.createPost);
                        if (!context.mounted || result == null) return;

                        final postView = result;
                        // Wait a frame so CreatePostScreen fully unmounts before we
                        // rebuild the feed / push detail (avoids InheritedElement
                        // '_dependents.isEmpty' crashes during route teardown).
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          ref
                              .read(feedControllerProvider.notifier)
                              .prependPost(postView);
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text('Post created'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          this.context.push('/posts/${postView.post.id}');
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width bottom navigation bar (standard app style, not a floating pill).
final class _StandardBottomBar extends StatelessWidget {
  const _StandardBottomBar({
    required this.currentIndex,
    required this.unreadCount,
    required this.bottomInset,
    required this.onDestinationSelected,
    required this.onCreatePost,
  });

  final int currentIndex;
  final int unreadCount;
  final double bottomInset;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onCreatePost;

  static const barHeight = ShellChrome.chromeHeight;

  // Tab order matches StatefulShellBranch: Search, Home, Notifications, Profile.
  // MingCute — distinctive cute/plump set (fill when selected, line when idle).
  static const _icons = [
    (MingCuteIcons.mgc_search_2_fill, MingCuteIcons.mgc_search_2_line),
    (MingCuteIcons.mgc_home_4_fill, MingCuteIcons.mgc_home_4_line),
    (
      MingCuteIcons.mgc_notification_fill,
      MingCuteIcons.mgc_notification_line,
    ),
    (MingCuteIcons.mgc_user_3_fill, MingCuteIcons.mgc_user_3_line),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SizedBox(
          height: barHeight,
          child: Row(
            children: [
              _tab(0),
              _tab(1),
              Expanded(child: _createPostButton()),
              _tab(2),
              _tab(3),
            ],
          ),
        ),
      ),
    );
  }

  /// Pill-shaped create action, sized to fit inside the bar.
  Widget _createPostButton() {
    const pillH = 36.0;
    return Center(
      child: Tooltip(
        message: 'Create post',
        child: Material(
          color: AppColors.accent,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onCreatePost,
            splashColor: Colors.white24,
            highlightColor: Colors.white12,
            child: const SizedBox(
              height: pillH,
              // Wider than tall → reads as a capsule, not a circle.
              width: 56,
              child: Icon(
                MingCuteIcons.mgc_add_fill,
                size: 22,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(int index) {
    final active = index == currentIndex;
    final icon = active ? _icons[index].$1 : _icons[index].$2;
    final child = Icon(
      icon,
      color: active ? AppColors.textPrimary : AppColors.textSecondary,
      size: 25,
    );
    // Same Material ink ripple as AppBar back/more IconButtons.
    return Expanded(
      child: IconButton(
        onPressed: () => onDestinationSelected(index),
        splashRadius: 24,
        tooltip: switch (index) {
          0 => 'Search',
          1 => 'Home',
          2 => 'Notifications',
          _ => 'Profile',
        },
        icon: index == 2 && unreadCount > 0
            ? Badge(
                label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                child: child,
              )
            : child,
      ),
    );
  }
}
