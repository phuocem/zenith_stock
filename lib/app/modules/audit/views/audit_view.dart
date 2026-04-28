
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
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('KIỂM KÊ KHO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.accentColor),
            onPressed: controller.fetchAudits,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: FilledButton.icon(
              onPressed: () => Get.toNamed(Routes.CREATE_AUDIT),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Tạo', style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppTheme.borderColor)),
      ),
      body: Column(
        children: [
          _AuditSummary(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.audits.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
              }
              if (controller.audits.isEmpty) {
                return const EmptyState(
                  message: 'Chưa có lịch sử kiểm kê\nNhấn Tạo để bắt đầu',
                  icon: Icons.playlist_add_check_outlined,
                );
              }
              return RefreshIndicator(
                color: AppTheme.primaryColor,
                backgroundColor: AppTheme.cardColor,
                onRefresh: controller.fetchAudits,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.audits.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
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
}

class _AuditSummary extends GetView<AuditController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = controller.audits.length;
      final hasVariance = controller.audits.where((a) => !a.isMatch).length;
      final matched = total - hasVariance;

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor.withOpacity(0.08), AppTheme.accentColor.withOpacity(0.04)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.analytics_outlined, color: AppTheme.primaryColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tổng: $total lần kiểm kê', style: AppTheme.titleStyle.copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ZenithBadge(label: '✓ Khớp: $matched', color: AppTheme.successColor, dot: true),
                      const SizedBox(width: 8),
                      ZenithBadge(label: '⚠ Lệch: $hasVariance', color: AppTheme.warningColor, dot: true),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
    final varColor = audit.isMatch
        ? AppTheme.successColor
        : (audit.hasExcess ? AppTheme.accentColor : AppTheme.dangerColor);
    final varLabel = audit.isMatch
        ? 'KHỚP'
        : (audit.hasExcess ? '+${audit.variance}' : '${audit.variance}');

    return ZenithCard(
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
                      style: AppTheme.titleStyle.copyWith(fontSize: 14),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    if (audit.productSku != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text('SKU: ${audit.productSku}', style: AppTheme.monoStyle.copyWith(fontSize: 10, color: AppTheme.accentColor)),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ZenithBadge(label: varLabel, color: varColor),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _DataPill(icon: Icons.archive_outlined, label: 'Hệ thống', value: '${audit.systemQty}', color: const Color(0xFF546E7A)),
              const SizedBox(width: 8),
              _DataPill(icon: Icons.fact_check_outlined, label: 'Thực tế', value: '${audit.actualQty}', color: varColor),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.person_outline, size: 12, color: Colors.white24),
              const SizedBox(width: 4),
              Text(audit.userFullName ?? 'N/A', style: AppTheme.captionStyle.copyWith(fontSize: 11)),
              const SizedBox(width: 12),
              Icon(Icons.schedule_outlined, size: 12, color: Colors.white24),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(audit.createdAt.toLocal()),
                style: AppTheme.monoStyle.copyWith(fontSize: 10),
              ),
            ],
          ),
          if (audit.adjustmentReason?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: varColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: varColor.withOpacity(0.1)),
              ),
              child: Text(
                'Lý do: ${audit.adjustmentReason}',
                style: AppTheme.captionStyle.copyWith(fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
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

