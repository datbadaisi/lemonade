import 'package:freezed_annotation/freezed_annotation.dart';

import 'comment.dart';
import 'post.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

int? _toNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

// ── CommentReply ──────────────────────────────────────────────────────────────
@Freezed(toJson: false)
abstract class CommentReply with _$CommentReply {
  const factory CommentReply({
    @JsonKey(fromJson: _toInt) @Default(0) int id,
    @JsonKey(name: 'recipient_id', fromJson: _toInt)
    @Default(0)
    int recipientId,
    @JsonKey(name: 'comment_id', fromJson: _toInt) @Default(0) int commentId,
    @Default(false) bool read,
    @Default('') String published,
  }) = _CommentReply;

  factory CommentReply.fromJson(Map<String, dynamic> json) =>
      _$CommentReplyFromJson(json);
}

// ── CommentReplyView ──────────────────────────────────────────────────────────
@Freezed(toJson: false)
abstract class CommentReplyView with _$CommentReplyView {
  const factory CommentReplyView({
    @JsonKey(name: 'comment_reply') required CommentReply commentReply,
    required Comment comment,
    required Person creator,
    required Post post,
    required Community community,
    required Person recipient,
    required CommentAggregates counts,
    @JsonKey(name: 'creator_banned_from_community')
    @Default(false)
    bool creatorBannedFromCommunity,
    @JsonKey(name: 'banned_from_community')
    @Default(false)
    bool bannedFromCommunity,
    @JsonKey(name: 'creator_is_moderator')
    @Default(false)
    bool creatorIsModerator,
    @JsonKey(name: 'creator_is_admin') @Default(false) bool creatorIsAdmin,
    @Default('NotSubscribed') String subscribed,
    @Default(false) bool saved,
    @JsonKey(name: 'creator_blocked') @Default(false) bool creatorBlocked,
    @JsonKey(name: 'my_vote', fromJson: _toNullableInt) int? myVote,
  }) = _CommentReplyView;

  factory CommentReplyView.fromJson(Map<String, dynamic> json) =>
      _$CommentReplyViewFromJson(json);
}

// ── PersonMention ─────────────────────────────────────────────────────────────
@Freezed(toJson: false)
abstract class PersonMention with _$PersonMention {
  const factory PersonMention({
    @JsonKey(fromJson: _toInt) @Default(0) int id,
    @JsonKey(name: 'recipient_id', fromJson: _toInt)
    @Default(0)
    int recipientId,
    @JsonKey(name: 'comment_id', fromJson: _toInt) @Default(0) int commentId,
    @Default(false) bool read,
    @Default('') String published,
  }) = _PersonMention;

  factory PersonMention.fromJson(Map<String, dynamic> json) =>
      _$PersonMentionFromJson(json);
}

// ── PersonMentionView ─────────────────────────────────────────────────────────
@Freezed(toJson: false)
abstract class PersonMentionView with _$PersonMentionView {
  const factory PersonMentionView({
    @JsonKey(name: 'person_mention') required PersonMention personMention,
    required Comment comment,
    required Person creator,
    required Post post,
    required Community community,
    required Person recipient,
    required CommentAggregates counts,
    @JsonKey(name: 'creator_banned_from_community')
    @Default(false)
    bool creatorBannedFromCommunity,
    @JsonKey(name: 'banned_from_community')
    @Default(false)
    bool bannedFromCommunity,
    @JsonKey(name: 'creator_is_moderator')
    @Default(false)
    bool creatorIsModerator,
    @JsonKey(name: 'creator_is_admin') @Default(false) bool creatorIsAdmin,
    @Default('NotSubscribed') String subscribed,
    @Default(false) bool saved,
    @JsonKey(name: 'creator_blocked') @Default(false) bool creatorBlocked,
    @JsonKey(name: 'my_vote', fromJson: _toNullableInt) int? myVote,
  }) = _PersonMentionView;

  factory PersonMentionView.fromJson(Map<String, dynamic> json) =>
      _$PersonMentionViewFromJson(json);
}

// ── PrivateMessage ────────────────────────────────────────────────────────────
@Freezed(toJson: false)
abstract class PrivateMessage with _$PrivateMessage {
  const factory PrivateMessage({
    @JsonKey(fromJson: _toInt) @Default(0) int id,
    @JsonKey(name: 'creator_id', fromJson: _toInt) @Default(0) int creatorId,
    @JsonKey(name: 'recipient_id', fromJson: _toInt)
    @Default(0)
    int recipientId,
    @Default('') String content,
    @Default(false) bool deleted,
    @Default(false) bool read,
    @Default('') String published,
    String? updated,
    @JsonKey(name: 'ap_id') @Default('') String apId,
    @Default(true) bool local,
  }) = _PrivateMessage;

  factory PrivateMessage.fromJson(Map<String, dynamic> json) =>
      _$PrivateMessageFromJson(json);
}

// ── PrivateMessageView ────────────────────────────────────────────────────────
@Freezed(toJson: false)
abstract class PrivateMessageView with _$PrivateMessageView {
  const factory PrivateMessageView({
    @JsonKey(name: 'private_message') required PrivateMessage privateMessage,
    required Person creator,
    required Person recipient,
  }) = _PrivateMessageView;

  factory PrivateMessageView.fromJson(Map<String, dynamic> json) =>
      _$PrivateMessageViewFromJson(json);
}

// ── GetUnreadCountResponse ────────────────────────────────────────────────────
@Freezed(toJson: false)
abstract class GetUnreadCountResponse with _$GetUnreadCountResponse {
  const GetUnreadCountResponse._();

  const factory GetUnreadCountResponse({
    @JsonKey(fromJson: _toInt) @Default(0) int replies,
    @JsonKey(fromJson: _toInt) @Default(0) int mentions,
    @JsonKey(name: 'private_messages', fromJson: _toInt)
    @Default(0)
    int privateMessages,
  }) = _GetUnreadCountResponse;

  factory GetUnreadCountResponse.fromJson(Map<String, dynamic> json) =>
      _$GetUnreadCountResponseFromJson(json);

  int get totalNotifications => replies + mentions;
  int get totalAll => replies + mentions + privateMessages;
}
