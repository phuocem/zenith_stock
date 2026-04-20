import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../providers/auth_provider.dart';
import '../repositories/auth_repository.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthProvider>(() => AuthProvider());
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find()));
    Get.lazyPut<AuthController>(() => AuthController(Get.find()));
  }
}
