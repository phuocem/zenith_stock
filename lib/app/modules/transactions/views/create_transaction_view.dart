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
      final typeLabel = isIn ? "NHẬP KHO" : "XUẤT KHO";
      return Scaffold(
        appBar: AppBar(
          title: Text(typeLabel),
          titleTextStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: typeColor,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: Get.back,
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
                    _buildWarehouseSelector(typeColor),
                    const SizedBox(height: 20),
                    _buildDraftItemsList(isIn),
                    const SizedBox(height: 16),
                    _buildAddProductBtn(context, isIn, typeColor),
                    const SizedBox(height: 20),
                    TextField(
                      controller: notesCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "Ghi chú (tuỳ chọn)",
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: refCtrl,
                      decoration: const InputDecoration(
                        labelText: "Mã tham chiếu / Số phiếu",
                        prefixIcon: Icon(Icons.tag_rounded),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildSubmitBar(typeColor, isIn, notesCtrl, refCtrl),
          ],
        ),
      );
    });
  }

  Widget _buildWarehouseSelector(Color color) {
    return ZenithCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.warehouse_outlined, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => DropdownButton<Warehouse>(
                value: controller.selectedWarehouse.value,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                dropdownColor: AppTheme.elevatedColor,
                style: AppTheme.titleStyle.copyWith(fontSize: 14),
                hint: const Text(
                  "Chọn kho",
                  style: TextStyle(color: Colors.white54),
                ),
                items: controller.warehouses
                    .map((w) => DropdownMenuItem(value: w, child: Text(w.name)))
                    .toList(),
                onChanged: (w) => controller.selectedWarehouse.value = w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftItemsList(bool isIn) {
    return Obx(() {
      if (controller.draftItems.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.cardDecoration(),
          child: const Center(
            child: Column(
              children: [
                Icon(
                  Icons.add_shopping_cart_outlined,
                  size: 40,
                  color: Colors.white12,
                ),
                SizedBox(height: 12),
                Text(
                  "Chưa có sản phẩm nào\nNhấn nút bên dưới để thêm",
                  style: TextStyle(color: Colors.white38, fontSize: 13),
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
            title: "${controller.draftItems.length} sản phẩm",
            trailing: TextButton(
              onPressed: controller.draftItems.clear,
              child: const Text(
                "Xóa tất cả",
                style: TextStyle(color: AppTheme.dangerColor, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...controller.draftItems.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final isOut = !isIn;
            final qtyCtrl = TextEditingController(
              text: item.quantity.toString(),
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ZenithCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: AppTheme.titleStyle.copyWith(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Lô: ${item.batch.batchCode}",
                            style: AppTheme.captionStyle.copyWith(fontSize: 11),
                          ),
                          if (isOut)
                            Text(
                              "Còn: ${item.batch.currentQuantity}",
                              style: AppTheme.captionStyle.copyWith(
                                fontSize: 11,
                                color: AppTheme.warningColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            size: 20,
                          ),
                          color: AppTheme.dangerColor,
                          onPressed: () {
                            if (item.quantity > 1) {
                              controller.updateDraftQty(i, item.quantity - 1);
                              qtyCtrl.text = (item.quantity).toString();
                            }
                          },
                        ),
                        SizedBox(
                          width: 44,
                          child: TextField(
                            controller: qtyCtrl,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: AppTheme.numberStyle.copyWith(fontSize: 16),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 6),
                              border: InputBorder.none,
                            ),
                            onChanged: (v) {
                              final qty = int.tryParse(v) ?? 1;
                              controller.updateDraftQty(i, qty.clamp(1, 99999));
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          color: AppTheme.successColor,
                          onPressed: () {
                            controller.updateDraftQty(i, item.quantity + 1);
                            qtyCtrl.text = (item.quantity).toString();
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.white24,
                          ),
                          onPressed: () => controller.removeDraftItem(i),
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

  Widget _buildAddProductBtn(BuildContext context, bool isIn, Color color) {
    return GestureDetector(
      onTap: () => _showAddItemSheet(context, isIn),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration(
          borderColor: color.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: color, size: 22),
            const SizedBox(width: 10),
            Text(
              "Thêm sản phẩm vào phiếu",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitBar(
    Color color,
    bool isIn,
    TextEditingController notes,
    TextEditingController ref,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Obx(
        () => ZenithButton(
          label: "XÁC NHẬN ${isIn ? 'NHẬP' : 'XUẤT'} KHO",
          isLoading: controller.isSubmitting.value,
          gradient: isIn ? AppTheme.successGradient : AppTheme.dangerGradient,
          onPressed: () => controller.submitTransaction(
            notes: notes.text,
            refNumber: ref.text,
          ),
        ),
      ),
    );
  }

  void _showAddItemSheet(BuildContext context, bool isIn) {
    Get.bottomSheet(
      _AddItemSheet(controller: controller, isIn: isIn),
      isScrollControlled: true,
    );
  }
}

class _AddItemSheet extends StatefulWidget {
  final TransactionController controller;
  final bool isIn;
  const _AddItemSheet({required this.controller, required this.isIn});
  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  List<Product> _products = [];
  List<Batch> _batches = [];
  Product? _selProduct;
  Batch? _selBatch;
  int _qty = 1;
  bool _loading = true;
  late final TextEditingController _qtyCtrl;
  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(text: '1');
    _loadProducts();
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    try {
      final list = await widget.controller.loadProductsForType();
      setState(() {
        _products = list;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _onProductSelected(Product p) async {
    setState(() {
      _selProduct = p;
      _selBatch = null;
      _batches = [];
      _loading = true;
    });
    try {
      final list = await widget.controller.loadBatchesForProduct(p.id);
      setState(() {
        _batches = list;
        if (list.isNotEmpty) _selBatch = list.first;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isIn ? AppTheme.successColor : AppTheme.dangerColor;
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.isIn
                    ? Icons.south_west_rounded
                    : Icons.north_east_rounded,
                color: color,
              ),
              const SizedBox(width: 10),
              Text(
                "Chọn sản phẩm",
                style: AppTheme.headlineStyle.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<Product>(
                      value: _selProduct,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: "Sản phẩm"),
                      dropdownColor: AppTheme.elevatedColor,
                      hint: const Text("Chọn sản phẩm"),
                      items: _products
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(
                                '${p.name} (Còn: ${p.currentStock})',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (p) {
                        if (p != null) _onProductSelected(p);
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_selProduct != null) ...[
                      DropdownButtonFormField<Batch>(
                        value: _selBatch,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: "Lô hàng"),
                        dropdownColor: AppTheme.elevatedColor,
                        hint: const Text("Chọn lô"),
                        items: _batches
                            .map(
                              (b) => DropdownMenuItem(
                                value: b,
                                child: Text(
                                  '${b.batchCode} (Còn: ${b.currentQuantity})',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (b) => setState(() => _selBatch = b),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_selBatch != null) ...[
                      Text("Số lượng", style: AppTheme.captionStyle),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              color: AppTheme.dangerColor,
                            ),
                            onPressed: () {
                              if (_qty > 1) setState(() => _qty--);
                            },
                          ),
                          Expanded(
                            child: TextField(
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              controller: _qtyCtrl,
                              style: AppTheme.numberStyle.copyWith(
                                fontSize: 24,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              onChanged: (v) => setState(
                                () => _qty = (int.tryParse(v) ?? 1).clamp(
                                  1,
                                  99999,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: AppTheme.successColor,
                            ),
                            onPressed: () {
                              setState(() => _qty++);
                              _qtyCtrl.text = _qty.toString();
                            },
                          ),
                        ],
                      ),
                      if (!widget.isIn && _qty > (_selBatch!.currentQuantity))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ZenithBadge(
                            label:
                                "⚠ Vượt tồn kho (${_selBatch!.currentQuantity})",
                            color: AppTheme.warningColor,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          ZenithButton(
            label: "THÊM VÀO PHIẾU",
            gradient: widget.isIn
                ? AppTheme.successGradient
                : AppTheme.dangerGradient,
            onPressed: (_selProduct == null || _selBatch == null)
                ? null
                : () {
                    widget.controller.addDraftItem(
                      TransactionItemDraft(
                        product: _selProduct!,
                        batch: _selBatch!,
                        quantity: _qty,
                      ),
                    );
                    Get.back();
                  },
          ),
        ],
      ),
    );
  }
}
