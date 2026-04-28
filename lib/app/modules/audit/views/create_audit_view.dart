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
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('TẠO PHIÊN KIỂM KÊ'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppTheme.borderColor)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ZenithCard(
                    borderColor: AppTheme.infoColor.withOpacity(0.2),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.infoColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.info_outline, color: AppTheme.infoColor, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Kiểm kê giúp đối soát số lượng thực tế với hệ thống. Nếu có chênh lệch, hệ thống sẽ tự động điều chỉnh.',
                            style: AppTheme.captionStyle.copyWith(fontSize: 12, height: 1.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Chọn kho *', style: AppTheme.labelStyle.copyWith(color: Colors.white60)),
                  const SizedBox(height: 8),
                  Obx(() => DropdownButtonFormField<Warehouse>(
                    value: controller.selectedWarehouse.value,
                    isExpanded: true,
                    dropdownColor: AppTheme.elevatedColor,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.warehouse_outlined, size: 18)),
                    items: controller.warehouses.map((w) =>
                        DropdownMenuItem(value: w, child: Text(w.name, style: const TextStyle(fontFamily: 'Inter', color: Colors.white70)))).toList(),
                    onChanged: (w) => controller.selectedWarehouse.value = w,
                  )),
                  const SizedBox(height: 16),
                  Text('Chọn sản phẩm *', style: AppTheme.labelStyle.copyWith(color: Colors.white60)),
                  const SizedBox(height: 8),
                  Obx(() => DropdownButtonFormField<Product>(
                    value: controller.selectedProduct.value,
                    isExpanded: true,
                    dropdownColor: AppTheme.elevatedColor,
                    hint: const Text('Tìm sản phẩm...', style: TextStyle(color: Color(0xFF546E7A))),
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.inventory_2_outlined, size: 18)),
                    items: controller.allProducts.map((p) => DropdownMenuItem(
                      value: p,
                      child: Text('${p.name} (${p.sku})', style: const TextStyle(fontSize: 13, fontFamily: 'Inter', color: Colors.white70)),
                    )).toList(),
                    onChanged: (p) { if (p != null) controller.onProductSelected(p); },
                  )),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.selectedProduct.value == null) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chọn lô hàng *', style: AppTheme.labelStyle.copyWith(color: Colors.white60)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<Batch>(
                          value: controller.selectedBatch.value,
                          isExpanded: true,
                          dropdownColor: AppTheme.elevatedColor,
                          hint: const Text('Chọn lô hàng'),
                          decoration: const InputDecoration(prefixIcon: Icon(Icons.archive_outlined, size: 18)),
                          items: controller.batchesForProduct.map((b) => DropdownMenuItem(
                            value: b,
                            child: Text('${b.batchCode} — Còn: ${b.currentQuantity}',
                                style: const TextStyle(fontSize: 13, fontFamily: 'Inter', color: Colors.white70)),
                          )).toList(),
                          onChanged: (b) { if (b != null) controller.onBatchSelected(b); },
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
                          borderColor: variance == 0
                              ? AppTheme.successColor.withOpacity(0.2)
                              : AppTheme.warningColor.withOpacity(0.2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _DataPill(
                                icon: Icons.archive_outlined,
                                label: 'HỆ THỐNG',
                                value: '$systemQty',
                                color: AppTheme.accentColor,
                              ),
                              Icon(Icons.compare_arrows_rounded, color: Colors.white24, size: 24),
                              _DataPill(
                                icon: Icons.balance_outlined,
                                label: 'CHÊNH LỆCH',
                                value: variance == 0 ? 'KHỚP' : (variance > 0 ? '+$variance' : '$variance'),
                                color: variance == 0
                                    ? AppTheme.successColor
                                    : (variance > 0 ? AppTheme.accentColor : AppTheme.dangerColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text('Số lượng thực tế *', style: AppTheme.labelStyle.copyWith(color: Colors.white60)),
                        const SizedBox(height: 10),
                        ZenithCard(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: Row(
                            children: [
                              _AuditQtyBtn(
                                icon: Icons.remove_rounded,
                                color: AppTheme.dangerColor,
                                onTap: () { if (controller.actualQty.value > 0) controller.actualQty.value--; },
                              ),
                              Expanded(
                                child: Obx(() => Text(
                                  '${controller.actualQty.value}',
                                  textAlign: TextAlign.center,
                                  style: AppTheme.numberStyle.copyWith(fontSize: 36),
                                )),
                              ),
                              _AuditQtyBtn(
                                icon: Icons.add_rounded,
                                color: AppTheme.successColor,
                                onTap: () => controller.actualQty.value++,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }),
                  Obx(() {
                    final batch = controller.selectedBatch.value;
                    if (batch == null) return const SizedBox.shrink();
                    final variance = controller.actualQty.value - batch.currentQuantity;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          variance != 0 ? 'Lý do chênh lệch *' : 'Ghi chú (tuỳ chọn)',
                          style: AppTheme.labelStyle.copyWith(color: Colors.white60),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: reasonCtrl,
                          maxLines: 2,
                          style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                          decoration: InputDecoration(
                            hintText: variance != 0 ? 'Giải thích lý do chênh lệch...' : 'Ghi chú thêm nếu cần',
                            prefixIcon: const Icon(Icons.notes_rounded, size: 18),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceColor,
              border: Border(top: BorderSide(color: AppTheme.borderColor)),
            ),
            child: Obx(() => ZenithButton(
              label: 'CHỐT SỔ KIỂM KÊ',
              icon: Icons.check_circle_outline,
              isLoading: controller.isSubmitting.value,
              onPressed: () => controller.submitAudit(reason: reasonCtrl.text.trim()),
            )),
          ),
        ],
      ),
    );
  }
}

class _AuditQtyBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _AuditQtyBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, size: 22, color: color),
      ),
    );
  }
}

class _DataPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _DataPill({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 9, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
              Text(value, style: TextStyle(color: color, fontSize: 13, fontFamily: 'JetBrains Mono', fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
