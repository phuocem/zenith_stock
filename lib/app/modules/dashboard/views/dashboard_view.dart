import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
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
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: const Text("ZENITH STOCK"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: AppTheme.primaryColor),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.dangerColor),
            onPressed: controller.logout,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }
        return RefreshIndicator(
          color: AppTheme.primaryColor,
          backgroundColor: AppTheme.cardColor,
          onRefresh: controller.fetchDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeHeader(),
                const SizedBox(height: 24),
                _buildSummaryCards(),
                const SizedBox(height: 28),
                _buildQuickNav(context),
                const SizedBox(height: 28),
                _buildChartSection(),
                const SizedBox(height: 28),
                _buildTopProductsSection(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWelcomeHeader() {
    return Obx(() {
      final name = controller.userName;
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.greeting, style: AppTheme.captionStyle.copyWith(fontSize: 14)),
                const SizedBox(height: 4),
                Text(name, style: AppTheme.headlineStyle),
                if (Get.isRegistered<UserController>())
                  Obx(() {
                    final role = UserController.to.roleName;
                    if (role == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: ZenithBadge(label: role.toUpperCase(), color: AppTheme.primaryColor),
                    );
                  }),
              ],
            ),
          ),

          Obx(() {
            final initials = Get.isRegistered<UserController>() ? UserController.to.initials : 'U';
            return Container(
              width: 54,
              height: 54,
              decoration: AppTheme.glowDecoration(color: AppTheme.primaryColor, radius: 27),
              child: Center(
                child: Text(initials, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              ),
            );
          }),
        ],
      );
    });
  }

  Widget _buildSummaryCards() {
    return Obx(() => GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.15,
      children: [
        ZenithStatCard(
          title: "TỔNG TỒN KHO",
          value: controller.totalStock.value.toString(),
          icon: Icons.inventory_2_rounded,
          color: AppTheme.primaryColor,
        ),
        ZenithStatCard(
          title: "SẮP HẾT HÀNG",
          value: controller.lowStockCount.value.toString(),
          icon: Icons.warning_amber_rounded,
          color: AppTheme.warningColor,
          subtitle: controller.lowStockCount.value > 0 ? 'Cần nhập thêm' : 'Ổn định',
        ),
        ZenithStatCard(
          title: "NHẬP TUẦN NÀY",
          value: controller.inboundThisWeek.value.toString(),
          icon: Icons.south_west_rounded,
          color: AppTheme.successColor,
        ),
        ZenithStatCard(
          title: "XUẤT TUẦN NÀY",
          value: controller.outboundThisWeek.value.toString(),
          icon: Icons.north_east_rounded,
          color: AppTheme.dangerColor,
        ),
      ],
    ));
  }

  Widget _buildQuickNav(BuildContext context) {
    final items = [
      _QuickNavItem(Icons.inventory_2_outlined, "Kho hàng", AppTheme.accentColor, Routes.INVENTORY),
      _QuickNavItem(Icons.swap_horiz_rounded, "Giao dịch", AppTheme.successColor, Routes.TRANSACTIONS),
      _QuickNavItem(Icons.playlist_add_check_rounded, "Kiểm kê", AppTheme.warningColor, Routes.AUDIT),
      _QuickNavItem(Icons.person_outline_rounded, "Hồ sơ", AppTheme.primaryColor, Routes.PROFILE),
    ];

    return ZenithCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: "Điều hướng nhanh"),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) => _buildQuickNavButton(item)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickNavButton(_QuickNavItem item) {
    return GestureDetector(
      onTap: () => Get.toNamed(item.route),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: item.color.withOpacity(0.2)),
            ),
            child: Icon(item.icon, color: item.color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(item.label, style: AppTheme.captionStyle.copyWith(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return ZenithCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("BIẾN ĐỘNG KHO", style: AppTheme.labelStyle.copyWith(fontSize: 11, letterSpacing: 2)),
                  const SizedBox(height: 4),
                  Text("7 ngày gần nhất", style: AppTheme.captionStyle.copyWith(fontSize: 11)),
                ],
              ),
              ZenithBadge(label: "LIVE", color: AppTheme.successColor),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: Obx(() {
              final data = controller.chartData;
              if (data.isEmpty || data.every((d) => d == 0)) {
                return Center(
                  child: Text("Chưa có dữ liệu giao dịch", style: AppTheme.captionStyle),
                );
              }
              return LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (data.reduce((a, b) => a > b ? a : b) / 4).clamp(1, double.infinity),
                    getDrawingHorizontalLine: (v) => FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i < 0 || i >= days.length) return const SizedBox();
                          return Text(days[i], style: const TextStyle(color: Colors.white24, fontSize: 10));
                        },
                        interval: 1,
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: AppTheme.primaryColor,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                          radius: 3,
                          color: AppTheme.primaryColor,
                          strokeWidth: 2,
                          strokeColor: Colors.black,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppTheme.primaryColor.withOpacity(0.2), Colors.transparent],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsSection() {
    return Obx(() {
      if (controller.topProducts.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: "Sản phẩm giao dịch nhiều nhất"),
          const SizedBox(height: 14),
          ...controller.topProducts.asMap().entries.map((e) {
            final item = e.value as Map<String, dynamic>;
            final idx  = e.key;
            final medals = ['🥇', '🥈', '🥉'];
            return FadeSlideItem(
              index: idx,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ZenithCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Text(idx < 3 ? medals[idx] : '${idx + 1}.', style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          (item['products'] as Map<String, dynamic>?)?['name'] ?? 'Sản phẩm',
                          style: AppTheme.titleStyle.copyWith(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ZenithBadge(label: "${item['quantity']} đơn", color: AppTheme.accentColor),
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

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppTheme.surfaceColor,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
            ),
            child: Obx(() {
              final name     = Get.isRegistered<UserController>() ? UserController.to.displayName : 'Zenith';
              final initials = Get.isRegistered<UserController>() ? UserController.to.initials : 'Z';
              final role     = Get.isRegistered<UserController>() ? UserController.to.roleName : null;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: AppTheme.glowDecoration(color: AppTheme.primaryColor, radius: 32),
                    child: Center(
                      child: Text(initials, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(name, style: AppTheme.titleStyle.copyWith(fontSize: 15)),
                  if (role != null) ...[
                    const SizedBox(height: 6),
                    ZenithBadge(label: role.toUpperCase(), color: AppTheme.primaryColor),
                  ],
                ],
              );
            }),
          ),
          _drawerItem(Icons.dashboard_outlined, "Tổng quan", true, () => Get.back()),
          _drawerItem(Icons.inventory_2_outlined, "Kho hàng", false, () => Get.toNamed(Routes.INVENTORY)),
          _drawerItem(Icons.swap_horiz_rounded, "Nhập / Xuất", false, () => Get.toNamed(Routes.TRANSACTIONS)),
          _drawerItem(Icons.playlist_add_check_rounded, "Kiểm kê", false, () => Get.toNamed(Routes.AUDIT)),
          _drawerItem(Icons.person_outline_rounded, "Hồ sơ cá nhân", false, () => Get.toNamed(Routes.PROFILE)),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ZenithButton(
              label: "ĐĂNG XUẤT",
              gradient: AppTheme.dangerGradient,
              icon: Icons.logout_rounded,
              onPressed: controller.logout,
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, bool isSelected, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.white38, size: 22),
      title: Text(title, style: TextStyle(color: isSelected ? AppTheme.primaryColor : Colors.white70, fontSize: 14)),
      selected: isSelected,
      selectedTileColor: AppTheme.primaryColor.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      onTap: onTap,
    );
  }
}

class _QuickNavItem {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  const _QuickNavItem(this.icon, this.label, this.color, this.route);
}
