import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import '../controllers/inventory_controller.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KHO HÀNG ZENITH"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_box_outlined,
              color: AppTheme.primaryColor,
            ),
            onPressed: () => _showAddProductDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategorySelector(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                );
              }
              final displayProducts = controller.filteredProducts;
              if (displayProducts.isEmpty) {
                return const Center(
                  child: Text(
                    "Chưa có sản phẩm nào",
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: displayProducts.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = displayProducts[index];
                  // Thêm hiệu ứng xuất hiện mượt mà (Fade + Slide)
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 400 + (index % 10 * 100)),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: _buildProductCard(product),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Tìm kiếm sản phẩm, SKU...",
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          filled: true,
          fillColor: AppTheme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 45,
      margin: const EdgeInsets.only(bottom: 12),
      child: Obx(() {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: controller.categories.length + 1,
          itemBuilder: (context, index) {
            final isAll = index == 0;
            final category = isAll ? null : controller.categories[index - 1];
            final categoryId = isAll ? 0 : category['id'];

            // LỒNG THÊM OBX Ở ĐÂY - Mé mày phải có Obx ở từng nút thì màu nó mới nhảy
            return Obx(() {
              final isSelected = controller.selectedCategoryId.value == categoryId;
              return _CategoryItem(
                label: isAll ? "Tất cả" : (category['name'] ?? ""),
                isSelected: isSelected,
                onTap: () => controller.setCategory(categoryId),
              );
            });
          },
        );
      }),
    );
  }
}

class _CategoryItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<_CategoryItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0, // Hiệu ứng nhấn lún
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.primaryColor.withOpacity(0.2)
                : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isSelected
                  ? AppTheme.primaryColor
                  : Colors.white.withOpacity(0.05),
              width: 1.5,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isSelected ? AppTheme.primaryColor : Colors.white60,
              fontWeight: widget.isSelected
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildProductCard(Map<String, dynamic> product) {
  final totalStock = product['current_stock'] ?? 0;
  final isLowStock = totalStock <= (product['min_stock_level'] ?? 0);

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: AppTheme.glassDecoration(opacity: 0.04).copyWith(
      boxShadow: AppTheme.luxuryShadow,
    ),
    child: Row(
      children: [
        // Ảnh / Icon sản phẩm với khung Glow
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.inventory_2_rounded,
                color: isLowStock ? Colors.orangeAccent : AppTheme.primaryColor,
                size: 30,
              ),
              if (isLowStock)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.orangeAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Thông tin sản phẩm
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product['name'],
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product['sku'],
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    product['categories']?['name'] ?? 'Không',
                    style: const TextStyle(color: Colors.white24, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Tồn kho & Actions
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isLowStock 
                    ? Colors.orangeAccent.withOpacity(0.1) 
                    : AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isLowStock 
                      ? Colors.orangeAccent.withOpacity(0.2) 
                      : AppTheme.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Text(
                "$totalStock ${product['units']?['name'] ?? 'pcs'}",
                style: GoogleFonts.outfit(
                  color: isLowStock ? Colors.orangeAccent : AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Icon(Icons.chevron_right_rounded, color: Colors.white12, size: 20),
          ],
        ),
      ],
    ),
  );
}

void _showAddProductDialog(BuildContext context) {
  final controller = Get.find<InventoryController>();
  final nameController = TextEditingController();
  final skuController = TextEditingController();
  final stockController = TextEditingController(text: "0");
  final descController = TextEditingController();

  int? selectedCategoryId;
  int? selectedUnitId;

  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Thêm sản phẩm mới",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Tên sản phẩm *"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: skuController,
              decoration: const InputDecoration(labelText: "Mã SKU *"),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    isExpanded: true, // Thêm cái này để không bị tràn
                    decoration: const InputDecoration(labelText: "Danh mục"),
                    dropdownColor: AppTheme.cardColor,
                    items: controller.categories
                        .map((c) => DropdownMenuItem<int>(
                              value: c['id'],
                              child: Text(c['name'],
                                  overflow: TextOverflow.ellipsis, // Cắt bớt nếu quá dài
                                  style: const TextStyle(fontSize: 13)),
                            ))
                        .toList(),
                    onChanged: (val) => selectedCategoryId = val,
                  ),
                ),
                const SizedBox(width: 8), // Giảm khoảng cách từ 16 xuống 8
                Expanded(
                  child: DropdownButtonFormField<int>(
                    isExpanded: true, // Thêm cái này để không bị tràn
                    decoration: const InputDecoration(labelText: "Đơn vị"),
                    dropdownColor: AppTheme.cardColor,
                    items: controller.units
                        .map((u) => DropdownMenuItem<int>(
                              value: u['id'],
                              child: Text(u['name'],
                                  overflow: TextOverflow.ellipsis, // Cắt bớt nếu quá dài
                                  style: const TextStyle(fontSize: 13)),
                            ))
                        .toList(),
                    onChanged: (val) => selectedUnitId = val,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Số lượng tồn kho ban đầu"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: "Mô tả ngắn"),
            ),
            const SizedBox(height: 32),
            Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          if (nameController.text.isEmpty ||
                              skuController.text.isEmpty ||
                              selectedCategoryId == null ||
                              selectedUnitId == null) {
                            Get.snackbar("Lỗi", "Vui lòng nhập đầy đủ thông tin bắt buộc");
                            return;
                          }
                          controller.addProduct(
                            name: nameController.text,
                            sku: skuController.text,
                            categoryId: selectedCategoryId!,
                            unitId: selectedUnitId!,
                            initialQuantity:
                                int.tryParse(stockController.text) ?? 0,
                            description: descController.text,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text("LƯU SẢN PHẨM"),
                )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}
