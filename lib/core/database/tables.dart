import 'package:drift/drift.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get iconName => text().withDefault(const Constant('coffee'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get name => text()();
  TextColumn get sku => text().unique()();
  IntColumn get price => integer()();
  TextColumn get imagePath => text().nullable()();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
}

class RestaurantTables extends Table {
  @override
  String get tableName => 'tables';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get tableNumber => text().unique()();
  IntColumn get capacity => integer().withDefault(const Constant(4))();
  TextColumn get status => text().withDefault(const Constant('available'))(); // 'available', 'occupied'
}

class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderNumber => text().unique()();
  IntColumn get tableId => integer().nullable().references(RestaurantTables, #id)();
  TextColumn get orderType => text().withDefault(const Constant('dine_in'))(); // 'dine_in', 'takeaway'
  TextColumn get status => text().withDefault(const Constant('pending'))(); // 'pending', 'completed', 'cancelled'
  IntColumn get subtotal => integer().withDefault(const Constant(0))();
  IntColumn get taxAmount => integer().withDefault(const Constant(0))();
  IntColumn get discountAmount => integer().withDefault(const Constant(0))();
  IntColumn get totalAmount => integer().withDefault(const Constant(0))();
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))(); // 'cash', 'qris', 'debit'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class OrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().references(Orders, #id, onDelete: KeyAction.cascade)();
  IntColumn get productId => integer().references(Products, #id)();
  TextColumn get productName => text()();
  IntColumn get priceAtSale => integer()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  TextColumn get notes => text().nullable()();
}

