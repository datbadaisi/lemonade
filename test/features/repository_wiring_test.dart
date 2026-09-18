import 'package:bluerum/app/providers.dart';
import 'package:bluerum/core/storage/shared_prefs_store.dart';
import 'package:bluerum/features/auth/data/auth_repository.dart';
import 'package:bluerum/features/comment/data/comment_repository_impl.dart';
import 'package:bluerum/features/community/data/community_repository_impl.dart';
import 'package:bluerum/features/search/data/search_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Proves feature repository providers resolve the shipped Lemmy* implementations
/// (the same providers presentation reads via ref.read(...)).
void main() {
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final store = await SharedPrefsStore.create();
    final auth = AuthService(store: store);
    await auth.init();
    container = ProviderContainer(
      overrides: [
        keyValueStoreProvider.overrideWithValue(store),
        authRepositoryProvider.overrideWithValue(auth),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('searchRepositoryProvider resolves LemmySearchRepository', () {
    final repo = container.read(searchRepositoryProvider);
    expect(repo, isA<LemmySearchRepository>());
  });

  test('commentRepositoryProvider resolves LemmyCommentRepository', () {
    final repo = container.read(commentRepositoryProvider);
    expect(repo, isA<LemmyCommentRepository>());
  });

  test('communityRepositoryProvider resolves LemmyCommunityRepository', () {
    final repo = container.read(communityRepositoryProvider);
    expect(repo, isA<LemmyCommunityRepository>());
  });
}
