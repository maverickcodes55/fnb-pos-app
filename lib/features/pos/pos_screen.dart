import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'models/mock_pos_data.dart';
import 'models/pos_models.dart';
import 'widgets/cart_panel.dart';
import 'widgets/category_filter_bar.dart';
import 'widgets/checkout_modal.dart';
import 'widgets/pos_top_bar.dart';
import 'widgets/product_card.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  String _searchQuery = '';
  int _selectedCategoryId = 0;
  OrderType _selectedOrderType = OrderType.dineIn;
  final String _selectedTable = 'MEJA 08';

  final List<CartItemModel> _cartItems = [
    CartItemModel(
      product: mockProducts[1], // Spanish Latte Macchiato
      quantity: 2,
      notes: 'Kurang Gula, Tambah Oat Milk',
    ),
    CartItemModel(
      product: mockProducts[0], // Smoked Beef Brisket Croissant
      quantity: 1,
      notes: 'Hangat, ekstra saus mustard',
    ),
    CartItemModel(
      product: mockProducts[4], // Matcha Cold Foam Cloud
      quantity: 1,
      notes: 'Es & manis standar',
    ),
  ];

  List<ProductModel> get _filteredProducts {
    return mockProducts.where((p) {
      final matchesCategory =
          _selectedCategoryId == 0 || p.categoryId == _selectedCategoryId;
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _addToCart(ProductModel product) {
    setState(() {
      final existingIndex =
          _cartItems.indexWhere((item) => item.product.id == product.id);
      if (existingIndex != -1) {
        _cartItems[existingIndex].quantity += 1;
      } else {
        _cartItems.add(CartItemModel(product: product, quantity: 1));
      }
    });
  }

  void _updateQuantity(CartItemModel item, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        _cartItems.remove(item);
      } else {
        item.quantity = newQuantity;
      }
    });
  }

  void _updateNotes(CartItemModel item, String newNotes) {
    setState(() {
      item.notes = newNotes;
    });
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
    });
  }

  void _openCheckoutModal() {
    final subtotal =
        _cartItems.fold(0, (sum, item) => sum + item.subtotal);
    final discount = (subtotal * 0.10).round();
    final service = ((subtotal - discount) * 0.05).round();
    final tax = (((subtotal - discount) + service) * 0.11).round();
    final grandTotal = (subtotal - discount) + service + tax;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CheckoutModal(
          cartItems: _cartItems,
          totalAmount: grandTotal,
          onPaymentSuccess: () {
            setState(() {
              _cartItems.clear();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: AppColors.secondary,
                content: Text(
                  'Pembayaran berhasil diverifikasi! Struk telah dicetak.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  // Top action bar
                  PosTopBar(
                    searchQuery: _searchQuery,
                    onSearchChanged: (val) => setState(() => _searchQuery = val),
                    selectedOrderType: _selectedOrderType,
                    onOrderTypeChanged: (type) =>
                        setState(() => _selectedOrderType = type),
                    selectedTable: _selectedTable,
                    onTableTap: () {},
                  ),
                  const SizedBox(height: 12),
                  // Category carousel
                  CategoryFilterBar(
                    categories: mockCategories,
                    selectedCategoryId: _selectedCategoryId,
                    onCategorySelected: (id) =>
                        setState(() => _selectedCategoryId = id),
                  ),
                  const SizedBox(height: 16),
                  // Product Grid Matrix
                  Expanded(
                    child: _filteredProducts.isEmpty
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
                            itemCount: _filteredProducts.length,
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 240,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.76,
                            ),
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return ProductCard(
                                product: product,
                                onAdd: () => _addToCart(product),
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
            cartItems: _cartItems,
            onClearCart: _clearCart,
            onUpdateQuantity: _updateQuantity,
            onUpdateNotes: _updateNotes,
            onCheckout: _openCheckoutModal,
          ),
        ],
      ),
    );
  }
}
