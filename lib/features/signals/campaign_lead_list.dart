import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:dashboard_core/dashboard_core.dart';

class CampaignLeadList extends StatelessWidget {
  final List<CampaignLeadModel> leads;
  final bool isLoading;
  final Object? error;
  final VoidCallback onRetry;

  const CampaignLeadList({
    super.key,
    required this.leads,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: _boxDecoration(context),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: _boxDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Campaign Leads',
              style: TextStyle(
                color: appPrimaryTextColor(context),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Failed to load leads: $error',
              style: const TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (leads.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: _boxDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Campaign Leads',
              style: TextStyle(
                color: appPrimaryTextColor(context),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No leads are attached to this campaign yet.',
              style: TextStyle(
                color: appSecondaryTextColor(context),
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      );
    }

    final deposited = leads.where((lead) => lead.depositCompleted).length;
    final totalValue = leads.fold<double>(
      0,
      (sum, lead) => sum + lead.depositAmount,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _boxDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Campaign Leads',
                  style: TextStyle(
                    color: appPrimaryTextColor(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              Text(
                '${leads.length} leads • $deposited deposited',
                style: TextStyle(
                  color: appSecondaryTextColor(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Total deposit value: ${_formatMoney(totalValue)}',
            style: TextStyle(
              color: appSecondaryTextColor(context),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 14),

          SizedBox(
            height: 420,
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: leads.length,
                itemBuilder: (context, index) {
                  return _LeadCard(lead: leads[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  static BoxDecoration _boxDecoration(BuildContext context) {
    return BoxDecoration(
      color: appCardBackgroundColor(context),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: appBorderColor(context)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: appIsDarkMode(context) ? 0.18 : 0.035,
          ),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
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

class _LeadCard extends StatelessWidget {
  final CampaignLeadModel lead;

  const _LeadCard({required this.lead});

  @override
  Widget build(BuildContext context) {
    final lastMessage = lead.lastMessageAt == null
        ? 'No recent message'
        : DateFormat('MMM d • HH:mm').format(lead.lastMessageAt!.toLocal());

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appIsDarkMode(context)
            ? const Color(0xFF0F172A)
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: appBorderColor(context)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 520;

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LeadIdentity(lead: lead),
                const SizedBox(height: 12),
                _LeadStatus(lead: lead),
                const SizedBox(height: 8),
                _LeadMeta(lastMessage: lastMessage),
              ],
            );
          }

          return Row(
            children: [
              Expanded(flex: 2, child: _LeadIdentity(lead: lead)),
              Expanded(child: _LeadStatus(lead: lead)),
              Expanded(child: _LeadMeta(lastMessage: lastMessage)),
            ],
          );
        },
      ),
    );
  }
}

class _LeadIdentity extends StatelessWidget {
  final CampaignLeadModel lead;

  const _LeadIdentity({required this.lead});

  @override
  Widget build(BuildContext context) {
    final username = lead.telegramUsername?.trim().isNotEmpty == true
        ? '@${lead.telegramUsername}'
        : 'No username';

    final firstChar = lead.displayName.trim().isEmpty
        ? '?'
        : lead.displayName.substring(0, 1).toUpperCase();

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: lead.depositCompleted
              ? const Color(0xFFDCFCE7)
              : const Color(0xFFEFF6FF),
          child: Text(
            firstChar,
            style: TextStyle(
              color: lead.depositCompleted
                  ? const Color(0xFF166534)
                  : const Color(0xFF1D4ED8),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lead.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: appPrimaryTextColor(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: appSecondaryTextColor(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.none,
                ),
              ),
              if (lead.email != null && lead.email!.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  lead.email!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: appSecondaryTextColor(context),
                    fontSize: 12,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LeadStatus extends StatelessWidget {
  final CampaignLeadModel lead;

  const _LeadStatus({required this.lead});

  @override
  Widget build(BuildContext context) {
    final statusText = lead.depositCompleted ? 'Deposited' : 'Pending';

    final statusColor = lead.depositCompleted
        ? const Color(0xFF166534)
        : const Color(0xFF92400E);

    final statusBg = lead.depositCompleted
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFEF3C7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: statusBg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            statusText.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _formatMoney(lead.depositAmount),
          style: TextStyle(
            color: appPrimaryTextColor(context),
            fontSize: 18,
            fontWeight: FontWeight.w900,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          'Deposit amount',
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

class _LeadMeta extends StatelessWidget {
  final String lastMessage;

  const _LeadMeta({required this.lastMessage});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.schedule_rounded,
          size: 16,
          color: appSecondaryTextColor(context),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: appSecondaryTextColor(context),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}
