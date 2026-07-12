import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/dashboard_card.dart';
import '../../app/app_form_styles.dart';
import '../../config/project_config.dart';
import 'dashboard_models.dart';
import 'dashboard_service.dart';
import 'widgets/action_card.dart';
import 'widgets/alue_card.dart';
import 'widgets/dashboard_summary_chart.dart';
import 'widgets/employer_report_preview.dart';
import 'widgets/funnel_card.dart';
import 'widgets/metric_bar.dart';
import 'widgets/pi_card.dart';
import 'widgets/segment_card.dart';

class DashboardPage extends StatefulWidget {
  final ProjectConfig project;

  const DashboardPage({
    super.key,
    required this.project,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardService _service;
  late Future<DashboardData> _futureDashboard;

  @override
  void initState() {
    super.initState();
    _service = DashboardService(Dio());
    _futureDashboard = _service.fetchDashboard();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureDashboard = _service.fetchDashboard();
    });

    await _futureDashboard;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardData>(
      future: _futureDashboard,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: appSheetBackgroundColor(context),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading dashboard report...',
                    style: TextStyle(
                      color: appSecondaryTextColor(context),
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: appSheetBackgroundColor(context),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load dashboard.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          );
        }

        final data = snapshot.data!;

        return Scaffold(
          backgroundColor: appSheetBackgroundColor(context),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: _DashboardContent(
                      data: data,
                      project: widget.project,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardData data;
  final ProjectConfig project;

  const _DashboardContent({
    required this.data,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DashboardHeader(
          timestamp: data.timestamp,
          project: project,
        ),

        const SizedBox(height: 24),

        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;

            return GridView.count(
              crossAxisCount: isWide ? 4 : 2,
              shrinkWrap: true,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: isWide ? 1.45 : 1.15,
              children: [
                KpiCard(
                  title: 'Total Users',
                  value: '${data.core.totalUsers}',
                  subtitle: 'Users in database',
                  icon: Icons.people_alt_rounded,
                ),
                KpiCard(
                  title: 'Verified Deposits',
                  value:
                      '${data.core.verifiedDeposits}/${data.core.totalUsers}',
                  subtitle:
                      '${(data.rates.conversion * 100).toStringAsFixed(0)}% conversion',
                  icon: Icons.verified_rounded,
                ),
                KpiCard(
                  title: 'Verified Value',
                  value: currency.format(data.value.totalVerified),
                  subtitle: 'Total verified deposit',
                  icon: Icons.payments_rounded,
                ),
                KpiCard(
                  title: 'Messages 7d',
                  value: '${data.core.messages7d}',
                  subtitle: 'Recent engagement',
                  icon: Icons.chat_bubble_rounded,
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        EmployerReportCard(data: data),

        const SizedBox(height: 24),

        DashboardCard(
          title: 'Growth Overview',
          subtitle:
              'Front-page statistics for users, funnel progress, verified deposits, and recent engagement.',
          height: 390,
          child: DashboardSummaryChart(data: data),
        ),

        const SizedBox(height: 24),

        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: FunnelCard(funnel: data.funnel),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 5,
                    child: ActionCard(
                      title: data.recommendedAction.title,
                      count: data.recommendedAction.count,
                      action: data.recommendedAction.action,
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                FunnelCard(funnel: data.funnel),
                const SizedBox(height: 16),
                ActionCard(
                  title: data.recommendedAction.title,
                  count: data.recommendedAction.count,
                  action: data.recommendedAction.action,
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        const _SectionTitle(
          title: 'Product Health',
          subtitle: 'Conversion, engagement, retention and risk',
        ),

        const SizedBox(height: 12),

        _Panel(
          child: Column(
            children: [
              MetricBar(
                label: 'Engagement 7d',
                value: data.rates.engagement7d,
              ),
              MetricBar(
                label: 'Conversion',
                value: data.rates.conversion,
              ),
              MetricBar(
                label: 'Email Completion',
                value: data.rates.email,
              ),
              MetricBar(
                label: 'Qualified ≥300',
                value: data.rates.qualified300,
              ),
              MetricBar(
                label: 'Retention W1',
                value: data.rates.retentionW1,
              ),
              MetricBar(
                label: 'Retention M1',
                value: data.rates.retentionM1,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ValueCard(value: data.value),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SegmentCard(segments: data.segments),
                  ),
                ],
              );
            }

            return Column(
              children: [
                ValueCard(value: data.value),
                const SizedBox(height: 16),
                SegmentCard(segments: data.segments),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final DateTime timestamp;
  final ProjectConfig project;

  const _DashboardHeader({
    required this.timestamp,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM d, yyyy • HH:mm');

    return Row(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            project.splashAssetPath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFF2563EB),
                child: const Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.splashTitle,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: appPrimaryTextColor(context),
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Last updated: ${formatter.format(timestamp)}',
                style: TextStyle(
                  fontSize: 14,
                  color: appSecondaryTextColor(context),
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: appPrimaryTextColor(context),
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: appSecondaryTextColor(context),
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: appBorderColor(context),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              appIsDarkMode(context) ? 0.18 : 0.04,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
