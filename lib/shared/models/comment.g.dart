// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Comment _$CommentFromJson(Map<String, dynamic> json) => _Comment(
  id: json['id'] == null ? 0 : _toInt(json['id']),
  creatorId: json['creator_id'] == null ? 0 : _toInt(json['creator_id']),
  postId: json['post_id'] == null ? 0 : _toInt(json['post_id']),
  content: json['content'] as String? ?? '',
  removed: json['removed'] as bool? ?? false,
  published: json['published'] as String? ?? '',
  updated: json['updated'] as String?,
  deleted: json['deleted'] as bool? ?? false,
  apId: json['ap_id'] as String? ?? '',
  local: json['local'] as bool? ?? true,
  path: json['path'] as String? ?? '',
  distinguished: json['distinguished'] as bool? ?? false,
  languageId: json['language_id'] == null ? 0 : _toInt(json['language_id']),
);

_CommentAggregates _$CommentAggregatesFromJson(Map<String, dynamic> json) =>
    _CommentAggregates(
      commentId: json['comment_id'] == null ? 0 : _toInt(json['comment_id']),
      score: json['score'] == null ? 0 : _toInt(json['score']),
      upvotes: json['upvotes'] == null ? 0 : _toInt(json['upvotes']),
      downvotes: json['downvotes'] == null ? 0 : _toInt(json['downvotes']),
      published: json['published'] as String? ?? '',
      childCount: json['child_count'] == null ? 0 : _toInt(json['child_count']),
    );

_CommentView _$CommentViewFromJson(Map<String, dynamic> json) => _CommentView(
  comment: Comment.fromJson(json['comment'] as Map<String, dynamic>),
  creator: Person.fromJson(json['creator'] as Map<String, dynamic>),
  community: Community.fromJson(json['community'] as Map<String, dynamic>),
  post: Post.fromJson(json['post'] as Map<String, dynamic>),
  counts: CommentAggregates.fromJson(json['counts'] as Map<String, dynamic>),
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
