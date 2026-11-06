import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database_seeder.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Users,
  Shifts,
  Categories,
  Products,
  ModifierGroups,
  ModifierOptions,
  ProductModifiers,
  RestaurantTables,
  Orders,
  OrderItems,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await _safeCreateTable(m, users);
          await _safeCreateTable(m, shifts);
          await _safeCreateTable(m, modifierGroups);
          await _safeCreateTable(m, modifierOptions);
          await _safeCreateTable(m, productModifiers);
          await _safeAddColumn('products', 'stock', () => m.addColumn(products, products.stock));
          await _safeAddColumn('orders', 'user_id', () => m.addColumn(orders, orders.userId));
          await _safeAddColumn('orders', 'shift_id', () => m.addColumn(orders, orders.shiftId));
          await _safeAddColumn('orders', 'voided_by', () => m.addColumn(orders, orders.voidedBy));
          await _safeAddColumn('orders', 'void_reason', () => m.addColumn(orders, orders.voidReason));
          await _safeAddColumn('order_items', 'selected_modifiers', () => m.addColumn(orderItems, orderItems.selectedModifiers));
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        await DatabaseSeeder.seedInitialData(this);
      },
    );
  }

  Future<void> _safeCreateTable(Migrator m, TableInfo table) async {
    try {
      await m.createTable(table);
    } catch (_) {
      // Table already exists or creation failed safely
    }
  }

  Future<void> _safeAddColumn(String tableName, String columnName, Future<void> Function() add) async {
    try {
      final rows = await customSelect('PRAGMA table_info("$tableName")').get();
      final exists = rows.any((r) => r.read<String>('name').toLowerCase() == columnName.toLowerCase());
      if (!exists) {
        await add();
      }
    } catch (_) {
      // Column check or add failed safely
    }
  }

  // ================= USERS CRUD & AUTH =================
  Stream<List<User>> watchUsers() => (select(users)..where((u) => u.isActive.equals(true))).watch();
  Future<List<User>> getAllUsers() => select(users).get();
  Future<User?> getUserById(int id) async {
    final list = await (select(users)..where((u) => u.id.equals(id))..limit(1)).get();
    return list.firstOrNull;
  }

  Future<User?> authenticateByPin(int userId, String pin) async {
    final list = await (select(users)
          ..where((u) => u.id.equals(userId) & u.pin.equals(pin) & u.isActive.equals(true))
          ..limit(1))
        .get();
    return list.firstOrNull;
  }

  Future<User?> verifyManagerOrAdminPin(String pin) async {
    final list = await (select(users)
          ..where((u) => u.pin.equals(pin) & (u.role.equals('admin') | u.role.equals('manager')) & u.isActive.equals(true))
          ..limit(1))
        .get();
    return list.firstOrNull;
  }

  Future<int> insertUser(UsersCompanion user) => into(users).insert(user);
  Future<bool> updateUser(Insertable<User> user) => update(users).replace(user);
  Future<int> deleteUser(int id) => (delete(users)..where((u) => u.id.equals(id))).go();

  // ================= SHIFTS MANAGEMENT =================
  Stream<Shift?> watchActiveShift() =>
      (select(shifts)..where((s) => s.status.equals('open'))..orderBy([(s) => OrderingTerm.desc(s.openedAt)])..limit(1))
          .watchSingleOrNull();

  Future<Shift?> getActiveShift() async {
    final list = await (select(shifts)
          ..where((s) => s.status.equals('open'))
          ..orderBy([(s) => OrderingTerm.desc(s.openedAt)])
          ..limit(1))
        .get();
    return list.firstOrNull;
  }
  Stream<List<Shift>> watchShifts() => (select(shifts)..orderBy([(s) => OrderingTerm.desc(s.openedAt)])).watch();

  Future<int> openShift({required int userId, required int startingCash}) {
    return into(shifts).insert(
      ShiftsCompanion.insert(
        userId: userId,
        startingCash: Value(startingCash),
        expectedCash: Value(startingCash),
        status: const Value('open'),
      ),
    );
  }

  Future<void> closeShift({required int shiftId, required int actualCash}) async {
    await (update(shifts)..where((s) => s.id.equals(shiftId))).write(
      ShiftsCompanion(
        closedAt: Value(DateTime.now()),
        actualCash: Value(actualCash),
        status: const Value('closed'),
      ),
    );
  }

  // ================= CATEGORIES & PRODUCTS =================
  Stream<List<Category>> watchCategories() => select(categories).watch();
  Stream<List<Product>> watchProducts() => select(products).watch();
  Future<int> insertCategory(CategoriesCompanion category) => into(categories).insert(category);
  Future<bool> updateCategory(Insertable<Category> category) => update(categories).replace(category);
  Future<int> deleteCategory(int id) => (delete(categories)..where((c) => c.id.equals(id))).go();

  Future<int> insertProduct(ProductsCompanion product) => into(products).insert(product);
  Future<bool> updateProduct(Insertable<Product> product) => update(products).replace(product);
  Future<int> deleteProduct(int productId) => (delete(products)..where((p) => p.id.equals(productId))).go();

  // ================= MODIFIERS =================
  Stream<List<ModifierGroup>> watchModifierGroups() => select(modifierGroups).watch();
  Stream<List<ModifierOption>> watchModifierOptions(int groupId) =>
      (select(modifierOptions)..where((m) => m.groupId.equals(groupId))).watch();
  Stream<List<ModifierOption>> watchAllModifierOptions() => select(modifierOptions).watch();
  Stream<List<ProductModifier>> watchProductModifiers() => select(productModifiers).watch();

  Future<List<ModifierGroup>> getProductModifierGroups(int productId) async {
    final links = await (select(productModifiers)..where((pm) => pm.productId.equals(productId))).get();
    if (links.isEmpty) return [];
    final groupIds = links.map((l) => l.groupId).toList();
    return (select(modifierGroups)..where((g) => g.id.isIn(groupIds))).get();
  }

  Future<List<ModifierOption>> getModifierOptions(int groupId) =>
      (select(modifierOptions)..where((m) => m.groupId.equals(groupId))).get();

  Future<int> insertModifierGroup(ModifierGroupsCompanion group) => into(modifierGroups).insert(group);
  Future<bool> updateModifierGroup(Insertable<ModifierGroup> group) => update(modifierGroups).replace(group);
  Future<int> deleteModifierGroup(int id) => (delete(modifierGroups)..where((g) => g.id.equals(id))).go();

  Future<int> insertModifierOption(ModifierOptionsCompanion option) => into(modifierOptions).insert(option);
  Future<bool> updateModifierOption(Insertable<ModifierOption> option) => update(modifierOptions).replace(option);
  Future<int> deleteModifierOption(int id) => (delete(modifierOptions)..where((o) => o.id.equals(id))).go();

  Future<int> linkProductModifier(int productId, int groupId) =>
      into(productModifiers).insert(ProductModifiersCompanion.insert(productId: productId, groupId: groupId));
  Future<int> unlinkProductModifier(int productId, int groupId) =>
      (delete(productModifiers)..where((pm) => pm.productId.equals(productId) & pm.groupId.equals(groupId))).go();

  // ================= TABLES =================
  Stream<List<RestaurantTable>> watchTables() => select(restaurantTables).watch();
  Future<void> updateTableStatus(int tableId, String status) async {
    await (update(restaurantTables)..where((t) => t.id.equals(tableId))).write(
      RestaurantTablesCompanion(status: Value(status)),
    );
  }

  // ================= ORDERS & ATOMIC TRANSACTIONS =================
  Stream<List<Order>> watchOrders() =>
      (select(orders)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  Stream<List<OrderItem>> watchOrderItems(int orderId) =>
      (select(orderItems)..where((tbl) => tbl.orderId.equals(orderId))).watch();
  Stream<List<OrderItem>> watchAllOrderItems() => select(orderItems).watch();

  Future<int> checkoutTransaction({
    required OrdersCompanion orderData,
    required List<OrderItemsCompanion> items,
    int? tableId,
  }) => completeCheckoutTransaction(orderData: orderData, items: items, tableId: tableId);

  /// Complete payment transaction:
  /// 1. Insert order and order_items
  /// 2. Deduct product stock. If stock <= 0, set isAvailable = false
  /// 3. If Cash, update expectedCash on active shift
  /// 4. If table assigned, mark table occupied
  Future<int> completeCheckoutTransaction({
    required OrdersCompanion orderData,
    required List<OrderItemsCompanion> items,
    int? tableId,
  }) {
    return transaction(() async {
      final orderId = await into(orders).insert(orderData);

      for (final item in items) {
        await into(orderItems).insert(item.copyWith(orderId: Value(orderId)));

        // Deduct inventory stock
        final prodId = item.productId.value;
        final product = await (select(products)..where((p) => p.id.equals(prodId))).getSingleOrNull();
        if (product != null) {
          final newStock = (product.stock - item.quantity.value).clamp(0, 999999);
          await (update(products)..where((p) => p.id.equals(prodId))).write(
            ProductsCompanion(
              stock: Value(newStock),
              isAvailable: Value(newStock > 0),
            ),
          );
        }
      }

      // If Cash and shift assigned, add to expected_cash in shifts table
      if (orderData.paymentMethod.value.toLowerCase() == 'cash' && orderData.shiftId.value != null) {
        final shiftId = orderData.shiftId.value!;
        final shift = await (select(shifts)..where((s) => s.id.equals(shiftId))).getSingleOrNull();
        if (shift != null) {
          await (update(shifts)..where((s) => s.id.equals(shiftId))).write(
            ShiftsCompanion(
              expectedCash: Value(shift.expectedCash + orderData.totalAmount.value),
            ),
          );
        }
      }

      if (tableId != null) {
        await (update(restaurantTables)..where((t) => t.id.equals(tableId))).write(
          const RestaurantTablesCompanion(status: Value('occupied')),
        );
      }

      return orderId;
    });
  }

  /// Atomic Void / Refund Order:
  /// 1. Update order status to 'cancelled' with voidedBy & voidReason
  /// 2. Rollback product stock in products table
  /// 3. If Cash, reduce expectedCash from shift
  Future<void> voidOrderTransaction({
    required int orderId,
    required int voidedByUserId,
    required String reason,
  }) {
    return transaction(() async {
      final order = await (select(orders)..where((o) => o.id.equals(orderId))).getSingleOrNull();
      if (order == null || order.status == 'cancelled') return;

      // Mark order as cancelled/voided
      await (update(orders)..where((o) => o.id.equals(orderId))).write(
        OrdersCompanion(
          status: const Value('cancelled'),
          voidedBy: Value(voidedByUserId),
          voidReason: Value(reason),
        ),
      );

      // Rollback product stock
      final items = await (select(orderItems)..where((oi) => oi.orderId.equals(orderId))).get();
      for (final item in items) {
        final product = await (select(products)..where((p) => p.id.equals(item.productId))).getSingleOrNull();
        if (product != null) {
          final restoredStock = product.stock + item.quantity;
          await (update(products)..where((p) => p.id.equals(item.productId))).write(
            ProductsCompanion(
              stock: Value(restoredStock),
              isAvailable: const Value(true),
            ),
          );
        }
      }

      // Rollback expected cash if payment method was cash
      if (order.paymentMethod.toLowerCase() == 'cash' && order.shiftId != null) {
        final shift = await (select(shifts)..where((s) => s.id.equals(order.shiftId!))).getSingleOrNull();
        if (shift != null) {
          final newExpected = (shift.expectedCash - order.totalAmount).clamp(0, 999999999);
          await (update(shifts)..where((s) => s.id.equals(order.shiftId!))).write(
            ShiftsCompanion(expectedCash: Value(newExpected)),
          );
        }
      }

      // If order had table, free table if no other active orders on it
      if (order.tableId != null) {
        final otherOrders = await (select(orders)
              ..where((o) => o.tableId.equals(order.tableId!) & o.status.equals('pending') & o.id.isNotValue(orderId)))
            .get();
        if (otherOrders.isEmpty) {
          await (update(restaurantTables)..where((t) => t.id.equals(order.tableId!))).write(
            const RestaurantTablesCompanion(status: Value('available')),
          );
        }
      }
    });
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    await (update(orders)..where((o) => o.id.equals(orderId))).write(
      OrdersCompanion(status: Value(status)),
    );
  }
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
