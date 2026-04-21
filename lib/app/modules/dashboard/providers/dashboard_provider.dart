import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardProvider {
  final SupabaseClient _supabase = Supabase.instance.client;
  Future<List<Map<String, dynamic>>> getDashboardStats({
    int? warehouseId,
  }) async {
    var query = _supabase.from('vw_dashboard_stats').select('*');
    if (warehouseId != null) {
      query = query.eq('warehouse_id', warehouseId);
    }
    return await query;
  }

  Future<List<Map<String, dynamic>>> getTransactionsLastDays(
    int days, {
    int? warehouseId,
  }) async {
    final from = DateTime.now()
        .subtract(Duration(days: days))
        .toIso8601String();
    var query = _supabase
        .from('transactions')
        .select(
          'id, type, created_at, warehouse_id, transaction_items(quantity)',
        )
        .gte('created_at', from);
    if (warehouseId != null) {
      query = query.eq('warehouse_id', warehouseId);
    }
    return await query;
  }

  Future<List<Map<String, dynamic>>> getTopProducts(
    int limit, {
    int? warehouseId,
  }) async {
    if (warehouseId != null) {
      final txRes = await _supabase
          .from('transactions')
          .select('id')
          .eq('warehouse_id', warehouseId);
      final txIds = (txRes).map((t) => t['id'] as String).toList();
      if (txIds.isEmpty) return [];
      return await _supabase
          .from('transaction_items')
          .select('product_id, products(name), quantity')
          .inFilter('transaction_id', txIds)
          .order('quantity', ascending: false)
          .limit(limit);
    }
    return await _supabase
        .from('transaction_items')
        .select('product_id, products(name), quantity')
        .order('quantity', ascending: false)
        .limit(limit);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
