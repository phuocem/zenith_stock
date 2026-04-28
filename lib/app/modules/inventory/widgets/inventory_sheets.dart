import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import '../../../core/theme.dart';
import '../../../core/global_styles.dart';
import '../controllers/inventory_controller.dart';
import '../../../data/models/product_model.dart';

void showAddProductSheet(BuildContext context) {
  if (!Get.isRegistered<InventoryController>()) {
    // If not registered, we need to register it. 
    // This happens if we call it from Dashboard without visiting Inventory first.
    // However, it's better to handle this in bindings.
    // For now, let's just find it or show an error.
    try {
      Get.find<InventoryController>();
    } catch (e) {
      Get.snackbar("Lỗi", "Hệ thống kho chưa sẵn sàng. Vui lòng vào màn hình Kho hàng trước.");
      return;
    }
  }

  final ctrl = Get.find<InventoryController>();
  final nameCtrl = TextEditingController();
  final skuCtrl = TextEditingController();
  final barcodeCtrl = TextEditingController();
  final stockCtrl = TextEditingController(text: '0');
  final minStockCtrl = TextEditingController(text: '10');
  final maxStockCtrl = TextEditingController(text: '1000');
  final weightCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final RxString base64Image = ''.obs;
  
  int? selCatId;
  int? selUnitId;
  int? selWarehouseId = ctrl.selectedWarehouseId.value;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_box_outlined, color: AppTheme.primaryColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text('Thêm sản phẩm mới', style: AppTheme.headlineStyle.copyWith(fontSize: 17)),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                decoration: const InputDecoration(labelText: 'Tên sản phẩm *'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: skuCtrl,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                      decoration: const InputDecoration(labelText: 'Mã SKU (Để trống tự tạo)'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: barcodeCtrl,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                      decoration: const InputDecoration(labelText: 'Barcode'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Danh mục *'),
                      dropdownColor: AppTheme.elevatedColor,
                      items: ctrl.categories.map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name, style: const TextStyle(fontSize: 13, fontFamily: 'Inter', color: Colors.white70)),
                      )).toList(),
                      onChanged: (v) => selCatId = v,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Đơn vị *'),
                      dropdownColor: AppTheme.elevatedColor,
                      items: ctrl.units.map((u) => DropdownMenuItem(
                        value: u.id,
                        child: Text(u.name, style: const TextStyle(fontSize: 13, fontFamily: 'Inter', color: Colors.white70)),
                      )).toList(),
                      onChanged: (v) => selUnitId = v,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<int>(
                      isExpanded: true,
                      value: selWarehouseId == 0 ? null : selWarehouseId,
                      decoration: const InputDecoration(labelText: 'Kho nhập ban đầu *'),
                      dropdownColor: AppTheme.elevatedColor,
                      items: ctrl.warehouses.map((w) => DropdownMenuItem(
                        value: w.id,
                        child: Text(w.name, style: const TextStyle(fontSize: 13, fontFamily: 'Inter', color: Colors.white70)),
                      )).toList(),
                      onChanged: (v) => selWarehouseId = v,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: stockCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                      decoration: const InputDecoration(labelText: 'SL ban đầu'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minStockCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                      decoration: const InputDecoration(labelText: 'Tồn tối thiểu'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: maxStockCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                      decoration: const InputDecoration(labelText: 'Tồn tối đa'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: weightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                      decoration: const InputDecoration(labelText: 'Trọng lượng'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        border: Border.all(color: AppTheme.borderColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: base64Image.value.isEmpty 
                          ? const Center(child: Text('Chưa có ảnh', style: TextStyle(color: Colors.white54, fontSize: 12)))
                          : Image.memory(
                              base64Decode(base64Image.value.split(',').last),
                              fit: BoxFit.cover,
                            ),
                    )),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      foregroundColor: AppTheme.primaryColor,
                      elevation: 0,
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: () async {
                      try {
                        print("===== [LOG] ĐANG MỞ THƯ VIỆN ẢNH =====");
                        final picker = ImagePicker();
                        final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
                        if (file != null) {
                          print("===== [LOG] CHỌN ẢNH THÀNH CÔNG: ${file.path} =====");
                          final bytes = await file.readAsBytes();
                          final b64 = base64Encode(bytes);
                          base64Image.value = 'data:image/jpeg;base64,$b64';
                          print("===== [LOG] ĐÃ LOAD ẢNH LÊN GIAO DIỆN =====");
                        } else {
                          print("===== [LOG] NGƯỜI DÙNG HỦY CHỌN ẢNH =====");
                        }
                      } catch (e) {
                        print("===== [LOG LỖI CHỌN ẢNH] $e =====");
                        Get.snackbar("Lỗi Ảnh", "Không thể lấy ảnh từ máy: $e", backgroundColor: Colors.red, colorText: Colors.white);
                      }
                    },
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('Chọn ảnh', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                decoration: const InputDecoration(labelText: 'Mô tả chi tiết'),
              ),
              const SizedBox(height: 28),
              Obx(() => ZenithButton(
                label: 'LƯU SẢN PHẨM',
                isLoading: ctrl.isLoading.value,
                icon: Icons.save_outlined,
                onPressed: () {
                  if (nameCtrl.text.isEmpty || selCatId == null || selWarehouseId == null || selWarehouseId == 0) {
                    Get.snackbar('Thiếu thông tin', 'Vui lòng nhập Tên, Danh mục và Kho');
                    return;
                  }
                  
                  final skuText = skuCtrl.text.trim();
                  final finalSku = skuText.isEmpty 
                      ? 'SKU-${DateTime.now().millisecondsSinceEpoch}' 
                      : skuText;

                  ctrl.addProduct(
                    name: nameCtrl.text.trim(),
                    sku: finalSku,
                    categoryId: selCatId!,
                    unitId: selUnitId,
                    initialQuantity: int.tryParse(stockCtrl.text) ?? 0,
                    description: descCtrl.text.trim(),
                    barcode: barcodeCtrl.text.trim(),
                    minStock: int.tryParse(minStockCtrl.text) ?? 10,
                    maxStock: int.tryParse(maxStockCtrl.text) ?? 1000,
                    weight: double.tryParse(weightCtrl.text),
                    imageUrl: base64Image.value.isEmpty ? null : base64Image.value,
                    warehouseId: selWarehouseId,
                  );
                },
              )),
            ],
          ),
        ),
      ),
    ),
  );
}

void showEditProductSheet(BuildContext context, Product product) {
  final ctrl = Get.find<InventoryController>();
  final nameCtrl = TextEditingController(text: product.name);
  final descCtrl = TextEditingController(text: product.description ?? '');
  final minStockCtrl = TextEditingController(text: product.minStockLevel.toString());

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text('Chỉnh sửa sản phẩm', style: AppTheme.headlineStyle.copyWith(fontSize: 17)),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                decoration: const InputDecoration(labelText: 'Tên sản phẩm *'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: minStockCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                decoration: const InputDecoration(labelText: 'Tồn tối thiểu'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                decoration: const InputDecoration(labelText: 'Mô tả chi tiết'),
              ),
              const SizedBox(height: 28),
              Obx(() => ZenithButton(
                label: 'CẬP NHẬT',
                isLoading: ctrl.isLoading.value,
                icon: Icons.check_circle_outline,
                onPressed: () {
                  if (nameCtrl.text.isEmpty) {
                    Get.snackbar('Lỗi', 'Vui lòng nhập tên sản phẩm');
                    return;
                  }
                  ctrl.editProduct(
                    product,
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    minStock: int.tryParse(minStockCtrl.text) ?? 10,
                  );
                },
              )),
            ],
          ),
        ),
      ),
    ),
  );
}
