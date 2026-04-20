import '../providers/audit_provider.dart';

class AuditRepository {
  final AuditProvider _provider;

  AuditRepository(this._provider);

  Future<List<Map<String, dynamic>>> fetchAudits() async => await _provider.getAudits();

  Future<void> submitAudit(Map<String, dynamic> data) async {
    await _provider.insertAudit({
      ...data,
      'user_id': _provider.currentUserId,
    });
  }
}
