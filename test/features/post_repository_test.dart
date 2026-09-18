import 'package:bluerum/features/post/data/post_repository_impl.dart';
import 'package:bluerum/features/post/domain/post_repository.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('post detail provider exposes repository failure', () async {
    final container = ProviderContainer(
      overrides: [postRepositoryProvider.overrideWithValue(_FailingPostRepo())],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(postDetailProvider(42).future),
      throwsA(isA<StateError>()),
    );
    expect(container.read(postDetailProvider(42)).hasError, isTrue);
  });
}

final class _FailingPostRepo implements PostRepository {
  @override
  Future<PostView> getPost(int postId) => Future.error(StateError('offline'));

  @override
  Future<PostView> save({required int postId, required bool save}) =>
      throw UnimplementedError();

  @override
  Future<PostView> vote({required int postId, required int score}) =>
      throw UnimplementedError();

  @override
  Future<void> markAsRead({required List<int> postIds, required bool read}) =>
      throw UnimplementedError();

  @override
  Future<PostView> createPost({
    required String name,
    required int communityId,
    String? body,
    String? url,
    bool? nsfw,
    int? languageId,
    String? altText,
    String? customThumbnail,
  }) => throw UnimplementedError();

  @override
  Future<PostView> editPost({
    required int postId,
    String? name,
    String? body,
    String? url,
    bool? nsfw,
    int? languageId,
    String? altText,
    String? customThumbnail,
  }) => throw UnimplementedError();

  @override
  Future<PostView> deletePost({required int postId, required bool deleted}) =>
      throw UnimplementedError();

  @override
  Future<String> uploadImage(
    List<int> bytes,
    String filename, {
    String? mimeType,
    void Function(void Function())? onCancelReady,
  }) => throw UnimplementedError();
}
