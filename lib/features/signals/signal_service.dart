import 'package:dio/dio.dart';

import '../../config/project_config.dart';
import 'campaign_lead_model.dart';
import 'campaign_model.dart';
import 'signal_model.dart';

class SignalService {
  final Dio _dio;
  final ApiEndpoints _apiEndpoints;

  SignalService(this._dio, ProjectConfig project)
    : _apiEndpoints = project.apiEndpoints;

  SignalService.withEndpoints(this._dio, {required ApiEndpoints apiEndpoints})
    : _apiEndpoints = apiEndpoints;

  Future<List<SignalModel>> fetchSignalHistory() async {
    final response = await _dio.get(
      _apiEndpoints.signalHistory,
      options: Options(headers: {'Accept': 'application/json'}),
    );

    final data = response.data;

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(SignalModel.fromJson)
          .toList();
    }

    if (data is Map<String, dynamic> && data['signals'] is List) {
      return (data['signals'] as List)
          .whereType<Map<String, dynamic>>()
          .map(SignalModel.fromJson)
          .toList();
    }

    throw Exception('Invalid signal history response');
  }

  Future<void> sendSignal({
    required int campaignId,
    required String title,
    required String signalType,
    required String market,
    required double entryPrice,
    required double stopLoss,
    required double takeProfit1,
    required double takeProfit2,
    required double takeProfit3,
    required String riskLevel,
    required String messageText,
    required int targetChatId,
    required String adminUsername,

    // If UI does not pass it yet, default keeps current test admin working.
    int adminTelegramId = 7376947596,
  }) async {
    final response = await _dio.post(
      _apiEndpoints.signalSend,
      data: {
        'admin_telegram_id': adminTelegramId,
        'admin_username': adminUsername,
        'campaign_id': campaignId,
        'title': title,
        'signal_type': signalType,
        'market': market,
        'entry_price': entryPrice,
        'stop_loss': stopLoss,
        'take_profit_1': takeProfit1,
        'take_profit_2': takeProfit2,
        'take_profit_3': takeProfit3,
        'risk_level': riskLevel,
        'message_text': messageText,
        'target_chat_id': targetChatId,
      },
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception('Failed to send signal');
    }
  }

  Future<List<CampaignModel>> fetchCampaigns() async {
    final response = await _dio.get(
      _apiEndpoints.campaignList,
      options: Options(headers: {'Accept': 'application/json'}),
    );

    final data = response.data;

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(CampaignModel.fromJson)
          .toList();
    }

    if (data is Map<String, dynamic> && data['campaigns'] is List) {
      return (data['campaigns'] as List)
          .whereType<Map<String, dynamic>>()
          .map(CampaignModel.fromJson)
          .toList();
    }

    throw Exception('Invalid campaigns response');
  }

  Future<List<CampaignLeadModel>> fetchCampaignLeads({
    required int campaignId,
    String status = 'all',
    String segment = 'all',
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _dio.post(
      _apiEndpoints.campaignLeads,
      data: {
        'campaign_id': campaignId,
        'status': status,
        'segment': segment,
        'limit': limit,
        'offset': offset,
      },
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    final data = response.data;

    if (data is Map<String, dynamic> && data['leads'] is List) {
      return (data['leads'] as List)
          .whereType<Map<String, dynamic>>()
          .map(CampaignLeadModel.fromJson)
          .toList();
    }

    throw Exception('Invalid campaign leads response');
  }

  Future<void> createCampaign({
    required String name,
    required String description,
    required String startDate,
    required String endDate,
    required String status,
    required String targetSegment,
    required String createdByUsername,

    // Same default admin id for current test admin.
    int adminTelegramId = 7376947596,
  }) async {
    final response = await _dio.post(
      _apiEndpoints.campaignCreate,
      data: {
        'admin_telegram_id': adminTelegramId,
        'admin_username': createdByUsername,
        'name': name,
        'description': description,
        'start_date': startDate,
        'end_date': endDate,
        'status': status,
        'target_segment': targetSegment,
      },
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception('Failed to create campaign');
    }
  }

  Future<Map<String, dynamic>> fetchCampaignStatus({
    required int campaignId,
  }) async {
    final response = await _dio.post(
      _apiEndpoints.campaignStatus,
      data: {'campaign_id': campaignId},
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw Exception('Invalid campaign status response');
  }

  // NOTE:
  // This needs a separate backend API if you want real campaign status update.
  // Current campaign status API only READS campaign stats.
  Future<void> updateCampaignStatus({
    required int campaignId,
    required String status,
    required String updatedByUsername,
  }) async {
    throw UnimplementedError(
      'Campaign status update API is not created yet. '
      'Create a campaign status update endpoint first.',
    );
  }
}
