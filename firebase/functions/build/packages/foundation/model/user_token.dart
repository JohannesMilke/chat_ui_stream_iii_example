import 'package:meta/meta.dart';

class UserToken {
  final String token;
  final String idUser;

  const UserToken({
    @required this.token,
    @required this.idUser,
  });

  UserToken copy({
    String token,
    String idUser,
  }) =>
      UserToken(
        token: token ?? this.token,
        idUser: idUser ?? this.idUser,
      );

  static UserToken fromJson(Map<String, dynamic> json) => UserToken(
        token: json['token'],
        idUser: json['idUser'],
      );

  Map<String, dynamic> toJson() => {
        'token': token,
        'idUser': idUser,
      };
}
