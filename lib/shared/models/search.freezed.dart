// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SearchResult {

@JsonKey(name: 'type_', defaultValue: 'All') String get type; List<PostView> get posts; List<CommentView> get comments; List<CommunityView> get communities; List<PersonView> get users;
/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchResultCopyWith<SearchResult> get copyWith => _$SearchResultCopyWithImpl<SearchResult>(this as SearchResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchResult&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.posts, posts)&&const DeepCollectionEquality().equals(other.comments, comments)&&const DeepCollectionEquality().equals(other.communities, communities)&&const DeepCollectionEquality().equals(other.users, users));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(posts),const DeepCollectionEquality().hash(comments),const DeepCollectionEquality().hash(communities),const DeepCollectionEquality().hash(users));

@override
String toString() {
  return 'SearchResult(type: $type, posts: $posts, comments: $comments, communities: $communities, users: $users)';
}


}

/// @nodoc
abstract mixin class $SearchResultCopyWith<$Res>  {
  factory $SearchResultCopyWith(SearchResult value, $Res Function(SearchResult) _then) = _$SearchResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'type_', defaultValue: 'All') String type, List<PostView> posts, List<CommentView> comments, List<CommunityView> communities, List<PersonView> users
});




}
/// @nodoc
class _$SearchResultCopyWithImpl<$Res>
    implements $SearchResultCopyWith<$Res> {
  _$SearchResultCopyWithImpl(this._self, this._then);

  final SearchResult _self;
  final $Res Function(SearchResult) _then;

/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? posts = null,Object? comments = null,Object? communities = null,Object? users = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as List<PostView>,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as List<CommentView>,communities: null == communities ? _self.communities : communities // ignore: cast_nullable_to_non_nullable
as List<CommunityView>,users: null == users ? _self.users : users // ignore: cast_nullable_to_non_nullable
as List<PersonView>,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchResult].
extension SearchResultPatterns on SearchResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchResult value)  $default,){
final _that = this;
switch (_that) {
case _SearchResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchResult value)?  $default,){
final _that = this;
switch (_that) {
case _SearchResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'type_', defaultValue: 'All')  String type,  List<PostView> posts,  List<CommentView> comments,  List<CommunityView> communities,  List<PersonView> users)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchResult() when $default != null:
return $default(_that.type,_that.posts,_that.comments,_that.communities,_that.users);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'type_', defaultValue: 'All')  String type,  List<PostView> posts,  List<CommentView> comments,  List<CommunityView> communities,  List<PersonView> users)  $default,) {final _that = this;
switch (_that) {
case _SearchResult():
return $default(_that.type,_that.posts,_that.comments,_that.communities,_that.users);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'type_', defaultValue: 'All')  String type,  List<PostView> posts,  List<CommentView> comments,  List<CommunityView> communities,  List<PersonView> users)?  $default,) {final _that = this;
switch (_that) {
case _SearchResult() when $default != null:
return $default(_that.type,_that.posts,_that.comments,_that.communities,_that.users);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _SearchResult implements SearchResult {
  const _SearchResult({@JsonKey(name: 'type_', defaultValue: 'All') this.type = 'All', final  List<PostView> posts = const <PostView>[], final  List<CommentView> comments = const <CommentView>[], final  List<CommunityView> communities = const <CommunityView>[], final  List<PersonView> users = const <PersonView>[]}): _posts = posts,_comments = comments,_communities = communities,_users = users;
  factory _SearchResult.fromJson(Map<String, dynamic> json) => _$SearchResultFromJson(json);

@override@JsonKey(name: 'type_', defaultValue: 'All') final  String type;
 final  List<PostView> _posts;
@override@JsonKey() List<PostView> get posts {
  if (_posts is EqualUnmodifiableListView) return _posts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posts);
}

 final  List<CommentView> _comments;
@override@JsonKey() List<CommentView> get comments {
  if (_comments is EqualUnmodifiableListView) return _comments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_comments);
}

 final  List<CommunityView> _communities;
@override@JsonKey() List<CommunityView> get communities {
  if (_communities is EqualUnmodifiableListView) return _communities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_communities);
}

 final  List<PersonView> _users;
@override@JsonKey() List<PersonView> get users {
  if (_users is EqualUnmodifiableListView) return _users;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_users);
}


/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchResultCopyWith<_SearchResult> get copyWith => __$SearchResultCopyWithImpl<_SearchResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchResult&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._posts, _posts)&&const DeepCollectionEquality().equals(other._comments, _comments)&&const DeepCollectionEquality().equals(other._communities, _communities)&&const DeepCollectionEquality().equals(other._users, _users));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_posts),const DeepCollectionEquality().hash(_comments),const DeepCollectionEquality().hash(_communities),const DeepCollectionEquality().hash(_users));

@override
String toString() {
  return 'SearchResult(type: $type, posts: $posts, comments: $comments, communities: $communities, users: $users)';
}


}

/// @nodoc
abstract mixin class _$SearchResultCopyWith<$Res> implements $SearchResultCopyWith<$Res> {
  factory _$SearchResultCopyWith(_SearchResult value, $Res Function(_SearchResult) _then) = __$SearchResultCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'type_', defaultValue: 'All') String type, List<PostView> posts, List<CommentView> comments, List<CommunityView> communities, List<PersonView> users
});




}
/// @nodoc
class __$SearchResultCopyWithImpl<$Res>
    implements _$SearchResultCopyWith<$Res> {
  __$SearchResultCopyWithImpl(this._self, this._then);

  final _SearchResult _self;
  final $Res Function(_SearchResult) _then;

/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? posts = null,Object? comments = null,Object? communities = null,Object? users = null,}) {
  return _then(_SearchResult(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as List<PostView>,comments: null == comments ? _self._comments : comments // ignore: cast_nullable_to_non_nullable
as List<CommentView>,communities: null == communities ? _self._communities : communities // ignore: cast_nullable_to_non_nullable
as List<CommunityView>,users: null == users ? _self._users : users // ignore: cast_nullable_to_non_nullable
as List<PersonView>,
  ));
}


}

// dart format on
