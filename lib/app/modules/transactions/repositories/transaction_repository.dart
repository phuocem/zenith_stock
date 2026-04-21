import '../providers/transaction_provider.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/product_model.dart';

class TransactionRepository {
  final TransactionProvider _provider;
  TransactionRepository(this._provider);
  Future<List<Transaction>> fetchHistory({
    String? type,
    int? warehouseId,
    int limit = 50,
  }) async {
    final data = await _provider.getHistory(
      type: type,
      warehouseId: warehouseId,
      limit: limit,
    );
    return data.map(Transaction.fromJson).toList();
  }

  Future<List<Warehouse>> fetchWarehouses() async {
    final data = await _provider.getWarehouses();
    return data.map(Warehouse.fromJson).toList();
  }

  Future<List<Product>> fetchProductsWithAvailableBatches({
    int? warehouseId,
  }) async {
    final data = await _provider.getProductsWithAvailableBatches(
      warehouseId: warehouseId,
    );
    return data.map(Product.fromJson).toList();
  }

  Future<List<Product>> fetchAllProducts() async {
    final data = await _provider.getAllProducts();
    return data.map(Product.fromJson).toList();
  }

  Future<List<Batch>> fetchAvailableBatches(
    String productId, {
    int? warehouseId,
  }) async {
    final data = await _provider.getAvailableBatchesForProduct(
      productId,
      warehouseId: warehouseId,
    );
    return data.map(Batch.fromJson).toList();
  }

  Future<List<Batch>> fetchAllBatches(
    String productId, {
    int? warehouseId,
  }) async {
    final data = await _provider.getBatchesForProduct(
      productId,
      warehouseId: warehouseId,
    );
    return data.map(Batch.fromJson).toList();
  }

  Future<void> submitTransaction({
    required String type,
    required int warehouseId,
    String? notes,
    String? referenceNumber,
    required List<TransactionItemDraft> items,
  }) async {
    final transRes = await _provider.insertTransaction({
      'type': type,
      'user_id': _provider.currentUserId,
      'warehouse_id': warehouseId,
      'notes': notes,
      'reference_number': referenceNumber,
    });
    final transId = transRes['id'];
    final itemsJson = items
        .map((item) => {'transaction_id': transId, ...item.toApiJson()})
        .toList();
    await _provider.insertTransactionItems(itemsJson);
  }
}
