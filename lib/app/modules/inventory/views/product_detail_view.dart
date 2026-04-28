import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/inventory_controller.dart';
import '../../../data/models/product_model.dart';
import '../../../core/theme.dart';
import '../../../core/global_styles.dart';

class ProductDetailView extends GetView<InventoryController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final productId = Get.arguments as String;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchProductDetail(productId);
    });

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('CHI TIẾT SẢN PHẨM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.accentColor),
            onPressed: () => controller.fetchProductDetail(productId),
          ),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppTheme.borderColor)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }
        final product = controller.selectedProduct.value;
        if (product == null) {
          return const EmptyState(message: 'Không tìm thấy sản phẩm', icon: Icons.search_off_rounded);
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductHeader(product: product),
              const SizedBox(height: 16),
              _StockSummary(product: product),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Danh sách lô hàng'),
              const SizedBox(height: 14),
              _BatchList(),
              const SizedBox(height: 24),
              _ArchiveButton(product: product),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }
}

class _ProductHeader extends StatelessWidget {
  final Product product;
  const _ProductHeader({required this.product});

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

    return ZenithCard(
      borderColor: statusColor.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [statusColor.withOpacity(0.12), statusColor.withOpacity(0.06)]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                ),
                clipBehavior: Clip.antiAlias,
                child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                  ? Image.memory(
                      base64Decode(product.imageUrl!.split(',').last),
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image_rounded, color: statusColor, size: 34),
                    )
                  : Icon(Icons.inventory_2_rounded, color: statusColor, size: 34),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: AppTheme.headlineStyle.copyWith(fontSize: 18)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 6,
                      children: [
                        ZenithBadge(label: 'SKU: ${product.sku}', color: AppTheme.accentColor),
                        ZenithBadge(label: statusLabel, color: statusColor, dot: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const ZenithDivider(margin: EdgeInsets.zero),
          const SizedBox(height: 14),
          if (product.categoryName != null)
            _InfoRow(Icons.category_outlined, 'Danh mục', product.categoryName!),
          if (product.unitName != null) ...[
            const SizedBox(height: 8),
            _InfoRow(Icons.square_foot_outlined, 'Đơn vị tính', product.unitName!),
          ],
          if (product.supplierName != null) ...[
            const SizedBox(height: 8),
            _InfoRow(Icons.business_outlined, 'Nhà cung cấp', product.supplierName!),
          ],
          if (product.description?.isNotEmpty == true) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Text(product.description!, style: AppTheme.captionStyle.copyWith(height: 1.6)),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF546E7A)),
        const SizedBox(width: 8),
        Text('$label:', style: AppTheme.captionStyle),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: AppTheme.captionStyle.copyWith(color: Colors.white70))),
      ],
    );
  }
}

class _StockSummary extends StatelessWidget {
  final Product product;
  const _StockSummary({required this.product});

  @override
  Widget build(BuildContext context) {
    final pct = product.maxStockLevel > 0
        ? (product.currentStock / product.maxStockLevel).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StockTile('TỒN HIỆN TẠI', product.currentStock.toString(), AppTheme.primaryColor)),
            const SizedBox(width: 10),
            Expanded(child: _StockTile('TỒN TỐI THIỂU', product.minStockLevel.toString(), AppTheme.warningColor)),
            const SizedBox(width: 10),
            Expanded(child: _StockTile('TỒN TỐI ĐA', product.maxStockLevel.toString(), AppTheme.accentColor)),
          ],
        ),
        const SizedBox(height: 12),
        ZenithCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mức tồn kho', style: AppTheme.captionStyle),
                  Text('${(pct * 100).toStringAsFixed(0)}%',
                      style: AppTheme.monoStyle.copyWith(color: AppTheme.primaryColor)),
                ],
              ),
              const SizedBox(height: 8),
              ZenithProgressBar(value: pct.toDouble(), color: AppTheme.primaryColor, height: 6),
            ],
          ),
        ),
      ],
    );
  }
}

class _StockTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StockTile(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Text(value, style: AppTheme.numberStyle.copyWith(color: color, fontSize: 22)),
          const SizedBox(height: 6),
          Text(label, style: AppTheme.labelStyle.copyWith(fontSize: 8), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _BatchList extends GetView<InventoryController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final batches = controller.productBatches;
      if (batches.isEmpty) {
        return const EmptyState(message: 'Chưa có lô hàng nào\nHãy nhập hàng để bắt đầu', icon: Icons.archive_outlined);
      }
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: batches.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => FadeSlideItem(index: i, child: _BatchCard(batch: batches[i])),
      );
    });
  }
}

class _BatchCard extends StatelessWidget {
  final Batch batch;
  const _BatchCard({required this.batch});

  @override
  Widget build(BuildContext context) {
    final isEmpty = batch.currentQuantity == 0;
    return ZenithCard(
      borderColor: isEmpty ? AppTheme.borderColor : AppTheme.primaryColor.withOpacity(0.12),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: isEmpty ? Colors.white.withOpacity(0.03) : AppTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.archive_rounded,
                color: isEmpty ? const Color(0xFF37474F) : AppTheme.primaryColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(batch.batchCode, style: AppTheme.monoStyle.copyWith(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(batch.warehouseName ?? 'Kho chính', style: AppTheme.captionStyle.copyWith(fontSize: 11)),
                    if (batch.expiryDate != null) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.event_outlined, size: 11, color: Color(0xFF37474F)),
                      const SizedBox(width: 3),
                      Text(
                        DateFormat('dd/MM/yyyy').format(batch.expiryDate!),
                        style: AppTheme.monoStyle.copyWith(fontSize: 10),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${batch.currentQuantity}',
                style: AppTheme.numberStyle.copyWith(
                  fontSize: 20,
                  color: isEmpty ? const Color(0xFF37474F) : AppTheme.primaryColor,
                ),
              ),
              Text('/ ${batch.initialQuantity}', style: AppTheme.monoStyle.copyWith(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArchiveButton extends GetView<InventoryController> {
  final Product product;
  const _ArchiveButton({required this.product});

  @override
  Widget build(BuildContext context) {
    return Obx(() => ZenithButton(
      label: 'NGỪNG KINH DOANH',
      gradient: AppTheme.dangerGradient,
      icon: Icons.archive_outlined,
      isLoading: controller.isLoading.value,
      onPressed: () async => controller.archiveProduct(product),
    ));
  }
}
