import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../config/project_config.dart';
import '../core/telegram/telegram_web_app.dart';
import 'splash_page.dart';

class DashboardApp extends StatelessWidget {
  final ProjectConfig project;

  const DashboardApp({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    final telegram = TelegramWebApp.instance;
    final isDark = telegram.isDarkMode;

    return MaterialApp(
      title: project.appTitle,
      debugShowCheckedModeBanner: false,
      scrollBehavior: const DashboardScrollBehavior(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: _buildTheme(brightness: Brightness.light),
      darkTheme: _buildTheme(brightness: Brightness.dark),
      home: SplashPage(project: project),
    );
  }

  ThemeData _buildTheme({
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: project.primaryColor,
      brightness: brightness,
    );

    final scaffoldBackground =
        isDark ? project.darkBackgroundColor : const Color(0xFFF6F8FB);

    final cardColor = isDark ? project.cardDarkColor : Colors.white;

    final primaryText = isDark ? Colors.white : const Color(0xFF111827);

    final secondaryText = isDark ? Colors.white70 : const Color(0xFF6B7280);

    final borderColor = isDark ? Colors.white12 : const Color(0xFFE5E7EB);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme.copyWith(
        primary: project.primaryColor,
        secondary: project.secondaryColor,
        surface: cardColor,
      ),
      scaffoldBackgroundColor: scaffoldBackground,
      canvasColor: scaffoldBackground,
      cardColor: cardColor,
      fontFamily: 'Roboto',

      iconTheme: IconThemeData(
        color: isDark ? project.softAccentColor : project.primaryColor,
      ),

      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.w900,
        ),
        headlineMedium: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.w900,
        ),
        headlineSmall: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.w900,
        ),
        titleLarge: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.w700,
        ),
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
          color: isDark ? project.secondaryColor : project.primaryColor,
          fontWeight: FontWeight.w800,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
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
          borderSide: BorderSide(
            color: project.primaryColor,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFDC2626),
            width: 1.5,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: project.primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB),
          disabledForegroundColor:
              isDark ? Colors.white38 : const Color(0xFF6B7280),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor:
              isDark ? project.secondaryColor : project.primaryColor,
          side: BorderSide(
            color: isDark ? project.secondaryColor : project.primaryColor,
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor:
              isDark ? project.secondaryColor : project.primaryColor,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? project.cardDarkColor : Colors.white,
        indicatorColor: project.primaryColor.withValues(alpha: 0.14),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: project.primaryColor);
          }

          return IconThemeData(
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: project.primaryColor,
              fontWeight: FontWeight.w800,
            );
          }

          return TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
          );
        }),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? project.cardDarkColor : Colors.white,
        selectedItemColor: project.primaryColor,
        unselectedItemColor: isDark ? Colors.white70 : const Color(0xFF6B7280),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.w600,
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(cardColor),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        titleTextStyle: TextStyle(
          color: primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
        contentTextStyle: TextStyle(
          color: secondaryText,
          fontSize: 14,
        ),
      ),
    );
  }
}

class DashboardScrollBehavior extends MaterialScrollBehavior {
  const DashboardScrollBehavior();

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
