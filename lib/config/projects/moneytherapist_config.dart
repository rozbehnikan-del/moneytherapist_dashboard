import 'package:flutter/material.dart';

import '../project_config.dart';

const ProjectConfig moneyTherapistConfig = ProjectConfig(
  id: 'moneytherapist',
  appTitle: 'MoneyTherapist Dashboard',
  displayName: 'MoneyTherapist',
  dashboardSubtitle: 'MoneyTherapist Expert System',
  splashAssetPath: 'assets/images/splash.png',
  splashTitle: 'Money Therapist Expert Dashboard',
  splashLoadingText: 'Loading Money Therapist analytics...',
  primaryColor: Color(0xFF7329E7),
  secondaryColor: Color(0xFFE6BA53),
  darkBackgroundColor: Color(0xFF05040B),
  cardDarkColor: Color(0xFF111827),
  softAccentColor: Color(0xFFB47AE7),
  apiEndpoints: ApiEndpoints(
    baseUrl: 'https://sizin8n.launchman.xyz/webhook',
    dashboardSummary: '/moneytherapist-dashboard-summary',
    adminMe: '/moneytherapist-admin-me',
    campaignList: '/moneytherapist-campaign-list',
    campaignCreate: '/moneytherapist-campaign-create',
    campaignStatus: '/moneytherapist-campaign-status',
    campaignLeads: '/moneytherapist-campaign-leads',
    signalHistory: '/moneytherapist-signal-history',
    signalSend: '/moneytherapist-signal-send',
    broadcastCreate: '/moneytherapist-broadcast-create',
    broadcastHistory: '/moneytherapist-broadcast-history',
    broadcastSend: '/moneytherapist-broadcast-send',
    broadcastAudiencePreview: '/moneytherapist-broadcast-audience-preview',
    mediaUpload: '/moneytherapist-media-upload',
  ),
  admin: AdminConfig(
    localDevelopmentBypassEnabled: true,
    ownerTelegramUserId: 7376947596,
    ownerTelegramUsername: 'RadicalaAI',
  ),
);
