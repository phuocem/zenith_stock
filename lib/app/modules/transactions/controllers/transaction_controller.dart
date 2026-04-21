import 'package:get/get.dart';
import '../repositories/transaction_repository.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/product_model.dart';

class TransactionController extends GetxController {
  final TransactionRepository _repository;

  final isLoading   = false.obs;
  final history     = <Transaction>[].obs;
  final filterType  = Rx<String?>(null);

  final isSubmitting      = false.obs;
  final formType          = 'IN'.obs;
  final selectedWarehouse = Rx<Warehouse?>(null);
  final warehouses        = <Warehouse>[].obs;
  final availableProducts = <Product>[].obs;
  final draftItems        = <TransactionItemDraft>[].obs;

  TransactionController(this._repository);

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
    fetchWarehouses();
  }

  Future<void> fetchHistory() async {
    try {
      isLoading.value = true;
      final res = await _repository.fetchHistory(type: filterType.value);
      history.assignAll(res);
    } catch (_) {
      Get.snackbar("Lỗi", "Không thể tải lịch sử giao dịch");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWarehouses() async {
    try {
      final res = await _repository.fetchWarehouses();
      warehouses.assignAll(res);
      if (res.isNotEmpty) selectedWarehouse.value = res.first;
    } catch (_) {}
  }

  Future<List<Product>> loadProductsForType() async {
    if (formType.value == 'OUT') {
      return await _repository.fetchProductsWithAvailableBatches();
    }
    return await _repository.fetchAllProducts();
  }

  Future<List<Batch>> loadBatchesForProduct(String productId) async {
    if (formType.value == 'OUT') {
      return await _repository.fetchAvailableBatches(productId);
    }
    return await _repository.fetchAllBatches(productId);
  }

  void addDraftItem(TransactionItemDraft item) {

    final existing = draftItems.indexWhere((d) => d.batch.id == item.batch.id);
    if (existing >= 0) {
      draftItems[existing].quantity += item.quantity;
      draftItems.refresh();
    } else {
      draftItems.add(item);
    }
  }

  void removeDraftItem(int index) => draftItems.removeAt(index);

  void updateDraftQty(int index, int qty) {
    draftItems[index].quantity = qty;
    draftItems.refresh();
  }

  void clearDraft() {
    draftItems.clear();
    formType.value = 'IN';
  }

  Future<void> submitTransaction({String? notes, String? refNumber}) async {
    if (selectedWarehouse.value == null) {
      Get.snackbar("Lỗi", "Vui lòng chọn kho");
      return;
    }
    if (draftItems.isEmpty) {
      Get.snackbar("Lỗi", "Vui lòng thêm ít nhất 1 sản phẩm");
      return;
    }

    if (formType.value == 'OUT') {
      for (final item in draftItems) {
        if (item.quantity > item.batch.currentQuantity) {
          Get.snackbar(
            "Không đủ hàng",
            "'${item.product.name}' — Lô ${item.batch.batchCode}: cần ${item.quantity}, còn ${item.batch.currentQuantity}",
            duration: const Duration(seconds: 4),
          );
          return;
        }
      }
    }

    try {
      isSubmitting.value = true;
      await _repository.submitTransaction(
        type: formType.value,
        warehouseId: selectedWarehouse.value!.id,
        notes: notes,
        referenceNumber: refNumber,
        items: draftItems.toList(),
      );
      clearDraft();
      Get.back();
      await fetchHistory();
      Get.snackbar(
        "✅ Thành công",
        "Đã ghi nhận ${formType.value == 'IN' ? 'phiếu nhập' : 'phiếu xuất'} kho",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Lỗi", "Giao dịch thất bại: $e");
    } finally {
      isSubmitting.value = false;
    }
  }
}
