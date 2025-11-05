class UserModel {
  final String email;
  final String nickname;
  final List<String> allergies;

  // set allergies to const [] as default for new users
  UserModel({
    required this.email,
    required this.nickname,
    this.allergies = const [],
  });

  // factory constructor to create a UserModel from a Firestore map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawAllergies = json['allergies'] ?? [];

    return UserModel(
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      allergies: rawAllergies.map((a) => a.toString()).toList(),
    );
  }

  // method to convert UserModel to a map for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'nickname': nickname,
      'allergies': allergies,
    };
  }
}
