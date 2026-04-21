import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../core/global_styles.dart';
import '../controllers/audit_controller.dart';
import '../../../data/models/audit_model.dart';
import '../../../routes/app_pages.dart';

class AuditView extends GetView<AuditController> {
  const AuditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KIỂM KÊ KHO"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.accentColor),
            onPressed: controller.fetchAudits,
          ),
          IconButton(
            icon: const Icon(Icons.playlist_add_check_rounded, color: AppTheme.primaryColor),
            onPressed: () => Get.toNamed(Routes.CREATE_AUDIT),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.audits.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
              }
              if (controller.audits.isEmpty) {
                return const EmptyState(
                  message: "Chưa có lịch sử kiểm kê\nNhấn + để tạo phiên kiểm kê mới",
                  icon: Icons.playlist_add_check_outlined,
                  actionLabel: "Tạo kiểm kê",
                );
              }
              return RefreshIndicator(
                color: AppTheme.primaryColor,
                backgroundColor: AppTheme.cardColor,
                onRefresh: controller.fetchAudits,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.audits.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => FadeSlideItem(
                    index: i,
                    child: _AuditCard(audit: controller.audits[i]),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Obx(() {
      final total      = controller.audits.length;
      final hasVariance = controller.audits.where((a) => !a.isMatch).length;
      final matched    = total - hasVariance;

      return Padding(
        padding: const EdgeInsets.all(16),
        child: ZenithCard(
          padding: const EdgeInsets.all(16),
          borderColor: AppTheme.primaryColor.withOpacity(0.2),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.analytics_outlined, color: AppTheme.primaryColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Tổng: $total lần kiểm kê", style: AppTheme.titleStyle.copyWith(fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(children: [
                      ZenithBadge(label: "✓ Khớp: $matched", color: AppTheme.successColor),
                      const SizedBox(width: 8),
                      ZenithBadge(label: "⚠ Lệch: $hasVariance", color: AppTheme.warningColor),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _AuditCard extends StatelessWidget {
  final InventoryAudit audit;
  const _AuditCard({required this.audit});

  @override
  Widget build(BuildContext context) {
    Color varColor = audit.isMatch
        ? AppTheme.successColor
        : (audit.hasExcess ? AppTheme.accentColor : AppTheme.dangerColor);
    String varLabel = audit.isMatch
        ? "KHỚP"
        : (audit.hasExcess ? "+${audit.variance}" : "${audit.variance}");

    return ZenithCard(
      padding: const EdgeInsets.all(14),
      borderColor: audit.isMatch ? null : varColor.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      audit.productName ?? 'Sản phẩm không xác định',
                      style: AppTheme.titleStyle.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (audit.productSku != null)
                      Text("SKU: ${audit.productSku}", style: AppTheme.captionStyle.copyWith(fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ZenithBadge(label: varLabel, color: varColor),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(Icons.archive_outlined, "Hệ thống: ${audit.systemQty}", Colors.white38),
              const SizedBox(width: 8),
              _InfoChip(Icons.fact_check_outlined, "Thực tế: ${audit.actualQty}", varColor),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person_outline, size: 13, color: Colors.white24),
              const SizedBox(width: 4),
              Text(audit.userFullName ?? 'N/A', style: AppTheme.captionStyle.copyWith(fontSize: 11)),
              const SizedBox(width: 12),
              Icon(Icons.schedule_outlined, size: 13, color: Colors.white24),
              const SizedBox(width: 4),
              Text(DateFormat('dd/MM/yyyy HH:mm').format(audit.createdAt.toLocal()),
                  style: AppTheme.captionStyle.copyWith(fontSize: 11)),
            ],
          ),
          if (audit.adjustmentReason?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text("Lý do: ${audit.adjustmentReason}", style: AppTheme.captionStyle.copyWith(fontSize: 11, fontStyle: FontStyle.italic)),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }
}
