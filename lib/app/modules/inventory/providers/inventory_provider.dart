import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryProvider {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getCategories() async {
    return await _supabase.from('categories').select('*').order('name');
  }

  Future<List<Map<String, dynamic>>> getUnits() async {
    return await _supabase.from('units').select('*').order('id');
  }

  Future<List<Map<String, dynamic>>> getWarehouses() async {
    return await _supabase.from('warehouses').select('*').order('id');
  }

  Future<List<Map<String, dynamic>>> getProducts({String? search, int? categoryId}) async {
    var baseQuery = _supabase
        .from('products')
        .select('*, categories(name), units(name)');

    if (categoryId != null && categoryId != 0) {
      baseQuery = baseQuery.eq('category_id', categoryId);
    }

    final result = await baseQuery.order('name');

    if (search != null && search.isNotEmpty) {
      final lower = search.toLowerCase();
      return result
          .where((p) =>
              (p['name'] as String? ?? '').toLowerCase().contains(lower) ||
              (p['sku'] as String? ?? '').toLowerCase().contains(lower))
          .toList();
    }
    return result;
  }

  Future<Map<String, dynamic>> getProductById(String id) async {
    return await _supabase
        .from('products')
        .select('*, categories(name), units(name)')
        .eq('id', id)
        .single();
  }

  Future<List<Map<String, dynamic>>> getBatchesForProduct(String productId) async {
    return await _supabase
        .from('batches')
        .select('*, warehouses(name)')
        .eq('product_id', productId)
        .order('created_at', ascending: false);
  }

  Future<List<Map<String, dynamic>>> getAvailableBatches(String productId) async {
    return await _supabase
        .from('batches')
        .select('*, warehouses(name)')
        .eq('product_id', productId)
        .gt('current_quantity', 0)
        .order('created_at', ascending: false);
  }

  Future<Map<String, dynamic>> insertProduct(Map<String, dynamic> data) async {
    return await _supabase.from('products').insert(data).select().single();
  }

  Future<Map<String, dynamic>> updateProduct(String id, Map<String, dynamic> data) async {
    return await _supabase.from('products').update(data).eq('id', id).select().single();
  }

  Future<void> deleteProduct(String id) async {
    await _supabase.from('products').delete().eq('id', id);
  }

  Future<void> insertBatch(Map<String, dynamic> data) async {
    await _supabase.from('batches').insert(data);
  }

  String get currentUserId => _supabase.auth.currentUser!.id;
}
