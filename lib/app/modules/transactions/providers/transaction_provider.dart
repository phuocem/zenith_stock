import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionProvider {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getHistory({String? type, int limit = 50}) async {
    var baseQuery = _supabase
        .from('transactions')
        .select('*, profiles(full_name), warehouses!transactions_warehouse_id_fkey(name), transaction_items(quantity, products(name, sku))');
    if (type != null) {
      baseQuery = baseQuery.eq('type', type);
    }
    return await baseQuery.order('created_at', ascending: false).limit(limit);
  }

  Future<List<Map<String, dynamic>>> getWarehouses() async {
    return await _supabase.from('warehouses').select('*').order('id');
  }

  Future<List<Map<String, dynamic>>> getProductsWithAvailableBatches() async {
    return await _supabase
        .from('products')
        .select('id, name, sku, current_stock, min_stock_level, units(name), categories(name)')
        .gt('current_stock', 0)
        .order('name');
  }

  Future<List<Map<String, dynamic>>> getAvailableBatchesForProduct(String productId) async {
    return await _supabase
        .from('batches')
        .select('id, batch_code, current_quantity, warehouses(name)')
        .eq('product_id', productId)
        .gt('current_quantity', 0)
        .order('created_at');
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    return await _supabase
        .from('products')
        .select('id, name, sku, current_stock, units(name), categories(name)')
        .order('name');
  }

  Future<List<Map<String, dynamic>>> getBatchesForProduct(String productId) async {
    return await _supabase
        .from('batches')
        .select('id, batch_code, current_quantity, warehouses(name)')
        .eq('product_id', productId)
        .order('created_at');
  }

  Future<Map<String, dynamic>> insertTransaction(Map<String, dynamic> data) async {
    return await _supabase.from('transactions').insert(data).select().single();
  }

  Future<void> insertTransactionItems(List<Map<String, dynamic>> items) async {
    await _supabase.from('transaction_items').insert(items);
  }

  String get currentUserId => _supabase.auth.currentUser!.id;
}
