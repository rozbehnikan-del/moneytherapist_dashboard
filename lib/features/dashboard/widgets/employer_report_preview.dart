import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/app_form_styles.dart';
import '../../../app/dashboard_card.dart';
import '../dashboard_models.dart';

class EmployerReportCard extends StatelessWidget {
  final DashboardData data;

  const EmployerReportCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('M/d/yyyy, HH:mm:ss');
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    final total = data.core.totalUsers;
    final verified = data.core.verifiedDeposits;
    final pending = data.core.pending;
    final validEmails = data.core.validEmails;

    final qualified300Count = _countFromRate(
      total: total,
      rate: data.rates.qualified300,
    );

    return DashboardCard(
      title: 'Dastyarical Expert Report 🟢',
      subtitle: dateFormatter.format(data.timestamp.toLocal()),
      height: 540,
      scrollableContent: true,
      trailing: Icon(
        Icons.psychology_rounded,
        color: const Color(0xFF2563EB),
        size: 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.analytics_rounded,
            title: 'Core KPIs',
          ),
          const SizedBox(height: 10),

          _ReportGrid(
            children: [
              _ReportRow(
                label: 'Total Users',
                value: '$total',
              ),
              _ReportRow(
                label: 'Verified Deposits',
                value: '$verified (${_percent(data.rates.conversion)})',
              ),
              _ReportRow(
                label: 'Pending / Unknown',
                value: '$pending (${_percentOf(pending, total)})',
              ),
              _ReportRow(
                label: 'Valid Emails',
                value: '$validEmails (${_percent(data.rates.email)})',
              ),
              _ReportRow(
                label: 'Qualified ≥300',
                value:
                    '$qualified300Count (${_percent(data.rates.qualified300)})',
              ),
              _ReportRow(
                label: 'Active 7d',
                value:
                    '${data.core.active7d} (${_percent(data.rates.engagement7d)})',
              ),
              _ReportRow(
                label: 'Active 24h',
                value:
                    '${data.core.active24h} (${_percentOf(data.core.active24h, total)})',
              ),
              _ReportRow(
                label: 'Active 30d',
                value:
                    '${data.core.active30d} (${_percentOf(data.core.active30d, total)})',
              ),
              _ReportRow(
                label: 'Messages 7d',
                value: '${data.core.messages7d}',
              ),
            ],
          ),

          const SizedBox(height: 22),

          const _SectionTitle(
            icon: Icons.speed_rounded,
            title: 'Metrics',
          ),
          const SizedBox(height: 12),

          _MetricLine(
            label: 'Engagement 7d',
            value: data.rates.engagement7d,
          ),
          _MetricLine(
            label: 'Conversion',
            value: data.rates.conversion,
          ),
          _MetricLine(
            label: 'Email',
            value: data.rates.email,
          ),
          _MetricLine(
            label: 'Qualified ≥300',
            value: data.rates.qualified300,
          ),
          _MetricLine(
            label: 'Hot Pending 48h',
            value: data.rates.hotPending48h,
          ),
          _MetricLine(
            label: 'Churn Risk 14d',
            value: data.rates.churnRisk14d,
          ),
          _MetricLine(
            label: 'Retention W1',
            value: data.rates.retentionW1,
          ),
          _MetricLine(
            label: 'Retention M1',
            value: data.rates.retentionM1,
          ),

          const SizedBox(height: 22),

          const _SectionTitle(
            icon: Icons.filter_alt_rounded,
            title: 'Funnel',
          ),
          const SizedBox(height: 12),

          _FunnelReport(data: data),

          const SizedBox(height: 22),

          const _SectionTitle(
            icon: Icons.payments_rounded,
            title: 'Value / Deposit Amount',
          ),
          const SizedBox(height: 10),

          _ReportGrid(
            children: [
              _ReportRow(
                label: 'Total Amount',
                value: currency.format(data.value.totalAmount),
              ),
              _ReportRow(
                label: 'Total Verified',
                value: currency.format(data.value.totalVerified),
              ),
              _ReportRow(
                label: 'Average Verified',
                value: currency.format(data.value.averageVerified),
              ),
              _ReportRow(
                label: 'Median P50 Verified',
                value: currency.format(data.value.p50Verified),
              ),
              _ReportRow(
                label: 'P90 Verified',
                value: currency.format(data.value.p90Verified),
              ),
              _ReportRow(
                label: 'Qualified ≥500',
                value: '${data.value.qualified500}',
              ),
              _ReportRow(
                label: 'Verified ≥500',
                value: '${data.value.verified500}',
              ),
            ],
          ),

          const SizedBox(height: 22),

          const _SectionTitle(
            icon: Icons.group_rounded,
            title: 'User Segments',
          ),
          const SizedBox(height: 10),

          _ReportGrid(
            children: [
              _ReportRow(
                label: 'Pending & No Email',
                value: '${data.segments.pendingNoEmail}',
              ),
              _ReportRow(
                label: 'Pending & Has Email',
                value: '${data.segments.pendingHasEmail}',
              ),
              _ReportRow(
                label: 'Verified < 300',
                value: '${data.segments.verifiedLt300}',
              ),
              _ReportRow(
                label: 'Verified 300–499',
                value: '${data.segments.verified300To499}',
              ),
              _ReportRow(
                label: 'Verified ≥500',
                value: '${data.segments.verifiedGe500}',
              ),
            ],
          ),

          const SizedBox(height: 22),

          const _SectionTitle(
            icon: Icons.repeat_rounded,
            title: 'Retention',
          ),
          const SizedBox(height: 10),

          _ReportGrid(
            children: [
              _ReportRow(
                label: 'Week 1 Retention',
                value: _percent(data.rates.retentionW1),
              ),
              _ReportRow(
                label: 'Month 1 Retention',
                value: _percent(data.rates.retentionM1),
              ),
            ],
          ),

          const SizedBox(height: 22),

          _RecommendedActionBox(data: data),
        ],
      ),
    );
  }

  static int _countFromRate({
    required int total,
    required double rate,
  }) {
    return (total * rate).round();
  }

  static String _percent(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  static String _percentOf(int value, int total) {
    if (total == 0) return '0.0%';
    return '${((value / total) * 100).toStringAsFixed(1)}%';
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF2563EB),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: appPrimaryTextColor(context),
            fontSize: 17,
            fontWeight: FontWeight.w900,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

class _ReportGrid extends StatelessWidget {
  final List<Widget> children;

  const _ReportGrid({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 720;

        if (!isWide) {
          return Column(
            children: children,
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: children
              .map(
                (child) => SizedBox(
                  width: (constraints.maxWidth - 12) / 2,
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ReportRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReportRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final dark = appIsDarkMode(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: appBorderColor(context),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: appSecondaryTextColor(context),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: appPrimaryTextColor(context),
                fontSize: 13,
                fontWeight: FontWeight.w900,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  final String label;
  final double value;

  const _MetricLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final percent = '${(clamped * 100).toStringAsFixed(1)}%';
    final dark = appIsDarkMode(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                color: appSecondaryTextColor(context),
                fontSize: 13,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: clamped,
                minHeight: 12,
                backgroundColor:
                    dark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation(
                  Color(0xFF2563EB),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 58,
            child: Text(
              percent,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: appPrimaryTextColor(context),
                fontSize: 13,
                fontWeight: FontWeight.w900,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FunnelReport extends StatelessWidget {
  final DashboardData data;

  const _FunnelReport({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final start = data.funnel.start;
    final onboarded = data.funnel.onboarded;
    final introSent = data.funnel.introSent;
    final verified = data.funnel.verified;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: appDarkPreviewColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  appIsDarkMode(context) ? Colors.white12 : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              const Text(
                'Start → Onboarded → Intro Sent → Verified',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _FunnelNumber(label: 'Start', value: start),
                  _FunnelNumber(label: 'Onboarded', value: onboarded),
                  _FunnelNumber(label: 'Intro', value: introSent),
                  _FunnelNumber(label: 'Verified', value: verified),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _ReportGrid(
          children: [
            _ReportRow(
              label: 'CR Start → Onboarded',
              value: _safePercent(onboarded, start),
            ),
            _ReportRow(
              label: 'CR Onboarded → Intro',
              value: _safePercent(introSent, onboarded),
            ),
            _ReportRow(
              label: 'CR Intro → Verified',
              value: _safePercent(verified, introSent),
            ),
          ],
        ),
      ],
    );
  }

  static String _safePercent(int value, int total) {
    if (total == 0) return '0.0%';
    return '${((value / total) * 100).toStringAsFixed(1)}%';
  }
}

class _FunnelNumber extends StatelessWidget {
  final String label;
  final int value;

  const _FunnelNumber({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendedActionBox extends StatelessWidget {
  final DashboardData data;

  const _RecommendedActionBox({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appDarkPreviewColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: appIsDarkMode(context) ? Colors.white12 : Colors.transparent,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFFFACC15),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recommended Action',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Biggest opportunity: ${data.recommendedAction.title} = ${data.recommendedAction.count}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.recommendedAction.action,
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.45,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}