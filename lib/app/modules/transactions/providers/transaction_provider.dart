import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TransactionProvider {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Dio _dio = Dio();
  
  String get _apiUrl => dotenv.env['API_URL'] ?? 'http://localhost:8000';

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

  // Unified submission via Backend API
  Future<Map<String, dynamic>> submitTransactionToBackend(Map<String, dynamic> data) async {
    final token = _supabase.auth.currentSession?.accessToken;
    if (token == null) throw Exception("Unauthorized: No session token");

    try {
      final response = await _dio.post(
        '$_apiUrl/transactions/',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      final msg = e.response?.data?['detail'] ?? e.message;
      throw Exception("Backend Error: $msg");
    }
  }

  String get currentUserId => _supabase.auth.currentUser!.id;
}
