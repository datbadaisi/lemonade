// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommentReply {

@JsonKey(fromJson: _toInt) int get id;@JsonKey(name: 'recipient_id', fromJson: _toInt) int get recipientId;@JsonKey(name: 'comment_id', fromJson: _toInt) int get commentId; bool get read; String get published;
/// Create a copy of CommentReply
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentReplyCopyWith<CommentReply> get copyWith => _$CommentReplyCopyWithImpl<CommentReply>(this as CommentReply, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentReply&&(identical(other.id, id) || other.id == id)&&(identical(other.recipientId, recipientId) || other.recipientId == recipientId)&&(identical(other.commentId, commentId) || other.commentId == commentId)&&(identical(other.read, read) || other.read == read)&&(identical(other.published, published) || other.published == published));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,recipientId,commentId,read,published);

@override
String toString() {
  return 'CommentReply(id: $id, recipientId: $recipientId, commentId: $commentId, read: $read, published: $published)';
}


}

/// @nodoc
abstract mixin class $CommentReplyCopyWith<$Res>  {
  factory $CommentReplyCopyWith(CommentReply value, $Res Function(CommentReply) _then) = _$CommentReplyCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _toInt) int id,@JsonKey(name: 'recipient_id', fromJson: _toInt) int recipientId,@JsonKey(name: 'comment_id', fromJson: _toInt) int commentId, bool read, String published
});




}
/// @nodoc
class _$CommentReplyCopyWithImpl<$Res>
    implements $CommentReplyCopyWith<$Res> {
  _$CommentReplyCopyWithImpl(this._self, this._then);

  final CommentReply _self;
  final $Res Function(CommentReply) _then;

/// Create a copy of CommentReply
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? recipientId = null,Object? commentId = null,Object? read = null,Object? published = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,recipientId: null == recipientId ? _self.recipientId : recipientId // ignore: cast_nullable_to_non_nullable
as int,commentId: null == commentId ? _self.commentId : commentId // ignore: cast_nullable_to_non_nullable
as int,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CommentReply].
extension CommentReplyPatterns on CommentReply {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentReply value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentReply() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentReply value)  $default,){
final _that = this;
switch (_that) {
case _CommentReply():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentReply value)?  $default,){
final _that = this;
switch (_that) {
case _CommentReply() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int id, @JsonKey(name: 'recipient_id', fromJson: _toInt)  int recipientId, @JsonKey(name: 'comment_id', fromJson: _toInt)  int commentId,  bool read,  String published)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentReply() when $default != null:
return $default(_that.id,_that.recipientId,_that.commentId,_that.read,_that.published);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int id, @JsonKey(name: 'recipient_id', fromJson: _toInt)  int recipientId, @JsonKey(name: 'comment_id', fromJson: _toInt)  int commentId,  bool read,  String published)  $default,) {final _that = this;
switch (_that) {
case _CommentReply():
return $default(_that.id,_that.recipientId,_that.commentId,_that.read,_that.published);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _toInt)  int id, @JsonKey(name: 'recipient_id', fromJson: _toInt)  int recipientId, @JsonKey(name: 'comment_id', fromJson: _toInt)  int commentId,  bool read,  String published)?  $default,) {final _that = this;
switch (_that) {
case _CommentReply() when $default != null:
return $default(_that.id,_that.recipientId,_that.commentId,_that.read,_that.published);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _CommentReply implements CommentReply {
  const _CommentReply({@JsonKey(fromJson: _toInt) this.id = 0, @JsonKey(name: 'recipient_id', fromJson: _toInt) this.recipientId = 0, @JsonKey(name: 'comment_id', fromJson: _toInt) this.commentId = 0, this.read = false, this.published = ''});
  factory _CommentReply.fromJson(Map<String, dynamic> json) => _$CommentReplyFromJson(json);

@override@JsonKey(fromJson: _toInt) final  int id;
@override@JsonKey(name: 'recipient_id', fromJson: _toInt) final  int recipientId;
@override@JsonKey(name: 'comment_id', fromJson: _toInt) final  int commentId;
@override@JsonKey() final  bool read;
@override@JsonKey() final  String published;

/// Create a copy of CommentReply
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentReplyCopyWith<_CommentReply> get copyWith => __$CommentReplyCopyWithImpl<_CommentReply>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentReply&&(identical(other.id, id) || other.id == id)&&(identical(other.recipientId, recipientId) || other.recipientId == recipientId)&&(identical(other.commentId, commentId) || other.commentId == commentId)&&(identical(other.read, read) || other.read == read)&&(identical(other.published, published) || other.published == published));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,recipientId,commentId,read,published);

@override
String toString() {
  return 'CommentReply(id: $id, recipientId: $recipientId, commentId: $commentId, read: $read, published: $published)';
}


}

/// @nodoc
abstract mixin class _$CommentReplyCopyWith<$Res> implements $CommentReplyCopyWith<$Res> {
  factory _$CommentReplyCopyWith(_CommentReply value, $Res Function(_CommentReply) _then) = __$CommentReplyCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _toInt) int id,@JsonKey(name: 'recipient_id', fromJson: _toInt) int recipientId,@JsonKey(name: 'comment_id', fromJson: _toInt) int commentId, bool read, String published
});




}
/// @nodoc
class __$CommentReplyCopyWithImpl<$Res>
    implements _$CommentReplyCopyWith<$Res> {
  __$CommentReplyCopyWithImpl(this._self, this._then);

  final _CommentReply _self;
  final $Res Function(_CommentReply) _then;

/// Create a copy of CommentReply
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? recipientId = null,Object? commentId = null,Object? read = null,Object? published = null,}) {
  return _then(_CommentReply(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,recipientId: null == recipientId ? _self.recipientId : recipientId // ignore: cast_nullable_to_non_nullable
as int,commentId: null == commentId ? _self.commentId : commentId // ignore: cast_nullable_to_non_nullable
as int,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CommentReplyView {

@JsonKey(name: 'comment_reply') CommentReply get commentReply; Comment get comment; Person get creator; Post get post; Community get community; Person get recipient; CommentAggregates get counts;@JsonKey(name: 'creator_banned_from_community') bool get creatorBannedFromCommunity;@JsonKey(name: 'banned_from_community') bool get bannedFromCommunity;@JsonKey(name: 'creator_is_moderator') bool get creatorIsModerator;@JsonKey(name: 'creator_is_admin') bool get creatorIsAdmin; String get subscribed; bool get saved;@JsonKey(name: 'creator_blocked') bool get creatorBlocked;@JsonKey(name: 'my_vote', fromJson: _toNullableInt) int? get myVote;
/// Create a copy of CommentReplyView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentReplyViewCopyWith<CommentReplyView> get copyWith => _$CommentReplyViewCopyWithImpl<CommentReplyView>(this as CommentReplyView, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentReplyView&&(identical(other.commentReply, commentReply) || other.commentReply == commentReply)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.post, post) || other.post == post)&&(identical(other.community, community) || other.community == community)&&(identical(other.recipient, recipient) || other.recipient == recipient)&&(identical(other.counts, counts) || other.counts == counts)&&(identical(other.creatorBannedFromCommunity, creatorBannedFromCommunity) || other.creatorBannedFromCommunity == creatorBannedFromCommunity)&&(identical(other.bannedFromCommunity, bannedFromCommunity) || other.bannedFromCommunity == bannedFromCommunity)&&(identical(other.creatorIsModerator, creatorIsModerator) || other.creatorIsModerator == creatorIsModerator)&&(identical(other.creatorIsAdmin, creatorIsAdmin) || other.creatorIsAdmin == creatorIsAdmin)&&(identical(other.subscribed, subscribed) || other.subscribed == subscribed)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.creatorBlocked, creatorBlocked) || other.creatorBlocked == creatorBlocked)&&(identical(other.myVote, myVote) || other.myVote == myVote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,commentReply,comment,creator,post,community,recipient,counts,creatorBannedFromCommunity,bannedFromCommunity,creatorIsModerator,creatorIsAdmin,subscribed,saved,creatorBlocked,myVote);

@override
String toString() {
  return 'CommentReplyView(commentReply: $commentReply, comment: $comment, creator: $creator, post: $post, community: $community, recipient: $recipient, counts: $counts, creatorBannedFromCommunity: $creatorBannedFromCommunity, bannedFromCommunity: $bannedFromCommunity, creatorIsModerator: $creatorIsModerator, creatorIsAdmin: $creatorIsAdmin, subscribed: $subscribed, saved: $saved, creatorBlocked: $creatorBlocked, myVote: $myVote)';
}


}

/// @nodoc
abstract mixin class $CommentReplyViewCopyWith<$Res>  {
  factory $CommentReplyViewCopyWith(CommentReplyView value, $Res Function(CommentReplyView) _then) = _$CommentReplyViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'comment_reply') CommentReply commentReply, Comment comment, Person creator, Post post, Community community, Person recipient, CommentAggregates counts,@JsonKey(name: 'creator_banned_from_community') bool creatorBannedFromCommunity,@JsonKey(name: 'banned_from_community') bool bannedFromCommunity,@JsonKey(name: 'creator_is_moderator') bool creatorIsModerator,@JsonKey(name: 'creator_is_admin') bool creatorIsAdmin, String subscribed, bool saved,@JsonKey(name: 'creator_blocked') bool creatorBlocked,@JsonKey(name: 'my_vote', fromJson: _toNullableInt) int? myVote
});


$CommentReplyCopyWith<$Res> get commentReply;$CommentCopyWith<$Res> get comment;$PersonCopyWith<$Res> get creator;$PostCopyWith<$Res> get post;$CommunityCopyWith<$Res> get community;$PersonCopyWith<$Res> get recipient;$CommentAggregatesCopyWith<$Res> get counts;

}
/// @nodoc
class _$CommentReplyViewCopyWithImpl<$Res>
    implements $CommentReplyViewCopyWith<$Res> {
  _$CommentReplyViewCopyWithImpl(this._self, this._then);

  final CommentReplyView _self;
  final $Res Function(CommentReplyView) _then;

/// Create a copy of CommentReplyView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? commentReply = null,Object? comment = null,Object? creator = null,Object? post = null,Object? community = null,Object? recipient = null,Object? counts = null,Object? creatorBannedFromCommunity = null,Object? bannedFromCommunity = null,Object? creatorIsModerator = null,Object? creatorIsAdmin = null,Object? subscribed = null,Object? saved = null,Object? creatorBlocked = null,Object? myVote = freezed,}) {
  return _then(_self.copyWith(
commentReply: null == commentReply ? _self.commentReply : commentReply // ignore: cast_nullable_to_non_nullable
as CommentReply,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as Comment,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as Person,post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as Post,community: null == community ? _self.community : community // ignore: cast_nullable_to_non_nullable
as Community,recipient: null == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as Person,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
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
/// Create a copy of CommentReplyView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentReplyCopyWith<$Res> get commentReply {
  
  return $CommentReplyCopyWith<$Res>(_self.commentReply, (value) {
    return _then(_self.copyWith(commentReply: value));
  });
}/// Create a copy of CommentReplyView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentCopyWith<$Res> get comment {
  
  return $CommentCopyWith<$Res>(_self.comment, (value) {
    return _then(_self.copyWith(comment: value));
  });
}/// Create a copy of CommentReplyView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get creator {
  
  return $PersonCopyWith<$Res>(_self.creator, (value) {
    return _then(_self.copyWith(creator: value));
  });
}/// Create a copy of CommentReplyView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCopyWith<$Res> get post {
  
  return $PostCopyWith<$Res>(_self.post, (value) {
    return _then(_self.copyWith(post: value));
  });
}/// Create a copy of CommentReplyView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommunityCopyWith<$Res> get community {
  
  return $CommunityCopyWith<$Res>(_self.community, (value) {
    return _then(_self.copyWith(community: value));
  });
}/// Create a copy of CommentReplyView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get recipient {
  
  return $PersonCopyWith<$Res>(_self.recipient, (value) {
    return _then(_self.copyWith(recipient: value));
  });
}/// Create a copy of CommentReplyView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentAggregatesCopyWith<$Res> get counts {
  
  return $CommentAggregatesCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}


/// Adds pattern-matching-related methods to [CommentReplyView].
extension CommentReplyViewPatterns on CommentReplyView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentReplyView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentReplyView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentReplyView value)  $default,){
final _that = this;
switch (_that) {
case _CommentReplyView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentReplyView value)?  $default,){
final _that = this;
switch (_that) {
case _CommentReplyView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'comment_reply')  CommentReply commentReply,  Comment comment,  Person creator,  Post post,  Community community,  Person recipient,  CommentAggregates counts, @JsonKey(name: 'creator_banned_from_community')  bool creatorBannedFromCommunity, @JsonKey(name: 'banned_from_community')  bool bannedFromCommunity, @JsonKey(name: 'creator_is_moderator')  bool creatorIsModerator, @JsonKey(name: 'creator_is_admin')  bool creatorIsAdmin,  String subscribed,  bool saved, @JsonKey(name: 'creator_blocked')  bool creatorBlocked, @JsonKey(name: 'my_vote', fromJson: _toNullableInt)  int? myVote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentReplyView() when $default != null:
return $default(_that.commentReply,_that.comment,_that.creator,_that.post,_that.community,_that.recipient,_that.counts,_that.creatorBannedFromCommunity,_that.bannedFromCommunity,_that.creatorIsModerator,_that.creatorIsAdmin,_that.subscribed,_that.saved,_that.creatorBlocked,_that.myVote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'comment_reply')  CommentReply commentReply,  Comment comment,  Person creator,  Post post,  Community community,  Person recipient,  CommentAggregates counts, @JsonKey(name: 'creator_banned_from_community')  bool creatorBannedFromCommunity, @JsonKey(name: 'banned_from_community')  bool bannedFromCommunity, @JsonKey(name: 'creator_is_moderator')  bool creatorIsModerator, @JsonKey(name: 'creator_is_admin')  bool creatorIsAdmin,  String subscribed,  bool saved, @JsonKey(name: 'creator_blocked')  bool creatorBlocked, @JsonKey(name: 'my_vote', fromJson: _toNullableInt)  int? myVote)  $default,) {final _that = this;
switch (_that) {
case _CommentReplyView():
return $default(_that.commentReply,_that.comment,_that.creator,_that.post,_that.community,_that.recipient,_that.counts,_that.creatorBannedFromCommunity,_that.bannedFromCommunity,_that.creatorIsModerator,_that.creatorIsAdmin,_that.subscribed,_that.saved,_that.creatorBlocked,_that.myVote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'comment_reply')  CommentReply commentReply,  Comment comment,  Person creator,  Post post,  Community community,  Person recipient,  CommentAggregates counts, @JsonKey(name: 'creator_banned_from_community')  bool creatorBannedFromCommunity, @JsonKey(name: 'banned_from_community')  bool bannedFromCommunity, @JsonKey(name: 'creator_is_moderator')  bool creatorIsModerator, @JsonKey(name: 'creator_is_admin')  bool creatorIsAdmin,  String subscribed,  bool saved, @JsonKey(name: 'creator_blocked')  bool creatorBlocked, @JsonKey(name: 'my_vote', fromJson: _toNullableInt)  int? myVote)?  $default,) {final _that = this;
switch (_that) {
case _CommentReplyView() when $default != null:
return $default(_that.commentReply,_that.comment,_that.creator,_that.post,_that.community,_that.recipient,_that.counts,_that.creatorBannedFromCommunity,_that.bannedFromCommunity,_that.creatorIsModerator,_that.creatorIsAdmin,_that.subscribed,_that.saved,_that.creatorBlocked,_that.myVote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _CommentReplyView implements CommentReplyView {
  const _CommentReplyView({@JsonKey(name: 'comment_reply') required this.commentReply, required this.comment, required this.creator, required this.post, required this.community, required this.recipient, required this.counts, @JsonKey(name: 'creator_banned_from_community') this.creatorBannedFromCommunity = false, @JsonKey(name: 'banned_from_community') this.bannedFromCommunity = false, @JsonKey(name: 'creator_is_moderator') this.creatorIsModerator = false, @JsonKey(name: 'creator_is_admin') this.creatorIsAdmin = false, this.subscribed = 'NotSubscribed', this.saved = false, @JsonKey(name: 'creator_blocked') this.creatorBlocked = false, @JsonKey(name: 'my_vote', fromJson: _toNullableInt) this.myVote});
  factory _CommentReplyView.fromJson(Map<String, dynamic> json) => _$CommentReplyViewFromJson(json);

@override@JsonKey(name: 'comment_reply') final  CommentReply commentReply;
@override final  Comment comment;
@override final  Person creator;
@override final  Post post;
@override final  Community community;
@override final  Person recipient;
@override final  CommentAggregates counts;
@override@JsonKey(name: 'creator_banned_from_community') final  bool creatorBannedFromCommunity;
@override@JsonKey(name: 'banned_from_community') final  bool bannedFromCommunity;
@override@JsonKey(name: 'creator_is_moderator') final  bool creatorIsModerator;
@override@JsonKey(name: 'creator_is_admin') final  bool creatorIsAdmin;
@override@JsonKey() final  String subscribed;
@override@JsonKey() final  bool saved;
@override@JsonKey(name: 'creator_blocked') final  bool creatorBlocked;
@override@JsonKey(name: 'my_vote', fromJson: _toNullableInt) final  int? myVote;

/// Create a copy of CommentReplyView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentReplyViewCopyWith<_CommentReplyView> get copyWith => __$CommentReplyViewCopyWithImpl<_CommentReplyView>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentReplyView&&(identical(other.commentReply, commentReply) || other.commentReply == commentReply)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.post, post) || other.post == post)&&(identical(other.community, community) || other.community == community)&&(identical(other.recipient, recipient) || other.recipient == recipient)&&(identical(other.counts, counts) || other.counts == counts)&&(identical(other.creatorBannedFromCommunity, creatorBannedFromCommunity) || other.creatorBannedFromCommunity == creatorBannedFromCommunity)&&(identical(other.bannedFromCommunity, bannedFromCommunity) || other.bannedFromCommunity == bannedFromCommunity)&&(identical(other.creatorIsModerator, creatorIsModerator) || other.creatorIsModerator == creatorIsModerator)&&(identical(other.creatorIsAdmin, creatorIsAdmin) || other.creatorIsAdmin == creatorIsAdmin)&&(identical(other.subscribed, subscribed) || other.subscribed == subscribed)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.creatorBlocked, creatorBlocked) || other.creatorBlocked == creatorBlocked)&&(identical(other.myVote, myVote) || other.myVote == myVote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,commentReply,comment,creator,post,community,recipient,counts,creatorBannedFromCommunity,bannedFromCommunity,creatorIsModerator,creatorIsAdmin,subscribed,saved,creatorBlocked,myVote);

@override
String toString() {
  return 'CommentReplyView(commentReply: $commentReply, comment: $comment, creator: $creator, post: $post, community: $community, recipient: $recipient, counts: $counts, creatorBannedFromCommunity: $creatorBannedFromCommunity, bannedFromCommunity: $bannedFromCommunity, creatorIsModerator: $creatorIsModerator, creatorIsAdmin: $creatorIsAdmin, subscribed: $subscribed, saved: $saved, creatorBlocked: $creatorBlocked, myVote: $myVote)';
}


}

/// @nodoc
abstract mixin class _$CommentReplyViewCopyWith<$Res> implements $CommentReplyViewCopyWith<$Res> {
  factory _$CommentReplyViewCopyWith(_CommentReplyView value, $Res Function(_CommentReplyView) _then) = __$CommentReplyViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'comment_reply') CommentReply commentReply, Comment comment, Person creator, Post post, Community community, Person recipient, CommentAggregates counts,@JsonKey(name: 'creator_banned_from_community') bool creatorBannedFromCommunity,@JsonKey(name: 'banned_from_community') bool bannedFromCommunity,@JsonKey(name: 'creator_is_moderator') bool creatorIsModerator,@JsonKey(name: 'creator_is_admin') bool creatorIsAdmin, String subscribed, bool saved,@JsonKey(name: 'creator_blocked') bool creatorBlocked,@JsonKey(name: 'my_vote', fromJson: _toNullableInt) int? myVote
});


@override $CommentReplyCopyWith<$Res> get commentReply;@override $CommentCopyWith<$Res> get comment;@override $PersonCopyWith<$Res> get creator;@override $PostCopyWith<$Res> get post;@override $CommunityCopyWith<$Res> get community;@override $PersonCopyWith<$Res> get recipient;@override $CommentAggregatesCopyWith<$Res> get counts;

}
/// @nodoc
class __$CommentReplyViewCopyWithImpl<$Res>
    implements _$CommentReplyViewCopyWith<$Res> {
  __$CommentReplyViewCopyWithImpl(this._self, this._then);

  final _CommentReplyView _self;
  final $Res Function(_CommentReplyView) _then;

/// Create a copy of CommentReplyView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? commentReply = null,Object? comment = null,Object? creator = null,Object? post = null,Object? community = null,Object? recipient = null,Object? counts = null,Object? creatorBannedFromCommunity = null,Object? bannedFromCommunity = null,Object? creatorIsModerator = null,Object? creatorIsAdmin = null,Object? subscribed = null,Object? saved = null,Object? creatorBlocked = null,Object? myVote = freezed,}) {
  return _then(_CommentReplyView(
commentReply: null == commentReply ? _self.commentReply : commentReply // ignore: cast_nullable_to_non_nullable
as CommentReply,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as Comment,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as Person,post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as Post,community: null == community ? _self.community : community // ignore: cast_nullable_to_non_nullable
as Community,recipient: null == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as Person,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
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

/// Create a copy of CommentReplyView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentReplyCopyWith<$Res> get commentReply {
  
  return $CommentReplyCopyWith<$Res>(_self.commentReply, (value) {
    return _then(_self.copyWith(commentReply: value));
  });
}/// Create a copy of CommentReplyView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentCopyWith<$Res> get comment {
  
  return $CommentCopyWith<$Res>(_self.comment, (value) {
    return _then(_self.copyWith(comment: value));
  });
}/// Create a copy of CommentReplyView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get creator {
  
  return $PersonCopyWith<$Res>(_self.creator, (value) {
    return _then(_self.copyWith(creator: value));
  });
}/// Create a copy of CommentReplyView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCopyWith<$Res> get post {
  
  return $PostCopyWith<$Res>(_self.post, (value) {
    return _then(_self.copyWith(post: value));
  });
}/// Create a copy of CommentReplyView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommunityCopyWith<$Res> get community {
  
  return $CommunityCopyWith<$Res>(_self.community, (value) {
    return _then(_self.copyWith(community: value));
  });
}/// Create a copy of CommentReplyView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get recipient {
  
  return $PersonCopyWith<$Res>(_self.recipient, (value) {
    return _then(_self.copyWith(recipient: value));
  });
}/// Create a copy of CommentReplyView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentAggregatesCopyWith<$Res> get counts {
  
  return $CommentAggregatesCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}


/// @nodoc
mixin _$PersonMention {

@JsonKey(fromJson: _toInt) int get id;@JsonKey(name: 'recipient_id', fromJson: _toInt) int get recipientId;@JsonKey(name: 'comment_id', fromJson: _toInt) int get commentId; bool get read; String get published;
/// Create a copy of PersonMention
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonMentionCopyWith<PersonMention> get copyWith => _$PersonMentionCopyWithImpl<PersonMention>(this as PersonMention, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonMention&&(identical(other.id, id) || other.id == id)&&(identical(other.recipientId, recipientId) || other.recipientId == recipientId)&&(identical(other.commentId, commentId) || other.commentId == commentId)&&(identical(other.read, read) || other.read == read)&&(identical(other.published, published) || other.published == published));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,recipientId,commentId,read,published);

@override
String toString() {
  return 'PersonMention(id: $id, recipientId: $recipientId, commentId: $commentId, read: $read, published: $published)';
}


}

/// @nodoc
abstract mixin class $PersonMentionCopyWith<$Res>  {
  factory $PersonMentionCopyWith(PersonMention value, $Res Function(PersonMention) _then) = _$PersonMentionCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _toInt) int id,@JsonKey(name: 'recipient_id', fromJson: _toInt) int recipientId,@JsonKey(name: 'comment_id', fromJson: _toInt) int commentId, bool read, String published
});




}
/// @nodoc
class _$PersonMentionCopyWithImpl<$Res>
    implements $PersonMentionCopyWith<$Res> {
  _$PersonMentionCopyWithImpl(this._self, this._then);

  final PersonMention _self;
  final $Res Function(PersonMention) _then;

/// Create a copy of PersonMention
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? recipientId = null,Object? commentId = null,Object? read = null,Object? published = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,recipientId: null == recipientId ? _self.recipientId : recipientId // ignore: cast_nullable_to_non_nullable
as int,commentId: null == commentId ? _self.commentId : commentId // ignore: cast_nullable_to_non_nullable
as int,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonMention].
extension PersonMentionPatterns on PersonMention {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonMention value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonMention() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonMention value)  $default,){
final _that = this;
switch (_that) {
case _PersonMention():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonMention value)?  $default,){
final _that = this;
switch (_that) {
case _PersonMention() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int id, @JsonKey(name: 'recipient_id', fromJson: _toInt)  int recipientId, @JsonKey(name: 'comment_id', fromJson: _toInt)  int commentId,  bool read,  String published)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonMention() when $default != null:
return $default(_that.id,_that.recipientId,_that.commentId,_that.read,_that.published);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int id, @JsonKey(name: 'recipient_id', fromJson: _toInt)  int recipientId, @JsonKey(name: 'comment_id', fromJson: _toInt)  int commentId,  bool read,  String published)  $default,) {final _that = this;
switch (_that) {
case _PersonMention():
return $default(_that.id,_that.recipientId,_that.commentId,_that.read,_that.published);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _toInt)  int id, @JsonKey(name: 'recipient_id', fromJson: _toInt)  int recipientId, @JsonKey(name: 'comment_id', fromJson: _toInt)  int commentId,  bool read,  String published)?  $default,) {final _that = this;
switch (_that) {
case _PersonMention() when $default != null:
return $default(_that.id,_that.recipientId,_that.commentId,_that.read,_that.published);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _PersonMention implements PersonMention {
  const _PersonMention({@JsonKey(fromJson: _toInt) this.id = 0, @JsonKey(name: 'recipient_id', fromJson: _toInt) this.recipientId = 0, @JsonKey(name: 'comment_id', fromJson: _toInt) this.commentId = 0, this.read = false, this.published = ''});
  factory _PersonMention.fromJson(Map<String, dynamic> json) => _$PersonMentionFromJson(json);

@override@JsonKey(fromJson: _toInt) final  int id;
@override@JsonKey(name: 'recipient_id', fromJson: _toInt) final  int recipientId;
@override@JsonKey(name: 'comment_id', fromJson: _toInt) final  int commentId;
@override@JsonKey() final  bool read;
@override@JsonKey() final  String published;

/// Create a copy of PersonMention
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonMentionCopyWith<_PersonMention> get copyWith => __$PersonMentionCopyWithImpl<_PersonMention>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonMention&&(identical(other.id, id) || other.id == id)&&(identical(other.recipientId, recipientId) || other.recipientId == recipientId)&&(identical(other.commentId, commentId) || other.commentId == commentId)&&(identical(other.read, read) || other.read == read)&&(identical(other.published, published) || other.published == published));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,recipientId,commentId,read,published);

@override
String toString() {
  return 'PersonMention(id: $id, recipientId: $recipientId, commentId: $commentId, read: $read, published: $published)';
}


}

/// @nodoc
abstract mixin class _$PersonMentionCopyWith<$Res> implements $PersonMentionCopyWith<$Res> {
  factory _$PersonMentionCopyWith(_PersonMention value, $Res Function(_PersonMention) _then) = __$PersonMentionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _toInt) int id,@JsonKey(name: 'recipient_id', fromJson: _toInt) int recipientId,@JsonKey(name: 'comment_id', fromJson: _toInt) int commentId, bool read, String published
});




}
/// @nodoc
class __$PersonMentionCopyWithImpl<$Res>
    implements _$PersonMentionCopyWith<$Res> {
  __$PersonMentionCopyWithImpl(this._self, this._then);

  final _PersonMention _self;
  final $Res Function(_PersonMention) _then;

/// Create a copy of PersonMention
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? recipientId = null,Object? commentId = null,Object? read = null,Object? published = null,}) {
  return _then(_PersonMention(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,recipientId: null == recipientId ? _self.recipientId : recipientId // ignore: cast_nullable_to_non_nullable
as int,commentId: null == commentId ? _self.commentId : commentId // ignore: cast_nullable_to_non_nullable
as int,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PersonMentionView {

@JsonKey(name: 'person_mention') PersonMention get personMention; Comment get comment; Person get creator; Post get post; Community get community; Person get recipient; CommentAggregates get counts;@JsonKey(name: 'creator_banned_from_community') bool get creatorBannedFromCommunity;@JsonKey(name: 'banned_from_community') bool get bannedFromCommunity;@JsonKey(name: 'creator_is_moderator') bool get creatorIsModerator;@JsonKey(name: 'creator_is_admin') bool get creatorIsAdmin; String get subscribed; bool get saved;@JsonKey(name: 'creator_blocked') bool get creatorBlocked;@JsonKey(name: 'my_vote', fromJson: _toNullableInt) int? get myVote;
/// Create a copy of PersonMentionView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonMentionViewCopyWith<PersonMentionView> get copyWith => _$PersonMentionViewCopyWithImpl<PersonMentionView>(this as PersonMentionView, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonMentionView&&(identical(other.personMention, personMention) || other.personMention == personMention)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.post, post) || other.post == post)&&(identical(other.community, community) || other.community == community)&&(identical(other.recipient, recipient) || other.recipient == recipient)&&(identical(other.counts, counts) || other.counts == counts)&&(identical(other.creatorBannedFromCommunity, creatorBannedFromCommunity) || other.creatorBannedFromCommunity == creatorBannedFromCommunity)&&(identical(other.bannedFromCommunity, bannedFromCommunity) || other.bannedFromCommunity == bannedFromCommunity)&&(identical(other.creatorIsModerator, creatorIsModerator) || other.creatorIsModerator == creatorIsModerator)&&(identical(other.creatorIsAdmin, creatorIsAdmin) || other.creatorIsAdmin == creatorIsAdmin)&&(identical(other.subscribed, subscribed) || other.subscribed == subscribed)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.creatorBlocked, creatorBlocked) || other.creatorBlocked == creatorBlocked)&&(identical(other.myVote, myVote) || other.myVote == myVote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,personMention,comment,creator,post,community,recipient,counts,creatorBannedFromCommunity,bannedFromCommunity,creatorIsModerator,creatorIsAdmin,subscribed,saved,creatorBlocked,myVote);

@override
String toString() {
  return 'PersonMentionView(personMention: $personMention, comment: $comment, creator: $creator, post: $post, community: $community, recipient: $recipient, counts: $counts, creatorBannedFromCommunity: $creatorBannedFromCommunity, bannedFromCommunity: $bannedFromCommunity, creatorIsModerator: $creatorIsModerator, creatorIsAdmin: $creatorIsAdmin, subscribed: $subscribed, saved: $saved, creatorBlocked: $creatorBlocked, myVote: $myVote)';
}


}

/// @nodoc
abstract mixin class $PersonMentionViewCopyWith<$Res>  {
  factory $PersonMentionViewCopyWith(PersonMentionView value, $Res Function(PersonMentionView) _then) = _$PersonMentionViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'person_mention') PersonMention personMention, Comment comment, Person creator, Post post, Community community, Person recipient, CommentAggregates counts,@JsonKey(name: 'creator_banned_from_community') bool creatorBannedFromCommunity,@JsonKey(name: 'banned_from_community') bool bannedFromCommunity,@JsonKey(name: 'creator_is_moderator') bool creatorIsModerator,@JsonKey(name: 'creator_is_admin') bool creatorIsAdmin, String subscribed, bool saved,@JsonKey(name: 'creator_blocked') bool creatorBlocked,@JsonKey(name: 'my_vote', fromJson: _toNullableInt) int? myVote
});


$PersonMentionCopyWith<$Res> get personMention;$CommentCopyWith<$Res> get comment;$PersonCopyWith<$Res> get creator;$PostCopyWith<$Res> get post;$CommunityCopyWith<$Res> get community;$PersonCopyWith<$Res> get recipient;$CommentAggregatesCopyWith<$Res> get counts;

}
/// @nodoc
class _$PersonMentionViewCopyWithImpl<$Res>
    implements $PersonMentionViewCopyWith<$Res> {
  _$PersonMentionViewCopyWithImpl(this._self, this._then);

  final PersonMentionView _self;
  final $Res Function(PersonMentionView) _then;

/// Create a copy of PersonMentionView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? personMention = null,Object? comment = null,Object? creator = null,Object? post = null,Object? community = null,Object? recipient = null,Object? counts = null,Object? creatorBannedFromCommunity = null,Object? bannedFromCommunity = null,Object? creatorIsModerator = null,Object? creatorIsAdmin = null,Object? subscribed = null,Object? saved = null,Object? creatorBlocked = null,Object? myVote = freezed,}) {
  return _then(_self.copyWith(
personMention: null == personMention ? _self.personMention : personMention // ignore: cast_nullable_to_non_nullable
as PersonMention,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as Comment,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as Person,post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as Post,community: null == community ? _self.community : community // ignore: cast_nullable_to_non_nullable
as Community,recipient: null == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as Person,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
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
/// Create a copy of PersonMentionView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonMentionCopyWith<$Res> get personMention {
  
  return $PersonMentionCopyWith<$Res>(_self.personMention, (value) {
    return _then(_self.copyWith(personMention: value));
  });
}/// Create a copy of PersonMentionView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentCopyWith<$Res> get comment {
  
  return $CommentCopyWith<$Res>(_self.comment, (value) {
    return _then(_self.copyWith(comment: value));
  });
}/// Create a copy of PersonMentionView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get creator {
  
  return $PersonCopyWith<$Res>(_self.creator, (value) {
    return _then(_self.copyWith(creator: value));
  });
}/// Create a copy of PersonMentionView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCopyWith<$Res> get post {
  
  return $PostCopyWith<$Res>(_self.post, (value) {
    return _then(_self.copyWith(post: value));
  });
}/// Create a copy of PersonMentionView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommunityCopyWith<$Res> get community {
  
  return $CommunityCopyWith<$Res>(_self.community, (value) {
    return _then(_self.copyWith(community: value));
  });
}/// Create a copy of PersonMentionView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get recipient {
  
  return $PersonCopyWith<$Res>(_self.recipient, (value) {
    return _then(_self.copyWith(recipient: value));
  });
}/// Create a copy of PersonMentionView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentAggregatesCopyWith<$Res> get counts {
  
  return $CommentAggregatesCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}


/// Adds pattern-matching-related methods to [PersonMentionView].
extension PersonMentionViewPatterns on PersonMentionView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonMentionView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonMentionView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonMentionView value)  $default,){
final _that = this;
switch (_that) {
case _PersonMentionView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonMentionView value)?  $default,){
final _that = this;
switch (_that) {
case _PersonMentionView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'person_mention')  PersonMention personMention,  Comment comment,  Person creator,  Post post,  Community community,  Person recipient,  CommentAggregates counts, @JsonKey(name: 'creator_banned_from_community')  bool creatorBannedFromCommunity, @JsonKey(name: 'banned_from_community')  bool bannedFromCommunity, @JsonKey(name: 'creator_is_moderator')  bool creatorIsModerator, @JsonKey(name: 'creator_is_admin')  bool creatorIsAdmin,  String subscribed,  bool saved, @JsonKey(name: 'creator_blocked')  bool creatorBlocked, @JsonKey(name: 'my_vote', fromJson: _toNullableInt)  int? myVote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonMentionView() when $default != null:
return $default(_that.personMention,_that.comment,_that.creator,_that.post,_that.community,_that.recipient,_that.counts,_that.creatorBannedFromCommunity,_that.bannedFromCommunity,_that.creatorIsModerator,_that.creatorIsAdmin,_that.subscribed,_that.saved,_that.creatorBlocked,_that.myVote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'person_mention')  PersonMention personMention,  Comment comment,  Person creator,  Post post,  Community community,  Person recipient,  CommentAggregates counts, @JsonKey(name: 'creator_banned_from_community')  bool creatorBannedFromCommunity, @JsonKey(name: 'banned_from_community')  bool bannedFromCommunity, @JsonKey(name: 'creator_is_moderator')  bool creatorIsModerator, @JsonKey(name: 'creator_is_admin')  bool creatorIsAdmin,  String subscribed,  bool saved, @JsonKey(name: 'creator_blocked')  bool creatorBlocked, @JsonKey(name: 'my_vote', fromJson: _toNullableInt)  int? myVote)  $default,) {final _that = this;
switch (_that) {
case _PersonMentionView():
return $default(_that.personMention,_that.comment,_that.creator,_that.post,_that.community,_that.recipient,_that.counts,_that.creatorBannedFromCommunity,_that.bannedFromCommunity,_that.creatorIsModerator,_that.creatorIsAdmin,_that.subscribed,_that.saved,_that.creatorBlocked,_that.myVote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'person_mention')  PersonMention personMention,  Comment comment,  Person creator,  Post post,  Community community,  Person recipient,  CommentAggregates counts, @JsonKey(name: 'creator_banned_from_community')  bool creatorBannedFromCommunity, @JsonKey(name: 'banned_from_community')  bool bannedFromCommunity, @JsonKey(name: 'creator_is_moderator')  bool creatorIsModerator, @JsonKey(name: 'creator_is_admin')  bool creatorIsAdmin,  String subscribed,  bool saved, @JsonKey(name: 'creator_blocked')  bool creatorBlocked, @JsonKey(name: 'my_vote', fromJson: _toNullableInt)  int? myVote)?  $default,) {final _that = this;
switch (_that) {
case _PersonMentionView() when $default != null:
return $default(_that.personMention,_that.comment,_that.creator,_that.post,_that.community,_that.recipient,_that.counts,_that.creatorBannedFromCommunity,_that.bannedFromCommunity,_that.creatorIsModerator,_that.creatorIsAdmin,_that.subscribed,_that.saved,_that.creatorBlocked,_that.myVote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _PersonMentionView implements PersonMentionView {
  const _PersonMentionView({@JsonKey(name: 'person_mention') required this.personMention, required this.comment, required this.creator, required this.post, required this.community, required this.recipient, required this.counts, @JsonKey(name: 'creator_banned_from_community') this.creatorBannedFromCommunity = false, @JsonKey(name: 'banned_from_community') this.bannedFromCommunity = false, @JsonKey(name: 'creator_is_moderator') this.creatorIsModerator = false, @JsonKey(name: 'creator_is_admin') this.creatorIsAdmin = false, this.subscribed = 'NotSubscribed', this.saved = false, @JsonKey(name: 'creator_blocked') this.creatorBlocked = false, @JsonKey(name: 'my_vote', fromJson: _toNullableInt) this.myVote});
  factory _PersonMentionView.fromJson(Map<String, dynamic> json) => _$PersonMentionViewFromJson(json);

@override@JsonKey(name: 'person_mention') final  PersonMention personMention;
@override final  Comment comment;
@override final  Person creator;
@override final  Post post;
@override final  Community community;
@override final  Person recipient;
@override final  CommentAggregates counts;
@override@JsonKey(name: 'creator_banned_from_community') final  bool creatorBannedFromCommunity;
@override@JsonKey(name: 'banned_from_community') final  bool bannedFromCommunity;
@override@JsonKey(name: 'creator_is_moderator') final  bool creatorIsModerator;
@override@JsonKey(name: 'creator_is_admin') final  bool creatorIsAdmin;
@override@JsonKey() final  String subscribed;
@override@JsonKey() final  bool saved;
@override@JsonKey(name: 'creator_blocked') final  bool creatorBlocked;
@override@JsonKey(name: 'my_vote', fromJson: _toNullableInt) final  int? myVote;

/// Create a copy of PersonMentionView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonMentionViewCopyWith<_PersonMentionView> get copyWith => __$PersonMentionViewCopyWithImpl<_PersonMentionView>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonMentionView&&(identical(other.personMention, personMention) || other.personMention == personMention)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.post, post) || other.post == post)&&(identical(other.community, community) || other.community == community)&&(identical(other.recipient, recipient) || other.recipient == recipient)&&(identical(other.counts, counts) || other.counts == counts)&&(identical(other.creatorBannedFromCommunity, creatorBannedFromCommunity) || other.creatorBannedFromCommunity == creatorBannedFromCommunity)&&(identical(other.bannedFromCommunity, bannedFromCommunity) || other.bannedFromCommunity == bannedFromCommunity)&&(identical(other.creatorIsModerator, creatorIsModerator) || other.creatorIsModerator == creatorIsModerator)&&(identical(other.creatorIsAdmin, creatorIsAdmin) || other.creatorIsAdmin == creatorIsAdmin)&&(identical(other.subscribed, subscribed) || other.subscribed == subscribed)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.creatorBlocked, creatorBlocked) || other.creatorBlocked == creatorBlocked)&&(identical(other.myVote, myVote) || other.myVote == myVote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,personMention,comment,creator,post,community,recipient,counts,creatorBannedFromCommunity,bannedFromCommunity,creatorIsModerator,creatorIsAdmin,subscribed,saved,creatorBlocked,myVote);

@override
String toString() {
  return 'PersonMentionView(personMention: $personMention, comment: $comment, creator: $creator, post: $post, community: $community, recipient: $recipient, counts: $counts, creatorBannedFromCommunity: $creatorBannedFromCommunity, bannedFromCommunity: $bannedFromCommunity, creatorIsModerator: $creatorIsModerator, creatorIsAdmin: $creatorIsAdmin, subscribed: $subscribed, saved: $saved, creatorBlocked: $creatorBlocked, myVote: $myVote)';
}


}

/// @nodoc
abstract mixin class _$PersonMentionViewCopyWith<$Res> implements $PersonMentionViewCopyWith<$Res> {
  factory _$PersonMentionViewCopyWith(_PersonMentionView value, $Res Function(_PersonMentionView) _then) = __$PersonMentionViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'person_mention') PersonMention personMention, Comment comment, Person creator, Post post, Community community, Person recipient, CommentAggregates counts,@JsonKey(name: 'creator_banned_from_community') bool creatorBannedFromCommunity,@JsonKey(name: 'banned_from_community') bool bannedFromCommunity,@JsonKey(name: 'creator_is_moderator') bool creatorIsModerator,@JsonKey(name: 'creator_is_admin') bool creatorIsAdmin, String subscribed, bool saved,@JsonKey(name: 'creator_blocked') bool creatorBlocked,@JsonKey(name: 'my_vote', fromJson: _toNullableInt) int? myVote
});


@override $PersonMentionCopyWith<$Res> get personMention;@override $CommentCopyWith<$Res> get comment;@override $PersonCopyWith<$Res> get creator;@override $PostCopyWith<$Res> get post;@override $CommunityCopyWith<$Res> get community;@override $PersonCopyWith<$Res> get recipient;@override $CommentAggregatesCopyWith<$Res> get counts;

}
/// @nodoc
class __$PersonMentionViewCopyWithImpl<$Res>
    implements _$PersonMentionViewCopyWith<$Res> {
  __$PersonMentionViewCopyWithImpl(this._self, this._then);

  final _PersonMentionView _self;
  final $Res Function(_PersonMentionView) _then;

/// Create a copy of PersonMentionView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? personMention = null,Object? comment = null,Object? creator = null,Object? post = null,Object? community = null,Object? recipient = null,Object? counts = null,Object? creatorBannedFromCommunity = null,Object? bannedFromCommunity = null,Object? creatorIsModerator = null,Object? creatorIsAdmin = null,Object? subscribed = null,Object? saved = null,Object? creatorBlocked = null,Object? myVote = freezed,}) {
  return _then(_PersonMentionView(
personMention: null == personMention ? _self.personMention : personMention // ignore: cast_nullable_to_non_nullable
as PersonMention,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as Comment,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as Person,post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as Post,community: null == community ? _self.community : community // ignore: cast_nullable_to_non_nullable
as Community,recipient: null == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as Person,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
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

/// Create a copy of PersonMentionView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonMentionCopyWith<$Res> get personMention {
  
  return $PersonMentionCopyWith<$Res>(_self.personMention, (value) {
    return _then(_self.copyWith(personMention: value));
  });
}/// Create a copy of PersonMentionView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentCopyWith<$Res> get comment {
  
  return $CommentCopyWith<$Res>(_self.comment, (value) {
    return _then(_self.copyWith(comment: value));
  });
}/// Create a copy of PersonMentionView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get creator {
  
  return $PersonCopyWith<$Res>(_self.creator, (value) {
    return _then(_self.copyWith(creator: value));
  });
}/// Create a copy of PersonMentionView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCopyWith<$Res> get post {
  
  return $PostCopyWith<$Res>(_self.post, (value) {
    return _then(_self.copyWith(post: value));
  });
}/// Create a copy of PersonMentionView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommunityCopyWith<$Res> get community {
  
  return $CommunityCopyWith<$Res>(_self.community, (value) {
    return _then(_self.copyWith(community: value));
  });
}/// Create a copy of PersonMentionView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get recipient {
  
  return $PersonCopyWith<$Res>(_self.recipient, (value) {
    return _then(_self.copyWith(recipient: value));
  });
}/// Create a copy of PersonMentionView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentAggregatesCopyWith<$Res> get counts {
  
  return $CommentAggregatesCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}


/// @nodoc
mixin _$PrivateMessage {

@JsonKey(fromJson: _toInt) int get id;@JsonKey(name: 'creator_id', fromJson: _toInt) int get creatorId;@JsonKey(name: 'recipient_id', fromJson: _toInt) int get recipientId; String get content; bool get deleted; bool get read; String get published; String? get updated;@JsonKey(name: 'ap_id') String get apId; bool get local;
/// Create a copy of PrivateMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrivateMessageCopyWith<PrivateMessage> get copyWith => _$PrivateMessageCopyWithImpl<PrivateMessage>(this as PrivateMessage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrivateMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.recipientId, recipientId) || other.recipientId == recipientId)&&(identical(other.content, content) || other.content == content)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.read, read) || other.read == read)&&(identical(other.published, published) || other.published == published)&&(identical(other.updated, updated) || other.updated == updated)&&(identical(other.apId, apId) || other.apId == apId)&&(identical(other.local, local) || other.local == local));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,recipientId,content,deleted,read,published,updated,apId,local);

@override
String toString() {
  return 'PrivateMessage(id: $id, creatorId: $creatorId, recipientId: $recipientId, content: $content, deleted: $deleted, read: $read, published: $published, updated: $updated, apId: $apId, local: $local)';
}


}

/// @nodoc
abstract mixin class $PrivateMessageCopyWith<$Res>  {
  factory $PrivateMessageCopyWith(PrivateMessage value, $Res Function(PrivateMessage) _then) = _$PrivateMessageCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _toInt) int id,@JsonKey(name: 'creator_id', fromJson: _toInt) int creatorId,@JsonKey(name: 'recipient_id', fromJson: _toInt) int recipientId, String content, bool deleted, bool read, String published, String? updated,@JsonKey(name: 'ap_id') String apId, bool local
});




}
/// @nodoc
class _$PrivateMessageCopyWithImpl<$Res>
    implements $PrivateMessageCopyWith<$Res> {
  _$PrivateMessageCopyWithImpl(this._self, this._then);

  final PrivateMessage _self;
  final $Res Function(PrivateMessage) _then;

/// Create a copy of PrivateMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creatorId = null,Object? recipientId = null,Object? content = null,Object? deleted = null,Object? read = null,Object? published = null,Object? updated = freezed,Object? apId = null,Object? local = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,recipientId: null == recipientId ? _self.recipientId : recipientId // ignore: cast_nullable_to_non_nullable
as int,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,updated: freezed == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as String?,apId: null == apId ? _self.apId : apId // ignore: cast_nullable_to_non_nullable
as String,local: null == local ? _self.local : local // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PrivateMessage].
extension PrivateMessagePatterns on PrivateMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrivateMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrivateMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrivateMessage value)  $default,){
final _that = this;
switch (_that) {
case _PrivateMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrivateMessage value)?  $default,){
final _that = this;
switch (_that) {
case _PrivateMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int id, @JsonKey(name: 'creator_id', fromJson: _toInt)  int creatorId, @JsonKey(name: 'recipient_id', fromJson: _toInt)  int recipientId,  String content,  bool deleted,  bool read,  String published,  String? updated, @JsonKey(name: 'ap_id')  String apId,  bool local)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrivateMessage() when $default != null:
return $default(_that.id,_that.creatorId,_that.recipientId,_that.content,_that.deleted,_that.read,_that.published,_that.updated,_that.apId,_that.local);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int id, @JsonKey(name: 'creator_id', fromJson: _toInt)  int creatorId, @JsonKey(name: 'recipient_id', fromJson: _toInt)  int recipientId,  String content,  bool deleted,  bool read,  String published,  String? updated, @JsonKey(name: 'ap_id')  String apId,  bool local)  $default,) {final _that = this;
switch (_that) {
case _PrivateMessage():
return $default(_that.id,_that.creatorId,_that.recipientId,_that.content,_that.deleted,_that.read,_that.published,_that.updated,_that.apId,_that.local);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _toInt)  int id, @JsonKey(name: 'creator_id', fromJson: _toInt)  int creatorId, @JsonKey(name: 'recipient_id', fromJson: _toInt)  int recipientId,  String content,  bool deleted,  bool read,  String published,  String? updated, @JsonKey(name: 'ap_id')  String apId,  bool local)?  $default,) {final _that = this;
switch (_that) {
case _PrivateMessage() when $default != null:
return $default(_that.id,_that.creatorId,_that.recipientId,_that.content,_that.deleted,_that.read,_that.published,_that.updated,_that.apId,_that.local);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _PrivateMessage implements PrivateMessage {
  const _PrivateMessage({@JsonKey(fromJson: _toInt) this.id = 0, @JsonKey(name: 'creator_id', fromJson: _toInt) this.creatorId = 0, @JsonKey(name: 'recipient_id', fromJson: _toInt) this.recipientId = 0, this.content = '', this.deleted = false, this.read = false, this.published = '', this.updated, @JsonKey(name: 'ap_id') this.apId = '', this.local = true});
  factory _PrivateMessage.fromJson(Map<String, dynamic> json) => _$PrivateMessageFromJson(json);

@override@JsonKey(fromJson: _toInt) final  int id;
@override@JsonKey(name: 'creator_id', fromJson: _toInt) final  int creatorId;
@override@JsonKey(name: 'recipient_id', fromJson: _toInt) final  int recipientId;
@override@JsonKey() final  String content;
@override@JsonKey() final  bool deleted;
@override@JsonKey() final  bool read;
@override@JsonKey() final  String published;
@override final  String? updated;
@override@JsonKey(name: 'ap_id') final  String apId;
@override@JsonKey() final  bool local;

/// Create a copy of PrivateMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrivateMessageCopyWith<_PrivateMessage> get copyWith => __$PrivateMessageCopyWithImpl<_PrivateMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrivateMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.recipientId, recipientId) || other.recipientId == recipientId)&&(identical(other.content, content) || other.content == content)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.read, read) || other.read == read)&&(identical(other.published, published) || other.published == published)&&(identical(other.updated, updated) || other.updated == updated)&&(identical(other.apId, apId) || other.apId == apId)&&(identical(other.local, local) || other.local == local));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,recipientId,content,deleted,read,published,updated,apId,local);

@override
String toString() {
  return 'PrivateMessage(id: $id, creatorId: $creatorId, recipientId: $recipientId, content: $content, deleted: $deleted, read: $read, published: $published, updated: $updated, apId: $apId, local: $local)';
}


}

/// @nodoc
abstract mixin class _$PrivateMessageCopyWith<$Res> implements $PrivateMessageCopyWith<$Res> {
  factory _$PrivateMessageCopyWith(_PrivateMessage value, $Res Function(_PrivateMessage) _then) = __$PrivateMessageCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _toInt) int id,@JsonKey(name: 'creator_id', fromJson: _toInt) int creatorId,@JsonKey(name: 'recipient_id', fromJson: _toInt) int recipientId, String content, bool deleted, bool read, String published, String? updated,@JsonKey(name: 'ap_id') String apId, bool local
});




}
/// @nodoc
class __$PrivateMessageCopyWithImpl<$Res>
    implements _$PrivateMessageCopyWith<$Res> {
  __$PrivateMessageCopyWithImpl(this._self, this._then);

  final _PrivateMessage _self;
  final $Res Function(_PrivateMessage) _then;

/// Create a copy of PrivateMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creatorId = null,Object? recipientId = null,Object? content = null,Object? deleted = null,Object? read = null,Object? published = null,Object? updated = freezed,Object? apId = null,Object? local = null,}) {
  return _then(_PrivateMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,recipientId: null == recipientId ? _self.recipientId : recipientId // ignore: cast_nullable_to_non_nullable
as int,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,updated: freezed == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as String?,apId: null == apId ? _self.apId : apId // ignore: cast_nullable_to_non_nullable
as String,local: null == local ? _self.local : local // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PrivateMessageView {

@JsonKey(name: 'private_message') PrivateMessage get privateMessage; Person get creator; Person get recipient;
/// Create a copy of PrivateMessageView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrivateMessageViewCopyWith<PrivateMessageView> get copyWith => _$PrivateMessageViewCopyWithImpl<PrivateMessageView>(this as PrivateMessageView, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrivateMessageView&&(identical(other.privateMessage, privateMessage) || other.privateMessage == privateMessage)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.recipient, recipient) || other.recipient == recipient));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,privateMessage,creator,recipient);

@override
String toString() {
  return 'PrivateMessageView(privateMessage: $privateMessage, creator: $creator, recipient: $recipient)';
}


}

/// @nodoc
abstract mixin class $PrivateMessageViewCopyWith<$Res>  {
  factory $PrivateMessageViewCopyWith(PrivateMessageView value, $Res Function(PrivateMessageView) _then) = _$PrivateMessageViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'private_message') PrivateMessage privateMessage, Person creator, Person recipient
});


$PrivateMessageCopyWith<$Res> get privateMessage;$PersonCopyWith<$Res> get creator;$PersonCopyWith<$Res> get recipient;

}
/// @nodoc
class _$PrivateMessageViewCopyWithImpl<$Res>
    implements $PrivateMessageViewCopyWith<$Res> {
  _$PrivateMessageViewCopyWithImpl(this._self, this._then);

  final PrivateMessageView _self;
  final $Res Function(PrivateMessageView) _then;

/// Create a copy of PrivateMessageView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? privateMessage = null,Object? creator = null,Object? recipient = null,}) {
  return _then(_self.copyWith(
privateMessage: null == privateMessage ? _self.privateMessage : privateMessage // ignore: cast_nullable_to_non_nullable
as PrivateMessage,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as Person,recipient: null == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as Person,
  ));
}
/// Create a copy of PrivateMessageView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PrivateMessageCopyWith<$Res> get privateMessage {
  
  return $PrivateMessageCopyWith<$Res>(_self.privateMessage, (value) {
    return _then(_self.copyWith(privateMessage: value));
  });
}/// Create a copy of PrivateMessageView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get creator {
  
  return $PersonCopyWith<$Res>(_self.creator, (value) {
    return _then(_self.copyWith(creator: value));
  });
}/// Create a copy of PrivateMessageView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get recipient {
  
  return $PersonCopyWith<$Res>(_self.recipient, (value) {
    return _then(_self.copyWith(recipient: value));
  });
}
}


/// Adds pattern-matching-related methods to [PrivateMessageView].
extension PrivateMessageViewPatterns on PrivateMessageView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrivateMessageView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrivateMessageView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrivateMessageView value)  $default,){
final _that = this;
switch (_that) {
case _PrivateMessageView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrivateMessageView value)?  $default,){
final _that = this;
switch (_that) {
case _PrivateMessageView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'private_message')  PrivateMessage privateMessage,  Person creator,  Person recipient)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrivateMessageView() when $default != null:
return $default(_that.privateMessage,_that.creator,_that.recipient);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'private_message')  PrivateMessage privateMessage,  Person creator,  Person recipient)  $default,) {final _that = this;
switch (_that) {
case _PrivateMessageView():
return $default(_that.privateMessage,_that.creator,_that.recipient);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'private_message')  PrivateMessage privateMessage,  Person creator,  Person recipient)?  $default,) {final _that = this;
switch (_that) {
case _PrivateMessageView() when $default != null:
return $default(_that.privateMessage,_that.creator,_that.recipient);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _PrivateMessageView implements PrivateMessageView {
  const _PrivateMessageView({@JsonKey(name: 'private_message') required this.privateMessage, required this.creator, required this.recipient});
  factory _PrivateMessageView.fromJson(Map<String, dynamic> json) => _$PrivateMessageViewFromJson(json);

@override@JsonKey(name: 'private_message') final  PrivateMessage privateMessage;
@override final  Person creator;
@override final  Person recipient;

/// Create a copy of PrivateMessageView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrivateMessageViewCopyWith<_PrivateMessageView> get copyWith => __$PrivateMessageViewCopyWithImpl<_PrivateMessageView>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrivateMessageView&&(identical(other.privateMessage, privateMessage) || other.privateMessage == privateMessage)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.recipient, recipient) || other.recipient == recipient));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,privateMessage,creator,recipient);

@override
String toString() {
  return 'PrivateMessageView(privateMessage: $privateMessage, creator: $creator, recipient: $recipient)';
}


}

/// @nodoc
abstract mixin class _$PrivateMessageViewCopyWith<$Res> implements $PrivateMessageViewCopyWith<$Res> {
  factory _$PrivateMessageViewCopyWith(_PrivateMessageView value, $Res Function(_PrivateMessageView) _then) = __$PrivateMessageViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'private_message') PrivateMessage privateMessage, Person creator, Person recipient
});


@override $PrivateMessageCopyWith<$Res> get privateMessage;@override $PersonCopyWith<$Res> get creator;@override $PersonCopyWith<$Res> get recipient;

}
/// @nodoc
class __$PrivateMessageViewCopyWithImpl<$Res>
    implements _$PrivateMessageViewCopyWith<$Res> {
  __$PrivateMessageViewCopyWithImpl(this._self, this._then);

  final _PrivateMessageView _self;
  final $Res Function(_PrivateMessageView) _then;

/// Create a copy of PrivateMessageView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? privateMessage = null,Object? creator = null,Object? recipient = null,}) {
  return _then(_PrivateMessageView(
privateMessage: null == privateMessage ? _self.privateMessage : privateMessage // ignore: cast_nullable_to_non_nullable
as PrivateMessage,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as Person,recipient: null == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as Person,
  ));
}

/// Create a copy of PrivateMessageView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PrivateMessageCopyWith<$Res> get privateMessage {
  
  return $PrivateMessageCopyWith<$Res>(_self.privateMessage, (value) {
    return _then(_self.copyWith(privateMessage: value));
  });
}/// Create a copy of PrivateMessageView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get creator {
  
  return $PersonCopyWith<$Res>(_self.creator, (value) {
    return _then(_self.copyWith(creator: value));
  });
}/// Create a copy of PrivateMessageView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonCopyWith<$Res> get recipient {
  
  return $PersonCopyWith<$Res>(_self.recipient, (value) {
    return _then(_self.copyWith(recipient: value));
  });
}
}


/// @nodoc
mixin _$GetUnreadCountResponse {

@JsonKey(fromJson: _toInt) int get replies;@JsonKey(fromJson: _toInt) int get mentions;@JsonKey(name: 'private_messages', fromJson: _toInt) int get privateMessages;
/// Create a copy of GetUnreadCountResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetUnreadCountResponseCopyWith<GetUnreadCountResponse> get copyWith => _$GetUnreadCountResponseCopyWithImpl<GetUnreadCountResponse>(this as GetUnreadCountResponse, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetUnreadCountResponse&&(identical(other.replies, replies) || other.replies == replies)&&(identical(other.mentions, mentions) || other.mentions == mentions)&&(identical(other.privateMessages, privateMessages) || other.privateMessages == privateMessages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,replies,mentions,privateMessages);

@override
String toString() {
  return 'GetUnreadCountResponse(replies: $replies, mentions: $mentions, privateMessages: $privateMessages)';
}


}

/// @nodoc
abstract mixin class $GetUnreadCountResponseCopyWith<$Res>  {
  factory $GetUnreadCountResponseCopyWith(GetUnreadCountResponse value, $Res Function(GetUnreadCountResponse) _then) = _$GetUnreadCountResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _toInt) int replies,@JsonKey(fromJson: _toInt) int mentions,@JsonKey(name: 'private_messages', fromJson: _toInt) int privateMessages
});




}
/// @nodoc
class _$GetUnreadCountResponseCopyWithImpl<$Res>
    implements $GetUnreadCountResponseCopyWith<$Res> {
  _$GetUnreadCountResponseCopyWithImpl(this._self, this._then);

  final GetUnreadCountResponse _self;
  final $Res Function(GetUnreadCountResponse) _then;

/// Create a copy of GetUnreadCountResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? replies = null,Object? mentions = null,Object? privateMessages = null,}) {
  return _then(_self.copyWith(
replies: null == replies ? _self.replies : replies // ignore: cast_nullable_to_non_nullable
as int,mentions: null == mentions ? _self.mentions : mentions // ignore: cast_nullable_to_non_nullable
as int,privateMessages: null == privateMessages ? _self.privateMessages : privateMessages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GetUnreadCountResponse].
extension GetUnreadCountResponsePatterns on GetUnreadCountResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GetUnreadCountResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GetUnreadCountResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GetUnreadCountResponse value)  $default,){
final _that = this;
switch (_that) {
case _GetUnreadCountResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GetUnreadCountResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GetUnreadCountResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int replies, @JsonKey(fromJson: _toInt)  int mentions, @JsonKey(name: 'private_messages', fromJson: _toInt)  int privateMessages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GetUnreadCountResponse() when $default != null:
return $default(_that.replies,_that.mentions,_that.privateMessages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int replies, @JsonKey(fromJson: _toInt)  int mentions, @JsonKey(name: 'private_messages', fromJson: _toInt)  int privateMessages)  $default,) {final _that = this;
switch (_that) {
case _GetUnreadCountResponse():
return $default(_that.replies,_that.mentions,_that.privateMessages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _toInt)  int replies, @JsonKey(fromJson: _toInt)  int mentions, @JsonKey(name: 'private_messages', fromJson: _toInt)  int privateMessages)?  $default,) {final _that = this;
switch (_that) {
case _GetUnreadCountResponse() when $default != null:
return $default(_that.replies,_that.mentions,_that.privateMessages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _GetUnreadCountResponse extends GetUnreadCountResponse {
  const _GetUnreadCountResponse({@JsonKey(fromJson: _toInt) this.replies = 0, @JsonKey(fromJson: _toInt) this.mentions = 0, @JsonKey(name: 'private_messages', fromJson: _toInt) this.privateMessages = 0}): super._();
  factory _GetUnreadCountResponse.fromJson(Map<String, dynamic> json) => _$GetUnreadCountResponseFromJson(json);

@override@JsonKey(fromJson: _toInt) final  int replies;
@override@JsonKey(fromJson: _toInt) final  int mentions;
@override@JsonKey(name: 'private_messages', fromJson: _toInt) final  int privateMessages;

/// Create a copy of GetUnreadCountResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GetUnreadCountResponseCopyWith<_GetUnreadCountResponse> get copyWith => __$GetUnreadCountResponseCopyWithImpl<_GetUnreadCountResponse>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GetUnreadCountResponse&&(identical(other.replies, replies) || other.replies == replies)&&(identical(other.mentions, mentions) || other.mentions == mentions)&&(identical(other.privateMessages, privateMessages) || other.privateMessages == privateMessages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,replies,mentions,privateMessages);

@override
String toString() {
  return 'GetUnreadCountResponse(replies: $replies, mentions: $mentions, privateMessages: $privateMessages)';
}


}

/// @nodoc
abstract mixin class _$GetUnreadCountResponseCopyWith<$Res> implements $GetUnreadCountResponseCopyWith<$Res> {
  factory _$GetUnreadCountResponseCopyWith(_GetUnreadCountResponse value, $Res Function(_GetUnreadCountResponse) _then) = __$GetUnreadCountResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _toInt) int replies,@JsonKey(fromJson: _toInt) int mentions,@JsonKey(name: 'private_messages', fromJson: _toInt) int privateMessages
});




}
/// @nodoc
class __$GetUnreadCountResponseCopyWithImpl<$Res>
    implements _$GetUnreadCountResponseCopyWith<$Res> {
  __$GetUnreadCountResponseCopyWithImpl(this._self, this._then);

  final _GetUnreadCountResponse _self;
  final $Res Function(_GetUnreadCountResponse) _then;

/// Create a copy of GetUnreadCountResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? replies = null,Object? mentions = null,Object? privateMessages = null,}) {
  return _then(_GetUnreadCountResponse(
replies: null == replies ? _self.replies : replies // ignore: cast_nullable_to_non_nullable
as int,mentions: null == mentions ? _self.mentions : mentions // ignore: cast_nullable_to_non_nullable
as int,privateMessages: null == privateMessages ? _self.privateMessages : privateMessages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
