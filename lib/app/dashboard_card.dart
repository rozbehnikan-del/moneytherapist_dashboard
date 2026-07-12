import 'package:flutter/material.dart';

import 'app_form_styles.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final double? height;
  final EdgeInsetsGeometry padding;
  final bool scrollableContent;

  const DashboardCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.trailing,
    this.height,
    this.padding = const EdgeInsets.all(20),
    this.scrollableContent = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardCardHeader(
            title: title,
            subtitle: subtitle,
            trailing: trailing,
          ),
          const SizedBox(height: 16),
          if (height == null)
            child
          else
            Expanded(
              child: scrollableContent
                  ? Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        physics: const ClampingScrollPhysics(),
                        child: child,
                      ),
                    )
                  : child,
            ),
        ],
      ),
    );

    if (height == null) {
      return content;
    }

    return SizedBox(height: height, child: content);
  }
}

class _DashboardCardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _DashboardCardHeader({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: subtitle == null
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: appPrimaryTextColor(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  decoration: TextDecoration.none,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: appSecondaryTextColor(context),
                    fontSize: 14,
                    height: 1.4,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}
