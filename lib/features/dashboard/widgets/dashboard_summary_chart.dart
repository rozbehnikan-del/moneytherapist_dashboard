import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../app/app_form_styles.dart';
import 'package:dashboard_core/dashboard_core.dart';

class DashboardSummaryChart extends StatelessWidget {
  final DashboardData data;

  const DashboardSummaryChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final dark = appIsDarkMode(context);

    final chartItems = [
      _ChartItem(label: 'Users', value: data.core.totalUsers.toDouble()),
      _ChartItem(label: 'Started', value: data.funnel.start.toDouble()),
      _ChartItem(label: 'Onboarded', value: data.funnel.onboarded.toDouble()),
      _ChartItem(label: 'Intro', value: data.funnel.introSent.toDouble()),
      _ChartItem(label: 'Verified', value: data.funnel.verified.toDouble()),
      _ChartItem(label: 'Messages', value: data.core.messages7d.toDouble()),
    ];

    final maxValue = chartItems.fold<double>(
      0,
      (max, item) => item.value > max ? item.value : max,
    );

    return BarChart(
      BarChartData(
        maxY: maxValue <= 0 ? 10 : maxValue * 1.25,
        minY: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateInterval(maxValue),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: dark ? Colors.white10 : const Color(0xFFE5E7EB),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return Text(
                  _compactNumber(value),
                  style: TextStyle(
                    color: appSecondaryTextColor(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();

                if (index < 0 || index >= chartItems.length) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    chartItems[index].label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: appSecondaryTextColor(context),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.none,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final item = chartItems[group.x.toInt()];

              return BarTooltipItem(
                '${item.label}\n${item.value.toStringAsFixed(0)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              );
            },
          ),
        ),
        barGroups: List.generate(chartItems.length, (index) {
          final item = chartItems[index];

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.value,
                width: 22,
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF2563EB),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxValue <= 0 ? 10 : maxValue * 1.25,
                  color: dark
                      ? const Color(0xFF1F2937)
                      : const Color(0xFFEFF6FF),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  static double _calculateInterval(double maxValue) {
    if (maxValue <= 10) return 2;
    if (maxValue <= 50) return 10;
    if (maxValue <= 100) return 20;
    if (maxValue <= 500) return 100;
    if (maxValue <= 1000) return 200;
    return maxValue / 5;
  }

  static String _compactNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toStringAsFixed(0);
  }
}

class _ChartItem {
  final String label;
  final double value;

  const _ChartItem({required this.label, required this.value});
}
