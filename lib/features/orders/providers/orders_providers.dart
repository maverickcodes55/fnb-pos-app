import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';

final restaurantTablesStreamProvider = StreamProvider<List<RestaurantTable>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchTables();
});

final ordersStreamProvider = StreamProvider<List<Order>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchOrders();
});

final activeOrdersStreamProvider = Provider<AsyncValue<List<Order>>>((ref) {
  final ordersAsync = ref.watch(ordersStreamProvider);
  return ordersAsync.whenData(
    (list) => list.where((o) => o.status == 'pending' || o.status == 'ready').toList(),
  );
});

final completedOrdersStreamProvider = Provider<AsyncValue<List<Order>>>((ref) {
  final ordersAsync = ref.watch(ordersStreamProvider);
  return ordersAsync.whenData(
    (list) => list.where((o) => o.status == 'completed' || o.status == 'cancelled').toList(),
  );
});

