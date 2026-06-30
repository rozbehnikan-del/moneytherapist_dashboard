class DashboardData {
  final DateTime timestamp;
  final CoreKpis core;
  final DashboardRates rates;
  final FunnelData funnel;
  final ValueData value;
  final SegmentData segments;
  final RecommendedAction recommendedAction;

  const DashboardData({
    required this.timestamp,
    required this.core,
    required this.rates,
    required this.funnel,
    required this.value,
    required this.segments,
    required this.recommendedAction,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      core: CoreKpis.fromJson(json['core'] ?? {}),
      rates: DashboardRates.fromJson(json['rates'] ?? {}),
      funnel: FunnelData.fromJson(json['funnel'] ?? {}),
      value: ValueData.fromJson(json['value'] ?? {}),
      segments: SegmentData.fromJson(json['segments'] ?? {}),
      recommendedAction: RecommendedAction.fromJson(
        json['recommendedAction'] ?? {},
      ),
    );
  }
}

class CoreKpis {
  final int totalUsers;
  final int verifiedDeposits;
  final int pending;
  final int validEmails;
  final int active7d;
  final int active24h;
  final int active30d;
  final int messages7d;

  const CoreKpis({
    required this.totalUsers,
    required this.verifiedDeposits,
    required this.pending,
    required this.validEmails,
    required this.active7d,
    required this.active24h,
    required this.active30d,
    required this.messages7d,
  });

  factory CoreKpis.fromJson(Map<String, dynamic> json) {
    return CoreKpis(
      totalUsers: NumberParser.toInt(json['totalUsers']),
      verifiedDeposits: NumberParser.toInt(json['verifiedDeposits']),
      pending: NumberParser.toInt(json['pending']),
      validEmails: NumberParser.toInt(json['validEmails']),
      active7d: NumberParser.toInt(json['active7d']),
      active24h: NumberParser.toInt(json['active24h']),
      active30d: NumberParser.toInt(json['active30d']),
      messages7d: NumberParser.toInt(json['messages7d']),
    );
  }
}

class DashboardRates {
  final double conversion;
  final double email;
  final double engagement7d;
  final double retentionW1;
  final double retentionM1;
  final double qualified300;
  final double hotPending48h;
  final double churnRisk14d;

  const DashboardRates({
    required this.conversion,
    required this.email,
    required this.engagement7d,
    required this.retentionW1,
    required this.retentionM1,
    required this.qualified300,
    required this.hotPending48h,
    required this.churnRisk14d,
  });

  factory DashboardRates.fromJson(Map<String, dynamic> json) {
    return DashboardRates(
      conversion: NumberParser.toDouble(json['conversion']),
      email: NumberParser.toDouble(json['email']),
      engagement7d: NumberParser.toDouble(json['engagement7d']),
      retentionW1: NumberParser.toDouble(json['retentionW1']),
      retentionM1: NumberParser.toDouble(json['retentionM1']),
      qualified300: NumberParser.toDouble(json['qualified300']),
      hotPending48h: NumberParser.toDouble(json['hotPending48h']),
      churnRisk14d: NumberParser.toDouble(json['churnRisk14d']),
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
      introSent: NumberParser.toInt(json['introSent']),
      verified: NumberParser.toInt(json['verified']),
    );
  }
}

class ValueData {
  final double totalAmount;
  final double totalVerified;
  final double averageVerified;
  final double p50Verified;
  final double p90Verified;
  final int qualified500;
  final int verified500;

  const ValueData({
    required this.totalAmount,
    required this.totalVerified,
    required this.averageVerified,
    required this.p50Verified,
    required this.p90Verified,
    required this.qualified500,
    required this.verified500,
  });

  factory ValueData.fromJson(Map<String, dynamic> json) {
    return ValueData(
      totalAmount: NumberParser.toDouble(json['totalAmount']),
      totalVerified: NumberParser.toDouble(json['totalVerified']),
      averageVerified: NumberParser.toDouble(json['averageVerified']),
      p50Verified: NumberParser.toDouble(json['p50Verified']),
      p90Verified: NumberParser.toDouble(json['p90Verified']),
      qualified500: NumberParser.toInt(json['qualified500']),
      verified500: NumberParser.toInt(json['verified500']),
    );
  }
}

class SegmentData {
  final int pendingNoEmail;
  final int pendingHasEmail;
  final int verifiedLt300;
  final int verified300To499;
  final int verifiedGe500;

  const SegmentData({
    required this.pendingNoEmail,
    required this.pendingHasEmail,
    required this.verifiedLt300,
    required this.verified300To499,
    required this.verifiedGe500,
  });

  factory SegmentData.fromJson(Map<String, dynamic> json) {
    return SegmentData(
      pendingNoEmail: NumberParser.toInt(json['pendingNoEmail']),
      pendingHasEmail: NumberParser.toInt(json['pendingHasEmail']),
      verifiedLt300: NumberParser.toInt(json['verifiedLt300']),
      verified300To499: NumberParser.toInt(json['verified300To499']),
      verifiedGe500: NumberParser.toInt(json['verifiedGe500']),
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
      title: json['title']?.toString() ?? 'No action',
      count: NumberParser.toInt(json['count']),
      action: json['action']?.toString() ?? '',
    );
  }
}

class NumberParser {
  static int toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}