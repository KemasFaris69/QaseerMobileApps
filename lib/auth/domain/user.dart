import 'package:equatable/equatable.dart';

/// Peran pengguna yang diizinkan mengakses aplikasi mobile POS Qaseer.
enum UserRole {
  kasir('Kasir'),
  pelayan('Pelayan');

  const UserRole(this.label);

  final String label;
}

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;

  @override
  List<Object?> get props => [id, name, email, role];
}
