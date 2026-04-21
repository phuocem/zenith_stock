import 'package:get/get.dart';
import '../providers/admin_provider.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/user_model.dart';

class AdminController extends GetxController {
  final AdminProvider _provider;
  AdminController(this._provider);
  final isLoading = false.obs;
  final users = <Map<String, dynamic>>[].obs;
  final roles = <Map<String, dynamic>>[].obs;
  final warehouses = <Warehouse>[].obs;
  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        _provider.getUsers(),
        _provider.getRoles(),
        _provider.getWarehouses(),
      ]);
      users.assignAll(results[0] as List<Map<String, dynamic>>);
      roles.assignAll(results[1] as List<Map<String, dynamic>>);
      warehouses.assignAll(
        (results[2] as List<Map<String, dynamic>>)
            .map((w) => Warehouse.fromJson(w))
            .toList(),
      );
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải dữ liệu: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createUser({
    required String email,
    required String password,
    required String fullName,
    required int roleId,
  }) async {
    try {
      isLoading.value = true;
      await _provider.createUser(
        email: email,
        password: password,
        fullName: fullName,
        roleId: roleId,
      );
      await fetchAll();
      Get.back();
      Get.snackbar("✅ Thành công", "Tạo nhân viên thành công");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tạo nhân viên: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateRole(String userId, int roleId) async {
    try {
      await _provider.updateUserRole(userId, roleId);
      await fetchAll();
      Get.back();
      Get.snackbar("✅ Thành công", "Đã cập nhật chức vụ");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể cập nhật: $e");
    }
  }

  Future<void> assignWarehouse(
    String userId,
    int warehouseId, {
    bool isPrimary = false,
  }) async {
    try {
      await _provider.assignWarehouse(
        userId,
        warehouseId,
        isPrimary: isPrimary,
      );
      await fetchAll();
      Get.snackbar("✅ Thành công", "Đã phân công kho");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể phân công: $e");
    }
  }

  Future<void> removeWarehouse(String userId, int warehouseId) async {
    try {
      await _provider.removeWarehouse(userId, warehouseId);
      await fetchAll();
      Get.snackbar("✅ Thành công", "Đã thu hồi phân công");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể thu hồi: $e");
    }
  }

  String roleName(int? roleId) {
    if (roleId == null) return 'Chưa có';
    final r = roles.firstWhereOrNull((r) => r['id'] == roleId);
    return r?['name'] as String? ?? 'Chưa có';
  }

  List<Map<String, dynamic>> userWarehouses(Map<String, dynamic> user) {
    final list = user['user_warehouses'] as List? ?? [];
    return list.cast<Map<String, dynamic>>();
  }
}
