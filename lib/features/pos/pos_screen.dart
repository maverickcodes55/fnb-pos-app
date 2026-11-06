import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/database/app_database.dart';
import 'models/pos_models.dart';
import 'providers/pos_providers.dart';
import 'widgets/cart_panel.dart';
import 'widgets/category_filter_bar.dart';
import 'widgets/checkout_modal.dart';
import 'widgets/pos_top_bar.dart';
import 'widgets/product_card.dart';
import 'widgets/product_modifier_modal.dart';
import 'widgets/receipt_preview_dialog.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  int _selectedCategoryId = 0;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onProductTap(ProductModel product) async {
    final db = ref.read(databaseProvider);
    final modifierGroups = await db.getProductModifierGroups(product.id);

    if (!mounted) return;

    if (modifierGroups.isNotEmpty) {
      // Show dynamic modifier selection modal
      ProductModifierModal.show(
        context,
        product: product,
        onConfirm: (modifiers, notes) {
          ref.read(cartNotifierProvider.notifier).addToCart(
                product,
                modifiers: modifiers,
                notes: notes,
              );
        },
      );
    } else {
      // Add directly
      ref.read(cartNotifierProvider.notifier).addToCart(product);
    }
  }

  void _openCheckoutModal(CartState cart) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CheckoutModal(
          cartItems: cart.items,
          totalAmount: cart.grandTotal,
          onPaymentSuccess: () async {
            final orderNumber = '#ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
            final itemsSnapshot = List<CartItemModel>.from(cart.items);
            final subtotal = cart.subtotal;
            final tax = cart.tax;
            final discount = cart.discount;
            final grandTotal = cart.grandTotal;
            final orderTypeStr = cart.orderType == OrderType.dineIn ? 'Dine In' : 'Takeaway';
            final tableNumber = cart.selectedTableNumber;

            // Execute atomic complete transaction in Drift
            await ref.read(cartNotifierProvider.notifier).checkout('Tunai / QRIS');

            if (mounted) {
              // Open Thermal Receipt Preview Modal
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => ReceiptPreviewDialog(
                  orderNumber: orderNumber,
                  orderType: orderTypeStr,
                  tableNumber: tableNumber,
                  items: itemsSnapshot,
                  subtotal: subtotal,
                  tax: tax,
                  discount: discount,
                  grandTotal: grandTotal,
                  paymentMethod: 'Tunai / QRIS',
                  onClose: () {},
                ),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartNotifierProvider);
    final cartNotifier = ref.read(cartNotifierProvider.notifier);
    final productsAsync = ref.watch(productsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    final dbCategories = categoriesAsync.value ?? [];
    final dbProducts = productsAsync.value ?? [];

    final categoryMap = {for (final c in dbCategories) c.id: c.name};

    final allProducts = dbProducts.map((p) {
      return ProductModel(
        id: p.id,
        categoryId: p.categoryId,
        categoryName: categoryMap[p.categoryId] ?? 'Katalog',
        name: p.name,
        sku: p.sku,
        price: p.price,
        imageUrl: p.imagePath ?? 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400&q=80',
        stock: p.stock,
        isAvailable: p.isAvailable && p.stock > 0,
      );
    }).toList();

    final categoryFilterList = [
      CategoryModel(id: 0, name: 'Semua Menu', iconName: 'all', count: allProducts.length),
      ...dbCategories.map((c) => CategoryModel(
            id: c.id,
            name: c.name,
            iconName: c.iconName,
            count: allProducts.where((p) => p.categoryId == c.id).length,
          )),
    ];

    final filteredProducts = allProducts.where((p) {
      final matchesCategory = _selectedCategoryId == 0 || p.categoryId == _selectedCategoryId;
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f1): () {
          _searchFocusNode.requestFocus();
        },
        const SingleActivator(LogicalKeyboardKey.f2): () {
          final nextType = cart.orderType == OrderType.dineIn ? OrderType.takeaway : OrderType.dineIn;
          cartNotifier.setOrderType(nextType);
        },
        const SingleActivator(LogicalKeyboardKey.f12): () {
          if (cart.items.isNotEmpty) {
            _openCheckoutModal(cart);
          }
        },
        const SingleActivator(LogicalKeyboardKey.escape): () {
          _searchController.clear();
          _searchFocusNode.unfocus();
          setState(() => _searchQuery = '');
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Row(
            children: [
              // Left Area: Discovery, Filters & Product Grid (65%)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      PosTopBar(
                        searchQuery: _searchQuery,
                        searchController: _searchController,
                        searchFocusNode: _searchFocusNode,
                        onSearchChanged: (val) => setState(() => _searchQuery = val),
                        selectedOrderType: cart.orderType,
                        onOrderTypeChanged: (type) => cartNotifier.setOrderType(type),
                        selectedTable: cart.selectedTableNumber,
                        onTableTap: () {},
                      ),
                      const SizedBox(height: 12),
                      CategoryFilterBar(
                        categories: categoryFilterList,
                        selectedCategoryId: _selectedCategoryId,
                        onCategorySelected: (id) => setState(() => _selectedCategoryId = id),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: filteredProducts.isEmpty
                            ? const Center(
                                child: Text(
                                  'Tidak ada menu yang sesuai dengan pencarian.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : GridView.builder(
                                itemCount: filteredProducts.length,
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 240,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.76,
                                ),
                                itemBuilder: (context, index) {
                                  final product = filteredProducts[index];
                                  return ProductCard(
                                    product: product,
                                    onAdd: () => _onProductTap(product),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              // Right Area: Active Cart Ticket & Checkout (35%)
              CartPanel(
                cartItems: cart.items,
                onClearCart: cartNotifier.clearCart,
                onUpdateQuantity: (item, qty) => cartNotifier.updateQuantity(item, qty),
                onUpdateNotes: (item, notes) => cartNotifier.updateNotes(item, notes),
                onCheckout: () => _openCheckoutModal(cart),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
