import 'package:flutter_test/flutter_test.dart';
import 'package:qasser_mobile/auth/data/fake_auth_repository.dart';
import 'package:qasser_mobile/auth/domain/auth_repository.dart';
import 'package:qasser_mobile/auth/domain/user.dart';

void main() {
  group('FakeAuthRepository', () {
    late FakeAuthRepository repository;

    setUp(() {
      repository = FakeAuthRepository(delay: Duration.zero);
    });

    test('login kasir berhasil dan mengisi currentUser', () async {
      final user = await repository.login(
        email: 'kasir@qaseer.id',
        password: 'qaseer123',
      );

      expect(user.role, UserRole.kasir);
      expect(user.email, 'kasir@qaseer.id');
      expect(repository.currentUser, equals(user));
    });

    test(
      'login pelayan berhasil dengan email huruf besar dan spasi pinggir',
      () async {
        final user = await repository.login(
          email: '  PELAYAN@Qaseer.id  ',
          password: 'qaseer123',
        );

        expect(user.role, UserRole.pelayan);
        expect(user.email, 'pelayan@qaseer.id');
        expect(repository.currentUser, equals(user));
      },
    );

    test('menolak email peran lama secara eksplisit', () async {
      const legacyEmails = [
        'owner@qaseer.id',
        'manager@qaseer.id',
        'dapur@qaseer.id',
        'gudang@qaseer.id',
        'akuntan@qaseer.id',
      ];

      for (final email in legacyEmails) {
        await expectLater(
          repository.login(email: ' $email ', password: 'qaseer123'),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              'Akun peran ini tidak memiliki akses. Hanya Pelayan dan Kasir yang dapat masuk.',
            ),
          ),
        );
      }
      expect(repository.currentUser, isNull);
    });

    test('menolak password salah termasuk beda spasi atau kapital', () async {
      for (final badPassword in ['salah123', ' qaseer123', 'Qaseer123']) {
        await expectLater(
          repository.login(email: 'kasir@qaseer.id', password: badPassword),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              'Email atau password salah.',
            ),
          ),
        );
      }
      expect(repository.currentUser, isNull);
    });

    test('menolak email tidak dikenal dengan pesan kredensial salah', () async {
      await expectLater(
        repository.login(email: 'tidakada@qaseer.id', password: 'qaseer123'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Email atau password salah.',
          ),
        ),
      );
    });

    test('logout menghapus currentUser', () async {
      await repository.login(email: 'kasir@qaseer.id', password: 'qaseer123');
      expect(repository.currentUser, isNotNull);

      await repository.logout();
      expect(repository.currentUser, isNull);
    });
  });
}
