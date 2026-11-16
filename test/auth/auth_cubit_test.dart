import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:qasser_mobile/auth/data/fake_auth_repository.dart';
import 'package:qasser_mobile/auth/domain/auth_repository.dart';
import 'package:qasser_mobile/auth/domain/user.dart';
import 'package:qasser_mobile/auth/presentation/auth_cubit.dart';

class _ControlledAuthRepository implements AuthRepository {
  User? _currentUser;
  int loginCalls = 0;
  Future<User> Function(String email, String password)? onLogin;
  Future<void> Function()? onLogout;

  @override
  User? get currentUser => _currentUser;

  @override
  Future<User> login({required String email, required String password}) async {
    loginCalls++;
    final user = await onLogin!(email, password);
    _currentUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    if (onLogout != null) {
      await onLogout!();
    }
    _currentUser = null;
  }
}

void main() {
  group('AuthCubit', () {
    test('state awal tidak terautentikasi saat repository kosong', () {
      final cubit = AuthCubit(FakeAuthRepository(delay: Duration.zero));
      addTearDown(cubit.close);

      expect(cubit.state, const AuthState());
      expect(cubit.state.isAuthenticated, isFalse);
    });

    test('login sukses meng-emit loading lalu user terautentikasi', () async {
      final cubit = AuthCubit(FakeAuthRepository(delay: Duration.zero));
      addTearDown(cubit.close);

      final expectedStates = expectLater(
        cubit.stream,
        emitsInOrder([
          const AuthState(loading: true),
          isA<AuthState>()
              .having((s) => s.loading, 'loading', false)
              .having((s) => s.isAuthenticated, 'isAuthenticated', true)
              .having((s) => s.user?.role, 'role', UserRole.kasir)
              .having((s) => s.error, 'error', isNull),
        ]),
      );

      await cubit.login('kasir@qaseer.id', 'qaseer123');
      await expectedStates;
    });

    test(
      'login gagal AuthException meng-emit error dan percobaan sukses berikutnya membersihkan error',
      () async {
        final cubit = AuthCubit(FakeAuthRepository(delay: Duration.zero));
        addTearDown(cubit.close);

        await cubit.login('owner@qaseer.id', 'qaseer123');
        expect(cubit.state.loading, isFalse);
        expect(cubit.state.user, isNull);
        expect(
          cubit.state.error,
          'Akun peran ini tidak memiliki akses. Hanya Pelayan dan Kasir yang dapat masuk.',
        );

        await cubit.login('pelayan@qaseer.id', 'qaseer123');
        expect(cubit.state.loading, isFalse);
        expect(cubit.state.user?.role, UserRole.pelayan);
        expect(cubit.state.error, isNull);
      },
    );

    test('login dengan error tak terduga meng-emit pesan fallback', () async {
      final repo = _ControlledAuthRepository()
        ..onLogin = (_, _) async => throw StateError('network');
      final cubit = AuthCubit(repo);
      addTearDown(cubit.close);

      await cubit.login('kasir@qaseer.id', 'qaseer123');

      expect(cubit.state.loading, isFalse);
      expect(cubit.state.user, isNull);
      expect(
        cubit.state.error,
        'Terjadi kesalahan saat masuk. Silakan coba lagi.',
      );
    });

    test(
      'mengabaikan panggilan login kedua saat loading sedang berjalan',
      () async {
        final completer = Completer<User>();
        final repo = _ControlledAuthRepository()
          ..onLogin = (_, _) => completer.future;
        final cubit = AuthCubit(repo);
        addTearDown(cubit.close);

        final first = cubit.login('kasir@qaseer.id', 'qaseer123');
        final second = cubit.login('pelayan@qaseer.id', 'qaseer123');

        expect(repo.loginCalls, 1);

        completer.complete(
          const User(
            id: 'u-kasir-1',
            name: 'Kasir Qaseer',
            email: 'kasir@qaseer.id',
            role: UserRole.kasir,
          ),
        );
        await Future.wait([first, second]);
        expect(cubit.state.user?.role, UserRole.kasir);
      },
    );

    test(
      'logout mengembalikan ke AuthState kosong dan menangani gagal logout',
      () async {
        final fakeRepo = FakeAuthRepository(delay: Duration.zero);
        final cubit = AuthCubit(fakeRepo);
        addTearDown(cubit.close);

        await cubit.login('kasir@qaseer.id', 'qaseer123');
        expect(cubit.state.isAuthenticated, isTrue);

        await cubit.logout();
        expect(cubit.state, const AuthState());

        final failingRepo = _ControlledAuthRepository()
          .._currentUser = const User(
            id: 'u-kasir-1',
            name: 'Kasir Qaseer',
            email: 'kasir@qaseer.id',
            role: UserRole.kasir,
          )
          ..onLogout = () async => throw StateError('timeout');
        final failingCubit = AuthCubit(failingRepo);
        addTearDown(failingCubit.close);

        await failingCubit.logout();
        expect(failingCubit.state.loading, isFalse);
        expect(failingCubit.state.isAuthenticated, isTrue);
        expect(failingCubit.state.error, 'Gagal keluar. Silakan coba lagi.');
      },
    );
  });
}
