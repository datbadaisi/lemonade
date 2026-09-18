// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LoginResponse {

 String? get jwt;@JsonKey(name: 'registration_created') bool get registrationCreated;@JsonKey(name: 'verify_email_sent') bool get verifyEmailSent;
/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginResponseCopyWith<LoginResponse> get copyWith => _$LoginResponseCopyWithImpl<LoginResponse>(this as LoginResponse, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginResponse&&(identical(other.jwt, jwt) || other.jwt == jwt)&&(identical(other.registrationCreated, registrationCreated) || other.registrationCreated == registrationCreated)&&(identical(other.verifyEmailSent, verifyEmailSent) || other.verifyEmailSent == verifyEmailSent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jwt,registrationCreated,verifyEmailSent);

@override
String toString() {
  return 'LoginResponse(jwt: $jwt, registrationCreated: $registrationCreated, verifyEmailSent: $verifyEmailSent)';
}


}

/// @nodoc
abstract mixin class $LoginResponseCopyWith<$Res>  {
  factory $LoginResponseCopyWith(LoginResponse value, $Res Function(LoginResponse) _then) = _$LoginResponseCopyWithImpl;
@useResult
$Res call({
 String? jwt,@JsonKey(name: 'registration_created') bool registrationCreated,@JsonKey(name: 'verify_email_sent') bool verifyEmailSent
});




}
/// @nodoc
class _$LoginResponseCopyWithImpl<$Res>
    implements $LoginResponseCopyWith<$Res> {
  _$LoginResponseCopyWithImpl(this._self, this._then);

  final LoginResponse _self;
  final $Res Function(LoginResponse) _then;

/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jwt = freezed,Object? registrationCreated = null,Object? verifyEmailSent = null,}) {
  return _then(_self.copyWith(
jwt: freezed == jwt ? _self.jwt : jwt // ignore: cast_nullable_to_non_nullable
as String?,registrationCreated: null == registrationCreated ? _self.registrationCreated : registrationCreated // ignore: cast_nullable_to_non_nullable
as bool,verifyEmailSent: null == verifyEmailSent ? _self.verifyEmailSent : verifyEmailSent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginResponse].
extension LoginResponsePatterns on LoginResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginResponse value)  $default,){
final _that = this;
switch (_that) {
case _LoginResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginResponse value)?  $default,){
final _that = this;
switch (_that) {
case _LoginResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? jwt, @JsonKey(name: 'registration_created')  bool registrationCreated, @JsonKey(name: 'verify_email_sent')  bool verifyEmailSent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginResponse() when $default != null:
return $default(_that.jwt,_that.registrationCreated,_that.verifyEmailSent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? jwt, @JsonKey(name: 'registration_created')  bool registrationCreated, @JsonKey(name: 'verify_email_sent')  bool verifyEmailSent)  $default,) {final _that = this;
switch (_that) {
case _LoginResponse():
return $default(_that.jwt,_that.registrationCreated,_that.verifyEmailSent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? jwt, @JsonKey(name: 'registration_created')  bool registrationCreated, @JsonKey(name: 'verify_email_sent')  bool verifyEmailSent)?  $default,) {final _that = this;
switch (_that) {
case _LoginResponse() when $default != null:
return $default(_that.jwt,_that.registrationCreated,_that.verifyEmailSent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _LoginResponse implements LoginResponse {
  const _LoginResponse({this.jwt, @JsonKey(name: 'registration_created') this.registrationCreated = false, @JsonKey(name: 'verify_email_sent') this.verifyEmailSent = false});
  factory _LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);

@override final  String? jwt;
@override@JsonKey(name: 'registration_created') final  bool registrationCreated;
@override@JsonKey(name: 'verify_email_sent') final  bool verifyEmailSent;

/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginResponseCopyWith<_LoginResponse> get copyWith => __$LoginResponseCopyWithImpl<_LoginResponse>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginResponse&&(identical(other.jwt, jwt) || other.jwt == jwt)&&(identical(other.registrationCreated, registrationCreated) || other.registrationCreated == registrationCreated)&&(identical(other.verifyEmailSent, verifyEmailSent) || other.verifyEmailSent == verifyEmailSent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jwt,registrationCreated,verifyEmailSent);

@override
String toString() {
  return 'LoginResponse(jwt: $jwt, registrationCreated: $registrationCreated, verifyEmailSent: $verifyEmailSent)';
}


}

/// @nodoc
abstract mixin class _$LoginResponseCopyWith<$Res> implements $LoginResponseCopyWith<$Res> {
  factory _$LoginResponseCopyWith(_LoginResponse value, $Res Function(_LoginResponse) _then) = __$LoginResponseCopyWithImpl;
@override @useResult
$Res call({
 String? jwt,@JsonKey(name: 'registration_created') bool registrationCreated,@JsonKey(name: 'verify_email_sent') bool verifyEmailSent
});




}
/// @nodoc
class __$LoginResponseCopyWithImpl<$Res>
    implements _$LoginResponseCopyWith<$Res> {
  __$LoginResponseCopyWithImpl(this._self, this._then);

  final _LoginResponse _self;
  final $Res Function(_LoginResponse) _then;

/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jwt = freezed,Object? registrationCreated = null,Object? verifyEmailSent = null,}) {
  return _then(_LoginResponse(
jwt: freezed == jwt ? _self.jwt : jwt // ignore: cast_nullable_to_non_nullable
as String?,registrationCreated: null == registrationCreated ? _self.registrationCreated : registrationCreated // ignore: cast_nullable_to_non_nullable
as bool,verifyEmailSent: null == verifyEmailSent ? _self.verifyEmailSent : verifyEmailSent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
