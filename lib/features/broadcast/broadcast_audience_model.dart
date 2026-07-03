class BroadcastAudiencePreview {
  final bool success;
  final String project;
  final int? campaignId;
  final String targetSegment;

  final int totalRecipients;
  final int verifiedRecipients;
  final int pendingRecipients;
  final int validEmailRecipients;

  final double verifiedAmount;
  final int qualified100;
  final int qualified300;
  final int vip500;

  final List<BroadcastAudienceUser> previewUsers;

  const BroadcastAudiencePreview({
    required this.success,
    required this.project,
    required this.campaignId,
    required this.targetSegment,
    required this.totalRecipients,
    required this.verifiedRecipients,
    required this.pendingRecipients,
    required this.validEmailRecipients,
    required this.verifiedAmount,
    required this.qualified100,
    required this.qualified300,
    required this.vip500,
    required this.previewUsers,
  });

  /// Compatibility with old UI names.
  int get count => totalRecipients;
  List<BroadcastAudienceUser> get users => previewUsers;

  BroadcastAudienceSummary get summary => BroadcastAudienceSummary(
        deposited: verifiedRecipients,
        pending: pendingRecipients,
        totalDepositAmount: verifiedAmount,
      );

  factory BroadcastAudiencePreview.fromJson(Map<String, dynamic> json) {
    return BroadcastAudiencePreview(
      success: _toBool(json['success']),
      project: json['project']?.toString() ?? 'moneytherapist',
      campaignId: _toNullableInt(json['campaign_id']),
      targetSegment: json['target_segment']?.toString() ?? 'all_users',
      totalRecipients: _toInt(json['total_recipients'] ?? json['count']),
      verifiedRecipients: _toInt(json['verified_recipients']),
      pendingRecipients: _toInt(json['pending_recipients']),
      validEmailRecipients: _toInt(json['valid_email_recipients']),
      verifiedAmount: _toDouble(json['verified_amount']),
      qualified100: _toInt(json['qualified_100']),
      qualified300: _toInt(json['qualified_300']),
      vip500: _toInt(json['vip_500']),
      previewUsers: _readUsers(json),
    );
  }

  static List<BroadcastAudienceUser> _readUsers(Map<String, dynamic> json) {
    final raw = json['preview_users'] ?? json['users'];

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => BroadcastAudienceUser.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    }

    return const [];
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
    }
    return 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt();
    }
    return null;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final normalized = value.toLowerCase().trim();
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
}

class BroadcastAudienceUser {
  final int id;
  final int? telegramUserId;
  final String? telegramChatId;
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
    required this.telegramUserId,
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
      telegramUserId: _toNullableInt(json['telegram_user_id']),
      telegramChatId: json['telegram_chat_id']?.toString(),
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
    final first = firstName?.trim();
    if (first != null && first.isNotEmpty) return first;

    final username = telegramUsername?.replaceAll('@', '').trim();
    if (username != null && username.isNotEmpty) return '@$username';

    return 'User #$id';
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
    }
    return 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt();
    }
    return null;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final normalized = value.toLowerCase().trim();
      return normalized == 'true' || normalized == 't' || normalized == '1';
    }
    return false;
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}