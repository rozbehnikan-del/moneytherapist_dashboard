import 'package:flutter/material.dart';

import 'package:dashboard_core/dashboard_core.dart';

class CampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  final bool isSelected;
  final VoidCallback? onTap;

  const CampaignCard({
    super.key,
    required this.campaign,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final signalRate = campaign.totalSignals == 0
        ? 0.0
        : campaign.sentSignals / campaign.totalSignals;

    final dark = appIsDarkMode(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 360,
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: appCardBackgroundColor(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : appBorderColor(context),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.18 : 0.035),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusPill(status: campaign.status),

            const SizedBox(height: 14),

            Text(
              campaign.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: appPrimaryTextColor(context),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                decoration: TextDecoration.none,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              campaign.description ?? 'No description',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: appSecondaryTextColor(context),
                fontSize: 13,
                height: 1.35,
                decoration: TextDecoration.none,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _MiniMetric(
                    label: 'Leads',
                    value: '${campaign.newLeads}',
                  ),
                ),
                Expanded(
                  child: _MiniMetric(
                    label: 'Deposits',
                    value: '${campaign.newDeposits}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _MiniMetric(
                    label: 'Value',
                    value: _formatMoney(campaign.depositAmount),
                  ),
                ),
                Expanded(
                  child: _MiniMetric(
                    label: 'Lead → Deposit',
                    value: '${campaign.leadToDepositRate.toStringAsFixed(0)}%',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: signalRate.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: dark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF2563EB)),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Signals: ${campaign.sentSignals}/${campaign.totalSignals}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: appSecondaryTextColor(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatMoney(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}K';
    }

    return '\$${value.toStringAsFixed(0)}';
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;

  const _MiniMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: appPrimaryTextColor(context),
            fontSize: 22,
            fontWeight: FontWeight.w900,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: appSecondaryTextColor(context),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    final Color bgColor;
    final Color textColor;

    if (normalized == 'active') {
      bgColor = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF166534);
    } else if (normalized == 'paused') {
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFF92400E);
    } else if (normalized == 'completed') {
      bgColor = const Color(0xFFEFF6FF);
      textColor = const Color(0xFF1D4ED8);
    } else {
      bgColor = const Color(0xFFF3F4F6);
      textColor = const Color(0xFF374151);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w900,
          fontSize: 11,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
