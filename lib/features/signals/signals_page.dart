import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashboard_core/dashboard_core.dart';

import '../../app/app_form_styles.dart';
import '../broadcast/broadcast_page.dart';
import 'campaign_card.dart';
import 'campaign_lead_list.dart';
import 'create_campaign_sheet.dart';
import 'create_signal_sheet.dart';

class SignalsPage extends StatefulWidget {
  final SignalService signalService;
  final BroadcastService broadcastService;
  final String? adminUsername;
  final String? adminRole;
  final bool showHeader;
  final bool showBroadcast;

  const SignalsPage({
    super.key,
    required this.signalService,
    required this.broadcastService,
    this.adminUsername,
    this.adminRole,
    this.showHeader = true,
    this.showBroadcast = true,
  });

  @override
  State<SignalsPage> createState() => _SignalsPageState();
}

class _SignalsPageState extends State<SignalsPage> {
  late final SignalService _service;
  late Future<List<SignalModel>> _futureSignals;
  late Future<List<CampaignModel>> _futureCampaigns;

  int? _selectedCampaignId;
  Future<List<CampaignLeadModel>>? _futureCampaignLeads;

  bool get _canManage {
    final role = widget.adminRole?.trim().toLowerCase();
    return role == 'owner' || role == 'admin';
  }

  bool get _canBroadcast {
    final role = widget.adminRole?.trim().toLowerCase();
    return role == 'owner' || role == 'admin';
  }

  @override
  void initState() {
    super.initState();
    _service = widget.signalService;
    _futureSignals = _service.fetchSignalHistory();
    _futureCampaigns = _service.fetchCampaigns();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureSignals = _service.fetchSignalHistory();
      _futureCampaigns = _service.fetchCampaigns();

      if (_selectedCampaignId != null) {
        _futureCampaignLeads = _service.fetchCampaignLeads(
          campaignId: _selectedCampaignId!,
        );
      }
    });

    final futures = <Future>[_futureSignals, _futureCampaigns];

    if (_futureCampaignLeads != null) {
      futures.add(_futureCampaignLeads!);
    }

    await Future.wait(futures);
  }

  void _loadCampaignLeads(int campaignId) {
    setState(() {
      _futureCampaignLeads = _service.fetchCampaignLeads(
        campaignId: campaignId,
      );
    });
  }

  Future<void> _openCreateSignalSheet(
    BuildContext context,
    List<CampaignModel> campaigns,
  ) async {
    if (!_canManage) return;

    if (campaigns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No campaign found. Please create a campaign first.'),
          backgroundColor: Color(0xFF991B1B),
        ),
      );
      return;
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return CreateSignalSheet(
          campaigns: campaigns,
          onSubmit: _service.sendSignal,
        );
      },
    );

    if (result == true) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signal sent successfully.'),
          backgroundColor: Color(0xFF166534),
        ),
      );

      await _refresh();
    }
  }

  Future<void> _openCreateCampaignSheet(BuildContext context) async {
    if (!_canManage) return;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return CreateCampaignSheet(
          adminUsername: widget.adminUsername,
          onSubmit: _service.createCampaign,
        );
      },
    );

    if (result == true) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Campaign created successfully.'),
          backgroundColor: Color(0xFF166534),
        ),
      );

      await _refresh();
    }
  }

  Future<void> _updateCampaignStatus({
    required CampaignModel campaign,
    required String status,
  }) async {
    if (!_canManage) return;

    try {
      await _service.updateCampaignStatus(
        campaignId: campaign.id,
        status: status,
        updatedByUsername: widget.adminUsername ?? 'unknown',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Campaign changed to $status.'),
          backgroundColor: const Color(0xFF166534),
        ),
      );

      await _refresh();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update campaign: $e'),
          backgroundColor: const Color(0xFF991B1B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appSheetBackgroundColor(context),
      body: SafeArea(
        child: FutureBuilder<List<SignalModel>>(
          future: _futureSignals,
          builder: (context, signalSnapshot) {
            if (signalSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (signalSnapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Failed to load signal history.\n${signalSnapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              );
            }

            final signals = signalSnapshot.data ?? [];

            final visibleSignals = _selectedCampaignId == null
                ? signals
                : signals
                      .where(
                        (signal) => signal.campaignId == _selectedCampaignId,
                      )
                      .toList();

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  if (widget.showHeader) ...[
                    _SignalsHeader(
                      adminUsername: widget.adminUsername,
                      adminRole: widget.adminRole,
                    ),
                    const SizedBox(height: 20),
                  ],

                  const SizedBox(height: 20),

                  FutureBuilder<List<CampaignModel>>(
                    future: _futureCampaigns,
                    builder: (context, campaignSnapshot) {
                      final campaigns = campaignSnapshot.data ?? [];
                      final isLoadingCampaigns =
                          campaignSnapshot.connectionState ==
                          ConnectionState.waiting;

                      return _CreateSignalCard(
                        isLoadingCampaigns: isLoadingCampaigns,
                        campaignCount: campaigns.length,
                        canManage: _canManage,
                        onPressed: isLoadingCampaigns || !_canManage
                            ? null
                            : () => _openCreateSignalSheet(context, campaigns),
                      );
                    },
                  ),

                  if (_canManage) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _openCreateCampaignSheet(context),
                      icon: const Icon(Icons.folder_copy_rounded),
                      label: const Text('New Campaign'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],

                  if (_canBroadcast && widget.showBroadcast) ...[
                    const SizedBox(height: 12),
                    FutureBuilder<List<CampaignModel>>(
                      future: _futureCampaigns,
                      builder: (context, campaignSnapshot) {
                        return BroadcastPage(
                          service: widget.broadcastService,
                          campaigns: campaignSnapshot.data ?? [],
                          adminUsername: widget.adminUsername,
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 24),

                  FutureBuilder<List<CampaignModel>>(
                    future: _futureCampaigns,
                    builder: (context, campaignSnapshot) {
                      final campaigns = campaignSnapshot.data ?? [];

                      if (campaignSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const _CampaignLoadingCard();
                      }

                      if (campaigns.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return _CampaignPerformanceSection(
                        campaigns: campaigns,
                        signals: signals,
                        selectedCampaignId: _selectedCampaignId,
                        canManageCampaigns: _canManage,
                        onStatusChanged: (campaign, status) {
                          _updateCampaignStatus(
                            campaign: campaign,
                            status: status,
                          );
                        },
                        onCampaignSelected: (campaignId) {
                          if (_selectedCampaignId == campaignId) {
                            setState(() {
                              _selectedCampaignId = null;
                              _futureCampaignLeads = null;
                            });
                          } else {
                            setState(() {
                              _selectedCampaignId = campaignId;
                            });

                            _loadCampaignLeads(campaignId);
                          }
                        },
                      );
                    },
                  ),

                  if (_selectedCampaignId != null &&
                      _futureCampaignLeads != null) ...[
                    const SizedBox(height: 16),
                    FutureBuilder<List<CampaignLeadModel>>(
                      future: _futureCampaignLeads,
                      builder: (context, leadSnapshot) {
                        return CampaignLeadList(
                          leads: leadSnapshot.data ?? [],
                          isLoading:
                              leadSnapshot.connectionState ==
                              ConnectionState.waiting,
                          error: leadSnapshot.error,
                          onRetry: () {
                            if (_selectedCampaignId != null) {
                              _loadCampaignLeads(_selectedCampaignId!);
                            }
                          },
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 24),

                  _SignalStatsRow(signals: visibleSignals),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Signal History',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: appPrimaryTextColor(context),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      if (_selectedCampaignId != null)
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedCampaignId = null;
                              _futureCampaignLeads = null;
                            });
                          },
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('Clear filter'),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _SignalHistorySection(signals: visibleSignals),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SignalsHeader extends StatelessWidget {
  final String? adminUsername;
  final String? adminRole;

  const _SignalsHeader({required this.adminUsername, required this.adminRole});

  @override
  Widget build(BuildContext context) {
    final username = adminUsername?.trim().isNotEmpty == true
        ? adminUsername!
        : 'Admin';

    final role = adminRole?.trim().isNotEmpty == true ? adminRole! : 'admin';

    return Row(
      children: [
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.campaign_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Signal Control Center',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: appPrimaryTextColor(context),
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_capitalize(role)} access • @$username',
                style: TextStyle(
                  fontSize: 14,
                  color: appSecondaryTextColor(context),
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: _roleBackground(role),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            role.toUpperCase(),
            style: TextStyle(
              color: _roleText(role),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }

  static Color _roleBackground(String role) {
    final normalized = role.toLowerCase();

    if (normalized == 'owner') return const Color(0xFFEDE9FE);
    if (normalized == 'admin') return const Color(0xFFDCFCE7);
    return const Color(0xFFEFF6FF);
  }

  static Color _roleText(String role) {
    final normalized = role.toLowerCase();

    if (normalized == 'owner') return const Color(0xFF6D28D9);
    if (normalized == 'admin') return const Color(0xFF166534);
    return const Color(0xFF1D4ED8);
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _CreateSignalCard extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoadingCampaigns;
  final int campaignCount;
  final bool canManage;

  const _CreateSignalCard({
    required this.onPressed,
    required this.isLoadingCampaigns,
    required this.campaignCount,
    required this.canManage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 560;

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CreateSignalText(
                  campaignCount: campaignCount,
                  isLoadingCampaigns: isLoadingCampaigns,
                  canManage: canManage,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onPressed,
                    icon: isLoadingCampaigns
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_rounded),
                    label: Text(
                      isLoadingCampaigns
                          ? 'Loading campaigns...'
                          : canManage
                          ? 'New Signal'
                          : 'Read-only access',
                    ),
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _CreateSignalText(
                  campaignCount: campaignCount,
                  isLoadingCampaigns: isLoadingCampaigns,
                  canManage: canManage,
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: onPressed,
                icon: isLoadingCampaigns
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_rounded),
                label: Text(
                  isLoadingCampaigns
                      ? 'Loading...'
                      : canManage
                      ? 'New'
                      : 'Read-only',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CreateSignalText extends StatelessWidget {
  final int campaignCount;
  final bool isLoadingCampaigns;
  final bool canManage;

  const _CreateSignalText({
    required this.campaignCount,
    required this.isLoadingCampaigns,
    required this.canManage,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = !canManage
        ? 'You can view analytics and history, but cannot send signals or manage campaigns.'
        : isLoadingCampaigns
        ? 'Loading active campaigns...'
        : campaignCount > 0
        ? '$campaignCount campaign available. Prepare and send a new signal.'
        : 'No campaign found. Create a campaign before sending signals.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create New Signal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
            height: 1.4,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

class _CampaignPerformanceSection extends StatelessWidget {
  final List<CampaignModel> campaigns;
  final List<SignalModel> signals;
  final int? selectedCampaignId;
  final bool canManageCampaigns;
  final ValueChanged<int> onCampaignSelected;
  final void Function(CampaignModel campaign, String status) onStatusChanged;

  const _CampaignPerformanceSection({
    required this.campaigns,
    required this.signals,
    required this.selectedCampaignId,
    required this.canManageCampaigns,
    required this.onCampaignSelected,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedCampaign = selectedCampaignId == null
        ? null
        : campaigns.where((c) => c.id == selectedCampaignId).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Campaign Performance',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: appPrimaryTextColor(context),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            if (selectedCampaign != null)
              TextButton.icon(
                onPressed: () => onCampaignSelected(selectedCampaign.id),
                icon: const Icon(Icons.close_rounded),
                label: const Text('Clear'),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          selectedCampaign == null
              ? 'Tap a campaign to filter signal history and stats.'
              : 'Filtering by: ${selectedCampaign.name}',
          style: TextStyle(
            fontSize: 14,
            color: appSecondaryTextColor(context),
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 350,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: campaigns.length,
            itemBuilder: (context, index) {
              final campaign = campaigns[index];

              return CampaignCard(
                campaign: campaign,
                isSelected: campaign.id == selectedCampaignId,
                onTap: () => onCampaignSelected(campaign.id),
              );
            },
          ),
        ),
        if (selectedCampaign != null) ...[
          const SizedBox(height: 14),
          _SelectedCampaignSummary(
            campaign: selectedCampaign,
            signals: signals
                .where((signal) => signal.campaignId == selectedCampaign.id)
                .toList(),
            canManageCampaigns: canManageCampaigns,
            onStatusChanged: (status) {
              onStatusChanged(selectedCampaign, status);
            },
          ),
        ],
      ],
    );
  }
}

class _SelectedCampaignSummary extends StatelessWidget {
  final CampaignModel campaign;
  final List<SignalModel> signals;
  final bool canManageCampaigns;
  final ValueChanged<String> onStatusChanged;

  const _SelectedCampaignSummary({
    required this.campaign,
    required this.signals,
    required this.canManageCampaigns,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final totalSignals = signals.length;
    final sentSignals = signals
        .where((s) => s.status.toLowerCase() == 'sent')
        .length;
    final failedSignals = signals
        .where((s) => s.status.toLowerCase() == 'failed')
        .length;

    final recommendation = campaign.newLeads == 0
        ? 'No leads are attached to this campaign yet. Connect users/leads to this campaign to measure real impact.'
        : campaign.newDeposits == 0
        ? 'Leads are coming in, but no deposits yet. Follow up with these users or improve the campaign CTA.'
        : 'Campaign is generating deposits. Keep tracking quality, conversion rate, and deposit value.';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: appDarkPreviewColor(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: appIsDarkMode(context) ? Colors.white12 : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: appIsDarkMode(context) ? 0.18 : 0.06,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Campaign Business Analytics',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              _DarkStatusPill(status: campaign.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            campaign.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            campaign.description ?? 'No description',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _DarkMetric(
                  label: 'New Leads',
                  value: '${campaign.newLeads}',
                ),
              ),
              Expanded(
                child: _DarkMetric(
                  label: 'Deposits',
                  value: '${campaign.newDeposits}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DarkMetric(
                  label: 'Deposit Value',
                  value: _formatMoney(campaign.depositAmount),
                ),
              ),
              Expanded(
                child: _DarkMetric(
                  label: 'Lead → Deposit',
                  value: '${campaign.leadToDepositRate.toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (campaign.leadToDepositRate / 100).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF22C55E)),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _DarkMetric(label: 'Signals', value: '$totalSignals'),
              ),
              Expanded(
                child: _DarkMetric(label: 'Sent', value: '$sentSignals'),
              ),
              Expanded(
                child: _DarkMetric(label: 'Failed', value: '$failedSignals'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFFFACC15),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    recommendation,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (canManageCampaigns) ...[
            const SizedBox(height: 18),
            const Text(
              'Campaign Control',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _StatusActionButton(
                  label: 'Activate',
                  icon: Icons.play_arrow_rounded,
                  isActive: campaign.status.toLowerCase() == 'active',
                  onPressed: () => onStatusChanged('active'),
                ),
                _StatusActionButton(
                  label: 'Pause',
                  icon: Icons.pause_rounded,
                  isActive: campaign.status.toLowerCase() == 'paused',
                  onPressed: () => onStatusChanged('paused'),
                ),
                _StatusActionButton(
                  label: 'Complete',
                  icon: Icons.check_rounded,
                  isActive: campaign.status.toLowerCase() == 'completed',
                  onPressed: () => onStatusChanged('completed'),
                ),
              ],
            ),
          ],
        ],
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

class _StatusActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;

  const _StatusActionButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return FilledButton.icon(
        onPressed: null,
        icon: Icon(icon),
        label: Text('$label current'),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white30),
      ),
    );
  }
}

class _DarkMetric extends StatelessWidget {
  final String label;
  final String value;

  const _DarkMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

class _DarkStatusPill extends StatelessWidget {
  final String status;

  const _DarkStatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    final color = normalized == 'active'
        ? const Color(0xFF22C55E)
        : normalized == 'paused'
        ? const Color(0xFFFACC15)
        : const Color(0xFFCBD5E1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

class _CampaignLoadingCard extends StatelessWidget {
  const _CampaignLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: appCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: appBorderColor(context)),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _SignalStatsRow extends StatelessWidget {
  final List<SignalModel> signals;

  const _SignalStatsRow({required this.signals});

  @override
  Widget build(BuildContext context) {
    final total = signals.length;
    final sent = signals.where((s) => s.status.toLowerCase() == 'sent').length;
    final failed = signals
        .where((s) => s.status.toLowerCase() == 'failed')
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 720;

        final cards = [
          _StatCard(
            title: 'Total Signals',
            value: '$total',
            icon: Icons.history_rounded,
          ),
          _StatCard(
            title: 'Sent',
            value: '$sent',
            icon: Icons.check_circle_rounded,
          ),
          _StatCard(
            title: 'Failed',
            value: '$failed',
            icon: Icons.error_rounded,
          ),
        ];

        if (isWide) {
          return Row(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                Expanded(child: cards[i]),
                if (i != cards.length - 1) const SizedBox(width: 12),
              ],
            ],
          );
        }

        return Column(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              cards[i],
              if (i != cards.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
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
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2563EB)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: appSecondaryTextColor(context),
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: appPrimaryTextColor(context),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class SignalHistoryCard extends StatelessWidget {
  final SignalModel signal;

  const SignalHistoryCard({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d • HH:mm');
    final sentAt = signal.sentAt == null
        ? 'Not sent'
        : dateFormat.format(signal.sentAt!.toLocal());

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SignalTopRow(signal: signal, sentAt: sentAt),
          const SizedBox(height: 14),
          Text(
            signal.title,
            style: TextStyle(
              color: appPrimaryTextColor(context),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            signal.market ?? 'No market',
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.none,
            ),
          ),
          if (signal.campaignName != null &&
              signal.campaignName!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.folder_rounded,
                  size: 16,
                  color: appSecondaryTextColor(context),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    signal.campaignName!,
                    style: TextStyle(
                      color: appSecondaryTextColor(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricChip(label: 'Entry', value: signal.entryPrice),
              _MetricChip(label: 'TP1', value: signal.takeProfit1),
              _MetricChip(label: 'TP2', value: signal.takeProfit2),
              _MetricChip(label: 'TP3', value: signal.takeProfit3),
              _MetricChip(label: 'SL', value: signal.stopLoss),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _cleanHtml(signal.messageText),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: appIsDarkMode(context)
                  ? Colors.white70
                  : const Color(0xFF4B5563),
              fontSize: 14,
              height: 1.45,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  static String _cleanHtml(String value) {
    return value.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}

class _SignalTopRow extends StatelessWidget {
  final SignalModel signal;
  final String sentAt;

  const _SignalTopRow({required this.signal, required this.sentAt});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatusPill(status: signal.status),
        const SizedBox(width: 8),
        if (signal.riskLevel != null) _RiskPill(risk: signal.riskLevel!),
        const Spacer(),
        Text(
          sentAt,
          style: TextStyle(
            color: appSecondaryTextColor(context),
            fontSize: 12,
            fontWeight: FontWeight.w600,
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

    if (normalized == 'sent') {
      bgColor = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF166534);
    } else if (normalized == 'draft') {
      bgColor = const Color(0xFFEFF6FF);
      textColor = const Color(0xFF1D4ED8);
    } else if (normalized == 'failed') {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFF991B1B);
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

class _RiskPill extends StatelessWidget {
  final String risk;

  const _RiskPill({required this.risk});

  @override
  Widget build(BuildContext context) {
    final normalized = risk.toLowerCase();

    final Color bgColor;
    final Color textColor;

    if (normalized == 'high') {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFF991B1B);
    } else if (normalized == 'low') {
      bgColor = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF166534);
    } else {
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFF92400E);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        risk.toUpperCase(),
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

class _SignalHistorySection extends StatelessWidget {
  final List<SignalModel> signals;

  const _SignalHistorySection({required this.signals});

  @override
  Widget build(BuildContext context) {
    if (signals.isEmpty) {
      return const _EmptySignals();
    }

    return Container(
      height: 520,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
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
      ),
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView.builder(
          physics: const ClampingScrollPhysics(),
          itemCount: signals.length,
          itemBuilder: (context, index) {
            return SignalHistoryCard(signal: signals[index]);
          },
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final double? value;

  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null) {
      return const SizedBox.shrink();
    }

    final display = value!.toStringAsFixed(value! % 1 == 0 ? 0 : 2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: appIsDarkMode(context)
            ? const Color(0xFF0F172A)
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: appBorderColor(context)),
      ),
      child: Text(
        '$label: $display',
        style: TextStyle(
          color: appIsDarkMode(context)
              ? Colors.white70
              : const Color(0xFF374151),
          fontSize: 14,
          fontWeight: FontWeight.w800,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

class _EmptySignals extends StatelessWidget {
  const _EmptySignals();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: appCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: appBorderColor(context)),
      ),
      child: Text(
        'No signals found for this filter.',
        style: TextStyle(
          color: appSecondaryTextColor(context),
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }

    return null;
  }
}
