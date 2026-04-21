import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';

class AuthRepository {
  final AuthProvider _provider;
  AuthRepository(this._provider);
  Session? get currentSession => _provider.currentSession;
  Future<User?> login(String email, String password) async {
    final response = await _provider.signIn(email, password);
    return response.user;
  }

  Future<User?> register(String email, String password) async {
    final response = await _provider.signUp(email, password);
    return response.user;
  }

  Future<void> logout() async {
    await _provider.signOut();
  }
}
