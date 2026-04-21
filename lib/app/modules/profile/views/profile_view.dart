import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
      appBar: AppBar(title: const Text("HỒ SƠ CÁ NHÂN")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAvatar(),
            const SizedBox(height: 28),
            _buildInfoCard(context, nameCtrl, phoneCtrl),
            const SizedBox(height: 24),
            _buildRoleCard(),
            const SizedBox(height: 32),
            _buildSaveButton(nameCtrl, phoneCtrl),
            const SizedBox(height: 16),
            _buildLogoutButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Obx(() {
      final profile = controller.currentProfile;
      final initials = profile?.initials ?? 'U';
      final name = profile?.displayName ?? 'Người dùng';
      final email = profile?.email ?? '';
      return Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: AppTheme.glowDecoration(
              color: AppTheme.primaryColor,
              radius: 48,
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.outfit(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(name, style: AppTheme.headlineStyle),
          const SizedBox(height: 6),
          Text(email, style: AppTheme.captionStyle),
        ],
      );
    });
  }

  Widget _buildInfoCard(
    BuildContext ctx,
    TextEditingController nameCtrl,
    TextEditingController phoneCtrl,
  ) {
    return ZenithCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: "Thông tin cá nhân"),
          const SizedBox(height: 20),
          TextField(
            controller: nameCtrl,
            onChanged: (v) => controller.fullName.value = v,
            decoration: const InputDecoration(
              labelText: "Họ và tên",
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: phoneCtrl,
            onChanged: (v) => controller.phone.value = v,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: "Số điện thoại",
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard() {
    return Obx(() {
      final profile = controller.currentProfile;
      if (profile == null) return const SizedBox.shrink();
      return ZenithCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: "Thông tin tài khoản"),
            const SizedBox(height: 16),
            _infoRow(Icons.email_outlined, "Email", profile.email ?? '—'),
            const SizedBox(height: 12),
            _infoRow(
              Icons.badge_outlined,
              "Vai trò",
              profile.roleName ?? '—',
              valueColor: AppTheme.primaryColor,
            ),
            const SizedBox(height: 12),
            _infoRow(
              Icons.security_outlined,
              "Trạng thái",
              "Đang hoạt động",
              valueColor: AppTheme.successColor,
            ),
          ],
        ),
      );
    });
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white38),
        const SizedBox(width: 12),
        SizedBox(width: 80, child: Text(label, style: AppTheme.captionStyle)),
        Expanded(
          child: Text(
            value,
            style: AppTheme.captionStyle.copyWith(
              color: valueColor ?? Colors.white70,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(
    TextEditingController nameCtrl,
    TextEditingController phoneCtrl,
  ) {
    return Obx(
      () => ZenithButton(
        label: "LƯU THAY ĐỔI",
        icon: Icons.save_outlined,
        isLoading: controller.isSaving.value,
        onPressed: controller.saveProfile,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ZenithButton(
      label: "ĐĂNG XUẤT",
      gradient: AppTheme.dangerGradient,
      icon: Icons.logout_rounded,
      onPressed: controller.logout,
    );
  }
}
