class CampaignLeadModel {
  final int id;
  final int? telegramUserId;
  final int? telegramChatId;
  final String? telegramUsername;
  final String? firstName;
  final String? email;
  final bool depositCompleted;
  final double depositAmount;
  final int accessTier;
  final bool introSent;
  final bool firstNoticeSent;
  final bool telegramVerified;
  final bool emailVerified;
  final DateTime? firstSeenAt;
  final DateTime? lastMessageAt;
  final int? campaignId;

  const CampaignLeadModel({
    required this.id,
    required this.telegramUserId,
    required this.telegramChatId,
    required this.telegramUsername,
    required this.firstName,
    required this.email,
    required this.depositCompleted,
    required this.depositAmount,
    required this.accessTier,
    required this.introSent,
    required this.firstNoticeSent,
    required this.telegramVerified,
    required this.emailVerified,
    required this.firstSeenAt,
    required this.lastMessageAt,
    required this.campaignId,
  });

  factory CampaignLeadModel.fromJson(Map<String, dynamic> json) {
    return CampaignLeadModel(
      id: _toInt(json['id']),
      telegramUserId: _toNullableInt(json['telegram_user_id']),
      telegramChatId: _toNullableInt(json['telegram_chat_id']),
      telegramUsername: json['telegram_username']?.toString(),
      firstName: json['first_name']?.toString(),
      email: json['email']?.toString(),
      depositCompleted: _toBool(json['deposit_completed']),
      depositAmount: _toDouble(json['deposit_amount']),
      accessTier: _toInt(json['access_tier']),
      introSent: _toBool(json['intro_sent']),
      firstNoticeSent: _toBool(json['first_notice_sent']),
      telegramVerified: _toBool(json['telegram_verified']),
      emailVerified: _toBool(json['email_verified']),
      firstSeenAt: _toDate(json['first_seen_at']),
      lastMessageAt: _toDate(json['last_message_at']),
      campaignId: _toNullableInt(json['campaign_id']),
    );
  }

  String get displayName {
    if (firstName != null && firstName!.trim().isNotEmpty) {
      return firstName!;
    }

    if (telegramUsername != null && telegramUsername!.trim().isNotEmpty) {
      return '@$telegramUsername';
    }

    return 'Lead #$id';
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
