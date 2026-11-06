import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database_seeder.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Categories, Products, RestaurantTables, Orders, OrderItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        await DatabaseSeeder.seedIfEmpty(this);
      },
    );
  }

  // Reactive Streams
  Stream<List<Category>> watchCategories() => select(categories).watch();
  Stream<List<Product>> watchProducts() => select(products).watch();
  Stream<List<RestaurantTable>> watchTables() => select(restaurantTables).watch();
  Stream<List<Order>> watchOrders() => (select(orders)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  Stream<List<OrderItem>> watchOrderItems(int orderId) =>
      (select(orderItems)..where((tbl) => tbl.orderId.equals(orderId))).watch();
  Stream<List<OrderItem>> watchAllOrderItems() => select(orderItems).watch();

  // Transactional Checkout Execution
  Future<int> checkoutTransaction({
    required OrdersCompanion orderData,
    required List<OrderItemsCompanion> items,
    int? tableId,
  }) {
    return transaction(() async {
      final orderId = await into(orders).insert(orderData);
      for (final item in items) {
        await into(orderItems).insert(item.copyWith(orderId: Value(orderId)));
      }
      if (tableId != null) {
        await (update(restaurantTables)..where((t) => t.id.equals(tableId))).write(
          const RestaurantTablesCompanion(status: Value('occupied')),
        );
      }
      return orderId;
    });
  }

  // Table Management
  Future<void> updateTableStatus(int tableId, String status) async {
    await (update(restaurantTables)..where((t) => t.id.equals(tableId))).write(
      RestaurantTablesCompanion(status: Value(status)),
    );
  }

  // Order Management
  Future<void> updateOrderStatus(int orderId, String status) async {
    await (update(orders)..where((o) => o.id.equals(orderId))).write(
      OrdersCompanion(status: Value(status)),
    );
  }

  // Product CRUD
  Future<int> insertProduct(ProductsCompanion product) => into(products).insert(product);
  Future<bool> updateProduct(Insertable<Product> product) => update(products).replace(product);
  Future<int> deleteProduct(int productId) =>
      (delete(products)..where((p) => p.id.equals(productId))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'fnb_pos.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => database.close());
  return database;
});
