import '../model/user_token.dart';

class AuthenticationResponse {
  final UserToken userToken;
  final String error;

  const AuthenticationResponse({
    this.userToken,
    this.error = '',
  });

  AuthenticationResponse copy({
    bool userToken,
    String error,
  }) =>
      AuthenticationResponse(
        userToken: userToken ?? this.userToken,
        error: error ?? this.error,
      );

  static AuthenticationResponse fromJson(Map<String, dynamic> json) =>
      AuthenticationResponse(
        userToken: json['userToken'] == null
            ? null
            : UserToken.fromJson(Map<String, dynamic>.from(json['userToken'])),
        error: json['error'],
      );

  Map<String, dynamic> toJson() => {
        'userToken': userToken == null ? null : userToken.toJson(),
        'error': error,
      };

  @override
  String toString() =>
      'AuthenticationResponse{userToken: $userToken, error: $error}';
}
