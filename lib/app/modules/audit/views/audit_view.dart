import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';
import '../controllers/audit_controller.dart';

class AuditView extends GetView<AuditController> {
  const AuditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KIỂM KÊ KHO"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.playlist_add_check_rounded,
              color: AppTheme.primaryColor,
            ),
            onPressed: () => _showNewAuditDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildAuditHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                );
              }
              if (controller.audits.isEmpty) {
                return const Center(
                  child: Text(
                    "Chưa có lịch sử kiểm kê",
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.audits.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final audit = controller.audits[index];
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 400 + (index % 10 * 100)),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: _buildAuditCard(audit),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration(opacity: 0.1).copyWith(
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.05),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.tips_and_updates_outlined,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "Đảm bảo số lượng thực tế khớp với hệ thống thông qua đối soát định kỳ.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditCard(Map<String, dynamic> audit) {
    final variance = (audit['variance'] as num? ?? 0).toInt();
    final date = DateTime.parse(audit['created_at']);
    final isMatch = variance == 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration(
        opacity: 0.03,
      ).copyWith(boxShadow: AppTheme.luxuryShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                audit['products']?['name'] ?? 'Sản phẩm không rõ',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (isMatch ? Colors.greenAccent : Colors.orangeAccent)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (isMatch ? Colors.greenAccent : Colors.orangeAccent)
                        .withOpacity(0.2),
                  ),
                ),
                child: Text(
                  isMatch ? "KHỚP" : "CHÊNH: $variance",
                  style: TextStyle(
                    color: isMatch ? Colors.greenAccent : Colors.orangeAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: Colors.white24),
              const SizedBox(width: 4),
              Text(
                audit['profiles']?['full_name'] ?? 'N/A',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.event_available_outlined,
                size: 14,
                color: Colors.white24,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd/MM/yyyy').format(date),
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          if (audit['adjustment_reason'] != null)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Lý do: ${audit['adjustment_reason']}",
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showNewAuditDialog() {
    Get.snackbar(
      "Tính năng",
      "Giao diện chọn lô hàng và nhập số lượng thực tế đang được hoàn thiện",
      snackPosition: SnackPosition.BOTTOM,
      colorText: Colors.white,
    );
  }
}
