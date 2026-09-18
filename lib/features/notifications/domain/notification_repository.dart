import 'package:bluerum/shared/models/notification.dart';
import 'package:bluerum/shared/models/post.dart';

/// Notifications + private-message inbox data access.
abstract interface class NotificationRepository {
  Future<List<CommentReplyView>> getReplies({
    int page = 1,
    int limit = 30,
    bool unreadOnly = false,
  });

  Future<List<PersonMentionView>> getMentions({
    int page = 1,
    int limit = 30,
    bool unreadOnly = false,
  });

  Future<List<PrivateMessageView>> getPrivateMessages({
    int page = 1,
    int limit = 50,
    bool unreadOnly = false,
  });

  Future<void> markAllAsRead();

  Future<CommentReplyView> markCommentReplyAsRead({
    required int commentReplyId,
    bool read = true,
  });

  Future<PersonMentionView> markPersonMentionAsRead({
    required int personMentionId,
    bool read = true,
  });

  Future<PostView> getPost(int postId);
}
