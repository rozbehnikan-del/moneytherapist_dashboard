import 'package:flutter/material.dart';

import 'app/dashboard_app.dart';
import 'config/projects/moneytherapist_config.dart';
import 'core/telegram/telegram_web_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  TelegramWebApp.instance.init();

  runApp(DashboardApp(project: moneyTherapistConfig));
}
