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
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        title: Obx(() {
          final whId = controller.selectedWarehouseId.value;
          final wh = controller.warehouses.firstWhereOrNull((w) => w.id == whId);
          return Text(wh?.name ?? 'KHO HÀNG');
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.accentColor),
            onPressed: controller.fetchData,
          ),
          _AddProductButton(context: context),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.borderColor),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingWarehouses.value) {
          return Column(
            children: [
              _WarehouseFilter(controller: controller),
              const Expanded(child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))),
            ],
          );
        }
        if (!controller.warehouseSelected.value) {
          return Column(
            children: [
              _WarehouseFilter(controller: controller),
              Expanded(child: _NoWarehouseSelected()),
            ],
          );
        }
        return Column(
          children: [
            _WarehouseFilter(controller: controller),
            _InventorySummary(controller: controller),
            _SearchBar(controller: controller),
            _CategoryChips(controller: controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                }
                final list = controller.filteredProducts;
                if (list.isEmpty) {
                  return EmptyState(
                    message: 'Không có sản phẩm trong kho này',
                    icon: Icons.inventory_2_outlined,
                    actionLabel: 'Thêm sản phẩm',
                    onAction: () => _showAddProductSheet(context),
                  );
                }
                return RefreshIndicator(
                  color: AppTheme.primaryColor,
                  backgroundColor: AppTheme.cardColor,
                  onRefresh: controller.fetchProducts,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
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
        );
      }),
    );
  }
}

class _AddProductButton extends StatelessWidget {
  final BuildContext context;
  const _AddProductButton({required this.context});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: FilledButton.icon(
        onPressed: () => _showAddProductSheet(context),
        icon: const Icon(Icons.add_rounded, size: 16),
        label: const Text('Thêm', style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w700)),
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}

class _WarehouseFilter extends StatelessWidget {
  final InventoryController controller;
  const _WarehouseFilter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.warehouses.isEmpty && !controller.isLoadingWarehouses.value) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppTheme.cardColor,
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppTheme.warningColor, size: 16),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Chưa được phân công kho nào',
                    style: TextStyle(color: Color(0xFF607D8B), fontSize: 12, fontFamily: 'Inter')),
              ),
              TextButton(
                onPressed: controller.fetchData,
                child: const Text('Thử lại', style: TextStyle(color: AppTheme.accentColor, fontSize: 12)),
              ),
            ],
          ),
        );
      }
      if (controller.warehouses.isEmpty) return const SizedBox.shrink();

      return Container(
        height: 48,
        color: AppTheme.surfaceColor,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          itemCount: controller.warehouses.length,
          itemBuilder: (_, i) {
            final wh = controller.warehouses[i];
            final sel = controller.selectedWarehouseId.value == wh.id;
            return _WarehouseChip(
              label: wh.name,
              isSelected: sel,
              onTap: () => controller.setWarehouse(wh.id),
            );
          },
        ),
      );
    });
  }
}

class _WarehouseChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _WarehouseChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppTheme.borderColor,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
          ] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warehouse_outlined,
              size: 13,
              color: isSelected ? Colors.black : const Color(0xFF546E7A),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white60,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 12, fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventorySummary extends StatelessWidget {
  final InventoryController controller;
  const _InventorySummary({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.warehouseSelected.value || controller.products.isEmpty) {
        return const SizedBox.shrink();
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          border: Border(bottom: BorderSide(color: AppTheme.borderColor, width: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  _SummaryItem(
                    label: 'SẢN PHẨM',
                    value: '${controller.totalItems}',
                    color: AppTheme.accentColor,
                  ),
                  const SizedBox(width: 24),
                  _SummaryItem(
                    label: 'TỔNG TỒN',
                    value: '${controller.totalStock}',
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
            if (controller.showOnlyLowStock.value)
              GestureDetector(
                onTap: () => controller.showOnlyLowStock.value = false,
                child: ZenithBadge(
                  label: 'SẮP HẾT HÀNG ✕',
                  color: AppTheme.warningColor,
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.labelStyle.copyWith(fontSize: 9, color: Colors.white38)),
        const SizedBox(height: 2),
        Text(value, style: AppTheme.numberStyle.copyWith(fontSize: 16, color: color)),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final InventoryController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
        onChanged: controller.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Tìm tên sản phẩm, SKU...',
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF546E7A), size: 20),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF546E7A), size: 18),
                  onPressed: () => controller.searchQuery.value = '',
                )
              : const SizedBox.shrink()),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final InventoryController controller;
  const _CategoryChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Obx(() => ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
      )),
    );
  }
}

class _NoWarehouseSelected extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlowPulse(
            color: AppTheme.accentColor,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accentColor.withOpacity(0.2)),
              ),
              child: const Icon(Icons.warehouse_outlined, size: 38, color: AppTheme.accentColor),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chọn kho để xem sản phẩm',
            style: TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'Sora', fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nhấn vào một kho ở trên để bắt đầu',
            style: TextStyle(color: Color(0xFF546E7A), fontSize: 12, fontFamily: 'Inter'),
          ),
        ],
      ),
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
      StockStatus.normal => AppTheme.successColor,
      StockStatus.low => AppTheme.warningColor,
      StockStatus.outOfStock => AppTheme.dangerColor,
    };
    String statusLabel = switch (status) {
      StockStatus.normal => 'BÌNH THƯỜNG',
      StockStatus.low => 'SẮP HẾT',
      StockStatus.outOfStock => 'HẾT HÀNG',
    };

    final stockPct = product.maxStockLevel > 0
        ? (product.currentStock / product.maxStockLevel).clamp(0.0, 1.0)
        : 0.0;

    return ZenithCard(
      borderColor: statusColor.withOpacity(status == StockStatus.normal ? 0.06 : 0.2),
      onTap: () => Get.toNamed(Routes.PRODUCT_DETAIL, arguments: product.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.inventory_2_rounded, color: statusColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: AppTheme.titleStyle.copyWith(fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('SKU: ', style: AppTheme.monoStyle.copyWith(fontSize: 10)),
                        Text(product.sku, style: AppTheme.monoStyle.copyWith(
                          fontSize: 10, color: AppTheme.accentColor,
                        )),
                        if (product.categoryName != null) ...[
                          const Text(' · ', style: TextStyle(color: Color(0xFF37474F))),
                          Text(product.categoryName!, style: AppTheme.captionStyle.copyWith(fontSize: 10)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              ZenithBadge(label: statusLabel, color: statusColor, dot: true),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          product.currentStock.toString(),
                          style: AppTheme.numberStyle.copyWith(
                            fontSize: 22, color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/ ${product.maxStockLevel}',
                          style: AppTheme.monoStyle.copyWith(color: const Color(0xFF37474F)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ZenithProgressBar(value: stockPct.toDouble(), color: statusColor),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ContextMenu(product: product, controller: controller),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContextMenu extends StatelessWidget {
  final Product product;
  final InventoryController controller;
  const _ContextMenu({required this.product, required this.controller});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: AppTheme.elevatedColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppTheme.borderColor)),
      icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF546E7A), size: 20),
      onSelected: (v) {
        if (v == 'detail') Get.toNamed(Routes.PRODUCT_DETAIL, arguments: product.id);
        if (v == 'edit') _showEditProductSheet(context, product);
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'detail',
          child: Row(children: [
            Icon(Icons.info_outline, size: 16, color: AppTheme.accentColor),
            SizedBox(width: 8),
            Text('Chi tiết', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white70)),
          ]),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            Icon(Icons.edit_outlined, size: 16, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Chỉnh sửa', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white70)),
          ]),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.15) : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryColor : Colors.white54,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            fontSize: 12, fontFamily: 'Inter',
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
              TextField(
                controller: skuCtrl,
                style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                decoration: const InputDecoration(labelText: 'Mã SKU *'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Danh mục'),
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
                      decoration: const InputDecoration(labelText: 'Đơn vị'),
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
              TextField(
                controller: stockCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                decoration: const InputDecoration(labelText: 'Tồn kho ban đầu'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                decoration: const InputDecoration(labelText: 'Mô tả'),
              ),
              const SizedBox(height: 28),
              Obx(() => ZenithButton(
                label: 'LƯU SẢN PHẨM',
                isLoading: ctrl.isLoading.value,
                icon: Icons.save_outlined,
                onPressed: () {
                  if (nameCtrl.text.isEmpty || skuCtrl.text.isEmpty || selCatId == null || selUnitId == null) {
                    Get.snackbar('Thiếu thông tin', 'Vui lòng nhập đầy đủ các trường bắt buộc *');
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
      ),
    ),
  );
}
void _showEditProductSheet(BuildContext context, Product product) {
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
              const SizedBox(height: 12),
              TextField(
                controller: minStockCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                decoration: const InputDecoration(labelText: 'Tồn kho tối thiểu'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                decoration: const InputDecoration(labelText: 'Mô tả'),
              ),
              const SizedBox(height: 28),
              Obx(() => ZenithButton(
                label: 'CẬP NHẬT',
                isLoading: ctrl.isLoading.value,
                icon: Icons.check_rounded,
                onPressed: () {
                  if (nameCtrl.text.isEmpty) {
                    Get.snackbar('Thiếu thông tin', 'Vui lòng nhập tên sản phẩm');
                    return;
                  }
                  ctrl.editProduct(
                    product,
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    minStock: int.tryParse(minStockCtrl.text) ?? product.minStockLevel,
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
