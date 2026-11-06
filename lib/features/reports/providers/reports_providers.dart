import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../orders/providers/orders_providers.dart';
import '../models/mock_reports_data.dart';
import '../models/report_models.dart';

final allOrderItemsStreamProvider = StreamProvider<List<OrderItem>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllOrderItems();
});

class ReportsSummary {
  final int totalGrossSales;
  final int completedOrdersCount;
  final int voidedOrdersCount;
  final int averageOrderValue;
  final int qrisCount;
  final int cashCount;
  final int debitCount;

  const ReportsSummary({
    required this.totalGrossSales,
    required this.completedOrdersCount,
    required this.voidedOrdersCount,
    required this.averageOrderValue,
    this.qrisCount = 0,
    this.cashCount = 0,
    this.debitCount = 0,
  });
}

final reportsTransactionsProvider = Provider<AsyncValue<List<TransactionRecord>>>((ref) {
  final ordersAsync = ref.watch(ordersStreamProvider);
  final itemsAsync = ref.watch(allOrderItemsStreamProvider);
  final tablesAsync = ref.watch(restaurantTablesStreamProvider);

  if (ordersAsync.isLoading || itemsAsync.isLoading || tablesAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (ordersAsync.hasError) {
    return AsyncValue.error(ordersAsync.error!, ordersAsync.stackTrace!);
  }

  final orders = ordersAsync.value ?? [];
  final items = itemsAsync.value ?? [];
  final tables = tablesAsync.value ?? [];

  if (orders.isEmpty) {
    return AsyncValue.data(initialMockTransactions);
  }

  final tableMap = {for (final t in tables) t.id: t.tableNumber};

  final records = orders.map((order) {
    final orderItems = items
        .where((i) => i.orderId == order.id)
        .map((i) => TransactionItem(
              productName: i.productName,
              quantity: i.quantity,
              price: i.priceAtSale,
              notes: i.notes,
            ))
        .toList();

    String customerOrTable;
    if (order.tableId != null && tableMap.containsKey(order.tableId)) {
      customerOrTable = '${tableMap[order.tableId]!} • Dine In';
    } else if (order.orderType == 'dine_in') {
      customerOrTable = 'Dine In • Meja Reguler';
    } else {
      customerOrTable = 'Takeaway • Pelanggan';
    }

    String paymentLabel;
    switch (order.paymentMethod.toLowerCase()) {
      case 'qris':
        paymentLabel = 'QRIS';
        break;
      case 'debit':
      case 'card':
        paymentLabel = 'Kartu';
        break;
      case 'cash':
      default:
        paymentLabel = 'Tunai';
        break;
    }

    return TransactionRecord(
      id: order.id,
      orderNumber: order.orderNumber,
      customerOrTable: customerOrTable,
      timestamp: order.createdAt,
      shift: 'Shift #1042',
      orderType: order.orderType == 'dine_in' ? 'Dine In' : 'Takeaway',
      paymentMethod: paymentLabel,
      subtotal: order.subtotal,
      discount: order.discountAmount,
      serviceFee: 0,
      tax: order.taxAmount,
      totalAmount: order.totalAmount,
      status: order.status == 'cancelled' ? TransactionStatus.voided : TransactionStatus.completed,
      referenceId: 'TXN-${order.id.toString().padLeft(6, '0')}',
      items: orderItems,
    );
  }).toList();

  return AsyncValue.data(records);
});

final reportsSummaryProvider = Provider<ReportsSummary>((ref) {
  final recordsAsync = ref.watch(reportsTransactionsProvider);
  final records = recordsAsync.value ?? initialMockTransactions;

  int gross = 0;
  int completed = 0;
  int voided = 0;
  int qris = 0;
  int cash = 0;
  int debit = 0;

  for (final r in records) {
    if (r.status == TransactionStatus.completed) {
      gross += r.totalAmount;
      completed++;
      if (r.paymentMethod == 'QRIS') {
        qris++;
      } else if (r.paymentMethod == 'Tunai') {
        cash++;
      } else {
        debit++;
      }
    } else {
      voided++;
    }
  }

  final aov = completed > 0 ? (gross / completed).round() : 0;

  return ReportsSummary(
    totalGrossSales: gross,
    completedOrdersCount: completed,
    voidedOrdersCount: voided,
    averageOrderValue: aov,
    qrisCount: qris,
    cashCount: cash,
    debitCount: debit,
  );
});
