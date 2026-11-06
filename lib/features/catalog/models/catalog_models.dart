enum StockStatusFilter {
  all('Semua'),
  safe('Stok Aman'),
  low('Stok Menipis'),
  outOfStock('Stok Habis');

  final String label;
  const StockStatusFilter(this.label);
}

class CatalogProduct {
  final int id;
  String name;
  String sku;
  int categoryId;
  String categoryName;
  int price;
  int costPrice;
  int stock;
  int minStockAlert;
  bool isAvailable;
  String imageUrl;

  CatalogProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    this.costPrice = 0,
    required this.stock,
    this.minStockAlert = 5,
    this.isAvailable = true,
    required this.imageUrl,
  });

  CatalogProduct copyWith({
    int? id,
    String? name,
    String? sku,
    int? categoryId,
    String? categoryName,
    int? price,
    int? costPrice,
    int? stock,
    int? minStockAlert,
    bool? isAvailable,
    String? imageUrl,
  }) {
    return CatalogProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      minStockAlert: minStockAlert ?? this.minStockAlert,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

