import 'package:get/get.dart';
import '../controllers/audit_controller.dart';
import '../providers/audit_provider.dart';
import '../repositories/audit_repository.dart';

class AuditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuditProvider>(() => AuditProvider());
    Get.lazyPut<AuditRepository>(() => AuditRepository(Get.find()));
    Get.lazyPut<AuditController>(() => AuditController(Get.find()));
  }
}
