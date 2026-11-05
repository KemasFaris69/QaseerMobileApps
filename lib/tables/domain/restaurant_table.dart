import 'package:equatable/equatable.dart';

enum TableStatus {
  tersedia('Tersedia'),
  terisi('Terisi'),
  perluDibersihkan('Perlu Dibersihkan');

  const TableStatus(this.label);

  final String label;
}

class RestaurantTable extends Equatable {
  const RestaurantTable({
    required this.id,
    required this.number,
    required this.area,
    required this.capacity,
    this.status = TableStatus.tersedia,
    this.guests,
    this.openedAt,
    this.runningTotal = 0,
  });

  final String id;
  final String number;
  final String area;
  final int capacity;
  final TableStatus status;
  final int? guests;
  final DateTime? openedAt;
  final int runningTotal;

  @override
  List<Object?> get props => [
        id,
        number,
        area,
        capacity,
        status,
        guests,
        openedAt,
        runningTotal,
      ];
}