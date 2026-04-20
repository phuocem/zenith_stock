import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/dashboard_controller.dart';
import '../../../core/theme.dart';
import '../../../routes/app_pages.dart';

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
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: controller.logout,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(),
              const SizedBox(height: 24),
              _buildSummaryCards(),
              const SizedBox(height: 32),
              _buildChartSection(context),
              const SizedBox(height: 32),
              _buildTopProductsSection(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Chào buổi tối,",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        Text(
          "Quản trị viên Zenith",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard("TỔNG TỒN KHO", controller.totalStock.value.toString(),
            Icons.inventory_2_rounded, AppTheme.primaryColor),
        _buildStatCard("SẮP HẾT HÀNG", controller.lowStockCount.value.toString(),
            Icons.error_outline_rounded, Colors.orangeAccent),
        _buildStatCard("NHẬP TRONG TUẦN", controller.inboundThisWeek.value.toString(),
            Icons.add_chart_rounded, Colors.greenAccent),
        _buildStatCard("XUẤT TRONG TUẦN", controller.outboundThisWeek.value.toString(),
            Icons.bar_chart_rounded, Colors.redAccent),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: AppTheme.glassDecoration().copyWith(
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(icon, size: 60, color: color.withOpacity(0.05)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(BuildContext context) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("BIẾN ĐỘNG KHO",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 2)),
                  Text("Dữ liệu thống kê 7 ngày gần nhất",
                      style: TextStyle(color: Colors.white24, fontSize: 10)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text("LIVE",
                    style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: controller.chartData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value);
                    }).toList(),
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 4,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.2),
                          AppTheme.primaryColor.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Sản phẩm bán chạy nhất",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.topProducts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = controller.topProducts[index];
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              tileColor: AppTheme.cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.shopping_bag_outlined,
                    color: AppTheme.primaryColor),
              ),
              title: Text(item['products']?['name'] ?? "Sản phẩm",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  "ID: ${item['product_id'].toString().substring(0, 8)}...",
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
              trailing: Text("+${item['quantity']}",
                  style: const TextStyle(
                      color: Colors.greenAccent, fontWeight: FontWeight.bold)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppTheme.backgroundColor,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/drawer_bg.png'),
                fit: BoxFit.cover,
                opacity: 0.2,
              ),
              color: Color(0xFF1E1E1E),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/app_logo.png',
                height: 80,
              ),
            ),
          ),
          _buildDrawerItem(
              Icons.dashboard_outlined, "Tổng quan", true, () => Get.back()),
          _buildDrawerItem(Icons.inventory_2_outlined, "Kho hàng", false,
              () => Get.toNamed(Routes.INVENTORY)),
          _buildDrawerItem(Icons.swap_horiz_rounded, "Nhập / Xuất", false,
              () => Get.toNamed(Routes.TRANSACTIONS)),
          _buildDrawerItem(Icons.analytics_outlined, "Kiểm kê", false,
              () => Get.toNamed(Routes.AUDIT)),
          _buildDrawerItem(Icons.settings_outlined, "Cấu hình", false, () => {}),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, bool isSelected, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.white54),
      title: Text(title, style: TextStyle(color: isSelected ? AppTheme.primaryColor : Colors.white70)),
      selected: isSelected,
      onTap: onTap,
    );
  }
}
