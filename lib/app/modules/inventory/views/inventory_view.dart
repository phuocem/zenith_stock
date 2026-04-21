import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppTheme.accentColor,
            ),
            onPressed: controller.fetchData,
          ),
          IconButton(
            icon: const Icon(
              Icons.add_box_outlined,
              color: AppTheme.primaryColor,
            ),
            onPressed: () => _showAddProductSheet(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingWarehouses.value) {
          return Column(
            children: [
              _buildWarehouseFilter(),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          );
        }
        if (!controller.warehouseSelected.value) {
          return Column(
            children: [
              _buildWarehouseFilter(),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warehouse_outlined,
                          size: 52,
                          color: AppTheme.accentColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Chọn kho để xem sản phẩm",
                        style: TextStyle(color: Colors.white60, fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Nhấn vào một kho ở trên để bắt đầu",
                        style: TextStyle(color: Colors.white30, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            _buildWarehouseFilter(),
            _buildSearchBar(),
            _buildCategoryFilter(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.products.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  );
                }
                final list = controller.filteredProducts;
                if (list.isEmpty) {
                  return EmptyState(
                    message: "Không có sản phẩm trong kho này",
                    icon: Icons.inventory_2_outlined,
                    actionLabel: "Thêm sản phẩm",
                    onAction: () => _showAddProductSheet(context),
                  );
                }
                return RefreshIndicator(
                  color: AppTheme.primaryColor,
                  backgroundColor: AppTheme.cardColor,
                  onRefresh: controller.fetchProducts,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => FadeSlideItem(
                      index: i,
                      child: _ProductCard(
                        product: list[i],
                        controller: controller,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      }),
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
          suffixIcon: Obx(
            () => controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.white38,
                      size: 18,
                    ),
                    onPressed: () {
                      controller.searchQuery.value = '';
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 44,
      child: Obx(
        () => ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: controller.categories.length + 1,
          itemBuilder: (_, i) {
            final isAll = i == 0;
            final cat = isAll ? null : controller.categories[i - 1];
            final catId = isAll ? 0 : cat!.id;
            final sel = controller.selectedCategoryId.value == catId;
            return _FilterChip(
              label: isAll ? 'Tất cả' : (cat?.name ?? ''),
              isSelected: sel,
              onTap: () => controller.setCategory(catId),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWarehouseFilter() {
    return Obx(() {
      if (controller.warehouses.isEmpty &&
          !controller.isLoadingWarehouses.value) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppTheme.cardColor,
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white38, size: 16),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Chưa được phân công kho nào",
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
              TextButton(
                onPressed: controller.fetchData,
                child: const Text(
                  "Thử lại",
                  style: TextStyle(color: AppTheme.accentColor, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      }
      if (controller.warehouses.isEmpty) return const SizedBox.shrink();
      return SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: controller.warehouses.length,
          itemBuilder: (_, i) {
            final wh = controller.warehouses[i];
            final sel = controller.selectedWarehouseId.value == wh.id;
            return _FilterChip(
              label: wh.name,
              isSelected: sel,
              activeColor: AppTheme.accentColor,
              onTap: () => controller.setWarehouse(wh.id),
            );
          },
        ),
      );
    });
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
      StockStatus.normal => AppTheme.primaryColor,
      StockStatus.low => AppTheme.warningColor,
      StockStatus.outOfStock => AppTheme.dangerColor,
    };
    String statusLabel = switch (status) {
      StockStatus.normal => "BÌNH THƯỜNG",
      StockStatus.low => "SẮP HẾT",
      StockStatus.outOfStock => "HẾT HÀNG",
    };
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.PRODUCT_DETAIL, arguments: product.id),
      onLongPress: () => _showProductOptions(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.cardDecoration(
          borderColor: statusColor.withOpacity(0.15),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                color: statusColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTheme.titleStyle.copyWith(fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.sku,
                          style: AppTheme.labelStyle.copyWith(fontSize: 9),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (product.categoryName != null)
                        Flexible(
                          child: Text(
                            product.categoryName!,
                            style: AppTheme.captionStyle.copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ZenithBadge(
                  label: '${product.currentStock} ${product.unitName ?? ""}',
                  color: statusColor,
                ),
                const SizedBox(height: 6),
                ZenithBadge(label: statusLabel, color: statusColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProductOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              product.name,
              style: AppTheme.titleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(
                Icons.edit_outlined,
                color: AppTheme.accentColor,
              ),
              title: const Text(
                'Chỉnh sửa thông tin',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Get.back();
                _showEditSheet(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.archive_outlined,
                color: AppTheme.warningColor,
              ),
              title: const Text(
                'Ngừng kinh doanh',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Sản phẩm vẫn được lưu trong hệ thống',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
              onTap: () {
                Get.back();
                controller.archiveProduct(product);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    final nameCtrl = TextEditingController(text: product.name);
    final descCtrl = TextEditingController(text: product.description ?? '');
    final minCtrl = TextEditingController(
      text: (product.minStockLevel ?? 0).toString(),
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Chỉnh sửa: ${product.name}',
              style: AppTheme.titleStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Mô tả'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: minCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Tồn kho tối thiểu'),
            ),
            const SizedBox(height: 20),
            Obx(
              () => ZenithButton(
                label: 'LƯU THAY ĐỔI',
                isLoading: controller.isLoading.value,
                onPressed: () => controller.editProduct(
                  product,
                  name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  minStock: int.tryParse(minCtrl.text) ?? 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? activeColor;
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.activeColor,
  });
  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppTheme.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.18) : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.06),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.white54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

void _showAddProductSheet(BuildContext context) {
  final ctrl = Get.find<InventoryController>();
  final nameCtrl = TextEditingController();
  final skuCtrl = TextEditingController();
  final stockCtrl = TextEditingController(text: '0');
  final descCtrl = TextEditingController();
  int? selCatId;
  int? selUnitId;
  Get.bottomSheet(
    StatefulBuilder(
      builder: (ctx, setState) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
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
                    const Icon(
                      Icons.add_box_outlined,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Thêm sản phẩm mới",
                      style: AppTheme.headlineStyle.copyWith(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Tên sản phẩm *",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: skuCtrl,
                  decoration: const InputDecoration(labelText: "Mã SKU *"),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: "Danh mục",
                        ),
                        dropdownColor: AppTheme.elevatedColor,
                        items: ctrl.categories
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(
                                  c.name,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => selCatId = v,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: "Đơn vị"),
                        dropdownColor: AppTheme.elevatedColor,
                        items: ctrl.units
                            .map(
                              (u) => DropdownMenuItem(
                                value: u.id,
                                child: Text(
                                  u.name,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => selUnitId = v,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Tồn kho ban đầu",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: "Mô tả"),
                ),
                const SizedBox(height: 28),
                Obx(
                  () => ZenithButton(
                    label: "LƯU SẢN PHẨM",
                    isLoading: ctrl.isLoading.value,
                    onPressed: () {
                      if (nameCtrl.text.isEmpty ||
                          skuCtrl.text.isEmpty ||
                          selCatId == null ||
                          selUnitId == null) {
                        Get.snackbar(
                          "Thiếu thông tin",
                          "Vui lòng nhập đầy đủ các trường bắt buộc *",
                        );
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
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
    isScrollControlled: true,
  );
}
