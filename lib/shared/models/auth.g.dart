// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    _LoginResponse(
      jwt: json['jwt'] as String?,
      registrationCreated: json['registration_created'] as bool? ?? false,
      verifyEmailSent: json['verify_email_sent'] as bool? ?? false,
    );
