import 'dart:convert';

class User {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String token;
   String userType; // Added userType field

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.token,
    this.userType = 'normal', // Default to 'normal' if not provided
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'token': token,
      'userType': userType, // Include userType in the map
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String? ?? "",
      fullName: map['fullName'] as String? ?? "",
      email: map['email'] as String? ?? "",
      phone: map['phone'] as String? ?? "",
      password: map['password'] as String? ?? "",
      token: map['token'] as String? ?? "",
      userType: map['userType'] as String? ?? 'normal', // Default to 'normal'
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}
