import 'user_model.dart';

class AuthResponseModel {
  const AuthResponseModel({required this.user, required this.accessToken});

  final UserModel user;
  final String accessToken;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json),
      accessToken: json['accessToken'] as String,
    );
  }
}
