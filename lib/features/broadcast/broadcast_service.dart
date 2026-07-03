import 'package:dio/dio.dart';

import 'broadcast_audience_model.dart';
import 'broadcast_model.dart';

class BroadcastService {
  final Dio _dio;

  BroadcastService(this._dio);

  // Use /webhook-test while testing n8n manually.
  // Change to /webhook after workflows are active/production.
  static const String _baseUrl = 'https://sizin8n.launchman.xyz/webhook';

  Future<BroadcastAudiencePreview> previewAudience({
    int? campaignId,
    required String targetSegment,
    int limit = 10,
  }) async {
    final response = await _dio.post(
      '$_baseUrl/moneytherapist-broadcast-audience-preview',
      data: {
        if (campaignId != null) 'campaign_id': campaignId,
        'target_segment': targetSegment,
        'limit': limit,
      },
      options: _jsonOptions(),
    );

    final data = response.data;
    if (data is Map) {
      return BroadcastAudiencePreview.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception('Invalid audience preview response');
  }

  Future<BroadcastModel> createBroadcast({
    int? campaignId,
    required String title,
    required String messageType,
    required String targetSegment,
    required String messageText,
    required String createdByUsername,
    String? createdByTelegramId,
    String? mediaUrl,
    String? mediaFileId,
    String? mediaCaption,
    String? buttonText,
    String? buttonUrl,
    String sendMode = 'now',
    DateTime? scheduledAt,
    int limit = 100,
  }) async {
    final response = await _dio.post(
      '$_baseUrl/moneytherapist-broadcast-create',
      data: {
        if (campaignId != null) 'campaign_id': campaignId,
        'title': title.trim(),
        'message_type': messageType.trim(),
        'target_segment': targetSegment.trim(),
        'message_text': messageText.trim(),
        'admin_username': createdByUsername.replaceAll('@', '').trim(),
        if (_hasValue(createdByTelegramId)) 'admin_telegram_id': createdByTelegramId!.trim(),
        if (_hasValue(mediaUrl)) 'media_url': mediaUrl!.trim(),
        if (_hasValue(mediaFileId)) 'media_file_id': mediaFileId!.trim(),
        if (_hasValue(mediaCaption)) 'media_caption': mediaCaption!.trim(),
        if (_hasValue(buttonText)) 'button_text': buttonText!.trim(),
        if (_hasValue(buttonUrl)) 'button_url': buttonUrl!.trim(),
        'send_mode': sendMode,
        if (scheduledAt != null) 'scheduled_at': scheduledAt.toUtc().toIso8601String(),
        'limit': limit,
      },
      options: _jsonOptions(),
    );

    final data = response.data;
    if (data is Map && data['broadcast'] is Map) {
      return BroadcastModel.fromJson(Map<String, dynamic>.from(data['broadcast'] as Map));
    }
    throw Exception('Invalid broadcast create response');
  }

  Future<BroadcastModel> sendBroadcast({
    required int broadcastId,
    required String adminUsername,
    int limit = 100,
  }) async {
    final response = await _dio.post(
      '$_baseUrl/moneytherapist-broadcast-send',
      data: {
        'broadcast_id': broadcastId,
        'admin_username': adminUsername.replaceAll('@', '').trim(),
        'limit': limit,
      },
      options: _jsonOptions(),
    );

    final data = response.data;
    if (data is Map && data['broadcast'] is Map) {
      return BroadcastModel.fromJson(Map<String, dynamic>.from(data['broadcast'] as Map));
    }
    throw Exception('Invalid broadcast send response');
  }

  Future<List<BroadcastModel>> fetchBroadcastHistory() async {
    final response = await _dio.get(
      '$_baseUrl/moneytherapist-broadcast-history',
      options: _jsonOptions(),
    );

    final data = response.data;
    if (data is List) {
      return data.whereType<Map>().map((item) => BroadcastModel.fromJson(Map<String, dynamic>.from(item))).toList();
    }
    if (data is Map && data['broadcasts'] is List) {
      return (data['broadcasts'] as List).whereType<Map>().map((item) => BroadcastModel.fromJson(Map<String, dynamic>.from(item))).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).whereType<Map>().map((item) => BroadcastModel.fromJson(Map<String, dynamic>.from(item))).toList();
    }
    throw Exception('Invalid broadcast history response');
  }

  Options _jsonOptions() {
    return Options(
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      headers: {'Accept': 'application/json'},
      sendTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
    );
  }

  bool _hasValue(String? value) {
    if (value == null) return false;
    final text = value.trim();
    return text.isNotEmpty && text.toLowerCase() != 'null' && text.toLowerCase() != 'undefined';
  }
}
