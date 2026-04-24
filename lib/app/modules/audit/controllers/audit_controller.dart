import 'package:get/get.dart';
import '../repositories/audit_repository.dart';
import '../../../data/models/audit_model.dart';
import '../../../data/models/product_model.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../inventory/controllers/inventory_controller.dart';

class AuditController extends GetxController {
  final AuditRepository _repository;
  final isLoading = false.obs;
  final audits = <InventoryAudit>[].obs;
  final isSubmitting = false.obs;
  final warehouses = <Warehouse>[].obs;
  final allProducts = <Product>[].obs;
  final batchesForProduct = <Batch>[].obs;
  final selectedWarehouse = Rx<Warehouse?>(null);
  final selectedProduct = Rx<Product?>(null);
  final selectedBatch = Rx<Batch?>(null);
  final actualQty = 0.obs;
  AuditController(this._repository);
  @override
  void onInit() {
    super.onInit();
    fetchAudits();
    fetchFormData();

    ever(selectedWarehouse, (_) {
      selectedProduct.value = null;
      selectedBatch.value = null;
      batchesForProduct.clear();
      actualQty.value = 0;
    });
  }

  Future<void> fetchAudits() async {
    try {
      isLoading.value = true;
      final res = await _repository.fetchAudits();
      audits.assignAll(res);
    } catch (_) {
      Get.snackbar("Lỗi", "Không thể tải lịch sử kiểm kê");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFormData() async {
    try {
      final results = await Future.wait([
        _repository.fetchWarehouses(),
        _repository.fetchAllProducts(),
      ]);
      warehouses.assignAll(results[0] as List<Warehouse>);
      allProducts.assignAll(results[1] as List<Product>);
      if ((results[0] as List).isNotEmpty) {
        selectedWarehouse.value = (results[0] as List<Warehouse>).first;
      }
    } catch (_) {}
  }

  Future<void> onProductSelected(Product product) async {
    selectedProduct.value = product;
    selectedBatch.value = null;
    batchesForProduct.clear();
    actualQty.value = 0;

    final wh = selectedWarehouse.value;
    if (wh == null) return;

    try {
      final batches = await _repository.fetchBatchesForProduct(product.id);

      final filtered = batches.where((b) => b.warehouseId == wh.id).toList();
      batchesForProduct.assignAll(filtered);

      if (filtered.isNotEmpty) {
        selectedBatch.value = filtered.first;
        actualQty.value = filtered.first.currentQuantity;
      }
    } catch (_) {}
  }

  void onBatchSelected(Batch batch) {
    selectedBatch.value = batch;
    actualQty.value = batch.currentQuantity;
  }

  Future<void> submitAudit({String? reason}) async {
    final wh = selectedWarehouse.value;
    final product = selectedProduct.value;
    final batch = selectedBatch.value;
    if (wh == null || product == null || batch == null) {
      Get.snackbar(
        "Thiếu thông tin",
        "Vui lòng chọn đầy đủ kho, sản phẩm và lô hàng",
      );
      return;
    }
    try {
      isSubmitting.value = true;
      await _repository.submitAudit(
        warehouseId: wh.id,
        productId: product.id,
        batchId: batch.id,
        systemQty: batch.currentQuantity,
        actualQty: actualQty.value,
        reason: reason,
      );
      selectedProduct.value = null;
      selectedBatch.value = null;
      batchesForProduct.clear();
      actualQty.value = 0;
      Get.back();

      if (Get.isRegistered<InventoryController>()) {
        Get.find<InventoryController>().fetchProducts();
      }
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().fetchDashboardData();
      }

      await fetchAudits();
      Get.snackbar(
        "✅ Thành công",
        "Đã ghi nhận kết quả kiểm kê",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Lỗi", "Chốt sổ thất bại: $e");
    } finally {
      isSubmitting.value = false;
    }
  }
}
