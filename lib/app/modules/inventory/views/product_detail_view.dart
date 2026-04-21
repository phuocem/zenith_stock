import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../core/global_styles.dart';
import '../controllers/inventory_controller.dart';
import '../../../data/models/product_model.dart';

class ProductDetailView extends GetView<InventoryController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final productId = Get.arguments as String;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchProductDetail(productId);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("CHI TIẾT SẢN PHẨM"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.accentColor),
            onPressed: () => controller.fetchProductDetail(productId),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }
        final product = controller.selectedProduct.value;
        if (product == null) {
          return const EmptyState(message: "Không tìm thấy sản phẩm", icon: Icons.search_off_rounded);
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductHeader(product),
              const SizedBox(height: 20),
              _buildStockSummary(product),
              const SizedBox(height: 24),
              const SectionHeader(title: "Danh sách lô hàng"),
              const SizedBox(height: 14),
              _buildBatchList(),
              const SizedBox(height: 24),
              _buildDeleteButton(product),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProductHeader(Product product) {
    final status = product.stockStatus;
    Color statusColor = switch (status) {
      StockStatus.normal   => AppTheme.successColor,
      StockStatus.low      => AppTheme.warningColor,
      StockStatus.outOfStock => AppTheme.dangerColor,
    };
    String statusLabel = switch (status) {
      StockStatus.normal   => "BÌNH THƯỜNG",
      StockStatus.low      => "SẮP HẾT",
      StockStatus.outOfStock => "HẾT HÀNG",
    };

    return ZenithCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                ),
                child: Icon(Icons.inventory_2_rounded, color: statusColor, size: 34),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: AppTheme.headlineStyle.copyWith(fontSize: 20)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        ZenithBadge(label: "SKU: ${product.sku}", color: AppTheme.accentColor),
                        ZenithBadge(label: statusLabel, color: statusColor),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          _infoRow(Icons.category_outlined, "Danh mục", product.categoryName ?? "—"),
          const SizedBox(height: 8),
          _infoRow(Icons.square_foot_outlined, "Đơn vị tính", product.unitName ?? "—"),
          if (product.supplierName != null) ...[
            const SizedBox(height: 8),
            _infoRow(Icons.business_outlined, "Nhà cung cấp", product.supplierName!),
          ],
          if (product.description?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(product.description!, style: AppTheme.captionStyle),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white38),
        const SizedBox(width: 8),
        Text("$label:", style: AppTheme.captionStyle),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: AppTheme.captionStyle.copyWith(color: Colors.white70))),
      ],
    );
  }

  Widget _buildStockSummary(Product product) {
    return Row(
      children: [
        Expanded(child: _stockCard("TỒN HIỆN TẠI", product.currentStock.toString(), AppTheme.primaryColor)),
        const SizedBox(width: 12),
        Expanded(child: _stockCard("TỒN TỐI THIỂU", product.minStockLevel.toString(), AppTheme.warningColor)),
        const SizedBox(width: 12),
        Expanded(child: _stockCard("TỒN TỐI ĐA", product.maxStockLevel.toString(), AppTheme.accentColor)),
      ],
    );
  }

  Widget _stockCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration(borderColor: color.withOpacity(0.2)),
      child: Column(
        children: [
          Text(value, style: AppTheme.numberStyle.copyWith(color: color, fontSize: 22)),
          const SizedBox(height: 6),
          Text(label, style: AppTheme.labelStyle.copyWith(fontSize: 8), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildBatchList() {
    return Obx(() {
      final batches = controller.productBatches;
      if (batches.isEmpty) {
        return const EmptyState(
          message: "Chưa có lô hàng nào\nHãy nhập hàng để bắt đầu",
          icon: Icons.archive_outlined,
        );
      }
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: batches.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => FadeSlideItem(index: i, child: _batchCard(batches[i])),
      );
    });
  }

  Widget _batchCard(Batch batch) {
    final isEmpty = batch.currentQuantity == 0;
    return ZenithCard(
      padding: const EdgeInsets.all(14),
      borderColor: isEmpty ? Colors.white12 : null,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isEmpty ? Colors.white.withOpacity(0.04) : AppTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.archive_rounded,
              color: isEmpty ? Colors.white24 : AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(batch.batchCode, style: AppTheme.titleStyle.copyWith(fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(batch.warehouseName ?? 'Kho chính', style: AppTheme.captionStyle.copyWith(fontSize: 11)),
                    if (batch.expiryDate != null) ...[
                      const SizedBox(width: 10),
                      Icon(Icons.event_outlined, size: 12, color: Colors.white38),
                      const SizedBox(width: 4),
                      Text(DateFormat('dd/MM/yyyy').format(batch.expiryDate!), style: AppTheme.captionStyle.copyWith(fontSize: 11)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${batch.currentQuantity}', style: AppTheme.numberStyle.copyWith(
                fontSize: 20,
                color: isEmpty ? Colors.white24 : AppTheme.primaryColor,
              )),
              Text('/ ${batch.initialQuantity}', style: AppTheme.captionStyle.copyWith(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(Product product) {
    return Obx(() => ZenithButton(
      label: "XÓA SẢN PHẨM",
      gradient: AppTheme.dangerGradient,
      icon: Icons.delete_outline_rounded,
      isLoading: controller.isLoading.value,
      onPressed: () async {
        await controller.deleteProduct(product);
        if (!controller.isLoading.value) Get.back();
      },
    ));
  }
}
