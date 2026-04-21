import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../core/global_styles.dart';
import '../controllers/inventory_controller.dart';
import '../../../data/models/product_model.dart';
import '../../../routes/app_pages.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KHO HÀNG"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.accentColor),
            onPressed: controller.fetchData,
          ),
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: AppTheme.primaryColor),
            onPressed: () => _showAddProductSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.products.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
              }
              final list = controller.filteredProducts;
              if (list.isEmpty) {
                return const EmptyState(
                  message: "Không tìm thấy sản phẩm nào",
                  icon: Icons.inventory_2_outlined,
                );
              }
              return RefreshIndicator(
                color: AppTheme.primaryColor,
                backgroundColor: AppTheme.cardColor,
                onRefresh: controller.fetchData,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => FadeSlideItem(
                    index: i,
                    child: _ProductCard(product: list[i], controller: controller),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        onChanged: controller.onSearchChanged,
        decoration: InputDecoration(
          hintText: "Tìm kiếm tên sản phẩm, SKU...",
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white38),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white38, size: 18),
                  onPressed: () {
                    controller.searchQuery.value = '';
                  },
                )
              : const SizedBox.shrink()),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 44,
      child: Obx(() => ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: controller.categories.length + 1,
        itemBuilder: (_, i) {
          final isAll = i == 0;
          final cat   = isAll ? null : controller.categories[i - 1];
          final catId = isAll ? 0 : cat!.id;
          return Obx(() {
            final sel = controller.selectedCategoryId.value == catId;
            return _CategoryChip(
              label: isAll ? 'Tất cả' : (cat?.name ?? ''),
              isSelected: sel,
              onTap: () => controller.setCategory(catId),
            );
          });
        },
      )),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final InventoryController controller;

  const _ProductCard({required this.product, required this.controller});

  @override
  Widget build(BuildContext context) {
    final status = product.stockStatus;
    Color statusColor = switch (status) {
      StockStatus.normal   => AppTheme.primaryColor,
      StockStatus.low      => AppTheme.warningColor,
      StockStatus.outOfStock => AppTheme.dangerColor,
    };
    String statusLabel = switch (status) {
      StockStatus.normal   => "BÌNH THƯỜNG",
      StockStatus.low      => "SẮP HẾT",
      StockStatus.outOfStock => "HẾT HÀNG",
    };

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.PRODUCT_DETAIL, arguments: product.id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.cardDecoration(
          borderColor: status != StockStatus.normal ? statusColor.withOpacity(0.3) : null,
        ).copyWith(boxShadow: AppTheme.luxuryShadow),
        child: Row(
          children: [

            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withOpacity(0.15)),
              ),
              child: Icon(Icons.inventory_2_rounded, color: statusColor, size: 28),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: AppTheme.titleStyle.copyWith(fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(product.sku, style: AppTheme.labelStyle.copyWith(fontSize: 9)),
                      ),
                      const SizedBox(width: 8),
                      if (product.categoryName != null)
                        Text(product.categoryName!, style: AppTheme.captionStyle.copyWith(fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ZenithBadge(label: '${product.currentStock} ${product.unitName ?? ""}', color: statusColor),
                const SizedBox(height: 6),
                ZenithBadge(label: statusLabel, color: statusColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.18) : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.06),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryColor : Colors.white54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

void _showAddProductSheet(BuildContext context) {
  final ctrl = Get.find<InventoryController>();
  final nameCtrl  = TextEditingController();
  final skuCtrl   = TextEditingController();
  final stockCtrl = TextEditingController(text: '0');
  final descCtrl  = TextEditingController();
  int? selCatId;
  int? selUnitId;

  Get.bottomSheet(
    StatefulBuilder(builder: (ctx, setState) {
      return Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        decoration: const BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.add_box_outlined, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Text("Thêm sản phẩm mới", style: AppTheme.headlineStyle.copyWith(fontSize: 18)),
                ],
              ),
              const SizedBox(height: 24),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Tên sản phẩm *")),
              const SizedBox(height: 12),
              TextField(controller: skuCtrl, decoration: const InputDecoration(labelText: "Mã SKU *")),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: "Danh mục"),
                      dropdownColor: AppTheme.elevatedColor,
                      items: ctrl.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (v) => selCatId = v,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: "Đơn vị"),
                      dropdownColor: AppTheme.elevatedColor,
                      items: ctrl.units.map((u) => DropdownMenuItem(value: u.id, child: Text(u.name, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (v) => selUnitId = v,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Tồn kho ban đầu")),
              const SizedBox(height: 12),
              TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: "Mô tả")),
              const SizedBox(height: 28),
              Obx(() => ZenithButton(
                label: "LƯU SẢN PHẨM",
                isLoading: ctrl.isLoading.value,
                onPressed: () {
                  if (nameCtrl.text.isEmpty || skuCtrl.text.isEmpty || selCatId == null || selUnitId == null) {
                    Get.snackbar("Thiếu thông tin", "Vui lòng nhập đầy đủ các trường bắt buộc *");
                    return;
                  }
                  ctrl.addProduct(
                    name: nameCtrl.text.trim(),
                    sku: skuCtrl.text.trim(),
                    categoryId: selCatId!,
                    unitId: selUnitId!,
                    initialQuantity: int.tryParse(stockCtrl.text) ?? 0,
                    description: descCtrl.text.trim(),
                  );
                },
              )),
            ],
          ),
        ),
      );
    }),
    isScrollControlled: true,
  );
}
