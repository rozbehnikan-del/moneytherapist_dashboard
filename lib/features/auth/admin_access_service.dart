import 'package:dio/dio.dart';

import '../../config/project_config.dart';
import '../../core/telegram/telegram_web_app.dart';
import 'admin_access_model.dart';

class AdminAccessService {
  final Dio _dio;
  final ApiEndpoints _apiEndpoints;
  final AdminConfig _adminConfig;

  AdminAccessService(
    this._dio,
    ProjectConfig project,
  )   : _apiEndpoints = project.apiEndpoints,
        _adminConfig = project.admin;

  AdminAccessService.withConfig(
    this._dio, {
    required ApiEndpoints apiEndpoints,
    required AdminConfig adminConfig,
  })  : _apiEndpoints = apiEndpoints,
        _adminConfig = adminConfig;

  Future<AdminAccessModel> checkAccess() async {
    final telegram = TelegramWebApp.instance;
    final user = telegram.user;

    if (_adminConfig.localDevelopmentBypassEnabled && _isLocalHost) {
      return AdminAccessModel(
        allowed: true,
        id: 0,
        telegramUserId: _adminConfig.ownerTelegramUserId,
        telegramUsername: _adminConfig.ownerTelegramUsername,
        role: 'owner',
      );
    }

    final response = await _dio.post(
      _apiEndpoints.adminMe,
      data: {
        'telegram_user_id': user?.id,
        'telegram_username': user?.username,
        'init_data': telegram.initData,
      },
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid admin access response');
    }

    final access = AdminAccessModel.fromJson(data).withFallback(
      telegramUserId: user?.id,
      telegramUsername: user?.username,
      role: _isKnownOwner(user) ? 'owner' : null,
    );

    if (access.allowed && _isKnownOwner(user)) {
      return AdminAccessModel(
        allowed: true,
        id: access.id,
        telegramUserId: access.telegramUserId,
        telegramUsername: access.telegramUsername,
        role: 'owner',
      );
    }

    return access;
  }

  bool _isKnownOwner(TelegramUser? user) {
    final username = user?.username?.trim().toLowerCase();
    final ownerUsername =
        _adminConfig.ownerTelegramUsername.trim().toLowerCase();
    return user?.id == _adminConfig.ownerTelegramUserId ||
        username == ownerUsername;
  }

  bool get _isLocalHost {
    final host = Uri.base.host.toLowerCase();
    return host == 'localhost' || host == '127.0.0.1' || host == '::1';
  }
}
