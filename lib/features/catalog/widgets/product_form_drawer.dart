import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../models/catalog_models.dart';

class ProductFormDrawer extends StatefulWidget {
  final CatalogProduct? product;
  final ValueChanged<CatalogProduct> onSave;
  final VoidCallback onCancel;
  final ValueChanged<CatalogProduct>? onDelete;

  const ProductFormDrawer({
    super.key,
    required this.product,
    required this.onSave,
    required this.onCancel,
    this.onDelete,
  });

  @override
  State<ProductFormDrawer> createState() => _ProductFormDrawerState();
}

class _ProductFormDrawerState extends State<ProductFormDrawer> {
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _priceController;
  late TextEditingController _costPriceController;
  late TextEditingController _minStockController;
  late int _stock;
  late bool _isAvailable;
  late int _selectedCategoryId;
  late String _selectedCategoryName;
  late String _imageUrl;

  final Map<int, String> _categories = {
    1: 'Kopi Spesialti',
    2: 'Pastry & Roti Artisan',
    3: 'Menu Utama',
    4: 'Minuman Dingin',
    5: 'Pencuci Mulut',
  };

  @override
  void initState({Key? key}) {
    super.initState();
    _populateFields();
  }

  @override
  void didUpdateWidget(ProductFormDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product != widget.product) {
      _populateFields();
    }
  }

  void _populateFields() {
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _skuController = TextEditingController(text: p?.sku ?? 'SKU-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}');
    _priceController = TextEditingController(text: p != null ? '${p.price}' : '35000');
    _costPriceController = TextEditingController(text: p != null ? '${p.costPrice}' : '15000');
    _minStockController = TextEditingController(text: p != null ? '${p.minStockAlert}' : '5');
    _stock = p?.stock ?? 10;
    _isAvailable = p?.isAvailable ?? true;
    _selectedCategoryId = p?.categoryId ?? 1;
    _selectedCategoryName = p?.categoryName ?? _categories[_selectedCategoryId]!;
    _imageUrl = p?.imageUrl ?? 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400&q=80';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama menu wajib diisi!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final price = int.tryParse(_priceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final costPrice = int.tryParse(_costPriceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final minStock = int.tryParse(_minStockController.text) ?? 5;

    final result = CatalogProduct(
      id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch,
      name: name,
      sku: _skuController.text.trim(),
      categoryId: _selectedCategoryId,
      categoryName: _categories[_selectedCategoryId] ?? 'Umum',
      price: price,
      costPrice: costPrice,
      stock: _stock,
      minStockAlert: minStock,
      isAvailable: _isAvailable,
      imageUrl: _imageUrl,
    );

    widget.onSave(result);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Container(
      width: 400,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(left: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEditing ? 'Ubah Data Menu' : 'Tambah Menu Baru',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _isAvailable
                            ? AppColors.secondaryContainer
                            : AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _isAvailable ? 'Aktif di Katalog' : 'Nonaktif',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _isAvailable
                              ? AppColors.onSecondaryContainer
                              : AppColors.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 18),
                  onPressed: widget.onCancel,
                ),
              ],
            ),
          ),
          // Form Fields (Scrollable)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Image Box
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        _imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.surfaceContainerHigh,
                          child: const Center(
                            child: Icon(LucideIcons.image, size: 36, color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(LucideIcons.camera, size: 14),
                            label: const Text('Ganti Foto', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.onSurface,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                            onPressed: () {
                              // Quick mock image switcher
                              setState(() {
                                _imageUrl = _imageUrl.contains('555507036')
                                    ? 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=400&q=80'
                                    : 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400&q=80';
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Nama Menu
                const Text(
                  'Nama Menu *',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Misal: Kopi Susu Aren',
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 14),
                // SKU & Kategori
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kode SKU',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _skuController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.surfaceContainerLow,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kategori',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _selectedCategoryId,
                                isExpanded: true,
                                icon: const Icon(LucideIcons.chevronDown, size: 14),
                                items: _categories.entries.map((e) {
                                  return DropdownMenuItem<int>(
                                    value: e.key,
                                    child: Text(
                                      e.value,
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedCategoryId = val;
                                      _selectedCategoryName = _categories[val]!;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Harga Jual & HPP
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Harga Jual (Rp)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixText: 'Rp ',
                              filled: true,
                              fillColor: AppColors.surfaceContainerLow,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HPP / Modal (Rp)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _costPriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixText: 'Rp ',
                              filled: true,
                              fillColor: AppColors.surfaceContainerLow,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Stok Stepper Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stok Inventaris Saat Ini',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                'Satuan: pieces (pcs)',
                                style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(LucideIcons.minus, size: 14),
                                  onPressed: () {
                                    if (_stock > 0) setState(() => _stock--);
                                  },
                                ),
                                SizedBox(
                                  width: 32,
                                  child: Text(
                                    '$_stock',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.plus, size: 14),
                                  onPressed: () {
                                    setState(() => _stock++);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Peringatan Stok Minimum',
                            style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                          ),
                          SizedBox(
                            width: 60,
                            height: 32,
                            child: TextField(
                              controller: _minStockController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.surfaceContainerLowest,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Aktif Switch
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ketersediaan Menu',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Tampilkan di layar kasir POS',
                            style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isAvailable,
                        activeColor: AppColors.secondary,
                        onChanged: (val) => setState(() => _isAvailable = val),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Footer Actions
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                if (isEditing && widget.onDelete != null)
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.error),
                    tooltip: 'Hapus Menu',
                    onPressed: () => widget.onDelete!(widget.product!),
                  ),
                const Spacer(),
                OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(LucideIcons.check, size: 16),
                  label: const Text('Simpan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
