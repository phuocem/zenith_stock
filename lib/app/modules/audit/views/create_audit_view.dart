import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/audit_controller.dart';
import '../../../core/theme.dart';
import '../../../core/global_styles.dart';
import '../../../data/models/product_model.dart';

class CreateAuditView extends GetView<AuditController> {
  const CreateAuditView({super.key});
  @override
  Widget build(BuildContext context) {
    final reasonCtrl = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text("TẠO PHIÊN KIỂM KÊ")),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ZenithCard(
                    padding: const EdgeInsets.all(14),
                    borderColor: AppTheme.primaryColor.withOpacity(0.2),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Kiểm kê giúp đối soát số lượng thực tế với hệ thống. Nếu có chênh lệch, hệ thống sẽ tự động điều chỉnh.",
                            style: AppTheme.captionStyle.copyWith(
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text("Chọn kho *", style: AppTheme.labelStyle),
                  const SizedBox(height: 8),
                  Obx(
                    () => DropdownButtonFormField<Warehouse>(
                      value: controller.selectedWarehouse.value,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.warehouse_outlined),
                      ),
                      dropdownColor: AppTheme.elevatedColor,
                      items: controller.warehouses
                          .map(
                            (w) =>
                                DropdownMenuItem(value: w, child: Text(w.name)),
                          )
                          .toList(),
                      onChanged: (w) => controller.selectedWarehouse.value = w,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text("Chọn sản phẩm *", style: AppTheme.labelStyle),
                  const SizedBox(height: 8),
                  Obx(
                    () => DropdownButtonFormField<Product>(
                      value: controller.selectedProduct.value,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.inventory_2_outlined),
                      ),
                      dropdownColor: AppTheme.elevatedColor,
                      hint: const Text("Tìm sản phẩm..."),
                      items: controller.allProducts
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(
                                '${p.name} (${p.sku})',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (p) {
                        if (p != null) controller.onProductSelected(p);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.selectedProduct.value == null)
                      return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Chọn lô hàng *", style: AppTheme.labelStyle),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<Batch>(
                          value: controller.selectedBatch.value,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.archive_outlined),
                          ),
                          dropdownColor: AppTheme.elevatedColor,
                          hint: const Text("Chọn lô hàng"),
                          items: controller.batchesForProduct
                              .map(
                                (b) => DropdownMenuItem(
                                  value: b,
                                  child: Text(
                                    '${b.batchCode} — Còn: ${b.currentQuantity}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (b) {
                            if (b != null) controller.onBatchSelected(b);
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }),
                  Obx(() {
                    final batch = controller.selectedBatch.value;
                    if (batch == null) return const SizedBox.shrink();
                    final systemQty = batch.currentQuantity;
                    final actualQty = controller.actualQty.value;
                    final variance = actualQty - systemQty;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ZenithCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "SỐ LƯỢNG HỆ THỐNG",
                                    style: AppTheme.labelStyle,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$systemQty',
                                    style: AppTheme.numberStyle.copyWith(
                                      color: AppTheme.accentColor,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(
                                Icons.compare_arrows_rounded,
                                color: Colors.white24,
                                size: 28,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "CHÊNH LỆCH",
                                    style: AppTheme.labelStyle,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    variance == 0
                                        ? "KHỚP"
                                        : (variance > 0
                                              ? "+$variance"
                                              : "$variance"),
                                    style: AppTheme.numberStyle.copyWith(
                                      fontSize: 20,
                                      color: variance == 0
                                          ? AppTheme.successColor
                                          : (variance > 0
                                                ? AppTheme.accentColor
                                                : AppTheme.dangerColor),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text("Số lượng thực tế *", style: AppTheme.labelStyle),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                color: AppTheme.dangerColor,
                                size: 32,
                              ),
                              onPressed: () {
                                if (controller.actualQty.value > 0) {
                                  controller.actualQty.value--;
                                }
                              },
                            ),
                            Expanded(
                              child: ZenithCard(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Text(
                                  '${controller.actualQty.value}',
                                  textAlign: TextAlign.center,
                                  style: AppTheme.numberStyle.copyWith(
                                    fontSize: 32,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle,
                                color: AppTheme.successColor,
                                size: 32,
                              ),
                              onPressed: () => controller.actualQty.value++,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }),
                  Obx(() {
                    final batch = controller.selectedBatch.value;
                    if (batch == null) return const SizedBox.shrink();
                    final variance =
                        controller.actualQty.value - batch.currentQuantity;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          variance != 0
                              ? "Lý do chênh lệch *"
                              : "Ghi chú (tuỳ chọn)",
                          style: AppTheme.labelStyle,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: reasonCtrl,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: variance != 0
                                ? "Giải thích lý do chênh lệch..."
                                : "Ghi chú thêm nếu cần",
                            prefixIcon: const Icon(Icons.notes_rounded),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.06)),
              ),
            ),
            child: Obx(
              () => ZenithButton(
                label: "CHỐT SỔ KIỂM KÊ",
                isLoading: controller.isSubmitting.value,
                icon: Icons.check_circle_outline,
                onPressed: () =>
                    controller.submitAudit(reason: reasonCtrl.text.trim()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
