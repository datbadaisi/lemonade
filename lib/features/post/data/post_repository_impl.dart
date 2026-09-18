import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/app/providers.dart';
import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:bluerum/shared/models/post.dart';
import '../domain/post_repository.dart';

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => LemmyPostRepository(ref.watch(lemmyApiClientProvider)),
);

final postDetailProvider = FutureProvider.autoDispose.family<PostView, int>(
  (ref, postId) => ref.watch(postRepositoryProvider).getPost(postId),
);

/// Post IDs marked read this session so feed cards dim immediately without
/// waiting for a list refresh from the server.
final sessionReadPostIdsProvider =
    NotifierProvider<SessionReadPostIds, Set<int>>(SessionReadPostIds.new);

final class SessionReadPostIds extends Notifier<Set<int>> {
  @override
  Set<int> build() => {};

  void add(int postId) {
    if (state.contains(postId)) return;
    state = {...state, postId};
  }

  void addAll(Iterable<int> postIds) {
    final next = {...state, ...postIds};
    if (next.length == state.length) return;
    state = next;
  }

  void clear() {
    if (state.isEmpty) return;
    state = {};
  }
}

final class LemmyPostRepository implements PostRepository {
  const LemmyPostRepository(this._client);

  final LemmyApiService _client;

  @override
  Future<PostView> getPost(int postId) => _client.getPost(postId);

  @override
  Future<PostView> save({required int postId, required bool save}) =>
      _client.savePost(postId: postId, save: save);

  @override
  Future<PostView> vote({required int postId, required int score}) =>
      _client.likePost(postId: postId, score: score);

  @override
  Future<void> markAsRead({required List<int> postIds, required bool read}) =>
      _client.markPostAsRead(postIds: postIds, read: read);

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
  }) => _client.createPost(
    name: name,
    communityId: communityId,
    body: body,
    url: url,
    nsfw: nsfw,
    languageId: languageId,
    altText: altText,
    customThumbnail: customThumbnail,
  );

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
  }) => _client.editPost(
    postId: postId,
    name: name,
    body: body,
    url: url,
    nsfw: nsfw,
    languageId: languageId,
    altText: altText,
    customThumbnail: customThumbnail,
  );

  @override
  Future<PostView> deletePost({required int postId, required bool deleted}) =>
      _client.deletePost(postId: postId, deleted: deleted);

  @override
  Future<String> uploadImage(
    List<int> bytes,
    String filename, {
    String? mimeType,
    void Function(void Function())? onCancelReady,
  }) => _client.uploadImage(
    bytes,
    filename,
    mimeType: mimeType,
    onCancelReady: onCancelReady,
  );
}
