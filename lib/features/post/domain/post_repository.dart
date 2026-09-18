import 'package:bluerum/shared/models/post.dart';

abstract interface class PostRepository {
  Future<PostView> getPost(int postId);
  Future<PostView> vote({required int postId, required int score});
  Future<PostView> save({required int postId, required bool save});

  /// Mark posts as read/unread (POST /post/mark_as_read).
  Future<void> markAsRead({required List<int> postIds, required bool read});

  Future<PostView> createPost({
    required String name,
    required int communityId,
    String? body,
    String? url,
    bool? nsfw,
    int? languageId,
    String? altText,
    String? customThumbnail,
  });

  Future<PostView> editPost({
    required int postId,
    String? name,
    String? body,
    String? url,
    bool? nsfw,
    int? languageId,
    String? altText,
    String? customThumbnail,
  });

  Future<PostView> deletePost({required int postId, required bool deleted});

  Future<String> uploadImage(
    List<int> bytes,
    String filename, {
    String? mimeType,
    void Function(void Function())? onCancelReady,
  });
}
