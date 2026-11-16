import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qasser_mobile/auth/data/fake_auth_repository.dart';
import 'package:qasser_mobile/auth/domain/auth_repository.dart';
import 'package:qasser_mobile/auth/domain/user.dart';
import 'package:qasser_mobile/auth/presentation/auth_cubit.dart';
import 'package:qasser_mobile/auth/presentation/login_page.dart';

class _DelayedAuthRepository implements AuthRepository {
  final Completer<User> completer = Completer<User>();
  int calls = 0;

  @override
  User? get currentUser => null;

  @override
  Future<User> login({required String email, required String password}) {
    calls++;
    return completer.future;
  }

  @override
  Future<void> logout() async {}
}

Widget _wrapWithAuth(AuthCubit cubit) {
  return BlocProvider<AuthCubit>.value(
    value: cubit,
    child: const MaterialApp(home: LoginPage()),
  );
}

void main() {
  group('LoginPage', () {
    testWidgets(
      'menampilkan layout putih tanpa Card, brand lockup, teks Backoffice, dan dua akun demo tanpa password',
      (tester) async {
        final cubit = AuthCubit(FakeAuthRepository(delay: Duration.zero));
        addTearDown(cubit.close);

        await tester.pumpWidget(_wrapWithAuth(cubit));

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, Colors.white);
        expect(find.byType(Card), findsNothing);

        expect(find.text('Qaseer'), findsOneWidget);
        expect(find.text('POS Restoran'), findsOneWidget);
        expect(find.text('Selamat Datang!'), findsOneWidget);
        expect(
          find.text('Silakan masukkan email dan password untuk mengakses Qaseer'),
          findsOneWidget,
        );
        expect(find.text('contoh: kasir@qaseer.id'), findsOneWidget);
        expect(find.text('Masukkan password Anda'), findsOneWidget);
        expect(
          find.textContaining(
            'Belum punya akun? Minta akun melalui pengelola Backoffice',
          ),
          findsOneWidget,
        );
        expect(
          find.text('Akun demo: kasir@qaseer.id · pelayan@qaseer.id'),
          findsOneWidget,
        );

        expect(find.textContaining('qaseer123'), findsNothing);
        expect(find.textContaining('Forgot Password'), findsNothing);
        expect(find.textContaining('Lupa Password'), findsNothing);
        expect(find.textContaining('Sign Up'), findsNothing);
      },
    );

    testWidgets('tidak overflow pada layar sempit selebar 320px', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final cubit = AuthCubit(FakeAuthRepository(delay: Duration.zero));
      addTearDown(cubit.close);

      await tester.pumpWidget(_wrapWithAuth(cubit));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Selamat Datang!'), findsOneWidget);
      expect(
        find.textContaining(
          'Belum punya akun? Minta akun melalui pengelola Backoffice',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Akun demo: kasir@qaseer.id · pelayan@qaseer.id'),
        findsOneWidget,
      );
    });

    testWidgets(
      'validasi email kosong, format salah, password kosong, dan kurang dari 6 karakter',
      (tester) async {
        final cubit = AuthCubit(FakeAuthRepository(delay: Duration.zero));
        addTearDown(cubit.close);

        await tester.pumpWidget(_wrapWithAuth(cubit));

        await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
        await tester.pump();
        expect(find.text('Email wajib diisi.'), findsOneWidget);
        expect(find.text('Password wajib diisi.'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField).at(0), 'bukan-email');
        await tester.enterText(find.byType(TextFormField).at(1), '12345');
        await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
        await tester.pump();
        expect(find.text('Format email tidak valid.'), findsOneWidget);
        expect(find.text('Password minimal 6 karakter.'), findsOneWidget);
      },
    );

    testWidgets(
      'toggle visibilitas password berfungsi dan email spasi/kapital tetap valid',
      (tester) async {
        final cubit = AuthCubit(FakeAuthRepository(delay: Duration.zero));
        addTearDown(cubit.close);

        await tester.pumpWidget(_wrapWithAuth(cubit));

        final passwordField = find.descendant(
          of: find.byType(TextFormField).at(1),
          matching: find.byType(EditableText),
        );
        expect(tester.widget<EditableText>(passwordField).obscureText, isTrue);

        await tester.tap(find.byIcon(Icons.visibility_outlined));
        await tester.pump();
        expect(tester.widget<EditableText>(passwordField).obscureText, isFalse);

        await tester.enterText(
          find.byType(TextFormField).at(0),
          '  KASIR@Qaseer.id  ',
        );
        await tester.enterText(find.byType(TextFormField).at(1), 'qaseer123');
        await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
        await tester.pumpAndSettle();

        expect(cubit.state.user?.role, UserRole.kasir);
      },
    );

    testWidgets(
      'menampilkan loading indicator dan mencegah double submit',
      (tester) async {
        final repo = _DelayedAuthRepository();
        final cubit = AuthCubit(repo);
        addTearDown(cubit.close);

        await tester.pumpWidget(_wrapWithAuth(cubit));

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'kasir@qaseer.id',
        );
        await tester.enterText(find.byType(TextFormField).at(1), 'qaseer123');
        await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.onPressed, isNull);

        await tester.tap(find.byType(FilledButton));
        await tester.pump();
        expect(repo.calls, 1);

        repo.completer.complete(
          const User(
            id: 'u-kasir-1',
            name: 'Kasir Qaseer',
            email: 'kasir@qaseer.id',
            role: UserRole.kasir,
          ),
        );
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'menampilkan pesan error saat akun peran lain ditolak dan bersih saat login ulang sukses',
      (tester) async {
        final cubit = AuthCubit(FakeAuthRepository(delay: Duration.zero));
        addTearDown(cubit.close);

        await tester.pumpWidget(_wrapWithAuth(cubit));

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'owner@qaseer.id',
        );
        await tester.enterText(find.byType(TextFormField).at(1), 'qaseer123');
        await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
        await tester.pumpAndSettle();

        const roleError =
            'Akun peran ini tidak memiliki akses. Hanya Pelayan dan Kasir yang dapat masuk.';
        expect(find.text(roleError), findsOneWidget);
        expect(cubit.state.isAuthenticated, isFalse);

        await tester.enterText(find.byType(TextFormField).at(1), '');
        await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
        await tester.pump();
        expect(find.text(roleError), findsOneWidget);
        expect(find.text('Password wajib diisi.'), findsOneWidget);

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'kasir@qaseer.id',
        );
        await tester.enterText(find.byType(TextFormField).at(1), 'qaseer123');
        await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
        await tester.pumpAndSettle();

        expect(find.text(roleError), findsNothing);
        expect(cubit.state.isAuthenticated, isTrue);
      },
    );
  });
}
