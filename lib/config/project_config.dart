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
  final ApiEndpoints apiEndpoints;
  final AdminConfig admin;

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
    required this.apiEndpoints,
    required this.admin,
  });
}

class ApiEndpoints {
  final String baseUrl;
  final String dashboardSummary;
  final String adminMe;
  final String campaignList;
  final String campaignCreate;
  final String campaignStatus;
  final String campaignLeads;
  final String signalHistory;
  final String signalSend;
  final String broadcastCreate;
  final String broadcastHistory;
  final String broadcastSend;
  final String broadcastAudiencePreview;
  final String mediaUpload;

  const ApiEndpoints({
    required this.baseUrl,
    required this.dashboardSummary,
    required this.adminMe,
    required this.campaignList,
    required this.campaignCreate,
    required this.campaignStatus,
    required this.campaignLeads,
    required this.signalHistory,
    required this.signalSend,
    required this.broadcastCreate,
    required this.broadcastHistory,
    required this.broadcastSend,
    required this.broadcastAudiencePreview,
    required this.mediaUpload,
  });
}

class AdminConfig {
  final bool localDevelopmentBypassEnabled;
  final int ownerTelegramUserId;
  final String ownerTelegramUsername;

  const AdminConfig({
    required this.localDevelopmentBypassEnabled,
    required this.ownerTelegramUserId,
    required this.ownerTelegramUsername,
  });
}
