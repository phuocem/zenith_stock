import '../providers/audit_provider.dart';
import '../../../data/models/audit_model.dart';
import '../../../data/models/product_model.dart';

class AuditRepository {
  final AuditProvider _provider;
  AuditRepository(this._provider);
  Future<List<InventoryAudit>> fetchAudits({String? productId}) async {
    final data = await _provider.getAudits(productId: productId);
    return data.map(InventoryAudit.fromJson).toList();
  }

  Future<List<Warehouse>> fetchWarehouses() async {
    final data = await _provider.getWarehouses();
    return data.map(Warehouse.fromJson).toList();
  }

  Future<List<Product>> fetchAllProducts() async {
    final data = await _provider.getAllProducts();
    return data.map(Product.fromJson).toList();
  }

  Future<List<Batch>> fetchBatchesForProduct(String productId) async {
    final data = await _provider.getBatchesForProduct(productId);
    return data.map(Batch.fromJson).toList();
  }

  Future<void> submitAudit({
    required int warehouseId,
    required String productId,
    required String batchId,
    required int systemQty,
    required int actualQty,
    String? reason,
  }) async {
    await _provider.insertAudit({
      'user_id': _provider.currentUserId,
      'warehouse_id': warehouseId,
      'product_id': productId,
      'batch_id': batchId,
      'system_qty': systemQty,
      'actual_qty': actualQty,
      'adjustment_reason': reason,
      'status': 'COMPLETED',
    });
  }
}
