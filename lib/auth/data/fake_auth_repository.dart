import '../domain/auth_repository.dart';
import '../domain/user.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.delay = const Duration(milliseconds: 400),
  });

  static const String _demoPassword = 'qaseer123';

  static const Set<String> _disallowedRoleEmails = {
    'owner@qaseer.id',
    'manager@qaseer.id',
    'dapur@qaseer.id',
    'gudang@qaseer.id',
    'akuntan@qaseer.id',
  };

  static const Map<String, User> _demoAccounts = {
    'kasir@qaseer.id': User(
      id: 'u-kasir-1',
      name: 'Kasir Qaseer',
      email: 'kasir@qaseer.id',
      role: UserRole.kasir,
    ),
    'pelayan@qaseer.id': User(
      id: 'u-pelayan-1',
      name: 'Pelayan Qaseer',
      email: 'pelayan@qaseer.id',
      role: UserRole.pelayan,
    ),
  };

  final Duration delay;
  User? _currentUser;

  @override
  User? get currentUser => _currentUser;

  @override
  Future<User> login({required String email, required String password}) async {
    await Future.delayed(delay);

    final normalizedEmail = email.trim().toLowerCase();

    if (_disallowedRoleEmails.contains(normalizedEmail)) {
      throw const AuthException(
        'Akun peran ini tidak memiliki akses. Hanya Pelayan dan Kasir yang dapat masuk.',
      );
    }

    final user = _demoAccounts[normalizedEmail];
    if (user == null || password != _demoPassword) {
      throw const AuthException('Email atau password salah.');
    }

    _currentUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(delay);
    _currentUser = null;
  }
}
