import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/app/providers.dart';
import 'package:bluerum/core/network/lemmy_api_client.dart';
import 'package:bluerum/shared/models/notification.dart';
import 'package:bluerum/shared/models/post.dart';
import 'package:bluerum/features/notifications/domain/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => LemmyNotificationRepository(ref.watch(lemmyApiClientProvider)),
);

final class LemmyNotificationRepository implements NotificationRepository {
  const LemmyNotificationRepository(this._client);

  final LemmyApiService _client;

  @override
  Future<List<CommentReplyView>> getReplies({
    int page = 1,
    int limit = 30,
    bool unreadOnly = false,
  }) =>
      _client.getReplies(unreadOnly: unreadOnly, limit: limit, page: page);

  @override
  Future<List<PersonMentionView>> getMentions({
    int page = 1,
    int limit = 30,
    bool unreadOnly = false,
  }) =>
      _client.getMentions(unreadOnly: unreadOnly, limit: limit, page: page);

  @override
  Future<List<PrivateMessageView>> getPrivateMessages({
    int page = 1,
    int limit = 50,
    bool unreadOnly = false,
  }) =>
      _client.getPrivateMessages(
        unreadOnly: unreadOnly,
        limit: limit,
        page: page,
      );

  @override
  Future<void> markAllAsRead() => _client.markAllAsRead();

  @override
  Future<CommentReplyView> markCommentReplyAsRead({
    required int commentReplyId,
    bool read = true,
  }) =>
      _client.markCommentReplyAsRead(
        commentReplyId: commentReplyId,
        read: read,
      );

  @override
  Future<PersonMentionView> markPersonMentionAsRead({
    required int personMentionId,
    bool read = true,
  }) =>
      _client.markPersonMentionAsRead(
        personMentionId: personMentionId,
        read: read,
      );

  @override
  Future<PostView> getPost(int postId) => _client.getPost(postId);
}
