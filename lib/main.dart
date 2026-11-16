import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth/data/fake_auth_repository.dart';
import 'auth/domain/auth_repository.dart';
import 'auth/domain/user.dart';
import 'auth/presentation/auth_cubit.dart';
import 'auth/presentation/login_page.dart';
import 'tables/data/fake_table_repository.dart';
import 'tables/domain/table_repository.dart';
import 'tables/presentation/table_dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.authRepository,
    this.tableRepository,
  });

  final AuthRepository? authRepository;
  final TableRepository? tableRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => authRepository ?? FakeAuthRepository(),
        ),
        RepositoryProvider<TableRepository>(
          create: (_) => tableRepository ?? FakeTableRepository(),
        ),
      ],
      child: BlocProvider<AuthCubit>(
        create: (context) => AuthCubit(context.read<AuthRepository>()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Qaseer — POS Restoran',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
            scaffoldBackgroundColor: const Color(0xFFF3F4F6),
          ),
          home: const _AuthGate(),
        ),
      ),
    );
  }
}

// TODO(orang-2): Ganti _AuthGate dan _AuthenticatedSessionShell dengan AppRouter + HomeShell.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;
        if (user == null) {
          return const LoginPage();
        }
        return _AuthenticatedSessionShell(
          user: user,
          loggingOut: state.loading,
        );
      },
    );
  }
}

class _AuthenticatedSessionShell extends StatelessWidget {
  const _AuthenticatedSessionShell({
    required this.user,
    required this.loggingOut,
  });

  final User user;
  final bool loggingOut;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Material(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      user.role.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: loggingOut
                        ? null
                        : () => context.read<AuthCubit>().logout(),
                    child: loggingOut
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text('Keluar'),
                            ],
                          )
                        : const Text('Keluar'),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: const TablesDart(),
          ),
        ),
      ],
    );
  }
}
