class BroadcastAudiencePreview {
  final bool success;
  final int? campaignId;
  final String targetSegment;
  final int count;
  final List<BroadcastAudienceUser> users;
  final BroadcastAudienceSummary summary;

  const BroadcastAudiencePreview({
    required this.success,
    required this.campaignId,
    required this.targetSegment,
    required this.count,
    required this.users,
    required this.summary,
  });

  factory BroadcastAudiencePreview.fromJson(Map<String, dynamic> json) {
    return BroadcastAudiencePreview(
      success: _toBool(json['success']),
      campaignId: _toNullableInt(json['campaign_id']),
      targetSegment: json['target_segment']?.toString() ?? '',
      count: _toInt(json['count']),
      users: json['users'] is List
          ? (json['users'] as List)
              .whereType<Map<String, dynamic>>()
              .map(BroadcastAudienceUser.fromJson)
              .toList()
          : [],
      summary: json['summary'] is Map<String, dynamic>
          ? BroadcastAudienceSummary.fromJson(
              json['summary'] as Map<String, dynamic>,
            )
          : const BroadcastAudienceSummary(
              deposited: 0,
              pending: 0,
              totalDepositAmount: 0,
            ),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
    }
    return 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt();
    }
    return null;
  }

  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final normalized = value.toLowerCase();
      return normalized == 'true' || normalized == 't' || normalized == '1';
    }
    return false;
  }
}

class BroadcastAudienceSummary {
  final int deposited;
  final int pending;
  final double totalDepositAmount;

  const BroadcastAudienceSummary({
    required this.deposited,
    required this.pending,
    required this.totalDepositAmount,
  });

  factory BroadcastAudienceSummary.fromJson(Map<String, dynamic> json) {
    return BroadcastAudienceSummary(
      deposited: _toInt(json['deposited']),
      pending: _toInt(json['pending']),
      totalDepositAmount: _toDouble(json['total_deposit_amount']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
    }
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}

class BroadcastAudienceUser {
  final int id;
  final int? telegramChatId;
  final String? telegramUsername;
  final String? firstName;
  final String? email;
  final bool depositCompleted;
  final double depositAmount;
  final String? leadStatus;
  final String? leadSegment;
  final int leadScore;
  final int? campaignId;
  final DateTime? lastMessageAt;

  const BroadcastAudienceUser({
    required this.id,
    required this.telegramChatId,
    required this.telegramUsername,
    required this.firstName,
    required this.email,
    required this.depositCompleted,
    required this.depositAmount,
    required this.leadStatus,
    required this.leadSegment,
    required this.leadScore,
    required this.campaignId,
    required this.lastMessageAt,
  });

  factory BroadcastAudienceUser.fromJson(Map<String, dynamic> json) {
    return BroadcastAudienceUser(
      id: _toInt(json['id']),
      telegramChatId: _toNullableInt(json['telegram_chat_id']),
      telegramUsername: json['telegram_username']?.toString(),
      firstName: json['first_name']?.toString(),
      email: json['email']?.toString(),
      depositCompleted: _toBool(json['deposit_completed']),
      depositAmount: _toDouble(json['deposit_amount']),
      leadStatus: json['lead_status']?.toString(),
      leadSegment: json['lead_segment']?.toString(),
      leadScore: _toInt(json['lead_score']),
      campaignId: _toNullableInt(json['campaign_id']),
      lastMessageAt: _toDate(json['last_message_at']),
    );
  }

  String get displayName {
    if (firstName != null && firstName!.trim().isNotEmpty) {
      return firstName!;
    }

    if (telegramUsername != null && telegramUsername!.trim().isNotEmpty) {
      return '@$telegramUsername';
    }

    return 'User #$id';
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
    }
    return 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt();
    }
    return null;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final normalized = value.toLowerCase();
      return normalized == 'true' || normalized == 't' || normalized == '1';
    }
    return false;
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}