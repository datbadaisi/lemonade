import 'package:bluerum/shared/models/post.dart';

abstract interface class FeedRepository {
  Future<List<PostView>> getPosts({
    required String sort,
    required String type,
    required int page,
    required int limit,
  });

  Future<PostView> vote({required int postId, required int score});
  Future<PostView> save({required int postId, required bool save});
}
