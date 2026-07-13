import 'package:flutter/material.dart';

import '../../../app/app_form_styles.dart';
import 'package:dashboard_core/dashboard_core.dart';

class SegmentCard extends StatelessWidget {
  final SegmentData segments;

  const SegmentCard({super.key, required this.segments});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Segments',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: appPrimaryTextColor(context),
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Where users are stuck or already valuable',
            style: TextStyle(
              fontSize: 14,
              color: appSecondaryTextColor(context),
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 20),
          _SegmentRow(
            label: 'Pending & No Email',
            value: segments.pendingNoEmail,
            icon: Icons.warning_amber_rounded,
          ),
          _SegmentRow(
            label: 'Pending & Has Email',
            value: segments.pendingHasEmail,
            icon: Icons.mark_email_unread_rounded,
          ),
          _SegmentRow(
            label: 'Verified < 300',
            value: segments.verifiedLt300,
            icon: Icons.trending_down_rounded,
          ),
          _SegmentRow(
            label: 'Verified 300–499',
            value: segments.verified300To499,
            icon: Icons.trending_flat_rounded,
          ),
          _SegmentRow(
            label: 'Verified ≥500',
            value: segments.verifiedGe500,
            icon: Icons.trending_up_rounded,
          ),
        ],
      ),
    );
  }
}

class _SegmentRow extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const _SegmentRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final dark = appIsDarkMode(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appBorderColor(context)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2563EB)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: dark ? Colors.white70 : const Color(0xFF374151),
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Text(
            '$value',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: appPrimaryTextColor(context),
              fontSize: 18,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: appBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: appIsDarkMode(context) ? 0.18 : 0.04,
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
