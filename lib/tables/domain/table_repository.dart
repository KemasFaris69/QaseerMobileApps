import 'restaurant_table.dart';

abstract class TableRepository {
  Future<List<RestaurantTable>> getTables();

  Future<void> openTable(String id, int guests);

  Future<void> markClean(String id);
}