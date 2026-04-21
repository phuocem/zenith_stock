class WarehouseAccess {
  final int id;
  final String code;
  final String name;
  final String? location;
  final bool isPrimary;
  const WarehouseAccess({
    required this.id,
    required this.code,
    required this.name,
    this.location,
    this.isPrimary = false,
  });
  factory WarehouseAccess.fromJson(Map<String, dynamic> json) {
    final wh = json['warehouses'] as Map<String, dynamic>? ?? json;
    return WarehouseAccess(
      id: wh['id'] as int,
      code: wh['code'] as String? ?? '',
      name: wh['name'] as String? ?? '',
      location: wh['location'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }
}

class UserProfile {
  final String id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final int? roleId;
  final String? roleName;
  final bool canViewAllWarehouses;
  final bool canManageProducts;
  final bool canManageUsers;
  final bool canCreateTransaction;
  final bool canAudit;
  final List<WarehouseAccess> warehouses;
  const UserProfile({
    required this.id,
    this.fullName,
    this.email,
    this.phone,
    this.avatarUrl,
    this.roleId,
    this.roleName,
    this.canViewAllWarehouses = false,
    this.canManageProducts = false,
    this.canManageUsers = false,
    this.canCreateTransaction = true,
    this.canAudit = false,
    this.warehouses = const [],
  });
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final role = json['roles'] as Map<String, dynamic>?;
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      roleId: json['role_id'] as int?,
      roleName: role?['name'] as String?,
      canViewAllWarehouses: role?['can_view_all_warehouses'] as bool? ?? false,
      canManageProducts: role?['can_manage_products'] as bool? ?? false,
      canManageUsers: role?['can_manage_users'] as bool? ?? false,
      canCreateTransaction: role?['can_create_transaction'] as bool? ?? true,
      canAudit: role?['can_audit'] as bool? ?? false,
    );
  }
  UserProfile copyWithWarehouses(List<WarehouseAccess> whs) => UserProfile(
    id: id,
    fullName: fullName,
    email: email,
    phone: phone,
    avatarUrl: avatarUrl,
    roleId: roleId,
    roleName: roleName,
    canViewAllWarehouses: canViewAllWarehouses,
    canManageProducts: canManageProducts,
    canManageUsers: canManageUsers,
    canCreateTransaction: canCreateTransaction,
    canAudit: canAudit,
    warehouses: whs,
  );
  UserProfile copyWith({String? fullName, String? phone, String? avatarUrl}) =>
      UserProfile(
        id: id,
        fullName: fullName ?? this.fullName,
        email: email,
        phone: phone ?? this.phone,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        roleId: roleId,
        roleName: roleName,
        canViewAllWarehouses: canViewAllWarehouses,
        canManageProducts: canManageProducts,
        canManageUsers: canManageUsers,
        canCreateTransaction: canCreateTransaction,
        canAudit: canAudit,
        warehouses: warehouses,
      );
  String get displayName =>
      fullName?.isNotEmpty == true ? fullName! : (email ?? 'Người dùng');
  String get initials {
    if (fullName?.isNotEmpty == true) {
      final parts = fullName!.trim().split(' ');
      if (parts.length >= 2)
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      return parts.first[0].toUpperCase();
    }
    return email?.isNotEmpty == true ? email![0].toUpperCase() : 'U';
  }

  List<int> get warehouseIds => warehouses.map((w) => w.id).toList();
  WarehouseAccess? get primaryWarehouse =>
      warehouses.where((w) => w.isPrimary).firstOrNull ??
      warehouses.firstOrNull;
}
