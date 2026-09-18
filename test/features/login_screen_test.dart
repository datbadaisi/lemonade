import 'package:bluerum/app/providers.dart';
import 'package:bluerum/core/storage/shared_prefs_store.dart';
import 'package:bluerum/features/auth/presentation/login_screen.dart';
import 'package:bluerum/features/auth/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'login validates required credentials before requesting the API',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final store = await SharedPrefsStore.create();
      final auth = AuthService(store: store);
      await auth.init();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            keyValueStoreProvider.overrideWithValue(store),
            authRepositoryProvider.overrideWithValue(auth),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      final submit = find.byType(FilledButton);
      await tester.scrollUntilVisible(
        submit,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(submit);
      await tester.pump();

      // Instance is pre-filled; username is the first empty required field.
      expect(find.text('Enter your username or email'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    },
  );
}
