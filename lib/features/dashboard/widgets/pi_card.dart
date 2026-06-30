import 'package:flutter/material.dart';

import '../../../app/app_form_styles.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final dark = appIsDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: appCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: appBorderColor(context),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.18 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF2563EB),
            size: 28,
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: appPrimaryTextColor(context),
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: dark ? Colors.white70 : const Color(0xFF374151),
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: appSecondaryTextColor(context),
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}