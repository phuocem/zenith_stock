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
      appBar: AppBar(
        title: const Text("QUẢN LÝ NHÂN VIÊN"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppTheme.accentColor,
            ),
            onPressed: controller.fetchAll,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.black),
        label: const Text(
          "Tạo nhân viên",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showCreateUserDialog(context, controller),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.users.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }
        if (controller.users.isEmpty) {
          return const EmptyState(
            message: "Chưa có nhân viên nào",
            icon: Icons.people_outline,
          );
        }
        return RefreshIndicator(
          color: AppTheme.primaryColor,
          backgroundColor: AppTheme.cardColor,
          onRefresh: controller.fetchAll,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: controller.users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) =>
                _UserCard(user: controller.users[i], ctrl: controller),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tạo tài khoản nhân viên",
                style: AppTheme.headlineStyle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Họ và tên *"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "Email *"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Mật khẩu (ít nhất 6 ký tự) *",
                ),
              ),
              const SizedBox(height: 20),
              const Text("Chức vụ *", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: controller.roles.map((r) {
                  final id = r['id'] as int;
                  final name = r['name'] as String;
                  final sel = selectedRole == id;
                  return ChoiceChip(
                    label: Text(name),
                    selected: sel,
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    backgroundColor: AppTheme.elevatedColor,
                    onSelected: (val) =>
                        setState(() => selectedRole = val ? id : null),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              Obx(
                () => ZenithButton(
                  label: "TẠO TÀI KHOẢN",
                  isLoading: controller.isLoading.value,
                  onPressed: () {
                    if (nameCtrl.text.isEmpty ||
                        emailCtrl.text.isEmpty ||
                        passCtrl.text.isEmpty ||
                        selectedRole == null) {
                      Get.snackbar("Lỗi", "Vui lòng nhập đầy đủ thông tin");
                      return;
                    }
                    if (passCtrl.text.length < 6) {
                      Get.snackbar("Lỗi", "Mật khẩu phải từ 6 ký tự");
                      return;
                    }
                    controller.createUser(
                      email: emailCtrl.text.trim(),
                      password: passCtrl.text,
                      fullName: nameCtrl.text.trim(),
                      roleId: selectedRole!,
                    );
                  },
                ),
              ),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration(
        borderColor: roleColor.withValues(alpha: 0.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: roleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTheme.titleStyle.copyWith(fontSize: 14),
                    ),
                    Text(
                      email,
                      style: AppTheme.captionStyle.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              ZenithBadge(label: roleName.toUpperCase(), color: roleColor),
            ],
          ),
          if (whList.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: whList.map((uw) {
                final wh = uw['warehouses'] as Map<String, dynamic>?;
                final whName = wh?['name'] as String? ?? '';
                final isPrimary = uw['is_primary'] as bool? ?? false;
                return Chip(
                  label: Text(
                    whName,
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                  avatar: isPrimary
                      ? const Icon(
                          Icons.star,
                          size: 12,
                          color: AppTheme.warningColor,
                        )
                      : null,
                  backgroundColor: AppTheme.elevatedColor,
                  side: const BorderSide(color: Colors.white12),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.manage_accounts_outlined, size: 16),
                  label: const Text(
                    "Đổi chức vụ",
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentColor,
                    side: const BorderSide(
                      color: AppTheme.accentColor,
                      width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () => _showRoleDialog(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.warehouse_outlined, size: 16),
                  label: const Text(
                    "Phân công kho",
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
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
          backgroundColor: AppTheme.cardColor,
          title: const Text(
            "Đổi chức vụ",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ctrl.roles.map((r) {
              final id = r['id'] as int;
              return RadioListTile<int>(
                title: Text(
                  r['name'] as String,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                value: id,
                groupValue: selectedRole,
                activeColor: AppTheme.primaryColor,
                onChanged: (v) => setState(() => selectedRole = v),
              );
            }).toList(),
          ),
          actions: [
            TextButton(onPressed: Get.back, child: const Text("Huỷ")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              onPressed: () {
                if (selectedRole != null)
                  ctrl.updateRole(userId, selectedRole!);
              },
              child: const Text("Lưu"),
            ),
          ],
        ),
      ),
    );
  }

  void _showWarehouseDialog(BuildContext context) {
    final userId = user['id'] as String;
    final assigned = ctrl
        .userWarehouses(user)
        .map((uw) {
          final wh = uw['warehouses'] as Map<String, dynamic>?;
          return wh?['id'] as int?;
        })
        .whereType<int>()
        .toSet();
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text(
            "Phân công kho",
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: ctrl.warehouses.map((wh) {
                final isAssigned = assigned.contains(wh.id);
                return CheckboxListTile(
                  title: Text(
                    wh.name,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  subtitle: Text(
                    wh.code,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  value: isAssigned,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        assigned.add(wh.id);
                        ctrl.assignWarehouse(
                          userId,
                          wh.id,
                          isPrimary: assigned.length == 1,
                        );
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              onPressed: Get.back,
              child: const Text("Xong"),
            ),
          ],
        ),
      ),
    );
  }
}
