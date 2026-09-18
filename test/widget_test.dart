import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:bluerum/app/app.dart';
import 'package:bluerum/app/providers.dart';
import 'package:bluerum/core/storage/shared_prefs_store.dart';
import 'package:bluerum/features/auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Need to set up SharedPreferences before using AuthService
    SharedPreferences.setMockInitialValues({});

    final store = await SharedPrefsStore.create();
    final authService = AuthService(store: store);
    await authService.init();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          keyValueStoreProvider.overrideWithValue(store),
          authRepositoryProvider.overrideWithValue(authService),
        ],
        child: const BluerumApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
