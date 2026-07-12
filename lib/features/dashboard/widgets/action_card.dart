import 'package:flutter/material.dart';

import '../../../app/app_form_styles.dart';

class ActionCard extends StatelessWidget {
  final String title;
  final int count;
  final String action;

  const ActionCard({
    super.key,
    required this.title,
    required this.count,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: appDarkPreviewColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: appIsDarkMode(context) ? Colors.white12 : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: appIsDarkMode(context) ? 0.18 : 0.08,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFFFACC15),
            size: 32,
          ),
          const SizedBox(height: 18),
          const Text(
            'Recommended Action',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$title = $count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            action,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
