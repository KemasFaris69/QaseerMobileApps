import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qasser_mobile/auth/data/fake_auth_repository.dart';
import 'package:qasser_mobile/auth/domain/auth_repository.dart';
import 'package:qasser_mobile/auth/domain/user.dart';
import 'package:qasser_mobile/main.dart';
import 'package:qasser_mobile/tables/data/fake_table_repository.dart';

class _ConfigurableLogoutAuthRepository implements AuthRepository {
  _ConfigurableLogoutAuthRepository({required this.onLogout});

  final Future<void> Function() onLogout;
  final FakeAuthRepository _delegate = FakeAuthRepository(delay: Duration.zero);
  int logoutCalls = 0;

  @override
  User? get currentUser => _delegate.currentUser;

  @override
  Future<User> login({required String email, required String password}) {
    return _delegate.login(email: email, password: password);
  }

  @override
  Future<void> logout() async {
    logoutCalls++;
    await onLogout();
    await _delegate.logout();
  }
}

void main() {
  testWidgets(
    'alur login pelayan, logout, dan login ulang kasir berjalan di MyApp',
    (tester) async {
      await tester.pumpWidget(
        MyApp(
          authRepository: FakeAuthRepository(delay: Duration.zero),
          tableRepository: FakeTableRepository(delay: Duration.zero),
        ),
      );

      expect(find.text('Masuk ke Qaseer'), findsOneWidget);
      expect(find.text('Denah Meja'), findsNothing);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'pelayan@qaseer.id',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'qaseer123');
      await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
      await tester.pumpAndSettle();

      expect(find.text('Denah Meja'), findsOneWidget);
      expect(find.text('Pelayan'), findsOneWidget);
      expect(find.text('Pelayan Qaseer'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Keluar'));
      await tester.pumpAndSettle();

      expect(find.text('Masuk ke Qaseer'), findsOneWidget);
      expect(find.textContaining('salah'), findsNothing);
      expect(find.textContaining('Gagal keluar'), findsNothing);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'kasir@qaseer.id',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'qaseer123');
      await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
      await tester.pumpAndSettle();

      expect(find.text('Denah Meja'), findsOneWidget);
      expect(find.text('Kasir'), findsOneWidget);
      expect(find.text('Kasir Qaseer'), findsOneWidget);
    },
  );

  testWidgets('menampilkan SnackBar error ketika proses logout gagal', (
    tester,
  ) async {
    final authRepo = _ConfigurableLogoutAuthRepository(
      onLogout: () async => throw StateError('network'),
    );

    await tester.pumpWidget(
      MyApp(
        authRepository: authRepo,
        tableRepository: FakeTableRepository(delay: Duration.zero),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'kasir@qaseer.id');
    await tester.enterText(find.byType(TextFormField).at(1), 'qaseer123');
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Keluar'));
    await tester.pumpAndSettle();

    expect(find.text('Denah Meja'), findsOneWidget);
    expect(find.text('Kasir'), findsOneWidget);
    expect(find.text('Gagal keluar. Silakan coba lagi.'), findsOneWidget);
  });

  testWidgets(
    'tombol Keluar menampilkan loading dan mengabaikan double-tap saat logout berjalan',
    (tester) async {
      final logoutCompleter = Completer<void>();
      final authRepo = _ConfigurableLogoutAuthRepository(
        onLogout: () => logoutCompleter.future,
      );

      await tester.pumpWidget(
        MyApp(
          authRepository: authRepo,
          tableRepository: FakeTableRepository(delay: Duration.zero),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'kasir@qaseer.id',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'qaseer123');
      await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
      await tester.pumpAndSettle();

      final logoutButtonFinder = find.widgetWithText(TextButton, 'Keluar');
      await tester.tap(logoutButtonFinder);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.widget<TextButton>(logoutButtonFinder).onPressed, isNull);

      await tester.tap(logoutButtonFinder);
      await tester.pump();
      expect(authRepo.logoutCalls, 1);

      logoutCompleter.complete();
      await tester.pumpAndSettle();

      expect(find.text('Masuk ke Qaseer'), findsOneWidget);
    },
  );
}
