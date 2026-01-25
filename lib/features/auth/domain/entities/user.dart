import 'package:equatable/equatable.dart';
import 'role.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final Role role;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  @override
  List<Object?> get props => [id, email, name, role];

  // Helper for JSON serialization (mock)
  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'name': name, 'role': role.index};
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: Role.values[json['role']],
    );
  }
}
