// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommentReply _$CommentReplyFromJson(Map<String, dynamic> json) =>
    _CommentReply(
      id: json['id'] == null ? 0 : _toInt(json['id']),
      recipientId: json['recipient_id'] == null
          ? 0
          : _toInt(json['recipient_id']),
      commentId: json['comment_id'] == null ? 0 : _toInt(json['comment_id']),
      read: json['read'] as bool? ?? false,
      published: json['published'] as String? ?? '',
    );

_CommentReplyView _$CommentReplyViewFromJson(Map<String, dynamic> json) =>
    _CommentReplyView(
      commentReply: CommentReply.fromJson(
        json['comment_reply'] as Map<String, dynamic>,
      ),
      comment: Comment.fromJson(json['comment'] as Map<String, dynamic>),
      creator: Person.fromJson(json['creator'] as Map<String, dynamic>),
      post: Post.fromJson(json['post'] as Map<String, dynamic>),
      community: Community.fromJson(json['community'] as Map<String, dynamic>),
      recipient: Person.fromJson(json['recipient'] as Map<String, dynamic>),
      counts: CommentAggregates.fromJson(
        json['counts'] as Map<String, dynamic>,
      ),
      creatorBannedFromCommunity:
          json['creator_banned_from_community'] as bool? ?? false,
      bannedFromCommunity: json['banned_from_community'] as bool? ?? false,
      creatorIsModerator: json['creator_is_moderator'] as bool? ?? false,
      creatorIsAdmin: json['creator_is_admin'] as bool? ?? false,
      subscribed: json['subscribed'] as String? ?? 'NotSubscribed',
      saved: json['saved'] as bool? ?? false,
      creatorBlocked: json['creator_blocked'] as bool? ?? false,
      myVote: _toNullableInt(json['my_vote']),
    );

_PersonMention _$PersonMentionFromJson(Map<String, dynamic> json) =>
    _PersonMention(
      id: json['id'] == null ? 0 : _toInt(json['id']),
      recipientId: json['recipient_id'] == null
          ? 0
          : _toInt(json['recipient_id']),
      commentId: json['comment_id'] == null ? 0 : _toInt(json['comment_id']),
      read: json['read'] as bool? ?? false,
      published: json['published'] as String? ?? '',
    );

_PersonMentionView _$PersonMentionViewFromJson(Map<String, dynamic> json) =>
    _PersonMentionView(
      personMention: PersonMention.fromJson(
        json['person_mention'] as Map<String, dynamic>,
      ),
      comment: Comment.fromJson(json['comment'] as Map<String, dynamic>),
      creator: Person.fromJson(json['creator'] as Map<String, dynamic>),
      post: Post.fromJson(json['post'] as Map<String, dynamic>),
      community: Community.fromJson(json['community'] as Map<String, dynamic>),
      recipient: Person.fromJson(json['recipient'] as Map<String, dynamic>),
      counts: CommentAggregates.fromJson(
        json['counts'] as Map<String, dynamic>,
      ),
      creatorBannedFromCommunity:
          json['creator_banned_from_community'] as bool? ?? false,
      bannedFromCommunity: json['banned_from_community'] as bool? ?? false,
      creatorIsModerator: json['creator_is_moderator'] as bool? ?? false,
      creatorIsAdmin: json['creator_is_admin'] as bool? ?? false,
      subscribed: json['subscribed'] as String? ?? 'NotSubscribed',
      saved: json['saved'] as bool? ?? false,
      creatorBlocked: json['creator_blocked'] as bool? ?? false,
      myVote: _toNullableInt(json['my_vote']),
    );

_PrivateMessage _$PrivateMessageFromJson(Map<String, dynamic> json) =>
    _PrivateMessage(
      id: json['id'] == null ? 0 : _toInt(json['id']),
      creatorId: json['creator_id'] == null ? 0 : _toInt(json['creator_id']),
      recipientId: json['recipient_id'] == null
          ? 0
          : _toInt(json['recipient_id']),
      content: json['content'] as String? ?? '',
      deleted: json['deleted'] as bool? ?? false,
      read: json['read'] as bool? ?? false,
      published: json['published'] as String? ?? '',
      updated: json['updated'] as String?,
      apId: json['ap_id'] as String? ?? '',
      local: json['local'] as bool? ?? true,
    );

_PrivateMessageView _$PrivateMessageViewFromJson(Map<String, dynamic> json) =>
    _PrivateMessageView(
      privateMessage: PrivateMessage.fromJson(
        json['private_message'] as Map<String, dynamic>,
      ),
      creator: Person.fromJson(json['creator'] as Map<String, dynamic>),
      recipient: Person.fromJson(json['recipient'] as Map<String, dynamic>),
    );

_GetUnreadCountResponse _$GetUnreadCountResponseFromJson(
  Map<String, dynamic> json,
) => _GetUnreadCountResponse(
  replies: json['replies'] == null ? 0 : _toInt(json['replies']),
  mentions: json['mentions'] == null ? 0 : _toInt(json['mentions']),
  privateMessages: json['private_messages'] == null
      ? 0
      : _toInt(json['private_messages']),
);
