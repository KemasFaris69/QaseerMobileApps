import '../domain/restaurant_table.dart';
import '../domain/table_repository.dart';

class FakeTableRepository implements TableRepository {
  FakeTableRepository({
    this.delay = const Duration(milliseconds: 400),
  }) {
    final now = DateTime.now();

    final initialTables = [
      const RestaurantTable(
        id: 'A1',
        number: 'A1',
        area: 'Indoor',
        capacity: 2,
      ),
      const RestaurantTable(
        id: 'A2',
        number: 'A2',
        area: 'Indoor',
        capacity: 4,
      ),
      RestaurantTable(
        id: 'A3',
        number: 'A3',
        area: 'Indoor',
        capacity: 4,
        status: TableStatus.terisi,
        guests: 3,
        openedAt: now.subtract(const Duration(minutes: 45)),
        runningTotal: 146000,
      ),
      const RestaurantTable(
        id: 'A4',
        number: 'A4',
        area: 'Indoor',
        capacity: 4,
        status: TableStatus.perluDibersihkan,
      ),
      const RestaurantTable(
        id: 'B1',
        number: 'B1',
        area: 'Outdoor',
        capacity: 4,
      ),
      RestaurantTable(
        id: 'B2',
        number: 'B2',
        area: 'Outdoor',
        capacity: 6,
        status: TableStatus.terisi,
        guests: 4,
        openedAt: now.subtract(const Duration(minutes: 20)),
        runningTotal: 84000,
      ),
      const RestaurantTable(
        id: 'B3',
        number: 'B3',
        area: 'Outdoor',
        capacity: 2,
        status: TableStatus.perluDibersihkan,
      ),
      const RestaurantTable(
        id: 'B4',
        number: 'B4',
        area: 'Outdoor',
        capacity: 4,
      ),
    ];

    for (final table in initialTables) {
      _tables[table.id] = table;
    }
  }

  final Duration delay;
  final Map<String, RestaurantTable> _tables = {};

  @override
  Future<List<RestaurantTable>> getTables() async {
    await Future.delayed(delay);
    return List.unmodifiable(_tables.values);
  }

  @override
  Future<void> openTable(String id, int guests) async {
    await Future.delayed(delay);

    final table = _tables[id];

    if (table == null) {
      throw StateError('Meja tidak ditemukan.');
    }

    if (table.status != TableStatus.tersedia) {
      throw StateError('Meja tidak tersedia.');
    }

    if (guests < 1) {
      throw ArgumentError('Jumlah tamu minimal satu.');
    }

    _tables[id] = RestaurantTable(
      id: table.id,
      number: table.number,
      area: table.area,
      capacity: table.capacity,
      status: TableStatus.terisi,
      guests: guests,
      openedAt: DateTime.now(),
    );
  }

  @override
  Future<void> markClean(String id) async {
    await Future.delayed(delay);

    final table = _tables[id];

    if (table == null) {
      throw StateError('Meja tidak ditemukan.');
    }

    if (table.status != TableStatus.perluDibersihkan) {
      throw StateError('Meja tidak perlu dibersihkan.');
    }

    _tables[id] = RestaurantTable(
      id: table.id,
      number: table.number,
      area: table.area,
      capacity: table.capacity,
    );
  }
}