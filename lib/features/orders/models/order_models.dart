enum TableStatus {
  available('Tersedia'),
  occupied('Terisi');

  final String label;
  const TableStatus(this.label);
}

enum OrderQueueStatus {
  pending('Memasak'),
  ready('Siap Saji'),
  completed('Selesai');

  final String label;
  const OrderQueueStatus(this.label);
}

class TableModel {
  final int id;
  final String tableNumber;
  final int capacity;
  TableStatus status;
  String? guestName;
  String? activeOrderNumber;
  int? totalAmount;
  DateTime? occupiedSince;

  TableModel({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.status,
    this.guestName,
    this.activeOrderNumber,
    this.totalAmount,
    this.occupiedSince,
  });
}

class ActiveOrderItem {
  final String productName;
  final int quantity;
  final String? notes;

  const ActiveOrderItem({
    required this.productName,
    required this.quantity,
    this.notes,
  });
}

class ActiveOrderModel {
  final int id;
  final String orderNumber;
  final String? tableNumber;
  final String orderType;
  OrderQueueStatus status;
  final List<ActiveOrderItem> items;
  final int totalAmount;
  final DateTime createdAt;

  ActiveOrderModel({
    required this.id,
    required this.orderNumber,
    this.tableNumber,
    required this.orderType,
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
  });
}

