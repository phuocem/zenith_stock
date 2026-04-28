import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme.dart';
import '../../../core/global_styles.dart';
import '../controllers/reports_controller.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('BÁO CÁO THỐNG KÊ', style: TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.borderColor),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }
        return RefreshIndicator(
          onRefresh: controller.fetchReportData,
          color: AppTheme.primaryColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Xu hướng nhập xuất 7 ngày'),
                const SizedBox(height: 16),
                _buildMainChart(),
                const SizedBox(height: 24),
                _buildSummaryStats(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMainChart() {
    return ZenithCard(
      borderColor: AppTheme.primaryColor.withOpacity(0.12),
      child: Column(
        children: [
          Row(
            children: [
              _ChartLegend(color: AppTheme.successColor, label: 'Nhập kho'),
              const SizedBox(width: 20),
              _ChartLegend(color: AppTheme.dangerColor, label: 'Xuất kho'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(color: AppTheme.borderColor, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('T${v.toInt() + 1}', style: AppTheme.monoStyle.copyWith(fontSize: 10)),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // INBOUND LINE (GREEN) - RUNS UP
                  _buildLineData(controller.inboundChartData, AppTheme.successColor, false),
                  // OUTBOUND LINE (RED) - RUNS DOWN
                  _buildLineData(controller.outboundChartData, AppTheme.dangerColor, true),
                ],
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(y: 0, color: Colors.white24, strokeWidth: 1.5, dashArray: [5, 5]),
                  ],
                ),
              ),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildLineData(List<double> data, Color color, bool isNegative) {
    return LineChartBarData(
      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), isNegative ? -e.value : e.value)).toList(),
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
          radius: 3,
          color: color,
          strokeColor: AppTheme.bgColor,
          strokeWidth: 2,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: isNegative ? Alignment.bottomCenter : Alignment.topCenter,
          end: isNegative ? Alignment.topCenter : Alignment.bottomCenter,
          colors: [color.withOpacity(0.15), Colors.transparent],
        ),
      ),
    );
  }

  Widget _buildSummaryStats() {
    final totalIn = controller.inboundChartData.fold<double>(0, (p, c) => p + c);
    final totalOut = controller.outboundChartData.fold<double>(0, (p, c) => p + c);

    return Row(
      children: [
        Expanded(
          child: _StatBox(
            label: 'TỔNG NHẬP (7D)',
            value: totalIn.toInt().toString(),
            color: AppTheme.successColor,
            icon: Icons.south_west_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatBox(
            label: 'TỔNG XUẤT (7D)',
            value: totalOut.toInt().toString(),
            color: AppTheme.dangerColor,
            icon: Icons.north_east_rounded,
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatBox({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ZenithCard(
      borderColor: color.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(value, style: AppTheme.numberStyle.copyWith(color: color, fontSize: 24)),
          const SizedBox(height: 4),
          Text(label, style: AppTheme.labelStyle.copyWith(fontSize: 10, color: Colors.white38)),
        ],
      ),
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
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTheme.captionStyle.copyWith(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
