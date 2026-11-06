import 'package:drift/drift.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get username => text().unique()();
  TextColumn get pin => text()(); // 6-digit PIN
  TextColumn get role => text()(); // 'admin', 'manager', 'cashier'
  TextColumn get avatarUrl => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class Shifts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  DateTimeColumn get openedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get closedAt => dateTime().nullable()();
  IntColumn get startingCash => integer().withDefault(const Constant(0))();
  IntColumn get expectedCash => integer().withDefault(const Constant(0))();
  IntColumn get actualCash => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('open'))(); // 'open', 'closed'
}

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
  IntColumn get stock => integer().withDefault(const Constant(10))();
  TextColumn get imagePath => text().nullable()();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
}

class ModifierGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BoolColumn get isRequired => boolean().withDefault(const Constant(false))();
  IntColumn get minSelect => integer().withDefault(const Constant(0))();
  IntColumn get maxSelect => integer().withDefault(const Constant(1))();
}

class ModifierOptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get groupId => integer().references(ModifierGroups, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  IntColumn get extraPrice => integer().withDefault(const Constant(0))();
}

class ProductModifiers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id, onDelete: KeyAction.cascade)();
  IntColumn get groupId => integer().references(ModifierGroups, #id, onDelete: KeyAction.cascade)();
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
  IntColumn get userId => integer().nullable().references(Users, #id)();
  IntColumn get shiftId => integer().nullable().references(Shifts, #id)();
  IntColumn get tableId => integer().nullable().references(RestaurantTables, #id)();
  TextColumn get orderType => text().withDefault(const Constant('dine_in'))(); // 'dine_in', 'takeaway'
  TextColumn get status => text().withDefault(const Constant('pending'))(); // 'pending', 'completed', 'cancelled'
  IntColumn get subtotal => integer().withDefault(const Constant(0))();
  IntColumn get taxAmount => integer().withDefault(const Constant(0))();
  IntColumn get discountAmount => integer().withDefault(const Constant(0))();
  IntColumn get totalAmount => integer().withDefault(const Constant(0))();
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))(); // 'cash', 'qris', 'debit'
  IntColumn get voidedBy => integer().nullable().references(Users, #id)();
  TextColumn get voidReason => text().nullable()();
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
  TextColumn get selectedModifiers => text().nullable()();
}
