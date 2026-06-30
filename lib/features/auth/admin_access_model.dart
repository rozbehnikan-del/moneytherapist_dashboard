class AdminAccessModel {
  final bool allowed;
  final int? id;
  final int? telegramUserId;
  final String? telegramUsername;
  final String? role;

  const AdminAccessModel({
    required this.allowed,
    required this.id,
    required this.telegramUserId,
    required this.telegramUsername,
    required this.role,
  });

  factory AdminAccessModel.fromJson(Map<String, dynamic> json) {
    final admin = json['admin'];

    if (admin is! Map) {
      return const AdminAccessModel(
        allowed: false,
        id: null,
        telegramUserId: null,
        telegramUsername: null,
        role: null,
      );
    }

    return AdminAccessModel(
      allowed: json['allowed'] == true,
      id: _toNullableInt(admin['id']),
      telegramUserId: _toNullableInt(admin['telegram_user_id']),
      telegramUsername: admin['telegram_username']?.toString(),
      role: admin['role']?.toString(),
    );
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}