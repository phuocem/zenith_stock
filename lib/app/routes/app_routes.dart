part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const AUTH = _Paths.AUTH;
  static const DASHBOARD = _Paths.DASHBOARD;
  static const INVENTORY = _Paths.INVENTORY;
  static const PRODUCT_DETAIL = _Paths.PRODUCT_DETAIL;
  static const TRANSACTIONS = _Paths.TRANSACTIONS;
  static const CREATE_TRANSACTION = _Paths.CREATE_TRANSACTION;
  static const AUDIT = _Paths.AUDIT;
  static const CREATE_AUDIT = _Paths.CREATE_AUDIT;
  static const PROFILE = _Paths.PROFILE;
  static const ADMIN = _Paths.ADMIN;
}

abstract class _Paths {
  _Paths._();
  static const AUTH = '/auth';
  static const DASHBOARD = '/dashboard';
  static const INVENTORY = '/inventory';
  static const PRODUCT_DETAIL = '/inventory/detail';
  static const TRANSACTIONS = '/transactions';
  static const CREATE_TRANSACTION = '/transactions/create';
  static const AUDIT = '/audit';
  static const CREATE_AUDIT = '/audit/create';
  static const PROFILE = '/profile';
  static const ADMIN = '/admin';
}
