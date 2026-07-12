import 'package:flutter/material.dart';

import 'app/money_therapist_app.dart';
import 'config/project_registry.dart';
import 'core/telegram/telegram_web_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  TelegramWebApp.instance.init();

  const projectId = String.fromEnvironment(
    'PROJECT_ID',
    defaultValue: 'moneytherapist',
  );
  final project = ProjectRegistry.resolve(projectId);

  runApp(DashboardApp(project: project));
}
