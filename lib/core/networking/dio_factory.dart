import 'package:dio/dio.dart';

import '../../config/project_config.dart';

class DioFactory {
  DioFactory._();

  static Dio create(ProjectConfig project) {
    return Dio(
      BaseOptions(
        baseUrl: project.apiEndpoints.baseUrl,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
      ),
    );
  }
}
