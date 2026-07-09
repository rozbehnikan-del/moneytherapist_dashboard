import 'package:dio/dio.dart';

import '../../core/telegram/telegram_web_app.dart';
import 'admin_access_model.dart';

class AdminAccessService {
  final Dio _dio;

  AdminAccessService(this._dio);

  static const String _adminUrl =
      'https://sizin8n.launchman.xyz/webhook/moneytherapist-admin-me';

  Future<AdminAccessModel> checkAccess() async {
    final telegram = TelegramWebApp.instance;
    final user = telegram.user;

    if (_isLocalHost) {
      return const AdminAccessModel(
        allowed: true,
        id: 0,
        telegramUserId: 7376947596,
        telegramUsername: 'RadicalaAI',
        role: 'owner',
      );
    }

    final response = await _dio.post(
      _adminUrl,
      data: {
        'telegram_user_id': user?.id,
        'telegram_username': user?.username,
        // 'telegram_username': user?.username ?? 'RadicalaAI',
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
    return user?.id == 7376947596 || username == 'radicalaai';
  }

  bool get _isLocalHost {
    final host = Uri.base.host.toLowerCase();
    return host == 'localhost' || host == '127.0.0.1' || host == '::1';
  }
}
