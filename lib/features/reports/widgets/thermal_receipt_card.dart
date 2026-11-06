import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/report_models.dart';

class ThermalReceiptCard extends StatelessWidget {
  final TransactionRecord record;
  final VoidCallback onReprint;
  final VoidCallback onVoidTransaction;
  final VoidCallback onShareReceipt;

  const ThermalReceiptCard({
    super.key,
    required this.record,
    required this.onReprint,
    required this.onVoidTransaction,
    required this.onShareReceipt,
  });

  @override
  Widget build(BuildContext context) {
    final isVoid = record.status == TransactionStatus.voided;

    return Container(
      width: 380,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Thermal Receipt Body (Scrollable)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                // Top Teeth Color Accent Bar
                Container(
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Store Header
                const Center(
                  child: Column(
                    children: [
                      Text(
                        'CULINARY COMMERCE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: AppColors.onSurface,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'ARTISAN CAFE & ROASTERY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Jl. Senopati No. 42, Kebayoran Baru, Jakarta Selatan',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                      Text(
                        'NPWP: 01.844.920.4-012.000',
                        style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _buildDashedDivider(),
                const SizedBox(height: 10),
                // Order Metadata
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('No: ${record.orderNumber}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    Text(record.customerOrTable, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kasir: Sarah K.', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                    Text(record.shift, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Tanggal: ${record.timestamp.day.toString().padLeft(2, '0')}/${record.timestamp.month.toString().padLeft(2, '0')}/${record.timestamp.year} ${record.timestamp.hour.toString().padLeft(2, '0')}:${record.timestamp.minute.toString().padLeft(2, '0')} WIB',
                  style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 10),
                _buildDashedDivider(),
                const SizedBox(height: 10),
                // Items List
                Column(
                  children: record.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  '${item.quantity}× ${item.productName}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(item.subtotal),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          if (item.notes != null && item.notes!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 14, top: 1),
                              child: Text(
                                '↳ ${item.notes}',
                                style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant, fontStyle: FontStyle.italic),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                _buildDashedDivider(),
                const SizedBox(height: 10),
                // Breakdown
                _buildBreakdownRow('Subtotal', CurrencyFormatter.format(record.subtotal)),
                if (record.discount > 0)
                  _buildBreakdownRow(
                    'Diskon Member VIP (10%)',
                    '-${CurrencyFormatter.format(record.discount)}',
                    textColor: AppColors.secondary,
                  ),
                if (record.serviceFee > 0)
                  _buildBreakdownRow('Biaya Layanan (5%)', CurrencyFormatter.format(record.serviceFee)),
                if (record.tax > 0)
                  _buildBreakdownRow('Pajak PB1 (11%)', CurrencyFormatter.format(record.tax)),
                const SizedBox(height: 10),
                _buildDashedDivider(),
                const SizedBox(height: 8),
                // Grand Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Dibayar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                    Text(
                      CurrencyFormatter.format(record.totalAmount),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isVoid ? AppColors.error : AppColors.primary,
                        decoration: isVoid ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Payment Verification Box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isVoid
                        ? AppColors.errorContainer.withValues(alpha: 0.3)
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Metode Bayar:', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                          Text(record.paymentMethod, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ID Referensi:', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                          Text(record.referenceId, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Status:', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                          Text(
                            isVoid ? 'Dibatalkan / Void' : 'Sukses / Lunas',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isVoid ? AppColors.error : AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Barcode simulation
                Center(
                  child: Column(
                    children: [
                      Icon(LucideIcons.scanLine, size: 36, color: AppColors.onSurface.withValues(alpha: 0.6)),
                      Text(
                        record.referenceId,
                        style: const TextStyle(fontSize: 10, letterSpacing: 1.5, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Receipt Actions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(LucideIcons.printer, size: 14),
                    label: const Text('Cetak Ulang', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.divider),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: onReprint,
                  ),
                ),
                const SizedBox(width: 6),
                if (!isVoid) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(LucideIcons.ban, size: 14),
                      label: const Text('Void / Batal', style: TextStyle(fontSize: 11)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.divider),
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: onVoidTransaction,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(LucideIcons.share2, size: 14),
                    label: const Text('E-Receipt', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(color: AppColors.divider),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: onShareReceipt,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedDivider() {
    return Row(
      children: List.generate(
        35,
        (index) => Expanded(
          child: Container(
            color: index % 2 == 0 ? Colors.transparent : AppColors.divider,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: textColor ?? AppColors.onSurfaceVariant),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor ?? AppColors.onSurface),
          ),
        ],
      ),
    );
  }
}
