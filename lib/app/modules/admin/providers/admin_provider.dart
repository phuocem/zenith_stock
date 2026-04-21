import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdminProvider {
  final _supabase = Supabase.instance.client;
  Future<List<Map<String, dynamic>>> getUsers() async {
    return await _supabase
        .from('profiles')
        .select(
          'id, full_name, email, phone, role_id, roles(name), user_warehouses!user_warehouses_user_id_fkey(is_primary, warehouses(id, code, name))',
        )
        .order('full_name');
  }

  Future<List<Map<String, dynamic>>> getRoles() async {
    return await _supabase.from('roles').select('*').order('id');
  }

  Future<List<Map<String, dynamic>>> getWarehouses() async {
    return await _supabase
        .from('warehouses')
        .select('id, code, name')
        .eq('is_active', true)
        .order('id');
  }

  Future<void> updateUserRole(String userId, int roleId) async {
    await _supabase
        .from('profiles')
        .update({'role_id': roleId})
        .eq('id', userId);
  }

  Future<void> assignWarehouse(
    String userId,
    int warehouseId, {
    bool isPrimary = false,
  }) async {
    await _supabase.from('user_warehouses').upsert({
      'user_id': userId,
      'warehouse_id': warehouseId,
      'is_primary': isPrimary,
    }, onConflict: 'user_id,warehouse_id');
  }

  Future<void> removeWarehouse(String userId, int warehouseId) async {
    await _supabase
        .from('user_warehouses')
        .delete()
        .eq('user_id', userId)
        .eq('warehouse_id', warehouseId);
  }

  Future<void> updateProfile(
    String userId, {
    String? fullName,
    String? phone,
  }) async {
    final data = <String, dynamic>{};
    if (fullName != null) data['full_name'] = fullName;
    if (phone != null) data['phone'] = phone;
    if (data.isEmpty) return;
    await _supabase.from('profiles').update(data).eq('id', userId);
  }

  Future<void> createUser({
    required String email,
    required String password,
    required String fullName,
    required int roleId,
  }) async {
    final url = '${dotenv.env['SUPABASE_URL']}/auth/v1/signup';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY']!;
    final dio = Dio();
    try {
      final res = await dio.post(
        url,
        data: {
          'email': email,
          'password': password,
          'data': {'full_name': fullName},
        },
        options: Options(
          headers: {
            'apikey': anonKey,
            'Authorization': 'Bearer $anonKey',
            'Content-Type': 'application/json',
          },
        ),
      );
      final userId = res.data['id'] ?? res.data['user']['id'];
      if (userId == null) throw Exception("Không lấy được ID người dùng");
      await Future.delayed(const Duration(milliseconds: 500));
      await _supabase
          .from('profiles')
          .update({'role_id': roleId})
          .eq('id', userId);
    } on DioException catch (e) {
      final msg = e.response?.data?['msg'] ?? e.message;
      throw Exception(msg);
    }
  }
}
