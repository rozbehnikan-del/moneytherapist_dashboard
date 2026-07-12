// ignore_for_file: use_null_aware_elements

import 'package:dio/dio.dart';

import '../../config/projects/moneytherapist_config.dart';
import 'broadcast_audience_model.dart';
import 'broadcast_model.dart';

class BroadcastService {
  final Dio _dio;

  BroadcastService(this._dio);

  // Use /webhook-test while testing n8n manually.
  // Change to /webhook after workflows are active/production.
  static final String _baseUrl = moneyTherapistConfig.apiEndpoints.baseUrl;
  static final String _testBaseUrl = '$_baseUrl-test';

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
    int? createdByTelegramId,
    String? mediaUrl,
    String? mediaFileId,
    String? mediaCaption,
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
        if (_hasValue(messageText)) 'message_text': messageText.trim(),
        'parse_mode': 'HTML',
        'send_mode': sendMode,
        'scheduled_at': scheduledAt?.toUtc().toIso8601String(),
        'created_by_username': createdByUsername.replaceAll('@', '').trim(),
        'admin_username': createdByUsername.replaceAll('@', '').trim(),
        if (createdByTelegramId != null)
          'admin_telegram_id': createdByTelegramId,
        if (_hasValue(mediaUrl)) 'media_url': mediaUrl!.trim(),
        if (_hasValue(mediaFileId)) 'media_file_id': mediaFileId!.trim(),
        if (_hasValue(mediaCaption)) 'media_caption': mediaCaption!.trim(),
        'limit': limit,
      },
      options: _jsonOptions(),
    );

    final data = response.data;
    final broadcast = _readBroadcast(data);
    if (broadcast != null) {
      return broadcast;
    }
    throw Exception('Invalid broadcast create response');
  }

  Future<BroadcastMediaUploadResult> uploadBroadcastMedia({
    required String messageType,
    required String fileName,
    required List<int> bytes,
    String? contentType,
    required String adminUsername,
    int? adminTelegramUserId,
    String? caption,
  }) async {
    final response = await _postMediaUploadWithFallback(
      urls: [
        '$_baseUrl/moneytherapist-media-upload',
        '$_testBaseUrl/moneytherapist-media-upload',
      ],
      messageType: messageType,
      fileName: fileName,
      bytes: bytes,
      contentType: contentType,
      adminUsername: adminUsername,
      adminTelegramUserId: adminTelegramUserId,
      caption: caption,
    );

    final data = response.data;
    if (data is Map) {
      return BroadcastMediaUploadResult.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw Exception('Invalid media file_id response');
  }

  Future<Response<dynamic>> _postMediaUploadWithFallback({
    required List<String> urls,
    required String messageType,
    required String fileName,
    required List<int> bytes,
    String? contentType,
    required String adminUsername,
    int? adminTelegramUserId,
    String? caption,
  }) async {
    DioException? lastDioError;

    for (final url in urls) {
      try {
        return await _dio.post(
          url,
          data: FormData.fromMap({
            'media_type': messageType.trim(),
            'message_type': messageType.trim(),
            'file_name': fileName.trim(),
            'admin_username': adminUsername.replaceAll('@', '').trim(),
            if (adminTelegramUserId != null)
              'admin_chat_id': adminTelegramUserId,
            if (_hasValue(caption)) 'caption': caption!.trim(),
            if (_hasValue(contentType)) 'content_type': contentType!.trim(),
            'file': MultipartFile.fromBytes(bytes, filename: fileName.trim()),
          }),
          options: Options(
            headers: {'Accept': 'application/json'},
            sendTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 90),
          ),
        );
      } on DioException catch (e) {
        lastDioError = e;
        if (!_shouldTryNextMediaUploadUrl(e)) rethrow;
      }
    }

    final reason = lastDioError == null
        ? ''
        : ' Last Dio error: ${lastDioError.type}. ${lastDioError.message ?? ''}';

    throw Exception(
      'Media upload failed before n8n returned a response. Check that the '
      'moneytherapist-media-upload workflow is active or listening in test '
      'mode, and that the webhook returns CORS headers for errors.$reason',
    );
  }

  bool _shouldTryNextMediaUploadUrl(DioException error) {
    if (error.type == DioExceptionType.connectionError) return true;
    if (error.type == DioExceptionType.connectionTimeout) return true;
    if (error.type == DioExceptionType.receiveTimeout) return true;

    final statusCode = error.response?.statusCode;
    return statusCode == 404 || statusCode == 405;
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
    final broadcast = _readBroadcast(data);
    if (broadcast != null) {
      return broadcast;
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
      return data
          .whereType<Map>()
          .map(
            (item) => BroadcastModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }
    if (data is Map && data['broadcasts'] is List) {
      return (data['broadcasts'] as List)
          .whereType<Map>()
          .map(
            (item) => BroadcastModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map>()
          .map(
            (item) => BroadcastModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
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
    return text.isNotEmpty &&
        text.toLowerCase() != 'null' &&
        text.toLowerCase() != 'undefined';
  }

  BroadcastModel? _readBroadcast(dynamic data) {
    if (data is! Map) return null;

    final map = Map<String, dynamic>.from(data);
    final wrapped = map['broadcast'] ?? map['data'] ?? map['result'];

    if (wrapped is Map) {
      return BroadcastModel.fromJson(Map<String, dynamic>.from(wrapped));
    }

    if (map.containsKey('id') || map.containsKey('broadcast_id')) {
      return BroadcastModel.fromJson(map);
    }

    return null;
  }
}

class BroadcastMediaUploadResult {
  final String mediaFileId;
  final String? mediaUrl;
  final String? fileName;
  final String? status;

  const BroadcastMediaUploadResult({
    required this.mediaFileId,
    this.mediaUrl,
    this.fileName,
    this.status,
  });

  factory BroadcastMediaUploadResult.fromJson(Map<String, dynamic> json) {
    final nestedData = json['data'];
    final nested = nestedData is Map
        ? Map<String, dynamic>.from(nestedData)
        : null;
    final mediaFileId = _cleanNullable(
      json['media_file_id'] ??
          json['file_id'] ??
          json['telegram_file_id'] ??
          nested?['media_file_id'] ??
          nested?['file_id'],
    );

    if (mediaFileId == null) {
      throw Exception('Media API did not return media_file_id');
    }

    return BroadcastMediaUploadResult(
      mediaFileId: mediaFileId,
      mediaUrl: _cleanNullable(json['media_url'] ?? json['url']),
      fileName: _cleanNullable(json['file_name'] ?? json['filename']),
      status: _cleanNullable(json['status']),
    );
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
}
