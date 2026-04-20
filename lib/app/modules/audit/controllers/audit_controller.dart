import 'package:get/get.dart';
import '../repositories/audit_repository.dart';

class AuditController extends GetxController {
  final AuditRepository _repository;
  
  final isLoading = false.obs;
  final audits = <dynamic>[].obs;

  AuditController(this._repository);

  @override
  void onInit() {
    super.onInit();
    fetchAudits();
  }

  Future<void> fetchAudits() async {
    try {
      isLoading.value = true;
      final res = await _repository.fetchAudits();
      audits.assignAll(res);
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải lịch sử kiểm kê");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitAudit(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      await _repository.submitAudit(data);
      await fetchAudits();
      Get.back();
      Get.snackbar("Thành công", "Đã chốt sổ kiểm kê");
    } catch (e) {
      Get.snackbar("Lỗi", "Chốt sổ thất bại");
    } finally {
      isLoading.value = false;
    }
  }
}
