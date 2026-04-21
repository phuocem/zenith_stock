import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/transaction_controller.dart';
import '../../../core/theme.dart';
import '../../../core/global_styles.dart';
import '../../../data/models/transaction_model.dart';
import '../../../routes/app_pages.dart';

class TransactionView extends GetView<TransactionController> {
  const TransactionView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GIAO DỊCH KHO"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppTheme.accentColor,
            ),
            onPressed: controller.fetchHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildActionButtons(context),
          _buildFilterTabs(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.history.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                );
              }
              if (controller.history.isEmpty) {
                return const EmptyState(
                  message: "Chưa có giao dịch nào",
                  icon: Icons.receipt_long_outlined,
                );
              }
              return RefreshIndicator(
                color: AppTheme.primaryColor,
                backgroundColor: AppTheme.cardColor,
                onRefresh: controller.fetchHistory,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => FadeSlideItem(
                    index: i,
                    child: _TransactionCard(transaction: controller.history[i]),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _ActionBtn(
              label: "NHẬP KHO",
              icon: Icons.south_west_rounded,
              color: AppTheme.successColor,
              onTap: () {
                controller.formType.value = 'IN';
                controller.draftItems.clear();
                Get.toNamed(Routes.CREATE_TRANSACTION);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionBtn(
              label: "XUẤT KHO",
              icon: Icons.north_east_rounded,
              color: AppTheme.dangerColor,
              onTap: () {
                controller.formType.value = 'OUT';
                controller.draftItems.clear();
                Get.toNamed(Routes.CREATE_TRANSACTION);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Obx(() {
      final types = [null, 'IN', 'OUT'];
      final labels = ['Tất cả', 'Nhập kho', 'Xuất kho'];
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Row(
          children: List.generate(types.length, (i) {
            final sel = controller.filterType.value == types[i];
            return GestureDetector(
              onTap: () {
                controller.filterType.value = types[i];
                controller.fetchHistory();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: sel
                      ? AppTheme.primaryColor.withOpacity(0.15)
                      : AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel ? AppTheme.primaryColor : Colors.white12,
                  ),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: sel ? AppTheme.primaryColor : Colors.white54,
                    fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }),
        ),
      );
    });
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction;
  const _TransactionCard({required this.transaction});
  @override
  Widget build(BuildContext context) {
    final t = transaction;
    Color typeColor = switch (t.type) {
      'IN' => AppTheme.successColor,
      'OUT' => AppTheme.dangerColor,
      'ADJUST' => AppTheme.warningColor,
      _ => Colors.white54,
    };
    IconData typeIcon = switch (t.type) {
      'IN' => Icons.south_west_rounded,
      'OUT' => Icons.north_east_rounded,
      'ADJUST' => Icons.tune_rounded,
      _ => Icons.swap_horiz,
    };
    String typeLabel = switch (t.type) {
      'IN' => "Phiếu Nhập Kho",
      'OUT' => "Phiếu Xuất Kho",
      'ADJUST' => "Điều Chỉnh",
      _ => t.type,
    };
    return ZenithCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(typeIcon, color: typeColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeLabel,
                  style: AppTheme.titleStyle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  "Bởi: ${t.userFullName ?? 'N/A'} · ${t.warehouseName ?? ''}",
                  style: AppTheme.captionStyle.copyWith(fontSize: 11),
                ),
                if (t.items.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    t.items
                            .map((i) => i.productName ?? 'SP')
                            .take(2)
                            .join(', ') +
                        (t.items.length > 2
                            ? ' +${t.items.length - 2} khác'
                            : ''),
                    style: AppTheme.captionStyle.copyWith(
                      fontSize: 11,
                      color: Colors.white38,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ZenithBadge(
                label: t.type == 'IN'
                    ? "+${t.totalQuantity}"
                    : "-${t.totalQuantity}",
                color: typeColor,
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat('dd/MM HH:mm').format(t.createdAt.toLocal()),
                style: AppTheme.captionStyle.copyWith(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration:
              AppTheme.cardDecoration(
                borderColor: color.withOpacity(0.25),
              ).copyWith(
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
