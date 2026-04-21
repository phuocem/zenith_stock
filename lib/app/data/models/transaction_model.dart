import 'product_model.dart';

class Transaction {
  final String id;
  final String type;
  final String? userId;
  final String? userFullName;
  final int? warehouseId;
  final String? warehouseName;
  final String? notes;
  final String? referenceNumber;
  final List<TransactionItem> items;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.type,
    this.userId,
    this.userFullName,
    this.warehouseId,
    this.warehouseName,
    this.notes,
    this.referenceNumber,
    this.items = const [],
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final rawItems = json['transaction_items'] as List<dynamic>? ?? [];
    return Transaction(
      id: json['id'] as String,
      type: json['type'] as String,
      userId: json['user_id'] as String?,
      userFullName: (json['profiles'] as Map<String, dynamic>?)?['full_name'] as String?,
      warehouseId: json['warehouse_id'] as int?,
      warehouseName: (json['warehouses'] as Map<String, dynamic>?)?['name'] as String?,
      notes: json['notes'] as String?,
      referenceNumber: json['reference_number'] as String?,
      items: rawItems.map((i) => TransactionItem.fromJson(i as Map<String, dynamic>)).toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  bool get isInbound => type == 'IN';
  bool get isOutbound => type == 'OUT';
  bool get isAdjust => type == 'ADJUST';

  int get totalQuantity => items.fold(0, (sum, i) => sum + i.quantity.abs());
}

class TransactionItem {
  final String id;
  final String transactionId;
  final String productId;
  final String? productName;
  final String? productSku;
  final String batchId;
  final int quantity;
  final double? unitPrice;

  const TransactionItem({
    required this.id,
    required this.transactionId,
    required this.productId,
    this.productName,
    this.productSku,
    required this.batchId,
    required this.quantity,
    this.unitPrice,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'] as String,
      transactionId: json['transaction_id'] as String,
      productId: json['product_id'] as String,
      productName: (json['products'] as Map<String, dynamic>?)?['name'] as String?,
      productSku: (json['products'] as Map<String, dynamic>?)?['sku'] as String?,
      batchId: json['batch_id'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unit_price'] as num?)?.toDouble(),
    );
  }
}

class TransactionItemDraft {
  final Product product;
  final Batch batch;
  int quantity;

  TransactionItemDraft({
    required this.product,
    required this.batch,
    required this.quantity,
  });

  Map<String, dynamic> toApiJson() => {
    'product_id': product.id,
    'batch_id': batch.id,
    'quantity': quantity,
    'unit_price': 0,
  };
}
