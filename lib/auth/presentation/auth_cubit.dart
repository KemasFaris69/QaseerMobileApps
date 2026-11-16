import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/auth_repository.dart';
import '../domain/user.dart';

class AuthState extends Equatable {
  const AuthState({
    this.user,
    this.loading = false,
    this.error,
  });

  final User? user;
  final bool loading;
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool clearUser = false,
    bool? loading,
    String? error,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [user, loading, error];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository)
      : super(AuthState(user: _repository.currentUser));

  final AuthRepository _repository;

  Future<void> login(String email, String password) async {
    if (state.loading) return;

    emit(state.copyWith(loading: true));

    try {
      final user = await _repository.login(email: email, password: password);
      emit(state.copyWith(user: user, loading: false));
    } on AuthException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Terjadi kesalahan saat masuk. Silakan coba lagi.',
        ),
      );
    }
  }

  Future<void> logout() async {
    if (state.loading) return;

    emit(state.copyWith(loading: true));

    try {
      await _repository.logout();
      emit(const AuthState());
    } catch (_) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Gagal keluar. Silakan coba lagi.',
        ),
      );
    }
  }
}
