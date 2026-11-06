import 'package:drift/drift.dart';

import 'app_database.dart';

class DatabaseSeeder {
  DatabaseSeeder._();

  static Future<void> seedInitialData(AppDatabase db) async {
    // Only execute if users table is empty
    final existingUsers = await db.select(db.users).get();
    if (existingUsers.isNotEmpty) return;

    // 1. Seed Default Users with PINs:
    // Admin: 111111 | Manager: 222222 | Cashier: 333333
    await db.into(db.users).insert(
      UsersCompanion.insert(
        name: 'Admin Sistem',
        username: 'admin',
        pin: '111111',
        role: 'admin',
        avatarUrl: const Value('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=150&q=80'),
      ),
    );

    await db.into(db.users).insert(
      UsersCompanion.insert(
        name: 'Budi Santoso',
        username: 'budi_mgr',
        pin: '222222',
        role: 'manager',
        avatarUrl: const Value('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80'),
      ),
    );

    final cashierId = await db.into(db.users).insert(
      UsersCompanion.insert(
        name: 'Andi Pratama',
        username: 'andi_kasir',
        pin: '333333',
        role: 'cashier',
        avatarUrl: const Value('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80'),
      ),
    );

    // Additional staff for rich directory
    await db.into(db.users).insert(
      UsersCompanion.insert(
        name: 'Sarah Kurniawan',
        username: 'sarah_kasir',
        pin: '333334',
        role: 'cashier',
        avatarUrl: const Value('https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=150&q=80'),
      ),
    );

    // 2. Seed Master Categories
    final catCoffee = await db.into(db.categories).insert(
      CategoriesCompanion.insert(
        name: 'Kopi Spesialti',
        iconName: const Value('coffee'),
      ),
    );
    final catPastry = await db.into(db.categories).insert(
      CategoriesCompanion.insert(
        name: 'Pastry & Roti Artisan',
        iconName: const Value('croissant'),
      ),
    );
    final catMain = await db.into(db.categories).insert(
      CategoriesCompanion.insert(
        name: 'Menu Utama',
        iconName: const Value('soup'),
      ),
    );
    final catDrink = await db.into(db.categories).insert(
      CategoriesCompanion.insert(
        name: 'Minuman Dingin',
        iconName: const Value('glass-water'),
      ),
    );
    final catDessert = await db.into(db.categories).insert(
      CategoriesCompanion.insert(
        name: 'Pencuci Mulut',
        iconName: const Value('ice-cream'),
      ),
    );

    // 3. Seed Modifier Groups & Options
    final sugarGroup = await db.into(db.modifierGroups).insert(
      ModifierGroupsCompanion.insert(
        name: 'Tingkat Kemanisan (Sugar Level)',
        isRequired: const Value(true),
        minSelect: const Value(1),
        maxSelect: const Value(1),
      ),
    );
    await db.into(db.modifierOptions).insert(ModifierOptionsCompanion.insert(groupId: sugarGroup, name: 'Normal Sweet (100%)', extraPrice: const Value(0)));
    await db.into(db.modifierOptions).insert(ModifierOptionsCompanion.insert(groupId: sugarGroup, name: 'Less Sweet (50%)', extraPrice: const Value(0)));
    await db.into(db.modifierOptions).insert(ModifierOptionsCompanion.insert(groupId: sugarGroup, name: 'Slight Sweet (25%)', extraPrice: const Value(0)));
    await db.into(db.modifierOptions).insert(ModifierOptionsCompanion.insert(groupId: sugarGroup, name: 'No Sugar (0%)', extraPrice: const Value(0)));

    final milkGroup = await db.into(db.modifierGroups).insert(
      ModifierGroupsCompanion.insert(
        name: 'Pilihan Susu (Dairy / Plant)',
        isRequired: const Value(false),
        minSelect: const Value(0),
        maxSelect: const Value(1),
      ),
    );
    await db.into(db.modifierOptions).insert(ModifierOptionsCompanion.insert(groupId: milkGroup, name: 'Fresh Milk Regular', extraPrice: const Value(0)));
    await db.into(db.modifierOptions).insert(ModifierOptionsCompanion.insert(groupId: milkGroup, name: 'Oat Milk Barista Edition', extraPrice: const Value(8000)));
    await db.into(db.modifierOptions).insert(ModifierOptionsCompanion.insert(groupId: milkGroup, name: 'Roasted Almond Milk', extraPrice: const Value(10000)));
    await db.into(db.modifierOptions).insert(ModifierOptionsCompanion.insert(groupId: milkGroup, name: 'Soy Milk Organic', extraPrice: const Value(6000)));

    final toppingGroup = await db.into(db.modifierGroups).insert(
      ModifierGroupsCompanion.insert(
        name: 'Ekstra Topping & Shot',
        isRequired: const Value(false),
        minSelect: const Value(0),
        maxSelect: const Value(3),
      ),
    );
    await db.into(db.modifierOptions).insert(ModifierOptionsCompanion.insert(groupId: toppingGroup, name: 'Extra Espresso Shot', extraPrice: const Value(10000)));
    await db.into(db.modifierOptions).insert(ModifierOptionsCompanion.insert(groupId: toppingGroup, name: 'Salted Caramel Drizzle', extraPrice: const Value(6000)));
    await db.into(db.modifierOptions).insert(ModifierOptionsCompanion.insert(groupId: toppingGroup, name: 'Madagascar Vanilla Syrup', extraPrice: const Value(5000)));
    await db.into(db.modifierOptions).insert(ModifierOptionsCompanion.insert(groupId: toppingGroup, name: 'Cold Foam Cloud', extraPrice: const Value(8000)));

    // 4. Seed Products with Stock
    final prodSpanishLatte = await db.into(db.products).insert(
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
    final prodCroissant = await db.into(db.products).insert(
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
    await db.into(db.products).insert(
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
    await db.into(db.products).insert(
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
    final prodMatcha = await db.into(db.products).insert(
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
    await db.into(db.products).insert(
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
    await db.into(db.products).insert(
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
    final prodTonic = await db.into(db.products).insert(
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

    // 5. Link Product Modifiers
    // Spanish Latte has Sugar, Milk, and Topping groups
    await db.linkProductModifier(prodSpanishLatte, sugarGroup);
    await db.linkProductModifier(prodSpanishLatte, milkGroup);
    await db.linkProductModifier(prodSpanishLatte, toppingGroup);

    // Matcha Cold Foam has Sugar and Milk groups
    await db.linkProductModifier(prodMatcha, sugarGroup);
    await db.linkProductModifier(prodMatcha, milkGroup);

    // Iced Tonic has Sugar and Topping groups
    await db.linkProductModifier(prodTonic, sugarGroup);
    await db.linkProductModifier(prodTonic, toppingGroup);

    // 6. Seed Restaurant Tables (1 to 12)
    final tableIds = <int>[];
    for (int i = 1; i <= 12; i++) {
      final tableNum = 'Meja ${i.toString().padLeft(2, '0')}';
      final capacity = (i % 4 == 0) ? 6 : (i % 2 == 0 ? 4 : 2);
      final id = await db.into(db.restaurantTables).insert(
        RestaurantTablesCompanion.insert(
          tableNumber: tableNum,
          capacity: Value(capacity),
          status: Value(i == 8 || i == 11 ? 'occupied' : 'available'),
        ),
      );
      tableIds.add(id);
    }

    // 7. Seed Initial Open Shift for Cashier
    final initialShiftId = await db.openShift(
      userId: cashierId,
      startingCash: 500000,
    );

    // 8. Seed Initial Completed Orders under the shift
    final order1Id = await db.into(db.orders).insert(
      OrdersCompanion.insert(
        orderNumber: '#ORD-201',
        userId: Value(cashierId),
        shiftId: Value(initialShiftId),
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
        shiftId: Value(initialShiftId),
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
    final shift = await db.getActiveShift();
    if (shift != null) {
      await (db.update(db.shifts)..where((s) => s.id.equals(shift.id))).write(
        ShiftsCompanion(
          expectedCash: Value(shift.expectedCash + 93240),
        ),
      );
    }
  }
}
