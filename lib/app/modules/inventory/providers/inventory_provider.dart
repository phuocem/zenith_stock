import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryProvider {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getCategories() async {
    return await _supabase.from('categories').select('*').order('id');
  }

  Future<List<Map<String, dynamic>>> getUnits() async {
    return await _supabase.from('units').select('*').order('id');
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    return await _supabase
        .from('products')
        .select('*, categories(name), units(name)')
        .order('name');
  }

  Future<Map<String, dynamic>> insertProduct(Map<String, dynamic> data) async {
    return await _supabase.from('products').insert(data).select().single();
  }

  Future<void> insertBatch(Map<String, dynamic> data) async {
    await _supabase.from('batches').insert(data);
  }
}
