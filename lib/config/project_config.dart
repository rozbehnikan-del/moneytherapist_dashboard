import 'package:flutter/material.dart';

class ProjectConfig {
  final String id;
  final String appTitle;
  final String displayName;
  final String dashboardSubtitle;
  final String splashAssetPath;
  final String splashTitle;
  final String splashLoadingText;
  final Color primaryColor;
  final Color secondaryColor;
  final Color darkBackgroundColor;
  final Color cardDarkColor;
  final Color softAccentColor;

  const ProjectConfig({
    required this.id,
    required this.appTitle,
    required this.displayName,
    required this.dashboardSubtitle,
    required this.splashAssetPath,
    required this.splashTitle,
    required this.splashLoadingText,
    required this.primaryColor,
    required this.secondaryColor,
    required this.darkBackgroundColor,
    required this.cardDarkColor,
    required this.softAccentColor,
  });
}
