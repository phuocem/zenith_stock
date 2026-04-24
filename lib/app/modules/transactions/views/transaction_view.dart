import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('GIAO DỊCH KHO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.accentColor),
            onPressed: controller.fetchHistory,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.borderColor),
        ),
      ),
      body: Column(
        children: [
          _ActionButtons(),
          _FilterTabs(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.history.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
              }
              if (controller.history.isEmpty) {
                return const EmptyState(
                  message: 'Chưa có giao dịch nào\nTạo phiếu nhập / xuất để bắt đầu',
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
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
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
}

class _ActionButtons extends GetView<TransactionController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _ActionBtn(
              label: 'NHẬP KHO',
              icon: Icons.south_west_rounded,
              color: AppTheme.successColor,
              gradient: AppTheme.successGradient,
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
              label: 'XUẤT KHO',
              icon: Icons.north_east_rounded,
              color: AppTheme.dangerColor,
              gradient: AppTheme.dangerGradient,
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
}

class _ActionBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Gradient gradient;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.icon, required this.color, required this.gradient, required this.onTap});

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween(begin: 1.0, end: 0.96).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(color: widget.color.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (b) => widget.gradient.createShader(b),
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(height: 10),
              ShaderMask(
                shaderCallback: (b) => widget.gradient.createShader(b),
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontFamily: 'Sora', fontWeight: FontWeight.w700,
                    fontSize: 12, letterSpacing: 1.5, color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterTabs extends GetView<TransactionController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      const types = [null, 'IN', 'OUT'];
      const labels = ['Tất cả', 'Nhập kho', 'Xuất kho'];
      final colors = [AppTheme.primaryColor, AppTheme.successColor, AppTheme.dangerColor];

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Row(
          children: List.generate(3, (i) {
            final sel = controller.filterType.value == types[i];
            return GestureDetector(
              onTap: () {
                controller.filterType.value = types[i];
                controller.fetchHistory();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? colors[i].withOpacity(0.12) : AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? colors[i] : AppTheme.borderColor),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: sel ? colors[i] : Colors.white54,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 13, fontFamily: 'Inter',
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
      'IN' => 'Phiếu Nhập Kho',
      'OUT' => 'Phiếu Xuất Kho',
      'ADJUST' => 'Điều Chỉnh',
      _ => t.type,
    };

    return ZenithCard(
      borderColor: typeColor.withOpacity(0.1),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
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
                Text(typeLabel, style: AppTheme.titleStyle.copyWith(fontSize: 14)),
                const SizedBox(height: 3),
                Text(
                  'Bởi: ${t.userFullName ?? 'N/A'} · ${t.warehouseName ?? ''}',
                  style: AppTheme.captionStyle.copyWith(fontSize: 11),
                ),
                if (t.items.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    t.items.map((i) => i.productName ?? 'SP').take(2).join(', ') +
                        (t.items.length > 2 ? ' +${t.items.length - 2} khác' : ''),
                    style: AppTheme.captionStyle.copyWith(fontSize: 11, color: const Color(0xFF37474F)),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ZenithBadge(
                label: t.type == 'IN' ? '+${t.totalQuantity}' : '-${t.totalQuantity}',
                color: typeColor,
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat('dd/MM HH:mm').format(t.createdAt.toLocal()),
                style: AppTheme.monoStyle.copyWith(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

