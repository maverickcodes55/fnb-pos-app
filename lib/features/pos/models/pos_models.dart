import '../../../core/database/app_database.dart';

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
  final List<ModifierOption> selectedModifiers;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    this.notes,
    this.selectedModifiers = const [],
  });

  int get modifierExtra => selectedModifiers.fold(0, (sum, m) => sum + m.extraPrice);
  int get unitPrice => product.price + modifierExtra;
  int get subtotal => unitPrice * quantity;
  String get modifiersSummary => selectedModifiers.map((m) => m.name).join(', ');
}

