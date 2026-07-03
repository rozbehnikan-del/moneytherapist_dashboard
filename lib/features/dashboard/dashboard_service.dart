import 'package:dio/dio.dart';

import 'dashboard_models.dart';

class DashboardService {
  final Dio _dio;

  DashboardService(this._dio);

  static const String _dashboardUrl =
      'https://sizin8n.launchman.xyz/webhook/moneytherapist-dashboard-summary';

  Future<DashboardData> fetchDashboard() async {
    final response = await _dio.get(
      _dashboardUrl,
      queryParameters: {
        't': DateTime.now().millisecondsSinceEpoch,
      },
      options: Options(
        responseType: ResponseType.json,
        headers: {
          'Accept': 'application/json',
          'Cache-Control': 'no-cache',
        },
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    final data = response.data;

    if (data is! Map) {
      throw Exception('Invalid dashboard response: response is not JSON object');
    }

    return DashboardData.fromJson(
      Map<String, dynamic>.from(data),
    );
  }
}