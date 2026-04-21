import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/inventory_repository.dart';
import '../../../data/models/product_model.dart';
import '../../../core/theme.dart';

class InventoryController extends GetxController {
  final InventoryRepository _repository;

  final isLoading = false.obs;
  final products   = <Product>[].obs;
  final categories = <Category>[].obs;
  final units      = <Unit>[].obs;
  final warehouses = <Warehouse>[].obs;
  final selectedCategoryId = 0.obs;
  final searchQuery = ''.obs;

  final selectedProduct = Rx<Product?>(null);
  final productBatches  = <Batch>[].obs;

  Timer? _searchTimer;

  InventoryController(this._repository);

  List<Product> get filteredProducts {
    var list = products.toList();
    if (selectedCategoryId.value != 0) {
      list = list.where((p) => p.categoryId == selectedCategoryId.value).toList();
    }
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((p) =>
        p.name.toLowerCase().contains(q) ||
        p.sku.toLowerCase().contains(q)
      ).toList();
    }
    return list;
  }

  void setCategory(int id) => selectedCategoryId.value = id;

  void onSearchChanged(String query) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = query;
    });
  }

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  @override
  void onClose() {
    _searchTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        _repository.fetchCategories(),
        _repository.fetchUnits(),
        _repository.fetchWarehouses(),
        _repository.fetchProducts(),
      ]);
      categories.assignAll(results[0] as List<Category>);
      units.assignAll(results[1] as List<Unit>);
      warehouses.assignAll(results[2] as List<Warehouse>);
      products.assignAll(results[3] as List<Product>);
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải dữ liệu kho: $e");
    } finally {
      isLoading.value = false;
    }
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
      Get.snackbar("✅ Thành công", "Đã thêm sản phẩm: $name",
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể thêm sản phẩm: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(Product product) async {
    if (product.currentStock > 0) {
      Get.snackbar("Không thể xóa", "Sản phẩm còn ${product.currentStock} trong kho",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text("Xác nhận xóa", style: TextStyle(color: Colors.white)),
        content: Text("Bạn có chắc muốn xóa '${product.name}'?",
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text("Hủy")),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text("Xóa", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      isLoading.value = true;
      await _repository.deleteProduct(product.id);
      products.removeWhere((p) => p.id == product.id);
      Get.snackbar("Đã xóa", "Đã xóa sản phẩm '${product.name}'",
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể xóa sản phẩm: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
