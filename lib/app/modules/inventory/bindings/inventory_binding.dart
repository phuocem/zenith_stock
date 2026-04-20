import 'package:get/get.dart';
import '../controllers/inventory_controller.dart';
import '../providers/inventory_provider.dart';
import '../repositories/inventory_repository.dart';

class InventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InventoryProvider>(() => InventoryProvider());
    Get.lazyPut<InventoryRepository>(() => InventoryRepository(Get.find()));
    Get.lazyPut<InventoryController>(() => InventoryController(Get.find()));
  }
}
