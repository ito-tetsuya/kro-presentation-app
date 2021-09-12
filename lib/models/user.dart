import 'dart:convert';

import 'package:flutter_sample/commons/request.dart';
import 'package:flutter_sample/const/api_path.dart';

class User {
  static User? signInUser;
  final int id;
  final String nickName;
  final String? email;
  final String? imagePath;

  User({
    required this.id,
    required this.nickName,
    this.email,
    this.imagePath
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nickName: json['nickname'],
      email: json['email'],
      imagePath: json['image_path'],
    );
  }

  static Future<void> signIn(String email, String password) async {
    final param = {
      'email': email,
      'password': password,
    };
    final response = await Request.callGetApi(ApiPath.login, param);
    print(json.decode(response.body));
    signInUser = User.fromJson(json.decode(response.body));
    print(signInUser);
  }

  static Future<void> signUp(Map<String, String?> body) async {
    await Request.callPostApi(ApiPath.user, body);
  }

  static Future<List<User>> getList() async {
    final response = await Request.callGetApi(ApiPath.user, {'id': signInUser!.id.toString()});
    return (json.decode(response.body) as List)
        .map((json) => User.fromJson(json))
        .toList();
  }
}
