import '../providers/dashboard_provider.dart';

class DashboardRepository {
  final DashboardProvider _provider;

  DashboardRepository(this._provider);

  Future<Map<String, dynamic>> getSummaryData() async {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));

    final results = await Future.wait([
      _provider.getInventorySummary(),
      _provider.getTransactions(oneWeekAgo),
      _provider.getTopProducts(5),
    ]);

    final inventory = results[0] as List;
    final transactions = results[1] as List;
    final topProducts = results[2] as List;

    int totalStock = 0;
    int lowStockCount = 0;
    for (var item in inventory) {
      totalStock += (item['total_stock'] as num? ?? 0).toInt();
      if (item['status'] == 'LOW') lowStockCount++;
    }

    int inbound = 0;
    int outbound = 0;
    List<double> chartData = List.filled(7, 0.0);
    
    for (var t in transactions) {
      final items = t['transaction_items'] as List? ?? [];
      int qty = items.fold<int>(0, (sum, i) => sum + (i['quantity'] as int? ?? 0));
      
      if (t['type'] == 'IN') inbound += qty;
      else outbound += qty;

      for (int i = 0; i < 7; i++) {
        final day = oneWeekAgo.add(Duration(days: i + 1));
        final dayStr = day.toIso8601String().split('T')[0];
        if (t['created_at'].contains(dayStr)) {
          chartData[i] += qty.toDouble();
        }
      }
    }

    return {
      'totalStock': totalStock,
      'lowStockCount': lowStockCount,
      'inboundThisWeek': inbound,
      'outboundThisWeek': outbound,
      'chartData': chartData,
      'topProducts': topProducts,
    };
  }

  Future<void> logout() async => await _provider.signOut();
}
