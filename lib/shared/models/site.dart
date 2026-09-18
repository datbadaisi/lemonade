import 'package:freezed_annotation/freezed_annotation.dart';

import 'post.dart';

part 'site.freezed.dart';
part 'site.g.dart';

/// Safely parse a value from JSON that might be String or num into int.
int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

List<int> _toIntList(Object? value) {
  if (value is! List) return const [];
  return value.map(_toInt).toList();
}

List<CommunityBlockView> _toCommunityBlocks(Object? value) {
  if (value is! List) return const [];
  return value
      .map((e) => CommunityBlockView.fromJson(e as Map<String, dynamic>))
      .toList();
}

List<InstanceBlockView> _toInstanceBlocks(Object? value) {
  if (value is! List) return const [];
  return value
      .map((e) => InstanceBlockView.fromJson(e as Map<String, dynamic>))
      .toList();
}

List<PersonBlockView> _toPersonBlocks(Object? value) {
  if (value is! List) return const [];
  return value
      .map((e) => PersonBlockView.fromJson(e as Map<String, dynamic>))
      .toList();
}

@Freezed(toJson: false)
abstract class Site with _$Site {
  const factory Site({
    @JsonKey(fromJson: _toInt) @Default(0) int id,
    @Default('') String name,
    String? sidebar,
    @Default('') String published,
    String? updated,
    String? icon,
    String? banner,
    String? description,
    @JsonKey(name: 'actor_id') @Default('') String actorId,
    @JsonKey(name: 'last_refreshed_at') @Default('') String lastRefreshedAt,
    @JsonKey(name: 'inbox_url') @Default('') String inboxUrl,
    @JsonKey(name: 'public_key') @Default('') String publicKey,
    @JsonKey(name: 'instance_id', fromJson: _toInt) @Default(0) int instanceId,
    @JsonKey(name: 'content_warning') String? contentWarning,
  }) = _Site;

  factory Site.fromJson(Map<String, dynamic> json) => _$SiteFromJson(json);
}

@Freezed(toJson: false)
abstract class SiteAggregates with _$SiteAggregates {
  const factory SiteAggregates({
    @JsonKey(name: 'site_id', fromJson: _toInt) @Default(0) int siteId,
    @JsonKey(fromJson: _toInt) @Default(0) int users,
    @JsonKey(fromJson: _toInt) @Default(0) int posts,
    @JsonKey(fromJson: _toInt) @Default(0) int comments,
    @JsonKey(fromJson: _toInt) @Default(0) int communities,
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
  }) = _SiteAggregates;

  factory SiteAggregates.fromJson(Map<String, dynamic> json) =>
      _$SiteAggregatesFromJson(json);
}

@Freezed(toJson: false)
abstract class SiteView with _$SiteView {
  const factory SiteView({
    required Site site,
    required SiteAggregates counts,
  }) = _SiteView;

  factory SiteView.fromJson(Map<String, dynamic> json) =>
      _$SiteViewFromJson(json);
}

/// A person with their aggregate stats and admin status.
@Freezed(toJson: false)
abstract class PersonView with _$PersonView {
  const factory PersonView({
    required Person person,
    required PersonAggregates counts,
    @JsonKey(name: 'is_admin') @Default(false) bool isAdmin,
  }) = _PersonView;

  factory PersonView.fromJson(Map<String, dynamic> json) =>
      _$PersonViewFromJson(json);
}

/// Aggregated stats for a person (used in LocalUserView).
@Freezed(toJson: false)
abstract class PersonAggregates with _$PersonAggregates {
  const factory PersonAggregates({
    @JsonKey(name: 'person_id', fromJson: _toInt) @Default(0) int personId,
    @JsonKey(name: 'post_count', fromJson: _toInt) @Default(0) int postCount,
    @JsonKey(name: 'comment_count', fromJson: _toInt)
    @Default(0)
    int commentCount,
  }) = _PersonAggregates;

  factory PersonAggregates.fromJson(Map<String, dynamic> json) =>
      _$PersonAggregatesFromJson(json);
}

@Freezed(toJson: false)
abstract class GetSiteResponse with _$GetSiteResponse {
  const factory GetSiteResponse({
    @JsonKey(name: 'site_view') required SiteView siteView,
    @Default(<dynamic>[]) List<dynamic> admins,
    @Default('') String version,
    @JsonKey(name: 'my_user') MyUserInfo? myUser,
    @JsonKey(name: 'all_languages') List<dynamic>? allLanguages,
    @JsonKey(name: 'discussion_languages') List<dynamic>? discussionLanguages,
    List<dynamic>? taglines,
    @JsonKey(name: 'custom_emojis') List<dynamic>? customEmojis,
    @JsonKey(name: 'blocked_urls') List<dynamic>? blockedUrls,
  }) = _GetSiteResponse;

  factory GetSiteResponse.fromJson(Map<String, dynamic> json) =>
      _$GetSiteResponseFromJson(json);
}

/// Information about the authenticated user, returned in [GetSiteResponse].
@Freezed(toJson: false)
abstract class MyUserInfo with _$MyUserInfo {
  const MyUserInfo._();

  const factory MyUserInfo({
    @JsonKey(name: 'local_user_view') required LocalUserView localUserView,
    @Default(<dynamic>[]) List<dynamic> follows,
    @Default(<dynamic>[]) List<dynamic> moderates,
    @JsonKey(name: 'community_blocks', fromJson: _toCommunityBlocks)
    @Default(<CommunityBlockView>[])
    List<CommunityBlockView> communityBlocks,
    @JsonKey(name: 'instance_blocks', fromJson: _toInstanceBlocks)
    @Default(<InstanceBlockView>[])
    List<InstanceBlockView> instanceBlocks,
    @JsonKey(name: 'person_blocks', fromJson: _toPersonBlocks)
    @Default(<PersonBlockView>[])
    List<PersonBlockView> personBlocks,
    @JsonKey(name: 'discussion_languages', fromJson: _toIntList)
    @Default(<int>[])
    List<int> discussionLanguages,
  }) = _MyUserInfo;

  factory MyUserInfo.fromJson(Map<String, dynamic> json) =>
      _$MyUserInfoFromJson(json);

  Person get person => localUserView.person;
}

@Freezed(toJson: false)
abstract class LocalUserView with _$LocalUserView {
  const factory LocalUserView({
    @JsonKey(name: 'local_user') required LocalUser localUser,
    required Person person,
    required PersonAggregates counts,
  }) = _LocalUserView;

  factory LocalUserView.fromJson(Map<String, dynamic> json) =>
      _$LocalUserViewFromJson(json);
}

@Freezed(toJson: false)
abstract class LocalUser with _$LocalUser {
  const factory LocalUser({
    @JsonKey(fromJson: _toInt) @Default(0) int id,
    @JsonKey(name: 'person_id', fromJson: _toInt) @Default(0) int personId,
    String? email,
    @JsonKey(name: 'show_nsfw') @Default(false) bool showNsfw,
    String? theme,
    // Preserves legacy parse: missing values become 0 via _toInt.
    @JsonKey(name: 'default_sort_type', fromJson: _toInt) int? defaultSortType,
    @JsonKey(name: 'default_listing_type', fromJson: _toInt)
    int? defaultListingType,
    @JsonKey(name: 'interface_language') String? interfaceLanguage,
    @JsonKey(name: 'show_avatars') @Default(true) bool showAvatars,
    @JsonKey(name: 'send_notifications_to_email')
    @Default(false)
    bool sendNotificationsToEmail,
    @JsonKey(name: 'show_scores') @Default(true) bool showScores,
    @JsonKey(name: 'show_bot_accounts') @Default(true) bool showBotAccounts,
    @JsonKey(name: 'show_read_posts') @Default(true) bool showReadPosts,
    @JsonKey(name: 'email_verified') @Default(false) bool emailVerified,
    @JsonKey(name: 'accepted_application')
    @Default(false)
    bool acceptedApplication,
    @JsonKey(name: 'open_links_in_new_tab')
    @Default(false)
    bool openLinksInNewTab,
    @JsonKey(name: 'blur_nsfw') @Default(true) bool blurNsfw,
    @JsonKey(name: 'auto_expand') @Default(false) bool autoExpand,
    @JsonKey(name: 'infinite_scroll_enabled')
    @Default(true)
    bool infiniteScrollEnabled,
    @Default(false) bool admin,
    @JsonKey(name: 'post_listing_mode', fromJson: _toInt) int? postListingMode,
    @JsonKey(name: 'totp_2fa_enabled') @Default(false) bool totp2faEnabled,
    @JsonKey(name: 'enable_keyboard_navigation')
    @Default(false)
    bool enableKeyboardNavigation,
    @JsonKey(name: 'enable_animated_images')
    @Default(true)
    bool enableAnimatedImages,
    @JsonKey(name: 'collapse_bot_comments')
    @Default(false)
    bool collapseBotComments,
  }) = _LocalUser;

  factory LocalUser.fromJson(Map<String, dynamic> json) =>
      _$LocalUserFromJson(json);
}

@Freezed(toJson: false)
abstract class Instance with _$Instance {
  const factory Instance({
    @JsonKey(fromJson: _toInt) @Default(0) int id,
    @Default('') String domain,
    @Default('') String published,
    String? updated,
    String? software,
    String? version,
  }) = _Instance;

  factory Instance.fromJson(Map<String, dynamic> json) =>
      _$InstanceFromJson(json);
}

@Freezed(toJson: false)
abstract class PersonBlockView with _$PersonBlockView {
  const factory PersonBlockView({
    required Person person,
    required Person target,
  }) = _PersonBlockView;

  factory PersonBlockView.fromJson(Map<String, dynamic> json) =>
      _$PersonBlockViewFromJson(json);
}

@Freezed(toJson: false)
abstract class CommunityBlockView with _$CommunityBlockView {
  const factory CommunityBlockView({
    required Person person,
    required Community community,
  }) = _CommunityBlockView;

  factory CommunityBlockView.fromJson(Map<String, dynamic> json) =>
      _$CommunityBlockViewFromJson(json);
}

@Freezed(toJson: false)
abstract class InstanceBlockView with _$InstanceBlockView {
  const factory InstanceBlockView({
    required Person person,
    required Instance instance,
  }) = _InstanceBlockView;

  factory InstanceBlockView.fromJson(Map<String, dynamic> json) =>
      _$InstanceBlockViewFromJson(json);
}
