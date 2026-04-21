import '../providers/inventory_provider.dart';
import '../../../data/models/product_model.dart';

class InventoryRepository {
  final InventoryProvider _provider;
  InventoryRepository(this._provider);

  Future<List<Category>> fetchCategories() async {
    final data = await _provider.getCategories();
    return data.map(Category.fromJson).toList();
  }

  Future<List<Unit>> fetchUnits() async {
    final data = await _provider.getUnits();
    return data.map(Unit.fromJson).toList();
  }

  Future<List<Warehouse>> fetchWarehouses() async {
    final data = await _provider.getWarehouses();
    return data.map(Warehouse.fromJson).toList();
  }

  Future<List<Product>> fetchProducts({String? search, int? categoryId}) async {
    final data = await _provider.getProducts(search: search, categoryId: categoryId);
    return data.map(Product.fromJson).toList();
  }

  Future<Product> fetchProductById(String id) async {
    final data = await _provider.getProductById(id);
    return Product.fromJson(data);
  }

  Future<List<Batch>> fetchBatchesForProduct(String productId) async {
    final data = await _provider.getBatchesForProduct(productId);
    return data.map(Batch.fromJson).toList();
  }

  Future<List<Batch>> fetchAvailableBatches(String productId) async {
    final data = await _provider.getAvailableBatches(productId);
    return data.map(Batch.fromJson).toList();
  }

  Future<void> addProductWithInitialStock({
    required String name,
    required String sku,
    required int categoryId,
    required int unitId,
    required int initialQuantity,
    String? description,
  }) async {
    final product = await _provider.insertProduct({
      'name': name,
      'sku': sku,
      'category_id': categoryId,
      'unit_id': unitId,
      'description': description,
    });

    if (initialQuantity > 0) {
      await _provider.insertBatch({
        'product_id': product['id'],
        'batch_code': 'INITIAL-${DateTime.now().millisecondsSinceEpoch}',
        'initial_quantity': initialQuantity,
        'current_quantity': initialQuantity,
        'cost_price': 0,
      });
    }
  }

  Future<void> deleteProduct(String id) async {
    await _provider.deleteProduct(id);
  }
}
