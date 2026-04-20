import 'package:supabase_flutter/supabase_flutter.dart';

class AuditProvider {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAudits() async {
    return await _supabase
        .from('inventory_audits')
        .select('*, products(name), profiles(full_name)')
        .order('created_at', ascending: false);
  }

  Future<void> insertAudit(Map<String, dynamic> data) async {
    await _supabase.from('inventory_audits').insert(data);
  }

  String get currentUserId => _supabase.auth.currentUser!.id;
}
