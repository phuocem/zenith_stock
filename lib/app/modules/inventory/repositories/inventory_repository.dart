import '../providers/inventory_provider.dart';

class InventoryRepository {
  final InventoryProvider _provider;

  InventoryRepository(this._provider);

  Future<List<Map<String, dynamic>>> fetchCategories() async => await _provider.getCategories();
  
  Future<List<Map<String, dynamic>>> fetchUnits() async => await _provider.getUnits();
  
  Future<List<Map<String, dynamic>>> fetchProducts() async => await _provider.getProducts();

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
}
