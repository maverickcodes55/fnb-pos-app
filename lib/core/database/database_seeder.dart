import 'package:drift/drift.dart';

import 'app_database.dart';

class DatabaseSeeder {
  DatabaseSeeder._();

  static Future<void> seedIfEmpty(AppDatabase db) async {
    final existingCategories = await db.select(db.categories).get();
    if (existingCategories.isNotEmpty) return;

    // Seed Categories
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

    // Seed Products
    await db.into(db.products).insert(
      ProductsCompanion.insert(
        categoryId: catPastry,
        name: 'Smoked Beef Brisket Croissant',
        sku: 'PST-001',
        price: 68000,
        imagePath: const Value('https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400&q=80'),
        isAvailable: const Value(true),
      ),
    );
    await db.into(db.products).insert(
      ProductsCompanion.insert(
        categoryId: catCoffee,
        name: 'Spanish Latte Macchiato',
        sku: 'KOP-001',
        price: 42000,
        imagePath: const Value('https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=400&q=80'),
        isAvailable: const Value(true),
      ),
    );
    await db.into(db.products).insert(
      ProductsCompanion.insert(
        categoryId: catMain,
        name: 'Truffle Parmesan Pasta',
        sku: 'MNU-001',
        price: 95000,
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
        imagePath: const Value('https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=400&q=80'),
        isAvailable: const Value(true),
      ),
    );
    await db.into(db.products).insert(
      ProductsCompanion.insert(
        categoryId: catDrink,
        name: 'Matcha Cold Foam Cloud',
        sku: 'MNM-001',
        price: 48000,
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
        imagePath: const Value('https://images.unsplash.com/photo-1551024601-bec78aea704b?w=400&q=80'),
        isAvailable: const Value(false),
      ),
    );
    await db.into(db.products).insert(
      ProductsCompanion.insert(
        categoryId: catDrink,
        name: 'Iced Cascara Orange Tonic',
        sku: 'MNM-002',
        price: 45000,
        imagePath: const Value('https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=400&q=80'),
        isAvailable: const Value(true),
      ),
    );

    // Seed Tables
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

    // Seed Sample Initial Orders (Pending, Ready, and Completed)
    final order1Id = await db.into(db.orders).insert(
      OrdersCompanion.insert(
        orderNumber: '#ORD-201',
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
        productId: 1,
        productName: 'Smoked Beef Brisket Croissant',
        priceAtSale: 68000,
        quantity: const Value(1),
        notes: const Value('Ekstra renyah'),
      ),
    );
    await db.into(db.orderItems).insert(
      OrderItemsCompanion.insert(
        orderId: order1Id,
        productId: 2,
        productName: 'Spanish Latte Macchiato',
        priceAtSale: 42000,
        quantity: const Value(1),
        notes: const Value('Less ice, less sweet'),
      ),
    );

    final order2Id = await db.into(db.orders).insert(
      OrdersCompanion.insert(
        orderNumber: '#ORD-202',
        tableId: Value(tableIds[10]), // Meja 11
        orderType: const Value('dine_in'),
        status: const Value('ready'),
        subtotal: const Value(143000),
        taxAmount: const Value(15730),
        discountAmount: const Value(10000),
        totalAmount: const Value(148730),
        paymentMethod: const Value('cash'),
      ),
    );
    await db.into(db.orderItems).insert(
      OrderItemsCompanion.insert(
        orderId: order2Id,
        productId: 3,
        productName: 'Truffle Parmesan Pasta',
        priceAtSale: 95000,
        quantity: const Value(1),
      ),
    );
    await db.into(db.orderItems).insert(
      OrderItemsCompanion.insert(
        orderId: order2Id,
        productId: 5,
        productName: 'Matcha Cold Foam Cloud',
        priceAtSale: 48000,
        quantity: const Value(1),
      ),
    );

    final order3Id = await db.into(db.orders).insert(
      OrdersCompanion.insert(
        orderNumber: '#ORD-203',
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
        orderId: order3Id,
        productId: 2,
        productName: 'Spanish Latte Macchiato',
        priceAtSale: 42000,
        quantity: const Value(2),
        notes: const Value('Bawa pulang'),
      ),
    );
  }
}
