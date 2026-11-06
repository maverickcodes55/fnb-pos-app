import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/pos_models.dart';

class ReceiptPreviewDialog extends StatelessWidget {
  final String orderNumber;
  final String orderType;
  final String? tableNumber;
  final List<CartItemModel> items;
  final int subtotal;
  final int tax;
  final int discount;
  final int grandTotal;
  final String paymentMethod;
  final VoidCallback onClose;

  const ReceiptPreviewDialog({
    super.key,
    required this.orderNumber,
    required this.orderType,
    this.tableNumber,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.grandTotal,
    required this.paymentMethod,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 440,
        constraints: const BoxConstraints(maxHeight: 700),
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
            // Header bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.check, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pembayaran Berhasil!',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSecondaryContainer,
                          ),
                        ),
                        Text(
                          'Struk siap dicetak ke printer thermal',
                          style: TextStyle(fontSize: 11, color: AppColors.onSecondaryContainer),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18),
                    color: AppColors.onSecondaryContainer,
                    onPressed: () {
                      Navigator.pop(context);
                      onClose();
                    },
                  ),
                ],
              ),
            ),

            // Thermal Paper Content (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.divider),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Store Name & Info
                      const Text(
                        'ARTISAN COFFEE & EATERY',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Jl. Senopati No. 45, Kebayoran Baru, Jakarta',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant, fontFamily: 'monospace'),
                      ),
                      const Text(
                        'Telp: (021) 5892-0192 | NPWP: 94.829.102.4-012',
                        style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant, fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 12),
                      _buildDashedLine(),
                      const SizedBox(height: 8),

                      // Order Metadata
                      _buildMetaRow('No. Struk', orderNumber),
                      _buildMetaRow('Waktu', timeStr),
                      _buildMetaRow('Kasir', 'Kasir Utama #01'),
                      _buildMetaRow(
                        'Tipe / Meja',
                        tableNumber != null ? '$tableNumber ($orderType)' : orderType,
                      ),
                      _buildMetaRow('Metode', paymentMethod),
                      const SizedBox(height: 8),
                      _buildDashedLine(),
                      const SizedBox(height: 10),

                      // Items Table
                      ...items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.product.name,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ),
                                    Text(
                                      CurrencyFormatter.format(item.subtotal),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${item.quantity}x @${CurrencyFormatter.format(item.product.price)}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.onSurfaceVariant,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    if (item.notes != null && item.notes!.isNotEmpty)
                                      Text(
                                        '(${item.notes})',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontStyle: FontStyle.italic,
                                          color: AppColors.onSurfaceVariant,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          )),

                      const SizedBox(height: 4),
                      _buildDashedLine(),
                      const SizedBox(height: 8),

                      // Totals
                      _buildCalculationRow('Subtotal', CurrencyFormatter.format(subtotal)),
                      if (discount > 0)
                        _buildCalculationRow('Diskon', '-${CurrencyFormatter.format(discount)}',
                            color: AppColors.secondary),
                      _buildCalculationRow('PB1 (11%)', CurrencyFormatter.format(tax)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL AKHIR',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(grandTotal),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildDashedLine(),
                      const SizedBox(height: 12),

                      // Footer & Barcode simulator
                      const Icon(LucideIcons.scanLine, size: 36, color: AppColors.onSurfaceVariant),
                      const SizedBox(height: 4),
                      Text(
                        '* $orderNumber *',
                        style: const TextStyle(
                          fontSize: 11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Terima kasih atas kunjungan Anda!\nWiFi: ArtisanGuest | Pass: kopienak',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Actions Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(LucideIcons.printer, size: 16),
                      label: const Text('Cetak Ulang Struk'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Mengirim struk $orderNumber ke printer thermal EPSON TM-T82X...'),
                            backgroundColor: AppColors.secondary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(LucideIcons.checkCheck, size: 16),
                      label: const Text('Selesai / Menu Baru'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        onClose();
                      },
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

  Widget _buildDashedLine() {
    return Row(
      children: List.generate(
        35,
        (index) => Expanded(
          child: Container(
            color: index % 2 == 0 ? Colors.transparent : AppColors.divider,
            height: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant, fontFamily: 'monospace'),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.onSurfaceVariant),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              color: color ?? AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

