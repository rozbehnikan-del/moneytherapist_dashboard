import 'package:flutter/material.dart';

import '../../../app/app_form_styles.dart';
import '../dashboard_models.dart';

class FunnelCard extends StatelessWidget {
  final FunnelData funnel;

  const FunnelCard({super.key, required this.funnel});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conversion Funnel',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: appPrimaryTextColor(context),
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'How users move from start to verified deposit',
            style: TextStyle(
              fontSize: 14,
              color: appSecondaryTextColor(context),
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 20),
          _FunnelStep(title: 'Started', value: funnel.start, rate: 1),
          _FunnelStep(
            title: 'Onboarded',
            value: funnel.onboarded,
            rate: funnel.start == 0 ? 0 : funnel.onboarded / funnel.start,
          ),
          _FunnelStep(
            title: 'Intro Sent',
            value: funnel.introSent,
            rate: funnel.onboarded == 0
                ? 0
                : funnel.introSent / funnel.onboarded,
          ),
          _FunnelStep(
            title: 'Verified',
            value: funnel.verified,
            rate: funnel.introSent == 0
                ? 0
                : funnel.verified / funnel.introSent,
          ),
        ],
      ),
    );
  }
}

class _FunnelStep extends StatelessWidget {
  final String title;
  final int value;
  final double rate;

  const _FunnelStep({
    required this.title,
    required this.value,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = rate.clamp(0.0, 1.0);
    final percent = (clamped * 100).toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: appIsDarkMode(context)
                    ? Colors.white70
                    : const Color(0xFF374151),
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Expanded(
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: clamped == 0 ? 0.04 : clamped,
              child: Container(
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '$value users',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 48,
            child: Text(
              '$percent%',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: appPrimaryTextColor(context),
                decoration: TextDecoration.none,
              ),
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
