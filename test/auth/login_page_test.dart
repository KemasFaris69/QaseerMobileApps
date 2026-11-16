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
      'menampilkan dua akun demo tanpa password dan teks Backoffice',
      (tester) async {
        final cubit = AuthCubit(FakeAuthRepository(delay: Duration.zero));
        addTearDown(cubit.close);

        await tester.pumpWidget(_wrapWithAuth(cubit));

        expect(find.text('Masuk ke Qaseer'), findsOneWidget);
        expect(find.textContaining('kasir@qaseer.id'), findsOneWidget);
        expect(find.textContaining('pelayan@qaseer.id'), findsOneWidget);
        expect(
          find.textContaining('Minta akun melalui pengelola Backoffice'),
          findsOneWidget,
        );
        expect(find.textContaining('qaseer123'), findsNothing);
      },
    );

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

    testWidgets('menampilkan pesan error saat akun peran lain ditolak', (
      tester,
    ) async {
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

      expect(
        find.text(
          'Akun peran ini tidak memiliki akses. Hanya Pelayan dan Kasir yang dapat masuk.',
        ),
        findsOneWidget,
      );
      expect(cubit.state.isAuthenticated, isFalse);
    });
  });
}
