class BroadcastModel {
  final int id;
  final int? campaignId;
  final String? campaignName;
  final String title;
  final String messageType;
  final String targetSegment;
  final String messageText;
  final String? mediaUrl;
  final String? mediaFileId;
  final String? mediaCaption;
  final String? buttonText;
  final String? buttonUrl;
  final String parseMode;
  final String status;
  final String sendMode;
  final int priority;
  final int totalRecipients;
  final int sentCount;
  final int failedCount;
  final int pendingRecipients;
  final int sentRecipients;
  final int failedRecipients;
  final double sentRatePercent;
  final String? createdByUsername;
  final String? createdByTelegramId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? sentAt;
  final DateTime? scheduledAt;
  final String? scheduledByUsername;

  const BroadcastModel({
    required this.id,
    required this.campaignId,
    required this.campaignName,
    required this.title,
    required this.messageType,
    required this.targetSegment,
    required this.messageText,
    required this.mediaUrl,
    required this.mediaFileId,
    required this.mediaCaption,
    required this.buttonText,
    required this.buttonUrl,
    required this.parseMode,
    required this.status,
    required this.sendMode,
    required this.priority,
    required this.totalRecipients,
    required this.sentCount,
    required this.failedCount,
    required this.pendingRecipients,
    required this.sentRecipients,
    required this.failedRecipients,
    required this.sentRatePercent,
    required this.createdByUsername,
    required this.createdByTelegramId,
    required this.createdAt,
    required this.updatedAt,
    required this.sentAt,
    required this.scheduledAt,
    required this.scheduledByUsername,
  });

  factory BroadcastModel.fromJson(Map<String, dynamic> json) {
    return BroadcastModel(
      id: _toInt(json['id']),
      campaignId: _toNullableInt(json['campaign_id']),
      campaignName: _cleanNullable(json['campaign_name']),
      title: _cleanNullable(json['title']) ?? 'Untitled broadcast',
      messageType: _cleanNullable(json['message_type']) ?? 'text',
      targetSegment: _cleanNullable(json['target_segment']) ?? 'all_users',
      messageText: _cleanNullable(json['message_text']) ?? '',
      mediaUrl: _cleanNullable(json['media_url']),
      mediaFileId: _cleanNullable(json['media_file_id']),
      mediaCaption: _cleanNullable(json['media_caption']),
      buttonText: _cleanNullable(json['button_text']),
      buttonUrl: _cleanNullable(json['button_url']),
      parseMode: _cleanNullable(json['parse_mode']) ?? 'HTML',
      status: _cleanNullable(json['status']) ?? 'draft',
      sendMode: _cleanNullable(json['send_mode']) ?? 'now',
      priority: _toInt(json['priority'], fallback: 5),
      totalRecipients: _toInt(json['total_recipients']),
      sentCount: _toInt(json['sent_count']),
      failedCount: _toInt(json['failed_count']),
      pendingRecipients: _toInt(json['pending_recipients']),
      sentRecipients: _toInt(json['sent_recipients']),
      failedRecipients: _toInt(json['failed_recipients']),
      sentRatePercent: _toDouble(json['sent_rate_percent']),
      createdByUsername: _cleanNullable(json['created_by_username']),
      createdByTelegramId: _cleanNullable(json['created_by_telegram_id']),
      createdAt: _toDate(json['created_at']),
      updatedAt: _toDate(json['updated_at']),
      sentAt: _toDate(json['sent_at']),
      scheduledAt: _toDate(json['scheduled_at']),
      scheduledByUsername: _cleanNullable(json['scheduled_by_username']),
    );
  }

  bool get hasMedia => _hasValue(mediaUrl) || _hasValue(mediaFileId);
  bool get hasButton => _hasValue(buttonText) && _hasValue(buttonUrl);

  static bool _hasValue(String? value) {
    if (value == null) return false;
    final text = value.trim();
    return text.isNotEmpty && text.toLowerCase() != 'null' && text.toLowerCase() != 'undefined';
  }

  static String? _cleanNullable(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null' || text.toLowerCase() == 'undefined') return null;
    return text;
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? fallback;
    return fallback;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? double.tryParse(value)?.toInt();
    return null;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
