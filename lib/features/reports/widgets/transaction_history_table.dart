import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/report_models.dart';

class TransactionHistoryTable extends StatelessWidget {
  final List<TransactionRecord> transactions;
  final TransactionRecord? selectedTransaction;
  final ValueChanged<TransactionRecord> onSelectTransaction;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final String selectedStatusFilter; // 'all', 'completed', 'voided'
  final ValueChanged<String> onStatusFilterChanged;

  const TransactionHistoryTable({
    super.key,
    required this.transactions,
    required this.selectedTransaction,
    required this.onSelectTransaction,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedStatusFilter,
    required this.onStatusFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Filter & Search Controls Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                // Search Input
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(LucideIcons.search, size: 16, color: AppColors.onSurfaceVariant),
                        ),
                        Expanded(
                          child: TextField(
                            onChanged: onSearchChanged,
                            decoration: const InputDecoration(
                              hintText: 'Cari ID Pesanan atau Tamu...',
                              hintStyle: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Status Filter Tabs
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFilterChip('all', 'Semua (${transactions.length})'),
                    const SizedBox(width: 4),
                    _buildFilterChip(
                      'completed',
                      'Selesai (${transactions.where((t) => t.status == TransactionStatus.completed).length})',
                    ),
                    const SizedBox(width: 4),
                    _buildFilterChip(
                      'voided',
                      'Batal (${transactions.where((t) => t.status == TransactionStatus.voided).length})',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Table Headers
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'ID & TAMU',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'WAKTU & SHIFT',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'TIPE',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'METODE',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'TOTAL',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    'STATUS',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          // Transactions List
          Expanded(
            child: transactions.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada riwayat transaksi yang cocok.',
                      style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                    ),
                  )
                : ListView.separated(
                    itemCount: transactions.length,
                    separatorBuilder: (_, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = transactions[index];
                      final isSelected = selectedTransaction?.id == item.id;
                      final isVoid = item.status == TransactionStatus.voided;

                      return InkWell(
                        onTap: () => onSelectTransaction(item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryFixed.withValues(alpha: 0.25)
                                : isVoid
                                    ? AppColors.errorContainer.withValues(alpha: 0.15)
                                    : Colors.transparent,
                            border: isSelected
                                ? const Border(
                                    left: BorderSide(color: AppColors.primary, width: 3),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              // ID & Guest
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.orderNumber,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isVoid ? AppColors.error : AppColors.onSurface,
                                      ),
                                    ),
                                    Text(
                                      item.customerOrTable,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              // Waktu & Shift
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      item.shift,
                                      style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              // Tipe
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.orderType,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                              // Metode
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      item.paymentMethod == 'QRIS'
                                          ? LucideIcons.qrCode
                                          : item.paymentMethod == 'Tunai'
                                              ? LucideIcons.banknote
                                              : LucideIcons.creditCard,
                                      size: 13,
                                      color: item.paymentMethod == 'QRIS'
                                          ? AppColors.primaryContainer
                                          : item.paymentMethod == 'Tunai'
                                              ? AppColors.secondary
                                              : AppColors.onSurface,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      item.paymentMethod,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              // Total
                              Expanded(
                                flex: 2,
                                child: Text(
                                  CurrencyFormatter.format(item.totalAmount),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isVoid ? AppColors.error : AppColors.onSurface,
                                    decoration: isVoid ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ),
                              // Status
                              SizedBox(
                                width: 70,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isVoid
                                          ? AppColors.errorContainer
                                          : AppColors.secondaryContainer,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      item.status.label,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: isVoid
                                            ? AppColors.onErrorContainer
                                            : AppColors.onSecondaryContainer,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = selectedStatusFilter == value;
    return InkWell(
      onTap: () => onStatusFilterChanged(value),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: isSelected ? AppColors.primaryContainer : AppColors.divider),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

