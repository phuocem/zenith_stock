import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/dashboard_controller.dart';
import '../../../core/theme.dart';
import '../../../core/global_styles.dart';
import '../../../routes/app_pages.dart';
import '../../../core/user_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      drawer: const _ZenithDrawer(),
      appBar: _buildAppBar(context),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _DashboardSkeleton();
        }
        return RefreshIndicator(
          color: AppTheme.primaryColor,
          backgroundColor: AppTheme.cardColor,
          displacement: 60,
          onRefresh: controller.fetchDashboardData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const _WelcomeHeader(),
                    const SizedBox(height: 24),
                    const _SummaryGrid(),
                    const SizedBox(height: 28),
                    _QuickNavSection(),
                    const SizedBox(height: 28),
                    const _ChartSection(),
                    const SizedBox(height: 28),
                    const _TopProductsSection(),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.surfaceColor,
      title: ShaderMask(
        shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
        child: const Text(
          'ZENITH STOCK',
          style: TextStyle(
            fontFamily: 'Sora',
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 3,
            color: Colors.white,
          ),
        ),
      ),
      actions: [
        Obx(() {
          final hasAlert = controller.lowStockCount.value > 0;
          return Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: hasAlert ? AppTheme.warningColor : const Color(0xFF546E7A),
                ),
                onPressed: () {},
              ),
              if (hasAlert)
                Positioned(
                  right: 10, top: 10,
                  child: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.warningColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          );
        }),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: AppTheme.dangerColor),
          onPressed: controller.logout,
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppTheme.borderColor),
      ),
    );
  }
}

class _WelcomeHeader extends GetView<DashboardController> {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final name = controller.userName;
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.greeting,
                    style: AppTheme.captionStyle.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(name, style: AppTheme.headlineStyle),
                  if (Get.isRegistered<UserController>())
                    Obx(() {
                      final role = UserController.to.roleName;
                      if (role == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ZenithBadge(
                          label: role.toUpperCase(),
                          color: AppTheme.primaryColor,
                          dot: true,
                        ),
                      );
                    }),
                ],
              ),
            ),
            GlowPulse(
              color: AppTheme.primaryColor,
              child: Container(
                width: 52, height: 52,
                decoration: AppTheme.glowDecoration(
                  color: AppTheme.primaryColor, radius: 26,
                ),
                child: Center(
                  child: Obx(() {
                    final initials = Get.isRegistered<UserController>()
                        ? UserController.to.initials : 'U';
                    return Text(
                      initials,
                      style: AppTheme.titleStyle.copyWith(
                        color: AppTheme.primaryColor, fontSize: 20,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _SummaryGrid extends GetView<DashboardController> {
  const _SummaryGrid();

  @override
  Widget build(BuildContext context) {
    return Obx(() => GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.95,
      children: [
        ZenithStatCard(
          title: 'TỔNG TỒN KHO',
          value: controller.totalStock.value.toString(),
          icon: Icons.inventory_2_rounded,
          color: AppTheme.primaryColor,
        ),
        ZenithStatCard(
          title: 'SẮP HẾT HÀNG',
          value: controller.lowStockCount.value.toString(),
          icon: Icons.warning_amber_rounded,
          color: AppTheme.warningColor,
          subtitle: controller.lowStockCount.value > 0 ? 'Cần nhập thêm' : 'Ổn định',
          onTap: () => Get.toNamed(Routes.INVENTORY, arguments: {'filter': 'low_stock'}),
        ),
        ZenithStatCard(
          title: 'NHẬP TUẦN NÀY',
          value: controller.inboundThisWeek.value.toString(),
          icon: Icons.south_west_rounded,
          color: AppTheme.successColor,
        ),
        ZenithStatCard(
          title: 'XUẤT TUẦN NÀY',
          value: controller.outboundThisWeek.value.toString(),
          icon: Icons.north_east_rounded,
          color: AppTheme.dangerColor,
        ),
      ],
    ));
  }
}

class _QuickNavSection extends GetView<DashboardController> {
  List<_NavItem> _items(bool isAdmin, bool canStock, bool canTx, bool canAudit) => [
    if (canTx) _NavItem(Icons.south_west_rounded, 'Nhập kho', AppTheme.successColor, Routes.CREATE_TRANSACTION, 'IN'),
    if (canTx) _NavItem(Icons.north_east_rounded, 'Xuất kho', AppTheme.dangerColor, Routes.CREATE_TRANSACTION, 'OUT'),
    if (canStock || isAdmin) _NavItem(Icons.inventory_2_outlined, 'Kho hàng', AppTheme.accentColor, Routes.INVENTORY),
    _NavItem(Icons.swap_horiz_rounded, 'Giao dịch', AppTheme.primaryColor, Routes.TRANSACTIONS),
    if (canAudit || isAdmin) _NavItem(Icons.playlist_add_check_rounded, 'Kiểm kê', AppTheme.warningColor, Routes.CREATE_AUDIT),
    if (isAdmin) _NavItem(Icons.people_outline_rounded, 'Nhân viên', const Color(0xFF9C88FF), Routes.ADMIN),
    _NavItem(Icons.person_outline_rounded, 'Hồ sơ', const Color(0xFF6C8EBF), Routes.PROFILE),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final uc = Get.isRegistered<UserController>() ? UserController.to : null;
      final isAdmin = uc?.isAdmin ?? false;
      final canStock = uc?.canManageProducts ?? false;
      final canTx = uc?.canCreateTx ?? true;
      final canAudit = uc?.canAudit ?? false;
      final items = _items(isAdmin, canStock, canTx, canAudit);
      if (items.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Thao tác nhanh'),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.0,
            children: items.asMap().entries.map((e) =>
              FadeSlideItem(
                index: e.key,
                child: _NavCell(item: e.value),
              ),
            ).toList(),
          ),
        ],
      );
    });
  }
}

class _NavCell extends GetView<DashboardController> {
  final _NavItem item;
  const _NavCell({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ZenithCard(
      padding: EdgeInsets.zero,
      borderColor: item.color.withOpacity(0.15),
      onTap: () {
        if (item.type != null) {
          final txCtrl = Get.find<dynamic>();

        }
        Get.toNamed(item.route);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            item.label,
            style: AppTheme.captionStyle.copyWith(
              color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  final String? type;
  const _NavItem(this.icon, this.label, this.color, this.route, [this.type]);
}

class _ChartSection extends GetView<DashboardController> {
  const _ChartSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Biểu đồ nhập / xuất 7 ngày'),
        const SizedBox(height: 14),
        ZenithCard(
          borderColor: AppTheme.primaryColor.withOpacity(0.12),
          child: Column(
            children: [
              Row(
                children: [
                  _ChartLegend(color: AppTheme.successColor, label: 'Nhập'),
                  const SizedBox(width: 16),
                  _ChartLegend(color: AppTheme.dangerColor, label: 'Xuất'),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 180,
                child: Obx(() {
                  final spots = controller.chartData
                      .asMap()
                      .entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                      .toList();
                  if (spots.isEmpty) {
                    return const Center(
                      child: Text('Chưa có dữ liệu', style: TextStyle(color: Color(0xFF546E7A))),
                    );
                  }
                  return LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => const FlLine(
                          color: AppTheme.borderColor, strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) => Text(
                              'T${v.toInt() + 1}',
                              style: AppTheme.monoStyle.copyWith(fontSize: 10),
                            ),
                          ),
                        ),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: AppTheme.primaryColor,
                          barWidth: 2.5,
                          dotData: FlDotData(
                            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                              radius: 3,
                              color: AppTheme.primaryColor,
                              strokeColor: AppTheme.bgColor,
                              strokeWidth: 2,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.primaryColor.withOpacity(0.15),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20, height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTheme.captionStyle),
      ],
    );
  }
}

class _TopProductsSection extends GetView<DashboardController> {
  const _TopProductsSection();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.topProducts.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Sản phẩm giao dịch nhiều nhất'),
          const SizedBox(height: 14),
          ...controller.topProducts.asMap().entries.map((e) {
            final item = e.value as Map<String, dynamic>;
            final idx = e.key;
            final medals = ['🥇', '🥈', '🥉'];
            return FadeSlideItem(
              index: idx,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ZenithCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: idx < 3
                            ? Text(medals[idx], style: const TextStyle(fontSize: 18))
                            : Text(
                                '${idx + 1}',
                                style: AppTheme.monoStyle.copyWith(
                                  fontWeight: FontWeight.w700, color: Colors.white38,
                                ),
                                textAlign: TextAlign.center,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (item['products'] as Map<String, dynamic>?)?['name'] ?? 'Sản phẩm',
                              style: AppTheme.titleStyle.copyWith(fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            ZenithProgressBar(
                              value: (item['quantity'] as int? ?? 0) / 100,
                              color: idx == 0
                                  ? AppTheme.primaryColor
                                  : idx == 1
                                      ? AppTheme.accentColor
                                      : AppTheme.successColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ZenithBadge(
                        label: '${item['quantity']} đơn',
                        color: idx == 0 ? AppTheme.primaryColor : AppTheme.accentColor,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      );
    });
  }
}

class _ZenithDrawer extends GetView<DashboardController> {
  const _ZenithDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surfaceColor,
      width: 280,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
            ),
            child: Obx(() {
              final uc = Get.isRegistered<UserController>() ? UserController.to : null;
              final name = uc?.displayName ?? 'Zenith';
              final initials = uc?.initials ?? 'Z';
              final role = uc?.roleName;

              return Row(
                children: [
                  GlowPulse(
                    color: AppTheme.primaryColor,
                    child: Container(
                      width: 52, height: 52,
                      decoration: AppTheme.glowDecoration(
                        color: AppTheme.primaryColor, radius: 26,
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: AppTheme.titleStyle.copyWith(
                            color: AppTheme.primaryColor, fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: AppTheme.titleStyle.copyWith(fontSize: 14)),
                        if (role != null) ...[
                          const SizedBox(height: 6),
                          ZenithBadge(label: role.toUpperCase(), color: AppTheme.primaryColor),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
          Expanded(
            child: Obx(() {
              final uc = Get.isRegistered<UserController>() ? UserController.to : null;
              final isAdmin = uc?.isAdmin ?? false;
              final canStock = uc?.canManageProducts ?? false;
              final canAudit = uc?.canAudit ?? false;
              final canTx = uc?.canCreateTx ?? true;

              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                children: [
                  _DrawerItem(Icons.dashboard_outlined, 'Tổng quan', true, Get.back),
                  if (canStock || isAdmin)
                    _DrawerItem(Icons.inventory_2_outlined, 'Kho hàng', false,
                        () => Get.toNamed(Routes.INVENTORY)),
                  if (canTx)
                    _DrawerItem(Icons.swap_horiz_rounded, 'Nhập / Xuất', false,
                        () => Get.toNamed(Routes.TRANSACTIONS)),
                  if (canAudit || isAdmin)
                    _DrawerItem(Icons.playlist_add_check_rounded, 'Kiểm kê', false,
                        () => Get.toNamed(Routes.AUDIT)),
                  if (isAdmin)
                    _DrawerItem(Icons.people_outline_rounded, 'Nhân viên', false,
                        () => Get.toNamed(Routes.ADMIN),
                        color: const Color(0xFF9C88FF)),
                  _DrawerItem(Icons.person_outline_rounded, 'Hồ sơ', false,
                      () => Get.toNamed(Routes.PROFILE)),
                ],
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: ZenithButton(
              label: 'ĐĂNG XUẤT',
              gradient: AppTheme.dangerGradient,
              icon: Icons.logout_rounded,
              onPressed: controller.logout,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem(this.icon, this.title, this.isSelected, this.onTap, {this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? (isSelected ? AppTheme.primaryColor : const Color(0xFF546E7A));
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.2) : Colors.transparent,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: c, size: 20),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryColor : Colors.white70,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        minLeadingWidth: 0,
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 100, height: 14, radius: 6),
                    const SizedBox(height: 8),
                    ShimmerBox(width: 160, height: 22, radius: 8),
                  ],
                ),
              ),
              ShimmerBox(width: 52, height: 52, radius: 26),
            ],
          ),
          const SizedBox(height: 28),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
            children: List.generate(4, (i) => ShimmerBox(width: double.infinity, height: 120, radius: 18)),
          ),
        ],
      ),
    );
  }
}
