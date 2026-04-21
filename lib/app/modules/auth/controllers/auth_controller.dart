import 'package:get/get.dart';
import '../repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';
import '../../../core/user_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final AuthRepository _repository;
  final isLoading = false.obs;
  final showPassword = false.obs;
  final email = ''.obs;
  final password = ''.obs;
  AuthController(this._repository);
  @override
  void onInit() {
    super.onInit();
    if (_repository.currentSession != null) {
      if (Get.isRegistered<UserController>()) {
        UserController.to.fetchProfile();
      }
      Future.microtask(() => Get.offAllNamed(Routes.DASHBOARD));
    }
  }

  Future<void> login() async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Thiếu thông tin", "Vui lòng nhập email và mật khẩu");
      return;
    }
    try {
      isLoading.value = true;
      final user = await _repository.login(
        email.value.trim(),
        password.value.trim(),
      );
      if (user != null) {
        if (Get.isRegistered<UserController>()) {
          await UserController.to.fetchProfile();
        }
        Get.offAllNamed(Routes.DASHBOARD);
      }
    } on AuthException catch (e) {
      Get.snackbar(
        "Đăng nhập thất bại",
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Lỗi", "Đã có lỗi xảy ra, vui lòng thử lại");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp() async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Thiếu thông tin", "Vui lòng nhập email và mật khẩu");
      return;
    }
    try {
      isLoading.value = true;
      await _repository.register(email.value.trim(), password.value.trim());
      Get.snackbar(
        "✅ Đăng ký thành công",
        "Tài khoản đã được tạo! Bạn có thể đăng nhập ngay.",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } on AuthException catch (e) {
      Get.snackbar("Lỗi đăng ký", e.message);
    } catch (e) {
      Get.snackbar("Lỗi", "Đã có lỗi xảy ra");
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() => showPassword.toggle();
}
