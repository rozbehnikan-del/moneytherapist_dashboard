import 'package:dio/dio.dart';

import '../../core/telegram/telegram_web_app.dart';
import 'admin_access_model.dart';

/*class AdminAccessService {
  final Dio _dio;

  AdminAccessService(this._dio);

  Future<AdminAccessModel> checkAccess() async {
    final telegram = TelegramWebApp.instance;
    final user = telegram.user;

    final response = await _dio.post(
      'https://dastyaricall.wpnv.xyz/webhook/dastyarical-admin-me',
      data: {
        'telegram_user_id': user?.id,
        // Development fallback. Remove this fallback before production.
        //'telegram_username': user?.username,
        'telegram_username': user?.username ?? 'RadicalaAI',
        'init_data': telegram.initData,
      },
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid admin access response');
    }

    return AdminAccessModel.fromJson(response.data as Map<String, dynamic>);
  }
}
*/


class AdminAccessService {
  final Dio _dio;

  AdminAccessService(this._dio);

  Future<AdminAccessModel> checkAccess() async {
    final telegram = TelegramWebApp.instance;
    final user = telegram.user;

    final bool isTelegram = telegram.initData.isNotEmpty;

    final response = await _dio.post(
      'https://dastyaricall.wpnv.xyz/webhook/dastyarical-admin-me',
      data: {
        // Real Telegram data when inside Telegram
        // Local fallback when testing in Chrome
        'telegram_user_id': isTelegram ? user?.id : 7376947596,
        'telegram_username': isTelegram
            ? user?.username
            : 'RadicalaAI',
        'init_data': telegram.initData,
      },
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid admin access response');
    }

    return AdminAccessModel.fromJson(response.data as Map<String, dynamic>);
  }
}