import 'package:equatable/equatable.dart';

import 'role.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final Role role;
  final String? companyName;
  final String? contactPerson;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? country;
  final String? city;
  final String? website;
  final bool emailVerified;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.companyName,
    this.contactPerson,
    this.firstName,
    this.lastName,
    this.phone,
    this.country,
    this.city,
    this.website,
    this.emailVerified = false,
  });

  @override
  List<Object?> get props => [
        id, email, name, role, companyName, contactPerson,
        firstName, lastName, phone, country, city, website, emailVerified,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'companyName': companyName,
      'contactPerson': contactPerson,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'country': country,
      'city': city,
      'website': website,
      'emailVerified': emailVerified,
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
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      website: json['website'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
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
