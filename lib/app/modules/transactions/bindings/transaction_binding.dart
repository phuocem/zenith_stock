import 'package:get/get.dart';
import '../controllers/transaction_controller.dart';
import '../providers/transaction_provider.dart';
import '../repositories/transaction_repository.dart';

class TransactionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionProvider>(() => TransactionProvider());
    Get.lazyPut<TransactionRepository>(() => TransactionRepository(Get.find()));
    Get.lazyPut<TransactionController>(() => TransactionController(Get.find()));
  }
}
