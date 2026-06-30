import 'package:flutter/material.dart';

import '../../../app/app_form_styles.dart';

class MetricBar extends StatelessWidget {
  final String label;
  final double value;

  const MetricBar({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final percent = (clamped * 100).toStringAsFixed(0);
    final dark = appIsDarkMode(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: dark ? Colors.white70 : const Color(0xFF374151),
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