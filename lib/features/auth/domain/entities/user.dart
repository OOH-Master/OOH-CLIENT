import 'package:equatable/equatable.dart';

import 'role.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final Role role;
  final String? companyName;
  final String? contactPerson;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.companyName,
    this.contactPerson,
  });

  @override
  List<Object?> get props => [id, email, name, role, companyName, contactPerson];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'companyName': companyName,
      'contactPerson': contactPerson,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: _parseRole(json['role']),
      companyName: json['companyName'] as String?,
      contactPerson: json['contactPerson'] as String?,
    );
  }

  static Role _parseRole(dynamic role) {
    if (role is int) return Role.values[role];
    if (role is String) {
      switch (role) {
        case 'brand':
          return Role.brand;
        case 'agency':
          return Role.agency;
        case 'mediaOwner':
          return Role.mediaOwner;
        case 'admin':
          return Role.admin;
      }
    }
    return Role.brand;
  }
}
