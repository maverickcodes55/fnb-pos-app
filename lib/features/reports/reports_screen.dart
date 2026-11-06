import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'models/mock_reports_data.dart';
import 'models/report_models.dart';
import 'widgets/sales_kpi_cards.dart';
import 'widgets/thermal_receipt_card.dart';
import 'widgets/transaction_history_table.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late List<TransactionRecord> _transactions;
  TransactionRecord? _selectedTransaction;
  String _searchQuery = '';
  String _selectedStatusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _transactions = List.from(initialMockTransactions);
    if (_transactions.isNotEmpty) {
      _selectedTransaction = _transactions.first;
    }
  }

  List<TransactionRecord> get _filteredTransactions {
    return _transactions.where((t) {
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
  }

  void _onReprint(TransactionRecord record) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mencetak ulang struk ${record.orderNumber} ke printer kasir...'),
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
            'Apakah Anda yakin ingin membatalkan transaksi ${record.orderNumber} sebesar Rp ${record.totalAmount}? Aksi ini akan dicatat dalam audit shift.',
          ),
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
                  record.status = TransactionStatus.voided;
                  if (_selectedTransaction?.id == record.id) {
                    _selectedTransaction = record;
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Transaksi ${record.orderNumber} berhasil dibatalkan (VOID).'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top KPI Cards
            const SalesKpiCards(),
            const SizedBox(height: 14),
            // Split Area: Table (~60%) and Digital Thermal Receipt (~40%)
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: TransactionHistoryTable(
                      transactions: _filteredTransactions,
                      selectedTransaction: _selectedTransaction,
                      onSelectTransaction: (item) {
                        setState(() => _selectedTransaction = item);
                      },
                      searchQuery: _searchQuery,
                      onSearchChanged: (val) => setState(() => _searchQuery = val),
                      selectedStatusFilter: _selectedStatusFilter,
                      onStatusFilterChanged: (val) => setState(() => _selectedStatusFilter = val),
                    ),
                  ),
                  const SizedBox(width: 14),
                  if (_selectedTransaction != null)
                    ThermalReceiptCard(
                      record: _selectedTransaction!,
                      onReprint: () => _onReprint(_selectedTransaction!),
                      onVoidTransaction: () => _onVoidTransaction(_selectedTransaction!),
                      onShareReceipt: () => _onShareReceipt(_selectedTransaction!),
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
