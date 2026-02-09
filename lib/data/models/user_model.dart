import 'dart:convert';

class User {
  final String name;
  final String email;
  final String? gender;
  final String? phone;

  User({
    required this.name,
    required this.email,
    this.gender,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'gender': gender,
      'phone': phone,
    };
  }

  String toJsonString() => json.encode(toJson());

  factory User.fromJsonString(String str) => User.fromJson(json.decode(str));
}
