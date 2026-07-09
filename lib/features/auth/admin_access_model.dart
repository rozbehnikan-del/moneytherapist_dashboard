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
    final admin = _readAdmin(json);

    return AdminAccessModel(
      allowed: _toBool(json['allowed'] ?? admin?['allowed']),
      id: _toNullableInt(admin?['id'] ?? json['id']),
      telegramUserId: _toNullableInt(
        admin?['telegram_user_id'] ??
            admin?['telegramUserId'] ??
            json['telegram_user_id'] ??
            json['telegramUserId'],
      ),
      telegramUsername: _cleanNullable(
        admin?['telegram_username'] ??
            admin?['telegramUsername'] ??
            json['telegram_username'] ??
            json['telegramUsername'],
      ),
      role: _cleanNullable(admin?['role'] ?? json['role']),
    );
  }

  AdminAccessModel withFallback({
    int? telegramUserId,
    String? telegramUsername,
    String? role,
  }) {
    return AdminAccessModel(
      allowed: allowed,
      id: id,
      telegramUserId: this.telegramUserId ?? telegramUserId,
      telegramUsername: this.telegramUsername ?? telegramUsername,
      role: this.role ?? role,
    );
  }

  static Map<String, dynamic>? _readAdmin(Map<String, dynamic> json) {
    final admin = json['admin'];
    if (admin is Map) return Map<String, dynamic>.from(admin);

    final data = json['data'];
    if (data is Map) {
      final nestedAdmin = data['admin'];
      if (nestedAdmin is Map) return Map<String, dynamic>.from(nestedAdmin);
      return Map<String, dynamic>.from(data);
    }

    if (json.containsKey('telegram_user_id') ||
        json.containsKey('telegramUserId') ||
        json.containsKey('telegram_username') ||
        json.containsKey('telegramUsername') ||
        json.containsKey('role')) {
      return json;
    }

    return null;
  }

  static bool _toBool(dynamic value) {
    if (value == true) return true;
    if (value is num) return value != 0;
    if (value is String) {
      final text = value.trim().toLowerCase();
      return text == 'true' || text == '1' || text == 'yes';
    }
    return false;
  }

  static String? _cleanNullable(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty ||
        text.toLowerCase() == 'null' ||
        text.toLowerCase() == 'undefined') {
      return null;
    }
    return text;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
