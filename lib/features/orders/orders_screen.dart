import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import 'models/mock_orders_data.dart';
import 'models/order_models.dart';
import 'widgets/order_queue_view.dart';
import 'widgets/table_grid_view.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _selectedTabIndex = 0; // 0: Tables, 1: Orders Queue
  late List<TableModel> _tables;
  late List<ActiveOrderModel> _activeOrders;

  @override
  void initState() {
    super.initState();
    _tables = List.from(initialMockTables);
    _activeOrders = List.from(initialMockOrders);
  }

  int get _occupiedCount =>
      _tables.where((t) => t.status == TableStatus.occupied).length;
  int get _availableCount =>
      _tables.where((t) => t.status == TableStatus.available).length;

  void _onOpenTable(TableModel table) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Buka ${table.tableNumber}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Kapasitas maksimal: ${table.capacity} orang'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nama Tamu / Pelanggan',
                  hintText: 'Misal: Budi (2 org)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                final name = controller.text.trim();
                Navigator.pop(context);
                setState(() {
                  table.status = TableStatus.occupied;
                  table.guestName = name.isEmpty ? 'Tamu Baru' : name;
                  table.activeOrderNumber = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
                  table.totalAmount = 0;
                  table.occupiedSince = DateTime.now();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${table.tableNumber} berhasil dibuka untuk ${table.guestName}.'),
                    backgroundColor: AppColors.secondary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Buka Meja'),
            ),
          ],
        );
      },
    );
  }

  void _onClearTable(TableModel table) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Kosongkan ${table.tableNumber}?'),
          content: Text(
            'Pelanggan "${table.guestName ?? 'Tamu'}" akan diselesaikan dan meja siap digunakan kembali.',
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
                  table.status = TableStatus.available;
                  table.guestName = null;
                  table.activeOrderNumber = null;
                  table.totalAmount = null;
                  table.occupiedSince = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${table.tableNumber} sekarang tersedia.'),
                    backgroundColor: AppColors.onSurface,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Kosongkan'),
            ),
          ],
        );
      },
    );
  }

  void _onViewOrder(TableModel table) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nota ${table.activeOrderNumber} untuk ${table.tableNumber} (${table.guestName}).'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onAdvanceOrderStatus(ActiveOrderModel order) {
    setState(() {
      if (order.status == OrderQueueStatus.pending) {
        order.status = OrderQueueStatus.ready;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan ${order.orderNumber} telah Siap Disajikan!'),
            backgroundColor: AppColors.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (order.status == OrderQueueStatus.ready) {
        order.status = OrderQueueStatus.completed;
        _activeOrders.removeWhere((o) => o.id == order.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan ${order.orderNumber} telah Selesai diantar.'),
            backgroundColor: AppColors.onSurface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Top Header Summary Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title and Metric Chips
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Operasional Meja & Antrean',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildMetricChip(
                      icon: LucideIcons.armchair,
                      label: '$_occupiedCount Terisi',
                      color: AppColors.primary,
                      bgColor: AppColors.primaryContainer.withValues(alpha: 0.12),
                    ),
                    const SizedBox(width: 8),
                    _buildMetricChip(
                      icon: LucideIcons.sparkles,
                      label: '$_availableCount Kosong',
                      color: AppColors.secondary,
                      bgColor: AppColors.secondaryContainer.withValues(alpha: 0.2),
                    ),
                    const SizedBox(width: 8),
                    _buildMetricChip(
                      icon: LucideIcons.chefHat,
                      label: '${_activeOrders.length} Di Dapur',
                      color: AppColors.tertiary,
                      bgColor: AppColors.tertiaryContainer.withValues(alpha: 0.15),
                    ),
                  ],
                ),
                // Tab Mode Selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTabBtn(
                        index: 0,
                        icon: LucideIcons.layoutGrid,
                        label: 'Denah Meja (${_tables.length})',
                      ),
                      const SizedBox(width: 4),
                      _buildTabBtn(
                        index: 1,
                        icon: LucideIcons.clipboardList,
                        label: 'Antrean Dapur (${_activeOrders.length})',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // View Content
          Expanded(
            child: _selectedTabIndex == 0
                ? TableGridView(
                    tables: _tables,
                    onOpenTable: _onOpenTable,
                    onClearTable: _onClearTable,
                    onViewOrder: _onViewOrder,
                  )
                : OrderQueueView(
                    orders: _activeOrders,
                    onAdvanceStatus: _onAdvanceOrderStatus,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBtn({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceContainerLowest : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
