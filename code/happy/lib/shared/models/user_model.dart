import 'dart:convert';

class UserModel {
  final String? uid;
  final String name;
  final String? photoURL;
  final String? email;

  UserModel({
    this.uid,
    required this.name,
    this.photoURL,
    this.email,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      photoURL: map['photoURL'],
      email: map['email'],
    );
  }

  factory UserModel.fromJson(String json) =>
      UserModel.fromMap(jsonDecode(json));

  Map<String, dynamic> toMap() => {
        "uid": uid,
        "name": name,
        "photoURL": photoURL,
        "email": email,
      };

  String toJson() => jsonEncode(toMap());
}
