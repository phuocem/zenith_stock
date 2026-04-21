import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/user_model.dart';

class UserController extends GetxController {
  static UserController get to => Get.find();

  final Rx<UserProfile?> profile = Rx<UserProfile?>(null);
  final isLoading = false.obs;

  final _supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final res = await _supabase
          .from('profiles')
          .select('*, roles(name)')
          .eq('id', userId)
          .single();

      final email = _supabase.auth.currentUser?.email;
      final data = {...res, 'email': email};
      profile.value = UserProfile.fromJson(data);
    } catch (_) {

    } finally {
      isLoading.value = false;
    }
  }

  String get displayName => profile.value?.displayName ?? 'Người dùng';
  String get initials => profile.value?.initials ?? 'U';
  String? get roleName => profile.value?.roleName;
  bool get isAdmin => roleName == 'Admin';

  void clear() => profile.value = null;
}
