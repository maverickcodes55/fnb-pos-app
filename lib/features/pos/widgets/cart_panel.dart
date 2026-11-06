import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/pos_models.dart';

class CartPanel extends StatelessWidget {
  final List<CartItemModel> cartItems;
  final VoidCallback onClearCart;
  final Function(CartItemModel, int) onUpdateQuantity;
  final Function(CartItemModel, String) onUpdateNotes;
  final VoidCallback onCheckout;

  const CartPanel({
    super.key,
    required this.cartItems,
    required this.onClearCart,
    required this.onUpdateQuantity,
    required this.onUpdateNotes,
    required this.onCheckout,
  });

  int get subtotal =>
      cartItems.fold(0, (sum, item) => sum + item.subtotal);
  int get discount => (subtotal * 0.10).round(); // 10% VIP Discount
  int get serviceFee => ((subtotal - discount) * 0.05).round(); // 5% Service
  int get tax => (((subtotal - discount) + serviceFee) * 0.11).round(); // 11% PB1
  int get grandTotal => (subtotal - discount) + serviceFee + tax;

  void _showNotesDialog(BuildContext context, CartItemModel item) {
    final controller = TextEditingController(text: item.notes ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Catatan: ${item.product.name}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Misal: Sedikit gula, extra saus...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () {
                onUpdateNotes(item, controller.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          left: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              border: Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Flexible(
                            child: Text(
                              'Pesanan #ORD-204',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 2.5,
                                  backgroundColor: AppColors.secondary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'MEJA 08',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (cartItems.isNotEmpty)
                      InkWell(
                        onTap: onClearCart,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.errorContainer.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.trash2,
                                size: 12,
                                color: AppColors.onErrorContainer,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Hapus',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onErrorContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Kasir: Sarah K.',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Shift #1 • 14:28 WIB',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Cart Line Items List
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.shoppingBag,
                          size: 44,
                          color: AppColors.onSurfaceVariant,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Keranjang Masih Kosong',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Pilih menu di sisi kiri untuk mulai memesan',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];

                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    item.product.imageUrl,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 48,
                                      height: 48,
                                      color: AppColors.surfaceContainerHigh,
                                      child: const Icon(
                                        LucideIcons.utensils,
                                        size: 18,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.product.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.onSurface,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            CurrencyFormatter.format(
                                                item.subtotal),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (item.notes != null &&
                                          item.notes!.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          item.notes!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.onSurfaceVariant,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 2),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          InkWell(
                                            onTap: () =>
                                                _showNotesDialog(context, item),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  LucideIcons.fileEdit,
                                                  size: 11,
                                                  color: AppColors.primary,
                                                ),
                                                SizedBox(width: 3),
                                                Text(
                                                  'Ubah Catatan',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '@ ${CurrencyFormatter.format(item.product.price)}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Stepper Row
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'JUMLAH',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () => onUpdateQuantity(
                                          item,
                                          item.quantity - 1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        child: Container(
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            color: item.quantity == 1
                                                ? AppColors.errorContainer
                                                : AppColors.surfaceContainerLowest,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Icon(
                                            item.quantity == 1
                                                ? LucideIcons.trash2
                                                : LucideIcons.minus,
                                            size: 12,
                                            color: item.quantity == 1
                                                ? AppColors.onErrorContainer
                                                : AppColors.onSurface,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 28,
                                        child: Text(
                                          '${item.quantity}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => onUpdateQuantity(
                                          item,
                                          item.quantity + 1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        child: Container(
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Icon(
                                            LucideIcons.plus,
                                            size: 12,
                                            color: AppColors.onPrimaryContainer,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          // Bottom Price Calculation & Checkout Button
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 6,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Promo Row
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.tag, size: 14, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text(
                            'Diskon VIP Member (10%)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        LucideIcons.checkCircle2,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Breakdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Subtotal (${cartItems.fold(0, (s, i) => s + i.quantity)} item)',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(subtotal),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        'Diskon (10% VIP)',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    Text(
                      '-${CurrencyFormatter.format(discount)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        'Biaya Layanan (5%)',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(serviceFee),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        'Pajak Restoran PB1 (11%)',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(tax),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Divider(),
                ),
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      'TOTAL BAYAR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(grandTotal),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Big CTA Pay Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    onPressed: cartItems.isEmpty ? null : onCheckout,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.zap, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Bayar [F12]',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          CurrencyFormatter.format(grandTotal),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
