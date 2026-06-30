import 'package:flutter/material.dart';

import 'app/dastyarical_app.dart';
import 'core/telegram/telegram_web_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  TelegramWebApp.instance.init();

  runApp(const DastyaricalApp());
}