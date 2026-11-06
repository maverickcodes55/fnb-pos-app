import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/database/app_database.dart';
import 'models/mock_orders_data.dart';
import 'models/order_models.dart';
import 'providers/orders_providers.dart';
import 'widgets/order_queue_view.dart';
import 'widgets/table_grid_view.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  int _selectedTabIndex = 0; // 0: Tables, 1: Orders Queue

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
              onPressed: () async {
                final name = controller.text.trim();
                Navigator.pop(context);
                final db = ref.read(databaseProvider);
                await db.updateTableStatus(table.id, 'occupied');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${table.tableNumber} berhasil dibuka untuk ${name.isEmpty ? 'Tamu' : name}.'),
                      backgroundColor: AppColors.secondary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
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
            'Pelanggan di "${table.tableNumber}" akan diselesaikan dan status meja diperbarui di database.',
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
                final db = ref.read(databaseProvider);
                await db.updateTableStatus(table.id, 'available');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${table.tableNumber} sekarang tersedia.'),
                      backgroundColor: AppColors.onSurface,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
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
        content: Text('Nota untuk ${table.tableNumber} (${table.guestName ?? 'Tamu'}).'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onAdvanceOrderStatus(ActiveOrderModel order) async {
    final db = ref.read(databaseProvider);
    if (order.status == OrderQueueStatus.pending) {
      await db.updateOrderStatus(order.id, 'ready');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan ${order.orderNumber} telah Siap Disajikan!'),
            backgroundColor: AppColors.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else if (order.status == OrderQueueStatus.ready) {
      await db.updateOrderStatus(order.id, 'completed');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan ${order.orderNumber} telah Selesai diantar.'),
            backgroundColor: AppColors.onSurface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  List<TableModel> _mapTables(List<RestaurantTable> dbTables) {
    if (dbTables.isEmpty) return initialMockTables;
    return dbTables.map((t) {
      final isOcc = t.status == 'occupied';
      return TableModel(
        id: t.id,
        tableNumber: t.tableNumber,
        capacity: t.capacity,
        status: isOcc ? TableStatus.occupied : TableStatus.available,
        guestName: isOcc ? 'Pelanggan Meja' : null,
        activeOrderNumber: isOcc ? 'ORD-${t.id + 100}' : null,
        totalAmount: isOcc ? (t.id * 45000 + 50000) : null,
      );
    }).toList();
  }

  List<ActiveOrderModel> _mapOrders(List<Order> dbOrders) {
    if (dbOrders.isEmpty) return initialMockOrders;
    return dbOrders
        .where((o) => o.status == 'pending' || o.status == 'ready')
        .map((o) {
      return ActiveOrderModel(
        id: o.id,
        orderNumber: o.orderNumber,
        tableNumber: o.tableId != null ? 'Meja ${o.tableId}' : null,
        orderType: o.orderType == 'dine_in' ? 'Dine-In' : 'Takeaway',
        status: o.status == 'ready' ? OrderQueueStatus.ready : OrderQueueStatus.pending,
        createdAt: o.createdAt,
        totalAmount: o.totalAmount,
        items: const [
          ActiveOrderItem(productName: 'Pesanan Masuk POS', quantity: 1),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tablesAsync = ref.watch(restaurantTablesStreamProvider);
    final ordersAsync = ref.watch(ordersStreamProvider);

    final tables = tablesAsync.maybeWhen(
      data: (list) => _mapTables(list),
      orElse: () => initialMockTables,
    );

    final activeOrders = ordersAsync.maybeWhen(
      data: (list) => _mapOrders(list),
      orElse: () => initialMockOrders,
    );

    final occupiedCount = tables.where((t) => t.status == TableStatus.occupied).length;
    final availableCount = tables.where((t) => t.status == TableStatus.available).length;

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
                      label: '$occupiedCount Terisi',
                      color: AppColors.primary,
                      bgColor: AppColors.primaryContainer.withValues(alpha: 0.12),
                    ),
                    const SizedBox(width: 8),
                    _buildMetricChip(
                      icon: LucideIcons.sparkles,
                      label: '$availableCount Kosong',
                      color: AppColors.secondary,
                      bgColor: AppColors.secondaryContainer.withValues(alpha: 0.2),
                    ),
                    const SizedBox(width: 8),
                    _buildMetricChip(
                      icon: LucideIcons.chefHat,
                      label: '${activeOrders.length} Di Dapur',
                      color: AppColors.tertiary,
                      bgColor: AppColors.tertiaryContainer.withValues(alpha: 0.15),
                    ),
                  ],
                ),
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
                        label: 'Denah Meja (${tables.length})',
                      ),
                      const SizedBox(width: 4),
                      _buildTabBtn(
                        index: 1,
                        icon: LucideIcons.clipboardList,
                        label: 'Antrean Dapur (${activeOrders.length})',
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
                    tables: tables,
                    onOpenTable: _onOpenTable,
                    onClearTable: _onClearTable,
                    onViewOrder: _onViewOrder,
                  )
                : OrderQueueView(
                    orders: activeOrders,
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
