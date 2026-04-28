import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../providers/dashboard_provider.dart';
import '../repositories/dashboard_repository.dart';
import '../../inventory/controllers/inventory_controller.dart';
import '../../inventory/repositories/inventory_repository.dart';
import '../../inventory/providers/inventory_provider.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardProvider>(() => DashboardProvider());
    Get.lazyPut<DashboardRepository>(() => DashboardRepository(Get.find()));
    Get.lazyPut<DashboardController>(() => DashboardController(Get.find()));
    
    // Support quick add product from dashboard
    Get.lazyPut<InventoryProvider>(() => InventoryProvider());
    Get.lazyPut<InventoryRepository>(() => InventoryRepository(Get.find()));
    Get.lazyPut<InventoryController>(() => InventoryController(Get.find()));
  }
}
