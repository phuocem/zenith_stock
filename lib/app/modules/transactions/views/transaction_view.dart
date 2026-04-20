import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/transaction_controller.dart';
import '../../../core/theme.dart';

class TransactionView extends GetView<TransactionController> {
  const TransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GIAO DỊCH KHO"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppTheme.primaryColor),
            onPressed: controller.fetchHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildQuickActions(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Text("Lịch sử gần đây", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
              }
              if (controller.history.isEmpty) {
                return const Center(child: Text("Chưa có giao dịch nào", style: TextStyle(color: Colors.white54)));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.history.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final trans = controller.history[index];
                  // Hiệu ứng xuất hiện mượt mà
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
                    child: _buildTransactionCard(trans),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              "NHẬP KHO", 
              Icons.add_shopping_cart_rounded, 
              Colors.greenAccent, 
              () => _showTransactionForm("IN")
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionButton(
              "XUẤT KHO", 
              Icons.local_shipping_outlined, 
              Colors.redAccent, 
              () => _showTransactionForm("OUT")
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: AppTheme.glassDecoration(opacity: 0.04).copyWith(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                title, 
                style: GoogleFonts.outfit(
                  color: color, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> trans) {
    final bool isAddition = trans['type'] == 'IN';
    final date = DateTime.parse(trans['created_at']);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration(opacity: 0.03).copyWith(
        boxShadow: AppTheme.luxuryShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isAddition ? Colors.greenAccent : Colors.redAccent).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isAddition ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: isAddition ? Colors.greenAccent : Colors.redAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAddition ? "Phiếu Nhập Kho" : "Phiếu Xuất Kho",
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Bởi: ${trans['profiles']?['full_name'] ?? 'N/A'}",
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isAddition ? "+ NHẬP" : "- XUẤT",
                style: GoogleFonts.outfit(
                  color: isAddition ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                DateFormat('dd/MM HH:mm').format(date),
                style: const TextStyle(color: Colors.white24, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTransactionForm(String type) {
    Get.snackbar("Tính năng", "Giao diện chọn sản phẩm và tạo phiếu $type đang được hoàn thiện", 
        snackPosition: SnackPosition.BOTTOM, colorText: Colors.white);
  }
}
