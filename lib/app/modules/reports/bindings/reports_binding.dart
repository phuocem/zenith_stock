import 'package:get/get.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../dashboard/repositories/dashboard_repository.dart';
import '../controllers/reports_controller.dart';

class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardProvider>(() => DashboardProvider());
    Get.lazyPut<DashboardRepository>(() => DashboardRepository(Get.find()));
    Get.lazyPut<ReportsController>(() => ReportsController(Get.find()));
  }
}
