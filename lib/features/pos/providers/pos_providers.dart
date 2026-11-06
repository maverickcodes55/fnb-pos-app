import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/pos_models.dart';

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchCategories();
});

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchProducts();
});

class CartState {
  final List<CartItemModel> items;
  final OrderType orderType;
  final int? selectedTableId;
  final String selectedTableNumber;

  const CartState({
    this.items = const [],
    this.orderType = OrderType.dineIn,
    this.selectedTableId,
    this.selectedTableNumber = 'MEJA 08',
  });

  int get subtotal => items.fold(0, (sum, i) => sum + i.subtotal);
  int get discount => (subtotal * 0.10).round();
  int get serviceFee => ((subtotal - discount) * 0.05).round();
  int get tax => (((subtotal - discount) + serviceFee) * 0.11).round();
  int get grandTotal => (subtotal - discount) + serviceFee + tax;
  int get totalQuantity => items.fold(0, (sum, i) => sum + i.quantity);

  CartState copyWith({
    List<CartItemModel>? items,
    OrderType? orderType,
    int? selectedTableId,
    String? selectedTableNumber,
  }) {
    return CartState(
      items: items ?? this.items,
      orderType: orderType ?? this.orderType,
      selectedTableId: selectedTableId ?? this.selectedTableId,
      selectedTableNumber: selectedTableNumber ?? this.selectedTableNumber,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final Ref ref;

  CartNotifier(this.ref) : super(const CartState());

  void setOrderType(OrderType type) {
    state = state.copyWith(orderType: type);
  }

  void setSelectedTable(int? tableId, String tableNumber) {
    state = state.copyWith(
      selectedTableId: tableId,
      selectedTableNumber: tableNumber,
    );
  }

  void addToCart(
    ProductModel product, {
    List<ModifierOption> modifiers = const [],
    String? notes,
  }) {
    final list = List<CartItemModel>.from(state.items);
    final modIds = modifiers.map((m) => m.id).toSet();

    final idx = list.indexWhere((i) {
      if (i.product.id != product.id) return false;
      final existingModIds = i.selectedModifiers.map((m) => m.id).toSet();
      return modIds.length == existingModIds.length && modIds.containsAll(existingModIds);
    });

    if (idx != -1 && (notes == null || notes == list[idx].notes)) {
      list[idx].quantity += 1;
    } else {
      list.add(CartItemModel(
        product: product,
        quantity: 1,
        selectedModifiers: modifiers,
        notes: notes,
      ));
    }
    state = state.copyWith(items: list);
  }

  void updateQuantity(CartItemModel item, int newQty) {
    final list = List<CartItemModel>.from(state.items);
    if (newQty <= 0) {
      list.remove(item);
    } else {
      final idx = list.indexOf(item);
      if (idx != -1) {
        list[idx].quantity = newQty;
      }
    }
    state = state.copyWith(items: list);
  }

  void updateNotes(CartItemModel item, String notes) {
    final list = List<CartItemModel>.from(state.items);
    final idx = list.indexOf(item);
    if (idx != -1) {
      list[idx].notes = notes;
    }
    state = state.copyWith(items: list);
  }

  void clearCart() {
    state = state.copyWith(items: const []);
  }

  Future<int> checkout(String paymentMethod) async {
    final db = ref.read(databaseProvider);
    final user = ref.read(currentUserProvider);
    final activeShift = await db.getActiveShift();

    final orderNum = 'ORD-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    final orderCompanion = OrdersCompanion.insert(
      orderNumber: orderNum,
      userId: user != null ? Value(user.id) : const Value.absent(),
      shiftId: activeShift != null ? Value(activeShift.id) : const Value.absent(),
      tableId: state.selectedTableId != null ? Value(state.selectedTableId) : const Value.absent(),
      orderType: Value(state.orderType == OrderType.dineIn ? 'dine_in' : 'takeaway'),
      status: const Value('pending'),
      subtotal: Value(state.subtotal),
      taxAmount: Value(state.tax),
      discountAmount: Value(state.discount),
      totalAmount: Value(state.grandTotal),
      paymentMethod: Value(paymentMethod),
      createdAt: Value(DateTime.now()),
    );

    final itemCompanions = state.items.map((cartItem) {
      return OrderItemsCompanion.insert(
        orderId: 0, // will be replaced in transaction
        productId: cartItem.product.id,
        productName: cartItem.product.name,
        priceAtSale: cartItem.unitPrice,
        quantity: Value(cartItem.quantity),
        notes: cartItem.notes != null ? Value(cartItem.notes) : const Value.absent(),
        selectedModifiers: cartItem.selectedModifiers.isNotEmpty
            ? Value(cartItem.modifiersSummary)
            : const Value.absent(),
      );
    }).toList();

    final orderId = await db.completeCheckoutTransaction(
      orderData: orderCompanion,
      items: itemCompanions,
      tableId: state.selectedTableId,
    );

    clearCart();
    return orderId;
  }
}

final cartNotifierProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ref);
});
