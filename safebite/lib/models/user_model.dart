import 'dart:convert';

class UserModel {
  final String email;
  final String nickname;
  final List<String>? allergies;

  UserModel({required this.email, required this.nickname, this.allergies});

  // Factory constructor to instantiate object from json format
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        email: json['email'],
        nickname: json['nickname'],
        allergies: List<String>.from(json['allergies']));
  }

  static List<UserModel> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data.map<UserModel>((dynamic d) => UserModel.fromJson(d)).toList();
  }

  Map<String, dynamic> toJson(UserModel UserModel) {
    return {
      'email': UserModel.email,
      'nickname': UserModel.nickname,
      'allergies': UserModel.allergies,
    };
  }
}
