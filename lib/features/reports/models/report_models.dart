enum TransactionStatus {
  completed('Selesai'),
  voided('Batal / Void');

  final String label;
  const TransactionStatus(this.label);
}

class TransactionItem {
  final String productName;
  final int quantity;
  final int price;
  final String? notes;

  const TransactionItem({
    required this.productName,
    required this.quantity,
    required this.price,
    this.notes,
  });

  int get subtotal => price * quantity;
}

class TransactionRecord {
  final int id;
  final String orderNumber;
  final String customerOrTable;
  final DateTime timestamp;
  final String shift;
  final String orderType; // 'Dine In', 'Takeaway', 'Pengantaran'
  final String paymentMethod; // 'QRIS', 'Tunai', 'Kartu'
  final int subtotal;
  final int discount;
  final int serviceFee;
  final int tax;
  final int totalAmount;
  TransactionStatus status;
  final String referenceId;
  final List<TransactionItem> items;

  TransactionRecord({
    required this.id,
    required this.orderNumber,
    required this.customerOrTable,
    required this.timestamp,
    required this.shift,
    required this.orderType,
    required this.paymentMethod,
    required this.subtotal,
    required this.discount,
    required this.serviceFee,
    required this.tax,
    required this.totalAmount,
    this.status = TransactionStatus.completed,
    required this.referenceId,
    required this.items,
  });
}
