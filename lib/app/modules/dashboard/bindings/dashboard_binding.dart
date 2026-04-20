import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../providers/dashboard_provider.dart';
import '../repositories/dashboard_repository.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardProvider>(() => DashboardProvider());
    Get.lazyPut<DashboardRepository>(() => DashboardRepository(Get.find()));
    Get.lazyPut<DashboardController>(() => DashboardController(Get.find()));
  }
}
