class BroadcastModel {
  final int id;
  final int? campaignId;
  final String? campaignName;
  final String title;
  final String messageType;
  final String targetSegment;
  final String messageText;
  final String status;
  final int totalRecipients;
  final int sentCount;
  final int failedCount;
  final String? createdByUsername;
  final DateTime? createdAt;
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
    required this.status,
    required this.totalRecipients,
    required this.sentCount,
    required this.failedCount,
    required this.createdByUsername,
    required this.createdAt,
    required this.sentAt,
    required this.scheduledAt,
    required this.scheduledByUsername,
  });

  factory BroadcastModel.fromJson(Map<String, dynamic> json) {
    return BroadcastModel(
      id: _toInt(json['id']),
      campaignId: _toNullableInt(json['campaign_id']),
      campaignName: json['campaign_name']?.toString(),
      title: json['title']?.toString() ?? 'Untitled broadcast',
      messageType: json['message_type']?.toString() ?? 'unknown',
      targetSegment: json['target_segment']?.toString() ?? 'unknown',
      messageText: json['message_text']?.toString() ?? '',
      status: json['status']?.toString() ?? 'draft',
      totalRecipients: _toInt(json['total_recipients']),
      sentCount: _toInt(json['sent_count']),
      failedCount: _toInt(json['failed_count']),
      createdByUsername: json['created_by_username']?.toString(),
      createdAt: _toDate(json['created_at']),
      sentAt: _toDate(json['sent_at']),
      scheduledAt: _toDate(json['scheduled_at']),
      scheduledByUsername: json['scheduled_by_username']?.toString(),
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

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}