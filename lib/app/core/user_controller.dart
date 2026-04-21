import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/user_model.dart';

class UserController extends GetxController {
  static UserController get to => Get.find();
  final Rx<UserProfile?> profile = Rx<UserProfile?>(null);
  final isLoading = false.obs;
  final _supabase = Supabase.instance.client;
  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      final profileData = await _supabase
          .from('profiles')
          .select(
            '*, roles(name, can_view_all_warehouses, can_manage_products, can_manage_users, can_create_transaction, can_audit)',
          )
          .eq('id', userId)
          .single();
      final warehouseData = await _supabase
          .from('user_warehouses')
          .select('is_primary, warehouses(id, code, name, location)')
          .eq('user_id', userId);
      final email = _supabase.auth.currentUser?.email;
      final p = UserProfile.fromJson({...profileData, 'email': email});
      final whs = (warehouseData as List<dynamic>)
          .map((e) => WarehouseAccess.fromJson(e as Map<String, dynamic>))
          .toList();
      profile.value = p.copyWithWarehouses(whs);
    } catch (e, stack) {
      print("fetchProfile ERROR: $e");
      print(stack);
      Get.snackbar(
        "Lỗi",
        "Không thể tải cấu hình tài khoản: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String get displayName => profile.value?.displayName ?? 'Người dùng';
  String get initials => profile.value?.initials ?? 'U';
  String? get roleName => profile.value?.roleName;
  bool get isAdmin => profile.value?.canViewAllWarehouses ?? false;
  bool get canManageProducts => profile.value?.canManageProducts ?? false;
  bool get canManageUsers => profile.value?.canManageUsers ?? false;
  bool get canCreateTx => profile.value?.canCreateTransaction ?? false;
  bool get canAudit => profile.value?.canAudit ?? false;
  List<int> get warehouseIds => profile.value?.warehouseIds ?? [];
  List<WarehouseAccess> get warehouses => profile.value?.warehouses ?? [];
  WarehouseAccess? get primaryWarehouse => profile.value?.primaryWarehouse;
  void clear() => profile.value = null;
}
