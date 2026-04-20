import 'package:get/get.dart';
import '../repositories/dashboard_repository.dart';
import '../../../routes/app_pages.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repository;
  
  final isLoading = true.obs;
  final totalStock = 0.obs;
  final lowStockCount = 0.obs;
  final inboundThisWeek = 0.obs;
  final outboundThisWeek = 0.obs;
  final chartData = <double>[].obs;
  final topProducts = <dynamic>[].obs;

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
      
      totalStock.value = data['totalStock'];
      lowStockCount.value = data['lowStockCount'];
      inboundThisWeek.value = data['inboundThisWeek'];
      outboundThisWeek.value = data['outboundThisWeek'];
      chartData.assignAll(data['chartData']);
      topProducts.assignAll(data['topProducts']);
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải dữ liệu Dashboard");
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    await _repository.logout();
    Get.offAllNamed(Routes.AUTH);
  }
}
