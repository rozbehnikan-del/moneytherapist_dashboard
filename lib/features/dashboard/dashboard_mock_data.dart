import 'dashboard_models.dart';

final mockDashboardData = DashboardData(
  timestamp: DateTime(2026, 5, 30, 21, 3, 59),
  core: const CoreKpis(
    totalUsers: 2,
    verifiedDeposits: 1,
    pending: 1,
    validEmails: 1,
    active7d: 1,
    active24h: 0,
    active30d: 4,
    messages7d: 20,
  ),
  rates: const DashboardRates(
    conversion: 0.5,
    email: 0.5,
    engagement7d: 0.5,
    retentionW1: 0.5,
    retentionM1: 0,
    qualified300: 0.5,
    hotPending48h: 0,
    churnRisk14d: 0,
  ),
  funnel: const FunnelData(
    start: 2,
    onboarded: 2,
    introSent: 2,
    verified: 1,
  ),
  value: const ValueData(
    totalAmount: 1200.15,
    totalVerified: 1200.15,
    averageVerified: 1200.15,
    p50Verified: 1200.15,
    p90Verified: 1200.15,
    qualified500: 1,
    verified500: 1,
  ),
  segments: const SegmentData(
    pendingNoEmail: 1,
    pendingHasEmail: 0,
    verifiedLt300: 0,
    verified300To499: 0,
    verifiedGe500: 1,
  ),
  recommendedAction: const RecommendedAction(
    title: 'Pending users without email',
    count: 1,
    action:
        'Run an information-completion campaign: ask for email/profile data, then guide them to the next step.',
  ),
);