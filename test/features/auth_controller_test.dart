import 'package:bluerum/app/providers.dart';
import 'package:bluerum/core/storage/shared_prefs_store.dart';
import 'package:bluerum/features/auth/data/auth_repository.dart';
import 'package:bluerum/features/auth/presentation/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('auth controller mirrors repository login state', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await SharedPrefsStore.create();
    final auth = AuthService(store: store);
    await auth.init();

    final container = ProviderContainer(
      overrides: [
        keyValueStoreProvider.overrideWithValue(store),
        authRepositoryProvider.overrideWithValue(auth),
      ],
    );
    addTearDown(container.dispose);

    final state = container.read(authControllerProvider);
    expect(state.isLoggedIn, isFalse);
    expect(state.initialized, isTrue);

    await auth.setJwt('test-token');
    final loggedIn = container.read(authControllerProvider);
    expect(loggedIn.isLoggedIn, isTrue);
    expect(loggedIn.jwt, 'test-token');
  });
}
