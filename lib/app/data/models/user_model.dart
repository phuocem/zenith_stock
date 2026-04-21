class UserProfile {
  final String id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final int? roleId;
  final String? roleName;

  const UserProfile({
    required this.id,
    this.fullName,
    this.email,
    this.phone,
    this.avatarUrl,
    this.roleId,
    this.roleName,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      roleId: json['role_id'] as int?,
      roleName: (json['roles'] as Map<String, dynamic>?)?['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'email': email,
    'phone': phone,
    'avatar_url': avatarUrl,
    'role_id': roleId,
  };

  String get displayName => fullName?.isNotEmpty == true ? fullName! : (email ?? 'Người dùng');
  String get initials {
    if (fullName?.isNotEmpty == true) {
      final parts = fullName!.trim().split(' ');
      if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      return parts.first[0].toUpperCase();
    }
    return email?.isNotEmpty == true ? email![0].toUpperCase() : 'U';
  }

  UserProfile copyWith({String? fullName, String? phone, String? avatarUrl}) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      roleId: roleId,
      roleName: roleName,
    );
  }
}
