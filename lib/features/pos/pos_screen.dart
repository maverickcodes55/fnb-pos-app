import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import 'models/mock_pos_data.dart';
import 'models/pos_models.dart';
import 'providers/pos_providers.dart';
import 'widgets/cart_panel.dart';
import 'widgets/category_filter_bar.dart';
import 'widgets/checkout_modal.dart';
import 'widgets/pos_top_bar.dart';
import 'widgets/product_card.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  String _searchQuery = '';
  int _selectedCategoryId = 0;

  List<ProductModel> _mapProducts(List<dynamic> dbProducts) {
    if (dbProducts.isEmpty) return mockProducts;
    return dbProducts.map((p) {
      return ProductModel(
        id: p.id,
        categoryId: p.categoryId,
        categoryName: p.categoryId == 1
            ? 'Kopi'
            : p.categoryId == 2
                ? 'Pastry'
                : p.categoryId == 3
                    ? 'Makanan'
                    : 'Minuman',
        name: p.name,
        sku: p.sku,
        price: p.price,
        imageUrl: p.imagePath ?? 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400&q=80',
        stock: 15,
        isAvailable: p.isAvailable,
      );
    }).toList();
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
            await ref.read(cartNotifierProvider.notifier).checkout('Tunai / QRIS');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.secondary,
                  content: Text(
                    'Transaksi berhasil disimpan ke database & struk dicetak!',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  behavior: SnackBarBehavior.floating,
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

    final allProducts = productsAsync.maybeWhen(
      data: (list) => _mapProducts(list),
      orElse: () => mockProducts,
    );

    final filteredProducts = allProducts.where((p) {
      final matchesCategory =
          _selectedCategoryId == 0 || p.categoryId == _selectedCategoryId;
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
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
                    onSearchChanged: (val) => setState(() => _searchQuery = val),
                    selectedOrderType: cart.orderType,
                    onOrderTypeChanged: (type) => cartNotifier.setOrderType(type),
                    selectedTable: cart.selectedTableNumber,
                    onTableTap: () {},
                  ),
                  const SizedBox(height: 12),
                  CategoryFilterBar(
                    categories: mockCategories,
                    selectedCategoryId: _selectedCategoryId,
                    onCategorySelected: (id) =>
                        setState(() => _selectedCategoryId = id),
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
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 240,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.76,
                            ),
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return ProductCard(
                                product: product,
                                onAdd: () => cartNotifier.addToCart(product),
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
            onUpdateQuantity: (item, qty) =>
                cartNotifier.updateQuantity(item, qty),
            onUpdateNotes: (item, notes) =>
                cartNotifier.updateNotes(item, notes),
            onCheckout: () => _openCheckoutModal(cart),
          ),
        ],
      ),
    );
  }
}
