import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/app_form_styles.dart';
import '../signals/campaign_model.dart';
import 'broadcast_model.dart';
import 'broadcast_service.dart';
import 'create_broadcast_sheet.dart';

class BroadcastPage extends StatefulWidget {
  final BroadcastService service;
  final List<CampaignModel> campaigns;
  final String? adminUsername;
  final int? adminTelegramUserId;

  const BroadcastPage({
    super.key,
    required this.service,
    required this.campaigns,
    required this.adminUsername,
    this.adminTelegramUserId,
  });

  @override
  State<BroadcastPage> createState() => _BroadcastPageState();
}

class _BroadcastPageState extends State<BroadcastPage> {
  late final BroadcastService _service;
  late Future<List<BroadcastModel>> _futureBroadcasts;

  @override
  void initState() {
    super.initState();
    _service = widget.service;
    _futureBroadcasts = _service.fetchBroadcastHistory();
  }

  Future<void> _refreshHistory() async {
    setState(() {
      _futureBroadcasts = _service.fetchBroadcastHistory();
    });
    await _futureBroadcasts;
  }

  Future<void> _openCreateBroadcast() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return CreateBroadcastSheet(
          campaigns: widget.campaigns,
          adminUsername: widget.adminUsername,
          adminTelegramUserId: widget.adminTelegramUserId,
          service: _service,
        );
      },
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Broadcast operation completed.'),
          backgroundColor: Color(0xFF166534),
        ),
      );
      await _refreshHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BroadcastHeroCard(onPressed: _openCreateBroadcast),
        const SizedBox(height: 16),
        _BroadcastHistorySection(
          futureBroadcasts: _futureBroadcasts,
          onRefresh: _refreshHistory,
        ),
      ],
    );
  }
}

class _BroadcastHeroCard extends StatelessWidget {
  final VoidCallback onPressed;

  const _BroadcastHeroCard({required this.onPressed});

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
            color: Colors.black.withValues(alpha: 0.08),
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
                const _BroadcastText(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onPressed,
                    icon: const Icon(Icons.campaign_rounded),
                    label: const Text('New Broadcast'),
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              const Expanded(child: _BroadcastText()),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.campaign_rounded),
                label: const Text('New Broadcast'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BroadcastText extends StatelessWidget {
  const _BroadcastText();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Broadcast Center',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Send text, photo, video, voice, and scheduled campaigns to clean lead segments.',
          style: TextStyle(
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

class _BroadcastHistorySection extends StatelessWidget {
  final Future<List<BroadcastModel>> futureBroadcasts;
  final Future<void> Function() onRefresh;

  const _BroadcastHistorySection({
    required this.futureBroadcasts,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BroadcastModel>>(
      future: futureBroadcasts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _BroadcastHistoryLoading();
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: _cardDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Broadcast History',
                  style: TextStyle(
                    color: appPrimaryTextColor(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Failed to load broadcast history: ${snapshot.error}',
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final broadcasts = snapshot.data ?? [];

        if (broadcasts.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: _cardDecoration(context),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'No broadcasts yet.',
                    style: TextStyle(
                      color: appSecondaryTextColor(context),
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: _cardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Broadcast History',
                      style: TextStyle(
                        color: appPrimaryTextColor(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onRefresh,
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: appSecondaryTextColor(context),
                    ),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 460,
                child: Scrollbar(
                  child: ListView.builder(
                    physics: const ClampingScrollPhysics(),
                    itemCount: broadcasts.length,
                    itemBuilder: (context, index) {
                      return _BroadcastHistoryCard(
                        broadcast: broadcasts[index],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static BoxDecoration _cardDecoration(BuildContext context) {
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
}

class _BroadcastHistoryLoading extends StatelessWidget {
  const _BroadcastHistoryLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: appCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: appBorderColor(context)),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _BroadcastHistoryCard extends StatelessWidget {
  final BroadcastModel broadcast;

  const _BroadcastHistoryCard({required this.broadcast});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d • HH:mm');
    final sentAt = broadcast.sentAt == null
        ? 'Not sent yet'
        : dateFormat.format(broadcast.sentAt!.toLocal());
    final scheduledAt = broadcast.scheduledAt == null
        ? null
        : dateFormat.format(broadcast.scheduledAt!.toLocal());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          final isNarrow = constraints.maxWidth < 720;
          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BroadcastMainInfo(broadcast: broadcast),
                const SizedBox(height: 12),
                _BroadcastStats(broadcast: broadcast),
                const SizedBox(height: 10),
                _BroadcastTime(sentAt: sentAt, scheduledAt: scheduledAt),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                flex: 2,
                child: _BroadcastMainInfo(broadcast: broadcast),
              ),
              Expanded(child: _BroadcastStats(broadcast: broadcast)),
              Expanded(
                child: _BroadcastTime(sentAt: sentAt, scheduledAt: scheduledAt),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BroadcastMainInfo extends StatelessWidget {
  final BroadcastModel broadcast;

  const _BroadcastMainInfo({required this.broadcast});

  @override
  Widget build(BuildContext context) {
    final message = broadcast.mediaCaption?.trim().isNotEmpty == true
        ? broadcast.mediaCaption!
        : broadcast.messageText;
    final isText = broadcast.messageType.toLowerCase() == 'text';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BroadcastStatusPill(status: broadcast.status),
        const SizedBox(height: 8),
        Text(
          broadcast.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: appPrimaryTextColor(context),
            fontSize: 16,
            fontWeight: FontWeight.w900,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          broadcast.campaignName?.trim().isNotEmpty == true
              ? broadcast.campaignName!
              : 'No campaign',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: appSecondaryTextColor(context),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isText
              ? message
              : message.trim().isEmpty
              ? '${broadcast.messageType} broadcast'
              : 'Caption: $message',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: appSecondaryTextColor(context),
            fontSize: 12,
            height: 1.35,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _LightChip(label: broadcast.messageType),
            _LightChip(label: broadcast.targetSegment),
            _LightChip(label: broadcast.sendMode),
            if (!isText && broadcast.hasMedia) const _LightChip(label: 'media'),
          ],
        ),
      ],
    );
  }
}

class _BroadcastStats extends StatelessWidget {
  final BroadcastModel broadcast;

  const _BroadcastStats({required this.broadcast});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: [
        _SmallStat(label: 'Recipients', value: '${broadcast.totalRecipients}'),
        _SmallStat(label: 'Sent', value: '${broadcast.sentCount}'),
        _SmallStat(label: 'Failed', value: '${broadcast.failedCount}'),
        _SmallStat(
          label: 'Rate',
          value: '${broadcast.sentRatePercent.toStringAsFixed(0)}%',
        ),
      ],
    );
  }
}

class _BroadcastTime extends StatelessWidget {
  final String sentAt;
  final String? scheduledAt;

  const _BroadcastTime({required this.sentAt, required this.scheduledAt});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (scheduledAt != null) ...[
          Row(
            children: [
              Icon(
                Icons.event_rounded,
                size: 16,
                color: appSecondaryTextColor(context),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Scheduled: $scheduledAt',
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
          ),
          const SizedBox(height: 6),
        ],
        Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 16,
              color: appSecondaryTextColor(context),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                sentAt,
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
        ),
      ],
    );
  }
}

class _SmallStat extends StatelessWidget {
  final String label;
  final String value;

  const _SmallStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: appPrimaryTextColor(context),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: appSecondaryTextColor(context),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _BroadcastStatusPill extends StatelessWidget {
  final String status;

  const _BroadcastStatusPill({required this.status});

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
    } else if (normalized == 'scheduled') {
      bgColor = const Color(0xFFDBEAFE);
      textColor = const Color(0xFF1D4ED8);
    } else if (normalized == 'sending') {
      bgColor = const Color(0xFFE0E7FF);
      textColor = const Color(0xFF3730A3);
    } else if (normalized == 'partial') {
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFF92400E);
    } else if (normalized == 'cancelled') {
      bgColor = const Color(0xFFE5E7EB);
      textColor = const Color(0xFF374151);
    } else {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFF991B1B);
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
          fontSize: 11,
          fontWeight: FontWeight.w900,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

class _LightChip extends StatelessWidget {
  final String label;

  const _LightChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final dark = appIsDarkMode(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: dark ? Colors.white12 : Colors.transparent),
      ),
      child: Text(
        label.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: dark ? const Color(0xFFBFDBFE) : const Color(0xFF1D4ED8),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
