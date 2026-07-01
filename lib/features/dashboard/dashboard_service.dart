import 'package:dio/dio.dart';

import 'dashboard_mock_data.dart';
import 'dashboard_models.dart';

class DashboardService {
  final Dio _dio;

  DashboardService(this._dio);

  Future<DashboardData> fetchDashboard() async {
    try {
      final response = await _dio
          .get(
            'https://sizin8n.launchman.xyz/webhook-test/moneytherapist-dashboard-summary',
            options: Options(
              headers: {
                'Accept': 'application/json',
              },
            ),
          )
          .timeout(const Duration(seconds: 8));

      if (response.data is! Map<String, dynamic>) {
        return mockDashboardData;
      }

      return DashboardData.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return mockDashboardData;
    }
  }
}