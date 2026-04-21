import '../providers/dashboard_provider.dart';

class DashboardRepository {
  final DashboardProvider _provider;

  DashboardRepository(this._provider);

  Future<Map<String, dynamic>> getSummaryData() async {
    const days = 7;
    final now = DateTime.now();

    final results = await Future.wait([
      _provider.getInventorySummary(),
      _provider.getTransactionsLastDays(days),
      _provider.getTopProducts(5),
    ]);

    final inventory   = results[0] as List;
    final transactions = results[1] as List;
    final topProducts  = results[2] as List;

    int totalStock   = 0;
    int lowStockCount = 0;
    for (final item in inventory) {
      totalStock += (item['total_stock'] as num? ?? 0).toInt();
      if (item['status'] == 'LOW') lowStockCount++;
    }

    int inbound  = 0;
    int outbound = 0;
    final chartData = List<double>.filled(days, 0.0);

    for (final t in transactions) {
      final items = t['transaction_items'] as List? ?? [];
      final qty = items.fold<int>(0, (s, i) => s + ((i['quantity'] as num?)?.toInt() ?? 0));

      if (t['type'] == 'IN')  inbound  += qty;
      if (t['type'] == 'OUT') outbound += qty;

      try {
        final tDate = DateTime.parse(t['created_at']).toLocal();
        final diff  = now.difference(tDate).inDays;
        if (diff >= 0 && diff < days) {
          chartData[days - 1 - diff] += qty.toDouble();
        }
      } catch (_) {}
    }

    return {
      'totalStock':       totalStock,
      'lowStockCount':    lowStockCount,
      'inboundThisWeek':  inbound,
      'outboundThisWeek': outbound,
      'chartData':        chartData,
      'topProducts':      topProducts,
    };
  }

  Future<void> logout() async => _provider.signOut();
}
