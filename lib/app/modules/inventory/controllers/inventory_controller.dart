import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/inventory_repository.dart';
import '../../../data/models/product_model.dart';
import '../../../core/theme.dart';
import '../../../core/user_controller.dart';

class InventoryController extends GetxController {
  final InventoryRepository _repository;
  final isLoading = false.obs;
  final isLoadingWarehouses = false.obs;
  final products = <Product>[].obs;
  final categories = <Category>[].obs;
  final units = <Unit>[].obs;
  final warehouses = <Warehouse>[].obs;
  final selectedCategoryId = 0.obs;
  final selectedWarehouseId = 0.obs;
  final warehouseSelected = false.obs;
  final searchQuery = ''.obs;
  final showOnlyLowStock = false.obs;
  final selectedProduct = Rx<Product?>(null);
  final productBatches = <Batch>[].obs;
  Timer? _searchTimer;
  InventoryController(this._repository);
  List<Product> get filteredProducts {
    var list = products.toList();
    if (showOnlyLowStock.value) {
      list = list.where((p) => p.stockStatus != StockStatus.normal).toList();
    }
    if (selectedCategoryId.value != 0) {
      list = list.where((p) => p.categoryId == selectedCategoryId.value).toList();
    }
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((p) => p.name.toLowerCase().contains(q) || p.sku.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  int get totalItems => filteredProducts.length;
  int get totalStock => filteredProducts.fold(0, (sum, p) => sum + p.currentStock);

  void setCategory(int id) => selectedCategoryId.value = id;
  void setWarehouse(int id) {
    selectedWarehouseId.value = id;
    selectedCategoryId.value = 0;
    searchQuery.value = '';
    warehouseSelected.value = true;
    products.clear(); // Clear old products immediately for better UX
    fetchProducts();
  }

  void onSearchChanged(String query) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = query;
    });
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['filter'] == 'low_stock') {
      showOnlyLowStock.value = true;
    }
    _loadWarehouses();
  }

  @override
  void onClose() {
    _searchTimer?.cancel();
    super.onClose();
  }

  Future<void> _loadWarehouses() async {
    try {
      isLoadingWarehouses.value = true;
      final results = await Future.wait([
        _repository.fetchWarehouses(),
        _repository.fetchCategories(),
        _repository.fetchUnits(),
      ]);
      warehouses.assignAll(results[0] as List<Warehouse>);
      categories.assignAll(results[1] as List<Category>);
      units.assignAll(results[2] as List<Unit>);
      if (warehouses.isNotEmpty) {
        if (Get.isRegistered<UserController>()) {
          final uc = UserController.to;
          if (!uc.isAdmin && uc.primaryWarehouse != null) {
            setWarehouse(uc.primaryWarehouse!.id);
          } else {
            setWarehouse(warehouses.first.id);
          }
        } else {
          setWarehouse(warehouses.first.id);
        }
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không tải được danh sách kho: $e");
    } finally {
      isLoadingWarehouses.value = false;
    }
  }

  Future<void> fetchProducts() async {
    if (!warehouseSelected.value) return;
    try {
      isLoading.value = true;
      final list = await _repository.fetchProducts(
        warehouseId: selectedWarehouseId.value,
      );
      products.assignAll(list);
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải sản phẩm: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchData() async {
    await _loadWarehouses();
    if (warehouseSelected.value) await fetchProducts();
  }

  Future<void> fetchProductDetail(String productId) async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        _repository.fetchProductById(productId),
        _repository.fetchBatchesForProduct(productId),
      ]);
      selectedProduct.value = results[0] as Product;
      productBatches.assignAll(results[1] as List<Batch>);
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải chi tiết sản phẩm");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addProduct({
    required String name,
    required String sku,
    required int categoryId,
    required int unitId,
    required int initialQuantity,
    String? description,
  }) async {
    try {
      isLoading.value = true;
      await _repository.addProductWithInitialStock(
        name: name,
        sku: sku,
        categoryId: categoryId,
        unitId: unitId,
        initialQuantity: initialQuantity,
        description: description,
      );
      await fetchData();
      Get.back();
      Get.snackbar(
        "✅ Thành công",
        "Đã thêm sản phẩm: $name",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể thêm sản phẩm: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editProduct(
    Product product, {
    required String name,
    required String description,
    required int minStock,
  }) async {
    try {
      isLoading.value = true;
      await _repository.updateProduct(product.id, {
        'name': name,
        'description': description,
        'min_stock_level': minStock,
      });
      await fetchData();
      Get.back();
      Get.snackbar(
        "✅ Đã cập nhật",
        "Thông tin sản phẩm đã được lưu",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể cập nhật sản phẩm: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> archiveProduct(Product product) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Ngừng kinh doanh?",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Sản phẩm '${product.name}' sẽ được chuyển sang trạng thái NGỪNG KD.\n\nLịch sử giao dịch vẫn được giữ nguyên.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              "Xác nhận",
              style: TextStyle(color: AppTheme.warningColor),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      isLoading.value = true;
      await _repository.archiveProduct(product.id);
      products.removeWhere((p) => p.id == product.id);
      Get.snackbar(
        "Đã ngừng",
        "Sản phẩm '${product.name}' đã ngừng kinh doanh",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể thay đổi trạng thái: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
