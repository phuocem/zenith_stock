import 'package:get/get.dart';
import '../repositories/dashboard_repository.dart';
import '../../../routes/app_pages.dart';
import '../../../core/user_controller.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repository;

  final isLoading    = true.obs;
  final totalStock   = 0.obs;
  final lowStockCount = 0.obs;
  final inboundThisWeek  = 0.obs;
  final outboundThisWeek = 0.obs;
  final chartData    = <double>[].obs;
  final topProducts  = <dynamic>[].obs;

  DashboardController(this._repository);

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      final data = await _repository.getSummaryData();

      totalStock.value       = data['totalStock'];
      lowStockCount.value    = data['lowStockCount'];
      inboundThisWeek.value  = data['inboundThisWeek'];
      outboundThisWeek.value = data['outboundThisWeek'];
      chartData.assignAll(data['chartData'] as List<double>);
      topProducts.assignAll(data['topProducts'] as List);
    } catch (_) {
      Get.snackbar("Lỗi", "Không thể tải dữ liệu Dashboard");
    } finally {
      isLoading.value = false;
    }
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng,';
    if (hour < 18) return 'Chào buổi chiều,';
    return 'Chào buổi tối,';
  }

  String get userName {
    if (Get.isRegistered<UserController>()) {
      return UserController.to.displayName;
    }
    return 'Bạn';
  }

  void logout() async {
    await _repository.logout();
    if (Get.isRegistered<UserController>()) {
      UserController.to.clear();
    }
    Get.offAllNamed(Routes.AUTH);
  }
}
