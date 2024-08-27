import 'dart:developer';

class User {
  final String id;
  final String name;
  final String companyName;
  final String email;
  final String password; // Be cautious with this field
  final int? pin; // Adjusted to int?
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.companyName,
    required this.email,
    required this.password,
    this.pin,
    this.emailVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        companyName: json['companyName'] ?? '',
        email: json['email'] ?? '',
        password: json['password'] ?? '', // Be cautious with this
        pin: json['pin'] != null ? json['pin'] as int? : null,
        emailVerified: json['emailVerified'] ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : DateTime.now(),
      );
    } catch (e) {
      log('Error parsing user JSON: $e');
      throw FormatException('Error parsing user JSON');
    }
  }

  // Method to convert a User object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'companyName': companyName,
      'email': email,
      'password': password, // Be cautious with this
      'pin': pin,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
