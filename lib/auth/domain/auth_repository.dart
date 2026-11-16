import 'user.dart';

/// Kesalahan autentikasi atau pembatasan peran saat masuk maupun keluar.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class AuthRepository {
  User? get currentUser;

  Future<User> login({required String email, required String password});

  Future<void> logout();
}
