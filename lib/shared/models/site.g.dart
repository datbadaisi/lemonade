// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Site _$SiteFromJson(Map<String, dynamic> json) => _Site(
  id: json['id'] == null ? 0 : _toInt(json['id']),
  name: json['name'] as String? ?? '',
  sidebar: json['sidebar'] as String?,
  published: json['published'] as String? ?? '',
  updated: json['updated'] as String?,
  icon: json['icon'] as String?,
  banner: json['banner'] as String?,
  description: json['description'] as String?,
  actorId: json['actor_id'] as String? ?? '',
  lastRefreshedAt: json['last_refreshed_at'] as String? ?? '',
  inboxUrl: json['inbox_url'] as String? ?? '',
  publicKey: json['public_key'] as String? ?? '',
  instanceId: json['instance_id'] == null ? 0 : _toInt(json['instance_id']),
  contentWarning: json['content_warning'] as String?,
);

_SiteAggregates _$SiteAggregatesFromJson(Map<String, dynamic> json) =>
    _SiteAggregates(
      siteId: json['site_id'] == null ? 0 : _toInt(json['site_id']),
      users: json['users'] == null ? 0 : _toInt(json['users']),
      posts: json['posts'] == null ? 0 : _toInt(json['posts']),
      comments: json['comments'] == null ? 0 : _toInt(json['comments']),
      communities: json['communities'] == null
          ? 0
          : _toInt(json['communities']),
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
    );

_SiteView _$SiteViewFromJson(Map<String, dynamic> json) => _SiteView(
  site: Site.fromJson(json['site'] as Map<String, dynamic>),
  counts: SiteAggregates.fromJson(json['counts'] as Map<String, dynamic>),
);

_PersonView _$PersonViewFromJson(Map<String, dynamic> json) => _PersonView(
  person: Person.fromJson(json['person'] as Map<String, dynamic>),
  counts: PersonAggregates.fromJson(json['counts'] as Map<String, dynamic>),
  isAdmin: json['is_admin'] as bool? ?? false,
);

_PersonAggregates _$PersonAggregatesFromJson(Map<String, dynamic> json) =>
    _PersonAggregates(
      personId: json['person_id'] == null ? 0 : _toInt(json['person_id']),
      postCount: json['post_count'] == null ? 0 : _toInt(json['post_count']),
      commentCount: json['comment_count'] == null
          ? 0
          : _toInt(json['comment_count']),
    );

_GetSiteResponse _$GetSiteResponseFromJson(Map<String, dynamic> json) =>
    _GetSiteResponse(
      siteView: SiteView.fromJson(json['site_view'] as Map<String, dynamic>),
      admins: json['admins'] as List<dynamic>? ?? const <dynamic>[],
      version: json['version'] as String? ?? '',
      myUser: json['my_user'] == null
          ? null
          : MyUserInfo.fromJson(json['my_user'] as Map<String, dynamic>),
      allLanguages: json['all_languages'] as List<dynamic>?,
      discussionLanguages: json['discussion_languages'] as List<dynamic>?,
      taglines: json['taglines'] as List<dynamic>?,
      customEmojis: json['custom_emojis'] as List<dynamic>?,
      blockedUrls: json['blocked_urls'] as List<dynamic>?,
    );

_MyUserInfo _$MyUserInfoFromJson(Map<String, dynamic> json) => _MyUserInfo(
  localUserView: LocalUserView.fromJson(
    json['local_user_view'] as Map<String, dynamic>,
  ),
  follows: json['follows'] as List<dynamic>? ?? const <dynamic>[],
  moderates: json['moderates'] as List<dynamic>? ?? const <dynamic>[],
  communityBlocks: json['community_blocks'] == null
      ? const <CommunityBlockView>[]
      : _toCommunityBlocks(json['community_blocks']),
  instanceBlocks: json['instance_blocks'] == null
      ? const <InstanceBlockView>[]
      : _toInstanceBlocks(json['instance_blocks']),
  personBlocks: json['person_blocks'] == null
      ? const <PersonBlockView>[]
      : _toPersonBlocks(json['person_blocks']),
  discussionLanguages: json['discussion_languages'] == null
      ? const <int>[]
      : _toIntList(json['discussion_languages']),
);

_LocalUserView _$LocalUserViewFromJson(Map<String, dynamic> json) =>
    _LocalUserView(
      localUser: LocalUser.fromJson(json['local_user'] as Map<String, dynamic>),
      person: Person.fromJson(json['person'] as Map<String, dynamic>),
      counts: PersonAggregates.fromJson(json['counts'] as Map<String, dynamic>),
    );

_LocalUser _$LocalUserFromJson(Map<String, dynamic> json) => _LocalUser(
  id: json['id'] == null ? 0 : _toInt(json['id']),
  personId: json['person_id'] == null ? 0 : _toInt(json['person_id']),
  email: json['email'] as String?,
  showNsfw: json['show_nsfw'] as bool? ?? false,
  theme: json['theme'] as String?,
  defaultSortType: _toInt(json['default_sort_type']),
  defaultListingType: _toInt(json['default_listing_type']),
  interfaceLanguage: json['interface_language'] as String?,
  showAvatars: json['show_avatars'] as bool? ?? true,
  sendNotificationsToEmail:
      json['send_notifications_to_email'] as bool? ?? false,
  showScores: json['show_scores'] as bool? ?? true,
  showBotAccounts: json['show_bot_accounts'] as bool? ?? true,
  showReadPosts: json['show_read_posts'] as bool? ?? true,
  emailVerified: json['email_verified'] as bool? ?? false,
  acceptedApplication: json['accepted_application'] as bool? ?? false,
  openLinksInNewTab: json['open_links_in_new_tab'] as bool? ?? false,
  blurNsfw: json['blur_nsfw'] as bool? ?? true,
  autoExpand: json['auto_expand'] as bool? ?? false,
  infiniteScrollEnabled: json['infinite_scroll_enabled'] as bool? ?? true,
  admin: json['admin'] as bool? ?? false,
  postListingMode: _toInt(json['post_listing_mode']),
  totp2faEnabled: json['totp_2fa_enabled'] as bool? ?? false,
  enableKeyboardNavigation:
      json['enable_keyboard_navigation'] as bool? ?? false,
  enableAnimatedImages: json['enable_animated_images'] as bool? ?? true,
  collapseBotComments: json['collapse_bot_comments'] as bool? ?? false,
);

_Instance _$InstanceFromJson(Map<String, dynamic> json) => _Instance(
  id: json['id'] == null ? 0 : _toInt(json['id']),
  domain: json['domain'] as String? ?? '',
  published: json['published'] as String? ?? '',
  updated: json['updated'] as String?,
  software: json['software'] as String?,
  version: json['version'] as String?,
);

_PersonBlockView _$PersonBlockViewFromJson(Map<String, dynamic> json) =>
    _PersonBlockView(
      person: Person.fromJson(json['person'] as Map<String, dynamic>),
      target: Person.fromJson(json['target'] as Map<String, dynamic>),
    );

_CommunityBlockView _$CommunityBlockViewFromJson(Map<String, dynamic> json) =>
    _CommunityBlockView(
      person: Person.fromJson(json['person'] as Map<String, dynamic>),
      community: Community.fromJson(json['community'] as Map<String, dynamic>),
    );

_InstanceBlockView _$InstanceBlockViewFromJson(Map<String, dynamic> json) =>
    _InstanceBlockView(
      person: Person.fromJson(json['person'] as Map<String, dynamic>),
      instance: Instance.fromJson(json['instance'] as Map<String, dynamic>),
    );
