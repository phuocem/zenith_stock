import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionProvider {
  final SupabaseClient _supabase = Supabase.instance.client;
  Future<List<Map<String, dynamic>>> getHistory({
    String? type,
    int? warehouseId,
    int limit = 50,
  }) async {
    var q = _supabase
        .from('transactions')
        .select(
          '*, profiles(full_name), warehouses!transactions_warehouse_id_fkey(name, code), transaction_items(quantity, products(name, sku))',
        );
    if (type != null) q = q.eq('type', type);
    if (warehouseId != null) q = q.eq('warehouse_id', warehouseId);
    return await q.order('created_at', ascending: false).limit(limit);
  }

  Future<List<Map<String, dynamic>>> getWarehouses() async {
    return await _supabase
        .from('warehouses')
        .select('id, code, name, location')
        .eq('is_active', true)
        .order('id');
  }

  Future<List<Map<String, dynamic>>> getProductsWithAvailableBatches({
    int? warehouseId,
  }) async {
    if (warehouseId != null) {
      final batchRes = await _supabase
          .from('batches')
          .select('product_id')
          .eq('warehouse_id', warehouseId)
          .gt('current_quantity', 0);
      final ids = (batchRes).map((b) => b['product_id'] as String).toList();
      if (ids.isEmpty) return [];
      return await _supabase
          .from('products')
          .select(
            'id, name, sku, current_stock, min_stock_level, units(name), categories(name)',
          )
          .inFilter('id', ids)
          .order('name');
    }
    return await _supabase
        .from('products')
        .select(
          'id, name, sku, current_stock, min_stock_level, units(name), categories(name)',
        )
        .gt('current_stock', 0)
        .order('name');
  }

  Future<List<Map<String, dynamic>>> getAvailableBatchesForProduct(
    String productId, {
    int? warehouseId,
  }) async {
    var q = _supabase
        .from('batches')
        .select(
          'id, batch_code, current_quantity, warehouse_id, warehouses(name, code)',
        )
        .eq('product_id', productId)
        .gt('current_quantity', 0);
    if (warehouseId != null) q = q.eq('warehouse_id', warehouseId);
    return await q.order('created_at');
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    return await _supabase
        .from('products')
        .select('id, name, sku, current_stock, units(name), categories(name)')
        .order('name');
  }

  Future<List<Map<String, dynamic>>> getBatchesForProduct(
    String productId, {
    int? warehouseId,
  }) async {
    var q = _supabase
        .from('batches')
        .select(
          'id, batch_code, current_quantity, warehouse_id, warehouses(name, code)',
        )
        .eq('product_id', productId);
    if (warehouseId != null) q = q.eq('warehouse_id', warehouseId);
    return await q.order('created_at');
  }

  Future<Map<String, dynamic>> insertTransaction(
    Map<String, dynamic> data,
  ) async {
    return await _supabase.from('transactions').insert(data).select().single();
  }

  Future<void> insertTransactionItems(List<Map<String, dynamic>> items) async {
    await _supabase.from('transaction_items').insert(items);
  }

  String get currentUserId => _supabase.auth.currentUser!.id;
}
