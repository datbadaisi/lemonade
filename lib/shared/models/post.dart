import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';
part 'post.g.dart';

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

/// Keep Lemmy `image_proxy` URLs as-is. Unwrapping to the origin often breaks
/// images that the home instance can still serve from cache (e.g. origin 451).
String? _cleanImageUrl(Object? value) => value is String ? value : null;

@Freezed(toJson: false)
abstract class Post with _$Post {
  const factory Post({
    @JsonKey(fromJson: _toInt) @Default(0) int id,
    @Default('') String name,
    @JsonKey(fromJson: _cleanImageUrl) String? url,
    String? body,
    @JsonKey(name: 'creator_id', fromJson: _toInt) @Default(0) int creatorId,
    @JsonKey(name: 'community_id', fromJson: _toInt)
    @Default(0)
    int communityId,
    @Default(false) bool removed,
    @Default(false) bool locked,
    @Default('') String published,
    String? updated,
    @Default(false) bool deleted,
    @Default(false) bool nsfw,
    @JsonKey(name: 'embed_title') String? embedTitle,
    @JsonKey(name: 'embed_description') String? embedDescription,
    @JsonKey(name: 'thumbnail_url', fromJson: _cleanImageUrl)
    String? thumbnailUrl,
    @JsonKey(name: 'ap_id') @Default('') String apId,
    @Default(true) bool local,
    @JsonKey(name: 'embed_video_url') String? embedVideoUrl,
    @JsonKey(name: 'language_id', fromJson: _toInt) @Default(0) int languageId,
    @JsonKey(name: 'featured_community') @Default(false) bool featuredCommunity,
    @JsonKey(name: 'featured_local') @Default(false) bool featuredLocal,
    @JsonKey(name: 'url_content_type') String? urlContentType,
    @JsonKey(name: 'alt_text') String? altText,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}

@Freezed(toJson: false)
abstract class ImageDetails with _$ImageDetails {
  const ImageDetails._();

  const factory ImageDetails({
    @Default('') String link,
    @JsonKey(fromJson: _toInt) @Default(0) int width,
    @JsonKey(fromJson: _toInt) @Default(0) int height,
    @JsonKey(name: 'content_type') @Default('') String contentType,
  }) = _ImageDetails;

  factory ImageDetails.fromJson(Map<String, dynamic> json) =>
      _$ImageDetailsFromJson(json);

  double get aspectRatio => width > 0 && height > 0 ? width / height : 16 / 9;
}

@Freezed(toJson: false)
abstract class PostAggregates with _$PostAggregates {
  const factory PostAggregates({
    @JsonKey(name: 'post_id', fromJson: _toInt) @Default(0) int postId,
    @JsonKey(fromJson: _toInt) @Default(0) int comments,
    @JsonKey(fromJson: _toInt) @Default(0) int score,
    @JsonKey(fromJson: _toInt) @Default(0) int upvotes,
    @JsonKey(fromJson: _toInt) @Default(0) int downvotes,
    @Default('') String published,
    @JsonKey(name: 'newest_comment_time')
    @Default('')
    String newestCommentTime,
  }) = _PostAggregates;

  factory PostAggregates.fromJson(Map<String, dynamic> json) =>
      _$PostAggregatesFromJson(json);
}

@Freezed(toJson: false)
abstract class Person with _$Person {
  const Person._();

  const factory Person({
    @JsonKey(fromJson: _toInt) @Default(0) int id,
    @Default('') String name,
    @JsonKey(name: 'display_name') String? displayName,
    String? avatar,
    @Default(false) bool banned,
    @Default('') String published,
    String? updated,
    @JsonKey(name: 'actor_id') @Default('') String actorId,
    String? bio,
    @Default(true) bool local,
    String? banner,
    @Default(false) bool deleted,
    @JsonKey(name: 'matrix_user_id') String? matrixUserId,
    @JsonKey(name: 'bot_account') @Default(false) bool botAccount,
    @JsonKey(name: 'ban_expires') String? banExpires,
    @JsonKey(name: 'instance_id', fromJson: _toInt) @Default(0) int instanceId,
  }) = _Person;

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

  String get displayNameOrName => displayName ?? name;
}

@Freezed(toJson: false)
abstract class Community with _$Community {
  const factory Community({
    @JsonKey(fromJson: _toInt) @Default(0) int id,
    @Default('') String name,
    @Default('') String title,
    String? description,
    @Default(false) bool removed,
    @Default('') String published,
    String? updated,
    @Default(false) bool deleted,
    @Default(false) bool nsfw,
    @JsonKey(name: 'actor_id') @Default('') String actorId,
    @Default(true) bool local,
    String? icon,
    String? banner,
    @Default(false) bool hidden,
    @JsonKey(name: 'posting_restricted_to_mods')
    @Default(false)
    bool postingRestrictedToMods,
    @JsonKey(name: 'instance_id', fromJson: _toInt) @Default(0) int instanceId,
    String? visibility,
  }) = _Community;

  factory Community.fromJson(Map<String, dynamic> json) =>
      _$CommunityFromJson(json);
}

@Freezed(toJson: false)
abstract class PostView with _$PostView {
  const factory PostView({
    required Post post,
    required Person creator,
    required Community community,
    required PostAggregates counts,
    @JsonKey(name: 'image_details') ImageDetails? imageDetails,
    @Default('NotSubscribed') String subscribed,
    @Default(false) bool saved,
    @Default(false) bool read,
    @Default(false) bool hidden,
    @JsonKey(name: 'creator_blocked') @Default(false) bool creatorBlocked,
    @JsonKey(name: 'my_vote', fromJson: _toNullableInt) int? myVote,
    @JsonKey(name: 'unread_comments', fromJson: _toInt)
    @Default(0)
    int unreadComments,
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
  }) = _PostView;

  factory PostView.fromJson(Map<String, dynamic> json) =>
      _$PostViewFromJson(json);
}

@Freezed(toJson: false)
abstract class CommunityAggregates with _$CommunityAggregates {
  const factory CommunityAggregates({
    @JsonKey(name: 'community_id', fromJson: _toInt)
    @Default(0)
    int communityId,
    @JsonKey(fromJson: _toInt) @Default(0) int subscribers,
    @JsonKey(fromJson: _toInt) @Default(0) int posts,
    @JsonKey(fromJson: _toInt) @Default(0) int comments,
    @Default('') String published,
    @JsonKey(name: 'users_active_day', fromJson: _toInt)
    @Default(0)
    int usersActiveDay,
    @JsonKey(name: 'users_active_week', fromJson: _toInt)
    @Default(0)
    int usersActiveWeek,
    @JsonKey(name: 'users_active_month', fromJson: _toInt)
    @Default(0)
    int usersActiveMonth,
    @JsonKey(name: 'users_active_half_year', fromJson: _toInt)
    @Default(0)
    int usersActiveHalfYear,
    @JsonKey(name: 'subscribers_local', fromJson: _toInt)
    @Default(0)
    int subscribersLocal,
  }) = _CommunityAggregates;

  factory CommunityAggregates.fromJson(Map<String, dynamic> json) =>
      _$CommunityAggregatesFromJson(json);
}

@Freezed(toJson: false)
abstract class CommunityView with _$CommunityView {
  const factory CommunityView({
    required Community community,
    /// "Subscribed" | "NotSubscribed" | "Pending"
    @Default('NotSubscribed') String subscribed,
    @Default(false) bool blocked,
    required CommunityAggregates counts,
    @JsonKey(name: 'banned_from_community')
    @Default(false)
    bool bannedFromCommunity,
    /// Populated after parse via [copyWith] in [LemmyApiClient.getCommunity].
    @Default(<CommunityModeratorView>[])
    List<CommunityModeratorView> moderators,
  }) = _CommunityView;

  factory CommunityView.fromJson(Map<String, dynamic> json) =>
      _$CommunityViewFromJson(json);
}

@Freezed(toJson: false)
abstract class CommunityModeratorView with _$CommunityModeratorView {
  const factory CommunityModeratorView({
    required Community community,
    required Person moderator,
  }) = _CommunityModeratorView;

  factory CommunityModeratorView.fromJson(Map<String, dynamic> json) =>
      _$CommunityModeratorViewFromJson(json);
}

class CreatePostBody {
  final String name;
  final int communityId;
  final String? body;
  final String? url;
  final bool? nsfw;
  final int? languageId;
  final String? altText;
  final String? customThumbnail;

  CreatePostBody({
    required this.name,
    required this.communityId,
    this.body,
    this.url,
    this.nsfw,
    this.languageId,
    this.altText,
    this.customThumbnail,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'community_id': communityId,
    if (body != null) 'body': body,
    if (url != null) 'url': url,
    if (nsfw != null) 'nsfw': nsfw,
    if (languageId != null) 'language_id': languageId,
    if (altText != null) 'alt_text': altText,
    if (customThumbnail != null) 'custom_thumbnail': customThumbnail,
  };
}

/// OpenAPI `EditPost` (v0.19.11) — required: `post_id`.
///
/// Optional: `name`, `url`, `body`, `alt_text`, `nsfw`, `language_id`,
/// `custom_thumbnail`. Omitted keys mean “leave unchanged” on the server
/// (matches Rust `Option` + `skip_serializing_none`).
class EditPostBody {
  final int postId;
  final String? name;
  final String? body;
  final String? url;
  final bool? nsfw;
  final int? languageId;
  final String? altText;
  final String? customThumbnail;

  const EditPostBody({
    required this.postId,
    this.name,
    this.body,
    this.url,
    this.nsfw,
    this.languageId,
    this.altText,
    this.customThumbnail,
  });

  Map<String, dynamic> toJson() => {
    'post_id': postId,
    if (name != null) 'name': name,
    if (url != null) 'url': url,
    if (body != null) 'body': body,
    if (altText != null) 'alt_text': altText,
    if (nsfw != null) 'nsfw': nsfw,
    if (languageId != null) 'language_id': languageId,
    if (customThumbnail != null) 'custom_thumbnail': customThumbnail,
  };
}

/// OpenAPI `DeletePost` — required: post_id, deleted.
class DeletePostBody {
  final int postId;
  final bool deleted;

  const DeletePostBody({required this.postId, required this.deleted});

  Map<String, dynamic> toJson() => {
    'post_id': postId,
    'deleted': deleted,
  };
}

class PostResponse {
  final PostView postView;

  PostResponse({required this.postView});

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(postView: PostView.fromJson(json['post_view']));
  }
}
