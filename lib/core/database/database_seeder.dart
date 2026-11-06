import 'package:drift/drift.dart';

import 'app_database.dart';

class DatabaseSeeder {
  DatabaseSeeder._();

  static Future<void> seedInitialData(AppDatabase db) async {
    // 1. Seed Default Users (Safe & Idempotent by username)
    await _getOrInsertUser(
      db,
      UsersCompanion.insert(
        name: 'Admin Sistem',
        username: 'admin',
        pin: '111111',
        role: 'admin',
        avatarUrl: const Value('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=150&q=80'),
      ),
    );

    await _getOrInsertUser(
      db,
      UsersCompanion.insert(
        name: 'Budi Santoso',
        username: 'budi_mgr',
        pin: '222222',
        role: 'manager',
        avatarUrl: const Value('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80'),
      ),
    );

    final cashierId = await _getOrInsertUser(
      db,
      UsersCompanion.insert(
        name: 'Andi Pratama',
        username: 'andi_kasir',
        pin: '333333',
        role: 'cashier',
        avatarUrl: const Value('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80'),
      ),
    );

    await _getOrInsertUser(
      db,
      UsersCompanion.insert(
        name: 'Sarah Kurniawan',
        username: 'sarah_kasir',
        pin: '333334',
        role: 'cashier',
        avatarUrl: const Value('https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=150&q=80'),
      ),
    );

    // 2. Seed Master Categories (Safe & Idempotent by name)
    final catCoffee = await _getOrInsertCategory(db, 'Kopi Spesialti', 'coffee');
    final catPastry = await _getOrInsertCategory(db, 'Pastry & Roti Artisan', 'croissant');
    final catMain = await _getOrInsertCategory(db, 'Menu Utama', 'soup');
    final catDrink = await _getOrInsertCategory(db, 'Minuman Dingin', 'glass-water');
    final catDessert = await _getOrInsertCategory(db, 'Pencuci Mulut', 'ice-cream');

    // 3. Seed Modifier Groups & Options (Safe & Idempotent)
    final sugarGroup = await _getOrInsertModifierGroup(
      db,
      name: 'Tingkat Kemanisan (Sugar Level)',
      isRequired: true,
      minSelect: 1,
      maxSelect: 1,
    );
    await _insertOptionIfNotExists(db, groupId: sugarGroup, name: 'Normal Sweet (100%)', extraPrice: 0);
    await _insertOptionIfNotExists(db, groupId: sugarGroup, name: 'Less Sweet (50%)', extraPrice: 0);
    await _insertOptionIfNotExists(db, groupId: sugarGroup, name: 'Slight Sweet (25%)', extraPrice: 0);
    await _insertOptionIfNotExists(db, groupId: sugarGroup, name: 'No Sugar (0%)', extraPrice: 0);

    final milkGroup = await _getOrInsertModifierGroup(
      db,
      name: 'Pilihan Susu (Dairy / Plant)',
      isRequired: false,
      minSelect: 0,
      maxSelect: 1,
    );
    await _insertOptionIfNotExists(db, groupId: milkGroup, name: 'Fresh Milk Regular', extraPrice: 0);
    await _insertOptionIfNotExists(db, groupId: milkGroup, name: 'Oat Milk Barista Edition', extraPrice: 8000);
    await _insertOptionIfNotExists(db, groupId: milkGroup, name: 'Roasted Almond Milk', extraPrice: 10000);
    await _insertOptionIfNotExists(db, groupId: milkGroup, name: 'Soy Milk Organic', extraPrice: 6000);

    final toppingGroup = await _getOrInsertModifierGroup(
      db,
      name: 'Ekstra Topping & Shot',
      isRequired: false,
      minSelect: 0,
      maxSelect: 3,
    );
    await _insertOptionIfNotExists(db, groupId: toppingGroup, name: 'Extra Espresso Shot', extraPrice: 10000);
    await _insertOptionIfNotExists(db, groupId: toppingGroup, name: 'Salted Caramel Drizzle', extraPrice: 6000);
    await _insertOptionIfNotExists(db, groupId: toppingGroup, name: 'Madagascar Vanilla Syrup', extraPrice: 5000);
    await _insertOptionIfNotExists(db, groupId: toppingGroup, name: 'Cold Foam Cloud', extraPrice: 8000);

    // 4. Seed Products with Stock (Safe & Idempotent by sku)
    final prodSpanishLatte = await _getOrInsertProduct(
      db,
      ProductsCompanion.insert(
        categoryId: catCoffee,
        name: 'Spanish Latte Macchiato',
        sku: 'KOP-001',
        price: 42000,
        stock: const Value(25),
        imagePath: const Value('https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=400&q=80'),
        isAvailable: const Value(true),
      ),
    );
    final prodCroissant = await _getOrInsertProduct(
      db,
      ProductsCompanion.insert(
        categoryId: catPastry,
        name: 'Smoked Beef Brisket Croissant',
        sku: 'PST-001',
        price: 68000,
        stock: const Value(12),
        imagePath: const Value('https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400&q=80'),
        isAvailable: const Value(true),
      ),
    );
    await _getOrInsertProduct(
      db,
      ProductsCompanion.insert(
        categoryId: catMain,
        name: 'Truffle Parmesan Pasta',
        sku: 'MNU-001',
        price: 95000,
        stock: const Value(8),
        imagePath: const Value('https://images.unsplash.com/photo-1621996346565-e3d5d6281691?w=400&q=80'),
        isAvailable: const Value(true),
      ),
    );
    await _getOrInsertProduct(
      db,
      ProductsCompanion.insert(
        categoryId: catPastry,
        name: 'Artisan Butter Sourdough Toast',
        sku: 'PST-002',
        price: 35000,
        stock: const Value(15),
        imagePath: const Value('https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=400&q=80'),
        isAvailable: const Value(true),
      ),
    );
    final prodMatcha = await _getOrInsertProduct(
      db,
      ProductsCompanion.insert(
        categoryId: catDrink,
        name: 'Matcha Cold Foam Cloud',
        sku: 'MNM-001',
        price: 48000,
        stock: const Value(20),
        imagePath: const Value('https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=400&q=80'),
        isAvailable: const Value(true),
      ),
    );
    await _getOrInsertProduct(
      db,
      ProductsCompanion.insert(
        categoryId: catMain,
        name: 'Pan-Seared Salmon Citrus',
        sku: 'MNU-002',
        price: 125000,
        stock: const Value(6),
        imagePath: const Value('https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400&q=80'),
        isAvailable: const Value(true),
      ),
    );
    await _getOrInsertProduct(
      db,
      ProductsCompanion.insert(
        categoryId: catDessert,
        name: 'Classic Pistachio Cannoli',
        sku: 'DST-001',
        price: 38000,
        stock: const Value(0),
        imagePath: const Value('https://images.unsplash.com/photo-1551024601-bec78aea704b?w=400&q=80'),
        isAvailable: const Value(false),
      ),
    );
    final prodTonic = await _getOrInsertProduct(
      db,
      ProductsCompanion.insert(
        categoryId: catDrink,
        name: 'Iced Cascara Orange Tonic',
        sku: 'MNM-002',
        price: 45000,
        stock: const Value(18),
        imagePath: const Value('https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=400&q=80'),
        isAvailable: const Value(true),
      ),
    );

    // 5. Link Product Modifiers (Safe & Idempotent)
    await _safeLinkProductModifier(db, prodSpanishLatte, sugarGroup);
    await _safeLinkProductModifier(db, prodSpanishLatte, milkGroup);
    await _safeLinkProductModifier(db, prodSpanishLatte, toppingGroup);

    await _safeLinkProductModifier(db, prodMatcha, sugarGroup);
    await _safeLinkProductModifier(db, prodMatcha, milkGroup);

    await _safeLinkProductModifier(db, prodTonic, sugarGroup);
    await _safeLinkProductModifier(db, prodTonic, toppingGroup);

    // 6. Seed Restaurant Tables (1 to 12)
    final tableIds = <int>[];
    for (int i = 1; i <= 12; i++) {
      final tableNum = 'Meja ${i.toString().padLeft(2, '0')}';
      final capacity = (i % 4 == 0) ? 6 : (i % 2 == 0 ? 4 : 2);
      final id = await _getOrInsertTable(db, tableNum, capacity, i == 8 || i == 11 ? 'occupied' : 'available');
      tableIds.add(id);
    }

    // 7. Seed Initial Open Shift if no active shift exists
    var activeShift = await db.getActiveShift();
    int shiftId;
    if (activeShift == null) {
      shiftId = await db.openShift(
        userId: cashierId,
        startingCash: 500000,
      );
    } else {
      shiftId = activeShift.id;
    }

    // 8. Seed Initial Completed Orders only if orders table is empty
    final existingOrders = await db.select(db.orders).get();
    if (existingOrders.isEmpty && tableIds.length >= 8) {
      final order1Id = await db.into(db.orders).insert(
        OrdersCompanion.insert(
          orderNumber: '#ORD-201',
          userId: Value(cashierId),
          shiftId: Value(shiftId),
          tableId: Value(tableIds[7]), // Meja 08
          orderType: const Value('dine_in'),
          status: const Value('pending'),
          subtotal: const Value(110000),
          taxAmount: const Value(12100),
          discountAmount: const Value(0),
          totalAmount: const Value(122100),
          paymentMethod: const Value('qris'),
        ),
      );
      await db.into(db.orderItems).insert(
        OrderItemsCompanion.insert(
          orderId: order1Id,
          productId: prodCroissant,
          productName: 'Smoked Beef Brisket Croissant',
          priceAtSale: 68000,
          quantity: const Value(1),
          notes: const Value('Ekstra renyah'),
        ),
      );
      await db.into(db.orderItems).insert(
        OrderItemsCompanion.insert(
          orderId: order1Id,
          productId: prodSpanishLatte,
          productName: 'Spanish Latte Macchiato',
          priceAtSale: 42000,
          quantity: const Value(1),
          notes: const Value('Oat Milk, Less Sweet'),
          selectedModifiers: const Value('Oat Milk Barista Edition, Less Sweet (50%)'),
        ),
      );

      final order2Id = await db.into(db.orders).insert(
        OrdersCompanion.insert(
          orderNumber: '#ORD-202',
          userId: Value(cashierId),
          shiftId: Value(shiftId),
          orderType: const Value('takeaway'),
          status: const Value('completed'),
          subtotal: const Value(84000),
          taxAmount: const Value(9240),
          discountAmount: const Value(0),
          totalAmount: const Value(93240),
          paymentMethod: const Value('cash'),
        ),
      );
      await db.into(db.orderItems).insert(
        OrderItemsCompanion.insert(
          orderId: order2Id,
          productId: prodSpanishLatte,
          productName: 'Spanish Latte Macchiato',
          priceAtSale: 42000,
          quantity: const Value(2),
          notes: const Value('Bawa pulang'),
          selectedModifiers: const Value('Normal Sweet (100%)'),
        ),
      );

      // Update expected cash on shift for the completed cash order
      final currentShift = await db.getActiveShift();
      if (currentShift != null) {
        await (db.update(db.shifts)..where((s) => s.id.equals(currentShift.id))).write(
          ShiftsCompanion(
            expectedCash: Value(currentShift.expectedCash + 93240),
          ),
        );
      }
    }
  }

  // Helper methods to guarantee zero constraint conflicts:

  static Future<int> _getOrInsertUser(AppDatabase db, UsersCompanion user) async {
    final existing = await (db.select(db.users)..where((u) => u.username.equals(user.username.value))).getSingleOrNull();
    if (existing != null) return existing.id;
    return await db.into(db.users).insert(user, mode: InsertMode.insertOrReplace);
  }

  static Future<int> _getOrInsertCategory(AppDatabase db, String name, String iconName) async {
    final existing = await (db.select(db.categories)..where((c) => c.name.equals(name))).getSingleOrNull();
    if (existing != null) return existing.id;
    return await db.into(db.categories).insert(
      CategoriesCompanion.insert(name: name, iconName: Value(iconName)),
    );
  }

  static Future<int> _getOrInsertModifierGroup(
    AppDatabase db, {
    required String name,
    required bool isRequired,
    required int minSelect,
    required int maxSelect,
  }) async {
    final existing = await (db.select(db.modifierGroups)..where((g) => g.name.equals(name))).getSingleOrNull();
    if (existing != null) return existing.id;
    return await db.into(db.modifierGroups).insert(
      ModifierGroupsCompanion.insert(
        name: name,
        isRequired: Value(isRequired),
        minSelect: Value(minSelect),
        maxSelect: Value(maxSelect),
      ),
    );
  }

  static Future<void> _insertOptionIfNotExists(
    AppDatabase db, {
    required int groupId,
    required String name,
    required int extraPrice,
  }) async {
    final existing = await (db.select(db.modifierOptions)
      ..where((o) => o.groupId.equals(groupId) & o.name.equals(name))).getSingleOrNull();
    if (existing == null) {
      await db.into(db.modifierOptions).insert(
        ModifierOptionsCompanion.insert(
          groupId: groupId,
          name: name,
          extraPrice: Value(extraPrice),
        ),
      );
    }
  }

  static Future<int> _getOrInsertProduct(AppDatabase db, ProductsCompanion product) async {
    final existing = await (db.select(db.products)..where((p) => p.sku.equals(product.sku.value))).getSingleOrNull();
    if (existing != null) return existing.id;
    return await db.into(db.products).insert(product, mode: InsertMode.insertOrReplace);
  }

  static Future<void> _safeLinkProductModifier(AppDatabase db, int productId, int groupId) async {
    final existing = await (db.select(db.productModifiers)
      ..where((pm) => pm.productId.equals(productId) & pm.groupId.equals(groupId))).getSingleOrNull();
    if (existing == null) {
      await db.linkProductModifier(productId, groupId);
    }
  }

  static Future<int> _getOrInsertTable(AppDatabase db, String tableNumber, int capacity, String status) async {
    final existing = await (db.select(db.restaurantTables)..where((t) => t.tableNumber.equals(tableNumber))).getSingleOrNull();
    if (existing != null) return existing.id;
    return await db.into(db.restaurantTables).insert(
      RestaurantTablesCompanion.insert(
        tableNumber: tableNumber,
        capacity: Value(capacity),
        status: Value(status),
      ),
    );
  }
}
