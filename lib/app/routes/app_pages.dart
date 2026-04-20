import 'package:get/get.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/inventory/bindings/inventory_binding.dart';
import '../modules/inventory/views/inventory_view.dart';
import '../modules/transactions/bindings/transaction_binding.dart';
import '../modules/transactions/views/transaction_view.dart';
import '../modules/audit/bindings/audit_binding.dart';
import '../modules/audit/views/audit_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.AUTH;

  static final routes = [
    GetPage(
      name: _Paths.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.INVENTORY,
      page: () => const InventoryView(),
      binding: InventoryBinding(),
    ),
    GetPage(
      name: _Paths.TRANSACTIONS,
      page: () => const TransactionView(),
      binding: TransactionBinding(),
    ),
    GetPage(
      name: _Paths.AUDIT,
      page: () => const AuditView(),
      binding: AuditBinding(),
    ),
  ];
}
