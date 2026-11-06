import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import 'models/catalog_models.dart';
import 'providers/catalog_providers.dart';
import 'widgets/catalog_filter_bar.dart';
import 'widgets/catalog_table.dart';
import 'widgets/product_form_drawer.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  String _searchQuery = '';
  int _selectedCategoryId = 0;
  StockStatusFilter _selectedStockFilter = StockStatusFilter.all;

  CatalogProduct? _selectedProduct;
  bool _isDrawerOpen = false;

  void _onSaveProduct(CatalogProduct product) async {
    await ref.read(catalogControllerProvider).saveProduct(product);
    setState(() {
      _selectedProduct = product;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menu "${product.name}" berhasil disimpan ke database!'),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onToggleAvailability(CatalogProduct product, bool isAvailable) async {
    await ref.read(catalogControllerProvider).toggleAvailability(product.id, isAvailable);
    setState(() {
      product.isAvailable = isAvailable;
      if (_selectedProduct?.id == product.id) {
        _selectedProduct = product.copyWith(isAvailable: isAvailable);
      }
    });
  }

  void _onDeleteProduct(CatalogProduct product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Menu'),
          content: Text('Apakah Anda yakin ingin menghapus "${product.name}" dari katalog?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                Navigator.pop(context);
                await ref.read(catalogControllerProvider).deleteProduct(product.id);
                setState(() {
                  _selectedProduct = null;
                  _isDrawerOpen = false;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Menu "${product.name}" telah dihapus dari database.'),
                      backgroundColor: AppColors.onSurface,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _openAddNew() {
    setState(() {
      _selectedProduct = null;
      _isDrawerOpen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(catalogProductsStreamProvider);
    final products = productsAsync.value ?? [];

    if (_selectedProduct == null && products.isNotEmpty && !_isDrawerOpen) {
      _selectedProduct = products.first;
      _isDrawerOpen = true;
    }

    final filteredProducts = products.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategoryId == 0 || p.categoryId == _selectedCategoryId;

      bool matchesStock = true;
      switch (_selectedStockFilter) {
        case StockStatusFilter.safe:
          matchesStock = p.stock > p.minStockAlert;
          break;
        case StockStatusFilter.low:
          matchesStock = p.stock > 0 && p.stock <= p.minStockAlert;
          break;
        case StockStatusFilter.outOfStock:
          matchesStock = p.stock == 0;
          break;
        case StockStatusFilter.all:
          matchesStock = true;
          break;
      }

      return matchesSearch && matchesCategory && matchesStock;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Left Area: Filter Bar & Catalog Table
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CatalogFilterBar(
                    totalCount: products.length,
                    searchQuery: _searchQuery,
                    onSearchChanged: (val) => setState(() => _searchQuery = val),
                    selectedCategoryId: _selectedCategoryId,
                    onCategorySelected: (val) => setState(() => _selectedCategoryId = val),
                    selectedStockFilter: _selectedStockFilter,
                    onStockFilterChanged: (val) => setState(() => _selectedStockFilter = val),
                    onAddNewProduct: _openAddNew,
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: CatalogTable(
                      products: filteredProducts,
                      selectedProduct: _selectedProduct,
                      onSelectProduct: (p) {
                        setState(() {
                          _selectedProduct = p;
                          _isDrawerOpen = true;
                        });
                      },
                      onToggleAvailability: _onToggleAvailability,
                      onEditProduct: (p) {
                        setState(() {
                          _selectedProduct = p;
                          _isDrawerOpen = true;
                        });
                      },
                      onDeleteProduct: _onDeleteProduct,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right Area: Product Edit/Create Drawer (Slide-Over Panel)
          if (_isDrawerOpen)
            ProductFormDrawer(
              product: _selectedProduct,
              onSave: _onSaveProduct,
              onCancel: () => setState(() => _isDrawerOpen = false),
              onDelete: _onDeleteProduct,
            ),
        ],
      ),
    );
  }
}
