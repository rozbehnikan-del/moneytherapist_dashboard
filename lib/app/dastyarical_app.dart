import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../core/telegram/telegram_web_app.dart';
import 'splash_page.dart';

class DastyaricalApp extends StatelessWidget {
  const DastyaricalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final telegram = TelegramWebApp.instance;
    final isDark = telegram.isDarkMode;

    return MaterialApp(
      title: 'Dastyarical Dashboard',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const DastyaricalScrollBehavior(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: _buildTheme(brightness: Brightness.light),
      darkTheme: _buildTheme(brightness: Brightness.dark),
      home: const SplashPage(),
    );
  }

  ThemeData _buildTheme({
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF005B7F),
      brightness: brightness,
    );

    final scaffoldBackground =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF6F8FB);

    final cardColor = isDark ? const Color(0xFF111827) : Colors.white;

    final primaryText = isDark ? Colors.white : const Color(0xFF111827);

    final secondaryText = isDark ? Colors.white70 : const Color(0xFF6B7280);

    final borderColor = isDark ? Colors.white12 : const Color(0xFFE5E7EB);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      canvasColor: scaffoldBackground,
      cardColor: cardColor,
      fontFamily: 'Roboto',
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: primaryText, fontWeight: FontWeight.w900),
        headlineMedium: TextStyle(color: primaryText, fontWeight: FontWeight.w900),
        headlineSmall: TextStyle(color: primaryText, fontWeight: FontWeight.w900),
        titleLarge: TextStyle(color: primaryText, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(color: primaryText, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: primaryText),
        bodyMedium: TextStyle(color: secondaryText),
        bodySmall: TextStyle(color: secondaryText),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : const Color(0xFF667085),
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: isDark ? Colors.white38 : const Color(0xFF98A2B3),
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF005B7F),
          fontWeight: FontWeight.w800,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFFACC15),
          foregroundColor: const Color(0xFF111111),
          disabledBackgroundColor:
              isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB),
          disabledForegroundColor:
              isDark ? Colors.white38 : const Color(0xFF6B7280),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? Colors.white : const Color(0xFF475569),
          side: BorderSide(
            color: isDark ? Colors.white24 : const Color(0xFF9CA3AF),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF005B7F),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: primaryText, fontWeight: FontWeight.w600),
        menuStyle: MenuStyle(backgroundColor: WidgetStatePropertyAll(cardColor)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        titleTextStyle: TextStyle(
          color: primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
        contentTextStyle: TextStyle(color: secondaryText, fontSize: 14),
      ),
    );
  }
}

class DastyaricalScrollBehavior extends MaterialScrollBehavior {
  const DastyaricalScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices {
    return {
      PointerDeviceKind.touch,
      PointerDeviceKind.mouse,
      PointerDeviceKind.trackpad,
      PointerDeviceKind.stylus,
      PointerDeviceKind.unknown,
    };
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}