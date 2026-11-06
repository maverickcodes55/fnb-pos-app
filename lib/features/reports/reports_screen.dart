import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'models/mock_reports_data.dart';
import 'models/report_models.dart';
import 'widgets/sales_kpi_cards.dart';
import 'widgets/thermal_receipt_card.dart';
import 'widgets/transaction_history_table.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/database/app_database.dart';
import 'models/report_models.dart';
import 'providers/reports_providers.dart';
import 'widgets/sales_kpi_cards.dart';
import 'widgets/thermal_receipt_card.dart';
import 'widgets/transaction_history_table.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int? _selectedTransactionId;
  String _searchQuery = '';
  String _selectedStatusFilter = 'all';

  void _onReprint(TransactionRecord record) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mencetak ulang struk ${record.orderNumber} ke printer thermal...'),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onVoidTransaction(TransactionRecord record) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Void Transaksi ${record.orderNumber}'),
          content: Text(
            'Apakah Anda yakin ingin membatalkan transaksi ${record.orderNumber} sebesar Rp ${record.totalAmount}? Aksi ini akan mengubah status di database dan dicatat dalam audit shift.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await ref.read(databaseProvider).updateOrderStatus(record.id, 'cancelled');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Transaksi ${record.orderNumber} berhasil dibatalkan (VOID).'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal membatalkan transaksi: $e'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: const Text('Ya, Void Transaksi'),
            ),
          ],
        );
      },
    );
  }

  void _onShareReceipt(TransactionRecord record) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tautan E-Receipt ${record.orderNumber} telah disalin ke clipboard.'),
        backgroundColor: AppColors.onSurface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(reportsTransactionsProvider);
    final summary = ref.watch(reportsSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top KPI Cards connected to live calculation
            SalesKpiCards(summary: summary),
            const SizedBox(height: 14),
            // Split Area: Table (~60%) and Digital Thermal Receipt (~40%)
            Expanded(
              child: transactionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error memuat data: $err')),
                data: (transactions) {
                  final filteredTransactions = transactions.where((t) {
                    final matchesSearch = _searchQuery.isEmpty ||
                        t.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        t.customerOrTable.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        t.referenceId.toLowerCase().contains(_searchQuery.toLowerCase());

                    bool matchesStatus = true;
                    if (_selectedStatusFilter == 'completed') {
                      matchesStatus = t.status == TransactionStatus.completed;
                    } else if (_selectedStatusFilter == 'voided') {
                      matchesStatus = t.status == TransactionStatus.voided;
                    }

                    return matchesSearch && matchesStatus;
                  }).toList();

                  // Select active transaction
                  TransactionRecord? selectedRecord;
                  if (filteredTransactions.isNotEmpty) {
                    selectedRecord = filteredTransactions.firstWhere(
                      (t) => t.id == _selectedTransactionId,
                      orElse: () => filteredTransactions.first,
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: TransactionHistoryTable(
                          transactions: filteredTransactions,
                          selectedTransaction: selectedRecord,
                          onSelectTransaction: (item) {
                            setState(() => _selectedTransactionId = item.id);
                          },
                          searchQuery: _searchQuery,
                          onSearchChanged: (val) => setState(() => _searchQuery = val),
                          selectedStatusFilter: _selectedStatusFilter,
                          onStatusFilterChanged: (val) => setState(() => _selectedStatusFilter = val),
                        ),
                      ),
                      const SizedBox(width: 14),
                      if (selectedRecord != null)
                        ThermalReceiptCard(
                          record: selectedRecord,
                          onReprint: () => _onReprint(selectedRecord!),
                          onVoidTransaction: () => _onVoidTransaction(selectedRecord!),
                          onShareReceipt: () => _onShareReceipt(selectedRecord!),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
