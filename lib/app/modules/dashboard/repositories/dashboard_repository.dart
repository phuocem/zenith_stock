import '../providers/dashboard_provider.dart';

class DashboardRepository {
  final DashboardProvider _provider;
  DashboardRepository(this._provider);
  Future<Map<String, dynamic>> getSummaryData({int? warehouseId}) async {
    const days = 7;
    final now = DateTime.now();
    final statsRes = await _provider.getDashboardStats(
      warehouseId: warehouseId,
    );
    int totalStock = 0;
    int lowStockCount = 0;
    int outOfStock = 0;
    for (final r in statsRes) {
      totalStock += (r['total_stock'] as num? ?? 0).toInt();
      lowStockCount += (r['low_stock'] as num? ?? 0).toInt();
      outOfStock += (r['out_of_stock'] as num? ?? 0).toInt();
    }
    final transactions = await _provider.getTransactionsLastDays(
      days,
      warehouseId: warehouseId,
    );
    int inbound = 0;
    int outbound = 0;
    final chartData = List<double>.filled(days, 0.0);
    for (final t in transactions) {
      final items = t['transaction_items'] as List? ?? [];
      final qty = items.fold<int>(
        0,
        (s, i) => s + ((i['quantity'] as num?)?.toInt() ?? 0),
      );
      if (t['type'] == 'IN') inbound += qty;
      if (t['type'] == 'OUT') outbound += qty;
      try {
        final tDate = DateTime.parse(t['created_at']).toLocal();
        final diff = now.difference(tDate).inDays;
        if (diff >= 0 && diff < days)
          chartData[days - 1 - diff] += qty.toDouble();
      } catch (_) {}
    }
    final topProducts = await _provider.getTopProducts(
      5,
      warehouseId: warehouseId,
    );
    return {
      'totalStock': totalStock,
      'lowStockCount': lowStockCount,
      'outOfStockCount': outOfStock,
      'inboundThisWeek': inbound,
      'outboundThisWeek': outbound,
      'chartData': chartData,
      'topProducts': topProducts,
    };
  }

  Future<void> logout() async => _provider.signOut();
}
