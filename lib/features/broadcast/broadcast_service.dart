import 'package:dio/dio.dart';

import 'broadcast_audience_model.dart';
import 'broadcast_model.dart';

class BroadcastService {
  final Dio _dio;

  BroadcastService(this._dio);

  Future<BroadcastAudiencePreview> previewAudience({
    int? campaignId,
    required String targetSegment,
  }) async {
    final response = await _dio.post(
      'https://dastyaricall.wpnv.xyz/webhook/dastyarical-broadcast-audience-preview',
      data: {
        if (campaignId != null) 'campaign_id': campaignId,
        'target_segment': targetSegment,
      },
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return BroadcastAudiencePreview.fromJson(data);
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
    DateTime? scheduledAt,
  }) async {
    final response = await _dio.post(
      'https://dastyaricall.wpnv.xyz/webhook/dastyarical-broadcast-create',
      data: {
        if (campaignId != null) 'campaign_id': campaignId,
        'title': title,
        'message_type': messageType,
        'target_segment': targetSegment,
        'message_text': messageText,
        'created_by_username': createdByUsername,
        if (scheduledAt != null) 'scheduled_at': scheduledAt.toIso8601String(),
      },
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    final data = response.data;

    if (data is Map<String, dynamic> &&
        data['broadcast'] is Map<String, dynamic>) {
      return BroadcastModel.fromJson(data['broadcast'] as Map<String, dynamic>);
    }

    throw Exception('Invalid broadcast create response');
  }

  Future<BroadcastModel> sendBroadcast({
    required int broadcastId,
    required String adminUsername,
  }) async {
    final response = await _dio.post(
      'https://dastyaricall.wpnv.xyz/webhook/dastyarical-broadcast-send',
      data: {
        'broadcast_id': broadcastId,
        'admin_username': adminUsername,
      },
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    final data = response.data;

    if (data is Map<String, dynamic> &&
        data['broadcast'] is Map<String, dynamic>) {
      return BroadcastModel.fromJson(data['broadcast'] as Map<String, dynamic>);
    }

    throw Exception('Invalid broadcast send response');
  }

  Future<List<BroadcastModel>> fetchBroadcastHistory() async {
    final response = await _dio.get(
      'https://dastyaricall.wpnv.xyz/webhook/dastyarical-broadcast-history',
      options: Options(
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    final data = response.data;

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(BroadcastModel.fromJson)
          .toList();
    }

    if (data is Map<String, dynamic> && data['broadcasts'] is List) {
      return (data['broadcasts'] as List)
          .whereType<Map<String, dynamic>>()
          .map(BroadcastModel.fromJson)
          .toList();
    }

    throw Exception('Invalid broadcast history response');
  }
}