class DashboardData {
  final DateTime timestamp;
  final DashboardProject project;
  final CoreKpis core;
  final DashboardRates rates;
  final FunnelData funnel;
  final ValueData value;
  final SegmentData segments;
  final DashboardOperations operations;
  final DashboardReport report;
  final RecommendedAction recommendedAction;

  const DashboardData({
    required this.timestamp,
    this.project = const DashboardProject(
      name: 'MoneyTherapist',
      type: 'Expert Dashboard',
    ),
    required this.core,
    required this.rates,
    required this.funnel,
    required this.value,
    required this.segments,
    this.operations = const DashboardOperations(),
    this.report = const DashboardReport(),
    required this.recommendedAction,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      project: DashboardProject.fromJson(_map(json['project'])),
      core: CoreKpis.fromJson(_map(json['core'])),
      rates: DashboardRates.fromJson(_map(json['rates'])),
      funnel: FunnelData.fromJson(_map(json['funnel'])),
      value: ValueData.fromJson(_map(json['value'])),
      segments: SegmentData.fromJson(_map(json['segments'])),
      operations: DashboardOperations.fromJson(_map(json['operations'])),
      report: DashboardReport.fromJson(_map(json['report'])),
      recommendedAction: RecommendedAction.fromJson(
        _map(json['recommended_action'] ?? json['recommendedAction']),
      ),
    );
  }
}

class DashboardProject {
  final String name;
  final String type;

  const DashboardProject({
    required this.name,
    required this.type,
  });

  factory DashboardProject.fromJson(Map<String, dynamic> json) {
    return DashboardProject(
      name: NumberParser.toStringValue(
        json['name'],
        fallback: 'MoneyTherapist',
      ),
      type: NumberParser.toStringValue(
        json['type'],
        fallback: 'Expert Dashboard',
      ),
    );
  }
}

class CoreKpis {
  final int totalUsers;
  final int verifiedDeposits;
  final int pending;
  final int validEmails;
  final int onboarded;
  final int introSent;
  final int active7d;
  final int active24h;
  final int active14d;
  final int active30d;
  final int messages7d;
  final int telegramVerified;
  final int emailVerified;
  final int broadcastOptOut;

  const CoreKpis({
    required this.totalUsers,
    required this.verifiedDeposits,
    required this.pending,
    required this.validEmails,
    this.onboarded = 0,
    this.introSent = 0,
    required this.active7d,
    required this.active24h,
    this.active14d = 0,
    required this.active30d,
    required this.messages7d,
    this.telegramVerified = 0,
    this.emailVerified = 0,
    this.broadcastOptOut = 0,
  });

  factory CoreKpis.fromJson(Map<String, dynamic> json) {
    return CoreKpis(
      totalUsers: NumberParser.toInt(
        json['total_users'] ?? json['totalUsers'],
      ),
      verifiedDeposits: NumberParser.toInt(
        json['verified_deposits'] ?? json['verifiedDeposits'],
      ),
      pending: NumberParser.toInt(json['pending']),
      validEmails: NumberParser.toInt(
        json['valid_emails'] ?? json['validEmails'],
      ),
      onboarded: NumberParser.toInt(json['onboarded']),
      introSent: NumberParser.toInt(
        json['intro_sent'] ?? json['introSent'],
      ),
      active7d: NumberParser.toInt(
        json['active_7d'] ?? json['active7d'],
      ),
      active24h: NumberParser.toInt(
        json['active_24h'] ?? json['active24h'],
      ),
      active14d: NumberParser.toInt(
        json['active_14d'] ?? json['active14d'],
      ),
      active30d: NumberParser.toInt(
        json['active_30d'] ?? json['active30d'],
      ),
      messages7d: NumberParser.toInt(
        json['messages_7d'] ?? json['messages7d'],
      ),
      telegramVerified: NumberParser.toInt(
        json['telegram_verified'] ?? json['telegramVerified'],
      ),
      emailVerified: NumberParser.toInt(
        json['email_verified'] ?? json['emailVerified'],
      ),
      broadcastOptOut: NumberParser.toInt(
        json['broadcast_opt_out'] ?? json['broadcastOptOut'],
      ),
    );
  }
}

class DashboardRates {
  final double conversion;
  final double email;
  final double engagement7d;
  final double engagement24h;
  final double engagement30d;
  final double messagePerActive7d;
  final double retentionW1;
  final double retentionM1;
  final double qualified100;
  final double qualified300;
  final double qualified500;
  final double hotPending48h;
  final double churnRisk14d;

  const DashboardRates({
    required this.conversion,
    required this.email,
    required this.engagement7d,
    this.engagement24h = 0,
    this.engagement30d = 0,
    this.messagePerActive7d = 0,
    required this.retentionW1,
    required this.retentionM1,
    this.qualified100 = 0,
    required this.qualified300,
    this.qualified500 = 0,
    required this.hotPending48h,
    required this.churnRisk14d,
  });

  factory DashboardRates.fromJson(Map<String, dynamic> json) {
    return DashboardRates(
      conversion: NumberParser.toDouble(json['conversion']),
      email: NumberParser.toDouble(json['email']),
      engagement7d: NumberParser.toDouble(
        json['engagement_7d'] ?? json['engagement7d'],
      ),
      engagement24h: NumberParser.toDouble(
        json['engagement_24h'] ?? json['engagement24h'],
      ),
      engagement30d: NumberParser.toDouble(
        json['engagement_30d'] ?? json['engagement30d'],
      ),
      messagePerActive7d: NumberParser.toDouble(
        json['message_per_active_7d'] ?? json['messagePerActive7d'],
      ),
      retentionW1: NumberParser.toDouble(
        json['retention_w1'] ?? json['retentionW1'],
      ),
      retentionM1: NumberParser.toDouble(
        json['retention_m1'] ?? json['retentionM1'],
      ),
      qualified100: NumberParser.toDouble(
        json['qualified_100'] ?? json['qualified100'],
      ),
      qualified300: NumberParser.toDouble(
        json['qualified_300'] ?? json['qualified300'],
      ),
      qualified500: NumberParser.toDouble(
        json['qualified_500'] ?? json['qualified500'],
      ),
      hotPending48h: NumberParser.toDouble(
        json['hot_pending_48h'] ?? json['hotPending48h'],
      ),
      churnRisk14d: NumberParser.toDouble(
        json['churn_risk_14d'] ?? json['churnRisk14d'],
      ),
    );
  }
}

class FunnelData {
  final int start;
  final int onboarded;
  final int introSent;
  final int verified;

  const FunnelData({
    required this.start,
    required this.onboarded,
    required this.introSent,
    required this.verified,
  });

  factory FunnelData.fromJson(Map<String, dynamic> json) {
    return FunnelData(
      start: NumberParser.toInt(json['start']),
      onboarded: NumberParser.toInt(json['onboarded']),
      introSent: NumberParser.toInt(
        json['intro_sent'] ?? json['introSent'],
      ),
      verified: NumberParser.toInt(json['verified']),
    );
  }

  double get crStartToOnboarded {
    if (start <= 0) return 0;
    return onboarded / start;
  }

  double get crOnboardedToIntro {
    if (onboarded <= 0) return 0;
    return introSent / onboarded;
  }

  double get crIntroToVerified {
    if (introSent <= 0) return 0;
    return verified / introSent;
  }
}

class ValueData {
  final double totalAmount;
  final double totalVerified;
  final double averageVerified;
  final double p50Verified;
  final double p90Verified;
  final double medianAllNonnull;

  final int qualified100;
  final int qualified300;
  final int qualified500;

  final int verified100;
  final int verified300;
  final int verified500;

  const ValueData({
    required this.totalAmount,
    required this.totalVerified,
    required this.averageVerified,
    required this.p50Verified,
    required this.p90Verified,
    this.medianAllNonnull = 0,
    this.qualified100 = 0,
    this.qualified300 = 0,
    required this.qualified500,
    this.verified100 = 0,
    this.verified300 = 0,
    required this.verified500,
  });

  factory ValueData.fromJson(Map<String, dynamic> json) {
    return ValueData(
      totalAmount: NumberParser.toDouble(
        json['total_amount_all'] ?? json['totalAmount'],
      ),
      totalVerified: NumberParser.toDouble(
        json['total_verified'] ?? json['totalVerified'],
      ),
      averageVerified: NumberParser.toDouble(
        json['average_verified'] ?? json['averageVerified'],
      ),
      p50Verified: NumberParser.toDouble(
        json['p50_verified'] ?? json['p50Verified'],
      ),
      p90Verified: NumberParser.toDouble(
        json['p90_verified'] ?? json['p90Verified'],
      ),
      medianAllNonnull: NumberParser.toDouble(
        json['median_all_nonnull'] ?? json['medianAllNonnull'],
      ),
      qualified100: NumberParser.toInt(
        json['qualified_100_all'] ?? json['qualified100'],
      ),
      qualified300: NumberParser.toInt(
        json['qualified_300_all'] ?? json['qualified300'],
      ),
      qualified500: NumberParser.toInt(
        json['qualified_500_all'] ?? json['qualified500'],
      ),
      verified100: NumberParser.toInt(
        json['qualified_100_verified'] ?? json['verified100'],
      ),
      verified300: NumberParser.toInt(
        json['qualified_300_verified'] ?? json['verified300'],
      ),
      verified500: NumberParser.toInt(
        json['qualified_500_verified'] ?? json['verified500'],
      ),
    );
  }
}

class SegmentData {
  final int pendingNoEmail;
  final int pendingHasEmail;

  /// Compatibility field for old UI.
  /// For the new API, this means verified users below 300:
  /// verified_lt100 + verified_100_to_299.
  final int verifiedLt300;

  /// The new API does not currently return 300-499 separately.
  /// We keep this for old widgets and set it to 0 unless API sends it.
  final int verified300To499;

  /// Compatibility field for old UI.
  /// For the new API, this uses verified_ge300.
  final int verifiedGe500;

  final int verifiedLt100;
  final int verified100To299;
  final int verifiedGe300;

  final int hotPending48h;
  final int new7d;
  final int new30d;

  const SegmentData({
    required this.pendingNoEmail,
    required this.pendingHasEmail,
    required this.verifiedLt300,
    required this.verified300To499,
    required this.verifiedGe500,
    this.verifiedLt100 = 0,
    this.verified100To299 = 0,
    this.verifiedGe300 = 0,
    this.hotPending48h = 0,
    this.new7d = 0,
    this.new30d = 0,
  });

  factory SegmentData.fromJson(Map<String, dynamic> json) {
    final verifiedLt100 = NumberParser.toInt(
      json['verified_lt100'] ?? json['verifiedLt100'],
    );

    final verified100To299 = NumberParser.toInt(
      json['verified_100_to_299'] ?? json['verified100To299'],
    );

    final verifiedGe300 = NumberParser.toInt(
      json['verified_ge300'] ?? json['verifiedGe300'],
    );

    return SegmentData(
      pendingNoEmail: NumberParser.toInt(
        json['pending_no_email'] ?? json['pendingNoEmail'],
      ),
      pendingHasEmail: NumberParser.toInt(
        json['pending_has_email'] ?? json['pendingHasEmail'],
      ),
      verifiedLt300: NumberParser.toInt(
        json['verified_lt300'] ?? json['verifiedLt300'],
        fallback: verifiedLt100 + verified100To299,
      ),
      verified300To499: NumberParser.toInt(
        json['verified_300_to_499'] ??
            json['verified_300_499'] ??
            json['verified300To499'],
      ),
      verifiedGe500: NumberParser.toInt(
        json['verified_ge500'] ?? json['verifiedGe500'],
        fallback: verifiedGe300,
      ),
      verifiedLt100: verifiedLt100,
      verified100To299: verified100To299,
      verifiedGe300: verifiedGe300,
      hotPending48h: NumberParser.toInt(
        json['hot_pending_48h'] ?? json['hotPending48h'],
      ),
      new7d: NumberParser.toInt(json['new_7d'] ?? json['new7d']),
      new30d: NumberParser.toInt(json['new_30d'] ?? json['new30d']),
    );
  }
}

class DashboardOperations {
  final int totalCampaigns;
  final int activeCampaigns;
  final int totalBroadcasts;
  final int sentBroadcasts;
  final int draftBroadcasts;
  final int scheduledBroadcasts;
  final int totalSignals;
  final int activeSignals;

  const DashboardOperations({
    this.totalCampaigns = 0,
    this.activeCampaigns = 0,
    this.totalBroadcasts = 0,
    this.sentBroadcasts = 0,
    this.draftBroadcasts = 0,
    this.scheduledBroadcasts = 0,
    this.totalSignals = 0,
    this.activeSignals = 0,
  });

  factory DashboardOperations.fromJson(Map<String, dynamic> json) {
    return DashboardOperations(
      totalCampaigns: NumberParser.toInt(json['total_campaigns']),
      activeCampaigns: NumberParser.toInt(json['active_campaigns']),
      totalBroadcasts: NumberParser.toInt(json['total_broadcasts']),
      sentBroadcasts: NumberParser.toInt(json['sent_broadcasts']),
      draftBroadcasts: NumberParser.toInt(json['draft_broadcasts']),
      scheduledBroadcasts: NumberParser.toInt(json['scheduled_broadcasts']),
      totalSignals: NumberParser.toInt(json['total_signals']),
      activeSignals: NumberParser.toInt(json['active_signals']),
    );
  }
}

class DashboardReport {
  final String dailyTitle;
  final String dailySummary;
  final String expertTitle;
  final String expertSummary;

  const DashboardReport({
    this.dailyTitle = '',
    this.dailySummary = '',
    this.expertTitle = '',
    this.expertSummary = '',
  });

  factory DashboardReport.fromJson(Map<String, dynamic> json) {
    return DashboardReport(
      dailyTitle: NumberParser.toStringValue(
        json['daily_title'],
        fallback: 'MoneyTherapist Daily Report',
      ),
      dailySummary: NumberParser.toStringValue(json['daily_summary']),
      expertTitle: NumberParser.toStringValue(
        json['expert_title'],
        fallback: 'MoneyTherapist Expert Report',
      ),
      expertSummary: NumberParser.toStringValue(json['expert_summary']),
    );
  }
}

class RecommendedAction {
  final String title;
  final int count;
  final String action;

  const RecommendedAction({
    required this.title,
    required this.count,
    required this.action,
  });

  factory RecommendedAction.fromJson(Map<String, dynamic> json) {
    return RecommendedAction(
      title: NumberParser.toStringValue(
        json['title'],
        fallback: 'Recommended Action',
      ),
      count: NumberParser.toInt(json['count']),
      action: NumberParser.toStringValue(json['action']),
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

class NumberParser {
  static int toInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();

    if (value is String) {
      final cleaned = value.replaceAll(',', '').trim();

      if (cleaned.isEmpty ||
          cleaned.toLowerCase() == 'null' ||
          cleaned.toLowerCase() == 'undefined') {
        return fallback;
      }

      return int.tryParse(cleaned) ??
          double.tryParse(cleaned)?.toInt() ??
          fallback;
    }

    return fallback;
  }

  static double toDouble(dynamic value, {double fallback = 0}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();

    if (value is String) {
      final cleaned = value.replaceAll(',', '').trim();

      if (cleaned.isEmpty ||
          cleaned.toLowerCase() == 'null' ||
          cleaned.toLowerCase() == 'undefined') {
        return fallback;
      }

      return double.tryParse(cleaned) ?? fallback;
    }

    return fallback;
  }

  static String toStringValue(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;

    final text = value.toString().trim();

    if (text.isEmpty ||
        text.toLowerCase() == 'null' ||
        text.toLowerCase() == 'undefined') {
      return fallback;
    }

    return text;
  }
}