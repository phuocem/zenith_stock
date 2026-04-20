import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardProvider {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getInventorySummary() async {
    return await _supabase.from('vw_inventory_summary').select();
  }

  Future<List<Map<String, dynamic>>> getTransactions(DateTime fromDate) async {
    return await _supabase
        .from('transactions')
        .select('*, transaction_items(quantity)')
        .gte('created_at', fromDate.toIso8601String());
  }

  Future<List<Map<String, dynamic>>> getTopProducts(int limit) async {
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
