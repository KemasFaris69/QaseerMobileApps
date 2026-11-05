import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/restaurant_table.dart';
import '../domain/table_repository.dart';

class TableState extends Equatable {
  const TableState({
    this.tables = const [],
    this.loading = false,
    this.processing = false,
    this.error,
    this.area,
    this.filter,
  });

  final List<RestaurantTable> tables;
  final bool loading;
  final bool processing;
  final String? error;
  final String? area;
  final TableStatus? filter;

  List<String> get areas =>
      tables.map((table) => table.area).toSet().toList();

  List<RestaurantTable> get visible => tables.where((table) {
        final matchesArea = area == null || table.area == area;
        final matchesStatus = filter == null || table.status == filter;
        return matchesArea && matchesStatus;
      }).toList();

  TableState copyWith({
    List<RestaurantTable>? tables,
    bool? loading,
    bool? processing,
    String? error,
    String? area,
    TableStatus? filter,
    bool clearArea = false,
    bool clearFilter = false,
  }) {
    return TableState(
      tables: tables ?? this.tables,
      loading: loading ?? this.loading,
      processing: processing ?? this.processing,
      error: error,
      area: clearArea ? null : area ?? this.area,
      filter: clearFilter ? null : filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [
        tables,
        loading,
        processing,
        error,
        area,
        filter,
      ];
}

class TableCubit extends Cubit<TableState> {
  TableCubit(this._repository) : super(const TableState());

  final TableRepository _repository;

  Future<void> load() async {
    if (state.loading || state.processing) return;

    emit(state.copyWith(loading: true));

    try {
      final tables = await _repository.getTables();
      emit(state.copyWith(tables: tables, loading: false));
    } catch (_) {
      emit(state.copyWith(
        loading: false,
        error: 'Gagal memuat meja. Silakan coba lagi.',
      ));
    }
  }

  void selectArea(String? area) {
    emit(state.copyWith(
      area: area,
      clearArea: area == null,
      clearFilter: true,
    ));
  }

  void setFilter(TableStatus? status) {
    emit(state.copyWith(
      filter: status,
      clearFilter: status == null,
    ));
  }

  Future<String?> openTable(String id, int guests) {
    return _run(
      () => _repository.openTable(id, guests),
      'Gagal membuka meja. Pastikan meja tersedia dan jumlah tamu valid.',
    );
  }

  Future<String?> markClean(String id) {
    return _run(
      () => _repository.markClean(id),
      'Gagal menandai bersih. Periksa status meja.',
    );
  }

  Future<String?> _run(
    Future<void> Function() action,
    String failure,
  ) async {
    if (state.processing || state.loading) {
      return 'Tunggu proses sebelumnya selesai.';
    }

    emit(state.copyWith(processing: true));

    try {
      await action();
    } catch (_) {
      emit(state.copyWith(processing: false));
      return failure;
    }

    try {
      final tables = await _repository.getTables();
      emit(state.copyWith(tables: tables, processing: false));
      return null;
    } catch (_) {
      emit(state.copyWith(
        processing: false,
        error: 'Perubahan tersimpan, tetapi daftar meja gagal diperbarui.',
      ));
      return 'Perubahan tersimpan. Refresh untuk melihat data terbaru.';
    }
  }
}