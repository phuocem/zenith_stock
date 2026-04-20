import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider {
  final SupabaseClient _supabase = Supabase.instance.client;

  Session? get currentSession => _supabase.auth.currentSession;

  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp(String email, String password) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': 'New User'},
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
