import 'package:get/get.dart';
import '../repositories/transaction_repository.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/product_model.dart';
import '../../../core/user_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../inventory/controllers/inventory_controller.dart';

class TransactionController extends GetxController {
  final TransactionRepository _repository;
  final isLoading = false.obs;
  final history = <Transaction>[].obs;
  final filterType = Rx<String?>(null);
  final isSubmitting = false.obs;
  final formType = 'IN'.obs;
  final selectedWarehouse = Rx<Warehouse?>(null);
  final warehouses = <Warehouse>[].obs;
  final availableProducts = <Product>[].obs;
  final draftItems = <TransactionItemDraft>[].obs;
  TransactionController(this._repository);
  @override
  void onInit() {
    super.onInit();
    fetchHistory();
    _initWarehouses();
  }

  void _initWarehouses() {
    if (!Get.isRegistered<UserController>()) {
      _fetchWarehousesFromDB();
      return;
    }
    final uc = UserController.to;
    if (uc.isAdmin) {
      _fetchWarehousesFromDB();
      return;
    }
    if (uc.warehouses.isNotEmpty) {
      final whs = uc.warehouses
          .map(
            (w) => Warehouse(
              id: w.id,
              code: w.code,
              name: w.name,
              location: w.location,
            ),
          )
          .toList();
      warehouses.assignAll(whs);
      final primary = uc.primaryWarehouse;
      if (primary != null) {
        selectedWarehouse.value =
            whs.firstWhereOrNull((w) => w.id == primary.id) ?? whs.first;
      } else if (whs.isNotEmpty) {
        selectedWarehouse.value = whs.first;
      }
    } else {
      _fetchWarehousesFromDB();
    }
  }

  Future<void> _fetchWarehousesFromDB() async {
    try {
      final res = await _repository.fetchWarehouses();
      warehouses.assignAll(res);
      if (res.isNotEmpty) selectedWarehouse.value = res.first;
    } catch (_) {}
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

  Future<List<Product>> loadProductsForType() async {
    final warehouseId = selectedWarehouse.value?.id;
    if (formType.value == 'OUT') {
      return await _repository.fetchProductsWithAvailableBatches(
        warehouseId: warehouseId,
      );
    }
    return await _repository.fetchAllProducts();
  }

  Future<List<Batch>> loadBatchesForProduct(String productId) async {
    final warehouseId = selectedWarehouse.value?.id;
    if (formType.value == 'OUT') {
      return await _repository.fetchAvailableBatches(
        productId,
        warehouseId: warehouseId,
      );
    }
    return await _repository.fetchAllBatches(
      productId,
      warehouseId: warehouseId,
    );
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

      // Refresh other modules for reactivity
      if (Get.isRegistered<InventoryController>()) {
        Get.find<InventoryController>().fetchProducts();
      }
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().fetchDashboardData();
      }

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
