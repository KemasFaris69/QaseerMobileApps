import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qasser_mobile/auth/data/fake_auth_repository.dart';
import 'package:qasser_mobile/main.dart';
import 'package:qasser_mobile/tables/data/fake_table_repository.dart';

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
}
