import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/transaction_controller.dart';
import '../../../core/theme.dart';
import '../../../core/global_styles.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/transaction_model.dart';

class CreateTransactionView extends GetView<TransactionController> {
  const CreateTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final notesCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    final argType = Get.arguments as String?;
    if (argType != null) {
      controller.formType.value = argType;
      controller.draftItems.clear();
    }

    return Obx(() {
      final isIn = controller.formType.value == 'IN';
      final typeColor = isIn ? AppTheme.successColor : AppTheme.dangerColor;
      final typeGradient = isIn ? AppTheme.successGradient : AppTheme.dangerGradient;

      return Scaffold(
        backgroundColor: AppTheme.bgColor,
        appBar: AppBar(
          backgroundColor: AppTheme.surfaceColor,
          title: ShaderMask(
            shaderCallback: (b) => typeGradient.createShader(b),
            child: Text(
              isIn ? 'NHẬP KHO' : 'XUẤT KHO',
              style: const TextStyle(
                fontFamily: 'Sora', fontWeight: FontWeight.w800,
                fontSize: 15, letterSpacing: 2, color: Colors.white,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: Get.back,
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppTheme.borderColor),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WarehouseSelector(typeColor: typeColor),
                    const SizedBox(height: 20),
                    _DraftItemsList(isIn: isIn),
                    const SizedBox(height: 12),
                    _AddProductButton(isIn: isIn, typeColor: typeColor),
                    const SizedBox(height: 20),
                    TextField(
                      controller: notesCtrl,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú (tuỳ chọn)',
                        prefixIcon: Icon(Icons.notes_rounded, size: 18),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: refCtrl,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                      decoration: const InputDecoration(
                        labelText: 'Mã tham chiếu / Số phiếu',
                        prefixIcon: Icon(Icons.tag_rounded, size: 18),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
            _SubmitBar(isIn: isIn, notesCtrl: notesCtrl, refCtrl: refCtrl),
          ],
        ),
      );
    });
  }
}

class _WarehouseSelector extends GetView<TransactionController> {
  final Color typeColor;
  const _WarehouseSelector({required this.typeColor});

  @override
  Widget build(BuildContext context) {
    return ZenithCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderColor: typeColor.withOpacity(0.15),
      child: Row(
        children: [
          Icon(Icons.warehouse_outlined, color: typeColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => DropdownButton<Warehouse>(
              value: controller.selectedWarehouse.value,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              dropdownColor: AppTheme.elevatedColor,
              style: const TextStyle(color: Colors.white, fontFamily: 'Inter', fontSize: 14),
              hint: const Text('Chọn kho', style: TextStyle(color: Color(0xFF546E7A))),
              items: controller.warehouses.map((w) =>
                DropdownMenuItem(value: w, child: Text(w.name)),
              ).toList(),
              onChanged: (w) => controller.selectedWarehouse.value = w,
            )),
          ),
        ],
      ),
    );
  }
}

class _DraftItemsList extends GetView<TransactionController> {
  final bool isIn;
  const _DraftItemsList({required this.isIn});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.draftItems.isEmpty) {
        return ZenithCard(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: Column(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.add_shopping_cart_outlined, size: 28, color: Color(0xFF37474F)),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Chưa có sản phẩm nào\nNhấn nút bên dưới để thêm',
                  style: TextStyle(color: Color(0xFF546E7A), fontSize: 13, fontFamily: 'Inter', height: 1.6),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: '${controller.draftItems.length} sản phẩm',
            trailing: TextButton(
              onPressed: controller.draftItems.clear,
              child: const Text('Xóa tất cả', style: TextStyle(color: AppTheme.dangerColor, fontSize: 12, fontFamily: 'Inter')),
            ),
          ),
          const SizedBox(height: 10),
          ...controller.draftItems.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ZenithCard(
                borderColor: (isIn ? AppTheme.successColor : AppTheme.dangerColor).withOpacity(0.1),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: (isIn ? AppTheme.successColor : AppTheme.dangerColor).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isIn ? Icons.south_west_rounded : Icons.north_east_rounded,
                        color: isIn ? AppTheme.successColor : AppTheme.dangerColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.name, style: AppTheme.titleStyle.copyWith(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('Lô: ${item.batch.batchCode}', style: AppTheme.monoStyle.copyWith(fontSize: 10)),
                          if (!isIn)
                            Text('Còn: ${item.batch.currentQuantity}',
                                style: AppTheme.captionStyle.copyWith(fontSize: 10, color: AppTheme.warningColor)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _QtyBtn(
                          icon: Icons.remove_rounded,
                          color: AppTheme.dangerColor,
                          onTap: () {
                            if (item.quantity > 1) controller.updateDraftQty(i, item.quantity - 1);
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Text(
                            '${item.quantity}',
                            style: AppTheme.numberStyle.copyWith(fontSize: 16),
                          ),
                        ),
                        _QtyBtn(
                          icon: Icons.add_rounded,
                          color: AppTheme.successColor,
                          onTap: () => controller.updateDraftQty(i, item.quantity + 1),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => controller.draftItems.removeAt(i),
                          child: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: AppTheme.dangerColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.close_rounded, size: 14, color: AppTheme.dangerColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      );
    });
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

class _AddProductButton extends GetView<TransactionController> {
  final bool isIn;
  final Color typeColor;
  const _AddProductButton({required this.isIn, required this.typeColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppTheme.cardColor,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        builder: (_) => _AddProductSheet(controller: controller, isIn: isIn),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: typeColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: typeColor.withOpacity(0.25), width: 1.5),
          boxShadow: [BoxShadow(color: typeColor.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: typeColor.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(Icons.add_rounded, color: typeColor, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'THÊM SẢN PHẨM VÀO PHIẾU',
              style: TextStyle(
                color: typeColor, fontFamily: 'Sora',
                fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitBar extends GetView<TransactionController> {
  final bool isIn;
  final TextEditingController notesCtrl;
  final TextEditingController refCtrl;
  const _SubmitBar({required this.isIn, required this.notesCtrl, required this.refCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: const Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Obx(() {
        final count = controller.draftItems.length;
        final total = controller.draftItems.fold<int>(0, (s, e) => s + e.quantity);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (count > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$count sản phẩm', style: AppTheme.captionStyle),
                  Text(
                    'Tổng: $total',
                    style: AppTheme.titleStyle.copyWith(
                      color: isIn ? AppTheme.successColor : AppTheme.dangerColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            ZenithButton(
              label: isIn ? 'HOÀN TẤT NHẬP KHO' : 'HOÀN TẤT XUẤT KHO',
              gradient: isIn ? AppTheme.successGradient : AppTheme.dangerGradient,
              icon: Icons.check_circle_outline,
              isLoading: controller.isSubmitting.value,
              onPressed: count == 0 ? null : () => controller.submitTransaction(
                notes: notesCtrl.text.trim(),
                refNumber: refCtrl.text.trim(),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _AddProductSheet extends StatefulWidget {
  final TransactionController controller;
  final bool isIn;
  const _AddProductSheet({required this.controller, required this.isIn});

  @override
  State<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<_AddProductSheet> {
  Product? _selProduct;
  Batch? _selBatch;
  List<Product> _products = [];
  List<Batch> _batches = [];
  int _qty = 1;
  bool _loading = false;
  final _qtyCtrl = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    try {
      final list = await widget.controller.loadProductsForType();
      setState(() { _products = list; _loading = false; });
    } catch (e) {
      print('Error loading products: $e');
      Get.snackbar('Lỗi tải sản phẩm', e.toString(), duration: const Duration(seconds: 5));
      setState(() => _loading = false);
    }
  }

  Future<void> _onProductSelected(Product p) async {
    setState(() { _selProduct = p; _selBatch = null; _batches = []; _loading = true; });
    try {
      final list = await widget.controller.loadBatchesForProduct(p.id);
      setState(() {
        _batches = list;
        if (list.isNotEmpty) _selBatch = list.first;
        _loading = false;
      });
    } catch (e) {
      print('Error loading batches for product ${p.id}: $e');
      Get.snackbar('Lỗi tải lô hàng', e.toString(), duration: const Duration(seconds: 5));
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.isIn ? AppTheme.successGradient : AppTheme.dangerGradient;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 36, height: 4, decoration: BoxDecoration(
              color: AppTheme.borderColor, borderRadius: BorderRadius.circular(2),
            )),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.isIn ? Icons.south_west_rounded : Icons.north_east_rounded,
                  color: Colors.white, size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text('Chọn sản phẩm', style: AppTheme.headlineStyle.copyWith(fontSize: 17)),
            ],
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)))
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<Product>(
                      initialValue: _selProduct,
                      isExpanded: true,
                      dropdownColor: AppTheme.elevatedColor,
                      hint: const Text('Chọn sản phẩm'),
                      decoration: const InputDecoration(
                        labelText: 'Sản phẩm',
                        prefixIcon: Icon(Icons.inventory_2_outlined, size: 18),
                      ),
                      items: _products.map((p) => DropdownMenuItem(
                        value: p,
                        child: Text('${p.name} (Còn: ${p.currentStock})',
                            style: const TextStyle(fontSize: 13, fontFamily: 'Inter', color: Colors.white70)),
                      )).toList(),
                      onChanged: (p) { if (p != null) _onProductSelected(p); },
                    ),
                    if (_selProduct != null) ...[
                      const SizedBox(height: 14),
                      DropdownButtonFormField<Batch>(
                        initialValue: _selBatch,
                        isExpanded: true,
                        dropdownColor: AppTheme.elevatedColor,
                        hint: const Text('Chọn lô'),
                        decoration: const InputDecoration(
                          labelText: 'Lô hàng',
                          prefixIcon: Icon(Icons.archive_outlined, size: 18),
                        ),
                        items: _batches.map((b) => DropdownMenuItem(
                          value: b,
                          child: Text('${b.batchCode} (Còn: ${b.currentQuantity})',
                              style: const TextStyle(fontSize: 13, fontFamily: 'Inter', color: Colors.white70)),
                        )).toList(),
                        onChanged: (b) => setState(() => _selBatch = b),
                      ),
                    ],
                    if (_selBatch != null) ...[
                      const SizedBox(height: 20),
                      Text('Số lượng', style: AppTheme.labelStyle),
                      const SizedBox(height: 10),
                      ZenithCard(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Row(
                          children: [
                            _QtyBtn(
                              icon: Icons.remove_rounded,
                              color: AppTheme.dangerColor,
                              onTap: () { if (_qty > 1) setState(() { _qty--; _qtyCtrl.text = '$_qty'; }); },
                            ),
                            Expanded(
                              child: TextField(
                                controller: _qtyCtrl,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                style: AppTheme.numberStyle.copyWith(fontSize: 28),
                                decoration: const InputDecoration(border: InputBorder.none, fillColor: Colors.transparent),
                                onChanged: (v) => setState(() => _qty = (int.tryParse(v) ?? 1).clamp(1, 99999)),
                              ),
                            ),
                            _QtyBtn(
                              icon: Icons.add_rounded,
                              color: AppTheme.successColor,
                              onTap: () { setState(() { _qty++; _qtyCtrl.text = '$_qty'; }); },
                            ),
                          ],
                        ),
                      ),
                      if (!widget.isIn && _qty > (_selBatch!.currentQuantity))
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ZenithBadge(
                            label: '⚠ Vượt tồn kho (${_selBatch!.currentQuantity})',
                            color: AppTheme.warningColor,
                          ),
                        ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ZenithButton(
            label: 'THÊM VÀO PHIẾU',
            gradient: gradient,
            icon: Icons.add_shopping_cart_rounded,
            onPressed: (_selProduct == null || _selBatch == null) ? null : () {
              widget.controller.addDraftItem(TransactionItemDraft(
                product: _selProduct!,
                batch: _selBatch!,
                quantity: _qty,
              ));
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
