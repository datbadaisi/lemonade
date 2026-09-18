// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'site.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Site {

@JsonKey(fromJson: _toInt) int get id; String get name; String? get sidebar; String get published; String? get updated; String? get icon; String? get banner; String? get description;@JsonKey(name: 'actor_id') String get actorId;@JsonKey(name: 'last_refreshed_at') String get lastRefreshedAt;@JsonKey(name: 'inbox_url') String get inboxUrl;@JsonKey(name: 'public_key') String get publicKey;@JsonKey(name: 'instance_id', fromJson: _toInt) int get instanceId;@JsonKey(name: 'content_warning') String? get contentWarning;
/// Create a copy of Site
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SiteCopyWith<Site> get copyWith => _$SiteCopyWithImpl<Site>(this as Site, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Site&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.sidebar, sidebar) || other.sidebar == sidebar)&&(identical(other.published, published) || other.published == published)&&(identical(other.updated, updated) || other.updated == updated)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.banner, banner) || other.banner == banner)&&(identical(other.description, description) || other.description == description)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.lastRefreshedAt, lastRefreshedAt) || other.lastRefreshedAt == lastRefreshedAt)&&(identical(other.inboxUrl, inboxUrl) || other.inboxUrl == inboxUrl)&&(identical(other.publicKey, publicKey) || other.publicKey == publicKey)&&(identical(other.instanceId, instanceId) || other.instanceId == instanceId)&&(identical(other.contentWarning, contentWarning) || other.contentWarning == contentWarning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,sidebar,published,updated,icon,banner,description,actorId,lastRefreshedAt,inboxUrl,publicKey,instanceId,contentWarning);

@override
String toString() {
  return 'Site(id: $id, name: $name, sidebar: $sidebar, published: $published, updated: $updated, icon: $icon, banner: $banner, description: $description, actorId: $actorId, lastRefreshedAt: $lastRefreshedAt, inboxUrl: $inboxUrl, publicKey: $publicKey, instanceId: $instanceId, contentWarning: $contentWarning)';
}


}

/// @nodoc
abstract mixin class $SiteCopyWith<$Res>  {
  factory $SiteCopyWith(Site value, $Res Function(Site) _then) = _$SiteCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _toInt) int id, String name, String? sidebar, String published, String? updated, String? icon, String? banner, String? description,@JsonKey(name: 'actor_id') String actorId,@JsonKey(name: 'last_refreshed_at') String lastRefreshedAt,@JsonKey(name: 'inbox_url') String inboxUrl,@JsonKey(name: 'public_key') String publicKey,@JsonKey(name: 'instance_id', fromJson: _toInt) int instanceId,@JsonKey(name: 'content_warning') String? contentWarning
});




}
/// @nodoc
class _$SiteCopyWithImpl<$Res>
    implements $SiteCopyWith<$Res> {
  _$SiteCopyWithImpl(this._self, this._then);

  final Site _self;
  final $Res Function(Site) _then;

/// Create a copy of Site
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? sidebar = freezed,Object? published = null,Object? updated = freezed,Object? icon = freezed,Object? banner = freezed,Object? description = freezed,Object? actorId = null,Object? lastRefreshedAt = null,Object? inboxUrl = null,Object? publicKey = null,Object? instanceId = null,Object? contentWarning = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sidebar: freezed == sidebar ? _self.sidebar : sidebar // ignore: cast_nullable_to_non_nullable
as String?,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,updated: freezed == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,banner: freezed == banner ? _self.banner : banner // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,lastRefreshedAt: null == lastRefreshedAt ? _self.lastRefreshedAt : lastRefreshedAt // ignore: cast_nullable_to_non_nullable
as String,inboxUrl: null == inboxUrl ? _self.inboxUrl : inboxUrl // ignore: cast_nullable_to_non_nullable
as String,publicKey: null == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as String,instanceId: null == instanceId ? _self.instanceId : instanceId // ignore: cast_nullable_to_non_nullable
as int,contentWarning: freezed == contentWarning ? _self.contentWarning : contentWarning // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Site].
extension SitePatterns on Site {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Site value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Site() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Site value)  $default,){
final _that = this;
switch (_that) {
case _Site():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Site value)?  $default,){
final _that = this;
switch (_that) {
case _Site() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int id,  String name,  String? sidebar,  String published,  String? updated,  String? icon,  String? banner,  String? description, @JsonKey(name: 'actor_id')  String actorId, @JsonKey(name: 'last_refreshed_at')  String lastRefreshedAt, @JsonKey(name: 'inbox_url')  String inboxUrl, @JsonKey(name: 'public_key')  String publicKey, @JsonKey(name: 'instance_id', fromJson: _toInt)  int instanceId, @JsonKey(name: 'content_warning')  String? contentWarning)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Site() when $default != null:
return $default(_that.id,_that.name,_that.sidebar,_that.published,_that.updated,_that.icon,_that.banner,_that.description,_that.actorId,_that.lastRefreshedAt,_that.inboxUrl,_that.publicKey,_that.instanceId,_that.contentWarning);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int id,  String name,  String? sidebar,  String published,  String? updated,  String? icon,  String? banner,  String? description, @JsonKey(name: 'actor_id')  String actorId, @JsonKey(name: 'last_refreshed_at')  String lastRefreshedAt, @JsonKey(name: 'inbox_url')  String inboxUrl, @JsonKey(name: 'public_key')  String publicKey, @JsonKey(name: 'instance_id', fromJson: _toInt)  int instanceId, @JsonKey(name: 'content_warning')  String? contentWarning)  $default,) {final _that = this;
switch (_that) {
case _Site():
return $default(_that.id,_that.name,_that.sidebar,_that.published,_that.updated,_that.icon,_that.banner,_that.description,_that.actorId,_that.lastRefreshedAt,_that.inboxUrl,_that.publicKey,_that.instanceId,_that.contentWarning);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _toInt)  int id,  String name,  String? sidebar,  String published,  String? updated,  String? icon,  String? banner,  String? description, @JsonKey(name: 'actor_id')  String actorId, @JsonKey(name: 'last_refreshed_at')  String lastRefreshedAt, @JsonKey(name: 'inbox_url')  String inboxUrl, @JsonKey(name: 'public_key')  String publicKey, @JsonKey(name: 'instance_id', fromJson: _toInt)  int instanceId, @JsonKey(name: 'content_warning')  String? contentWarning)?  $default,) {final _that = this;
switch (_that) {
case _Site() when $default != null:
return $default(_that.id,_that.name,_that.sidebar,_that.published,_that.updated,_that.icon,_that.banner,_that.description,_that.actorId,_that.lastRefreshedAt,_that.inboxUrl,_that.publicKey,_that.instanceId,_that.contentWarning);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _Site implements Site {
  const _Site({@JsonKey(fromJson: _toInt) this.id = 0, this.name = '', this.sidebar, this.published = '', this.updated, this.icon, this.banner, this.description, @JsonKey(name: 'actor_id') this.actorId = '', @JsonKey(name: 'last_refreshed_at') this.lastRefreshedAt = '', @JsonKey(name: 'inbox_url') this.inboxUrl = '', @JsonKey(name: 'public_key') this.publicKey = '', @JsonKey(name: 'instance_id', fromJson: _toInt) this.instanceId = 0, @JsonKey(name: 'content_warning') this.contentWarning});
  factory _Site.fromJson(Map<String, dynamic> json) => _$SiteFromJson(json);

@override@JsonKey(fromJson: _toInt) final  int id;
@override@JsonKey() final  String name;
@override final  String? sidebar;
@override@JsonKey() final  String published;
@override final  String? updated;
@override final  String? icon;
@override final  String? banner;
@override final  String? description;
@override@JsonKey(name: 'actor_id') final  String actorId;
@override@JsonKey(name: 'last_refreshed_at') final  String lastRefreshedAt;
@override@JsonKey(name: 'inbox_url') final  String inboxUrl;
@override@JsonKey(name: 'public_key') final  String publicKey;
@override@JsonKey(name: 'instance_id', fromJson: _toInt) final  int instanceId;
@override@JsonKey(name: 'content_warning') final  String? contentWarning;

/// Create a copy of Site
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SiteCopyWith<_Site> get copyWith => __$SiteCopyWithImpl<_Site>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Site&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.sidebar, sidebar) || other.sidebar == sidebar)&&(identical(other.published, published) || other.published == published)&&(identical(other.updated, updated) || other.updated == updated)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.banner, banner) || other.banner == banner)&&(identical(other.description, description) || other.description == description)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.lastRefreshedAt, lastRefreshedAt) || other.lastRefreshedAt == lastRefreshedAt)&&(identical(other.inboxUrl, inboxUrl) || other.inboxUrl == inboxUrl)&&(identical(other.publicKey, publicKey) || other.publicKey == publicKey)&&(identical(other.instanceId, instanceId) || other.instanceId == instanceId)&&(identical(other.contentWarning, contentWarning) || other.contentWarning == contentWarning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,sidebar,published,updated,icon,banner,description,actorId,lastRefreshedAt,inboxUrl,publicKey,instanceId,contentWarning);

@override
String toString() {
  return 'Site(id: $id, name: $name, sidebar: $sidebar, published: $published, updated: $updated, icon: $icon, banner: $banner, description: $description, actorId: $actorId, lastRefreshedAt: $lastRefreshedAt, inboxUrl: $inboxUrl, publicKey: $publicKey, instanceId: $instanceId, contentWarning: $contentWarning)';
}


}

/// @nodoc
abstract mixin class _$SiteCopyWith<$Res> implements $SiteCopyWith<$Res> {
  factory _$SiteCopyWith(_Site value, $Res Function(_Site) _then) = __$SiteCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _toInt) int id, String name, String? sidebar, String published, String? updated, String? icon, String? banner, String? description,@JsonKey(name: 'actor_id') String actorId,@JsonKey(name: 'last_refreshed_at') String lastRefreshedAt,@JsonKey(name: 'inbox_url') String inboxUrl,@JsonKey(name: 'public_key') String publicKey,@JsonKey(name: 'instance_id', fromJson: _toInt) int instanceId,@JsonKey(name: 'content_warning') String? contentWarning
});




}
/// @nodoc
class __$SiteCopyWithImpl<$Res>
    implements _$SiteCopyWith<$Res> {
  __$SiteCopyWithImpl(this._self, this._then);

  final _Site _self;
  final $Res Function(_Site) _then;

/// Create a copy of Site
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? sidebar = freezed,Object? published = null,Object? updated = freezed,Object? icon = freezed,Object? banner = freezed,Object? description = freezed,Object? actorId = null,Object? lastRefreshedAt = null,Object? inboxUrl = null,Object? publicKey = null,Object? instanceId = null,Object? contentWarning = freezed,}) {
  return _then(_Site(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sidebar: freezed == sidebar ? _self.sidebar : sidebar // ignore: cast_nullable_to_non_nullable
as String?,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,updated: freezed == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,banner: freezed == banner ? _self.banner : banner // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,lastRefreshedAt: null == lastRefreshedAt ? _self.lastRefreshedAt : lastRefreshedAt // ignore: cast_nullable_to_non_nullable
as String,inboxUrl: null == inboxUrl ? _self.inboxUrl : inboxUrl // ignore: cast_nullable_to_non_nullable
as String,publicKey: null == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as String,instanceId: null == instanceId ? _self.instanceId : instanceId // ignore: cast_nullable_to_non_nullable
as int,contentWarning: freezed == contentWarning ? _self.contentWarning : contentWarning // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SiteAggregates {

@JsonKey(name: 'site_id', fromJson: _toInt) int get siteId;@JsonKey(fromJson: _toInt) int get users;@JsonKey(fromJson: _toInt) int get posts;@JsonKey(fromJson: _toInt) int get comments;@JsonKey(fromJson: _toInt) int get communities;@JsonKey(name: 'users_active_day', fromJson: _toInt) int get usersActiveDay;@JsonKey(name: 'users_active_week', fromJson: _toInt) int get usersActiveWeek;@JsonKey(name: 'users_active_month', fromJson: _toInt) int get usersActiveMonth;@JsonKey(name: 'users_active_half_year', fromJson: _toInt) int get usersActiveHalfYear;
/// Create a copy of SiteAggregates
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SiteAggregatesCopyWith<SiteAggregates> get copyWith => _$SiteAggregatesCopyWithImpl<SiteAggregates>(this as SiteAggregates, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SiteAggregates&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.users, users) || other.users == users)&&(identical(other.posts, posts) || other.posts == posts)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.communities, communities) || other.communities == communities)&&(identical(other.usersActiveDay, usersActiveDay) || other.usersActiveDay == usersActiveDay)&&(identical(other.usersActiveWeek, usersActiveWeek) || other.usersActiveWeek == usersActiveWeek)&&(identical(other.usersActiveMonth, usersActiveMonth) || other.usersActiveMonth == usersActiveMonth)&&(identical(other.usersActiveHalfYear, usersActiveHalfYear) || other.usersActiveHalfYear == usersActiveHalfYear));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,siteId,users,posts,comments,communities,usersActiveDay,usersActiveWeek,usersActiveMonth,usersActiveHalfYear);

@override
String toString() {
  return 'SiteAggregates(siteId: $siteId, users: $users, posts: $posts, comments: $comments, communities: $communities, usersActiveDay: $usersActiveDay, usersActiveWeek: $usersActiveWeek, usersActiveMonth: $usersActiveMonth, usersActiveHalfYear: $usersActiveHalfYear)';
}


}

/// @nodoc
abstract mixin class $SiteAggregatesCopyWith<$Res>  {
  factory $SiteAggregatesCopyWith(SiteAggregates value, $Res Function(SiteAggregates) _then) = _$SiteAggregatesCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'site_id', fromJson: _toInt) int siteId,@JsonKey(fromJson: _toInt) int users,@JsonKey(fromJson: _toInt) int posts,@JsonKey(fromJson: _toInt) int comments,@JsonKey(fromJson: _toInt) int communities,@JsonKey(name: 'users_active_day', fromJson: _toInt) int usersActiveDay,@JsonKey(name: 'users_active_week', fromJson: _toInt) int usersActiveWeek,@JsonKey(name: 'users_active_month', fromJson: _toInt) int usersActiveMonth,@JsonKey(name: 'users_active_half_year', fromJson: _toInt) int usersActiveHalfYear
});




}
/// @nodoc
class _$SiteAggregatesCopyWithImpl<$Res>
    implements $SiteAggregatesCopyWith<$Res> {
  _$SiteAggregatesCopyWithImpl(this._self, this._then);

  final SiteAggregates _self;
  final $Res Function(SiteAggregates) _then;

/// Create a copy of SiteAggregates
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? siteId = null,Object? users = null,Object? posts = null,Object? comments = null,Object? communities = null,Object? usersActiveDay = null,Object? usersActiveWeek = null,Object? usersActiveMonth = null,Object? usersActiveHalfYear = null,}) {
  return _then(_self.copyWith(
siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as int,users: null == users ? _self.users : users // ignore: cast_nullable_to_non_nullable
as int,posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as int,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as int,communities: null == communities ? _self.communities : communities // ignore: cast_nullable_to_non_nullable
as int,usersActiveDay: null == usersActiveDay ? _self.usersActiveDay : usersActiveDay // ignore: cast_nullable_to_non_nullable
as int,usersActiveWeek: null == usersActiveWeek ? _self.usersActiveWeek : usersActiveWeek // ignore: cast_nullable_to_non_nullable
as int,usersActiveMonth: null == usersActiveMonth ? _self.usersActiveMonth : usersActiveMonth // ignore: cast_nullable_to_non_nullable
as int,usersActiveHalfYear: null == usersActiveHalfYear ? _self.usersActiveHalfYear : usersActiveHalfYear // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SiteAggregates].
extension SiteAggregatesPatterns on SiteAggregates {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SiteAggregates value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SiteAggregates() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SiteAggregates value)  $default,){
final _that = this;
switch (_that) {
case _SiteAggregates():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SiteAggregates value)?  $default,){
final _that = this;
switch (_that) {
case _SiteAggregates() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'site_id', fromJson: _toInt)  int siteId, @JsonKey(fromJson: _toInt)  int users, @JsonKey(fromJson: _toInt)  int posts, @JsonKey(fromJson: _toInt)  int comments, @JsonKey(fromJson: _toInt)  int communities, @JsonKey(name: 'users_active_day', fromJson: _toInt)  int usersActiveDay, @JsonKey(name: 'users_active_week', fromJson: _toInt)  int usersActiveWeek, @JsonKey(name: 'users_active_month', fromJson: _toInt)  int usersActiveMonth, @JsonKey(name: 'users_active_half_year', fromJson: _toInt)  int usersActiveHalfYear)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SiteAggregates() when $default != null:
return $default(_that.siteId,_that.users,_that.posts,_that.comments,_that.communities,_that.usersActiveDay,_that.usersActiveWeek,_that.usersActiveMonth,_that.usersActiveHalfYear);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'site_id', fromJson: _toInt)  int siteId, @JsonKey(fromJson: _toInt)  int users, @JsonKey(fromJson: _toInt)  int posts, @JsonKey(fromJson: _toInt)  int comments, @JsonKey(fromJson: _toInt)  int communities, @JsonKey(name: 'users_active_day', fromJson: _toInt)  int usersActiveDay, @JsonKey(name: 'users_active_week', fromJson: _toInt)  int usersActiveWeek, @JsonKey(name: 'users_active_month', fromJson: _toInt)  int usersActiveMonth, @JsonKey(name: 'users_active_half_year', fromJson: _toInt)  int usersActiveHalfYear)  $default,) {final _that = this;
switch (_that) {
case _SiteAggregates():
return $default(_that.siteId,_that.users,_that.posts,_that.comments,_that.communities,_that.usersActiveDay,_that.usersActiveWeek,_that.usersActiveMonth,_that.usersActiveHalfYear);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'site_id', fromJson: _toInt)  int siteId, @JsonKey(fromJson: _toInt)  int users, @JsonKey(fromJson: _toInt)  int posts, @JsonKey(fromJson: _toInt)  int comments, @JsonKey(fromJson: _toInt)  int communities, @JsonKey(name: 'users_active_day', fromJson: _toInt)  int usersActiveDay, @JsonKey(name: 'users_active_week', fromJson: _toInt)  int usersActiveWeek, @JsonKey(name: 'users_active_month', fromJson: _toInt)  int usersActiveMonth, @JsonKey(name: 'users_active_half_year', fromJson: _toInt)  int usersActiveHalfYear)?  $default,) {final _that = this;
switch (_that) {
case _SiteAggregates() when $default != null:
return $default(_that.siteId,_that.users,_that.posts,_that.comments,_that.communities,_that.usersActiveDay,_that.usersActiveWeek,_that.usersActiveMonth,_that.usersActiveHalfYear);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _SiteAggregates implements SiteAggregates {
  const _SiteAggregates({@JsonKey(name: 'site_id', fromJson: _toInt) this.siteId = 0, @JsonKey(fromJson: _toInt) this.users = 0, @JsonKey(fromJson: _toInt) this.posts = 0, @JsonKey(fromJson: _toInt) this.comments = 0, @JsonKey(fromJson: _toInt) this.communities = 0, @JsonKey(name: 'users_active_day', fromJson: _toInt) this.usersActiveDay = 0, @JsonKey(name: 'users_active_week', fromJson: _toInt) this.usersActiveWeek = 0, @JsonKey(name: 'users_active_month', fromJson: _toInt) this.usersActiveMonth = 0, @JsonKey(name: 'users_active_half_year', fromJson: _toInt) this.usersActiveHalfYear = 0});
  factory _SiteAggregates.fromJson(Map<String, dynamic> json) => _$SiteAggregatesFromJson(json);

@override@JsonKey(name: 'site_id', fromJson: _toInt) final  int siteId;
@override@JsonKey(fromJson: _toInt) final  int users;
@override@JsonKey(fromJson: _toInt) final  int posts;
@override@JsonKey(fromJson: _toInt) final  int comments;
@override@JsonKey(fromJson: _toInt) final  int communities;
@override@JsonKey(name: 'users_active_day', fromJson: _toInt) final  int usersActiveDay;
@override@JsonKey(name: 'users_active_week', fromJson: _toInt) final  int usersActiveWeek;
@override@JsonKey(name: 'users_active_month', fromJson: _toInt) final  int usersActiveMonth;
@override@JsonKey(name: 'users_active_half_year', fromJson: _toInt) final  int usersActiveHalfYear;

/// Create a copy of SiteAggregates
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SiteAggregatesCopyWith<_SiteAggregates> get copyWith => __$SiteAggregatesCopyWithImpl<_SiteAggregates>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SiteAggregates&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.users, users) || other.users == users)&&(identical(other.posts, posts) || other.posts == posts)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.communities, communities) || other.communities == communities)&&(identical(other.usersActiveDay, usersActiveDay) || other.usersActiveDay == usersActiveDay)&&(identical(other.usersActiveWeek, usersActiveWeek) || other.usersActiveWeek == usersActiveWeek)&&(identical(other.usersActiveMonth, usersActiveMonth) || other.usersActiveMonth == usersActiveMonth)&&(identical(other.usersActiveHalfYear, usersActiveHalfYear) || other.usersActiveHalfYear == usersActiveHalfYear));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,siteId,users,posts,comments,communities,usersActiveDay,usersActiveWeek,usersActiveMonth,usersActiveHalfYear);

@override
String toString() {
  return 'SiteAggregates(siteId: $siteId, users: $users, posts: $posts, comments: $comments, communities: $communities, usersActiveDay: $usersActiveDay, usersActiveWeek: $usersActiveWeek, usersActiveMonth: $usersActiveMonth, usersActiveHalfYear: $usersActiveHalfYear)';
}


}

/// @nodoc
abstract mixin class _$SiteAggregatesCopyWith<$Res> implements $SiteAggregatesCopyWith<$Res> {
  factory _$SiteAggregatesCopyWith(_SiteAggregates value, $Res Function(_SiteAggregates) _then) = __$SiteAggregatesCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'site_id', fromJson: _toInt) int siteId,@JsonKey(fromJson: _toInt) int users,@JsonKey(fromJson: _toInt) int posts,@JsonKey(fromJson: _toInt) int comments,@JsonKey(fromJson: _toInt) int communities,@JsonKey(name: 'users_active_day', fromJson: _toInt) int usersActiveDay,@JsonKey(name: 'users_active_week', fromJson: _toInt) int usersActiveWeek,@JsonKey(name: 'users_active_month', fromJson: _toInt) int usersActiveMonth,@JsonKey(name: 'users_active_half_year', fromJson: _toInt) int usersActiveHalfYear
});




}
/// @nodoc
class __$SiteAggregatesCopyWithImpl<$Res>
    implements _$SiteAggregatesCopyWith<$Res> {
  __$SiteAggregatesCopyWithImpl(this._self, this._then);

  final _SiteAggregates _self;
  final $Res Function(_SiteAggregates) _then;

/// Create a copy of SiteAggregates
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? siteId = null,Object? users = null,Object? posts = null,Object? comments = null,Object? communities = null,Object? usersActiveDay = null,Object? usersActiveWeek = null,Object? usersActiveMonth = null,Object? usersActiveHalfYear = null,}) {
  return _then(_SiteAggregates(
siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as int,users: null == users ? _self.users : users // ignore: cast_nullable_to_non_nullable
as int,posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as int,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as int,communities: null == communities ? _self.communities : communities // ignore: cast_nullable_to_non_nullable
as int,usersActiveDay: null == usersActiveDay ? _self.usersActiveDay : usersActiveDay // ignore: cast_nullable_to_non_nullable
as int,usersActiveWeek: null == usersActiveWeek ? _self.usersActiveWeek : usersActiveWeek // ignore: cast_nullable_to_non_nullable
as int,usersActiveMonth: null == usersActiveMonth ? _self.usersActiveMonth : usersActiveMonth // ignore: cast_nullable_to_non_nullable
as int,usersActiveHalfYear: null == usersActiveHalfYear ? _self.usersActiveHalfYear : usersActiveHalfYear // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SiteView {

 Site get site; SiteAggregates get counts;
/// Create a copy of SiteView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SiteViewCopyWith<SiteView> get copyWith => _$SiteViewCopyWithImpl<SiteView>(this as SiteView, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SiteView&&(identical(other.site, site) || other.site == site)&&(identical(other.counts, counts) || other.counts == counts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,site,counts);

@override
String toString() {
  return 'SiteView(site: $site, counts: $counts)';
}


}

/// @nodoc
abstract mixin class $SiteViewCopyWith<$Res>  {
  factory $SiteViewCopyWith(SiteView value, $Res Function(SiteView) _then) = _$SiteViewCopyWithImpl;
@useResult
$Res call({
 Site site, SiteAggregates counts
});


$SiteCopyWith<$Res> get site;$SiteAggregatesCopyWith<$Res> get counts;

}
/// @nodoc
class _$SiteViewCopyWithImpl<$Res>
    implements $SiteViewCopyWith<$Res> {
  _$SiteViewCopyWithImpl(this._self, this._then);

  final SiteView _self;
  final $Res Function(SiteView) _then;

/// Create a copy of SiteView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? site = null,Object? counts = null,}) {
  return _then(_self.copyWith(
site: null == site ? _self.site : site // ignore: cast_nullable_to_non_nullable
as Site,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as SiteAggregates,
  ));
}
/// Create a copy of SiteView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SiteCopyWith<$Res> get site {
  
  return $SiteCopyWith<$Res>(_self.site, (value) {
    return _then(_self.copyWith(site: value));
  });
}/// Create a copy of SiteView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SiteAggregatesCopyWith<$Res> get counts {
  
  return $SiteAggregatesCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}


/// Adds pattern-matching-related methods to [SiteView].
extension SiteViewPatterns on SiteView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SiteView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SiteView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SiteView value)  $default,){
final _that = this;
switch (_that) {
case _SiteView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SiteView value)?  $default,){
final _that = this;
switch (_that) {
case _SiteView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Site site,  SiteAggregates counts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SiteView() when $default != null:
return $default(_that.site,_that.counts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Site site,  SiteAggregates counts)  $default,) {final _that = this;
switch (_that) {
case _SiteView():
return $default(_that.site,_that.counts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Site site,  SiteAggregates counts)?  $default,) {final _that = this;
switch (_that) {
case _SiteView() when $default != null:
return $default(_that.site,_that.counts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _SiteView implements SiteView {
  const _SiteView({required this.site, required this.counts});
  factory _SiteView.fromJson(Map<String, dynamic> json) => _$SiteViewFromJson(json);

@override final  Site site;
@override final  SiteAggregates counts;

/// Create a copy of SiteView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SiteViewCopyWith<_SiteView> get copyWith => __$SiteViewCopyWithImpl<_SiteView>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SiteView&&(identical(other.site, site) || other.site == site)&&(identical(other.counts, counts) || other.counts == counts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,site,counts);

@override
String toString() {
  return 'SiteView(site: $site, counts: $counts)';
}


}

/// @nodoc
abstract mixin class _$SiteViewCopyWith<$Res> implements $SiteViewCopyWith<$Res> {
  factory _$SiteViewCopyWith(_SiteView value, $Res Function(_SiteView) _then) = __$SiteViewCopyWithImpl;
@override @useResult
$Res call({
 Site site, SiteAggregates counts
});


@override $SiteCopyWith<$Res> get site;@override $SiteAggregatesCopyWith<$Res> get counts;

}
/// @nodoc
class __$SiteViewCopyWithImpl<$Res>
    implements _$SiteViewCopyWith<$Res> {
  __$SiteViewCopyWithImpl(this._self, this._then);

  final _SiteView _self;
  final $Res Function(_SiteView) _then;

/// Create a copy of SiteView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? site = null,Object? counts = null,}) {
  return _then(_SiteView(
site: null == site ? _self.site : site // ignore: cast_nullable_to_non_nullable
as Site,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as SiteAggregates,
  ));
}

/// Create a copy of SiteView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SiteCopyWith<$Res> get site {
  
  return $SiteCopyWith<$Res>(_self.site, (value) {
    return _then(_self.copyWith(site: value));
  });
}/// Create a copy of SiteView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SiteAggregatesCopyWith<$Res> get counts {
  
  return $SiteAggregatesCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}


/// @nodoc
mixin _$PersonView {

 Person get person; PersonAggregates get counts;@JsonKey(name: 'is_admin') bool get isAdmin;
/// Create a copy of PersonView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonViewCopyWith<PersonView> get copyWith => _$PersonViewCopyWithImpl<PersonView>(this as PersonView, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonView&&(identical(other.person, person) || other.person == person)&&(identical(other.counts, counts) || other.counts == counts)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,person,counts,isAdmin);

@override
String toString() {
  return 'PersonView(person: $person, counts: $counts, isAdmin: $isAdmin)';
}


}

/// @nodoc
abstract mixin class $PersonViewCopyWith<$Res>  {
  factory $PersonViewCopyWith(PersonView value, $Res Function(PersonView) _then) = _$PersonViewCopyWithImpl;
@useResult
$Res call({
 Person person, PersonAggregates counts,@JsonKey(name: 'is_admin') bool isAdmin
});


$PersonCopyWith<$Res> get person;$PersonAggregatesCopyWith<$Res> get counts;

}
/// @nodoc
class _$PersonViewCopyWithImpl<$Res>
    implements $PersonViewCopyWith<$Res> {
  _$PersonViewCopyWithImpl(this._self, this._then);

  final PersonView _self;
  final $Res Function(PersonView) _then;

/// Create a copy of PersonView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? person = null,Object? counts = null,Object? isAdmin = null,}) {
  return _then(_self.copyWith(
person: null == person ? _self.person : person // ignore: cast_nullable_to_non_nullable
as Person,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as PersonAggregates,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of PersonView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get person {
  
  return $PersonCopyWith<$Res>(_self.person, (value) {
    return _then(_self.copyWith(person: value));
  });
}/// Create a copy of PersonView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonAggregatesCopyWith<$Res> get counts {
  
  return $PersonAggregatesCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}


/// Adds pattern-matching-related methods to [PersonView].
extension PersonViewPatterns on PersonView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonView value)  $default,){
final _that = this;
switch (_that) {
case _PersonView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonView value)?  $default,){
final _that = this;
switch (_that) {
case _PersonView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Person person,  PersonAggregates counts, @JsonKey(name: 'is_admin')  bool isAdmin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonView() when $default != null:
return $default(_that.person,_that.counts,_that.isAdmin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Person person,  PersonAggregates counts, @JsonKey(name: 'is_admin')  bool isAdmin)  $default,) {final _that = this;
switch (_that) {
case _PersonView():
return $default(_that.person,_that.counts,_that.isAdmin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Person person,  PersonAggregates counts, @JsonKey(name: 'is_admin')  bool isAdmin)?  $default,) {final _that = this;
switch (_that) {
case _PersonView() when $default != null:
return $default(_that.person,_that.counts,_that.isAdmin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _PersonView implements PersonView {
  const _PersonView({required this.person, required this.counts, @JsonKey(name: 'is_admin') this.isAdmin = false});
  factory _PersonView.fromJson(Map<String, dynamic> json) => _$PersonViewFromJson(json);

@override final  Person person;
@override final  PersonAggregates counts;
@override@JsonKey(name: 'is_admin') final  bool isAdmin;

/// Create a copy of PersonView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonViewCopyWith<_PersonView> get copyWith => __$PersonViewCopyWithImpl<_PersonView>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonView&&(identical(other.person, person) || other.person == person)&&(identical(other.counts, counts) || other.counts == counts)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,person,counts,isAdmin);

@override
String toString() {
  return 'PersonView(person: $person, counts: $counts, isAdmin: $isAdmin)';
}


}

/// @nodoc
abstract mixin class _$PersonViewCopyWith<$Res> implements $PersonViewCopyWith<$Res> {
  factory _$PersonViewCopyWith(_PersonView value, $Res Function(_PersonView) _then) = __$PersonViewCopyWithImpl;
@override @useResult
$Res call({
 Person person, PersonAggregates counts,@JsonKey(name: 'is_admin') bool isAdmin
});


@override $PersonCopyWith<$Res> get person;@override $PersonAggregatesCopyWith<$Res> get counts;

}
/// @nodoc
class __$PersonViewCopyWithImpl<$Res>
    implements _$PersonViewCopyWith<$Res> {
  __$PersonViewCopyWithImpl(this._self, this._then);

  final _PersonView _self;
  final $Res Function(_PersonView) _then;

/// Create a copy of PersonView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? person = null,Object? counts = null,Object? isAdmin = null,}) {
  return _then(_PersonView(
person: null == person ? _self.person : person // ignore: cast_nullable_to_non_nullable
as Person,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as PersonAggregates,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of PersonView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get person {
  
  return $PersonCopyWith<$Res>(_self.person, (value) {
    return _then(_self.copyWith(person: value));
  });
}/// Create a copy of PersonView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonAggregatesCopyWith<$Res> get counts {
  
  return $PersonAggregatesCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}


/// @nodoc
mixin _$PersonAggregates {

@JsonKey(name: 'person_id', fromJson: _toInt) int get personId;@JsonKey(name: 'post_count', fromJson: _toInt) int get postCount;@JsonKey(name: 'comment_count', fromJson: _toInt) int get commentCount;
/// Create a copy of PersonAggregates
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonAggregatesCopyWith<PersonAggregates> get copyWith => _$PersonAggregatesCopyWithImpl<PersonAggregates>(this as PersonAggregates, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonAggregates&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.postCount, postCount) || other.postCount == postCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,personId,postCount,commentCount);

@override
String toString() {
  return 'PersonAggregates(personId: $personId, postCount: $postCount, commentCount: $commentCount)';
}


}

/// @nodoc
abstract mixin class $PersonAggregatesCopyWith<$Res>  {
  factory $PersonAggregatesCopyWith(PersonAggregates value, $Res Function(PersonAggregates) _then) = _$PersonAggregatesCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'person_id', fromJson: _toInt) int personId,@JsonKey(name: 'post_count', fromJson: _toInt) int postCount,@JsonKey(name: 'comment_count', fromJson: _toInt) int commentCount
});




}
/// @nodoc
class _$PersonAggregatesCopyWithImpl<$Res>
    implements $PersonAggregatesCopyWith<$Res> {
  _$PersonAggregatesCopyWithImpl(this._self, this._then);

  final PersonAggregates _self;
  final $Res Function(PersonAggregates) _then;

/// Create a copy of PersonAggregates
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? personId = null,Object? postCount = null,Object? commentCount = null,}) {
  return _then(_self.copyWith(
personId: null == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as int,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonAggregates].
extension PersonAggregatesPatterns on PersonAggregates {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonAggregates value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonAggregates() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonAggregates value)  $default,){
final _that = this;
switch (_that) {
case _PersonAggregates():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonAggregates value)?  $default,){
final _that = this;
switch (_that) {
case _PersonAggregates() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'person_id', fromJson: _toInt)  int personId, @JsonKey(name: 'post_count', fromJson: _toInt)  int postCount, @JsonKey(name: 'comment_count', fromJson: _toInt)  int commentCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonAggregates() when $default != null:
return $default(_that.personId,_that.postCount,_that.commentCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'person_id', fromJson: _toInt)  int personId, @JsonKey(name: 'post_count', fromJson: _toInt)  int postCount, @JsonKey(name: 'comment_count', fromJson: _toInt)  int commentCount)  $default,) {final _that = this;
switch (_that) {
case _PersonAggregates():
return $default(_that.personId,_that.postCount,_that.commentCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'person_id', fromJson: _toInt)  int personId, @JsonKey(name: 'post_count', fromJson: _toInt)  int postCount, @JsonKey(name: 'comment_count', fromJson: _toInt)  int commentCount)?  $default,) {final _that = this;
switch (_that) {
case _PersonAggregates() when $default != null:
return $default(_that.personId,_that.postCount,_that.commentCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _PersonAggregates implements PersonAggregates {
  const _PersonAggregates({@JsonKey(name: 'person_id', fromJson: _toInt) this.personId = 0, @JsonKey(name: 'post_count', fromJson: _toInt) this.postCount = 0, @JsonKey(name: 'comment_count', fromJson: _toInt) this.commentCount = 0});
  factory _PersonAggregates.fromJson(Map<String, dynamic> json) => _$PersonAggregatesFromJson(json);

@override@JsonKey(name: 'person_id', fromJson: _toInt) final  int personId;
@override@JsonKey(name: 'post_count', fromJson: _toInt) final  int postCount;
@override@JsonKey(name: 'comment_count', fromJson: _toInt) final  int commentCount;

/// Create a copy of PersonAggregates
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonAggregatesCopyWith<_PersonAggregates> get copyWith => __$PersonAggregatesCopyWithImpl<_PersonAggregates>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonAggregates&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.postCount, postCount) || other.postCount == postCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,personId,postCount,commentCount);

@override
String toString() {
  return 'PersonAggregates(personId: $personId, postCount: $postCount, commentCount: $commentCount)';
}


}

/// @nodoc
abstract mixin class _$PersonAggregatesCopyWith<$Res> implements $PersonAggregatesCopyWith<$Res> {
  factory _$PersonAggregatesCopyWith(_PersonAggregates value, $Res Function(_PersonAggregates) _then) = __$PersonAggregatesCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'person_id', fromJson: _toInt) int personId,@JsonKey(name: 'post_count', fromJson: _toInt) int postCount,@JsonKey(name: 'comment_count', fromJson: _toInt) int commentCount
});




}
/// @nodoc
class __$PersonAggregatesCopyWithImpl<$Res>
    implements _$PersonAggregatesCopyWith<$Res> {
  __$PersonAggregatesCopyWithImpl(this._self, this._then);

  final _PersonAggregates _self;
  final $Res Function(_PersonAggregates) _then;

/// Create a copy of PersonAggregates
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? personId = null,Object? postCount = null,Object? commentCount = null,}) {
  return _then(_PersonAggregates(
personId: null == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as int,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$GetSiteResponse {

@JsonKey(name: 'site_view') SiteView get siteView; List<dynamic> get admins; String get version;@JsonKey(name: 'my_user') MyUserInfo? get myUser;@JsonKey(name: 'all_languages') List<dynamic>? get allLanguages;@JsonKey(name: 'discussion_languages') List<dynamic>? get discussionLanguages; List<dynamic>? get taglines;@JsonKey(name: 'custom_emojis') List<dynamic>? get customEmojis;@JsonKey(name: 'blocked_urls') List<dynamic>? get blockedUrls;
/// Create a copy of GetSiteResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetSiteResponseCopyWith<GetSiteResponse> get copyWith => _$GetSiteResponseCopyWithImpl<GetSiteResponse>(this as GetSiteResponse, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetSiteResponse&&(identical(other.siteView, siteView) || other.siteView == siteView)&&const DeepCollectionEquality().equals(other.admins, admins)&&(identical(other.version, version) || other.version == version)&&(identical(other.myUser, myUser) || other.myUser == myUser)&&const DeepCollectionEquality().equals(other.allLanguages, allLanguages)&&const DeepCollectionEquality().equals(other.discussionLanguages, discussionLanguages)&&const DeepCollectionEquality().equals(other.taglines, taglines)&&const DeepCollectionEquality().equals(other.customEmojis, customEmojis)&&const DeepCollectionEquality().equals(other.blockedUrls, blockedUrls));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,siteView,const DeepCollectionEquality().hash(admins),version,myUser,const DeepCollectionEquality().hash(allLanguages),const DeepCollectionEquality().hash(discussionLanguages),const DeepCollectionEquality().hash(taglines),const DeepCollectionEquality().hash(customEmojis),const DeepCollectionEquality().hash(blockedUrls));

@override
String toString() {
  return 'GetSiteResponse(siteView: $siteView, admins: $admins, version: $version, myUser: $myUser, allLanguages: $allLanguages, discussionLanguages: $discussionLanguages, taglines: $taglines, customEmojis: $customEmojis, blockedUrls: $blockedUrls)';
}


}

/// @nodoc
abstract mixin class $GetSiteResponseCopyWith<$Res>  {
  factory $GetSiteResponseCopyWith(GetSiteResponse value, $Res Function(GetSiteResponse) _then) = _$GetSiteResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'site_view') SiteView siteView, List<dynamic> admins, String version,@JsonKey(name: 'my_user') MyUserInfo? myUser,@JsonKey(name: 'all_languages') List<dynamic>? allLanguages,@JsonKey(name: 'discussion_languages') List<dynamic>? discussionLanguages, List<dynamic>? taglines,@JsonKey(name: 'custom_emojis') List<dynamic>? customEmojis,@JsonKey(name: 'blocked_urls') List<dynamic>? blockedUrls
});


$SiteViewCopyWith<$Res> get siteView;$MyUserInfoCopyWith<$Res>? get myUser;

}
/// @nodoc
class _$GetSiteResponseCopyWithImpl<$Res>
    implements $GetSiteResponseCopyWith<$Res> {
  _$GetSiteResponseCopyWithImpl(this._self, this._then);

  final GetSiteResponse _self;
  final $Res Function(GetSiteResponse) _then;

/// Create a copy of GetSiteResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? siteView = null,Object? admins = null,Object? version = null,Object? myUser = freezed,Object? allLanguages = freezed,Object? discussionLanguages = freezed,Object? taglines = freezed,Object? customEmojis = freezed,Object? blockedUrls = freezed,}) {
  return _then(_self.copyWith(
siteView: null == siteView ? _self.siteView : siteView // ignore: cast_nullable_to_non_nullable
as SiteView,admins: null == admins ? _self.admins : admins // ignore: cast_nullable_to_non_nullable
as List<dynamic>,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,myUser: freezed == myUser ? _self.myUser : myUser // ignore: cast_nullable_to_non_nullable
as MyUserInfo?,allLanguages: freezed == allLanguages ? _self.allLanguages : allLanguages // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,discussionLanguages: freezed == discussionLanguages ? _self.discussionLanguages : discussionLanguages // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,taglines: freezed == taglines ? _self.taglines : taglines // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,customEmojis: freezed == customEmojis ? _self.customEmojis : customEmojis // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,blockedUrls: freezed == blockedUrls ? _self.blockedUrls : blockedUrls // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,
  ));
}
/// Create a copy of GetSiteResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SiteViewCopyWith<$Res> get siteView {
  
  return $SiteViewCopyWith<$Res>(_self.siteView, (value) {
    return _then(_self.copyWith(siteView: value));
  });
}/// Create a copy of GetSiteResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MyUserInfoCopyWith<$Res>? get myUser {
    if (_self.myUser == null) {
    return null;
  }

  return $MyUserInfoCopyWith<$Res>(_self.myUser!, (value) {
    return _then(_self.copyWith(myUser: value));
  });
}
}


/// Adds pattern-matching-related methods to [GetSiteResponse].
extension GetSiteResponsePatterns on GetSiteResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GetSiteResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetSiteResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GetSiteResponse value)  $default,){
final _that = this;
switch (_that) {
case _GetSiteResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GetSiteResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GetSiteResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'site_view')  SiteView siteView,  List<dynamic> admins,  String version, @JsonKey(name: 'my_user')  MyUserInfo? myUser, @JsonKey(name: 'all_languages')  List<dynamic>? allLanguages, @JsonKey(name: 'discussion_languages')  List<dynamic>? discussionLanguages,  List<dynamic>? taglines, @JsonKey(name: 'custom_emojis')  List<dynamic>? customEmojis, @JsonKey(name: 'blocked_urls')  List<dynamic>? blockedUrls)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GetSiteResponse() when $default != null:
return $default(_that.siteView,_that.admins,_that.version,_that.myUser,_that.allLanguages,_that.discussionLanguages,_that.taglines,_that.customEmojis,_that.blockedUrls);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'site_view')  SiteView siteView,  List<dynamic> admins,  String version, @JsonKey(name: 'my_user')  MyUserInfo? myUser, @JsonKey(name: 'all_languages')  List<dynamic>? allLanguages, @JsonKey(name: 'discussion_languages')  List<dynamic>? discussionLanguages,  List<dynamic>? taglines, @JsonKey(name: 'custom_emojis')  List<dynamic>? customEmojis, @JsonKey(name: 'blocked_urls')  List<dynamic>? blockedUrls)  $default,) {final _that = this;
switch (_that) {
case _GetSiteResponse():
return $default(_that.siteView,_that.admins,_that.version,_that.myUser,_that.allLanguages,_that.discussionLanguages,_that.taglines,_that.customEmojis,_that.blockedUrls);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'site_view')  SiteView siteView,  List<dynamic> admins,  String version, @JsonKey(name: 'my_user')  MyUserInfo? myUser, @JsonKey(name: 'all_languages')  List<dynamic>? allLanguages, @JsonKey(name: 'discussion_languages')  List<dynamic>? discussionLanguages,  List<dynamic>? taglines, @JsonKey(name: 'custom_emojis')  List<dynamic>? customEmojis, @JsonKey(name: 'blocked_urls')  List<dynamic>? blockedUrls)?  $default,) {final _that = this;
switch (_that) {
case _GetSiteResponse() when $default != null:
return $default(_that.siteView,_that.admins,_that.version,_that.myUser,_that.allLanguages,_that.discussionLanguages,_that.taglines,_that.customEmojis,_that.blockedUrls);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _GetSiteResponse implements GetSiteResponse {
  const _GetSiteResponse({@JsonKey(name: 'site_view') required this.siteView, final  List<dynamic> admins = const <dynamic>[], this.version = '', @JsonKey(name: 'my_user') this.myUser, @JsonKey(name: 'all_languages') final  List<dynamic>? allLanguages, @JsonKey(name: 'discussion_languages') final  List<dynamic>? discussionLanguages, final  List<dynamic>? taglines, @JsonKey(name: 'custom_emojis') final  List<dynamic>? customEmojis, @JsonKey(name: 'blocked_urls') final  List<dynamic>? blockedUrls}): _admins = admins,_allLanguages = allLanguages,_discussionLanguages = discussionLanguages,_taglines = taglines,_customEmojis = customEmojis,_blockedUrls = blockedUrls;
  factory _GetSiteResponse.fromJson(Map<String, dynamic> json) => _$GetSiteResponseFromJson(json);

@override@JsonKey(name: 'site_view') final  SiteView siteView;
 final  List<dynamic> _admins;
@override@JsonKey() List<dynamic> get admins {
  if (_admins is EqualUnmodifiableListView) return _admins;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_admins);
}

@override@JsonKey() final  String version;
@override@JsonKey(name: 'my_user') final  MyUserInfo? myUser;
 final  List<dynamic>? _allLanguages;
@override@JsonKey(name: 'all_languages') List<dynamic>? get allLanguages {
  final value = _allLanguages;
  if (value == null) return null;
  if (_allLanguages is EqualUnmodifiableListView) return _allLanguages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<dynamic>? _discussionLanguages;
@override@JsonKey(name: 'discussion_languages') List<dynamic>? get discussionLanguages {
  final value = _discussionLanguages;
  if (value == null) return null;
  if (_discussionLanguages is EqualUnmodifiableListView) return _discussionLanguages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<dynamic>? _taglines;
@override List<dynamic>? get taglines {
  final value = _taglines;
  if (value == null) return null;
  if (_taglines is EqualUnmodifiableListView) return _taglines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<dynamic>? _customEmojis;
@override@JsonKey(name: 'custom_emojis') List<dynamic>? get customEmojis {
  final value = _customEmojis;
  if (value == null) return null;
  if (_customEmojis is EqualUnmodifiableListView) return _customEmojis;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<dynamic>? _blockedUrls;
@override@JsonKey(name: 'blocked_urls') List<dynamic>? get blockedUrls {
  final value = _blockedUrls;
  if (value == null) return null;
  if (_blockedUrls is EqualUnmodifiableListView) return _blockedUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of GetSiteResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetSiteResponseCopyWith<_GetSiteResponse> get copyWith => __$GetSiteResponseCopyWithImpl<_GetSiteResponse>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetSiteResponse&&(identical(other.siteView, siteView) || other.siteView == siteView)&&const DeepCollectionEquality().equals(other._admins, _admins)&&(identical(other.version, version) || other.version == version)&&(identical(other.myUser, myUser) || other.myUser == myUser)&&const DeepCollectionEquality().equals(other._allLanguages, _allLanguages)&&const DeepCollectionEquality().equals(other._discussionLanguages, _discussionLanguages)&&const DeepCollectionEquality().equals(other._taglines, _taglines)&&const DeepCollectionEquality().equals(other._customEmojis, _customEmojis)&&const DeepCollectionEquality().equals(other._blockedUrls, _blockedUrls));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,siteView,const DeepCollectionEquality().hash(_admins),version,myUser,const DeepCollectionEquality().hash(_allLanguages),const DeepCollectionEquality().hash(_discussionLanguages),const DeepCollectionEquality().hash(_taglines),const DeepCollectionEquality().hash(_customEmojis),const DeepCollectionEquality().hash(_blockedUrls));

@override
String toString() {
  return 'GetSiteResponse(siteView: $siteView, admins: $admins, version: $version, myUser: $myUser, allLanguages: $allLanguages, discussionLanguages: $discussionLanguages, taglines: $taglines, customEmojis: $customEmojis, blockedUrls: $blockedUrls)';
}


}

/// @nodoc
abstract mixin class _$GetSiteResponseCopyWith<$Res> implements $GetSiteResponseCopyWith<$Res> {
  factory _$GetSiteResponseCopyWith(_GetSiteResponse value, $Res Function(_GetSiteResponse) _then) = __$GetSiteResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'site_view') SiteView siteView, List<dynamic> admins, String version,@JsonKey(name: 'my_user') MyUserInfo? myUser,@JsonKey(name: 'all_languages') List<dynamic>? allLanguages,@JsonKey(name: 'discussion_languages') List<dynamic>? discussionLanguages, List<dynamic>? taglines,@JsonKey(name: 'custom_emojis') List<dynamic>? customEmojis,@JsonKey(name: 'blocked_urls') List<dynamic>? blockedUrls
});


@override $SiteViewCopyWith<$Res> get siteView;@override $MyUserInfoCopyWith<$Res>? get myUser;

}
/// @nodoc
class __$GetSiteResponseCopyWithImpl<$Res>
    implements _$GetSiteResponseCopyWith<$Res> {
  __$GetSiteResponseCopyWithImpl(this._self, this._then);

  final _GetSiteResponse _self;
  final $Res Function(_GetSiteResponse) _then;

/// Create a copy of GetSiteResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? siteView = null,Object? admins = null,Object? version = null,Object? myUser = freezed,Object? allLanguages = freezed,Object? discussionLanguages = freezed,Object? taglines = freezed,Object? customEmojis = freezed,Object? blockedUrls = freezed,}) {
  return _then(_GetSiteResponse(
siteView: null == siteView ? _self.siteView : siteView // ignore: cast_nullable_to_non_nullable
as SiteView,admins: null == admins ? _self._admins : admins // ignore: cast_nullable_to_non_nullable
as List<dynamic>,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,myUser: freezed == myUser ? _self.myUser : myUser // ignore: cast_nullable_to_non_nullable
as MyUserInfo?,allLanguages: freezed == allLanguages ? _self._allLanguages : allLanguages // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,discussionLanguages: freezed == discussionLanguages ? _self._discussionLanguages : discussionLanguages // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,taglines: freezed == taglines ? _self._taglines : taglines // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,customEmojis: freezed == customEmojis ? _self._customEmojis : customEmojis // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,blockedUrls: freezed == blockedUrls ? _self._blockedUrls : blockedUrls // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,
  ));
}

/// Create a copy of GetSiteResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SiteViewCopyWith<$Res> get siteView {
  
  return $SiteViewCopyWith<$Res>(_self.siteView, (value) {
    return _then(_self.copyWith(siteView: value));
  });
}/// Create a copy of GetSiteResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MyUserInfoCopyWith<$Res>? get myUser {
    if (_self.myUser == null) {
    return null;
  }

  return $MyUserInfoCopyWith<$Res>(_self.myUser!, (value) {
    return _then(_self.copyWith(myUser: value));
  });
}
}


/// @nodoc
mixin _$MyUserInfo {

@JsonKey(name: 'local_user_view') LocalUserView get localUserView; List<dynamic> get follows; List<dynamic> get moderates;@JsonKey(name: 'community_blocks', fromJson: _toCommunityBlocks) List<CommunityBlockView> get communityBlocks;@JsonKey(name: 'instance_blocks', fromJson: _toInstanceBlocks) List<InstanceBlockView> get instanceBlocks;@JsonKey(name: 'person_blocks', fromJson: _toPersonBlocks) List<PersonBlockView> get personBlocks;@JsonKey(name: 'discussion_languages', fromJson: _toIntList) List<int> get discussionLanguages;
/// Create a copy of MyUserInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyUserInfoCopyWith<MyUserInfo> get copyWith => _$MyUserInfoCopyWithImpl<MyUserInfo>(this as MyUserInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyUserInfo&&(identical(other.localUserView, localUserView) || other.localUserView == localUserView)&&const DeepCollectionEquality().equals(other.follows, follows)&&const DeepCollectionEquality().equals(other.moderates, moderates)&&const DeepCollectionEquality().equals(other.communityBlocks, communityBlocks)&&const DeepCollectionEquality().equals(other.instanceBlocks, instanceBlocks)&&const DeepCollectionEquality().equals(other.personBlocks, personBlocks)&&const DeepCollectionEquality().equals(other.discussionLanguages, discussionLanguages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,localUserView,const DeepCollectionEquality().hash(follows),const DeepCollectionEquality().hash(moderates),const DeepCollectionEquality().hash(communityBlocks),const DeepCollectionEquality().hash(instanceBlocks),const DeepCollectionEquality().hash(personBlocks),const DeepCollectionEquality().hash(discussionLanguages));

@override
String toString() {
  return 'MyUserInfo(localUserView: $localUserView, follows: $follows, moderates: $moderates, communityBlocks: $communityBlocks, instanceBlocks: $instanceBlocks, personBlocks: $personBlocks, discussionLanguages: $discussionLanguages)';
}


}

/// @nodoc
abstract mixin class $MyUserInfoCopyWith<$Res>  {
  factory $MyUserInfoCopyWith(MyUserInfo value, $Res Function(MyUserInfo) _then) = _$MyUserInfoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'local_user_view') LocalUserView localUserView, List<dynamic> follows, List<dynamic> moderates,@JsonKey(name: 'community_blocks', fromJson: _toCommunityBlocks) List<CommunityBlockView> communityBlocks,@JsonKey(name: 'instance_blocks', fromJson: _toInstanceBlocks) List<InstanceBlockView> instanceBlocks,@JsonKey(name: 'person_blocks', fromJson: _toPersonBlocks) List<PersonBlockView> personBlocks,@JsonKey(name: 'discussion_languages', fromJson: _toIntList) List<int> discussionLanguages
});


$LocalUserViewCopyWith<$Res> get localUserView;

}
/// @nodoc
class _$MyUserInfoCopyWithImpl<$Res>
    implements $MyUserInfoCopyWith<$Res> {
  _$MyUserInfoCopyWithImpl(this._self, this._then);

  final MyUserInfo _self;
  final $Res Function(MyUserInfo) _then;

/// Create a copy of MyUserInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? localUserView = null,Object? follows = null,Object? moderates = null,Object? communityBlocks = null,Object? instanceBlocks = null,Object? personBlocks = null,Object? discussionLanguages = null,}) {
  return _then(_self.copyWith(
localUserView: null == localUserView ? _self.localUserView : localUserView // ignore: cast_nullable_to_non_nullable
as LocalUserView,follows: null == follows ? _self.follows : follows // ignore: cast_nullable_to_non_nullable
as List<dynamic>,moderates: null == moderates ? _self.moderates : moderates // ignore: cast_nullable_to_non_nullable
as List<dynamic>,communityBlocks: null == communityBlocks ? _self.communityBlocks : communityBlocks // ignore: cast_nullable_to_non_nullable
as List<CommunityBlockView>,instanceBlocks: null == instanceBlocks ? _self.instanceBlocks : instanceBlocks // ignore: cast_nullable_to_non_nullable
as List<InstanceBlockView>,personBlocks: null == personBlocks ? _self.personBlocks : personBlocks // ignore: cast_nullable_to_non_nullable
as List<PersonBlockView>,discussionLanguages: null == discussionLanguages ? _self.discussionLanguages : discussionLanguages // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}
/// Create a copy of MyUserInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalUserViewCopyWith<$Res> get localUserView {
  
  return $LocalUserViewCopyWith<$Res>(_self.localUserView, (value) {
    return _then(_self.copyWith(localUserView: value));
  });
}
}


/// Adds pattern-matching-related methods to [MyUserInfo].
extension MyUserInfoPatterns on MyUserInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyUserInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyUserInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyUserInfo value)  $default,){
final _that = this;
switch (_that) {
case _MyUserInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyUserInfo value)?  $default,){
final _that = this;
switch (_that) {
case _MyUserInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'local_user_view')  LocalUserView localUserView,  List<dynamic> follows,  List<dynamic> moderates, @JsonKey(name: 'community_blocks', fromJson: _toCommunityBlocks)  List<CommunityBlockView> communityBlocks, @JsonKey(name: 'instance_blocks', fromJson: _toInstanceBlocks)  List<InstanceBlockView> instanceBlocks, @JsonKey(name: 'person_blocks', fromJson: _toPersonBlocks)  List<PersonBlockView> personBlocks, @JsonKey(name: 'discussion_languages', fromJson: _toIntList)  List<int> discussionLanguages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyUserInfo() when $default != null:
return $default(_that.localUserView,_that.follows,_that.moderates,_that.communityBlocks,_that.instanceBlocks,_that.personBlocks,_that.discussionLanguages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'local_user_view')  LocalUserView localUserView,  List<dynamic> follows,  List<dynamic> moderates, @JsonKey(name: 'community_blocks', fromJson: _toCommunityBlocks)  List<CommunityBlockView> communityBlocks, @JsonKey(name: 'instance_blocks', fromJson: _toInstanceBlocks)  List<InstanceBlockView> instanceBlocks, @JsonKey(name: 'person_blocks', fromJson: _toPersonBlocks)  List<PersonBlockView> personBlocks, @JsonKey(name: 'discussion_languages', fromJson: _toIntList)  List<int> discussionLanguages)  $default,) {final _that = this;
switch (_that) {
case _MyUserInfo():
return $default(_that.localUserView,_that.follows,_that.moderates,_that.communityBlocks,_that.instanceBlocks,_that.personBlocks,_that.discussionLanguages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'local_user_view')  LocalUserView localUserView,  List<dynamic> follows,  List<dynamic> moderates, @JsonKey(name: 'community_blocks', fromJson: _toCommunityBlocks)  List<CommunityBlockView> communityBlocks, @JsonKey(name: 'instance_blocks', fromJson: _toInstanceBlocks)  List<InstanceBlockView> instanceBlocks, @JsonKey(name: 'person_blocks', fromJson: _toPersonBlocks)  List<PersonBlockView> personBlocks, @JsonKey(name: 'discussion_languages', fromJson: _toIntList)  List<int> discussionLanguages)?  $default,) {final _that = this;
switch (_that) {
case _MyUserInfo() when $default != null:
return $default(_that.localUserView,_that.follows,_that.moderates,_that.communityBlocks,_that.instanceBlocks,_that.personBlocks,_that.discussionLanguages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _MyUserInfo extends MyUserInfo {
  const _MyUserInfo({@JsonKey(name: 'local_user_view') required this.localUserView, final  List<dynamic> follows = const <dynamic>[], final  List<dynamic> moderates = const <dynamic>[], @JsonKey(name: 'community_blocks', fromJson: _toCommunityBlocks) final  List<CommunityBlockView> communityBlocks = const <CommunityBlockView>[], @JsonKey(name: 'instance_blocks', fromJson: _toInstanceBlocks) final  List<InstanceBlockView> instanceBlocks = const <InstanceBlockView>[], @JsonKey(name: 'person_blocks', fromJson: _toPersonBlocks) final  List<PersonBlockView> personBlocks = const <PersonBlockView>[], @JsonKey(name: 'discussion_languages', fromJson: _toIntList) final  List<int> discussionLanguages = const <int>[]}): _follows = follows,_moderates = moderates,_communityBlocks = communityBlocks,_instanceBlocks = instanceBlocks,_personBlocks = personBlocks,_discussionLanguages = discussionLanguages,super._();
  factory _MyUserInfo.fromJson(Map<String, dynamic> json) => _$MyUserInfoFromJson(json);

@override@JsonKey(name: 'local_user_view') final  LocalUserView localUserView;
 final  List<dynamic> _follows;
@override@JsonKey() List<dynamic> get follows {
  if (_follows is EqualUnmodifiableListView) return _follows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_follows);
}

 final  List<dynamic> _moderates;
@override@JsonKey() List<dynamic> get moderates {
  if (_moderates is EqualUnmodifiableListView) return _moderates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_moderates);
}

 final  List<CommunityBlockView> _communityBlocks;
@override@JsonKey(name: 'community_blocks', fromJson: _toCommunityBlocks) List<CommunityBlockView> get communityBlocks {
  if (_communityBlocks is EqualUnmodifiableListView) return _communityBlocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_communityBlocks);
}

 final  List<InstanceBlockView> _instanceBlocks;
@override@JsonKey(name: 'instance_blocks', fromJson: _toInstanceBlocks) List<InstanceBlockView> get instanceBlocks {
  if (_instanceBlocks is EqualUnmodifiableListView) return _instanceBlocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_instanceBlocks);
}

 final  List<PersonBlockView> _personBlocks;
@override@JsonKey(name: 'person_blocks', fromJson: _toPersonBlocks) List<PersonBlockView> get personBlocks {
  if (_personBlocks is EqualUnmodifiableListView) return _personBlocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_personBlocks);
}

 final  List<int> _discussionLanguages;
@override@JsonKey(name: 'discussion_languages', fromJson: _toIntList) List<int> get discussionLanguages {
  if (_discussionLanguages is EqualUnmodifiableListView) return _discussionLanguages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_discussionLanguages);
}


/// Create a copy of MyUserInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyUserInfoCopyWith<_MyUserInfo> get copyWith => __$MyUserInfoCopyWithImpl<_MyUserInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyUserInfo&&(identical(other.localUserView, localUserView) || other.localUserView == localUserView)&&const DeepCollectionEquality().equals(other._follows, _follows)&&const DeepCollectionEquality().equals(other._moderates, _moderates)&&const DeepCollectionEquality().equals(other._communityBlocks, _communityBlocks)&&const DeepCollectionEquality().equals(other._instanceBlocks, _instanceBlocks)&&const DeepCollectionEquality().equals(other._personBlocks, _personBlocks)&&const DeepCollectionEquality().equals(other._discussionLanguages, _discussionLanguages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,localUserView,const DeepCollectionEquality().hash(_follows),const DeepCollectionEquality().hash(_moderates),const DeepCollectionEquality().hash(_communityBlocks),const DeepCollectionEquality().hash(_instanceBlocks),const DeepCollectionEquality().hash(_personBlocks),const DeepCollectionEquality().hash(_discussionLanguages));

@override
String toString() {
  return 'MyUserInfo(localUserView: $localUserView, follows: $follows, moderates: $moderates, communityBlocks: $communityBlocks, instanceBlocks: $instanceBlocks, personBlocks: $personBlocks, discussionLanguages: $discussionLanguages)';
}


}

/// @nodoc
abstract mixin class _$MyUserInfoCopyWith<$Res> implements $MyUserInfoCopyWith<$Res> {
  factory _$MyUserInfoCopyWith(_MyUserInfo value, $Res Function(_MyUserInfo) _then) = __$MyUserInfoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'local_user_view') LocalUserView localUserView, List<dynamic> follows, List<dynamic> moderates,@JsonKey(name: 'community_blocks', fromJson: _toCommunityBlocks) List<CommunityBlockView> communityBlocks,@JsonKey(name: 'instance_blocks', fromJson: _toInstanceBlocks) List<InstanceBlockView> instanceBlocks,@JsonKey(name: 'person_blocks', fromJson: _toPersonBlocks) List<PersonBlockView> personBlocks,@JsonKey(name: 'discussion_languages', fromJson: _toIntList) List<int> discussionLanguages
});


@override $LocalUserViewCopyWith<$Res> get localUserView;

}
/// @nodoc
class __$MyUserInfoCopyWithImpl<$Res>
    implements _$MyUserInfoCopyWith<$Res> {
  __$MyUserInfoCopyWithImpl(this._self, this._then);

  final _MyUserInfo _self;
  final $Res Function(_MyUserInfo) _then;

/// Create a copy of MyUserInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? localUserView = null,Object? follows = null,Object? moderates = null,Object? communityBlocks = null,Object? instanceBlocks = null,Object? personBlocks = null,Object? discussionLanguages = null,}) {
  return _then(_MyUserInfo(
localUserView: null == localUserView ? _self.localUserView : localUserView // ignore: cast_nullable_to_non_nullable
as LocalUserView,follows: null == follows ? _self._follows : follows // ignore: cast_nullable_to_non_nullable
as List<dynamic>,moderates: null == moderates ? _self._moderates : moderates // ignore: cast_nullable_to_non_nullable
as List<dynamic>,communityBlocks: null == communityBlocks ? _self._communityBlocks : communityBlocks // ignore: cast_nullable_to_non_nullable
as List<CommunityBlockView>,instanceBlocks: null == instanceBlocks ? _self._instanceBlocks : instanceBlocks // ignore: cast_nullable_to_non_nullable
as List<InstanceBlockView>,personBlocks: null == personBlocks ? _self._personBlocks : personBlocks // ignore: cast_nullable_to_non_nullable
as List<PersonBlockView>,discussionLanguages: null == discussionLanguages ? _self._discussionLanguages : discussionLanguages // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

/// Create a copy of MyUserInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalUserViewCopyWith<$Res> get localUserView {
  
  return $LocalUserViewCopyWith<$Res>(_self.localUserView, (value) {
    return _then(_self.copyWith(localUserView: value));
  });
}
}


/// @nodoc
mixin _$LocalUserView {

@JsonKey(name: 'local_user') LocalUser get localUser; Person get person; PersonAggregates get counts;
/// Create a copy of LocalUserView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalUserViewCopyWith<LocalUserView> get copyWith => _$LocalUserViewCopyWithImpl<LocalUserView>(this as LocalUserView, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalUserView&&(identical(other.localUser, localUser) || other.localUser == localUser)&&(identical(other.person, person) || other.person == person)&&(identical(other.counts, counts) || other.counts == counts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,localUser,person,counts);

@override
String toString() {
  return 'LocalUserView(localUser: $localUser, person: $person, counts: $counts)';
}


}

/// @nodoc
abstract mixin class $LocalUserViewCopyWith<$Res>  {
  factory $LocalUserViewCopyWith(LocalUserView value, $Res Function(LocalUserView) _then) = _$LocalUserViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'local_user') LocalUser localUser, Person person, PersonAggregates counts
});


$LocalUserCopyWith<$Res> get localUser;$PersonCopyWith<$Res> get person;$PersonAggregatesCopyWith<$Res> get counts;

}
/// @nodoc
class _$LocalUserViewCopyWithImpl<$Res>
    implements $LocalUserViewCopyWith<$Res> {
  _$LocalUserViewCopyWithImpl(this._self, this._then);

  final LocalUserView _self;
  final $Res Function(LocalUserView) _then;

/// Create a copy of LocalUserView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? localUser = null,Object? person = null,Object? counts = null,}) {
  return _then(_self.copyWith(
localUser: null == localUser ? _self.localUser : localUser // ignore: cast_nullable_to_non_nullable
as LocalUser,person: null == person ? _self.person : person // ignore: cast_nullable_to_non_nullable
as Person,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as PersonAggregates,
  ));
}
/// Create a copy of LocalUserView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalUserCopyWith<$Res> get localUser {
  
  return $LocalUserCopyWith<$Res>(_self.localUser, (value) {
    return _then(_self.copyWith(localUser: value));
  });
}/// Create a copy of LocalUserView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get person {
  
  return $PersonCopyWith<$Res>(_self.person, (value) {
    return _then(_self.copyWith(person: value));
  });
}/// Create a copy of LocalUserView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonAggregatesCopyWith<$Res> get counts {
  
  return $PersonAggregatesCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}


/// Adds pattern-matching-related methods to [LocalUserView].
extension LocalUserViewPatterns on LocalUserView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalUserView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalUserView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalUserView value)  $default,){
final _that = this;
switch (_that) {
case _LocalUserView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalUserView value)?  $default,){
final _that = this;
switch (_that) {
case _LocalUserView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'local_user')  LocalUser localUser,  Person person,  PersonAggregates counts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalUserView() when $default != null:
return $default(_that.localUser,_that.person,_that.counts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'local_user')  LocalUser localUser,  Person person,  PersonAggregates counts)  $default,) {final _that = this;
switch (_that) {
case _LocalUserView():
return $default(_that.localUser,_that.person,_that.counts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'local_user')  LocalUser localUser,  Person person,  PersonAggregates counts)?  $default,) {final _that = this;
switch (_that) {
case _LocalUserView() when $default != null:
return $default(_that.localUser,_that.person,_that.counts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _LocalUserView implements LocalUserView {
  const _LocalUserView({@JsonKey(name: 'local_user') required this.localUser, required this.person, required this.counts});
  factory _LocalUserView.fromJson(Map<String, dynamic> json) => _$LocalUserViewFromJson(json);

@override@JsonKey(name: 'local_user') final  LocalUser localUser;
@override final  Person person;
@override final  PersonAggregates counts;

/// Create a copy of LocalUserView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalUserViewCopyWith<_LocalUserView> get copyWith => __$LocalUserViewCopyWithImpl<_LocalUserView>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalUserView&&(identical(other.localUser, localUser) || other.localUser == localUser)&&(identical(other.person, person) || other.person == person)&&(identical(other.counts, counts) || other.counts == counts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,localUser,person,counts);

@override
String toString() {
  return 'LocalUserView(localUser: $localUser, person: $person, counts: $counts)';
}


}

/// @nodoc
abstract mixin class _$LocalUserViewCopyWith<$Res> implements $LocalUserViewCopyWith<$Res> {
  factory _$LocalUserViewCopyWith(_LocalUserView value, $Res Function(_LocalUserView) _then) = __$LocalUserViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'local_user') LocalUser localUser, Person person, PersonAggregates counts
});


@override $LocalUserCopyWith<$Res> get localUser;@override $PersonCopyWith<$Res> get person;@override $PersonAggregatesCopyWith<$Res> get counts;

}
/// @nodoc
class __$LocalUserViewCopyWithImpl<$Res>
    implements _$LocalUserViewCopyWith<$Res> {
  __$LocalUserViewCopyWithImpl(this._self, this._then);

  final _LocalUserView _self;
  final $Res Function(_LocalUserView) _then;

/// Create a copy of LocalUserView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? localUser = null,Object? person = null,Object? counts = null,}) {
  return _then(_LocalUserView(
localUser: null == localUser ? _self.localUser : localUser // ignore: cast_nullable_to_non_nullable
as LocalUser,person: null == person ? _self.person : person // ignore: cast_nullable_to_non_nullable
as Person,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as PersonAggregates,
  ));
}

/// Create a copy of LocalUserView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalUserCopyWith<$Res> get localUser {
  
  return $LocalUserCopyWith<$Res>(_self.localUser, (value) {
    return _then(_self.copyWith(localUser: value));
  });
}/// Create a copy of LocalUserView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get person {
  
  return $PersonCopyWith<$Res>(_self.person, (value) {
    return _then(_self.copyWith(person: value));
  });
}/// Create a copy of LocalUserView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonAggregatesCopyWith<$Res> get counts {
  
  return $PersonAggregatesCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}


/// @nodoc
mixin _$LocalUser {

@JsonKey(fromJson: _toInt) int get id;@JsonKey(name: 'person_id', fromJson: _toInt) int get personId; String? get email;@JsonKey(name: 'show_nsfw') bool get showNsfw; String? get theme;// Preserves legacy parse: missing values become 0 via _toInt.
@JsonKey(name: 'default_sort_type', fromJson: _toInt) int? get defaultSortType;@JsonKey(name: 'default_listing_type', fromJson: _toInt) int? get defaultListingType;@JsonKey(name: 'interface_language') String? get interfaceLanguage;@JsonKey(name: 'show_avatars') bool get showAvatars;@JsonKey(name: 'send_notifications_to_email') bool get sendNotificationsToEmail;@JsonKey(name: 'show_scores') bool get showScores;@JsonKey(name: 'show_bot_accounts') bool get showBotAccounts;@JsonKey(name: 'show_read_posts') bool get showReadPosts;@JsonKey(name: 'email_verified') bool get emailVerified;@JsonKey(name: 'accepted_application') bool get acceptedApplication;@JsonKey(name: 'open_links_in_new_tab') bool get openLinksInNewTab;@JsonKey(name: 'blur_nsfw') bool get blurNsfw;@JsonKey(name: 'auto_expand') bool get autoExpand;@JsonKey(name: 'infinite_scroll_enabled') bool get infiniteScrollEnabled; bool get admin;@JsonKey(name: 'post_listing_mode', fromJson: _toInt) int? get postListingMode;@JsonKey(name: 'totp_2fa_enabled') bool get totp2faEnabled;@JsonKey(name: 'enable_keyboard_navigation') bool get enableKeyboardNavigation;@JsonKey(name: 'enable_animated_images') bool get enableAnimatedImages;@JsonKey(name: 'collapse_bot_comments') bool get collapseBotComments;
/// Create a copy of LocalUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalUserCopyWith<LocalUser> get copyWith => _$LocalUserCopyWithImpl<LocalUser>(this as LocalUser, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalUser&&(identical(other.id, id) || other.id == id)&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.email, email) || other.email == email)&&(identical(other.showNsfw, showNsfw) || other.showNsfw == showNsfw)&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.defaultSortType, defaultSortType) || other.defaultSortType == defaultSortType)&&(identical(other.defaultListingType, defaultListingType) || other.defaultListingType == defaultListingType)&&(identical(other.interfaceLanguage, interfaceLanguage) || other.interfaceLanguage == interfaceLanguage)&&(identical(other.showAvatars, showAvatars) || other.showAvatars == showAvatars)&&(identical(other.sendNotificationsToEmail, sendNotificationsToEmail) || other.sendNotificationsToEmail == sendNotificationsToEmail)&&(identical(other.showScores, showScores) || other.showScores == showScores)&&(identical(other.showBotAccounts, showBotAccounts) || other.showBotAccounts == showBotAccounts)&&(identical(other.showReadPosts, showReadPosts) || other.showReadPosts == showReadPosts)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.acceptedApplication, acceptedApplication) || other.acceptedApplication == acceptedApplication)&&(identical(other.openLinksInNewTab, openLinksInNewTab) || other.openLinksInNewTab == openLinksInNewTab)&&(identical(other.blurNsfw, blurNsfw) || other.blurNsfw == blurNsfw)&&(identical(other.autoExpand, autoExpand) || other.autoExpand == autoExpand)&&(identical(other.infiniteScrollEnabled, infiniteScrollEnabled) || other.infiniteScrollEnabled == infiniteScrollEnabled)&&(identical(other.admin, admin) || other.admin == admin)&&(identical(other.postListingMode, postListingMode) || other.postListingMode == postListingMode)&&(identical(other.totp2faEnabled, totp2faEnabled) || other.totp2faEnabled == totp2faEnabled)&&(identical(other.enableKeyboardNavigation, enableKeyboardNavigation) || other.enableKeyboardNavigation == enableKeyboardNavigation)&&(identical(other.enableAnimatedImages, enableAnimatedImages) || other.enableAnimatedImages == enableAnimatedImages)&&(identical(other.collapseBotComments, collapseBotComments) || other.collapseBotComments == collapseBotComments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,personId,email,showNsfw,theme,defaultSortType,defaultListingType,interfaceLanguage,showAvatars,sendNotificationsToEmail,showScores,showBotAccounts,showReadPosts,emailVerified,acceptedApplication,openLinksInNewTab,blurNsfw,autoExpand,infiniteScrollEnabled,admin,postListingMode,totp2faEnabled,enableKeyboardNavigation,enableAnimatedImages,collapseBotComments]);

@override
String toString() {
  return 'LocalUser(id: $id, personId: $personId, email: $email, showNsfw: $showNsfw, theme: $theme, defaultSortType: $defaultSortType, defaultListingType: $defaultListingType, interfaceLanguage: $interfaceLanguage, showAvatars: $showAvatars, sendNotificationsToEmail: $sendNotificationsToEmail, showScores: $showScores, showBotAccounts: $showBotAccounts, showReadPosts: $showReadPosts, emailVerified: $emailVerified, acceptedApplication: $acceptedApplication, openLinksInNewTab: $openLinksInNewTab, blurNsfw: $blurNsfw, autoExpand: $autoExpand, infiniteScrollEnabled: $infiniteScrollEnabled, admin: $admin, postListingMode: $postListingMode, totp2faEnabled: $totp2faEnabled, enableKeyboardNavigation: $enableKeyboardNavigation, enableAnimatedImages: $enableAnimatedImages, collapseBotComments: $collapseBotComments)';
}


}

/// @nodoc
abstract mixin class $LocalUserCopyWith<$Res>  {
  factory $LocalUserCopyWith(LocalUser value, $Res Function(LocalUser) _then) = _$LocalUserCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _toInt) int id,@JsonKey(name: 'person_id', fromJson: _toInt) int personId, String? email,@JsonKey(name: 'show_nsfw') bool showNsfw, String? theme,@JsonKey(name: 'default_sort_type', fromJson: _toInt) int? defaultSortType,@JsonKey(name: 'default_listing_type', fromJson: _toInt) int? defaultListingType,@JsonKey(name: 'interface_language') String? interfaceLanguage,@JsonKey(name: 'show_avatars') bool showAvatars,@JsonKey(name: 'send_notifications_to_email') bool sendNotificationsToEmail,@JsonKey(name: 'show_scores') bool showScores,@JsonKey(name: 'show_bot_accounts') bool showBotAccounts,@JsonKey(name: 'show_read_posts') bool showReadPosts,@JsonKey(name: 'email_verified') bool emailVerified,@JsonKey(name: 'accepted_application') bool acceptedApplication,@JsonKey(name: 'open_links_in_new_tab') bool openLinksInNewTab,@JsonKey(name: 'blur_nsfw') bool blurNsfw,@JsonKey(name: 'auto_expand') bool autoExpand,@JsonKey(name: 'infinite_scroll_enabled') bool infiniteScrollEnabled, bool admin,@JsonKey(name: 'post_listing_mode', fromJson: _toInt) int? postListingMode,@JsonKey(name: 'totp_2fa_enabled') bool totp2faEnabled,@JsonKey(name: 'enable_keyboard_navigation') bool enableKeyboardNavigation,@JsonKey(name: 'enable_animated_images') bool enableAnimatedImages,@JsonKey(name: 'collapse_bot_comments') bool collapseBotComments
});




}
/// @nodoc
class _$LocalUserCopyWithImpl<$Res>
    implements $LocalUserCopyWith<$Res> {
  _$LocalUserCopyWithImpl(this._self, this._then);

  final LocalUser _self;
  final $Res Function(LocalUser) _then;

/// Create a copy of LocalUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? personId = null,Object? email = freezed,Object? showNsfw = null,Object? theme = freezed,Object? defaultSortType = freezed,Object? defaultListingType = freezed,Object? interfaceLanguage = freezed,Object? showAvatars = null,Object? sendNotificationsToEmail = null,Object? showScores = null,Object? showBotAccounts = null,Object? showReadPosts = null,Object? emailVerified = null,Object? acceptedApplication = null,Object? openLinksInNewTab = null,Object? blurNsfw = null,Object? autoExpand = null,Object? infiniteScrollEnabled = null,Object? admin = null,Object? postListingMode = freezed,Object? totp2faEnabled = null,Object? enableKeyboardNavigation = null,Object? enableAnimatedImages = null,Object? collapseBotComments = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,personId: null == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as int,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,showNsfw: null == showNsfw ? _self.showNsfw : showNsfw // ignore: cast_nullable_to_non_nullable
as bool,theme: freezed == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String?,defaultSortType: freezed == defaultSortType ? _self.defaultSortType : defaultSortType // ignore: cast_nullable_to_non_nullable
as int?,defaultListingType: freezed == defaultListingType ? _self.defaultListingType : defaultListingType // ignore: cast_nullable_to_non_nullable
as int?,interfaceLanguage: freezed == interfaceLanguage ? _self.interfaceLanguage : interfaceLanguage // ignore: cast_nullable_to_non_nullable
as String?,showAvatars: null == showAvatars ? _self.showAvatars : showAvatars // ignore: cast_nullable_to_non_nullable
as bool,sendNotificationsToEmail: null == sendNotificationsToEmail ? _self.sendNotificationsToEmail : sendNotificationsToEmail // ignore: cast_nullable_to_non_nullable
as bool,showScores: null == showScores ? _self.showScores : showScores // ignore: cast_nullable_to_non_nullable
as bool,showBotAccounts: null == showBotAccounts ? _self.showBotAccounts : showBotAccounts // ignore: cast_nullable_to_non_nullable
as bool,showReadPosts: null == showReadPosts ? _self.showReadPosts : showReadPosts // ignore: cast_nullable_to_non_nullable
as bool,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,acceptedApplication: null == acceptedApplication ? _self.acceptedApplication : acceptedApplication // ignore: cast_nullable_to_non_nullable
as bool,openLinksInNewTab: null == openLinksInNewTab ? _self.openLinksInNewTab : openLinksInNewTab // ignore: cast_nullable_to_non_nullable
as bool,blurNsfw: null == blurNsfw ? _self.blurNsfw : blurNsfw // ignore: cast_nullable_to_non_nullable
as bool,autoExpand: null == autoExpand ? _self.autoExpand : autoExpand // ignore: cast_nullable_to_non_nullable
as bool,infiniteScrollEnabled: null == infiniteScrollEnabled ? _self.infiniteScrollEnabled : infiniteScrollEnabled // ignore: cast_nullable_to_non_nullable
as bool,admin: null == admin ? _self.admin : admin // ignore: cast_nullable_to_non_nullable
as bool,postListingMode: freezed == postListingMode ? _self.postListingMode : postListingMode // ignore: cast_nullable_to_non_nullable
as int?,totp2faEnabled: null == totp2faEnabled ? _self.totp2faEnabled : totp2faEnabled // ignore: cast_nullable_to_non_nullable
as bool,enableKeyboardNavigation: null == enableKeyboardNavigation ? _self.enableKeyboardNavigation : enableKeyboardNavigation // ignore: cast_nullable_to_non_nullable
as bool,enableAnimatedImages: null == enableAnimatedImages ? _self.enableAnimatedImages : enableAnimatedImages // ignore: cast_nullable_to_non_nullable
as bool,collapseBotComments: null == collapseBotComments ? _self.collapseBotComments : collapseBotComments // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LocalUser].
extension LocalUserPatterns on LocalUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalUser value)  $default,){
final _that = this;
switch (_that) {
case _LocalUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalUser value)?  $default,){
final _that = this;
switch (_that) {
case _LocalUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int id, @JsonKey(name: 'person_id', fromJson: _toInt)  int personId,  String? email, @JsonKey(name: 'show_nsfw')  bool showNsfw,  String? theme, @JsonKey(name: 'default_sort_type', fromJson: _toInt)  int? defaultSortType, @JsonKey(name: 'default_listing_type', fromJson: _toInt)  int? defaultListingType, @JsonKey(name: 'interface_language')  String? interfaceLanguage, @JsonKey(name: 'show_avatars')  bool showAvatars, @JsonKey(name: 'send_notifications_to_email')  bool sendNotificationsToEmail, @JsonKey(name: 'show_scores')  bool showScores, @JsonKey(name: 'show_bot_accounts')  bool showBotAccounts, @JsonKey(name: 'show_read_posts')  bool showReadPosts, @JsonKey(name: 'email_verified')  bool emailVerified, @JsonKey(name: 'accepted_application')  bool acceptedApplication, @JsonKey(name: 'open_links_in_new_tab')  bool openLinksInNewTab, @JsonKey(name: 'blur_nsfw')  bool blurNsfw, @JsonKey(name: 'auto_expand')  bool autoExpand, @JsonKey(name: 'infinite_scroll_enabled')  bool infiniteScrollEnabled,  bool admin, @JsonKey(name: 'post_listing_mode', fromJson: _toInt)  int? postListingMode, @JsonKey(name: 'totp_2fa_enabled')  bool totp2faEnabled, @JsonKey(name: 'enable_keyboard_navigation')  bool enableKeyboardNavigation, @JsonKey(name: 'enable_animated_images')  bool enableAnimatedImages, @JsonKey(name: 'collapse_bot_comments')  bool collapseBotComments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalUser() when $default != null:
return $default(_that.id,_that.personId,_that.email,_that.showNsfw,_that.theme,_that.defaultSortType,_that.defaultListingType,_that.interfaceLanguage,_that.showAvatars,_that.sendNotificationsToEmail,_that.showScores,_that.showBotAccounts,_that.showReadPosts,_that.emailVerified,_that.acceptedApplication,_that.openLinksInNewTab,_that.blurNsfw,_that.autoExpand,_that.infiniteScrollEnabled,_that.admin,_that.postListingMode,_that.totp2faEnabled,_that.enableKeyboardNavigation,_that.enableAnimatedImages,_that.collapseBotComments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int id, @JsonKey(name: 'person_id', fromJson: _toInt)  int personId,  String? email, @JsonKey(name: 'show_nsfw')  bool showNsfw,  String? theme, @JsonKey(name: 'default_sort_type', fromJson: _toInt)  int? defaultSortType, @JsonKey(name: 'default_listing_type', fromJson: _toInt)  int? defaultListingType, @JsonKey(name: 'interface_language')  String? interfaceLanguage, @JsonKey(name: 'show_avatars')  bool showAvatars, @JsonKey(name: 'send_notifications_to_email')  bool sendNotificationsToEmail, @JsonKey(name: 'show_scores')  bool showScores, @JsonKey(name: 'show_bot_accounts')  bool showBotAccounts, @JsonKey(name: 'show_read_posts')  bool showReadPosts, @JsonKey(name: 'email_verified')  bool emailVerified, @JsonKey(name: 'accepted_application')  bool acceptedApplication, @JsonKey(name: 'open_links_in_new_tab')  bool openLinksInNewTab, @JsonKey(name: 'blur_nsfw')  bool blurNsfw, @JsonKey(name: 'auto_expand')  bool autoExpand, @JsonKey(name: 'infinite_scroll_enabled')  bool infiniteScrollEnabled,  bool admin, @JsonKey(name: 'post_listing_mode', fromJson: _toInt)  int? postListingMode, @JsonKey(name: 'totp_2fa_enabled')  bool totp2faEnabled, @JsonKey(name: 'enable_keyboard_navigation')  bool enableKeyboardNavigation, @JsonKey(name: 'enable_animated_images')  bool enableAnimatedImages, @JsonKey(name: 'collapse_bot_comments')  bool collapseBotComments)  $default,) {final _that = this;
switch (_that) {
case _LocalUser():
return $default(_that.id,_that.personId,_that.email,_that.showNsfw,_that.theme,_that.defaultSortType,_that.defaultListingType,_that.interfaceLanguage,_that.showAvatars,_that.sendNotificationsToEmail,_that.showScores,_that.showBotAccounts,_that.showReadPosts,_that.emailVerified,_that.acceptedApplication,_that.openLinksInNewTab,_that.blurNsfw,_that.autoExpand,_that.infiniteScrollEnabled,_that.admin,_that.postListingMode,_that.totp2faEnabled,_that.enableKeyboardNavigation,_that.enableAnimatedImages,_that.collapseBotComments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _toInt)  int id, @JsonKey(name: 'person_id', fromJson: _toInt)  int personId,  String? email, @JsonKey(name: 'show_nsfw')  bool showNsfw,  String? theme, @JsonKey(name: 'default_sort_type', fromJson: _toInt)  int? defaultSortType, @JsonKey(name: 'default_listing_type', fromJson: _toInt)  int? defaultListingType, @JsonKey(name: 'interface_language')  String? interfaceLanguage, @JsonKey(name: 'show_avatars')  bool showAvatars, @JsonKey(name: 'send_notifications_to_email')  bool sendNotificationsToEmail, @JsonKey(name: 'show_scores')  bool showScores, @JsonKey(name: 'show_bot_accounts')  bool showBotAccounts, @JsonKey(name: 'show_read_posts')  bool showReadPosts, @JsonKey(name: 'email_verified')  bool emailVerified, @JsonKey(name: 'accepted_application')  bool acceptedApplication, @JsonKey(name: 'open_links_in_new_tab')  bool openLinksInNewTab, @JsonKey(name: 'blur_nsfw')  bool blurNsfw, @JsonKey(name: 'auto_expand')  bool autoExpand, @JsonKey(name: 'infinite_scroll_enabled')  bool infiniteScrollEnabled,  bool admin, @JsonKey(name: 'post_listing_mode', fromJson: _toInt)  int? postListingMode, @JsonKey(name: 'totp_2fa_enabled')  bool totp2faEnabled, @JsonKey(name: 'enable_keyboard_navigation')  bool enableKeyboardNavigation, @JsonKey(name: 'enable_animated_images')  bool enableAnimatedImages, @JsonKey(name: 'collapse_bot_comments')  bool collapseBotComments)?  $default,) {final _that = this;
switch (_that) {
case _LocalUser() when $default != null:
return $default(_that.id,_that.personId,_that.email,_that.showNsfw,_that.theme,_that.defaultSortType,_that.defaultListingType,_that.interfaceLanguage,_that.showAvatars,_that.sendNotificationsToEmail,_that.showScores,_that.showBotAccounts,_that.showReadPosts,_that.emailVerified,_that.acceptedApplication,_that.openLinksInNewTab,_that.blurNsfw,_that.autoExpand,_that.infiniteScrollEnabled,_that.admin,_that.postListingMode,_that.totp2faEnabled,_that.enableKeyboardNavigation,_that.enableAnimatedImages,_that.collapseBotComments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _LocalUser implements LocalUser {
  const _LocalUser({@JsonKey(fromJson: _toInt) this.id = 0, @JsonKey(name: 'person_id', fromJson: _toInt) this.personId = 0, this.email, @JsonKey(name: 'show_nsfw') this.showNsfw = false, this.theme, @JsonKey(name: 'default_sort_type', fromJson: _toInt) this.defaultSortType, @JsonKey(name: 'default_listing_type', fromJson: _toInt) this.defaultListingType, @JsonKey(name: 'interface_language') this.interfaceLanguage, @JsonKey(name: 'show_avatars') this.showAvatars = true, @JsonKey(name: 'send_notifications_to_email') this.sendNotificationsToEmail = false, @JsonKey(name: 'show_scores') this.showScores = true, @JsonKey(name: 'show_bot_accounts') this.showBotAccounts = true, @JsonKey(name: 'show_read_posts') this.showReadPosts = true, @JsonKey(name: 'email_verified') this.emailVerified = false, @JsonKey(name: 'accepted_application') this.acceptedApplication = false, @JsonKey(name: 'open_links_in_new_tab') this.openLinksInNewTab = false, @JsonKey(name: 'blur_nsfw') this.blurNsfw = true, @JsonKey(name: 'auto_expand') this.autoExpand = false, @JsonKey(name: 'infinite_scroll_enabled') this.infiniteScrollEnabled = true, this.admin = false, @JsonKey(name: 'post_listing_mode', fromJson: _toInt) this.postListingMode, @JsonKey(name: 'totp_2fa_enabled') this.totp2faEnabled = false, @JsonKey(name: 'enable_keyboard_navigation') this.enableKeyboardNavigation = false, @JsonKey(name: 'enable_animated_images') this.enableAnimatedImages = true, @JsonKey(name: 'collapse_bot_comments') this.collapseBotComments = false});
  factory _LocalUser.fromJson(Map<String, dynamic> json) => _$LocalUserFromJson(json);

@override@JsonKey(fromJson: _toInt) final  int id;
@override@JsonKey(name: 'person_id', fromJson: _toInt) final  int personId;
@override final  String? email;
@override@JsonKey(name: 'show_nsfw') final  bool showNsfw;
@override final  String? theme;
// Preserves legacy parse: missing values become 0 via _toInt.
@override@JsonKey(name: 'default_sort_type', fromJson: _toInt) final  int? defaultSortType;
@override@JsonKey(name: 'default_listing_type', fromJson: _toInt) final  int? defaultListingType;
@override@JsonKey(name: 'interface_language') final  String? interfaceLanguage;
@override@JsonKey(name: 'show_avatars') final  bool showAvatars;
@override@JsonKey(name: 'send_notifications_to_email') final  bool sendNotificationsToEmail;
@override@JsonKey(name: 'show_scores') final  bool showScores;
@override@JsonKey(name: 'show_bot_accounts') final  bool showBotAccounts;
@override@JsonKey(name: 'show_read_posts') final  bool showReadPosts;
@override@JsonKey(name: 'email_verified') final  bool emailVerified;
@override@JsonKey(name: 'accepted_application') final  bool acceptedApplication;
@override@JsonKey(name: 'open_links_in_new_tab') final  bool openLinksInNewTab;
@override@JsonKey(name: 'blur_nsfw') final  bool blurNsfw;
@override@JsonKey(name: 'auto_expand') final  bool autoExpand;
@override@JsonKey(name: 'infinite_scroll_enabled') final  bool infiniteScrollEnabled;
@override@JsonKey() final  bool admin;
@override@JsonKey(name: 'post_listing_mode', fromJson: _toInt) final  int? postListingMode;
@override@JsonKey(name: 'totp_2fa_enabled') final  bool totp2faEnabled;
@override@JsonKey(name: 'enable_keyboard_navigation') final  bool enableKeyboardNavigation;
@override@JsonKey(name: 'enable_animated_images') final  bool enableAnimatedImages;
@override@JsonKey(name: 'collapse_bot_comments') final  bool collapseBotComments;

/// Create a copy of LocalUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalUserCopyWith<_LocalUser> get copyWith => __$LocalUserCopyWithImpl<_LocalUser>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalUser&&(identical(other.id, id) || other.id == id)&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.email, email) || other.email == email)&&(identical(other.showNsfw, showNsfw) || other.showNsfw == showNsfw)&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.defaultSortType, defaultSortType) || other.defaultSortType == defaultSortType)&&(identical(other.defaultListingType, defaultListingType) || other.defaultListingType == defaultListingType)&&(identical(other.interfaceLanguage, interfaceLanguage) || other.interfaceLanguage == interfaceLanguage)&&(identical(other.showAvatars, showAvatars) || other.showAvatars == showAvatars)&&(identical(other.sendNotificationsToEmail, sendNotificationsToEmail) || other.sendNotificationsToEmail == sendNotificationsToEmail)&&(identical(other.showScores, showScores) || other.showScores == showScores)&&(identical(other.showBotAccounts, showBotAccounts) || other.showBotAccounts == showBotAccounts)&&(identical(other.showReadPosts, showReadPosts) || other.showReadPosts == showReadPosts)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.acceptedApplication, acceptedApplication) || other.acceptedApplication == acceptedApplication)&&(identical(other.openLinksInNewTab, openLinksInNewTab) || other.openLinksInNewTab == openLinksInNewTab)&&(identical(other.blurNsfw, blurNsfw) || other.blurNsfw == blurNsfw)&&(identical(other.autoExpand, autoExpand) || other.autoExpand == autoExpand)&&(identical(other.infiniteScrollEnabled, infiniteScrollEnabled) || other.infiniteScrollEnabled == infiniteScrollEnabled)&&(identical(other.admin, admin) || other.admin == admin)&&(identical(other.postListingMode, postListingMode) || other.postListingMode == postListingMode)&&(identical(other.totp2faEnabled, totp2faEnabled) || other.totp2faEnabled == totp2faEnabled)&&(identical(other.enableKeyboardNavigation, enableKeyboardNavigation) || other.enableKeyboardNavigation == enableKeyboardNavigation)&&(identical(other.enableAnimatedImages, enableAnimatedImages) || other.enableAnimatedImages == enableAnimatedImages)&&(identical(other.collapseBotComments, collapseBotComments) || other.collapseBotComments == collapseBotComments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,personId,email,showNsfw,theme,defaultSortType,defaultListingType,interfaceLanguage,showAvatars,sendNotificationsToEmail,showScores,showBotAccounts,showReadPosts,emailVerified,acceptedApplication,openLinksInNewTab,blurNsfw,autoExpand,infiniteScrollEnabled,admin,postListingMode,totp2faEnabled,enableKeyboardNavigation,enableAnimatedImages,collapseBotComments]);

@override
String toString() {
  return 'LocalUser(id: $id, personId: $personId, email: $email, showNsfw: $showNsfw, theme: $theme, defaultSortType: $defaultSortType, defaultListingType: $defaultListingType, interfaceLanguage: $interfaceLanguage, showAvatars: $showAvatars, sendNotificationsToEmail: $sendNotificationsToEmail, showScores: $showScores, showBotAccounts: $showBotAccounts, showReadPosts: $showReadPosts, emailVerified: $emailVerified, acceptedApplication: $acceptedApplication, openLinksInNewTab: $openLinksInNewTab, blurNsfw: $blurNsfw, autoExpand: $autoExpand, infiniteScrollEnabled: $infiniteScrollEnabled, admin: $admin, postListingMode: $postListingMode, totp2faEnabled: $totp2faEnabled, enableKeyboardNavigation: $enableKeyboardNavigation, enableAnimatedImages: $enableAnimatedImages, collapseBotComments: $collapseBotComments)';
}


}

/// @nodoc
abstract mixin class _$LocalUserCopyWith<$Res> implements $LocalUserCopyWith<$Res> {
  factory _$LocalUserCopyWith(_LocalUser value, $Res Function(_LocalUser) _then) = __$LocalUserCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _toInt) int id,@JsonKey(name: 'person_id', fromJson: _toInt) int personId, String? email,@JsonKey(name: 'show_nsfw') bool showNsfw, String? theme,@JsonKey(name: 'default_sort_type', fromJson: _toInt) int? defaultSortType,@JsonKey(name: 'default_listing_type', fromJson: _toInt) int? defaultListingType,@JsonKey(name: 'interface_language') String? interfaceLanguage,@JsonKey(name: 'show_avatars') bool showAvatars,@JsonKey(name: 'send_notifications_to_email') bool sendNotificationsToEmail,@JsonKey(name: 'show_scores') bool showScores,@JsonKey(name: 'show_bot_accounts') bool showBotAccounts,@JsonKey(name: 'show_read_posts') bool showReadPosts,@JsonKey(name: 'email_verified') bool emailVerified,@JsonKey(name: 'accepted_application') bool acceptedApplication,@JsonKey(name: 'open_links_in_new_tab') bool openLinksInNewTab,@JsonKey(name: 'blur_nsfw') bool blurNsfw,@JsonKey(name: 'auto_expand') bool autoExpand,@JsonKey(name: 'infinite_scroll_enabled') bool infiniteScrollEnabled, bool admin,@JsonKey(name: 'post_listing_mode', fromJson: _toInt) int? postListingMode,@JsonKey(name: 'totp_2fa_enabled') bool totp2faEnabled,@JsonKey(name: 'enable_keyboard_navigation') bool enableKeyboardNavigation,@JsonKey(name: 'enable_animated_images') bool enableAnimatedImages,@JsonKey(name: 'collapse_bot_comments') bool collapseBotComments
});




}
/// @nodoc
class __$LocalUserCopyWithImpl<$Res>
    implements _$LocalUserCopyWith<$Res> {
  __$LocalUserCopyWithImpl(this._self, this._then);

  final _LocalUser _self;
  final $Res Function(_LocalUser) _then;

/// Create a copy of LocalUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? personId = null,Object? email = freezed,Object? showNsfw = null,Object? theme = freezed,Object? defaultSortType = freezed,Object? defaultListingType = freezed,Object? interfaceLanguage = freezed,Object? showAvatars = null,Object? sendNotificationsToEmail = null,Object? showScores = null,Object? showBotAccounts = null,Object? showReadPosts = null,Object? emailVerified = null,Object? acceptedApplication = null,Object? openLinksInNewTab = null,Object? blurNsfw = null,Object? autoExpand = null,Object? infiniteScrollEnabled = null,Object? admin = null,Object? postListingMode = freezed,Object? totp2faEnabled = null,Object? enableKeyboardNavigation = null,Object? enableAnimatedImages = null,Object? collapseBotComments = null,}) {
  return _then(_LocalUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,personId: null == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as int,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,showNsfw: null == showNsfw ? _self.showNsfw : showNsfw // ignore: cast_nullable_to_non_nullable
as bool,theme: freezed == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String?,defaultSortType: freezed == defaultSortType ? _self.defaultSortType : defaultSortType // ignore: cast_nullable_to_non_nullable
as int?,defaultListingType: freezed == defaultListingType ? _self.defaultListingType : defaultListingType // ignore: cast_nullable_to_non_nullable
as int?,interfaceLanguage: freezed == interfaceLanguage ? _self.interfaceLanguage : interfaceLanguage // ignore: cast_nullable_to_non_nullable
as String?,showAvatars: null == showAvatars ? _self.showAvatars : showAvatars // ignore: cast_nullable_to_non_nullable
as bool,sendNotificationsToEmail: null == sendNotificationsToEmail ? _self.sendNotificationsToEmail : sendNotificationsToEmail // ignore: cast_nullable_to_non_nullable
as bool,showScores: null == showScores ? _self.showScores : showScores // ignore: cast_nullable_to_non_nullable
as bool,showBotAccounts: null == showBotAccounts ? _self.showBotAccounts : showBotAccounts // ignore: cast_nullable_to_non_nullable
as bool,showReadPosts: null == showReadPosts ? _self.showReadPosts : showReadPosts // ignore: cast_nullable_to_non_nullable
as bool,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,acceptedApplication: null == acceptedApplication ? _self.acceptedApplication : acceptedApplication // ignore: cast_nullable_to_non_nullable
as bool,openLinksInNewTab: null == openLinksInNewTab ? _self.openLinksInNewTab : openLinksInNewTab // ignore: cast_nullable_to_non_nullable
as bool,blurNsfw: null == blurNsfw ? _self.blurNsfw : blurNsfw // ignore: cast_nullable_to_non_nullable
as bool,autoExpand: null == autoExpand ? _self.autoExpand : autoExpand // ignore: cast_nullable_to_non_nullable
as bool,infiniteScrollEnabled: null == infiniteScrollEnabled ? _self.infiniteScrollEnabled : infiniteScrollEnabled // ignore: cast_nullable_to_non_nullable
as bool,admin: null == admin ? _self.admin : admin // ignore: cast_nullable_to_non_nullable
as bool,postListingMode: freezed == postListingMode ? _self.postListingMode : postListingMode // ignore: cast_nullable_to_non_nullable
as int?,totp2faEnabled: null == totp2faEnabled ? _self.totp2faEnabled : totp2faEnabled // ignore: cast_nullable_to_non_nullable
as bool,enableKeyboardNavigation: null == enableKeyboardNavigation ? _self.enableKeyboardNavigation : enableKeyboardNavigation // ignore: cast_nullable_to_non_nullable
as bool,enableAnimatedImages: null == enableAnimatedImages ? _self.enableAnimatedImages : enableAnimatedImages // ignore: cast_nullable_to_non_nullable
as bool,collapseBotComments: null == collapseBotComments ? _self.collapseBotComments : collapseBotComments // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Instance {

@JsonKey(fromJson: _toInt) int get id; String get domain; String get published; String? get updated; String? get software; String? get version;
/// Create a copy of Instance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InstanceCopyWith<Instance> get copyWith => _$InstanceCopyWithImpl<Instance>(this as Instance, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Instance&&(identical(other.id, id) || other.id == id)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.published, published) || other.published == published)&&(identical(other.updated, updated) || other.updated == updated)&&(identical(other.software, software) || other.software == software)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,domain,published,updated,software,version);

@override
String toString() {
  return 'Instance(id: $id, domain: $domain, published: $published, updated: $updated, software: $software, version: $version)';
}


}

/// @nodoc
abstract mixin class $InstanceCopyWith<$Res>  {
  factory $InstanceCopyWith(Instance value, $Res Function(Instance) _then) = _$InstanceCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _toInt) int id, String domain, String published, String? updated, String? software, String? version
});




}
/// @nodoc
class _$InstanceCopyWithImpl<$Res>
    implements $InstanceCopyWith<$Res> {
  _$InstanceCopyWithImpl(this._self, this._then);

  final Instance _self;
  final $Res Function(Instance) _then;

/// Create a copy of Instance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? domain = null,Object? published = null,Object? updated = freezed,Object? software = freezed,Object? version = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,updated: freezed == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as String?,software: freezed == software ? _self.software : software // ignore: cast_nullable_to_non_nullable
as String?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Instance].
extension InstancePatterns on Instance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Instance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Instance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Instance value)  $default,){
final _that = this;
switch (_that) {
case _Instance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Instance value)?  $default,){
final _that = this;
switch (_that) {
case _Instance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int id,  String domain,  String published,  String? updated,  String? software,  String? version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Instance() when $default != null:
return $default(_that.id,_that.domain,_that.published,_that.updated,_that.software,_that.version);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int id,  String domain,  String published,  String? updated,  String? software,  String? version)  $default,) {final _that = this;
switch (_that) {
case _Instance():
return $default(_that.id,_that.domain,_that.published,_that.updated,_that.software,_that.version);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _toInt)  int id,  String domain,  String published,  String? updated,  String? software,  String? version)?  $default,) {final _that = this;
switch (_that) {
case _Instance() when $default != null:
return $default(_that.id,_that.domain,_that.published,_that.updated,_that.software,_that.version);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _Instance implements Instance {
  const _Instance({@JsonKey(fromJson: _toInt) this.id = 0, this.domain = '', this.published = '', this.updated, this.software, this.version});
  factory _Instance.fromJson(Map<String, dynamic> json) => _$InstanceFromJson(json);

@override@JsonKey(fromJson: _toInt) final  int id;
@override@JsonKey() final  String domain;
@override@JsonKey() final  String published;
@override final  String? updated;
@override final  String? software;
@override final  String? version;

/// Create a copy of Instance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InstanceCopyWith<_Instance> get copyWith => __$InstanceCopyWithImpl<_Instance>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Instance&&(identical(other.id, id) || other.id == id)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.published, published) || other.published == published)&&(identical(other.updated, updated) || other.updated == updated)&&(identical(other.software, software) || other.software == software)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,domain,published,updated,software,version);

@override
String toString() {
  return 'Instance(id: $id, domain: $domain, published: $published, updated: $updated, software: $software, version: $version)';
}


}

/// @nodoc
abstract mixin class _$InstanceCopyWith<$Res> implements $InstanceCopyWith<$Res> {
  factory _$InstanceCopyWith(_Instance value, $Res Function(_Instance) _then) = __$InstanceCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _toInt) int id, String domain, String published, String? updated, String? software, String? version
});




}
/// @nodoc
class __$InstanceCopyWithImpl<$Res>
    implements _$InstanceCopyWith<$Res> {
  __$InstanceCopyWithImpl(this._self, this._then);

  final _Instance _self;
  final $Res Function(_Instance) _then;

/// Create a copy of Instance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? domain = null,Object? published = null,Object? updated = freezed,Object? software = freezed,Object? version = freezed,}) {
  return _then(_Instance(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,updated: freezed == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as String?,software: freezed == software ? _self.software : software // ignore: cast_nullable_to_non_nullable
as String?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PersonBlockView {

 Person get person; Person get target;
/// Create a copy of PersonBlockView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonBlockViewCopyWith<PersonBlockView> get copyWith => _$PersonBlockViewCopyWithImpl<PersonBlockView>(this as PersonBlockView, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonBlockView&&(identical(other.person, person) || other.person == person)&&(identical(other.target, target) || other.target == target));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,person,target);

@override
String toString() {
  return 'PersonBlockView(person: $person, target: $target)';
}


}

/// @nodoc
abstract mixin class $PersonBlockViewCopyWith<$Res>  {
  factory $PersonBlockViewCopyWith(PersonBlockView value, $Res Function(PersonBlockView) _then) = _$PersonBlockViewCopyWithImpl;
@useResult
$Res call({
 Person person, Person target
});


$PersonCopyWith<$Res> get person;$PersonCopyWith<$Res> get target;

}
/// @nodoc
class _$PersonBlockViewCopyWithImpl<$Res>
    implements $PersonBlockViewCopyWith<$Res> {
  _$PersonBlockViewCopyWithImpl(this._self, this._then);

  final PersonBlockView _self;
  final $Res Function(PersonBlockView) _then;

/// Create a copy of PersonBlockView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? person = null,Object? target = null,}) {
  return _then(_self.copyWith(
person: null == person ? _self.person : person // ignore: cast_nullable_to_non_nullable
as Person,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as Person,
  ));
}
/// Create a copy of PersonBlockView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get person {
  
  return $PersonCopyWith<$Res>(_self.person, (value) {
    return _then(_self.copyWith(person: value));
  });
}/// Create a copy of PersonBlockView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get target {
  
  return $PersonCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}
}


/// Adds pattern-matching-related methods to [PersonBlockView].
extension PersonBlockViewPatterns on PersonBlockView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonBlockView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonBlockView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonBlockView value)  $default,){
final _that = this;
switch (_that) {
case _PersonBlockView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonBlockView value)?  $default,){
final _that = this;
switch (_that) {
case _PersonBlockView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Person person,  Person target)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonBlockView() when $default != null:
return $default(_that.person,_that.target);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Person person,  Person target)  $default,) {final _that = this;
switch (_that) {
case _PersonBlockView():
return $default(_that.person,_that.target);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Person person,  Person target)?  $default,) {final _that = this;
switch (_that) {
case _PersonBlockView() when $default != null:
return $default(_that.person,_that.target);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _PersonBlockView implements PersonBlockView {
  const _PersonBlockView({required this.person, required this.target});
  factory _PersonBlockView.fromJson(Map<String, dynamic> json) => _$PersonBlockViewFromJson(json);

@override final  Person person;
@override final  Person target;

/// Create a copy of PersonBlockView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonBlockViewCopyWith<_PersonBlockView> get copyWith => __$PersonBlockViewCopyWithImpl<_PersonBlockView>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonBlockView&&(identical(other.person, person) || other.person == person)&&(identical(other.target, target) || other.target == target));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,person,target);

@override
String toString() {
  return 'PersonBlockView(person: $person, target: $target)';
}


}

/// @nodoc
abstract mixin class _$PersonBlockViewCopyWith<$Res> implements $PersonBlockViewCopyWith<$Res> {
  factory _$PersonBlockViewCopyWith(_PersonBlockView value, $Res Function(_PersonBlockView) _then) = __$PersonBlockViewCopyWithImpl;
@override @useResult
$Res call({
 Person person, Person target
});


@override $PersonCopyWith<$Res> get person;@override $PersonCopyWith<$Res> get target;

}
/// @nodoc
class __$PersonBlockViewCopyWithImpl<$Res>
    implements _$PersonBlockViewCopyWith<$Res> {
  __$PersonBlockViewCopyWithImpl(this._self, this._then);

  final _PersonBlockView _self;
  final $Res Function(_PersonBlockView) _then;

/// Create a copy of PersonBlockView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? person = null,Object? target = null,}) {
  return _then(_PersonBlockView(
person: null == person ? _self.person : person // ignore: cast_nullable_to_non_nullable
as Person,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as Person,
  ));
}

/// Create a copy of PersonBlockView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get person {
  
  return $PersonCopyWith<$Res>(_self.person, (value) {
    return _then(_self.copyWith(person: value));
  });
}/// Create a copy of PersonBlockView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get target {
  
  return $PersonCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}
}


/// @nodoc
mixin _$CommunityBlockView {

 Person get person; Community get community;
/// Create a copy of CommunityBlockView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityBlockViewCopyWith<CommunityBlockView> get copyWith => _$CommunityBlockViewCopyWithImpl<CommunityBlockView>(this as CommunityBlockView, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunityBlockView&&(identical(other.person, person) || other.person == person)&&(identical(other.community, community) || other.community == community));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,person,community);

@override
String toString() {
  return 'CommunityBlockView(person: $person, community: $community)';
}


}

/// @nodoc
abstract mixin class $CommunityBlockViewCopyWith<$Res>  {
  factory $CommunityBlockViewCopyWith(CommunityBlockView value, $Res Function(CommunityBlockView) _then) = _$CommunityBlockViewCopyWithImpl;
@useResult
$Res call({
 Person person, Community community
});


$PersonCopyWith<$Res> get person;$CommunityCopyWith<$Res> get community;

}
/// @nodoc
class _$CommunityBlockViewCopyWithImpl<$Res>
    implements $CommunityBlockViewCopyWith<$Res> {
  _$CommunityBlockViewCopyWithImpl(this._self, this._then);

  final CommunityBlockView _self;
  final $Res Function(CommunityBlockView) _then;

/// Create a copy of CommunityBlockView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? person = null,Object? community = null,}) {
  return _then(_self.copyWith(
person: null == person ? _self.person : person // ignore: cast_nullable_to_non_nullable
as Person,community: null == community ? _self.community : community // ignore: cast_nullable_to_non_nullable
as Community,
  ));
}
/// Create a copy of CommunityBlockView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get person {
  
  return $PersonCopyWith<$Res>(_self.person, (value) {
    return _then(_self.copyWith(person: value));
  });
}/// Create a copy of CommunityBlockView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommunityCopyWith<$Res> get community {
  
  return $CommunityCopyWith<$Res>(_self.community, (value) {
    return _then(_self.copyWith(community: value));
  });
}
}


/// Adds pattern-matching-related methods to [CommunityBlockView].
extension CommunityBlockViewPatterns on CommunityBlockView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunityBlockView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunityBlockView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunityBlockView value)  $default,){
final _that = this;
switch (_that) {
case _CommunityBlockView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunityBlockView value)?  $default,){
final _that = this;
switch (_that) {
case _CommunityBlockView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Person person,  Community community)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunityBlockView() when $default != null:
return $default(_that.person,_that.community);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Person person,  Community community)  $default,) {final _that = this;
switch (_that) {
case _CommunityBlockView():
return $default(_that.person,_that.community);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Person person,  Community community)?  $default,) {final _that = this;
switch (_that) {
case _CommunityBlockView() when $default != null:
return $default(_that.person,_that.community);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _CommunityBlockView implements CommunityBlockView {
  const _CommunityBlockView({required this.person, required this.community});
  factory _CommunityBlockView.fromJson(Map<String, dynamic> json) => _$CommunityBlockViewFromJson(json);

@override final  Person person;
@override final  Community community;

/// Create a copy of CommunityBlockView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityBlockViewCopyWith<_CommunityBlockView> get copyWith => __$CommunityBlockViewCopyWithImpl<_CommunityBlockView>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunityBlockView&&(identical(other.person, person) || other.person == person)&&(identical(other.community, community) || other.community == community));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,person,community);

@override
String toString() {
  return 'CommunityBlockView(person: $person, community: $community)';
}


}

/// @nodoc
abstract mixin class _$CommunityBlockViewCopyWith<$Res> implements $CommunityBlockViewCopyWith<$Res> {
  factory _$CommunityBlockViewCopyWith(_CommunityBlockView value, $Res Function(_CommunityBlockView) _then) = __$CommunityBlockViewCopyWithImpl;
@override @useResult
$Res call({
 Person person, Community community
});


@override $PersonCopyWith<$Res> get person;@override $CommunityCopyWith<$Res> get community;

}
/// @nodoc
class __$CommunityBlockViewCopyWithImpl<$Res>
    implements _$CommunityBlockViewCopyWith<$Res> {
  __$CommunityBlockViewCopyWithImpl(this._self, this._then);

  final _CommunityBlockView _self;
  final $Res Function(_CommunityBlockView) _then;

/// Create a copy of CommunityBlockView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? person = null,Object? community = null,}) {
  return _then(_CommunityBlockView(
person: null == person ? _self.person : person // ignore: cast_nullable_to_non_nullable
as Person,community: null == community ? _self.community : community // ignore: cast_nullable_to_non_nullable
as Community,
  ));
}

/// Create a copy of CommunityBlockView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get person {
  
  return $PersonCopyWith<$Res>(_self.person, (value) {
    return _then(_self.copyWith(person: value));
  });
}/// Create a copy of CommunityBlockView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommunityCopyWith<$Res> get community {
  
  return $CommunityCopyWith<$Res>(_self.community, (value) {
    return _then(_self.copyWith(community: value));
  });
}
}


/// @nodoc
mixin _$InstanceBlockView {

 Person get person; Instance get instance;
/// Create a copy of InstanceBlockView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InstanceBlockViewCopyWith<InstanceBlockView> get copyWith => _$InstanceBlockViewCopyWithImpl<InstanceBlockView>(this as InstanceBlockView, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InstanceBlockView&&(identical(other.person, person) || other.person == person)&&(identical(other.instance, instance) || other.instance == instance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,person,instance);

@override
String toString() {
  return 'InstanceBlockView(person: $person, instance: $instance)';
}


}

/// @nodoc
abstract mixin class $InstanceBlockViewCopyWith<$Res>  {
  factory $InstanceBlockViewCopyWith(InstanceBlockView value, $Res Function(InstanceBlockView) _then) = _$InstanceBlockViewCopyWithImpl;
@useResult
$Res call({
 Person person, Instance instance
});


$PersonCopyWith<$Res> get person;$InstanceCopyWith<$Res> get instance;

}
/// @nodoc
class _$InstanceBlockViewCopyWithImpl<$Res>
    implements $InstanceBlockViewCopyWith<$Res> {
  _$InstanceBlockViewCopyWithImpl(this._self, this._then);

  final InstanceBlockView _self;
  final $Res Function(InstanceBlockView) _then;

/// Create a copy of InstanceBlockView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? person = null,Object? instance = null,}) {
  return _then(_self.copyWith(
person: null == person ? _self.person : person // ignore: cast_nullable_to_non_nullable
as Person,instance: null == instance ? _self.instance : instance // ignore: cast_nullable_to_non_nullable
as Instance,
  ));
}
/// Create a copy of InstanceBlockView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get person {
  
  return $PersonCopyWith<$Res>(_self.person, (value) {
    return _then(_self.copyWith(person: value));
  });
}/// Create a copy of InstanceBlockView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InstanceCopyWith<$Res> get instance {
  
  return $InstanceCopyWith<$Res>(_self.instance, (value) {
    return _then(_self.copyWith(instance: value));
  });
}
}


/// Adds pattern-matching-related methods to [InstanceBlockView].
extension InstanceBlockViewPatterns on InstanceBlockView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InstanceBlockView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InstanceBlockView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InstanceBlockView value)  $default,){
final _that = this;
switch (_that) {
case _InstanceBlockView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InstanceBlockView value)?  $default,){
final _that = this;
switch (_that) {
case _InstanceBlockView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Person person,  Instance instance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InstanceBlockView() when $default != null:
return $default(_that.person,_that.instance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Person person,  Instance instance)  $default,) {final _that = this;
switch (_that) {
case _InstanceBlockView():
return $default(_that.person,_that.instance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Person person,  Instance instance)?  $default,) {final _that = this;
switch (_that) {
case _InstanceBlockView() when $default != null:
return $default(_that.person,_that.instance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _InstanceBlockView implements InstanceBlockView {
  const _InstanceBlockView({required this.person, required this.instance});
  factory _InstanceBlockView.fromJson(Map<String, dynamic> json) => _$InstanceBlockViewFromJson(json);

@override final  Person person;
@override final  Instance instance;

/// Create a copy of InstanceBlockView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InstanceBlockViewCopyWith<_InstanceBlockView> get copyWith => __$InstanceBlockViewCopyWithImpl<_InstanceBlockView>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InstanceBlockView&&(identical(other.person, person) || other.person == person)&&(identical(other.instance, instance) || other.instance == instance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,person,instance);

@override
String toString() {
  return 'InstanceBlockView(person: $person, instance: $instance)';
}


}

/// @nodoc
abstract mixin class _$InstanceBlockViewCopyWith<$Res> implements $InstanceBlockViewCopyWith<$Res> {
  factory _$InstanceBlockViewCopyWith(_InstanceBlockView value, $Res Function(_InstanceBlockView) _then) = __$InstanceBlockViewCopyWithImpl;
@override @useResult
$Res call({
 Person person, Instance instance
});


@override $PersonCopyWith<$Res> get person;@override $InstanceCopyWith<$Res> get instance;

}
/// @nodoc
class __$InstanceBlockViewCopyWithImpl<$Res>
    implements _$InstanceBlockViewCopyWith<$Res> {
  __$InstanceBlockViewCopyWithImpl(this._self, this._then);

  final _InstanceBlockView _self;
  final $Res Function(_InstanceBlockView) _then;

/// Create a copy of InstanceBlockView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? person = null,Object? instance = null,}) {
  return _then(_InstanceBlockView(
person: null == person ? _self.person : person // ignore: cast_nullable_to_non_nullable
as Person,instance: null == instance ? _self.instance : instance // ignore: cast_nullable_to_non_nullable
as Instance,
  ));
}

/// Create a copy of InstanceBlockView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get person {
  
  return $PersonCopyWith<$Res>(_self.person, (value) {
    return _then(_self.copyWith(person: value));
  });
}/// Create a copy of InstanceBlockView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InstanceCopyWith<$Res> get instance {
  
  return $InstanceCopyWith<$Res>(_self.instance, (value) {
    return _then(_self.copyWith(instance: value));
  });
}
}

// dart format on
