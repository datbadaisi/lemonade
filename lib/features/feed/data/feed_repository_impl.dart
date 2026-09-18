import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/app/providers.dart';
import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:bluerum/shared/models/post.dart';
import '../domain/feed_repository.dart';

final feedRepositoryProvider = Provider<FeedRepository>(
  (ref) => LemmyFeedRepository(ref.watch(lemmyApiClientProvider)));

final class LemmyFeedRepository implements FeedRepository {
  const LemmyFeedRepository(this._client);

  final LemmyApiService _client;

  @override
  Future<List<PostView>> getPosts({
    required String sort,
    required String type,
    required int page,
    required int limit,
  }) => _client.getPosts(sort: sort, type: type, page: page, limit: limit);

  @override
  Future<PostView> save({required int postId, required bool save}) =>
      _client.savePost(postId: postId, save: save);

  @override
  Future<PostView> vote({required int postId, required int score}) =>
      _client.likePost(postId: postId, score: score);
}
