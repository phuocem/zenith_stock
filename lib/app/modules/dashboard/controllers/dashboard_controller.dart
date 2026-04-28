import 'package:get/get.dart';
import '../repositories/dashboard_repository.dart';
import '../../../routes/app_pages.dart';
import '../../../core/user_controller.dart';
import '../../../data/models/user_model.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repository;
  final isLoading = true.obs;
  final totalStock = 0.obs;
  final lowStockCount = 0.obs;
  final outOfStockCount = 0.obs;
  final inboundThisWeek = 0.obs;
  final outboundThisWeek = 0.obs;
  final inboundChartData = <double>[].obs;
  final outboundChartData = <double>[].obs;
  final topProducts = <dynamic>[].obs;
  final selectedWarehouse = Rx<WarehouseAccess?>(null);
  final availableWarehouses = <WarehouseAccess>[].obs;
  DashboardController(this._repository);
  @override
  void onInit() {
    super.onInit();
    _initWarehouse();
  }

  void _initWarehouse() {
    if (!Get.isRegistered<UserController>()) {
      fetchDashboardData();
      return;
    }
    final uc = UserController.to;
    availableWarehouses.assignAll(uc.warehouses);
    if (uc.isAdmin) {
      selectedWarehouse.value = null;
    } else {
      selectedWarehouse.value = uc.primaryWarehouse;
    }
    fetchDashboardData();
  }

  void selectWarehouse(WarehouseAccess? wh) {
    selectedWarehouse.value = wh;
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      final data = await _repository.getSummaryData(
        warehouseId: selectedWarehouse.value?.id,
      );
      totalStock.value = data['totalStock'] as int;
      lowStockCount.value = data['lowStockCount'] as int;
      outOfStockCount.value = data['outOfStockCount'] as int;
      inboundThisWeek.value = data['inboundThisWeek'] as int;
      outboundThisWeek.value = data['outboundThisWeek'] as int;
      inboundChartData.assignAll(data['inboundChartData'] as List<double>);
      outboundChartData.assignAll(data['outboundChartData'] as List<double>);
      topProducts.assignAll(data['topProducts'] as List);
    } catch (_) {
      Get.snackbar("Lỗi", "Không thể tải dữ liệu Dashboard");
    } finally {
      isLoading.value = false;
    }
  }

  String get selectedWarehouseName =>
      selectedWarehouse.value?.name ?? 'Toàn hệ thống';
  bool get isAdmin =>
      Get.isRegistered<UserController>() ? UserController.to.isAdmin : false;
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng,';
    if (hour < 18) return 'Chào buổi chiều,';
    return 'Chào buổi tối,';
  }

  String get userName {
    if (Get.isRegistered<UserController>())
      return UserController.to.displayName;
    return 'Bạn';
  }

  void logout() async {
    await _repository.logout();
    if (Get.isRegistered<UserController>()) UserController.to.clear();
    Get.offAllNamed(Routes.AUTH);
  }
}
