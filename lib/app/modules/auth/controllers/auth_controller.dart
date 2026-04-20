import 'package:get/get.dart';
import '../repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';
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
      Future.microtask(() => Get.offAllNamed(Routes.DASHBOARD));
    }
  }

  Future<void> login() async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Lỗi", "Vui lòng nhập đầy đủ thông tin");
      return;
    }

    try {
      isLoading.value = true;
      final user = await _repository.login(email.value.trim(), password.value.trim());

      if (user != null) {
        Get.offAllNamed(Routes.DASHBOARD);
      }
    } on AuthException catch (e) {
      Get.snackbar("Đăng nhập thất bại", e.message);
    } catch (e) {
      Get.snackbar("Lỗi", "Đã có lỗi xảy ra vui lòng thử lại sau");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp() async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Lỗi", "Vui lòng nhập đầy đủ thông tin");
      return;
    }

    try {
      isLoading.value = true;
      final user = await _repository.register(email.value.trim(), password.value.trim());

      if (user != null) {
        Get.snackbar("Thành công", "Đã tạo tài khoản! Bạn có thể đăng nhập ngay.");
      }
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
