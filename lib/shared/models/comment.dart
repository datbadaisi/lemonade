// ignore_for_file: avoid_dynamic_calls

// ── Comment models — generated from openapi.json v0.19.11 ────────────────────
//
// Aligned with the following OpenAPI schemas:
//   - Comment
//   - CommentView
//   - CommentAggregates
//   - CommentSortType  (enum)
//   - CommentResponse
//   - GetComments      (query params)
//   - GetCommentsResponse
//   - CreateComment    (request body)
//   - CreateCommentLike (request body)
//   - SaveComment      (request body)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bluerum/shared/models/post.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

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

// ── CommentSortType ───────────────────────────────────────────────────────────
//
// OpenAPI enum: ["Hot","Top","New","Old","Controversial"]
// https://github.com/MV-GH/lemmy_openapi_spec

enum CommentSortType {
  hot('Hot'),
  top('Top'),
  controversial('Controversial'),
  new_('New'),
  old('Old');

  final String value;
  const CommentSortType(this.value);
}

// ── Comment ───────────────────────────────────────────────────────────────────
//
// OpenAPI required: id, creator_id, post_id, content, removed, published,
//                   deleted, ap_id, local, path, distinguished, language_id
// Optional:         updated

@Freezed(toJson: false)
abstract class Comment with _$Comment {
  const Comment._();

  const factory Comment({
    @JsonKey(fromJson: _toInt) @Default(0) int id,
    @JsonKey(name: 'creator_id', fromJson: _toInt) @Default(0) int creatorId,
    @JsonKey(name: 'post_id', fromJson: _toInt) @Default(0) int postId,
    @Default('') String content,
    @Default(false) bool removed,
    @Default('') String published,
    String? updated,
    @Default(false) bool deleted,
    @JsonKey(name: 'ap_id') @Default('') String apId,
    @Default(true) bool local,
    @Default('') String path,
    @Default(false) bool distinguished,
    @JsonKey(name: 'language_id', fromJson: _toInt) @Default(0) int languageId,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  /// Depth in the comment tree.
  ///
  /// Convention (preserved from the original implementation):
  ///   depth = path.split('.').length - 1
  ///
  /// Lemmy path examples:
  ///   "0.12345"        → depth 1  (top-level comment)
  ///   "0.12345.67890"  → depth 2  (first reply)
  ///   "0.1.2.3"        → depth 3  (second reply)
  ///
  /// post_detail_screen.dart treats depth <= 1 as top-level, which matches
  /// this convention.
  int get depth => path.isEmpty ? 1 : path.split('.').length - 1;

  /// ID of the direct parent comment, or null if this is top-level.
  int? get parentId {
    if (path.isEmpty) return null;
    final parts = path.split('.');
    if (parts.length < 3) return null; // "0.id" → top-level
    final parentStr = parts[parts.length - 2];
    final pid = int.tryParse(parentStr);
    // "0" is the virtual root sentinel — not a real comment
    return (pid == null || pid == 0) ? null : pid;
  }

  /// ID of the absolute top-level parent comment in the hierarchy.
  /// If the comment itself is top-level, returns its own ID.
  int get absoluteParentId {
    if (path.isEmpty) return id;
    final parts = path.split('.');
    if (parts.length < 2) return id;
    final pid = int.tryParse(parts[1]);
    return (pid == null || pid == 0) ? id : pid;
  }
}

// ── CommentAggregates ─────────────────────────────────────────────────────────
//
// OpenAPI required: comment_id, score, upvotes, downvotes, published, child_count

@Freezed(toJson: false)
abstract class CommentAggregates with _$CommentAggregates {
  const factory CommentAggregates({
    @JsonKey(name: 'comment_id', fromJson: _toInt) @Default(0) int commentId,
    @JsonKey(fromJson: _toInt) @Default(0) int score,
    @JsonKey(fromJson: _toInt) @Default(0) int upvotes,
    @JsonKey(fromJson: _toInt) @Default(0) int downvotes,
    @Default('') String published,
    @JsonKey(name: 'child_count', fromJson: _toInt) @Default(0) int childCount,
  }) = _CommentAggregates;

  factory CommentAggregates.fromJson(Map<String, dynamic> json) =>
      _$CommentAggregatesFromJson(json);
}

// ── CommentView ───────────────────────────────────────────────────────────────
//
// OpenAPI required: comment, creator, post, community, counts,
//                   creator_banned_from_community, banned_from_community,
//                   creator_is_moderator, creator_is_admin, subscribed,
//                   saved, creator_blocked
// Optional:         my_vote

@Freezed(toJson: false)
abstract class CommentView with _$CommentView {
  const factory CommentView({
    required Comment comment,
    required Person creator,
    required Community community,
    required Post post,
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

    /// SubscribedType enum value, e.g. "Subscribed", "NotSubscribed", "Pending"
    @Default('NotSubscribed') String subscribed,
    @Default(false) bool saved,
    @JsonKey(name: 'creator_blocked') @Default(false) bool creatorBlocked,

    /// Signed integer: 1 = upvoted, -1 = downvoted, null = not voted.
    @JsonKey(name: 'my_vote', fromJson: _toNullableInt) int? myVote,
  }) = _CommentView;

  factory CommentView.fromJson(Map<String, dynamic> json) =>
      _$CommentViewFromJson(json);
}

// ── CommentResponse ───────────────────────────────────────────────────────────
//
// OpenAPI required: comment_view, recipient_ids
// Returned by: POST /comment, PUT /comment, POST /comment/like,
//              PUT /comment/save, POST /comment/delete, etc.

class CommentResponse {
  final CommentView commentView;

  /// IDs of LocalUser recipients (e.g. the person who was replied to).
  final List<int> recipientIds;

  const CommentResponse({
    required this.commentView,
    required this.recipientIds,
  });

  factory CommentResponse.fromJson(Map<String, dynamic> json) {
    return CommentResponse(
      commentView: CommentView.fromJson(
        json['comment_view'] as Map<String, dynamic>),
      recipientIds:
          (json['recipient_ids'] as List<dynamic>?)
              ?.map((e) => _toInt(e))
              .toList() ??
          []);
  }
}

// ── GetCommentsResponse ───────────────────────────────────────────────────────
//
// OpenAPI required: comments

class GetCommentsResponse {
  final List<CommentView> comments;

  const GetCommentsResponse({required this.comments});

  factory GetCommentsResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['comments'] as List<dynamic>? ?? [];
    return GetCommentsResponse(
      comments: raw
          .map((c) => CommentView.fromJson(c as Map<String, dynamic>))
          .toList());
  }
}

// ── GetComments (query params) ────────────────────────────────────────────────
//
// OpenAPI optional: type_, sort, max_depth, page, limit, community_id,
//                   community_name, post_id, parent_id, saved_only,
//                   liked_only, disliked_only

class GetCommentsParams {
  final int? postId;
  final int? parentId;
  final CommentSortType? sort;
  final int? page;
  final int? limit;
  final int? maxDepth;
  final String? type;
  final int? communityId;
  final String? communityName;
  final bool? savedOnly;
  final bool? likedOnly;
  final bool? dislikedOnly;

  const GetCommentsParams({
    this.postId,
    this.parentId,
    this.sort,
    this.page,
    this.limit,
    this.maxDepth,
    this.type,
    this.communityId,
    this.communityName,
    this.savedOnly,
    this.likedOnly,
    this.dislikedOnly,
  });

  /// Serialize to query-parameter map (omitting null values).
  Map<String, String> toQueryParameters() {
    final params = <String, String>{};
    if (postId != null) params['post_id'] = postId.toString();
    if (parentId != null) params['parent_id'] = parentId.toString();
    if (sort != null) params['sort'] = sort!.value;
    if (page != null) params['page'] = page.toString();
    if (limit != null) params['limit'] = limit.toString();
    if (maxDepth != null) params['max_depth'] = maxDepth.toString();
    if (type != null) params['type_'] = type!;
    if (communityId != null) params['community_id'] = communityId.toString();
    if (communityName != null) params['community_name'] = communityName!;
    if (savedOnly != null) params['saved_only'] = savedOnly.toString();
    if (likedOnly != null) params['liked_only'] = likedOnly.toString();
    if (dislikedOnly != null) params['disliked_only'] = dislikedOnly.toString();
    return params;
  }
}

// ── CreateComment (request body) ──────────────────────────────────────────────
//
// OpenAPI required: content, post_id
// Optional:         parent_id, language_id

class CreateCommentBody {
  final String content;
  final int postId;
  final int? parentId;
  final int? languageId;

  const CreateCommentBody({
    required this.content,
    required this.postId,
    this.parentId,
    this.languageId,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'content': content,
      'post_id': postId,
      if (parentId != null) 'parent_id': parentId,
      if (languageId != null) 'language_id': languageId,
    };
  }
}

// ── CreateCommentLike (request body) ─────────────────────────────────────────
//
// OpenAPI required: comment_id, score

class CreateCommentLike {
  final int commentId;

  /// 1 = upvote, -1 = downvote, 0 = remove vote.
  final int score;

  const CreateCommentLike({required this.commentId, required this.score});

  Map<String, dynamic> toJson() => <String, dynamic>{
    'comment_id': commentId,
    'score': score,
  };
}

// ── SaveComment (request body) ────────────────────────────────────────────────
//
// OpenAPI required: comment_id, save

class SaveCommentBody {
  final int commentId;
  final bool save;

  const SaveCommentBody({required this.commentId, required this.save});

  Map<String, dynamic> toJson() => <String, dynamic>{
    'comment_id': commentId,
    'save': save,
  };
}

// ── EditComment (request body) ────────────────────────────────────────────────
//
// OpenAPI required: comment_id
// Optional:         content, language_id

class EditCommentBody {
  final int commentId;
  final String? content;
  final int? languageId;

  const EditCommentBody({
    required this.commentId,
    this.content,
    this.languageId,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'comment_id': commentId,
      if (content != null) 'content': content,
      if (languageId != null) 'language_id': languageId,
    };
  }
}

// ── DeleteComment (request body) ──────────────────────────────────────────────
//
// OpenAPI required: comment_id, deleted

class DeleteCommentBody {
  final int commentId;
  final bool deleted;

  const DeleteCommentBody({required this.commentId, required this.deleted});

  Map<String, dynamic> toJson() => <String, dynamic>{
    'comment_id': commentId,
    'deleted': deleted,
  };
}
