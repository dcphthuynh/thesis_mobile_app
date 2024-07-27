// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  String userId;
  String? password;

  User({
    required this.userId,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json["user_id"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "password": password,
      };

  @override
  String toString() {
    return 'User: {UserID: ${userId}}';
  }
}
