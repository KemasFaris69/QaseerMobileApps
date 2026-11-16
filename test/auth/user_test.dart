import 'package:flutter_test/flutter_test.dart';
import 'package:qasser_mobile/auth/domain/auth_repository.dart';
import 'package:qasser_mobile/auth/domain/user.dart';

void main() {
  group('UserRole & User', () {
    test('hanya menyediakan peran kasir dan pelayan dengan nama kompatibel', () {
      expect(UserRole.values, [UserRole.kasir, UserRole.pelayan]);
      expect(UserRole.kasir.name, 'kasir');
      expect(UserRole.kasir.label, 'Kasir');
      expect(UserRole.pelayan.name, 'pelayan');
      expect(UserRole.pelayan.label, 'Pelayan');
    });

    test('User mendukung kesetaraan nilai Equatable', () {
      const a = User(
        id: 'u-1',
        name: 'Kasir Qaseer',
        email: 'kasir@qaseer.id',
        role: UserRole.kasir,
      );
      const b = User(
        id: 'u-1',
        name: 'Kasir Qaseer',
        email: 'kasir@qaseer.id',
        role: UserRole.kasir,
      );
      const c = User(
        id: 'u-2',
        name: 'Pelayan Qaseer',
        email: 'pelayan@qaseer.id',
        role: UserRole.pelayan,
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('AuthException mengembalikan pesan melalui toString', () {
      const error = AuthException('Email atau password salah.');
      expect(error.message, 'Email atau password salah.');
      expect(error.toString(), 'Email atau password salah.');
    });
  });
}
