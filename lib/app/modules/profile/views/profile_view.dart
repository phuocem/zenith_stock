import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../core/theme.dart';
import '../../../core/global_styles.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController(text: controller.fullName.value);
    final phoneCtrl = TextEditingController(text: controller.phone.value);

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('HỒ SƠ CÁ NHÂN'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppTheme.borderColor)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _ProfileHero(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoCard(nameCtrl: nameCtrl, phoneCtrl: phoneCtrl),
                  const SizedBox(height: 16),
                  _AccountCard(),
                  const SizedBox(height: 24),
                  _SaveButton(nameCtrl: nameCtrl, phoneCtrl: phoneCtrl),
                  const SizedBox(height: 12),
                  _LogoutButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHero extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profile = controller.currentProfile;
      final initials = profile?.initials ?? 'U';
      final name = profile?.displayName ?? 'Người dùng';
      final email = profile?.email ?? '';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          border: const Border(bottom: BorderSide(color: AppTheme.borderColor)),
        ),
        child: Column(
          children: [
            GlowPulse(
              color: AppTheme.primaryColor,
              child: Container(
                width: 88, height: 88,
                decoration: AppTheme.glowDecoration(color: AppTheme.primaryColor, radius: 44),
                child: Center(
                  child: Text(
                    initials,
                    style: AppTheme.headlineStyle.copyWith(
                      color: AppTheme.primaryColor, fontSize: 34, fontFamily: 'Sora',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(name, style: AppTheme.headlineStyle.copyWith(fontSize: 20)),
            const SizedBox(height: 4),
            Text(email, style: AppTheme.captionStyle),
            const SizedBox(height: 12),
            ZenithBadge(label: 'ĐANG HOẠT ĐỘNG', color: AppTheme.successColor, dot: true),
          ],
        ),
      );
    });
  }
}

class _InfoCard extends GetView<ProfileController> {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  const _InfoCard({required this.nameCtrl, required this.phoneCtrl});

  @override
  Widget build(BuildContext context) {
    return ZenithCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Thông tin cá nhân'),
          const SizedBox(height: 20),
          TextField(
            controller: nameCtrl,
            onChanged: (v) => controller.fullName.value = v,
            enabled: controller.isAdmin,
            style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
            decoration: InputDecoration(
              labelText: 'Họ và tên',
              prefixIcon: const Icon(Icons.person_outline, size: 18),
              suffixIcon: !controller.isAdmin ? const Icon(Icons.lock_outline, size: 16, color: Colors.white24) : null,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: phoneCtrl,
            onChanged: (v) => controller.phone.value = v,
            enabled: controller.isAdmin,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
            decoration: InputDecoration(
              labelText: 'Số điện thoại',
              prefixIcon: const Icon(Icons.phone_outlined, size: 18),
              suffixIcon: !controller.isAdmin ? const Icon(Icons.lock_outline, size: 16, color: Colors.white24) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profile = controller.currentProfile;
      if (profile == null) return const SizedBox.shrink();
      return ZenithCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Thông tin tài khoản'),
            const SizedBox(height: 16),
            _InfoRow(Icons.email_outlined, 'Email', profile.email ?? '—'),
            const ZenithDivider(),
            _InfoRow(Icons.badge_outlined, 'Vai trò', profile.roleName ?? '—', valueColor: AppTheme.primaryColor),
            const ZenithDivider(),
            _InfoRow(Icons.security_outlined, 'Trạng thái', 'Đang hoạt động', valueColor: AppTheme.successColor),
          ],
        ),
      );
    });
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow(this.icon, this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF546E7A)),
          const SizedBox(width: 12),
          SizedBox(width: 80, child: Text(label, style: AppTheme.captionStyle)),
          Expanded(
            child: Text(
              value,
              style: AppTheme.captionStyle.copyWith(color: valueColor ?? Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends GetView<ProfileController> {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  const _SaveButton({required this.nameCtrl, required this.phoneCtrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isAdmin) return const SizedBox.shrink();
      return ZenithButton(
        label: 'LƯU THAY ĐỔI',
        icon: Icons.save_outlined,
        isLoading: controller.isSaving.value,
        onPressed: controller.saveProfile,
      );
    });
  }
}

class _LogoutButton extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return ZenithButton(
      label: 'ĐĂNG XUẤT',
      gradient: AppTheme.dangerGradient,
      icon: Icons.logout_rounded,
      onPressed: controller.logout,
    );
  }
}
