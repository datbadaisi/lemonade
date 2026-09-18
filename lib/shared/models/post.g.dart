// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Post _$PostFromJson(Map<String, dynamic> json) => _Post(
  id: json['id'] == null ? 0 : _toInt(json['id']),
  name: json['name'] as String? ?? '',
  url: _cleanImageUrl(json['url']),
  body: json['body'] as String?,
  creatorId: json['creator_id'] == null ? 0 : _toInt(json['creator_id']),
  communityId: json['community_id'] == null ? 0 : _toInt(json['community_id']),
  removed: json['removed'] as bool? ?? false,
  locked: json['locked'] as bool? ?? false,
  published: json['published'] as String? ?? '',
  updated: json['updated'] as String?,
  deleted: json['deleted'] as bool? ?? false,
  nsfw: json['nsfw'] as bool? ?? false,
  embedTitle: json['embed_title'] as String?,
  embedDescription: json['embed_description'] as String?,
  thumbnailUrl: _cleanImageUrl(json['thumbnail_url']),
  apId: json['ap_id'] as String? ?? '',
  local: json['local'] as bool? ?? true,
  embedVideoUrl: json['embed_video_url'] as String?,
  languageId: json['language_id'] == null ? 0 : _toInt(json['language_id']),
  featuredCommunity: json['featured_community'] as bool? ?? false,
  featuredLocal: json['featured_local'] as bool? ?? false,
  urlContentType: json['url_content_type'] as String?,
  altText: json['alt_text'] as String?,
);

_ImageDetails _$ImageDetailsFromJson(Map<String, dynamic> json) =>
    _ImageDetails(
      link: json['link'] as String? ?? '',
      width: json['width'] == null ? 0 : _toInt(json['width']),
      height: json['height'] == null ? 0 : _toInt(json['height']),
      contentType: json['content_type'] as String? ?? '',
    );

_PostAggregates _$PostAggregatesFromJson(Map<String, dynamic> json) =>
    _PostAggregates(
      postId: json['post_id'] == null ? 0 : _toInt(json['post_id']),
      comments: json['comments'] == null ? 0 : _toInt(json['comments']),
      score: json['score'] == null ? 0 : _toInt(json['score']),
      upvotes: json['upvotes'] == null ? 0 : _toInt(json['upvotes']),
      downvotes: json['downvotes'] == null ? 0 : _toInt(json['downvotes']),
      published: json['published'] as String? ?? '',
      newestCommentTime: json['newest_comment_time'] as String? ?? '',
    );

_Person _$PersonFromJson(Map<String, dynamic> json) => _Person(
  id: json['id'] == null ? 0 : _toInt(json['id']),
  name: json['name'] as String? ?? '',
  displayName: json['display_name'] as String?,
  avatar: json['avatar'] as String?,
  banned: json['banned'] as bool? ?? false,
  published: json['published'] as String? ?? '',
  updated: json['updated'] as String?,
  actorId: json['actor_id'] as String? ?? '',
  bio: json['bio'] as String?,
  local: json['local'] as bool? ?? true,
  banner: json['banner'] as String?,
  deleted: json['deleted'] as bool? ?? false,
  matrixUserId: json['matrix_user_id'] as String?,
  botAccount: json['bot_account'] as bool? ?? false,
  banExpires: json['ban_expires'] as String?,
  instanceId: json['instance_id'] == null ? 0 : _toInt(json['instance_id']),
);

_Community _$CommunityFromJson(Map<String, dynamic> json) => _Community(
  id: json['id'] == null ? 0 : _toInt(json['id']),
  name: json['name'] as String? ?? '',
  title: json['title'] as String? ?? '',
  description: json['description'] as String?,
  removed: json['removed'] as bool? ?? false,
  published: json['published'] as String? ?? '',
  updated: json['updated'] as String?,
  deleted: json['deleted'] as bool? ?? false,
  nsfw: json['nsfw'] as bool? ?? false,
  actorId: json['actor_id'] as String? ?? '',
  local: json['local'] as bool? ?? true,
  icon: json['icon'] as String?,
  banner: json['banner'] as String?,
  hidden: json['hidden'] as bool? ?? false,
  postingRestrictedToMods: json['posting_restricted_to_mods'] as bool? ?? false,
  instanceId: json['instance_id'] == null ? 0 : _toInt(json['instance_id']),
  visibility: json['visibility'] as String?,
);

_PostView _$PostViewFromJson(Map<String, dynamic> json) => _PostView(
  post: Post.fromJson(json['post'] as Map<String, dynamic>),
  creator: Person.fromJson(json['creator'] as Map<String, dynamic>),
  community: Community.fromJson(json['community'] as Map<String, dynamic>),
  counts: PostAggregates.fromJson(json['counts'] as Map<String, dynamic>),
  imageDetails: json['image_details'] == null
      ? null
      : ImageDetails.fromJson(json['image_details'] as Map<String, dynamic>),
  subscribed: json['subscribed'] as String? ?? 'NotSubscribed',
  saved: json['saved'] as bool? ?? false,
  read: json['read'] as bool? ?? false,
  hidden: json['hidden'] as bool? ?? false,
  creatorBlocked: json['creator_blocked'] as bool? ?? false,
  myVote: _toNullableInt(json['my_vote']),
  unreadComments: json['unread_comments'] == null
      ? 0
      : _toInt(json['unread_comments']),
  creatorBannedFromCommunity:
      json['creator_banned_from_community'] as bool? ?? false,
  bannedFromCommunity: json['banned_from_community'] as bool? ?? false,
  creatorIsModerator: json['creator_is_moderator'] as bool? ?? false,
  creatorIsAdmin: json['creator_is_admin'] as bool? ?? false,
);

_CommunityAggregates _$CommunityAggregatesFromJson(
  Map<String, dynamic> json,
) => _CommunityAggregates(
  communityId: json['community_id'] == null ? 0 : _toInt(json['community_id']),
  subscribers: json['subscribers'] == null ? 0 : _toInt(json['subscribers']),
  posts: json['posts'] == null ? 0 : _toInt(json['posts']),
  comments: json['comments'] == null ? 0 : _toInt(json['comments']),
  published: json['published'] as String? ?? '',
  usersActiveDay: json['users_active_day'] == null
      ? 0
      : _toInt(json['users_active_day']),
  usersActiveWeek: json['users_active_week'] == null
      ? 0
      : _toInt(json['users_active_week']),
  usersActiveMonth: json['users_active_month'] == null
      ? 0
      : _toInt(json['users_active_month']),
  usersActiveHalfYear: json['users_active_half_year'] == null
      ? 0
      : _toInt(json['users_active_half_year']),
  subscribersLocal: json['subscribers_local'] == null
      ? 0
      : _toInt(json['subscribers_local']),
);

_CommunityView _$CommunityViewFromJson(Map<String, dynamic> json) =>
    _CommunityView(
      community: Community.fromJson(json['community'] as Map<String, dynamic>),
      subscribed: json['subscribed'] as String? ?? 'NotSubscribed',
      blocked: json['blocked'] as bool? ?? false,
      counts: CommunityAggregates.fromJson(
        json['counts'] as Map<String, dynamic>,
      ),
      bannedFromCommunity: json['banned_from_community'] as bool? ?? false,
      moderators:
          (json['moderators'] as List<dynamic>?)
              ?.map(
                (e) =>
                    CommunityModeratorView.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <CommunityModeratorView>[],
    );

_CommunityModeratorView _$CommunityModeratorViewFromJson(
  Map<String, dynamic> json,
) => _CommunityModeratorView(
  community: Community.fromJson(json['community'] as Map<String, dynamic>),
  moderator: Person.fromJson(json['moderator'] as Map<String, dynamic>),
);
