import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../../../core/theme.dart';
import '../../../core/global_styles.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('QUẢN LÝ NHÂN VIÊN'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.accentColor),
            onPressed: controller.fetchAll,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: FilledButton.icon(
              onPressed: () => _showCreateUserDialog(context, controller),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
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
      body: Obx(() {
        if (controller.isLoading.value && controller.users.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }
        if (controller.users.isEmpty) {
          return const EmptyState(message: 'Chưa có nhân viên nào', icon: Icons.people_outline);
        }
        return RefreshIndicator(
          color: AppTheme.primaryColor,
          backgroundColor: AppTheme.cardColor,
          onRefresh: controller.fetchAll,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: controller.users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => FadeSlideItem(
              index: i,
              child: _UserCard(user: controller.users[i], ctrl: controller),
            ),
          ),
        );
      }),
    );
  }

  void _showCreateUserDialog(BuildContext context, AdminController controller) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    int? selectedRole;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppTheme.borderColor, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(width: 38, height: 38,
                    decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.person_add_alt_1_rounded, color: AppTheme.primaryColor, size: 18)),
                  const SizedBox(width: 12),
                  Text('Tạo tài khoản nhân viên', style: AppTheme.headlineStyle.copyWith(fontSize: 17)),
                ],
              ),
              const SizedBox(height: 24),
              TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                decoration: const InputDecoration(labelText: 'Họ và tên *', prefixIcon: Icon(Icons.person_outline, size: 18))),
              const SizedBox(height: 12),
              TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                decoration: const InputDecoration(labelText: 'Email *', prefixIcon: Icon(Icons.email_outlined, size: 18))),
              const SizedBox(height: 12),
              TextField(controller: passCtrl, obscureText: true,
                style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                decoration: const InputDecoration(labelText: 'Mật khẩu (ít nhất 6 ký tự) *', prefixIcon: Icon(Icons.lock_outline, size: 18))),
              const SizedBox(height: 20),
              Text('Chức vụ *', style: AppTheme.labelStyle.copyWith(color: Colors.white60)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: controller.roles.map((r) {
                  final id = r['id'] as int;
                  final name = r['name'] as String;
                  final sel = selectedRole == id;
                  final roleColor = id == 1 ? AppTheme.dangerColor : id == 2 ? AppTheme.primaryColor : AppTheme.successColor;
                  return GestureDetector(
                    onTap: () => setState(() => selectedRole = sel ? null : id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? roleColor.withOpacity(0.15) : AppTheme.elevatedColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: sel ? roleColor : AppTheme.borderColor),
                      ),
                      child: Text(name, style: TextStyle(color: sel ? roleColor : Colors.white54, fontWeight: sel ? FontWeight.w700 : FontWeight.w400, fontFamily: 'Inter', fontSize: 13)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              Obx(() => ZenithButton(
                label: 'TẠO TÀI KHOẢN',
                icon: Icons.person_add_alt_1_rounded,
                isLoading: controller.isLoading.value,
                onPressed: () {
                  if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.isEmpty || selectedRole == null) {
                    Get.snackbar('Lỗi', 'Vui lòng nhập đầy đủ thông tin'); return;
                  }
                  if (passCtrl.text.length < 6) { Get.snackbar('Lỗi', 'Mật khẩu phải từ 6 ký tự'); return; }
                  controller.createUser(email: emailCtrl.text.trim(), password: passCtrl.text, fullName: nameCtrl.text.trim(), roleId: selectedRole!);
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final AdminController ctrl;
  const _UserCard({required this.user, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final name = user['full_name'] as String? ?? 'Chưa đặt tên';
    final email = user['email'] as String? ?? '';
    final roleId = user['role_id'] as int?;
    final roleName = ctrl.roleName(roleId);
    final whList = ctrl.userWarehouses(user);
    Color roleColor = switch (roleId) {
      1 => AppTheme.dangerColor,
      2 => AppTheme.primaryColor,
      3 => AppTheme.successColor,
      _ => Colors.white38,
    };

    return ZenithCard(
      borderColor: roleColor.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: roleColor.withOpacity(0.25)),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(color: roleColor, fontWeight: FontWeight.w800, fontSize: 18, fontFamily: 'Sora'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTheme.titleStyle.copyWith(fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(email, style: AppTheme.captionStyle.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              ZenithBadge(label: roleName.toUpperCase(), color: roleColor, dot: true),
            ],
          ),
          if (whList.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: whList.map((uw) {
                final wh = uw['warehouses'] as Map<String, dynamic>?;
                final whName = wh?['name'] as String? ?? '';
                final isPrimary = uw['is_primary'] as bool? ?? false;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPrimary ? AppTheme.warningColor.withOpacity(0.1) : AppTheme.elevatedColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isPrimary ? AppTheme.warningColor.withOpacity(0.3) : AppTheme.borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPrimary) ...[
                        const Icon(Icons.star_rounded, size: 10, color: AppTheme.warningColor),
                        const SizedBox(width: 4),
                      ],
                      Text(whName, style: TextStyle(fontSize: 10, color: isPrimary ? AppTheme.warningColor : Colors.white54, fontFamily: 'Inter')),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.manage_accounts_outlined, size: 14),
                  label: const Text('Đổi chức vụ', style: TextStyle(fontSize: 11, fontFamily: 'Inter')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentColor,
                    side: const BorderSide(color: AppTheme.accentColor),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showRoleDialog(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.warehouse_outlined, size: 14),
                  label: const Text('Phân công kho', style: TextStyle(fontSize: 11, fontFamily: 'Inter')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showWarehouseDialog(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRoleDialog(BuildContext context) {
    final userId = user['id'] as String;
    int? selectedRole = user['role_id'] as int?;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Đổi chức vụ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ctrl.roles.map((r) {
              final id = r['id'] as int;
              return RadioListTile<int>(
                title: Text(r['name'] as String, style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Inter')),
                value: id, groupValue: selectedRole,
                activeColor: AppTheme.primaryColor,
                onChanged: (v) => setState(() => selectedRole = v),
              );
            }).toList(),
          ),
          actions: [
            TextButton(onPressed: Get.back, child: const Text('Huỷ')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.black),
              onPressed: () { if (selectedRole != null) ctrl.updateRole(userId, selectedRole!); },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWarehouseDialog(BuildContext context) {
    final userId = user['id'] as String;
    final assigned = ctrl.userWarehouses(user).map((uw) {
      final wh = uw['warehouses'] as Map<String, dynamic>?;
      return wh?['id'] as int?;
    }).whereType<int>().toSet();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Phân công kho'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: ctrl.warehouses.map((wh) {
                final isAssigned = assigned.contains(wh.id);
                return CheckboxListTile(
                  title: Text(wh.name, style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Inter')),
                  subtitle: Text(wh.code, style: const TextStyle(color: Color(0xFF546E7A), fontSize: 11)),
                  value: isAssigned, activeColor: AppTheme.primaryColor,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        assigned.add(wh.id);
                        ctrl.assignWarehouse(userId, wh.id, isPrimary: assigned.length == 1);
                      } else {
                        assigned.remove(wh.id);
                        ctrl.removeWarehouse(userId, wh.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.black),
              onPressed: Get.back, child: const Text('Xong'),
            ),
          ],
        ),
      ),
    );
  }
}
