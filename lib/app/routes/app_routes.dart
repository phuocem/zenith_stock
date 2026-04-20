part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const DASHBOARD = _Paths.DASHBOARD;
  static const AUTH = _Paths.AUTH;
  static const INVENTORY = _Paths.INVENTORY;
  static const TRANSACTIONS = _Paths.TRANSACTIONS;
  static const AUDIT = _Paths.AUDIT;
}

abstract class _Paths {
  _Paths._();
  static const DASHBOARD = '/dashboard';
  static const AUTH = '/auth';
  static const INVENTORY = '/inventory';
  static const TRANSACTIONS = '/transactions';
  static const AUDIT = '/audit';
}
