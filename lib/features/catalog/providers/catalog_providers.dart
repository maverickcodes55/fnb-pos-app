import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../models/catalog_models.dart';

final catalogProductsStreamProvider = StreamProvider<List<CatalogProduct>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchProducts().map((products) {
    return products.map((p) {
      return CatalogProduct(
        id: p.id,
        name: p.name,
        sku: p.sku,
        categoryId: p.categoryId,
        categoryName: _mapCategoryName(p.categoryId),
        price: p.price,
        stock: 12,
        isAvailable: p.isAvailable,
        imageUrl: p.imagePath ?? 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400&q=80',
      );
    }).toList();
  });
});

String _mapCategoryName(int categoryId) {
  switch (categoryId) {
    case 1:
      return 'Kopi Spesialti';
    case 2:
      return 'Pastry & Roti Artisan';
    case 3:
      return 'Menu Utama';
    case 4:
      return 'Minuman Dingin';
    case 5:
      return 'Pencuci Mulut';
    default:
      return 'Umum';
  }
}

class CatalogController {
  final AppDatabase db;

  CatalogController(this.db);

  Future<void> saveProduct(CatalogProduct product) async {
    final existing = await (db.select(db.products)..where((p) => p.id.equals(product.id))).getSingleOrNull();

    if (existing == null) {
      await db.insertProduct(
        ProductsCompanion.insert(
          categoryId: product.categoryId,
          name: product.name,
          sku: product.sku,
          price: product.price,
          imagePath: Value(product.imageUrl),
          isAvailable: Value(product.isAvailable),
        ),
      );
    } else {
      await db.updateProduct(
        Product(
          id: product.id,
          categoryId: product.categoryId,
          name: product.name,
          sku: product.sku,
          price: product.price,
          imagePath: product.imageUrl,
          isAvailable: product.isAvailable,
        ),
      );
    }
  }

  Future<void> deleteProduct(int productId) async {
    await db.deleteProduct(productId);
  }

  Future<void> toggleAvailability(int productId, bool isAvailable) async {
    await (db.update(db.products)..where((p) => p.id.equals(productId))).write(
      ProductsCompanion(isAvailable: Value(isAvailable)),
    );
  }
}

final catalogControllerProvider = Provider<CatalogController>((ref) {
  final db = ref.watch(databaseProvider);
  return CatalogController(db);
});
