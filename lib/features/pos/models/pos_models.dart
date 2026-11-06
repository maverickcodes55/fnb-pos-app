enum OrderType {
  dineIn('Dine-In'),
  takeaway('Takeaway'),
  delivery('Pengantaran');

  final String label;
  const OrderType(this.label);
}

class CategoryModel {
  final int id;
  final String name;
  final String iconName;
  final int count;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
    required this.count,
  });
}

class ProductModel {
  final int id;
  final int categoryId;
  final String categoryName;
  final String name;
  final String sku;
  final int price;
  final String imageUrl;
  final int stock;
  final String? badge;
  final bool isAvailable;

  const ProductModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.sku,
    required this.price,
    required this.imageUrl,
    required this.stock,
    this.badge,
    this.isAvailable = true,
  });
}

class CartItemModel {
  final ProductModel product;
  int quantity;
  String? notes;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    this.notes,
  });

  int get subtotal => product.price * quantity;
}
