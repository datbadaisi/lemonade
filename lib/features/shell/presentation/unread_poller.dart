import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/app/providers.dart';

/// Owns the authenticated unread-count polling lifecycle outside the shell UI.
final unreadPollerProvider = Provider<void>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  final api = ref.watch(lemmyApiClientProvider);
  Timer? timer;
  var lastLoggedIn = auth.isLoggedIn;
  var lastInstance = auth.activeInstanceUrl;
  var lastAccountId = auth.activeAccountId;

  Future<void> refresh() async {
    if (auth.isLoggedIn) {
      await auth.fetchUnreadCounts(api);
    }
  }

  void configure({bool force = false}) {
    final changed =
        lastLoggedIn != auth.isLoggedIn ||
        lastInstance != auth.activeInstanceUrl ||
        lastAccountId != auth.activeAccountId;
    if (!force && !changed) return;
    lastLoggedIn = auth.isLoggedIn;
    lastInstance = auth.activeInstanceUrl;
    lastAccountId = auth.activeAccountId;
    timer?.cancel();
    if (!auth.isLoggedIn) {
      auth.clearAllNotifications();
      return;
    }
    unawaited(refresh());
    timer = Timer.periodic(const Duration(seconds: 30), (_) {
      unawaited(refresh());
    });
  }

  auth.addListener(configure);
  configure(force: true);
  ref.onDispose(() {
    auth.removeListener(configure);
    timer?.cancel();
  });
});
