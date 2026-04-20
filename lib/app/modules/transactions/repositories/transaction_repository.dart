import '../providers/transaction_provider.dart';

class TransactionRepository {
  final TransactionProvider _provider;

  TransactionRepository(this._provider);

  Future<List<Map<String, dynamic>>> fetchHistory() async => await _provider.getHistory();

  Future<void> submitTransaction({
    required String type,
    required int warehouseId,
    required String notes,
    required List<Map<String, dynamic>> items,
  }) async {
    final transRes = await _provider.insertTransaction({
      'type': type,
      'user_id': _provider.currentUserId,
      'warehouse_id': warehouseId,
      'notes': notes
    });

    final transId = transRes['id'];
    final itemsToInsert = items.map((item) => {
      'transaction_id': transId,
      'product_id': item['product_id'],
      'batch_id': item['batch_id'],
      'quantity': item['quantity'],
      'unit_price': item['unit_price']
    }).toList();

    await _provider.insertTransactionItems(itemsToInsert);
  }
}
