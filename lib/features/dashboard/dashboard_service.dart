import 'package:dio/dio.dart';

import '../../config/project_config.dart';
import 'dashboard_models.dart';

class DashboardService {
  final Dio _dio;
  final ApiEndpoints _apiEndpoints;

  DashboardService(this._dio, ProjectConfig project)
    : _apiEndpoints = project.apiEndpoints;

  DashboardService.withEndpoints(
    this._dio, {
    required ApiEndpoints apiEndpoints,
  }) : _apiEndpoints = apiEndpoints;

  Future<DashboardData> fetchDashboard() async {
    final response = await _dio.get(
      _apiEndpoints.dashboardSummary,
      queryParameters: {'t': DateTime.now().millisecondsSinceEpoch},
      options: Options(
        responseType: ResponseType.json,
        headers: {'Cache-Control': 'no-cache'},
      ),
    );

    final data = response.data;

    if (data is! Map) {
      throw Exception(
        'Invalid dashboard response: response is not JSON object',
      );
    }

    return DashboardData.fromJson(Map<String, dynamic>.from(data));
  }
}
