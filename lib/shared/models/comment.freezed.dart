// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Comment {

@JsonKey(fromJson: _toInt) int get id;@JsonKey(name: 'creator_id', fromJson: _toInt) int get creatorId;@JsonKey(name: 'post_id', fromJson: _toInt) int get postId; String get content; bool get removed; String get published; String? get updated; bool get deleted;@JsonKey(name: 'ap_id') String get apId; bool get local; String get path; bool get distinguished;@JsonKey(name: 'language_id', fromJson: _toInt) int get languageId;
/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentCopyWith<Comment> get copyWith => _$CommentCopyWithImpl<Comment>(this as Comment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Comment&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.content, content) || other.content == content)&&(identical(other.removed, removed) || other.removed == removed)&&(identical(other.published, published) || other.published == published)&&(identical(other.updated, updated) || other.updated == updated)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.apId, apId) || other.apId == apId)&&(identical(other.local, local) || other.local == local)&&(identical(other.path, path) || other.path == path)&&(identical(other.distinguished, distinguished) || other.distinguished == distinguished)&&(identical(other.languageId, languageId) || other.languageId == languageId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,postId,content,removed,published,updated,deleted,apId,local,path,distinguished,languageId);

@override
String toString() {
  return 'Comment(id: $id, creatorId: $creatorId, postId: $postId, content: $content, removed: $removed, published: $published, updated: $updated, deleted: $deleted, apId: $apId, local: $local, path: $path, distinguished: $distinguished, languageId: $languageId)';
}


}

/// @nodoc
abstract mixin class $CommentCopyWith<$Res>  {
  factory $CommentCopyWith(Comment value, $Res Function(Comment) _then) = _$CommentCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _toInt) int id,@JsonKey(name: 'creator_id', fromJson: _toInt) int creatorId,@JsonKey(name: 'post_id', fromJson: _toInt) int postId, String content, bool removed, String published, String? updated, bool deleted,@JsonKey(name: 'ap_id') String apId, bool local, String path, bool distinguished,@JsonKey(name: 'language_id', fromJson: _toInt) int languageId
});




}
/// @nodoc
class _$CommentCopyWithImpl<$Res>
    implements $CommentCopyWith<$Res> {
  _$CommentCopyWithImpl(this._self, this._then);

  final Comment _self;
  final $Res Function(Comment) _then;

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creatorId = null,Object? postId = null,Object? content = null,Object? removed = null,Object? published = null,Object? updated = freezed,Object? deleted = null,Object? apId = null,Object? local = null,Object? path = null,Object? distinguished = null,Object? languageId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as int,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,removed: null == removed ? _self.removed : removed // ignore: cast_nullable_to_non_nullable
as bool,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,updated: freezed == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as String?,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,apId: null == apId ? _self.apId : apId // ignore: cast_nullable_to_non_nullable
as String,local: null == local ? _self.local : local // ignore: cast_nullable_to_non_nullable
as bool,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,distinguished: null == distinguished ? _self.distinguished : distinguished // ignore: cast_nullable_to_non_nullable
as bool,languageId: null == languageId ? _self.languageId : languageId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Comment].
extension CommentPatterns on Comment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Comment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Comment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Comment value)  $default,){
final _that = this;
switch (_that) {
case _Comment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Comment value)?  $default,){
final _that = this;
switch (_that) {
case _Comment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int id, @JsonKey(name: 'creator_id', fromJson: _toInt)  int creatorId, @JsonKey(name: 'post_id', fromJson: _toInt)  int postId,  String content,  bool removed,  String published,  String? updated,  bool deleted, @JsonKey(name: 'ap_id')  String apId,  bool local,  String path,  bool distinguished, @JsonKey(name: 'language_id', fromJson: _toInt)  int languageId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Comment() when $default != null:
return $default(_that.id,_that.creatorId,_that.postId,_that.content,_that.removed,_that.published,_that.updated,_that.deleted,_that.apId,_that.local,_that.path,_that.distinguished,_that.languageId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int id, @JsonKey(name: 'creator_id', fromJson: _toInt)  int creatorId, @JsonKey(name: 'post_id', fromJson: _toInt)  int postId,  String content,  bool removed,  String published,  String? updated,  bool deleted, @JsonKey(name: 'ap_id')  String apId,  bool local,  String path,  bool distinguished, @JsonKey(name: 'language_id', fromJson: _toInt)  int languageId)  $default,) {final _that = this;
switch (_that) {
case _Comment():
return $default(_that.id,_that.creatorId,_that.postId,_that.content,_that.removed,_that.published,_that.updated,_that.deleted,_that.apId,_that.local,_that.path,_that.distinguished,_that.languageId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _toInt)  int id, @JsonKey(name: 'creator_id', fromJson: _toInt)  int creatorId, @JsonKey(name: 'post_id', fromJson: _toInt)  int postId,  String content,  bool removed,  String published,  String? updated,  bool deleted, @JsonKey(name: 'ap_id')  String apId,  bool local,  String path,  bool distinguished, @JsonKey(name: 'language_id', fromJson: _toInt)  int languageId)?  $default,) {final _that = this;
switch (_that) {
case _Comment() when $default != null:
return $default(_that.id,_that.creatorId,_that.postId,_that.content,_that.removed,_that.published,_that.updated,_that.deleted,_that.apId,_that.local,_that.path,_that.distinguished,_that.languageId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _Comment extends Comment {
  const _Comment({@JsonKey(fromJson: _toInt) this.id = 0, @JsonKey(name: 'creator_id', fromJson: _toInt) this.creatorId = 0, @JsonKey(name: 'post_id', fromJson: _toInt) this.postId = 0, this.content = '', this.removed = false, this.published = '', this.updated, this.deleted = false, @JsonKey(name: 'ap_id') this.apId = '', this.local = true, this.path = '', this.distinguished = false, @JsonKey(name: 'language_id', fromJson: _toInt) this.languageId = 0}): super._();
  factory _Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);

@override@JsonKey(fromJson: _toInt) final  int id;
@override@JsonKey(name: 'creator_id', fromJson: _toInt) final  int creatorId;
@override@JsonKey(name: 'post_id', fromJson: _toInt) final  int postId;
@override@JsonKey() final  String content;
@override@JsonKey() final  bool removed;
@override@JsonKey() final  String published;
@override final  String? updated;
@override@JsonKey() final  bool deleted;
@override@JsonKey(name: 'ap_id') final  String apId;
@override@JsonKey() final  bool local;
@override@JsonKey() final  String path;
@override@JsonKey() final  bool distinguished;
@override@JsonKey(name: 'language_id', fromJson: _toInt) final  int languageId;

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentCopyWith<_Comment> get copyWith => __$CommentCopyWithImpl<_Comment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Comment&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.content, content) || other.content == content)&&(identical(other.removed, removed) || other.removed == removed)&&(identical(other.published, published) || other.published == published)&&(identical(other.updated, updated) || other.updated == updated)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.apId, apId) || other.apId == apId)&&(identical(other.local, local) || other.local == local)&&(identical(other.path, path) || other.path == path)&&(identical(other.distinguished, distinguished) || other.distinguished == distinguished)&&(identical(other.languageId, languageId) || other.languageId == languageId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,postId,content,removed,published,updated,deleted,apId,local,path,distinguished,languageId);

@override
String toString() {
  return 'Comment(id: $id, creatorId: $creatorId, postId: $postId, content: $content, removed: $removed, published: $published, updated: $updated, deleted: $deleted, apId: $apId, local: $local, path: $path, distinguished: $distinguished, languageId: $languageId)';
}


}

/// @nodoc
abstract mixin class _$CommentCopyWith<$Res> implements $CommentCopyWith<$Res> {
  factory _$CommentCopyWith(_Comment value, $Res Function(_Comment) _then) = __$CommentCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _toInt) int id,@JsonKey(name: 'creator_id', fromJson: _toInt) int creatorId,@JsonKey(name: 'post_id', fromJson: _toInt) int postId, String content, bool removed, String published, String? updated, bool deleted,@JsonKey(name: 'ap_id') String apId, bool local, String path, bool distinguished,@JsonKey(name: 'language_id', fromJson: _toInt) int languageId
});




}
/// @nodoc
class __$CommentCopyWithImpl<$Res>
    implements _$CommentCopyWith<$Res> {
  __$CommentCopyWithImpl(this._self, this._then);

  final _Comment _self;
  final $Res Function(_Comment) _then;

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creatorId = null,Object? postId = null,Object? content = null,Object? removed = null,Object? published = null,Object? updated = freezed,Object? deleted = null,Object? apId = null,Object? local = null,Object? path = null,Object? distinguished = null,Object? languageId = null,}) {
  return _then(_Comment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as int,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,removed: null == removed ? _self.removed : removed // ignore: cast_nullable_to_non_nullable
as bool,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,updated: freezed == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as String?,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,apId: null == apId ? _self.apId : apId // ignore: cast_nullable_to_non_nullable
as String,local: null == local ? _self.local : local // ignore: cast_nullable_to_non_nullable
as bool,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,distinguished: null == distinguished ? _self.distinguished : distinguished // ignore: cast_nullable_to_non_nullable
as bool,languageId: null == languageId ? _self.languageId : languageId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CommentAggregates {

@JsonKey(name: 'comment_id', fromJson: _toInt) int get commentId;@JsonKey(fromJson: _toInt) int get score;@JsonKey(fromJson: _toInt) int get upvotes;@JsonKey(fromJson: _toInt) int get downvotes; String get published;@JsonKey(name: 'child_count', fromJson: _toInt) int get childCount;
/// Create a copy of CommentAggregates
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentAggregatesCopyWith<CommentAggregates> get copyWith => _$CommentAggregatesCopyWithImpl<CommentAggregates>(this as CommentAggregates, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentAggregates&&(identical(other.commentId, commentId) || other.commentId == commentId)&&(identical(other.score, score) || other.score == score)&&(identical(other.upvotes, upvotes) || other.upvotes == upvotes)&&(identical(other.downvotes, downvotes) || other.downvotes == downvotes)&&(identical(other.published, published) || other.published == published)&&(identical(other.childCount, childCount) || other.childCount == childCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,commentId,score,upvotes,downvotes,published,childCount);

@override
String toString() {
  return 'CommentAggregates(commentId: $commentId, score: $score, upvotes: $upvotes, downvotes: $downvotes, published: $published, childCount: $childCount)';
}


}

/// @nodoc
abstract mixin class $CommentAggregatesCopyWith<$Res>  {
  factory $CommentAggregatesCopyWith(CommentAggregates value, $Res Function(CommentAggregates) _then) = _$CommentAggregatesCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'comment_id', fromJson: _toInt) int commentId,@JsonKey(fromJson: _toInt) int score,@JsonKey(fromJson: _toInt) int upvotes,@JsonKey(fromJson: _toInt) int downvotes, String published,@JsonKey(name: 'child_count', fromJson: _toInt) int childCount
});




}
/// @nodoc
class _$CommentAggregatesCopyWithImpl<$Res>
    implements $CommentAggregatesCopyWith<$Res> {
  _$CommentAggregatesCopyWithImpl(this._self, this._then);

  final CommentAggregates _self;
  final $Res Function(CommentAggregates) _then;

/// Create a copy of CommentAggregates
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? commentId = null,Object? score = null,Object? upvotes = null,Object? downvotes = null,Object? published = null,Object? childCount = null,}) {
  return _then(_self.copyWith(
commentId: null == commentId ? _self.commentId : commentId // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,upvotes: null == upvotes ? _self.upvotes : upvotes // ignore: cast_nullable_to_non_nullable
as int,downvotes: null == downvotes ? _self.downvotes : downvotes // ignore: cast_nullable_to_non_nullable
as int,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,childCount: null == childCount ? _self.childCount : childCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CommentAggregates].
extension CommentAggregatesPatterns on CommentAggregates {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentAggregates value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentAggregates() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentAggregates value)  $default,){
final _that = this;
switch (_that) {
case _CommentAggregates():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentAggregates value)?  $default,){
final _that = this;
switch (_that) {
case _CommentAggregates() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'comment_id', fromJson: _toInt)  int commentId, @JsonKey(fromJson: _toInt)  int score, @JsonKey(fromJson: _toInt)  int upvotes, @JsonKey(fromJson: _toInt)  int downvotes,  String published, @JsonKey(name: 'child_count', fromJson: _toInt)  int childCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentAggregates() when $default != null:
return $default(_that.commentId,_that.score,_that.upvotes,_that.downvotes,_that.published,_that.childCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'comment_id', fromJson: _toInt)  int commentId, @JsonKey(fromJson: _toInt)  int score, @JsonKey(fromJson: _toInt)  int upvotes, @JsonKey(fromJson: _toInt)  int downvotes,  String published, @JsonKey(name: 'child_count', fromJson: _toInt)  int childCount)  $default,) {final _that = this;
switch (_that) {
case _CommentAggregates():
return $default(_that.commentId,_that.score,_that.upvotes,_that.downvotes,_that.published,_that.childCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'comment_id', fromJson: _toInt)  int commentId, @JsonKey(fromJson: _toInt)  int score, @JsonKey(fromJson: _toInt)  int upvotes, @JsonKey(fromJson: _toInt)  int downvotes,  String published, @JsonKey(name: 'child_count', fromJson: _toInt)  int childCount)?  $default,) {final _that = this;
switch (_that) {
case _CommentAggregates() when $default != null:
return $default(_that.commentId,_that.score,_that.upvotes,_that.downvotes,_that.published,_that.childCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _CommentAggregates implements CommentAggregates {
  const _CommentAggregates({@JsonKey(name: 'comment_id', fromJson: _toInt) this.commentId = 0, @JsonKey(fromJson: _toInt) this.score = 0, @JsonKey(fromJson: _toInt) this.upvotes = 0, @JsonKey(fromJson: _toInt) this.downvotes = 0, this.published = '', @JsonKey(name: 'child_count', fromJson: _toInt) this.childCount = 0});
  factory _CommentAggregates.fromJson(Map<String, dynamic> json) => _$CommentAggregatesFromJson(json);

@override@JsonKey(name: 'comment_id', fromJson: _toInt) final  int commentId;
@override@JsonKey(fromJson: _toInt) final  int score;
@override@JsonKey(fromJson: _toInt) final  int upvotes;
@override@JsonKey(fromJson: _toInt) final  int downvotes;
@override@JsonKey() final  String published;
@override@JsonKey(name: 'child_count', fromJson: _toInt) final  int childCount;

/// Create a copy of CommentAggregates
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentAggregatesCopyWith<_CommentAggregates> get copyWith => __$CommentAggregatesCopyWithImpl<_CommentAggregates>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentAggregates&&(identical(other.commentId, commentId) || other.commentId == commentId)&&(identical(other.score, score) || other.score == score)&&(identical(other.upvotes, upvotes) || other.upvotes == upvotes)&&(identical(other.downvotes, downvotes) || other.downvotes == downvotes)&&(identical(other.published, published) || other.published == published)&&(identical(other.childCount, childCount) || other.childCount == childCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,commentId,score,upvotes,downvotes,published,childCount);

@override
String toString() {
  return 'CommentAggregates(commentId: $commentId, score: $score, upvotes: $upvotes, downvotes: $downvotes, published: $published, childCount: $childCount)';
}


}

/// @nodoc
abstract mixin class _$CommentAggregatesCopyWith<$Res> implements $CommentAggregatesCopyWith<$Res> {
  factory _$CommentAggregatesCopyWith(_CommentAggregates value, $Res Function(_CommentAggregates) _then) = __$CommentAggregatesCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'comment_id', fromJson: _toInt) int commentId,@JsonKey(fromJson: _toInt) int score,@JsonKey(fromJson: _toInt) int upvotes,@JsonKey(fromJson: _toInt) int downvotes, String published,@JsonKey(name: 'child_count', fromJson: _toInt) int childCount
});




}
/// @nodoc
class __$CommentAggregatesCopyWithImpl<$Res>
    implements _$CommentAggregatesCopyWith<$Res> {
  __$CommentAggregatesCopyWithImpl(this._self, this._then);

  final _CommentAggregates _self;
  final $Res Function(_CommentAggregates) _then;

/// Create a copy of CommentAggregates
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? commentId = null,Object? score = null,Object? upvotes = null,Object? downvotes = null,Object? published = null,Object? childCount = null,}) {
  return _then(_CommentAggregates(
commentId: null == commentId ? _self.commentId : commentId // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,upvotes: null == upvotes ? _self.upvotes : upvotes // ignore: cast_nullable_to_non_nullable
as int,downvotes: null == downvotes ? _self.downvotes : downvotes // ignore: cast_nullable_to_non_nullable
as int,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,childCount: null == childCount ? _self.childCount : childCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CommentView {

 Comment get comment; Person get creator; Community get community; Post get post; CommentAggregates get counts;@JsonKey(name: 'creator_banned_from_community') bool get creatorBannedFromCommunity;@JsonKey(name: 'banned_from_community') bool get bannedFromCommunity;@JsonKey(name: 'creator_is_moderator') bool get creatorIsModerator;@JsonKey(name: 'creator_is_admin') bool get creatorIsAdmin;/// SubscribedType enum value, e.g. "Subscribed", "NotSubscribed", "Pending"
 String get subscribed; bool get saved;@JsonKey(name: 'creator_blocked') bool get creatorBlocked;/// Signed integer: 1 = upvoted, -1 = downvoted, null = not voted.
@JsonKey(name: 'my_vote', fromJson: _toNullableInt) int? get myVote;
/// Create a copy of CommentView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentViewCopyWith<CommentView> get copyWith => _$CommentViewCopyWithImpl<CommentView>(this as CommentView, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentView&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.community, community) || other.community == community)&&(identical(other.post, post) || other.post == post)&&(identical(other.counts, counts) || other.counts == counts)&&(identical(other.creatorBannedFromCommunity, creatorBannedFromCommunity) || other.creatorBannedFromCommunity == creatorBannedFromCommunity)&&(identical(other.bannedFromCommunity, bannedFromCommunity) || other.bannedFromCommunity == bannedFromCommunity)&&(identical(other.creatorIsModerator, creatorIsModerator) || other.creatorIsModerator == creatorIsModerator)&&(identical(other.creatorIsAdmin, creatorIsAdmin) || other.creatorIsAdmin == creatorIsAdmin)&&(identical(other.subscribed, subscribed) || other.subscribed == subscribed)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.creatorBlocked, creatorBlocked) || other.creatorBlocked == creatorBlocked)&&(identical(other.myVote, myVote) || other.myVote == myVote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,comment,creator,community,post,counts,creatorBannedFromCommunity,bannedFromCommunity,creatorIsModerator,creatorIsAdmin,subscribed,saved,creatorBlocked,myVote);

@override
String toString() {
  return 'CommentView(comment: $comment, creator: $creator, community: $community, post: $post, counts: $counts, creatorBannedFromCommunity: $creatorBannedFromCommunity, bannedFromCommunity: $bannedFromCommunity, creatorIsModerator: $creatorIsModerator, creatorIsAdmin: $creatorIsAdmin, subscribed: $subscribed, saved: $saved, creatorBlocked: $creatorBlocked, myVote: $myVote)';
}


}

/// @nodoc
abstract mixin class $CommentViewCopyWith<$Res>  {
  factory $CommentViewCopyWith(CommentView value, $Res Function(CommentView) _then) = _$CommentViewCopyWithImpl;
@useResult
$Res call({
 Comment comment, Person creator, Community community, Post post, CommentAggregates counts,@JsonKey(name: 'creator_banned_from_community') bool creatorBannedFromCommunity,@JsonKey(name: 'banned_from_community') bool bannedFromCommunity,@JsonKey(name: 'creator_is_moderator') bool creatorIsModerator,@JsonKey(name: 'creator_is_admin') bool creatorIsAdmin, String subscribed, bool saved,@JsonKey(name: 'creator_blocked') bool creatorBlocked,@JsonKey(name: 'my_vote', fromJson: _toNullableInt) int? myVote
});


$CommentCopyWith<$Res> get comment;$PersonCopyWith<$Res> get creator;$CommunityCopyWith<$Res> get community;$PostCopyWith<$Res> get post;$CommentAggregatesCopyWith<$Res> get counts;

}
/// @nodoc
class _$CommentViewCopyWithImpl<$Res>
    implements $CommentViewCopyWith<$Res> {
  _$CommentViewCopyWithImpl(this._self, this._then);

  final CommentView _self;
  final $Res Function(CommentView) _then;

/// Create a copy of CommentView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? comment = null,Object? creator = null,Object? community = null,Object? post = null,Object? counts = null,Object? creatorBannedFromCommunity = null,Object? bannedFromCommunity = null,Object? creatorIsModerator = null,Object? creatorIsAdmin = null,Object? subscribed = null,Object? saved = null,Object? creatorBlocked = null,Object? myVote = freezed,}) {
  return _then(_self.copyWith(
comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as Comment,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as Person,community: null == community ? _self.community : community // ignore: cast_nullable_to_non_nullable
as Community,post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as Post,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as CommentAggregates,creatorBannedFromCommunity: null == creatorBannedFromCommunity ? _self.creatorBannedFromCommunity : creatorBannedFromCommunity // ignore: cast_nullable_to_non_nullable
as bool,bannedFromCommunity: null == bannedFromCommunity ? _self.bannedFromCommunity : bannedFromCommunity // ignore: cast_nullable_to_non_nullable
as bool,creatorIsModerator: null == creatorIsModerator ? _self.creatorIsModerator : creatorIsModerator // ignore: cast_nullable_to_non_nullable
as bool,creatorIsAdmin: null == creatorIsAdmin ? _self.creatorIsAdmin : creatorIsAdmin // ignore: cast_nullable_to_non_nullable
as bool,subscribed: null == subscribed ? _self.subscribed : subscribed // ignore: cast_nullable_to_non_nullable
as String,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,creatorBlocked: null == creatorBlocked ? _self.creatorBlocked : creatorBlocked // ignore: cast_nullable_to_non_nullable
as bool,myVote: freezed == myVote ? _self.myVote : myVote // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of CommentView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentCopyWith<$Res> get comment {
  
  return $CommentCopyWith<$Res>(_self.comment, (value) {
    return _then(_self.copyWith(comment: value));
  });
}/// Create a copy of CommentView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get creator {
  
  return $PersonCopyWith<$Res>(_self.creator, (value) {
    return _then(_self.copyWith(creator: value));
  });
}/// Create a copy of CommentView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommunityCopyWith<$Res> get community {
  
  return $CommunityCopyWith<$Res>(_self.community, (value) {
    return _then(_self.copyWith(community: value));
  });
}/// Create a copy of CommentView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCopyWith<$Res> get post {
  
  return $PostCopyWith<$Res>(_self.post, (value) {
    return _then(_self.copyWith(post: value));
  });
}/// Create a copy of CommentView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentAggregatesCopyWith<$Res> get counts {
  
  return $CommentAggregatesCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}


/// Adds pattern-matching-related methods to [CommentView].
extension CommentViewPatterns on CommentView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentView value)  $default,){
final _that = this;
switch (_that) {
case _CommentView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentView value)?  $default,){
final _that = this;
switch (_that) {
case _CommentView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Comment comment,  Person creator,  Community community,  Post post,  CommentAggregates counts, @JsonKey(name: 'creator_banned_from_community')  bool creatorBannedFromCommunity, @JsonKey(name: 'banned_from_community')  bool bannedFromCommunity, @JsonKey(name: 'creator_is_moderator')  bool creatorIsModerator, @JsonKey(name: 'creator_is_admin')  bool creatorIsAdmin,  String subscribed,  bool saved, @JsonKey(name: 'creator_blocked')  bool creatorBlocked, @JsonKey(name: 'my_vote', fromJson: _toNullableInt)  int? myVote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentView() when $default != null:
return $default(_that.comment,_that.creator,_that.community,_that.post,_that.counts,_that.creatorBannedFromCommunity,_that.bannedFromCommunity,_that.creatorIsModerator,_that.creatorIsAdmin,_that.subscribed,_that.saved,_that.creatorBlocked,_that.myVote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Comment comment,  Person creator,  Community community,  Post post,  CommentAggregates counts, @JsonKey(name: 'creator_banned_from_community')  bool creatorBannedFromCommunity, @JsonKey(name: 'banned_from_community')  bool bannedFromCommunity, @JsonKey(name: 'creator_is_moderator')  bool creatorIsModerator, @JsonKey(name: 'creator_is_admin')  bool creatorIsAdmin,  String subscribed,  bool saved, @JsonKey(name: 'creator_blocked')  bool creatorBlocked, @JsonKey(name: 'my_vote', fromJson: _toNullableInt)  int? myVote)  $default,) {final _that = this;
switch (_that) {
case _CommentView():
return $default(_that.comment,_that.creator,_that.community,_that.post,_that.counts,_that.creatorBannedFromCommunity,_that.bannedFromCommunity,_that.creatorIsModerator,_that.creatorIsAdmin,_that.subscribed,_that.saved,_that.creatorBlocked,_that.myVote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Comment comment,  Person creator,  Community community,  Post post,  CommentAggregates counts, @JsonKey(name: 'creator_banned_from_community')  bool creatorBannedFromCommunity, @JsonKey(name: 'banned_from_community')  bool bannedFromCommunity, @JsonKey(name: 'creator_is_moderator')  bool creatorIsModerator, @JsonKey(name: 'creator_is_admin')  bool creatorIsAdmin,  String subscribed,  bool saved, @JsonKey(name: 'creator_blocked')  bool creatorBlocked, @JsonKey(name: 'my_vote', fromJson: _toNullableInt)  int? myVote)?  $default,) {final _that = this;
switch (_that) {
case _CommentView() when $default != null:
return $default(_that.comment,_that.creator,_that.community,_that.post,_that.counts,_that.creatorBannedFromCommunity,_that.bannedFromCommunity,_that.creatorIsModerator,_that.creatorIsAdmin,_that.subscribed,_that.saved,_that.creatorBlocked,_that.myVote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _CommentView implements CommentView {
  const _CommentView({required this.comment, required this.creator, required this.community, required this.post, required this.counts, @JsonKey(name: 'creator_banned_from_community') this.creatorBannedFromCommunity = false, @JsonKey(name: 'banned_from_community') this.bannedFromCommunity = false, @JsonKey(name: 'creator_is_moderator') this.creatorIsModerator = false, @JsonKey(name: 'creator_is_admin') this.creatorIsAdmin = false, this.subscribed = 'NotSubscribed', this.saved = false, @JsonKey(name: 'creator_blocked') this.creatorBlocked = false, @JsonKey(name: 'my_vote', fromJson: _toNullableInt) this.myVote});
  factory _CommentView.fromJson(Map<String, dynamic> json) => _$CommentViewFromJson(json);

@override final  Comment comment;
@override final  Person creator;
@override final  Community community;
@override final  Post post;
@override final  CommentAggregates counts;
@override@JsonKey(name: 'creator_banned_from_community') final  bool creatorBannedFromCommunity;
@override@JsonKey(name: 'banned_from_community') final  bool bannedFromCommunity;
@override@JsonKey(name: 'creator_is_moderator') final  bool creatorIsModerator;
@override@JsonKey(name: 'creator_is_admin') final  bool creatorIsAdmin;
/// SubscribedType enum value, e.g. "Subscribed", "NotSubscribed", "Pending"
@override@JsonKey() final  String subscribed;
@override@JsonKey() final  bool saved;
@override@JsonKey(name: 'creator_blocked') final  bool creatorBlocked;
/// Signed integer: 1 = upvoted, -1 = downvoted, null = not voted.
@override@JsonKey(name: 'my_vote', fromJson: _toNullableInt) final  int? myVote;

/// Create a copy of CommentView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentViewCopyWith<_CommentView> get copyWith => __$CommentViewCopyWithImpl<_CommentView>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentView&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.community, community) || other.community == community)&&(identical(other.post, post) || other.post == post)&&(identical(other.counts, counts) || other.counts == counts)&&(identical(other.creatorBannedFromCommunity, creatorBannedFromCommunity) || other.creatorBannedFromCommunity == creatorBannedFromCommunity)&&(identical(other.bannedFromCommunity, bannedFromCommunity) || other.bannedFromCommunity == bannedFromCommunity)&&(identical(other.creatorIsModerator, creatorIsModerator) || other.creatorIsModerator == creatorIsModerator)&&(identical(other.creatorIsAdmin, creatorIsAdmin) || other.creatorIsAdmin == creatorIsAdmin)&&(identical(other.subscribed, subscribed) || other.subscribed == subscribed)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.creatorBlocked, creatorBlocked) || other.creatorBlocked == creatorBlocked)&&(identical(other.myVote, myVote) || other.myVote == myVote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,comment,creator,community,post,counts,creatorBannedFromCommunity,bannedFromCommunity,creatorIsModerator,creatorIsAdmin,subscribed,saved,creatorBlocked,myVote);

@override
String toString() {
  return 'CommentView(comment: $comment, creator: $creator, community: $community, post: $post, counts: $counts, creatorBannedFromCommunity: $creatorBannedFromCommunity, bannedFromCommunity: $bannedFromCommunity, creatorIsModerator: $creatorIsModerator, creatorIsAdmin: $creatorIsAdmin, subscribed: $subscribed, saved: $saved, creatorBlocked: $creatorBlocked, myVote: $myVote)';
}


}

/// @nodoc
abstract mixin class _$CommentViewCopyWith<$Res> implements $CommentViewCopyWith<$Res> {
  factory _$CommentViewCopyWith(_CommentView value, $Res Function(_CommentView) _then) = __$CommentViewCopyWithImpl;
@override @useResult
$Res call({
 Comment comment, Person creator, Community community, Post post, CommentAggregates counts,@JsonKey(name: 'creator_banned_from_community') bool creatorBannedFromCommunity,@JsonKey(name: 'banned_from_community') bool bannedFromCommunity,@JsonKey(name: 'creator_is_moderator') bool creatorIsModerator,@JsonKey(name: 'creator_is_admin') bool creatorIsAdmin, String subscribed, bool saved,@JsonKey(name: 'creator_blocked') bool creatorBlocked,@JsonKey(name: 'my_vote', fromJson: _toNullableInt) int? myVote
});


@override $CommentCopyWith<$Res> get comment;@override $PersonCopyWith<$Res> get creator;@override $CommunityCopyWith<$Res> get community;@override $PostCopyWith<$Res> get post;@override $CommentAggregatesCopyWith<$Res> get counts;

}
/// @nodoc
class __$CommentViewCopyWithImpl<$Res>
    implements _$CommentViewCopyWith<$Res> {
  __$CommentViewCopyWithImpl(this._self, this._then);

  final _CommentView _self;
  final $Res Function(_CommentView) _then;

/// Create a copy of CommentView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? comment = null,Object? creator = null,Object? community = null,Object? post = null,Object? counts = null,Object? creatorBannedFromCommunity = null,Object? bannedFromCommunity = null,Object? creatorIsModerator = null,Object? creatorIsAdmin = null,Object? subscribed = null,Object? saved = null,Object? creatorBlocked = null,Object? myVote = freezed,}) {
  return _then(_CommentView(
comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as Comment,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as Person,community: null == community ? _self.community : community // ignore: cast_nullable_to_non_nullable
as Community,post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as Post,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as CommentAggregates,creatorBannedFromCommunity: null == creatorBannedFromCommunity ? _self.creatorBannedFromCommunity : creatorBannedFromCommunity // ignore: cast_nullable_to_non_nullable
as bool,bannedFromCommunity: null == bannedFromCommunity ? _self.bannedFromCommunity : bannedFromCommunity // ignore: cast_nullable_to_non_nullable
as bool,creatorIsModerator: null == creatorIsModerator ? _self.creatorIsModerator : creatorIsModerator // ignore: cast_nullable_to_non_nullable
as bool,creatorIsAdmin: null == creatorIsAdmin ? _self.creatorIsAdmin : creatorIsAdmin // ignore: cast_nullable_to_non_nullable
as bool,subscribed: null == subscribed ? _self.subscribed : subscribed // ignore: cast_nullable_to_non_nullable
as String,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,creatorBlocked: null == creatorBlocked ? _self.creatorBlocked : creatorBlocked // ignore: cast_nullable_to_non_nullable
as bool,myVote: freezed == myVote ? _self.myVote : myVote // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of CommentView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentCopyWith<$Res> get comment {
  
  return $CommentCopyWith<$Res>(_self.comment, (value) {
    return _then(_self.copyWith(comment: value));
  });
}/// Create a copy of CommentView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get creator {
  
  return $PersonCopyWith<$Res>(_self.creator, (value) {
    return _then(_self.copyWith(creator: value));
  });
}/// Create a copy of CommentView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommunityCopyWith<$Res> get community {
  
  return $CommunityCopyWith<$Res>(_self.community, (value) {
    return _then(_self.copyWith(community: value));
  });
}/// Create a copy of CommentView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCopyWith<$Res> get post {
  
  return $PostCopyWith<$Res>(_self.post, (value) {
    return _then(_self.copyWith(post: value));
  });
}/// Create a copy of CommentView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentAggregatesCopyWith<$Res> get counts {
  
  return $CommentAggregatesCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}

// dart format on
