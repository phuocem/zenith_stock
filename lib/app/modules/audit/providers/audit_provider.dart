import 'package:supabase_flutter/supabase_flutter.dart';

class AuditProvider {
  final SupabaseClient _supabase = Supabase.instance.client;
  Future<List<Map<String, dynamic>>> getAudits({
    String? productId,
    int limit = 50,
  }) async {
    var baseQuery = _supabase
        .from('inventory_audits')
        .select(
          '*, products(name, sku), profiles(full_name), warehouses(name)',
        );
    if (productId != null) {
      baseQuery = baseQuery.eq('product_id', productId);
    }
    return await baseQuery.order('created_at', ascending: false).limit(limit);
  }

  Future<void> insertAudit(Map<String, dynamic> data) async {
    await _supabase.from('inventory_audits').insert(data);
  }

  Future<List<Map<String, dynamic>>> getWarehouses() async {
    return await _supabase.from('warehouses').select('*').order('id');
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    return await _supabase
        .from('products')
        .select('id, name, sku, current_stock, units(name), categories(name)')
        .order('name');
  }

  Future<List<Map<String, dynamic>>> getBatchesForProduct(
    String productId,
  ) async {
    return await _supabase
        .from('batches')
        .select(
          'id, batch_code, current_quantity, warehouse_id, warehouses(name)',
        )
        .eq('product_id', productId)
        .order('created_at', ascending: false);
  }

  String get currentUserId => _supabase.auth.currentUser!.id;
}
