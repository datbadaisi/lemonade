import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/app/providers.dart';
import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:bluerum/features/auth/domain/stored_account.dart';
import '../domain/auth_state.dart';

/// Riverpod-facing authentication state.
///
/// It bridges the existing persistence service during the incremental port so
/// new features never need a `ChangeNotifier` constructor parameter.
final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

final class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    final legacyAuth = ref.watch(authRepositoryProvider);
    void sync() => state = _fromLegacy();

    legacyAuth.addListener(sync);
    ref.onDispose(() => legacyAuth.removeListener(sync));
    return _fromLegacy();
  }

  AuthState _fromLegacy() {
    final auth = ref.read(authRepositoryProvider);
    return AuthState(
      initialized: auth.initialized,
      instanceUrl: auth.activeInstanceUrl,
      jwt: auth.jwt,
      username: auth.username,
      personId: auth.personId,
      unreadReplies: auth.unreadReplies,
      unreadMentions: auth.unreadMentions,
      unreadPrivateMessages: auth.unreadPrivateMessages,
      accounts: auth.accounts,
      activeAccountId: auth.activeAccountId,
    );
  }

  Future<LoginResponse> login({
    required String usernameOrEmail,
    required String password,
    String? totpToken,
    String? instanceUrl,
  }) => ref
      .read(authRepositoryProvider)
      .login(
        api: ref.read(lemmyApiClientProvider),
        usernameOrEmail: usernameOrEmail,
        password: password,
        totpToken: totpToken,
        instanceUrl: instanceUrl,
      );

  Future<void> logout() => ref
      .read(authRepositoryProvider)
      .logout(api: ref.read(lemmyApiClientProvider));

  Future<void> setInstance(String url) =>
      ref.read(authRepositoryProvider).setInstance(url);

  Future<void> switchAccount(String accountId) => ref
      .read(authRepositoryProvider)
      .switchAccount(
        accountId,
        api: ref.read(lemmyApiClientProvider),
      );

  List<StoredAccount> get accounts =>
      ref.read(authRepositoryProvider).accounts;
}
