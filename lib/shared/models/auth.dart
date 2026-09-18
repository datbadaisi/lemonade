import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth.freezed.dart';
part 'auth.g.dart';

@Freezed(toJson: false)
abstract class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    String? jwt,
    @JsonKey(name: 'registration_created')
    @Default(false)
    bool registrationCreated,
    @JsonKey(name: 'verify_email_sent') @Default(false) bool verifyEmailSent,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}
