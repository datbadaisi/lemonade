// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Post {

@JsonKey(fromJson: _toInt) int get id; String get name;@JsonKey(fromJson: _cleanImageUrl) String? get url; String? get body;@JsonKey(name: 'creator_id', fromJson: _toInt) int get creatorId;@JsonKey(name: 'community_id', fromJson: _toInt) int get communityId; bool get removed; bool get locked; String get published; String? get updated; bool get deleted; bool get nsfw;@JsonKey(name: 'embed_title') String? get embedTitle;@JsonKey(name: 'embed_description') String? get embedDescription;@JsonKey(name: 'thumbnail_url', fromJson: _cleanImageUrl) String? get thumbnailUrl;@JsonKey(name: 'ap_id') String get apId; bool get local;@JsonKey(name: 'embed_video_url') String? get embedVideoUrl;@JsonKey(name: 'language_id', fromJson: _toInt) int get languageId;@JsonKey(name: 'featured_community') bool get featuredCommunity;@JsonKey(name: 'featured_local') bool get featuredLocal;@JsonKey(name: 'url_content_type') String? get urlContentType;@JsonKey(name: 'alt_text') String? get altText;
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCopyWith<Post> get copyWith => _$PostCopyWithImpl<Post>(this as Post, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Post&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url)&&(identical(other.body, body) || other.body == body)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.communityId, communityId) || other.communityId == communityId)&&(identical(other.removed, removed) || other.removed == removed)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.published, published) || other.published == published)&&(identical(other.updated, updated) || other.updated == updated)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.nsfw, nsfw) || other.nsfw == nsfw)&&(identical(other.embedTitle, embedTitle) || other.embedTitle == embedTitle)&&(identical(other.embedDescription, embedDescription) || other.embedDescription == embedDescription)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.apId, apId) || other.apId == apId)&&(identical(other.local, local) || other.local == local)&&(identical(other.embedVideoUrl, embedVideoUrl) || other.embedVideoUrl == embedVideoUrl)&&(identical(other.languageId, languageId) || other.languageId == languageId)&&(identical(other.featuredCommunity, featuredCommunity) || other.featuredCommunity == featuredCommunity)&&(identical(other.featuredLocal, featuredLocal) || other.featuredLocal == featuredLocal)&&(identical(other.urlContentType, urlContentType) || other.urlContentType == urlContentType)&&(identical(other.altText, altText) || other.altText == altText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,url,body,creatorId,communityId,removed,locked,published,updated,deleted,nsfw,embedTitle,embedDescription,thumbnailUrl,apId,local,embedVideoUrl,languageId,featuredCommunity,featuredLocal,urlContentType,altText]);

@override
String toString() {
  return 'Post(id: $id, name: $name, url: $url, body: $body, creatorId: $creatorId, communityId: $communityId, removed: $removed, locked: $locked, published: $published, updated: $updated, deleted: $deleted, nsfw: $nsfw, embedTitle: $embedTitle, embedDescription: $embedDescription, thumbnailUrl: $thumbnailUrl, apId: $apId, local: $local, embedVideoUrl: $embedVideoUrl, languageId: $languageId, featuredCommunity: $featuredCommunity, featuredLocal: $featuredLocal, urlContentType: $urlContentType, altText: $altText)';
}


}

/// @nodoc
abstract mixin class $PostCopyWith<$Res>  {
  factory $PostCopyWith(Post value, $Res Function(Post) _then) = _$PostCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _toInt) int id, String name,@JsonKey(fromJson: _cleanImageUrl) String? url, String? body,@JsonKey(name: 'creator_id', fromJson: _toInt) int creatorId,@JsonKey(name: 'community_id', fromJson: _toInt) int communityId, bool removed, bool locked, String published, String? updated, bool deleted, bool nsfw,@JsonKey(name: 'embed_title') String? embedTitle,@JsonKey(name: 'embed_description') String? embedDescription,@JsonKey(name: 'thumbnail_url', fromJson: _cleanImageUrl) String? thumbnailUrl,@JsonKey(name: 'ap_id') String apId, bool local,@JsonKey(name: 'embed_video_url') String? embedVideoUrl,@JsonKey(name: 'language_id', fromJson: _toInt) int languageId,@JsonKey(name: 'featured_community') bool featuredCommunity,@JsonKey(name: 'featured_local') bool featuredLocal,@JsonKey(name: 'url_content_type') String? urlContentType,@JsonKey(name: 'alt_text') String? altText
});




}
/// @nodoc
class _$PostCopyWithImpl<$Res>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._self, this._then);

  final Post _self;
  final $Res Function(Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? url = freezed,Object? body = freezed,Object? creatorId = null,Object? communityId = null,Object? removed = null,Object? locked = null,Object? published = null,Object? updated = freezed,Object? deleted = null,Object? nsfw = null,Object? embedTitle = freezed,Object? embedDescription = freezed,Object? thumbnailUrl = freezed,Object? apId = null,Object? local = null,Object? embedVideoUrl = freezed,Object? languageId = null,Object? featuredCommunity = null,Object? featuredLocal = null,Object? urlContentType = freezed,Object? altText = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,communityId: null == communityId ? _self.communityId : communityId // ignore: cast_nullable_to_non_nullable
as int,removed: null == removed ? _self.removed : removed // ignore: cast_nullable_to_non_nullable
as bool,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,updated: freezed == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as String?,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,nsfw: null == nsfw ? _self.nsfw : nsfw // ignore: cast_nullable_to_non_nullable
as bool,embedTitle: freezed == embedTitle ? _self.embedTitle : embedTitle // ignore: cast_nullable_to_non_nullable
as String?,embedDescription: freezed == embedDescription ? _self.embedDescription : embedDescription // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,apId: null == apId ? _self.apId : apId // ignore: cast_nullable_to_non_nullable
as String,local: null == local ? _self.local : local // ignore: cast_nullable_to_non_nullable
as bool,embedVideoUrl: freezed == embedVideoUrl ? _self.embedVideoUrl : embedVideoUrl // ignore: cast_nullable_to_non_nullable
as String?,languageId: null == languageId ? _self.languageId : languageId // ignore: cast_nullable_to_non_nullable
as int,featuredCommunity: null == featuredCommunity ? _self.featuredCommunity : featuredCommunity // ignore: cast_nullable_to_non_nullable
as bool,featuredLocal: null == featuredLocal ? _self.featuredLocal : featuredLocal // ignore: cast_nullable_to_non_nullable
as bool,urlContentType: freezed == urlContentType ? _self.urlContentType : urlContentType // ignore: cast_nullable_to_non_nullable
as String?,altText: freezed == altText ? _self.altText : altText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Post].
extension PostPatterns on Post {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Post value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Post value)  $default,){
final _that = this;
switch (_that) {
case _Post():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Post value)?  $default,){
final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int id,  String name, @JsonKey(fromJson: _cleanImageUrl)  String? url,  String? body, @JsonKey(name: 'creator_id', fromJson: _toInt)  int creatorId, @JsonKey(name: 'community_id', fromJson: _toInt)  int communityId,  bool removed,  bool locked,  String published,  String? updated,  bool deleted,  bool nsfw, @JsonKey(name: 'embed_title')  String? embedTitle, @JsonKey(name: 'embed_description')  String? embedDescription, @JsonKey(name: 'thumbnail_url', fromJson: _cleanImageUrl)  String? thumbnailUrl, @JsonKey(name: 'ap_id')  String apId,  bool local, @JsonKey(name: 'embed_video_url')  String? embedVideoUrl, @JsonKey(name: 'language_id', fromJson: _toInt)  int languageId, @JsonKey(name: 'featured_community')  bool featuredCommunity, @JsonKey(name: 'featured_local')  bool featuredLocal, @JsonKey(name: 'url_content_type')  String? urlContentType, @JsonKey(name: 'alt_text')  String? altText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.name,_that.url,_that.body,_that.creatorId,_that.communityId,_that.removed,_that.locked,_that.published,_that.updated,_that.deleted,_that.nsfw,_that.embedTitle,_that.embedDescription,_that.thumbnailUrl,_that.apId,_that.local,_that.embedVideoUrl,_that.languageId,_that.featuredCommunity,_that.featuredLocal,_that.urlContentType,_that.altText);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int id,  String name, @JsonKey(fromJson: _cleanImageUrl)  String? url,  String? body, @JsonKey(name: 'creator_id', fromJson: _toInt)  int creatorId, @JsonKey(name: 'community_id', fromJson: _toInt)  int communityId,  bool removed,  bool locked,  String published,  String? updated,  bool deleted,  bool nsfw, @JsonKey(name: 'embed_title')  String? embedTitle, @JsonKey(name: 'embed_description')  String? embedDescription, @JsonKey(name: 'thumbnail_url', fromJson: _cleanImageUrl)  String? thumbnailUrl, @JsonKey(name: 'ap_id')  String apId,  bool local, @JsonKey(name: 'embed_video_url')  String? embedVideoUrl, @JsonKey(name: 'language_id', fromJson: _toInt)  int languageId, @JsonKey(name: 'featured_community')  bool featuredCommunity, @JsonKey(name: 'featured_local')  bool featuredLocal, @JsonKey(name: 'url_content_type')  String? urlContentType, @JsonKey(name: 'alt_text')  String? altText)  $default,) {final _that = this;
switch (_that) {
case _Post():
return $default(_that.id,_that.name,_that.url,_that.body,_that.creatorId,_that.communityId,_that.removed,_that.locked,_that.published,_that.updated,_that.deleted,_that.nsfw,_that.embedTitle,_that.embedDescription,_that.thumbnailUrl,_that.apId,_that.local,_that.embedVideoUrl,_that.languageId,_that.featuredCommunity,_that.featuredLocal,_that.urlContentType,_that.altText);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _toInt)  int id,  String name, @JsonKey(fromJson: _cleanImageUrl)  String? url,  String? body, @JsonKey(name: 'creator_id', fromJson: _toInt)  int creatorId, @JsonKey(name: 'community_id', fromJson: _toInt)  int communityId,  bool removed,  bool locked,  String published,  String? updated,  bool deleted,  bool nsfw, @JsonKey(name: 'embed_title')  String? embedTitle, @JsonKey(name: 'embed_description')  String? embedDescription, @JsonKey(name: 'thumbnail_url', fromJson: _cleanImageUrl)  String? thumbnailUrl, @JsonKey(name: 'ap_id')  String apId,  bool local, @JsonKey(name: 'embed_video_url')  String? embedVideoUrl, @JsonKey(name: 'language_id', fromJson: _toInt)  int languageId, @JsonKey(name: 'featured_community')  bool featuredCommunity, @JsonKey(name: 'featured_local')  bool featuredLocal, @JsonKey(name: 'url_content_type')  String? urlContentType, @JsonKey(name: 'alt_text')  String? altText)?  $default,) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.name,_that.url,_that.body,_that.creatorId,_that.communityId,_that.removed,_that.locked,_that.published,_that.updated,_that.deleted,_that.nsfw,_that.embedTitle,_that.embedDescription,_that.thumbnailUrl,_that.apId,_that.local,_that.embedVideoUrl,_that.languageId,_that.featuredCommunity,_that.featuredLocal,_that.urlContentType,_that.altText);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _Post implements Post {
  const _Post({@JsonKey(fromJson: _toInt) this.id = 0, this.name = '', @JsonKey(fromJson: _cleanImageUrl) this.url, this.body, @JsonKey(name: 'creator_id', fromJson: _toInt) this.creatorId = 0, @JsonKey(name: 'community_id', fromJson: _toInt) this.communityId = 0, this.removed = false, this.locked = false, this.published = '', this.updated, this.deleted = false, this.nsfw = false, @JsonKey(name: 'embed_title') this.embedTitle, @JsonKey(name: 'embed_description') this.embedDescription, @JsonKey(name: 'thumbnail_url', fromJson: _cleanImageUrl) this.thumbnailUrl, @JsonKey(name: 'ap_id') this.apId = '', this.local = true, @JsonKey(name: 'embed_video_url') this.embedVideoUrl, @JsonKey(name: 'language_id', fromJson: _toInt) this.languageId = 0, @JsonKey(name: 'featured_community') this.featuredCommunity = false, @JsonKey(name: 'featured_local') this.featuredLocal = false, @JsonKey(name: 'url_content_type') this.urlContentType, @JsonKey(name: 'alt_text') this.altText});
  factory _Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

@override@JsonKey(fromJson: _toInt) final  int id;
@override@JsonKey() final  String name;
@override@JsonKey(fromJson: _cleanImageUrl) final  String? url;
@override final  String? body;
@override@JsonKey(name: 'creator_id', fromJson: _toInt) final  int creatorId;
@override@JsonKey(name: 'community_id', fromJson: _toInt) final  int communityId;
@override@JsonKey() final  bool removed;
@override@JsonKey() final  bool locked;
@override@JsonKey() final  String published;
@override final  String? updated;
@override@JsonKey() final  bool deleted;
@override@JsonKey() final  bool nsfw;
@override@JsonKey(name: 'embed_title') final  String? embedTitle;
@override@JsonKey(name: 'embed_description') final  String? embedDescription;
@override@JsonKey(name: 'thumbnail_url', fromJson: _cleanImageUrl) final  String? thumbnailUrl;
@override@JsonKey(name: 'ap_id') final  String apId;
@override@JsonKey() final  bool local;
@override@JsonKey(name: 'embed_video_url') final  String? embedVideoUrl;
@override@JsonKey(name: 'language_id', fromJson: _toInt) final  int languageId;
@override@JsonKey(name: 'featured_community') final  bool featuredCommunity;
@override@JsonKey(name: 'featured_local') final  bool featuredLocal;
@override@JsonKey(name: 'url_content_type') final  String? urlContentType;
@override@JsonKey(name: 'alt_text') final  String? altText;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostCopyWith<_Post> get copyWith => __$PostCopyWithImpl<_Post>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Post&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url)&&(identical(other.body, body) || other.body == body)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.communityId, communityId) || other.communityId == communityId)&&(identical(other.removed, removed) || other.removed == removed)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.published, published) || other.published == published)&&(identical(other.updated, updated) || other.updated == updated)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.nsfw, nsfw) || other.nsfw == nsfw)&&(identical(other.embedTitle, embedTitle) || other.embedTitle == embedTitle)&&(identical(other.embedDescription, embedDescription) || other.embedDescription == embedDescription)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.apId, apId) || other.apId == apId)&&(identical(other.local, local) || other.local == local)&&(identical(other.embedVideoUrl, embedVideoUrl) || other.embedVideoUrl == embedVideoUrl)&&(identical(other.languageId, languageId) || other.languageId == languageId)&&(identical(other.featuredCommunity, featuredCommunity) || other.featuredCommunity == featuredCommunity)&&(identical(other.featuredLocal, featuredLocal) || other.featuredLocal == featuredLocal)&&(identical(other.urlContentType, urlContentType) || other.urlContentType == urlContentType)&&(identical(other.altText, altText) || other.altText == altText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,url,body,creatorId,communityId,removed,locked,published,updated,deleted,nsfw,embedTitle,embedDescription,thumbnailUrl,apId,local,embedVideoUrl,languageId,featuredCommunity,featuredLocal,urlContentType,altText]);

@override
String toString() {
  return 'Post(id: $id, name: $name, url: $url, body: $body, creatorId: $creatorId, communityId: $communityId, removed: $removed, locked: $locked, published: $published, updated: $updated, deleted: $deleted, nsfw: $nsfw, embedTitle: $embedTitle, embedDescription: $embedDescription, thumbnailUrl: $thumbnailUrl, apId: $apId, local: $local, embedVideoUrl: $embedVideoUrl, languageId: $languageId, featuredCommunity: $featuredCommunity, featuredLocal: $featuredLocal, urlContentType: $urlContentType, altText: $altText)';
}


}

/// @nodoc
abstract mixin class _$PostCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$PostCopyWith(_Post value, $Res Function(_Post) _then) = __$PostCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _toInt) int id, String name,@JsonKey(fromJson: _cleanImageUrl) String? url, String? body,@JsonKey(name: 'creator_id', fromJson: _toInt) int creatorId,@JsonKey(name: 'community_id', fromJson: _toInt) int communityId, bool removed, bool locked, String published, String? updated, bool deleted, bool nsfw,@JsonKey(name: 'embed_title') String? embedTitle,@JsonKey(name: 'embed_description') String? embedDescription,@JsonKey(name: 'thumbnail_url', fromJson: _cleanImageUrl) String? thumbnailUrl,@JsonKey(name: 'ap_id') String apId, bool local,@JsonKey(name: 'embed_video_url') String? embedVideoUrl,@JsonKey(name: 'language_id', fromJson: _toInt) int languageId,@JsonKey(name: 'featured_community') bool featuredCommunity,@JsonKey(name: 'featured_local') bool featuredLocal,@JsonKey(name: 'url_content_type') String? urlContentType,@JsonKey(name: 'alt_text') String? altText
});




}
/// @nodoc
class __$PostCopyWithImpl<$Res>
    implements _$PostCopyWith<$Res> {
  __$PostCopyWithImpl(this._self, this._then);

  final _Post _self;
  final $Res Function(_Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? url = freezed,Object? body = freezed,Object? creatorId = null,Object? communityId = null,Object? removed = null,Object? locked = null,Object? published = null,Object? updated = freezed,Object? deleted = null,Object? nsfw = null,Object? embedTitle = freezed,Object? embedDescription = freezed,Object? thumbnailUrl = freezed,Object? apId = null,Object? local = null,Object? embedVideoUrl = freezed,Object? languageId = null,Object? featuredCommunity = null,Object? featuredLocal = null,Object? urlContentType = freezed,Object? altText = freezed,}) {
  return _then(_Post(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,communityId: null == communityId ? _self.communityId : communityId // ignore: cast_nullable_to_non_nullable
as int,removed: null == removed ? _self.removed : removed // ignore: cast_nullable_to_non_nullable
as bool,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,updated: freezed == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as String?,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,nsfw: null == nsfw ? _self.nsfw : nsfw // ignore: cast_nullable_to_non_nullable
as bool,embedTitle: freezed == embedTitle ? _self.embedTitle : embedTitle // ignore: cast_nullable_to_non_nullable
as String?,embedDescription: freezed == embedDescription ? _self.embedDescription : embedDescription // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,apId: null == apId ? _self.apId : apId // ignore: cast_nullable_to_non_nullable
as String,local: null == local ? _self.local : local // ignore: cast_nullable_to_non_nullable
as bool,embedVideoUrl: freezed == embedVideoUrl ? _self.embedVideoUrl : embedVideoUrl // ignore: cast_nullable_to_non_nullable
as String?,languageId: null == languageId ? _self.languageId : languageId // ignore: cast_nullable_to_non_nullable
as int,featuredCommunity: null == featuredCommunity ? _self.featuredCommunity : featuredCommunity // ignore: cast_nullable_to_non_nullable
as bool,featuredLocal: null == featuredLocal ? _self.featuredLocal : featuredLocal // ignore: cast_nullable_to_non_nullable
as bool,urlContentType: freezed == urlContentType ? _self.urlContentType : urlContentType // ignore: cast_nullable_to_non_nullable
as String?,altText: freezed == altText ? _self.altText : altText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ImageDetails {

 String get link;@JsonKey(fromJson: _toInt) int get width;@JsonKey(fromJson: _toInt) int get height;@JsonKey(name: 'content_type') String get contentType;
/// Create a copy of ImageDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageDetailsCopyWith<ImageDetails> get copyWith => _$ImageDetailsCopyWithImpl<ImageDetails>(this as ImageDetails, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageDetails&&(identical(other.link, link) || other.link == link)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.contentType, contentType) || other.contentType == contentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,link,width,height,contentType);

@override
String toString() {
  return 'ImageDetails(link: $link, width: $width, height: $height, contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class $ImageDetailsCopyWith<$Res>  {
  factory $ImageDetailsCopyWith(ImageDetails value, $Res Function(ImageDetails) _then) = _$ImageDetailsCopyWithImpl;
@useResult
$Res call({
 String link,@JsonKey(fromJson: _toInt) int width,@JsonKey(fromJson: _toInt) int height,@JsonKey(name: 'content_type') String contentType
});




}
/// @nodoc
class _$ImageDetailsCopyWithImpl<$Res>
    implements $ImageDetailsCopyWith<$Res> {
  _$ImageDetailsCopyWithImpl(this._self, this._then);

  final ImageDetails _self;
  final $Res Function(ImageDetails) _then;

/// Create a copy of ImageDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? link = null,Object? width = null,Object? height = null,Object? contentType = null,}) {
  return _then(_self.copyWith(
link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ImageDetails].
extension ImageDetailsPatterns on ImageDetails {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageDetails() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageDetails value)  $default,){
final _that = this;
switch (_that) {
case _ImageDetails():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageDetails value)?  $default,){
final _that = this;
switch (_that) {
case _ImageDetails() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String link, @JsonKey(fromJson: _toInt)  int width, @JsonKey(fromJson: _toInt)  int height, @JsonKey(name: 'content_type')  String contentType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageDetails() when $default != null:
return $default(_that.link,_that.width,_that.height,_that.contentType);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String link, @JsonKey(fromJson: _toInt)  int width, @JsonKey(fromJson: _toInt)  int height, @JsonKey(name: 'content_type')  String contentType)  $default,) {final _that = this;
switch (_that) {
case _ImageDetails():
return $default(_that.link,_that.width,_that.height,_that.contentType);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String link, @JsonKey(fromJson: _toInt)  int width, @JsonKey(fromJson: _toInt)  int height, @JsonKey(name: 'content_type')  String contentType)?  $default,) {final _that = this;
switch (_that) {
case _ImageDetails() when $default != null:
return $default(_that.link,_that.width,_that.height,_that.contentType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _ImageDetails extends ImageDetails {
  const _ImageDetails({this.link = '', @JsonKey(fromJson: _toInt) this.width = 0, @JsonKey(fromJson: _toInt) this.height = 0, @JsonKey(name: 'content_type') this.contentType = ''}): super._();
  factory _ImageDetails.fromJson(Map<String, dynamic> json) => _$ImageDetailsFromJson(json);

@override@JsonKey() final  String link;
@override@JsonKey(fromJson: _toInt) final  int width;
@override@JsonKey(fromJson: _toInt) final  int height;
@override@JsonKey(name: 'content_type') final  String contentType;

/// Create a copy of ImageDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageDetailsCopyWith<_ImageDetails> get copyWith => __$ImageDetailsCopyWithImpl<_ImageDetails>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageDetails&&(identical(other.link, link) || other.link == link)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.contentType, contentType) || other.contentType == contentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,link,width,height,contentType);

@override
String toString() {
  return 'ImageDetails(link: $link, width: $width, height: $height, contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class _$ImageDetailsCopyWith<$Res> implements $ImageDetailsCopyWith<$Res> {
  factory _$ImageDetailsCopyWith(_ImageDetails value, $Res Function(_ImageDetails) _then) = __$ImageDetailsCopyWithImpl;
@override @useResult
$Res call({
 String link,@JsonKey(fromJson: _toInt) int width,@JsonKey(fromJson: _toInt) int height,@JsonKey(name: 'content_type') String contentType
});




}
/// @nodoc
class __$ImageDetailsCopyWithImpl<$Res>
    implements _$ImageDetailsCopyWith<$Res> {
  __$ImageDetailsCopyWithImpl(this._self, this._then);

  final _ImageDetails _self;
  final $Res Function(_ImageDetails) _then;

/// Create a copy of ImageDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? link = null,Object? width = null,Object? height = null,Object? contentType = null,}) {
  return _then(_ImageDetails(
link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PostAggregates {

@JsonKey(name: 'post_id', fromJson: _toInt) int get postId;@JsonKey(fromJson: _toInt) int get comments;@JsonKey(fromJson: _toInt) int get score;@JsonKey(fromJson: _toInt) int get upvotes;@JsonKey(fromJson: _toInt) int get downvotes; String get published;@JsonKey(name: 'newest_comment_time') String get newestCommentTime;
/// Create a copy of PostAggregates
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostAggregatesCopyWith<PostAggregates> get copyWith => _$PostAggregatesCopyWithImpl<PostAggregates>(this as PostAggregates, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostAggregates&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.score, score) || other.score == score)&&(identical(other.upvotes, upvotes) || other.upvotes == upvotes)&&(identical(other.downvotes, downvotes) || other.downvotes == downvotes)&&(identical(other.published, published) || other.published == published)&&(identical(other.newestCommentTime, newestCommentTime) || other.newestCommentTime == newestCommentTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postId,comments,score,upvotes,downvotes,published,newestCommentTime);

@override
String toString() {
  return 'PostAggregates(postId: $postId, comments: $comments, score: $score, upvotes: $upvotes, downvotes: $downvotes, published: $published, newestCommentTime: $newestCommentTime)';
}


}

/// @nodoc
abstract mixin class $PostAggregatesCopyWith<$Res>  {
  factory $PostAggregatesCopyWith(PostAggregates value, $Res Function(PostAggregates) _then) = _$PostAggregatesCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'post_id', fromJson: _toInt) int postId,@JsonKey(fromJson: _toInt) int comments,@JsonKey(fromJson: _toInt) int score,@JsonKey(fromJson: _toInt) int upvotes,@JsonKey(fromJson: _toInt) int downvotes, String published,@JsonKey(name: 'newest_comment_time') String newestCommentTime
});




}
/// @nodoc
class _$PostAggregatesCopyWithImpl<$Res>
    implements $PostAggregatesCopyWith<$Res> {
  _$PostAggregatesCopyWithImpl(this._self, this._then);

  final PostAggregates _self;
  final $Res Function(PostAggregates) _then;

/// Create a copy of PostAggregates
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? postId = null,Object? comments = null,Object? score = null,Object? upvotes = null,Object? downvotes = null,Object? published = null,Object? newestCommentTime = null,}) {
  return _then(_self.copyWith(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as int,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,upvotes: null == upvotes ? _self.upvotes : upvotes // ignore: cast_nullable_to_non_nullable
as int,downvotes: null == downvotes ? _self.downvotes : downvotes // ignore: cast_nullable_to_non_nullable
as int,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,newestCommentTime: null == newestCommentTime ? _self.newestCommentTime : newestCommentTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PostAggregates].
extension PostAggregatesPatterns on PostAggregates {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostAggregates value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostAggregates() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostAggregates value)  $default,){
final _that = this;
switch (_that) {
case _PostAggregates():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostAggregates value)?  $default,){
final _that = this;
switch (_that) {
case _PostAggregates() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'post_id', fromJson: _toInt)  int postId, @JsonKey(fromJson: _toInt)  int comments, @JsonKey(fromJson: _toInt)  int score, @JsonKey(fromJson: _toInt)  int upvotes, @JsonKey(fromJson: _toInt)  int downvotes,  String published, @JsonKey(name: 'newest_comment_time')  String newestCommentTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostAggregates() when $default != null:
return $default(_that.postId,_that.comments,_that.score,_that.upvotes,_that.downvotes,_that.published,_that.newestCommentTime);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'post_id', fromJson: _toInt)  int postId, @JsonKey(fromJson: _toInt)  int comments, @JsonKey(fromJson: _toInt)  int score, @JsonKey(fromJson: _toInt)  int upvotes, @JsonKey(fromJson: _toInt)  int downvotes,  String published, @JsonKey(name: 'newest_comment_time')  String newestCommentTime)  $default,) {final _that = this;
switch (_that) {
case _PostAggregates():
return $default(_that.postId,_that.comments,_that.score,_that.upvotes,_that.downvotes,_that.published,_that.newestCommentTime);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'post_id', fromJson: _toInt)  int postId, @JsonKey(fromJson: _toInt)  int comments, @JsonKey(fromJson: _toInt)  int score, @JsonKey(fromJson: _toInt)  int upvotes, @JsonKey(fromJson: _toInt)  int downvotes,  String published, @JsonKey(name: 'newest_comment_time')  String newestCommentTime)?  $default,) {final _that = this;
switch (_that) {
case _PostAggregates() when $default != null:
return $default(_that.postId,_that.comments,_that.score,_that.upvotes,_that.downvotes,_that.published,_that.newestCommentTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _PostAggregates implements PostAggregates {
  const _PostAggregates({@JsonKey(name: 'post_id', fromJson: _toInt) this.postId = 0, @JsonKey(fromJson: _toInt) this.comments = 0, @JsonKey(fromJson: _toInt) this.score = 0, @JsonKey(fromJson: _toInt) this.upvotes = 0, @JsonKey(fromJson: _toInt) this.downvotes = 0, this.published = '', @JsonKey(name: 'newest_comment_time') this.newestCommentTime = ''});
  factory _PostAggregates.fromJson(Map<String, dynamic> json) => _$PostAggregatesFromJson(json);

@override@JsonKey(name: 'post_id', fromJson: _toInt) final  int postId;
@override@JsonKey(fromJson: _toInt) final  int comments;
@override@JsonKey(fromJson: _toInt) final  int score;
@override@JsonKey(fromJson: _toInt) final  int upvotes;
@override@JsonKey(fromJson: _toInt) final  int downvotes;
@override@JsonKey() final  String published;
@override@JsonKey(name: 'newest_comment_time') final  String newestCommentTime;

/// Create a copy of PostAggregates
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostAggregatesCopyWith<_PostAggregates> get copyWith => __$PostAggregatesCopyWithImpl<_PostAggregates>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostAggregates&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.score, score) || other.score == score)&&(identical(other.upvotes, upvotes) || other.upvotes == upvotes)&&(identical(other.downvotes, downvotes) || other.downvotes == downvotes)&&(identical(other.published, published) || other.published == published)&&(identical(other.newestCommentTime, newestCommentTime) || other.newestCommentTime == newestCommentTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postId,comments,score,upvotes,downvotes,published,newestCommentTime);

@override
String toString() {
  return 'PostAggregates(postId: $postId, comments: $comments, score: $score, upvotes: $upvotes, downvotes: $downvotes, published: $published, newestCommentTime: $newestCommentTime)';
}


}

/// @nodoc
abstract mixin class _$PostAggregatesCopyWith<$Res> implements $PostAggregatesCopyWith<$Res> {
  factory _$PostAggregatesCopyWith(_PostAggregates value, $Res Function(_PostAggregates) _then) = __$PostAggregatesCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'post_id', fromJson: _toInt) int postId,@JsonKey(fromJson: _toInt) int comments,@JsonKey(fromJson: _toInt) int score,@JsonKey(fromJson: _toInt) int upvotes,@JsonKey(fromJson: _toInt) int downvotes, String published,@JsonKey(name: 'newest_comment_time') String newestCommentTime
});




}
/// @nodoc
class __$PostAggregatesCopyWithImpl<$Res>
    implements _$PostAggregatesCopyWith<$Res> {
  __$PostAggregatesCopyWithImpl(this._self, this._then);

  final _PostAggregates _self;
  final $Res Function(_PostAggregates) _then;

/// Create a copy of PostAggregates
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? postId = null,Object? comments = null,Object? score = null,Object? upvotes = null,Object? downvotes = null,Object? published = null,Object? newestCommentTime = null,}) {
  return _then(_PostAggregates(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as int,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,upvotes: null == upvotes ? _self.upvotes : upvotes // ignore: cast_nullable_to_non_nullable
as int,downvotes: null == downvotes ? _self.downvotes : downvotes // ignore: cast_nullable_to_non_nullable
as int,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,newestCommentTime: null == newestCommentTime ? _self.newestCommentTime : newestCommentTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Person {

@JsonKey(fromJson: _toInt) int get id; String get name;@JsonKey(name: 'display_name') String? get displayName; String? get avatar; bool get banned; String get published; String? get updated;@JsonKey(name: 'actor_id') String get actorId; String? get bio; bool get local; String? get banner; bool get deleted;@JsonKey(name: 'matrix_user_id') String? get matrixUserId;@JsonKey(name: 'bot_account') bool get botAccount;@JsonKey(name: 'ban_expires') String? get banExpires;@JsonKey(name: 'instance_id', fromJson: _toInt) int get instanceId;
/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonCopyWith<Person> get copyWith => _$PersonCopyWithImpl<Person>(this as Person, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Person&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.banned, banned) || other.banned == banned)&&(identical(other.published, published) || other.published == published)&&(identical(other.updated, updated) || other.updated == updated)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.local, local) || other.local == local)&&(identical(other.banner, banner) || other.banner == banner)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.matrixUserId, matrixUserId) || other.matrixUserId == matrixUserId)&&(identical(other.botAccount, botAccount) || other.botAccount == botAccount)&&(identical(other.banExpires, banExpires) || other.banExpires == banExpires)&&(identical(other.instanceId, instanceId) || other.instanceId == instanceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,displayName,avatar,banned,published,updated,actorId,bio,local,banner,deleted,matrixUserId,botAccount,banExpires,instanceId);

@override
String toString() {
  return 'Person(id: $id, name: $name, displayName: $displayName, avatar: $avatar, banned: $banned, published: $published, updated: $updated, actorId: $actorId, bio: $bio, local: $local, banner: $banner, deleted: $deleted, matrixUserId: $matrixUserId, botAccount: $botAccount, banExpires: $banExpires, instanceId: $instanceId)';
}


}

/// @nodoc
abstract mixin class $PersonCopyWith<$Res>  {
  factory $PersonCopyWith(Person value, $Res Function(Person) _then) = _$PersonCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _toInt) int id, String name,@JsonKey(name: 'display_name') String? displayName, String? avatar, bool banned, String published, String? updated,@JsonKey(name: 'actor_id') String actorId, String? bio, bool local, String? banner, bool deleted,@JsonKey(name: 'matrix_user_id') String? matrixUserId,@JsonKey(name: 'bot_account') bool botAccount,@JsonKey(name: 'ban_expires') String? banExpires,@JsonKey(name: 'instance_id', fromJson: _toInt) int instanceId
});




}
/// @nodoc
class _$PersonCopyWithImpl<$Res>
    implements $PersonCopyWith<$Res> {
  _$PersonCopyWithImpl(this._self, this._then);

  final Person _self;
  final $Res Function(Person) _then;

/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? displayName = freezed,Object? avatar = freezed,Object? banned = null,Object? published = null,Object? updated = freezed,Object? actorId = null,Object? bio = freezed,Object? local = null,Object? banner = freezed,Object? deleted = null,Object? matrixUserId = freezed,Object? botAccount = null,Object? banExpires = freezed,Object? instanceId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,banned: null == banned ? _self.banned : banned // ignore: cast_nullable_to_non_nullable
as bool,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,updated: freezed == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as String?,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,local: null == local ? _self.local : local // ignore: cast_nullable_to_non_nullable
as bool,banner: freezed == banner ? _self.banner : banner // ignore: cast_nullable_to_non_nullable
as String?,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,matrixUserId: freezed == matrixUserId ? _self.matrixUserId : matrixUserId // ignore: cast_nullable_to_non_nullable
as String?,botAccount: null == botAccount ? _self.botAccount : botAccount // ignore: cast_nullable_to_non_nullable
as bool,banExpires: freezed == banExpires ? _self.banExpires : banExpires // ignore: cast_nullable_to_non_nullable
as String?,instanceId: null == instanceId ? _self.instanceId : instanceId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Person].
extension PersonPatterns on Person {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Person value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Person() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Person value)  $default,){
final _that = this;
switch (_that) {
case _Person():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Person value)?  $default,){
final _that = this;
switch (_that) {
case _Person() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int id,  String name, @JsonKey(name: 'display_name')  String? displayName,  String? avatar,  bool banned,  String published,  String? updated, @JsonKey(name: 'actor_id')  String actorId,  String? bio,  bool local,  String? banner,  bool deleted, @JsonKey(name: 'matrix_user_id')  String? matrixUserId, @JsonKey(name: 'bot_account')  bool botAccount, @JsonKey(name: 'ban_expires')  String? banExpires, @JsonKey(name: 'instance_id', fromJson: _toInt)  int instanceId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Person() when $default != null:
return $default(_that.id,_that.name,_that.displayName,_that.avatar,_that.banned,_that.published,_that.updated,_that.actorId,_that.bio,_that.local,_that.banner,_that.deleted,_that.matrixUserId,_that.botAccount,_that.banExpires,_that.instanceId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int id,  String name, @JsonKey(name: 'display_name')  String? displayName,  String? avatar,  bool banned,  String published,  String? updated, @JsonKey(name: 'actor_id')  String actorId,  String? bio,  bool local,  String? banner,  bool deleted, @JsonKey(name: 'matrix_user_id')  String? matrixUserId, @JsonKey(name: 'bot_account')  bool botAccount, @JsonKey(name: 'ban_expires')  String? banExpires, @JsonKey(name: 'instance_id', fromJson: _toInt)  int instanceId)  $default,) {final _that = this;
switch (_that) {
case _Person():
return $default(_that.id,_that.name,_that.displayName,_that.avatar,_that.banned,_that.published,_that.updated,_that.actorId,_that.bio,_that.local,_that.banner,_that.deleted,_that.matrixUserId,_that.botAccount,_that.banExpires,_that.instanceId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _toInt)  int id,  String name, @JsonKey(name: 'display_name')  String? displayName,  String? avatar,  bool banned,  String published,  String? updated, @JsonKey(name: 'actor_id')  String actorId,  String? bio,  bool local,  String? banner,  bool deleted, @JsonKey(name: 'matrix_user_id')  String? matrixUserId, @JsonKey(name: 'bot_account')  bool botAccount, @JsonKey(name: 'ban_expires')  String? banExpires, @JsonKey(name: 'instance_id', fromJson: _toInt)  int instanceId)?  $default,) {final _that = this;
switch (_that) {
case _Person() when $default != null:
return $default(_that.id,_that.name,_that.displayName,_that.avatar,_that.banned,_that.published,_that.updated,_that.actorId,_that.bio,_that.local,_that.banner,_that.deleted,_that.matrixUserId,_that.botAccount,_that.banExpires,_that.instanceId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _Person extends Person {
  const _Person({@JsonKey(fromJson: _toInt) this.id = 0, this.name = '', @JsonKey(name: 'display_name') this.displayName, this.avatar, this.banned = false, this.published = '', this.updated, @JsonKey(name: 'actor_id') this.actorId = '', this.bio, this.local = true, this.banner, this.deleted = false, @JsonKey(name: 'matrix_user_id') this.matrixUserId, @JsonKey(name: 'bot_account') this.botAccount = false, @JsonKey(name: 'ban_expires') this.banExpires, @JsonKey(name: 'instance_id', fromJson: _toInt) this.instanceId = 0}): super._();
  factory _Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

@override@JsonKey(fromJson: _toInt) final  int id;
@override@JsonKey() final  String name;
@override@JsonKey(name: 'display_name') final  String? displayName;
@override final  String? avatar;
@override@JsonKey() final  bool banned;
@override@JsonKey() final  String published;
@override final  String? updated;
@override@JsonKey(name: 'actor_id') final  String actorId;
@override final  String? bio;
@override@JsonKey() final  bool local;
@override final  String? banner;
@override@JsonKey() final  bool deleted;
@override@JsonKey(name: 'matrix_user_id') final  String? matrixUserId;
@override@JsonKey(name: 'bot_account') final  bool botAccount;
@override@JsonKey(name: 'ban_expires') final  String? banExpires;
@override@JsonKey(name: 'instance_id', fromJson: _toInt) final  int instanceId;

/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonCopyWith<_Person> get copyWith => __$PersonCopyWithImpl<_Person>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Person&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.banned, banned) || other.banned == banned)&&(identical(other.published, published) || other.published == published)&&(identical(other.updated, updated) || other.updated == updated)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.local, local) || other.local == local)&&(identical(other.banner, banner) || other.banner == banner)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.matrixUserId, matrixUserId) || other.matrixUserId == matrixUserId)&&(identical(other.botAccount, botAccount) || other.botAccount == botAccount)&&(identical(other.banExpires, banExpires) || other.banExpires == banExpires)&&(identical(other.instanceId, instanceId) || other.instanceId == instanceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,displayName,avatar,banned,published,updated,actorId,bio,local,banner,deleted,matrixUserId,botAccount,banExpires,instanceId);

@override
String toString() {
  return 'Person(id: $id, name: $name, displayName: $displayName, avatar: $avatar, banned: $banned, published: $published, updated: $updated, actorId: $actorId, bio: $bio, local: $local, banner: $banner, deleted: $deleted, matrixUserId: $matrixUserId, botAccount: $botAccount, banExpires: $banExpires, instanceId: $instanceId)';
}


}

/// @nodoc
abstract mixin class _$PersonCopyWith<$Res> implements $PersonCopyWith<$Res> {
  factory _$PersonCopyWith(_Person value, $Res Function(_Person) _then) = __$PersonCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _toInt) int id, String name,@JsonKey(name: 'display_name') String? displayName, String? avatar, bool banned, String published, String? updated,@JsonKey(name: 'actor_id') String actorId, String? bio, bool local, String? banner, bool deleted,@JsonKey(name: 'matrix_user_id') String? matrixUserId,@JsonKey(name: 'bot_account') bool botAccount,@JsonKey(name: 'ban_expires') String? banExpires,@JsonKey(name: 'instance_id', fromJson: _toInt) int instanceId
});




}
/// @nodoc
class __$PersonCopyWithImpl<$Res>
    implements _$PersonCopyWith<$Res> {
  __$PersonCopyWithImpl(this._self, this._then);

  final _Person _self;
  final $Res Function(_Person) _then;

/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? displayName = freezed,Object? avatar = freezed,Object? banned = null,Object? published = null,Object? updated = freezed,Object? actorId = null,Object? bio = freezed,Object? local = null,Object? banner = freezed,Object? deleted = null,Object? matrixUserId = freezed,Object? botAccount = null,Object? banExpires = freezed,Object? instanceId = null,}) {
  return _then(_Person(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,banned: null == banned ? _self.banned : banned // ignore: cast_nullable_to_non_nullable
as bool,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,updated: freezed == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as String?,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,local: null == local ? _self.local : local // ignore: cast_nullable_to_non_nullable
as bool,banner: freezed == banner ? _self.banner : banner // ignore: cast_nullable_to_non_nullable
as String?,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,matrixUserId: freezed == matrixUserId ? _self.matrixUserId : matrixUserId // ignore: cast_nullable_to_non_nullable
as String?,botAccount: null == botAccount ? _self.botAccount : botAccount // ignore: cast_nullable_to_non_nullable
as bool,banExpires: freezed == banExpires ? _self.banExpires : banExpires // ignore: cast_nullable_to_non_nullable
as String?,instanceId: null == instanceId ? _self.instanceId : instanceId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Community {

@JsonKey(fromJson: _toInt) int get id; String get name; String get title; String? get description; bool get removed; String get published; String? get updated; bool get deleted; bool get nsfw;@JsonKey(name: 'actor_id') String get actorId; bool get local; String? get icon; String? get banner; bool get hidden;@JsonKey(name: 'posting_restricted_to_mods') bool get postingRestrictedToMods;@JsonKey(name: 'instance_id', fromJson: _toInt) int get instanceId; String? get visibility;
/// Create a copy of Community
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityCopyWith<Community> get copyWith => _$CommunityCopyWithImpl<Community>(this as Community, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Community&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.removed, removed) || other.removed == removed)&&(identical(other.published, published) || other.published == published)&&(identical(other.updated, updated) || other.updated == updated)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.nsfw, nsfw) || other.nsfw == nsfw)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.local, local) || other.local == local)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.banner, banner) || other.banner == banner)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.postingRestrictedToMods, postingRestrictedToMods) || other.postingRestrictedToMods == postingRestrictedToMods)&&(identical(other.instanceId, instanceId) || other.instanceId == instanceId)&&(identical(other.visibility, visibility) || other.visibility == visibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,title,description,removed,published,updated,deleted,nsfw,actorId,local,icon,banner,hidden,postingRestrictedToMods,instanceId,visibility);

@override
String toString() {
  return 'Community(id: $id, name: $name, title: $title, description: $description, removed: $removed, published: $published, updated: $updated, deleted: $deleted, nsfw: $nsfw, actorId: $actorId, local: $local, icon: $icon, banner: $banner, hidden: $hidden, postingRestrictedToMods: $postingRestrictedToMods, instanceId: $instanceId, visibility: $visibility)';
}


}

/// @nodoc
abstract mixin class $CommunityCopyWith<$Res>  {
  factory $CommunityCopyWith(Community value, $Res Function(Community) _then) = _$CommunityCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _toInt) int id, String name, String title, String? description, bool removed, String published, String? updated, bool deleted, bool nsfw,@JsonKey(name: 'actor_id') String actorId, bool local, String? icon, String? banner, bool hidden,@JsonKey(name: 'posting_restricted_to_mods') bool postingRestrictedToMods,@JsonKey(name: 'instance_id', fromJson: _toInt) int instanceId, String? visibility
});




}
/// @nodoc
class _$CommunityCopyWithImpl<$Res>
    implements $CommunityCopyWith<$Res> {
  _$CommunityCopyWithImpl(this._self, this._then);

  final Community _self;
  final $Res Function(Community) _then;

/// Create a copy of Community
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? title = null,Object? description = freezed,Object? removed = null,Object? published = null,Object? updated = freezed,Object? deleted = null,Object? nsfw = null,Object? actorId = null,Object? local = null,Object? icon = freezed,Object? banner = freezed,Object? hidden = null,Object? postingRestrictedToMods = null,Object? instanceId = null,Object? visibility = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,removed: null == removed ? _self.removed : removed // ignore: cast_nullable_to_non_nullable
as bool,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,updated: freezed == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as String?,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,nsfw: null == nsfw ? _self.nsfw : nsfw // ignore: cast_nullable_to_non_nullable
as bool,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,local: null == local ? _self.local : local // ignore: cast_nullable_to_non_nullable
as bool,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,banner: freezed == banner ? _self.banner : banner // ignore: cast_nullable_to_non_nullable
as String?,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,postingRestrictedToMods: null == postingRestrictedToMods ? _self.postingRestrictedToMods : postingRestrictedToMods // ignore: cast_nullable_to_non_nullable
as bool,instanceId: null == instanceId ? _self.instanceId : instanceId // ignore: cast_nullable_to_non_nullable
as int,visibility: freezed == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Community].
extension CommunityPatterns on Community {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Community value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Community() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Community value)  $default,){
final _that = this;
switch (_that) {
case _Community():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Community value)?  $default,){
final _that = this;
switch (_that) {
case _Community() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int id,  String name,  String title,  String? description,  bool removed,  String published,  String? updated,  bool deleted,  bool nsfw, @JsonKey(name: 'actor_id')  String actorId,  bool local,  String? icon,  String? banner,  bool hidden, @JsonKey(name: 'posting_restricted_to_mods')  bool postingRestrictedToMods, @JsonKey(name: 'instance_id', fromJson: _toInt)  int instanceId,  String? visibility)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Community() when $default != null:
return $default(_that.id,_that.name,_that.title,_that.description,_that.removed,_that.published,_that.updated,_that.deleted,_that.nsfw,_that.actorId,_that.local,_that.icon,_that.banner,_that.hidden,_that.postingRestrictedToMods,_that.instanceId,_that.visibility);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int id,  String name,  String title,  String? description,  bool removed,  String published,  String? updated,  bool deleted,  bool nsfw, @JsonKey(name: 'actor_id')  String actorId,  bool local,  String? icon,  String? banner,  bool hidden, @JsonKey(name: 'posting_restricted_to_mods')  bool postingRestrictedToMods, @JsonKey(name: 'instance_id', fromJson: _toInt)  int instanceId,  String? visibility)  $default,) {final _that = this;
switch (_that) {
case _Community():
return $default(_that.id,_that.name,_that.title,_that.description,_that.removed,_that.published,_that.updated,_that.deleted,_that.nsfw,_that.actorId,_that.local,_that.icon,_that.banner,_that.hidden,_that.postingRestrictedToMods,_that.instanceId,_that.visibility);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _toInt)  int id,  String name,  String title,  String? description,  bool removed,  String published,  String? updated,  bool deleted,  bool nsfw, @JsonKey(name: 'actor_id')  String actorId,  bool local,  String? icon,  String? banner,  bool hidden, @JsonKey(name: 'posting_restricted_to_mods')  bool postingRestrictedToMods, @JsonKey(name: 'instance_id', fromJson: _toInt)  int instanceId,  String? visibility)?  $default,) {final _that = this;
switch (_that) {
case _Community() when $default != null:
return $default(_that.id,_that.name,_that.title,_that.description,_that.removed,_that.published,_that.updated,_that.deleted,_that.nsfw,_that.actorId,_that.local,_that.icon,_that.banner,_that.hidden,_that.postingRestrictedToMods,_that.instanceId,_that.visibility);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _Community implements Community {
  const _Community({@JsonKey(fromJson: _toInt) this.id = 0, this.name = '', this.title = '', this.description, this.removed = false, this.published = '', this.updated, this.deleted = false, this.nsfw = false, @JsonKey(name: 'actor_id') this.actorId = '', this.local = true, this.icon, this.banner, this.hidden = false, @JsonKey(name: 'posting_restricted_to_mods') this.postingRestrictedToMods = false, @JsonKey(name: 'instance_id', fromJson: _toInt) this.instanceId = 0, this.visibility});
  factory _Community.fromJson(Map<String, dynamic> json) => _$CommunityFromJson(json);

@override@JsonKey(fromJson: _toInt) final  int id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String title;
@override final  String? description;
@override@JsonKey() final  bool removed;
@override@JsonKey() final  String published;
@override final  String? updated;
@override@JsonKey() final  bool deleted;
@override@JsonKey() final  bool nsfw;
@override@JsonKey(name: 'actor_id') final  String actorId;
@override@JsonKey() final  bool local;
@override final  String? icon;
@override final  String? banner;
@override@JsonKey() final  bool hidden;
@override@JsonKey(name: 'posting_restricted_to_mods') final  bool postingRestrictedToMods;
@override@JsonKey(name: 'instance_id', fromJson: _toInt) final  int instanceId;
@override final  String? visibility;

/// Create a copy of Community
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityCopyWith<_Community> get copyWith => __$CommunityCopyWithImpl<_Community>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Community&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.removed, removed) || other.removed == removed)&&(identical(other.published, published) || other.published == published)&&(identical(other.updated, updated) || other.updated == updated)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.nsfw, nsfw) || other.nsfw == nsfw)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.local, local) || other.local == local)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.banner, banner) || other.banner == banner)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.postingRestrictedToMods, postingRestrictedToMods) || other.postingRestrictedToMods == postingRestrictedToMods)&&(identical(other.instanceId, instanceId) || other.instanceId == instanceId)&&(identical(other.visibility, visibility) || other.visibility == visibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,title,description,removed,published,updated,deleted,nsfw,actorId,local,icon,banner,hidden,postingRestrictedToMods,instanceId,visibility);

@override
String toString() {
  return 'Community(id: $id, name: $name, title: $title, description: $description, removed: $removed, published: $published, updated: $updated, deleted: $deleted, nsfw: $nsfw, actorId: $actorId, local: $local, icon: $icon, banner: $banner, hidden: $hidden, postingRestrictedToMods: $postingRestrictedToMods, instanceId: $instanceId, visibility: $visibility)';
}


}

/// @nodoc
abstract mixin class _$CommunityCopyWith<$Res> implements $CommunityCopyWith<$Res> {
  factory _$CommunityCopyWith(_Community value, $Res Function(_Community) _then) = __$CommunityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _toInt) int id, String name, String title, String? description, bool removed, String published, String? updated, bool deleted, bool nsfw,@JsonKey(name: 'actor_id') String actorId, bool local, String? icon, String? banner, bool hidden,@JsonKey(name: 'posting_restricted_to_mods') bool postingRestrictedToMods,@JsonKey(name: 'instance_id', fromJson: _toInt) int instanceId, String? visibility
});




}
/// @nodoc
class __$CommunityCopyWithImpl<$Res>
    implements _$CommunityCopyWith<$Res> {
  __$CommunityCopyWithImpl(this._self, this._then);

  final _Community _self;
  final $Res Function(_Community) _then;

/// Create a copy of Community
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? title = null,Object? description = freezed,Object? removed = null,Object? published = null,Object? updated = freezed,Object? deleted = null,Object? nsfw = null,Object? actorId = null,Object? local = null,Object? icon = freezed,Object? banner = freezed,Object? hidden = null,Object? postingRestrictedToMods = null,Object? instanceId = null,Object? visibility = freezed,}) {
  return _then(_Community(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,removed: null == removed ? _self.removed : removed // ignore: cast_nullable_to_non_nullable
as bool,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,updated: freezed == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as String?,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,nsfw: null == nsfw ? _self.nsfw : nsfw // ignore: cast_nullable_to_non_nullable
as bool,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,local: null == local ? _self.local : local // ignore: cast_nullable_to_non_nullable
as bool,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,banner: freezed == banner ? _self.banner : banner // ignore: cast_nullable_to_non_nullable
as String?,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,postingRestrictedToMods: null == postingRestrictedToMods ? _self.postingRestrictedToMods : postingRestrictedToMods // ignore: cast_nullable_to_non_nullable
as bool,instanceId: null == instanceId ? _self.instanceId : instanceId // ignore: cast_nullable_to_non_nullable
as int,visibility: freezed == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PostView {

 Post get post; Person get creator; Community get community; PostAggregates get counts;@JsonKey(name: 'image_details') ImageDetails? get imageDetails; String get subscribed; bool get saved; bool get read; bool get hidden;@JsonKey(name: 'creator_blocked') bool get creatorBlocked;@JsonKey(name: 'my_vote', fromJson: _toNullableInt) int? get myVote;@JsonKey(name: 'unread_comments', fromJson: _toInt) int get unreadComments;@JsonKey(name: 'creator_banned_from_community') bool get creatorBannedFromCommunity;@JsonKey(name: 'banned_from_community') bool get bannedFromCommunity;@JsonKey(name: 'creator_is_moderator') bool get creatorIsModerator;@JsonKey(name: 'creator_is_admin') bool get creatorIsAdmin;
/// Create a copy of PostView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostViewCopyWith<PostView> get copyWith => _$PostViewCopyWithImpl<PostView>(this as PostView, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostView&&(identical(other.post, post) || other.post == post)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.community, community) || other.community == community)&&(identical(other.counts, counts) || other.counts == counts)&&(identical(other.imageDetails, imageDetails) || other.imageDetails == imageDetails)&&(identical(other.subscribed, subscribed) || other.subscribed == subscribed)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.read, read) || other.read == read)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.creatorBlocked, creatorBlocked) || other.creatorBlocked == creatorBlocked)&&(identical(other.myVote, myVote) || other.myVote == myVote)&&(identical(other.unreadComments, unreadComments) || other.unreadComments == unreadComments)&&(identical(other.creatorBannedFromCommunity, creatorBannedFromCommunity) || other.creatorBannedFromCommunity == creatorBannedFromCommunity)&&(identical(other.bannedFromCommunity, bannedFromCommunity) || other.bannedFromCommunity == bannedFromCommunity)&&(identical(other.creatorIsModerator, creatorIsModerator) || other.creatorIsModerator == creatorIsModerator)&&(identical(other.creatorIsAdmin, creatorIsAdmin) || other.creatorIsAdmin == creatorIsAdmin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,post,creator,community,counts,imageDetails,subscribed,saved,read,hidden,creatorBlocked,myVote,unreadComments,creatorBannedFromCommunity,bannedFromCommunity,creatorIsModerator,creatorIsAdmin);

@override
String toString() {
  return 'PostView(post: $post, creator: $creator, community: $community, counts: $counts, imageDetails: $imageDetails, subscribed: $subscribed, saved: $saved, read: $read, hidden: $hidden, creatorBlocked: $creatorBlocked, myVote: $myVote, unreadComments: $unreadComments, creatorBannedFromCommunity: $creatorBannedFromCommunity, bannedFromCommunity: $bannedFromCommunity, creatorIsModerator: $creatorIsModerator, creatorIsAdmin: $creatorIsAdmin)';
}


}

/// @nodoc
abstract mixin class $PostViewCopyWith<$Res>  {
  factory $PostViewCopyWith(PostView value, $Res Function(PostView) _then) = _$PostViewCopyWithImpl;
@useResult
$Res call({
 Post post, Person creator, Community community, PostAggregates counts,@JsonKey(name: 'image_details') ImageDetails? imageDetails, String subscribed, bool saved, bool read, bool hidden,@JsonKey(name: 'creator_blocked') bool creatorBlocked,@JsonKey(name: 'my_vote', fromJson: _toNullableInt) int? myVote,@JsonKey(name: 'unread_comments', fromJson: _toInt) int unreadComments,@JsonKey(name: 'creator_banned_from_community') bool creatorBannedFromCommunity,@JsonKey(name: 'banned_from_community') bool bannedFromCommunity,@JsonKey(name: 'creator_is_moderator') bool creatorIsModerator,@JsonKey(name: 'creator_is_admin') bool creatorIsAdmin
});


$PostCopyWith<$Res> get post;$PersonCopyWith<$Res> get creator;$CommunityCopyWith<$Res> get community;$PostAggregatesCopyWith<$Res> get counts;$ImageDetailsCopyWith<$Res>? get imageDetails;

}
/// @nodoc
class _$PostViewCopyWithImpl<$Res>
    implements $PostViewCopyWith<$Res> {
  _$PostViewCopyWithImpl(this._self, this._then);

  final PostView _self;
  final $Res Function(PostView) _then;

/// Create a copy of PostView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? post = null,Object? creator = null,Object? community = null,Object? counts = null,Object? imageDetails = freezed,Object? subscribed = null,Object? saved = null,Object? read = null,Object? hidden = null,Object? creatorBlocked = null,Object? myVote = freezed,Object? unreadComments = null,Object? creatorBannedFromCommunity = null,Object? bannedFromCommunity = null,Object? creatorIsModerator = null,Object? creatorIsAdmin = null,}) {
  return _then(_self.copyWith(
post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as Post,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as Person,community: null == community ? _self.community : community // ignore: cast_nullable_to_non_nullable
as Community,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as PostAggregates,imageDetails: freezed == imageDetails ? _self.imageDetails : imageDetails // ignore: cast_nullable_to_non_nullable
as ImageDetails?,subscribed: null == subscribed ? _self.subscribed : subscribed // ignore: cast_nullable_to_non_nullable
as String,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,creatorBlocked: null == creatorBlocked ? _self.creatorBlocked : creatorBlocked // ignore: cast_nullable_to_non_nullable
as bool,myVote: freezed == myVote ? _self.myVote : myVote // ignore: cast_nullable_to_non_nullable
as int?,unreadComments: null == unreadComments ? _self.unreadComments : unreadComments // ignore: cast_nullable_to_non_nullable
as int,creatorBannedFromCommunity: null == creatorBannedFromCommunity ? _self.creatorBannedFromCommunity : creatorBannedFromCommunity // ignore: cast_nullable_to_non_nullable
as bool,bannedFromCommunity: null == bannedFromCommunity ? _self.bannedFromCommunity : bannedFromCommunity // ignore: cast_nullable_to_non_nullable
as bool,creatorIsModerator: null == creatorIsModerator ? _self.creatorIsModerator : creatorIsModerator // ignore: cast_nullable_to_non_nullable
as bool,creatorIsAdmin: null == creatorIsAdmin ? _self.creatorIsAdmin : creatorIsAdmin // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of PostView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCopyWith<$Res> get post {
  
  return $PostCopyWith<$Res>(_self.post, (value) {
    return _then(_self.copyWith(post: value));
  });
}/// Create a copy of PostView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get creator {
  
  return $PersonCopyWith<$Res>(_self.creator, (value) {
    return _then(_self.copyWith(creator: value));
  });
}/// Create a copy of PostView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommunityCopyWith<$Res> get community {
  
  return $CommunityCopyWith<$Res>(_self.community, (value) {
    return _then(_self.copyWith(community: value));
  });
}/// Create a copy of PostView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostAggregatesCopyWith<$Res> get counts {
  
  return $PostAggregatesCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}/// Create a copy of PostView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageDetailsCopyWith<$Res>? get imageDetails {
    if (_self.imageDetails == null) {
    return null;
  }

  return $ImageDetailsCopyWith<$Res>(_self.imageDetails!, (value) {
    return _then(_self.copyWith(imageDetails: value));
  });
}
}


/// Adds pattern-matching-related methods to [PostView].
extension PostViewPatterns on PostView {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostView() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostView value)  $default,){
final _that = this;
switch (_that) {
case _PostView():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostView value)?  $default,){
final _that = this;
switch (_that) {
case _PostView() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Post post,  Person creator,  Community community,  PostAggregates counts, @JsonKey(name: 'image_details')  ImageDetails? imageDetails,  String subscribed,  bool saved,  bool read,  bool hidden, @JsonKey(name: 'creator_blocked')  bool creatorBlocked, @JsonKey(name: 'my_vote', fromJson: _toNullableInt)  int? myVote, @JsonKey(name: 'unread_comments', fromJson: _toInt)  int unreadComments, @JsonKey(name: 'creator_banned_from_community')  bool creatorBannedFromCommunity, @JsonKey(name: 'banned_from_community')  bool bannedFromCommunity, @JsonKey(name: 'creator_is_moderator')  bool creatorIsModerator, @JsonKey(name: 'creator_is_admin')  bool creatorIsAdmin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostView() when $default != null:
return $default(_that.post,_that.creator,_that.community,_that.counts,_that.imageDetails,_that.subscribed,_that.saved,_that.read,_that.hidden,_that.creatorBlocked,_that.myVote,_that.unreadComments,_that.creatorBannedFromCommunity,_that.bannedFromCommunity,_that.creatorIsModerator,_that.creatorIsAdmin);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Post post,  Person creator,  Community community,  PostAggregates counts, @JsonKey(name: 'image_details')  ImageDetails? imageDetails,  String subscribed,  bool saved,  bool read,  bool hidden, @JsonKey(name: 'creator_blocked')  bool creatorBlocked, @JsonKey(name: 'my_vote', fromJson: _toNullableInt)  int? myVote, @JsonKey(name: 'unread_comments', fromJson: _toInt)  int unreadComments, @JsonKey(name: 'creator_banned_from_community')  bool creatorBannedFromCommunity, @JsonKey(name: 'banned_from_community')  bool bannedFromCommunity, @JsonKey(name: 'creator_is_moderator')  bool creatorIsModerator, @JsonKey(name: 'creator_is_admin')  bool creatorIsAdmin)  $default,) {final _that = this;
switch (_that) {
case _PostView():
return $default(_that.post,_that.creator,_that.community,_that.counts,_that.imageDetails,_that.subscribed,_that.saved,_that.read,_that.hidden,_that.creatorBlocked,_that.myVote,_that.unreadComments,_that.creatorBannedFromCommunity,_that.bannedFromCommunity,_that.creatorIsModerator,_that.creatorIsAdmin);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Post post,  Person creator,  Community community,  PostAggregates counts, @JsonKey(name: 'image_details')  ImageDetails? imageDetails,  String subscribed,  bool saved,  bool read,  bool hidden, @JsonKey(name: 'creator_blocked')  bool creatorBlocked, @JsonKey(name: 'my_vote', fromJson: _toNullableInt)  int? myVote, @JsonKey(name: 'unread_comments', fromJson: _toInt)  int unreadComments, @JsonKey(name: 'creator_banned_from_community')  bool creatorBannedFromCommunity, @JsonKey(name: 'banned_from_community')  bool bannedFromCommunity, @JsonKey(name: 'creator_is_moderator')  bool creatorIsModerator, @JsonKey(name: 'creator_is_admin')  bool creatorIsAdmin)?  $default,) {final _that = this;
switch (_that) {
case _PostView() when $default != null:
return $default(_that.post,_that.creator,_that.community,_that.counts,_that.imageDetails,_that.subscribed,_that.saved,_that.read,_that.hidden,_that.creatorBlocked,_that.myVote,_that.unreadComments,_that.creatorBannedFromCommunity,_that.bannedFromCommunity,_that.creatorIsModerator,_that.creatorIsAdmin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _PostView implements PostView {
  const _PostView({required this.post, required this.creator, required this.community, required this.counts, @JsonKey(name: 'image_details') this.imageDetails, this.subscribed = 'NotSubscribed', this.saved = false, this.read = false, this.hidden = false, @JsonKey(name: 'creator_blocked') this.creatorBlocked = false, @JsonKey(name: 'my_vote', fromJson: _toNullableInt) this.myVote, @JsonKey(name: 'unread_comments', fromJson: _toInt) this.unreadComments = 0, @JsonKey(name: 'creator_banned_from_community') this.creatorBannedFromCommunity = false, @JsonKey(name: 'banned_from_community') this.bannedFromCommunity = false, @JsonKey(name: 'creator_is_moderator') this.creatorIsModerator = false, @JsonKey(name: 'creator_is_admin') this.creatorIsAdmin = false});
  factory _PostView.fromJson(Map<String, dynamic> json) => _$PostViewFromJson(json);

@override final  Post post;
@override final  Person creator;
@override final  Community community;
@override final  PostAggregates counts;
@override@JsonKey(name: 'image_details') final  ImageDetails? imageDetails;
@override@JsonKey() final  String subscribed;
@override@JsonKey() final  bool saved;
@override@JsonKey() final  bool read;
@override@JsonKey() final  bool hidden;
@override@JsonKey(name: 'creator_blocked') final  bool creatorBlocked;
@override@JsonKey(name: 'my_vote', fromJson: _toNullableInt) final  int? myVote;
@override@JsonKey(name: 'unread_comments', fromJson: _toInt) final  int unreadComments;
@override@JsonKey(name: 'creator_banned_from_community') final  bool creatorBannedFromCommunity;
@override@JsonKey(name: 'banned_from_community') final  bool bannedFromCommunity;
@override@JsonKey(name: 'creator_is_moderator') final  bool creatorIsModerator;
@override@JsonKey(name: 'creator_is_admin') final  bool creatorIsAdmin;

/// Create a copy of PostView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostViewCopyWith<_PostView> get copyWith => __$PostViewCopyWithImpl<_PostView>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostView&&(identical(other.post, post) || other.post == post)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.community, community) || other.community == community)&&(identical(other.counts, counts) || other.counts == counts)&&(identical(other.imageDetails, imageDetails) || other.imageDetails == imageDetails)&&(identical(other.subscribed, subscribed) || other.subscribed == subscribed)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.read, read) || other.read == read)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.creatorBlocked, creatorBlocked) || other.creatorBlocked == creatorBlocked)&&(identical(other.myVote, myVote) || other.myVote == myVote)&&(identical(other.unreadComments, unreadComments) || other.unreadComments == unreadComments)&&(identical(other.creatorBannedFromCommunity, creatorBannedFromCommunity) || other.creatorBannedFromCommunity == creatorBannedFromCommunity)&&(identical(other.bannedFromCommunity, bannedFromCommunity) || other.bannedFromCommunity == bannedFromCommunity)&&(identical(other.creatorIsModerator, creatorIsModerator) || other.creatorIsModerator == creatorIsModerator)&&(identical(other.creatorIsAdmin, creatorIsAdmin) || other.creatorIsAdmin == creatorIsAdmin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,post,creator,community,counts,imageDetails,subscribed,saved,read,hidden,creatorBlocked,myVote,unreadComments,creatorBannedFromCommunity,bannedFromCommunity,creatorIsModerator,creatorIsAdmin);

@override
String toString() {
  return 'PostView(post: $post, creator: $creator, community: $community, counts: $counts, imageDetails: $imageDetails, subscribed: $subscribed, saved: $saved, read: $read, hidden: $hidden, creatorBlocked: $creatorBlocked, myVote: $myVote, unreadComments: $unreadComments, creatorBannedFromCommunity: $creatorBannedFromCommunity, bannedFromCommunity: $bannedFromCommunity, creatorIsModerator: $creatorIsModerator, creatorIsAdmin: $creatorIsAdmin)';
}


}

/// @nodoc
abstract mixin class _$PostViewCopyWith<$Res> implements $PostViewCopyWith<$Res> {
  factory _$PostViewCopyWith(_PostView value, $Res Function(_PostView) _then) = __$PostViewCopyWithImpl;
@override @useResult
$Res call({
 Post post, Person creator, Community community, PostAggregates counts,@JsonKey(name: 'image_details') ImageDetails? imageDetails, String subscribed, bool saved, bool read, bool hidden,@JsonKey(name: 'creator_blocked') bool creatorBlocked,@JsonKey(name: 'my_vote', fromJson: _toNullableInt) int? myVote,@JsonKey(name: 'unread_comments', fromJson: _toInt) int unreadComments,@JsonKey(name: 'creator_banned_from_community') bool creatorBannedFromCommunity,@JsonKey(name: 'banned_from_community') bool bannedFromCommunity,@JsonKey(name: 'creator_is_moderator') bool creatorIsModerator,@JsonKey(name: 'creator_is_admin') bool creatorIsAdmin
});


@override $PostCopyWith<$Res> get post;@override $PersonCopyWith<$Res> get creator;@override $CommunityCopyWith<$Res> get community;@override $PostAggregatesCopyWith<$Res> get counts;@override $ImageDetailsCopyWith<$Res>? get imageDetails;

}
/// @nodoc
class __$PostViewCopyWithImpl<$Res>
    implements _$PostViewCopyWith<$Res> {
  __$PostViewCopyWithImpl(this._self, this._then);

  final _PostView _self;
  final $Res Function(_PostView) _then;

/// Create a copy of PostView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? post = null,Object? creator = null,Object? community = null,Object? counts = null,Object? imageDetails = freezed,Object? subscribed = null,Object? saved = null,Object? read = null,Object? hidden = null,Object? creatorBlocked = null,Object? myVote = freezed,Object? unreadComments = null,Object? creatorBannedFromCommunity = null,Object? bannedFromCommunity = null,Object? creatorIsModerator = null,Object? creatorIsAdmin = null,}) {
  return _then(_PostView(
post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as Post,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as Person,community: null == community ? _self.community : community // ignore: cast_nullable_to_non_nullable
as Community,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as PostAggregates,imageDetails: freezed == imageDetails ? _self.imageDetails : imageDetails // ignore: cast_nullable_to_non_nullable
as ImageDetails?,subscribed: null == subscribed ? _self.subscribed : subscribed // ignore: cast_nullable_to_non_nullable
as String,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,creatorBlocked: null == creatorBlocked ? _self.creatorBlocked : creatorBlocked // ignore: cast_nullable_to_non_nullable
as bool,myVote: freezed == myVote ? _self.myVote : myVote // ignore: cast_nullable_to_non_nullable
as int?,unreadComments: null == unreadComments ? _self.unreadComments : unreadComments // ignore: cast_nullable_to_non_nullable
as int,creatorBannedFromCommunity: null == creatorBannedFromCommunity ? _self.creatorBannedFromCommunity : creatorBannedFromCommunity // ignore: cast_nullable_to_non_nullable
as bool,bannedFromCommunity: null == bannedFromCommunity ? _self.bannedFromCommunity : bannedFromCommunity // ignore: cast_nullable_to_non_nullable
as bool,creatorIsModerator: null == creatorIsModerator ? _self.creatorIsModerator : creatorIsModerator // ignore: cast_nullable_to_non_nullable
as bool,creatorIsAdmin: null == creatorIsAdmin ? _self.creatorIsAdmin : creatorIsAdmin // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of PostView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCopyWith<$Res> get post {
  
  return $PostCopyWith<$Res>(_self.post, (value) {
    return _then(_self.copyWith(post: value));
  });
}/// Create a copy of PostView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get creator {
  
  return $PersonCopyWith<$Res>(_self.creator, (value) {
    return _then(_self.copyWith(creator: value));
  });
}/// Create a copy of PostView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommunityCopyWith<$Res> get community {
  
  return $CommunityCopyWith<$Res>(_self.community, (value) {
    return _then(_self.copyWith(community: value));
  });
}/// Create a copy of PostView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostAggregatesCopyWith<$Res> get counts {
  
  return $PostAggregatesCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}/// Create a copy of PostView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageDetailsCopyWith<$Res>? get imageDetails {
    if (_self.imageDetails == null) {
    return null;
  }

  return $ImageDetailsCopyWith<$Res>(_self.imageDetails!, (value) {
    return _then(_self.copyWith(imageDetails: value));
  });
}
}


/// @nodoc
mixin _$CommunityAggregates {

@JsonKey(name: 'community_id', fromJson: _toInt) int get communityId;@JsonKey(fromJson: _toInt) int get subscribers;@JsonKey(fromJson: _toInt) int get posts;@JsonKey(fromJson: _toInt) int get comments; String get published;@JsonKey(name: 'users_active_day', fromJson: _toInt) int get usersActiveDay;@JsonKey(name: 'users_active_week', fromJson: _toInt) int get usersActiveWeek;@JsonKey(name: 'users_active_month', fromJson: _toInt) int get usersActiveMonth;@JsonKey(name: 'users_active_half_year', fromJson: _toInt) int get usersActiveHalfYear;@JsonKey(name: 'subscribers_local', fromJson: _toInt) int get subscribersLocal;
/// Create a copy of CommunityAggregates
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityAggregatesCopyWith<CommunityAggregates> get copyWith => _$CommunityAggregatesCopyWithImpl<CommunityAggregates>(this as CommunityAggregates, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunityAggregates&&(identical(other.communityId, communityId) || other.communityId == communityId)&&(identical(other.subscribers, subscribers) || other.subscribers == subscribers)&&(identical(other.posts, posts) || other.posts == posts)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.published, published) || other.published == published)&&(identical(other.usersActiveDay, usersActiveDay) || other.usersActiveDay == usersActiveDay)&&(identical(other.usersActiveWeek, usersActiveWeek) || other.usersActiveWeek == usersActiveWeek)&&(identical(other.usersActiveMonth, usersActiveMonth) || other.usersActiveMonth == usersActiveMonth)&&(identical(other.usersActiveHalfYear, usersActiveHalfYear) || other.usersActiveHalfYear == usersActiveHalfYear)&&(identical(other.subscribersLocal, subscribersLocal) || other.subscribersLocal == subscribersLocal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,communityId,subscribers,posts,comments,published,usersActiveDay,usersActiveWeek,usersActiveMonth,usersActiveHalfYear,subscribersLocal);

@override
String toString() {
  return 'CommunityAggregates(communityId: $communityId, subscribers: $subscribers, posts: $posts, comments: $comments, published: $published, usersActiveDay: $usersActiveDay, usersActiveWeek: $usersActiveWeek, usersActiveMonth: $usersActiveMonth, usersActiveHalfYear: $usersActiveHalfYear, subscribersLocal: $subscribersLocal)';
}


}

/// @nodoc
abstract mixin class $CommunityAggregatesCopyWith<$Res>  {
  factory $CommunityAggregatesCopyWith(CommunityAggregates value, $Res Function(CommunityAggregates) _then) = _$CommunityAggregatesCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'community_id', fromJson: _toInt) int communityId,@JsonKey(fromJson: _toInt) int subscribers,@JsonKey(fromJson: _toInt) int posts,@JsonKey(fromJson: _toInt) int comments, String published,@JsonKey(name: 'users_active_day', fromJson: _toInt) int usersActiveDay,@JsonKey(name: 'users_active_week', fromJson: _toInt) int usersActiveWeek,@JsonKey(name: 'users_active_month', fromJson: _toInt) int usersActiveMonth,@JsonKey(name: 'users_active_half_year', fromJson: _toInt) int usersActiveHalfYear,@JsonKey(name: 'subscribers_local', fromJson: _toInt) int subscribersLocal
});




}
/// @nodoc
class _$CommunityAggregatesCopyWithImpl<$Res>
    implements $CommunityAggregatesCopyWith<$Res> {
  _$CommunityAggregatesCopyWithImpl(this._self, this._then);

  final CommunityAggregates _self;
  final $Res Function(CommunityAggregates) _then;

/// Create a copy of CommunityAggregates
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? communityId = null,Object? subscribers = null,Object? posts = null,Object? comments = null,Object? published = null,Object? usersActiveDay = null,Object? usersActiveWeek = null,Object? usersActiveMonth = null,Object? usersActiveHalfYear = null,Object? subscribersLocal = null,}) {
  return _then(_self.copyWith(
communityId: null == communityId ? _self.communityId : communityId // ignore: cast_nullable_to_non_nullable
as int,subscribers: null == subscribers ? _self.subscribers : subscribers // ignore: cast_nullable_to_non_nullable
as int,posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as int,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as int,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,usersActiveDay: null == usersActiveDay ? _self.usersActiveDay : usersActiveDay // ignore: cast_nullable_to_non_nullable
as int,usersActiveWeek: null == usersActiveWeek ? _self.usersActiveWeek : usersActiveWeek // ignore: cast_nullable_to_non_nullable
as int,usersActiveMonth: null == usersActiveMonth ? _self.usersActiveMonth : usersActiveMonth // ignore: cast_nullable_to_non_nullable
as int,usersActiveHalfYear: null == usersActiveHalfYear ? _self.usersActiveHalfYear : usersActiveHalfYear // ignore: cast_nullable_to_non_nullable
as int,subscribersLocal: null == subscribersLocal ? _self.subscribersLocal : subscribersLocal // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CommunityAggregates].
extension CommunityAggregatesPatterns on CommunityAggregates {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunityAggregates value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunityAggregates() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunityAggregates value)  $default,){
final _that = this;
switch (_that) {
case _CommunityAggregates():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunityAggregates value)?  $default,){
final _that = this;
switch (_that) {
case _CommunityAggregates() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'community_id', fromJson: _toInt)  int communityId, @JsonKey(fromJson: _toInt)  int subscribers, @JsonKey(fromJson: _toInt)  int posts, @JsonKey(fromJson: _toInt)  int comments,  String published, @JsonKey(name: 'users_active_day', fromJson: _toInt)  int usersActiveDay, @JsonKey(name: 'users_active_week', fromJson: _toInt)  int usersActiveWeek, @JsonKey(name: 'users_active_month', fromJson: _toInt)  int usersActiveMonth, @JsonKey(name: 'users_active_half_year', fromJson: _toInt)  int usersActiveHalfYear, @JsonKey(name: 'subscribers_local', fromJson: _toInt)  int subscribersLocal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunityAggregates() when $default != null:
return $default(_that.communityId,_that.subscribers,_that.posts,_that.comments,_that.published,_that.usersActiveDay,_that.usersActiveWeek,_that.usersActiveMonth,_that.usersActiveHalfYear,_that.subscribersLocal);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'community_id', fromJson: _toInt)  int communityId, @JsonKey(fromJson: _toInt)  int subscribers, @JsonKey(fromJson: _toInt)  int posts, @JsonKey(fromJson: _toInt)  int comments,  String published, @JsonKey(name: 'users_active_day', fromJson: _toInt)  int usersActiveDay, @JsonKey(name: 'users_active_week', fromJson: _toInt)  int usersActiveWeek, @JsonKey(name: 'users_active_month', fromJson: _toInt)  int usersActiveMonth, @JsonKey(name: 'users_active_half_year', fromJson: _toInt)  int usersActiveHalfYear, @JsonKey(name: 'subscribers_local', fromJson: _toInt)  int subscribersLocal)  $default,) {final _that = this;
switch (_that) {
case _CommunityAggregates():
return $default(_that.communityId,_that.subscribers,_that.posts,_that.comments,_that.published,_that.usersActiveDay,_that.usersActiveWeek,_that.usersActiveMonth,_that.usersActiveHalfYear,_that.subscribersLocal);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'community_id', fromJson: _toInt)  int communityId, @JsonKey(fromJson: _toInt)  int subscribers, @JsonKey(fromJson: _toInt)  int posts, @JsonKey(fromJson: _toInt)  int comments,  String published, @JsonKey(name: 'users_active_day', fromJson: _toInt)  int usersActiveDay, @JsonKey(name: 'users_active_week', fromJson: _toInt)  int usersActiveWeek, @JsonKey(name: 'users_active_month', fromJson: _toInt)  int usersActiveMonth, @JsonKey(name: 'users_active_half_year', fromJson: _toInt)  int usersActiveHalfYear, @JsonKey(name: 'subscribers_local', fromJson: _toInt)  int subscribersLocal)?  $default,) {final _that = this;
switch (_that) {
case _CommunityAggregates() when $default != null:
return $default(_that.communityId,_that.subscribers,_that.posts,_that.comments,_that.published,_that.usersActiveDay,_that.usersActiveWeek,_that.usersActiveMonth,_that.usersActiveHalfYear,_that.subscribersLocal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _CommunityAggregates implements CommunityAggregates {
  const _CommunityAggregates({@JsonKey(name: 'community_id', fromJson: _toInt) this.communityId = 0, @JsonKey(fromJson: _toInt) this.subscribers = 0, @JsonKey(fromJson: _toInt) this.posts = 0, @JsonKey(fromJson: _toInt) this.comments = 0, this.published = '', @JsonKey(name: 'users_active_day', fromJson: _toInt) this.usersActiveDay = 0, @JsonKey(name: 'users_active_week', fromJson: _toInt) this.usersActiveWeek = 0, @JsonKey(name: 'users_active_month', fromJson: _toInt) this.usersActiveMonth = 0, @JsonKey(name: 'users_active_half_year', fromJson: _toInt) this.usersActiveHalfYear = 0, @JsonKey(name: 'subscribers_local', fromJson: _toInt) this.subscribersLocal = 0});
  factory _CommunityAggregates.fromJson(Map<String, dynamic> json) => _$CommunityAggregatesFromJson(json);

@override@JsonKey(name: 'community_id', fromJson: _toInt) final  int communityId;
@override@JsonKey(fromJson: _toInt) final  int subscribers;
@override@JsonKey(fromJson: _toInt) final  int posts;
@override@JsonKey(fromJson: _toInt) final  int comments;
@override@JsonKey() final  String published;
@override@JsonKey(name: 'users_active_day', fromJson: _toInt) final  int usersActiveDay;
@override@JsonKey(name: 'users_active_week', fromJson: _toInt) final  int usersActiveWeek;
@override@JsonKey(name: 'users_active_month', fromJson: _toInt) final  int usersActiveMonth;
@override@JsonKey(name: 'users_active_half_year', fromJson: _toInt) final  int usersActiveHalfYear;
@override@JsonKey(name: 'subscribers_local', fromJson: _toInt) final  int subscribersLocal;

/// Create a copy of CommunityAggregates
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityAggregatesCopyWith<_CommunityAggregates> get copyWith => __$CommunityAggregatesCopyWithImpl<_CommunityAggregates>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunityAggregates&&(identical(other.communityId, communityId) || other.communityId == communityId)&&(identical(other.subscribers, subscribers) || other.subscribers == subscribers)&&(identical(other.posts, posts) || other.posts == posts)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.published, published) || other.published == published)&&(identical(other.usersActiveDay, usersActiveDay) || other.usersActiveDay == usersActiveDay)&&(identical(other.usersActiveWeek, usersActiveWeek) || other.usersActiveWeek == usersActiveWeek)&&(identical(other.usersActiveMonth, usersActiveMonth) || other.usersActiveMonth == usersActiveMonth)&&(identical(other.usersActiveHalfYear, usersActiveHalfYear) || other.usersActiveHalfYear == usersActiveHalfYear)&&(identical(other.subscribersLocal, subscribersLocal) || other.subscribersLocal == subscribersLocal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,communityId,subscribers,posts,comments,published,usersActiveDay,usersActiveWeek,usersActiveMonth,usersActiveHalfYear,subscribersLocal);

@override
String toString() {
  return 'CommunityAggregates(communityId: $communityId, subscribers: $subscribers, posts: $posts, comments: $comments, published: $published, usersActiveDay: $usersActiveDay, usersActiveWeek: $usersActiveWeek, usersActiveMonth: $usersActiveMonth, usersActiveHalfYear: $usersActiveHalfYear, subscribersLocal: $subscribersLocal)';
}


}

/// @nodoc
abstract mixin class _$CommunityAggregatesCopyWith<$Res> implements $CommunityAggregatesCopyWith<$Res> {
  factory _$CommunityAggregatesCopyWith(_CommunityAggregates value, $Res Function(_CommunityAggregates) _then) = __$CommunityAggregatesCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'community_id', fromJson: _toInt) int communityId,@JsonKey(fromJson: _toInt) int subscribers,@JsonKey(fromJson: _toInt) int posts,@JsonKey(fromJson: _toInt) int comments, String published,@JsonKey(name: 'users_active_day', fromJson: _toInt) int usersActiveDay,@JsonKey(name: 'users_active_week', fromJson: _toInt) int usersActiveWeek,@JsonKey(name: 'users_active_month', fromJson: _toInt) int usersActiveMonth,@JsonKey(name: 'users_active_half_year', fromJson: _toInt) int usersActiveHalfYear,@JsonKey(name: 'subscribers_local', fromJson: _toInt) int subscribersLocal
});




}
/// @nodoc
class __$CommunityAggregatesCopyWithImpl<$Res>
    implements _$CommunityAggregatesCopyWith<$Res> {
  __$CommunityAggregatesCopyWithImpl(this._self, this._then);

  final _CommunityAggregates _self;
  final $Res Function(_CommunityAggregates) _then;

/// Create a copy of CommunityAggregates
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? communityId = null,Object? subscribers = null,Object? posts = null,Object? comments = null,Object? published = null,Object? usersActiveDay = null,Object? usersActiveWeek = null,Object? usersActiveMonth = null,Object? usersActiveHalfYear = null,Object? subscribersLocal = null,}) {
  return _then(_CommunityAggregates(
communityId: null == communityId ? _self.communityId : communityId // ignore: cast_nullable_to_non_nullable
as int,subscribers: null == subscribers ? _self.subscribers : subscribers // ignore: cast_nullable_to_non_nullable
as int,posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as int,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as int,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,usersActiveDay: null == usersActiveDay ? _self.usersActiveDay : usersActiveDay // ignore: cast_nullable_to_non_nullable
as int,usersActiveWeek: null == usersActiveWeek ? _self.usersActiveWeek : usersActiveWeek // ignore: cast_nullable_to_non_nullable
as int,usersActiveMonth: null == usersActiveMonth ? _self.usersActiveMonth : usersActiveMonth // ignore: cast_nullable_to_non_nullable
as int,usersActiveHalfYear: null == usersActiveHalfYear ? _self.usersActiveHalfYear : usersActiveHalfYear // ignore: cast_nullable_to_non_nullable
as int,subscribersLocal: null == subscribersLocal ? _self.subscribersLocal : subscribersLocal // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CommunityView {

 Community get community;/// "Subscribed" | "NotSubscribed" | "Pending"
 String get subscribed; bool get blocked; CommunityAggregates get counts;@JsonKey(name: 'banned_from_community') bool get bannedFromCommunity;/// Populated after parse via [copyWith] in [LemmyApiClient.getCommunity].
 List<CommunityModeratorView> get moderators;
/// Create a copy of CommunityView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityViewCopyWith<CommunityView> get copyWith => _$CommunityViewCopyWithImpl<CommunityView>(this as CommunityView, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunityView&&(identical(other.community, community) || other.community == community)&&(identical(other.subscribed, subscribed) || other.subscribed == subscribed)&&(identical(other.blocked, blocked) || other.blocked == blocked)&&(identical(other.counts, counts) || other.counts == counts)&&(identical(other.bannedFromCommunity, bannedFromCommunity) || other.bannedFromCommunity == bannedFromCommunity)&&const DeepCollectionEquality().equals(other.moderators, moderators));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,community,subscribed,blocked,counts,bannedFromCommunity,const DeepCollectionEquality().hash(moderators));

@override
String toString() {
  return 'CommunityView(community: $community, subscribed: $subscribed, blocked: $blocked, counts: $counts, bannedFromCommunity: $bannedFromCommunity, moderators: $moderators)';
}


}

/// @nodoc
abstract mixin class $CommunityViewCopyWith<$Res>  {
  factory $CommunityViewCopyWith(CommunityView value, $Res Function(CommunityView) _then) = _$CommunityViewCopyWithImpl;
@useResult
$Res call({
 Community community, String subscribed, bool blocked, CommunityAggregates counts,@JsonKey(name: 'banned_from_community') bool bannedFromCommunity, List<CommunityModeratorView> moderators
});


$CommunityCopyWith<$Res> get community;$CommunityAggregatesCopyWith<$Res> get counts;

}
/// @nodoc
class _$CommunityViewCopyWithImpl<$Res>
    implements $CommunityViewCopyWith<$Res> {
  _$CommunityViewCopyWithImpl(this._self, this._then);

  final CommunityView _self;
  final $Res Function(CommunityView) _then;

/// Create a copy of CommunityView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? community = null,Object? subscribed = null,Object? blocked = null,Object? counts = null,Object? bannedFromCommunity = null,Object? moderators = null,}) {
  return _then(_self.copyWith(
community: null == community ? _self.community : community // ignore: cast_nullable_to_non_nullable
as Community,subscribed: null == subscribed ? _self.subscribed : subscribed // ignore: cast_nullable_to_non_nullable
as String,blocked: null == blocked ? _self.blocked : blocked // ignore: cast_nullable_to_non_nullable
as bool,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as CommunityAggregates,bannedFromCommunity: null == bannedFromCommunity ? _self.bannedFromCommunity : bannedFromCommunity // ignore: cast_nullable_to_non_nullable
as bool,moderators: null == moderators ? _self.moderators : moderators // ignore: cast_nullable_to_non_nullable
as List<CommunityModeratorView>,
  ));
}
/// Create a copy of CommunityView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommunityCopyWith<$Res> get community {
  
  return $CommunityCopyWith<$Res>(_self.community, (value) {
    return _then(_self.copyWith(community: value));
  });
}/// Create a copy of CommunityView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommunityAggregatesCopyWith<$Res> get counts {
  
  return $CommunityAggregatesCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}


/// Adds pattern-matching-related methods to [CommunityView].
extension CommunityViewPatterns on CommunityView {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunityView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunityView() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunityView value)  $default,){
final _that = this;
switch (_that) {
case _CommunityView():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunityView value)?  $default,){
final _that = this;
switch (_that) {
case _CommunityView() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Community community,  String subscribed,  bool blocked,  CommunityAggregates counts, @JsonKey(name: 'banned_from_community')  bool bannedFromCommunity,  List<CommunityModeratorView> moderators)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunityView() when $default != null:
return $default(_that.community,_that.subscribed,_that.blocked,_that.counts,_that.bannedFromCommunity,_that.moderators);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Community community,  String subscribed,  bool blocked,  CommunityAggregates counts, @JsonKey(name: 'banned_from_community')  bool bannedFromCommunity,  List<CommunityModeratorView> moderators)  $default,) {final _that = this;
switch (_that) {
case _CommunityView():
return $default(_that.community,_that.subscribed,_that.blocked,_that.counts,_that.bannedFromCommunity,_that.moderators);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Community community,  String subscribed,  bool blocked,  CommunityAggregates counts, @JsonKey(name: 'banned_from_community')  bool bannedFromCommunity,  List<CommunityModeratorView> moderators)?  $default,) {final _that = this;
switch (_that) {
case _CommunityView() when $default != null:
return $default(_that.community,_that.subscribed,_that.blocked,_that.counts,_that.bannedFromCommunity,_that.moderators);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _CommunityView implements CommunityView {
  const _CommunityView({required this.community, this.subscribed = 'NotSubscribed', this.blocked = false, required this.counts, @JsonKey(name: 'banned_from_community') this.bannedFromCommunity = false, final  List<CommunityModeratorView> moderators = const <CommunityModeratorView>[]}): _moderators = moderators;
  factory _CommunityView.fromJson(Map<String, dynamic> json) => _$CommunityViewFromJson(json);

@override final  Community community;
/// "Subscribed" | "NotSubscribed" | "Pending"
@override@JsonKey() final  String subscribed;
@override@JsonKey() final  bool blocked;
@override final  CommunityAggregates counts;
@override@JsonKey(name: 'banned_from_community') final  bool bannedFromCommunity;
/// Populated after parse via [copyWith] in [LemmyApiClient.getCommunity].
 final  List<CommunityModeratorView> _moderators;
/// Populated after parse via [copyWith] in [LemmyApiClient.getCommunity].
@override@JsonKey() List<CommunityModeratorView> get moderators {
  if (_moderators is EqualUnmodifiableListView) return _moderators;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_moderators);
}


/// Create a copy of CommunityView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityViewCopyWith<_CommunityView> get copyWith => __$CommunityViewCopyWithImpl<_CommunityView>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunityView&&(identical(other.community, community) || other.community == community)&&(identical(other.subscribed, subscribed) || other.subscribed == subscribed)&&(identical(other.blocked, blocked) || other.blocked == blocked)&&(identical(other.counts, counts) || other.counts == counts)&&(identical(other.bannedFromCommunity, bannedFromCommunity) || other.bannedFromCommunity == bannedFromCommunity)&&const DeepCollectionEquality().equals(other._moderators, _moderators));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,community,subscribed,blocked,counts,bannedFromCommunity,const DeepCollectionEquality().hash(_moderators));

@override
String toString() {
  return 'CommunityView(community: $community, subscribed: $subscribed, blocked: $blocked, counts: $counts, bannedFromCommunity: $bannedFromCommunity, moderators: $moderators)';
}


}

/// @nodoc
abstract mixin class _$CommunityViewCopyWith<$Res> implements $CommunityViewCopyWith<$Res> {
  factory _$CommunityViewCopyWith(_CommunityView value, $Res Function(_CommunityView) _then) = __$CommunityViewCopyWithImpl;
@override @useResult
$Res call({
 Community community, String subscribed, bool blocked, CommunityAggregates counts,@JsonKey(name: 'banned_from_community') bool bannedFromCommunity, List<CommunityModeratorView> moderators
});


@override $CommunityCopyWith<$Res> get community;@override $CommunityAggregatesCopyWith<$Res> get counts;

}
/// @nodoc
class __$CommunityViewCopyWithImpl<$Res>
    implements _$CommunityViewCopyWith<$Res> {
  __$CommunityViewCopyWithImpl(this._self, this._then);

  final _CommunityView _self;
  final $Res Function(_CommunityView) _then;

/// Create a copy of CommunityView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? community = null,Object? subscribed = null,Object? blocked = null,Object? counts = null,Object? bannedFromCommunity = null,Object? moderators = null,}) {
  return _then(_CommunityView(
community: null == community ? _self.community : community // ignore: cast_nullable_to_non_nullable
as Community,subscribed: null == subscribed ? _self.subscribed : subscribed // ignore: cast_nullable_to_non_nullable
as String,blocked: null == blocked ? _self.blocked : blocked // ignore: cast_nullable_to_non_nullable
as bool,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as CommunityAggregates,bannedFromCommunity: null == bannedFromCommunity ? _self.bannedFromCommunity : bannedFromCommunity // ignore: cast_nullable_to_non_nullable
as bool,moderators: null == moderators ? _self._moderators : moderators // ignore: cast_nullable_to_non_nullable
as List<CommunityModeratorView>,
  ));
}

/// Create a copy of CommunityView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommunityCopyWith<$Res> get community {
  
  return $CommunityCopyWith<$Res>(_self.community, (value) {
    return _then(_self.copyWith(community: value));
  });
}/// Create a copy of CommunityView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommunityAggregatesCopyWith<$Res> get counts {
  
  return $CommunityAggregatesCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}


/// @nodoc
mixin _$CommunityModeratorView {

 Community get community; Person get moderator;
/// Create a copy of CommunityModeratorView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityModeratorViewCopyWith<CommunityModeratorView> get copyWith => _$CommunityModeratorViewCopyWithImpl<CommunityModeratorView>(this as CommunityModeratorView, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunityModeratorView&&(identical(other.community, community) || other.community == community)&&(identical(other.moderator, moderator) || other.moderator == moderator));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,community,moderator);

@override
String toString() {
  return 'CommunityModeratorView(community: $community, moderator: $moderator)';
}


}

/// @nodoc
abstract mixin class $CommunityModeratorViewCopyWith<$Res>  {
  factory $CommunityModeratorViewCopyWith(CommunityModeratorView value, $Res Function(CommunityModeratorView) _then) = _$CommunityModeratorViewCopyWithImpl;
@useResult
$Res call({
 Community community, Person moderator
});


$CommunityCopyWith<$Res> get community;$PersonCopyWith<$Res> get moderator;

}
/// @nodoc
class _$CommunityModeratorViewCopyWithImpl<$Res>
    implements $CommunityModeratorViewCopyWith<$Res> {
  _$CommunityModeratorViewCopyWithImpl(this._self, this._then);

  final CommunityModeratorView _self;
  final $Res Function(CommunityModeratorView) _then;

/// Create a copy of CommunityModeratorView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? community = null,Object? moderator = null,}) {
  return _then(_self.copyWith(
community: null == community ? _self.community : community // ignore: cast_nullable_to_non_nullable
as Community,moderator: null == moderator ? _self.moderator : moderator // ignore: cast_nullable_to_non_nullable
as Person,
  ));
}
/// Create a copy of CommunityModeratorView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommunityCopyWith<$Res> get community {
  
  return $CommunityCopyWith<$Res>(_self.community, (value) {
    return _then(_self.copyWith(community: value));
  });
}/// Create a copy of CommunityModeratorView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get moderator {
  
  return $PersonCopyWith<$Res>(_self.moderator, (value) {
    return _then(_self.copyWith(moderator: value));
  });
}
}


/// Adds pattern-matching-related methods to [CommunityModeratorView].
extension CommunityModeratorViewPatterns on CommunityModeratorView {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunityModeratorView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunityModeratorView() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunityModeratorView value)  $default,){
final _that = this;
switch (_that) {
case _CommunityModeratorView():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunityModeratorView value)?  $default,){
final _that = this;
switch (_that) {
case _CommunityModeratorView() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Community community,  Person moderator)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunityModeratorView() when $default != null:
return $default(_that.community,_that.moderator);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Community community,  Person moderator)  $default,) {final _that = this;
switch (_that) {
case _CommunityModeratorView():
return $default(_that.community,_that.moderator);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Community community,  Person moderator)?  $default,) {final _that = this;
switch (_that) {
case _CommunityModeratorView() when $default != null:
return $default(_that.community,_that.moderator);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _CommunityModeratorView implements CommunityModeratorView {
  const _CommunityModeratorView({required this.community, required this.moderator});
  factory _CommunityModeratorView.fromJson(Map<String, dynamic> json) => _$CommunityModeratorViewFromJson(json);

@override final  Community community;
@override final  Person moderator;

/// Create a copy of CommunityModeratorView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityModeratorViewCopyWith<_CommunityModeratorView> get copyWith => __$CommunityModeratorViewCopyWithImpl<_CommunityModeratorView>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunityModeratorView&&(identical(other.community, community) || other.community == community)&&(identical(other.moderator, moderator) || other.moderator == moderator));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,community,moderator);

@override
String toString() {
  return 'CommunityModeratorView(community: $community, moderator: $moderator)';
}


}

/// @nodoc
abstract mixin class _$CommunityModeratorViewCopyWith<$Res> implements $CommunityModeratorViewCopyWith<$Res> {
  factory _$CommunityModeratorViewCopyWith(_CommunityModeratorView value, $Res Function(_CommunityModeratorView) _then) = __$CommunityModeratorViewCopyWithImpl;
@override @useResult
$Res call({
 Community community, Person moderator
});


@override $CommunityCopyWith<$Res> get community;@override $PersonCopyWith<$Res> get moderator;

}
/// @nodoc
class __$CommunityModeratorViewCopyWithImpl<$Res>
    implements _$CommunityModeratorViewCopyWith<$Res> {
  __$CommunityModeratorViewCopyWithImpl(this._self, this._then);

  final _CommunityModeratorView _self;
  final $Res Function(_CommunityModeratorView) _then;

/// Create a copy of CommunityModeratorView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? community = null,Object? moderator = null,}) {
  return _then(_CommunityModeratorView(
community: null == community ? _self.community : community // ignore: cast_nullable_to_non_nullable
as Community,moderator: null == moderator ? _self.moderator : moderator // ignore: cast_nullable_to_non_nullable
as Person,
  ));
}

/// Create a copy of CommunityModeratorView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommunityCopyWith<$Res> get community {
  
  return $CommunityCopyWith<$Res>(_self.community, (value) {
    return _then(_self.copyWith(community: value));
  });
}/// Create a copy of CommunityModeratorView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get moderator {
  
  return $PersonCopyWith<$Res>(_self.moderator, (value) {
    return _then(_self.copyWith(moderator: value));
  });
}
}

// dart format on
