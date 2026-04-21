import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/user_model.dart';
import '../../../core/user_controller.dart';
import '../../../routes/app_pages.dart';

class ProfileController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final fullName = ''.obs;
  final phone = ''.obs;
  @override
  void onInit() {
    super.onInit();
    _loadFromGlobal();
  }

  void _loadFromGlobal() {
    if (Get.isRegistered<UserController>()) {
      final profile = UserController.to.profile.value;
      if (profile != null) {
        fullName.value = profile.fullName ?? '';
        phone.value = profile.phone ?? '';
      }
    }
  }

  UserProfile? get currentProfile => Get.isRegistered<UserController>()
      ? UserController.to.profile.value
      : null;
  Future<void> saveProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      isSaving.value = true;
      await _supabase
          .from('profiles')
          .update({
            'full_name': fullName.value.trim(),
            'phone': phone.value.trim(),
          })
          .eq('id', userId);
      if (Get.isRegistered<UserController>()) {
        await UserController.to.fetchProfile();
      }
      Get.snackbar(
        "✅ Đã lưu",
        "Thông tin hồ sơ đã được cập nhật",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể cập nhật hồ sơ: $e");
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    if (Get.isRegistered<UserController>()) UserController.to.clear();
    Get.offAllNamed(Routes.AUTH);
  }
}
