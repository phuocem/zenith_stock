import 'package:get/get.dart';
import '../repositories/inventory_repository.dart';

class InventoryController extends GetxController {
  final InventoryRepository _repository;
  
  final isLoading = false.obs;
  final products = <dynamic>[].obs;
  final categories = <dynamic>[].obs;
  final units = <dynamic>[].obs; 
  final selectedCategoryId = 0.obs;

  InventoryController(this._repository);

  List<dynamic> get filteredProducts {
    if (selectedCategoryId.value == 0) return products;
    return products.where((p) => p['category_id'] == selectedCategoryId.value).toList();
  }

  void setCategory(dynamic id) {
    selectedCategoryId.value = id ?? 0;
  }

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        _repository.fetchCategories(),
        _repository.fetchUnits(),
        _repository.fetchProducts(),
      ]);
      
      categories.assignAll(results[0]);
      units.assignAll(results[1]);
      products.assignAll(results[2]);
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải dữ liệu kho");
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
      Get.snackbar("Thành công", "Đã thêm sản phẩm: $name");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể thêm sản phẩm: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
