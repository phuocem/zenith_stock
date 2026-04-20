import 'package:get/get.dart';
import '../repositories/transaction_repository.dart';

class TransactionController extends GetxController {
  final TransactionRepository _repository;
  
  final isLoading = false.obs;
  final history = <dynamic>[].obs;

  TransactionController(this._repository);

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      isLoading.value = true;
      final res = await _repository.fetchHistory();
      history.assignAll(res);
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải lịch sử giao dịch");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createTransaction(String type, int warehouseId, String notes, List<Map<String, dynamic>> items) async {
    try {
      isLoading.value = true;
      await _repository.submitTransaction(
        type: type,
        warehouseId: warehouseId,
        notes: notes,
        items: items,
      );
      
      await fetchHistory();
      Get.back();
      Get.snackbar("Thành công", "Đã ghi nhận giao dịch $type");
    } catch (e) {
      Get.snackbar("Lỗi", "Giao dịch thất bại: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
