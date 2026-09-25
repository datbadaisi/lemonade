import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/feed/presentation/home_screen.dart';
import '../../features/notifications/presentation/notification_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/community/presentation/community_detail_screen.dart';
import '../../features/create_post/presentation/create_post_screen.dart';
import '../../features/comment/presentation/comment_compose_screen.dart';
import '../../shared/models/post.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/blocks_screen.dart';
import '../../features/profile/presentation/saved_posts_screen.dart';
import '../../features/shell/presentation/main_shell.dart';
import '../../features/shell/presentation/shell_chrome.dart';
import '../../features/post/data/post_repository_impl.dart';
import '../../features/post/presentation/post_detail_screen.dart';
import '../../features/subscription/presentation/lifetime_support_screen.dart';
import '../providers.dart';
import 'chat_detail_route.dart';
import 'routes.dart';

/// Application router. Feature screens read auth/API from Riverpod — no service
/// prop-drilling through route builders.
/// Single long-lived [GoRouter]. Must not be recreated while the same
/// [ShellChrome.branchNavigatorKeys] are still attached — that causes
/// "Duplicate GlobalKeys detected in widget tree".
final appRouterProvider = Provider<GoRouter>((ref) {
  // Use read (not watch) so auth notifyListeners does not rebuild this
  // provider and construct a second GoRouter with the same navigator keys.
  final auth = ref.read(authRepositoryProvider);
  final chrome = ShellChrome.instance;
  final branchKeys = chrome.branchNavigatorKeys;
  final branchObservers = chrome.branchObservers;

  final router = GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: auth,
    observers: [chrome.routeObserver],
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isLogin = location == AppRoutes.login;
      if (isLogin && auth.isLoggedIn) return AppRoutes.home;
      // createPost is intentionally not guarded here so logged-out users
      // see CreatePostScreen's LoginRequiredScaffold (profile-style blank).
      final requiresAuth =
          location == AppRoutes.composeComment ||
          location == AppRoutes.saved ||
          location == AppRoutes.blocks ||
          location == AppRoutes.settings ||
          location.startsWith('/chat/');
      if (requiresAuth && !auth.isLoggedIn) return AppRoutes.login;
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            BluerumShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: branchKeys[0],
            observers: [branchObservers[0]],
            routes: [
              GoRoute(
                path: AppRoutes.search,
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: branchKeys[1],
            observers: [branchObservers[1]],
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: branchKeys[2],
            observers: [branchObservers[2]],
            routes: [
              GoRoute(
                path: AppRoutes.notifications,
                builder: (context, state) => const NotificationScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: branchKeys[3],
            observers: [branchObservers[3]],
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/posts/:id',
        builder: (context, state) {
          final postId = int.tryParse(state.pathParameters['id'] ?? '');
          if (postId == null) return const _NotFoundScreen();
          return _PostDetailLoader(postId: postId);
        },
      ),
      GoRoute(
        path: '/c/:name',
        builder: (context, state) =>
            CommunityDetailScreen(communityName: state.pathParameters['name']),
      ),
      GoRoute(
        path: '/u/:username',
        builder: (context, state) =>
            ProfileScreen(username: state.pathParameters['username']),
      ),
      GoRoute(
        path: AppRoutes.createPost,
        builder: (context, state) {
          final extra = state.extra;
          CommunityView? initial;
          if (extra is CommunityView) {
            initial = extra;
          } else if (extra is Map && extra['community'] is CommunityView) {
            initial = extra['community'] as CommunityView;
          }
          return CreatePostScreen(initialCommunity: initial);
        },
      ),
      GoRoute(
        path: AppRoutes.composeComment,
        builder: (context, state) {
          // Comment compose requires a post context from deep-link extras.
          final extra = state.extra;
          if (extra is! Map || extra['postView'] == null) {
            return const _NotFoundScreen();
          }
          return CommentComposeScreen(
            postView: extra['postView'],
            parentComment: extra['parentComment'],
            editingComment: extra['editingComment'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) {
          final personId = auth.username == null ? 0 : 0;
          // personId is resolved on the screen via site/my_user when 0 is wrong;
          // settings only needs logout/prefs for the signed-in user.
          return SettingsScreen(personId: personId);
        },
      ),
      GoRoute(
        path: AppRoutes.lifetime,
        builder: (context, state) => const LifetimeSupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.blocks,
        builder: (context, state) => const BlocksScreen(personId: 0),
      ),
      GoRoute(
        path: AppRoutes.saved,
        builder: (context, state) => const SavedPostsScreen(personId: 0),
      ),
      GoRoute(
        path: AppRoutes.chatPath,
        builder: (context, state) {
          final personId = int.tryParse(state.pathParameters['personId'] ?? '');
          return personId == null
              ? const _NotFoundScreen()
              : ChatDetailRoute(personId: personId);
        },
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

final class _PostDetailLoader extends ConsumerWidget {
  const _PostDetailLoader({required this.postId});

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(postDetailProvider(postId));
    return post.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: TextButton(
            onPressed: () => ref.invalidate(postDetailProvider(postId)),
            child: Text('Unable to load this post: $error'),
          ),
        ),
      ),
      data: (postView) => PostDetailScreen(postView: postView),
    );
  }
}

final class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('This link is not valid.')));
}
