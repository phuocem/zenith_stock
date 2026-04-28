import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/global_styles.dart';
import '../../../core/theme.dart';
import '../../../core/user_controller.dart';
import '../../../routes/app_pages.dart';
import '../../inventory/widgets/inventory_sheets.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
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
                  color: hasAlert
                      ? AppTheme.warningColor
                      : const Color(0xFF546E7A),
                ),
                onPressed: () {},
              ),
              if (hasAlert)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
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
                width: 52,
                height: 52,
                decoration: AppTheme.glowDecoration(
                  color: AppTheme.primaryColor,
                  radius: 26,
                ),
                child: Center(
                  child: Obx(() {
                    final initials = Get.isRegistered<UserController>()
                        ? UserController.to.initials
                        : 'U';
                    return Text(
                      initials,
                      style: AppTheme.titleStyle.copyWith(
                        color: AppTheme.primaryColor,
                        fontSize: 20,
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
    return Obx(
      () => GridView.count(
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
            subtitle: controller.lowStockCount.value > 0
                ? 'Cần nhập thêm'
                : 'Ổn định',
            onTap: () => Get.toNamed(
              Routes.INVENTORY,
              arguments: {'filter': 'low_stock'},
            ),
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
      ),
    );
  }
}

class _QuickNavSection extends GetView<DashboardController> {
  List<_NavItem> _items(
    bool isAdmin,
    bool canStock,
    bool canTx,
    bool canAudit,
  ) => [
    _NavItem(
      Icons.bar_chart_rounded,
      'Báo cáo',
      AppTheme.accentColor,
      Routes.REPORTS,
    ),
    if (canStock || isAdmin)
      _NavItem(
        Icons.add_box_outlined,
        'Thêm SP',
        AppTheme.primaryColor,
        'ADD_PRODUCT',
      ),
    if (canTx)
      _NavItem(
        Icons.south_west_rounded,
        'Nhập kho',
        AppTheme.successColor,
        Routes.CREATE_TRANSACTION,
        'IN',
      ),
    if (canTx)
      _NavItem(
        Icons.north_east_rounded,
        'Xuất kho',
        AppTheme.dangerColor,
        Routes.CREATE_TRANSACTION,
        'OUT',
      ),
    if (canStock || isAdmin)
      _NavItem(
        Icons.inventory_2_outlined,
        'Kho hàng',
        AppTheme.accentColor,
        Routes.INVENTORY,
      ),
    _NavItem(
      Icons.swap_horiz_rounded,
      'Giao dịch',
      AppTheme.primaryColor,
      Routes.TRANSACTIONS,
    ),
    if (canAudit || isAdmin)
      _NavItem(
        Icons.playlist_add_check_rounded,
        'Kiểm kê',
        AppTheme.warningColor,
        Routes.CREATE_AUDIT,
      ),
    if (isAdmin)
      _NavItem(
        Icons.people_outline_rounded,
        'Nhân viên',
        const Color(0xFF9C88FF),
        Routes.ADMIN,
      ),
    _NavItem(
      Icons.person_outline_rounded,
      'Hồ sơ',
      const Color(0xFF6C8EBF),
      Routes.PROFILE,
    ),
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
            children: items
                .asMap()
                .entries
                .map(
                  (e) => FadeSlideItem(
                    index: e.key,
                    child: _NavCell(item: e.value),
                  ),
                )
                .toList(),
          ),
        ],
      );
    });
  }
}

class _NavCell extends GetView<DashboardController> {
  final _NavItem item;
  const _NavCell({required this.item});

  @override
  Widget build(BuildContext context) {
    return ZenithCard(
      padding: EdgeInsets.zero,
      borderColor: item.color.withOpacity(0.15),
      onTap: () {
        if (item.route == 'ADD_PRODUCT') {
          showAddProductSheet(context);
          return;
        }
        if (item.type != null) {
          Get.toNamed(item.route, arguments: item.type);
        } else {
          Get.toNamed(item.route);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
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
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 11,
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



class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
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
              children: List.generate(
                4,
                (i) =>
                    ShimmerBox(width: double.infinity, height: 120, radius: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
