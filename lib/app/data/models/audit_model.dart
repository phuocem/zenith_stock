class InventoryAudit {
  final String id;
  final String? userId;
  final String? userFullName;
  final int? warehouseId;
  final String? warehouseName;
  final String productId;
  final String? productName;
  final String? productSku;
  final String batchId;
  final int systemQty;
  final int actualQty;
  final int variance;
  final String? adjustmentReason;
  final String status;
  final DateTime createdAt;

  const InventoryAudit({
    required this.id,
    this.userId,
    this.userFullName,
    this.warehouseId,
    this.warehouseName,
    required this.productId,
    this.productName,
    this.productSku,
    required this.batchId,
    required this.systemQty,
    required this.actualQty,
    required this.variance,
    this.adjustmentReason,
    this.status = 'COMPLETED',
    required this.createdAt,
  });

  factory InventoryAudit.fromJson(Map<String, dynamic> json) {
    return InventoryAudit(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      userFullName: (json['profiles'] as Map<String, dynamic>?)?['full_name'] as String?,
      warehouseId: json['warehouse_id'] as int?,
      warehouseName: (json['warehouses'] as Map<String, dynamic>?)?['name'] as String?,
      productId: json['product_id'] as String,
      productName: (json['products'] as Map<String, dynamic>?)?['name'] as String?,
      productSku: (json['products'] as Map<String, dynamic>?)?['sku'] as String?,
      batchId: json['batch_id'] as String,
      systemQty: (json['system_qty'] as num).toInt(),
      actualQty: (json['actual_qty'] as num).toInt(),
      variance: (json['variance'] as num?)?.toInt() ?? 0,
      adjustmentReason: json['adjustment_reason'] as String?,
      status: json['status'] as String? ?? 'COMPLETED',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  bool get isMatch => variance == 0;
  bool get hasExcess => variance > 0;
  bool get hasDeficit => variance < 0;
}
