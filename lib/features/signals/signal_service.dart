import 'package:dio/dio.dart';

import 'campaign_lead_model.dart';
import 'campaign_model.dart';
import 'signal_model.dart';

class SignalService {
  final Dio _dio;

  SignalService(this._dio);

  Future<List<SignalModel>> fetchSignalHistory() async {
    final response = await _dio.get(
      'https://dastyaricall.wpnv.xyz/webhook/dastyarical-signal-history',
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
  }) async {
    final response = await _dio.post(
      'https://dastyaricall.wpnv.xyz/webhook/dastyarical-signal-send',
      data: {
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
        'admin_username': adminUsername,
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
      'https://dastyaricall.wpnv.xyz/webhook/dastyarical-campaigns',
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
  }) async {
    final response = await _dio.get(
      'https://dastyaricall.wpnv.xyz/webhook/dastyarical-campaign-leads',
      queryParameters: {
        'campaign_id': campaignId,
      },
      options: Options(
        headers: {
          'Accept': 'application/json',
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
  }) async {
    final response = await _dio.post(
      'https://dastyaricall.wpnv.xyz/webhook/dastyarical-campaign-create',
      data: {
        'name': name,
        'description': description,
        'start_date': startDate,
        'end_date': endDate,
        'status': status,
        'target_segment': targetSegment,
        'created_by_username': createdByUsername,
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

  Future<void> updateCampaignStatus({
    required int campaignId,
    required String status,
    required String updatedByUsername,
  }) async {
    final response = await _dio.post(
      'https://dastyaricall.wpnv.xyz/webhook/dastyarical-campaign-status',
      data: {
        'campaign_id': campaignId,
        'status': status,
        'updated_by_username': updatedByUsername,
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
      throw Exception('Failed to update campaign status');
    }
  }
}