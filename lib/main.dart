import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'tables/data/fake_table_repository.dart';
import 'tables/domain/table_repository.dart';
import 'tables/presentation/table_dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<TableRepository>(
      create: (_) => FakeTableRepository(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Qaseer — Meja',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        ),
        home: const TablesDart(),
      ),
    );
  }
}
