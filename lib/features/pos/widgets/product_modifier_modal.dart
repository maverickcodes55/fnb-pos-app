import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/pos_models.dart';

class ProductModifierModal extends ConsumerStatefulWidget {
  final ProductModel product;
  final Function(List<ModifierOption> modifiers, String? notes) onConfirm;

  const ProductModifierModal({
    super.key,
    required this.product,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required ProductModel product,
    required Function(List<ModifierOption> modifiers, String? notes) onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ProductModifierModal(
        product: product,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  ConsumerState<ProductModifierModal> createState() => _ProductModifierModalState();
}

class _ProductModifierModalState extends ConsumerState<ProductModifierModal> {
  final TextEditingController _notesController = TextEditingController();
  final Map<int, List<ModifierOption>> _selectedOptionsByGroup = {};
  List<ModifierGroup> _groups = [];
  Map<int, List<ModifierOption>> _optionsByGroup = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadModifierData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadModifierData() async {
    final db = ref.read(databaseProvider);
    final groups = await db.getProductModifierGroups(widget.product.id);
    final Map<int, List<ModifierOption>> optionsMap = {};

    for (final g in groups) {
      final opts = await db.getModifierOptions(g.id);
      optionsMap[g.id] = opts;

      // Auto-select first option if required and single select
      if (g.isRequired && opts.isNotEmpty) {
        _selectedOptionsByGroup[g.id] = [opts.first];
      } else {
        _selectedOptionsByGroup[g.id] = [];
      }
    }

    if (mounted) {
      setState(() {
        _groups = groups;
        _optionsByGroup = optionsMap;
        _isLoading = false;
      });
    }
  }

  void _toggleOption(ModifierGroup group, ModifierOption option) {
    setState(() {
      final currentList = _selectedOptionsByGroup[group.id] ?? [];

      if (group.maxSelect == 1) {
        // Radio behavior
        _selectedOptionsByGroup[group.id] = [option];
      } else {
        // Multi-select behavior
        if (currentList.any((o) => o.id == option.id)) {
          currentList.removeWhere((o) => o.id == option.id);
        } else {
          if (currentList.length < group.maxSelect) {
            currentList.add(option);
          }
        }
        _selectedOptionsByGroup[group.id] = currentList;
      }
    });
  }

  bool get _isSatisfied {
    for (final g in _groups) {
      if (g.isRequired) {
        final count = _selectedOptionsByGroup[g.id]?.length ?? 0;
        if (count < g.minSelect) return false;
      }
    }
    return true;
  }

  int get _calculatedPrice {
    int total = widget.product.price;
    for (final list in _selectedOptionsByGroup.values) {
      for (final opt in list) {
        total += opt.extraPrice;
      }
    }
    return total;
  }

  List<ModifierOption> get _allSelectedModifiers {
    final List<ModifierOption> result = [];
    for (final list in _selectedOptionsByGroup.values) {
      result.addAll(list);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 520,
        constraints: const BoxConstraints(maxHeight: 720),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x30000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Product Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.product.imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 56,
                        height: 56,
                        color: AppColors.surfaceContainerHigh,
                        child: const Icon(LucideIcons.utensils, size: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Harga Dasar: ${CurrencyFormatter.format(widget.product.price)} • Stok: ${widget.product.stock} pcs',
                          style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Modifier Groups List (Scrollable)
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _groups.isEmpty
                      ? const Center(child: Text('Menu ini tidak memiliki opsi modifikasi.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(18),
                          itemCount: _groups.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 18),
                          itemBuilder: (context, index) {
                            final group = _groups[index];
                            final options = _optionsByGroup[group.id] ?? [];
                            final selected = _selectedOptionsByGroup[group.id] ?? [];

                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        group.name,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: group.isRequired
                                              ? AppColors.tertiaryContainer.withValues(alpha: 0.2)
                                              : AppColors.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          group.isRequired ? 'WAJIB • PILIH 1' : 'OPSIONAL (MAKS ${group.maxSelect})',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: group.isRequired ? AppColors.tertiary : AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Options
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: options.map((opt) {
                                      final isOptSelected = selected.any((o) => o.id == opt.id);

                                      return ChoiceChip(
                                        label: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              opt.name,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: isOptSelected ? FontWeight.w700 : FontWeight.w500,
                                                color: isOptSelected ? AppColors.onPrimaryContainer : AppColors.onSurface,
                                              ),
                                            ),
                                            if (opt.extraPrice > 0) ...[
                                              const SizedBox(width: 4),
                                              Text(
                                                '+${CurrencyFormatter.format(opt.extraPrice)}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: isOptSelected ? AppColors.onPrimaryContainer : AppColors.primary,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        selected: isOptSelected,
                                        selectedColor: AppColors.primaryContainer,
                                        backgroundColor: AppColors.surfaceContainerLowest,
                                        onSelected: (_) => _toggleOption(group, opt),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),

            // Notes input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: 'Catatan koki / barista (cth: Less Ice, extra cup terpisah)...',
                  hintStyle: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  prefixIcon: const Icon(LucideIcons.messageSquare, size: 16),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),

            // Bottom CTA Confirmation Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL ITEM',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
                      ),
                      Text(
                        CurrencyFormatter.format(_calculatedPrice),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isSatisfied
                        ? () {
                            Navigator.pop(context);
                            widget.onConfirm(
                              _allSelectedModifiers,
                              _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                            );
                          }
                        : null,
                    icon: const Icon(LucideIcons.shoppingBag, size: 18),
                    label: const Text(
                      'Tambahkan ke Keranjang',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
