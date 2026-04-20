import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionProvider {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getHistory() async {
    return await _supabase
        .from('transactions')
        .select('*, profiles(full_name), warehouses!transactions_warehouse_id_fkey(name)')
        .order('created_at', ascending: false);
  }

  Future<Map<String, dynamic>> insertTransaction(Map<String, dynamic> data) async {
    return await _supabase.from('transactions').insert(data).select().single();
  }

  Future<void> insertTransactionItems(List<Map<String, dynamic>> items) async {
    await _supabase.from('transaction_items').insert(items);
  }

  String get currentUserId => _supabase.auth.currentUser!.id;
}
