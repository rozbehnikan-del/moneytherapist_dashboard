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
    dashboardSummary:
        'https://sizin8n.launchman.xyz/webhook/moneytherapist-dashboard-summary',
    adminMe:
        'https://sizin8n.launchman.xyz/webhook/moneytherapist-admin-me',
    campaignList:
        'https://sizin8n.launchman.xyz/webhook/moneytherapist-campaign-list',
    campaignCreate:
        'https://sizin8n.launchman.xyz/webhook/moneytherapist-campaign-create',
    campaignStatus:
        'https://sizin8n.launchman.xyz/webhook/moneytherapist-campaign-status',
    campaignLeads:
        'https://sizin8n.launchman.xyz/webhook/moneytherapist-campaign-leads',
    signalHistory:
        'https://sizin8n.launchman.xyz/webhook/moneytherapist-signal-history',
    signalSend:
        'https://sizin8n.launchman.xyz/webhook/moneytherapist-signal-send',
    broadcastCreate:
        'https://sizin8n.launchman.xyz/webhook/moneytherapist-broadcast-create',
    broadcastHistory:
        'https://sizin8n.launchman.xyz/webhook/moneytherapist-broadcast-history',
    broadcastSend:
        'https://sizin8n.launchman.xyz/webhook/moneytherapist-broadcast-send',
    broadcastAudiencePreview:
        'https://sizin8n.launchman.xyz/webhook/moneytherapist-broadcast-audience-preview',
    mediaUpload:
        'https://sizin8n.launchman.xyz/webhook/moneytherapist-media-upload',
  ),
  admin: AdminConfig(
    localDevelopmentBypassEnabled: true,
    ownerTelegramUserId: 7376947596,
    ownerTelegramUsername: 'RadicalaAI',
  ),
);
