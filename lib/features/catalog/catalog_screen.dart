import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'models/catalog_models.dart';
import 'models/mock_catalog_data.dart';
import 'widgets/catalog_filter_bar.dart';
import 'widgets/catalog_table.dart';
import 'widgets/product_form_drawer.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late List<CatalogProduct> _products;
  String _searchQuery = '';
  int _selectedCategoryId = 0;
  StockStatusFilter _selectedStockFilter = StockStatusFilter.all;

  CatalogProduct? _selectedProduct;
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _products = List.from(initialCatalogProducts);
    if (_products.isNotEmpty) {
      _selectedProduct = _products.first;
      _isDrawerOpen = true; // permanently open by default on landscape desktop
    }
  }

  List<CatalogProduct> get _filteredProducts {
    return _products.where((p) {
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
  }

  void _onSaveProduct(CatalogProduct product) {
    setState(() {
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        _selectedProduct = product;
      } else {
        _products.insert(0, product);
        _selectedProduct = product;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Menu "${product.name}" berhasil disimpan!'),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onToggleAvailability(CatalogProduct product, bool isAvailable) {
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
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _products.removeWhere((p) => p.id == product.id);
                  if (_selectedProduct?.id == product.id) {
                    _selectedProduct = _products.isNotEmpty ? _products.first : null;
                    _isDrawerOpen = _selectedProduct != null;
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Menu "${product.name}" telah dihapus.'),
                    backgroundColor: AppColors.onSurface,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
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
                    totalCount: _products.length,
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
                      products: _filteredProducts,
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
