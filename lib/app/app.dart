import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/features/community/data/community_repository_impl.dart';
import 'package:bluerum/features/shell/presentation/unread_poller.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class BluerumApp extends ConsumerWidget {
  const BluerumApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(unreadPollerProvider);
    ref.watch(authSessionSideEffectsProvider);
    return MaterialApp.router(
      title: 'Lemonade',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      routerConfig: ref.watch(appRouterProvider));
  }
}
