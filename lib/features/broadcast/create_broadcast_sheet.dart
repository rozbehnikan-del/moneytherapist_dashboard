import 'package:flutter/material.dart';

import '../../app/app_form_styles.dart';
import '../signals/campaign_model.dart';
import 'broadcast_audience_model.dart';
import 'broadcast_model.dart';
import 'broadcast_service.dart';

class CreateBroadcastSheet extends StatefulWidget {
  final List<CampaignModel> campaigns;
  final String? adminUsername;
  final BroadcastService service;

  const CreateBroadcastSheet({
    super.key,
    required this.campaigns,
    required this.adminUsername,
    required this.service,
  });

  @override
  State<CreateBroadcastSheet> createState() => _CreateBroadcastSheetState();
}

class _CreateBroadcastSheetState extends State<CreateBroadcastSheet> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  String _messageType = 'follow_up';
  String _targetSegment = 'campaign_leads';
  int? _campaignId;

  bool _isPreviewing = false;
  bool _isCreating = false;
  bool _isSending = false;

  bool _scheduleForLater = false;
  DateTime? _scheduledDateTime;

  BroadcastAudiencePreview? _preview;
  BroadcastModel? _createdBroadcast;

  @override
  void initState() {
    super.initState();

    if (widget.campaigns.isNotEmpty) {
      _campaignId = widget.campaigns.first.id;
    }

    _titleController.text = 'Follow up campaign leads';
    _messageController.text =
        'Hey! Just checking in - do you need help completing your deposit?';

    _titleController.addListener(_refreshPreview);
    _messageController.addListener(_refreshPreview);
  }

  void _refreshPreview() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_refreshPreview);
    _messageController.removeListener(_refreshPreview);

    _titleController.dispose();
    _messageController.dispose();

    super.dispose();
  }

  Future<void> _previewAudience() async {
    if (!_formKey.currentState!.validate()) return;

    if (_targetSegment == 'campaign_leads' && _campaignId == null) {
      _showError('Please select a campaign.');
      return;
    }

    setState(() {
      _isPreviewing = true;
      _preview = null;
      _createdBroadcast = null;
    });

    try {
      final result = await widget.service.previewAudience(
        campaignId: _targetSegment == 'campaign_leads' ? _campaignId : null,
        targetSegment: _targetSegment,
      );

      if (!mounted) return;

      setState(() {
        _preview = result;
      });
    } catch (e) {
      if (!mounted) return;
      _showError('Preview failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isPreviewing = false;
        });
      }
    }
  }

  Future<void> _createDraft() async {
    if (!_formKey.currentState!.validate()) return;

    if (_preview == null) {
      _showError('Preview audience first.');
      return;
    }

    if (_preview!.count == 0) {
      _showError('No recipients found for this segment.');
      return;
    }

    if (_scheduleForLater && _scheduledDateTime == null) {
      _showError('Please select schedule date and time.');
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final broadcast = await widget.service.createBroadcast(
        campaignId: _targetSegment == 'campaign_leads' ? _campaignId : null,
        title: _titleController.text.trim(),
        messageType: _messageType,
        targetSegment: _targetSegment,
        messageText: _messageController.text.trim(),
        createdByUsername: widget.adminUsername ?? 'unknown',
        scheduledAt: _scheduleForLater ? _scheduledDateTime : null,
      );

      if (!mounted) return;

      setState(() {
        _createdBroadcast = broadcast;
      });

      _showSuccess(
        _scheduleForLater
            ? 'Broadcast scheduled successfully.'
            : 'Broadcast draft created.',
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Create failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Future<void> _sendBroadcast() async {
    final broadcast = _createdBroadcast;

    if (broadcast == null) {
      _showError('Create draft first.');
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final sent = await widget.service.sendBroadcast(
        broadcastId: broadcast.id,
        adminUsername: widget.adminUsername ?? 'unknown',
      );

      if (!mounted) return;

      _showSuccess('Broadcast sent to ${sent.sentCount} users.');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _showError('Send failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _pickScheduledDateTime() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _scheduledDateTime ?? now.add(const Duration(minutes: 10)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _scheduledDateTime ?? now.add(const Duration(minutes: 10)),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );

    if (pickedTime == null || !mounted) return;

    final selected = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (selected.isBefore(now)) {
      _showError('Scheduled time must be in the future.');
      return;
    }

    setState(() {
      _scheduledDateTime = selected;
      _createdBroadcast = null;
    });
  }

  String _formatScheduledDateTime(DateTime value) {
    final date = value.toLocal();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '${date.year}-$month-$day $hour:$minute';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF991B1B),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF166534),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.65,
        maxChildSize: 0.96,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: appSheetBackgroundColor(context),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: ListView(
              controller: scrollController,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Create Broadcast',
                        style: TextStyle(
                          color: appPrimaryTextColor(context),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: Icon(
                        Icons.close_rounded,
                        color: appSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  'Select audience, preview recipients, create draft, then send.',
                  style: TextStyle(
                    color: appSecondaryTextColor(context),
                    fontSize: 14,
                    decoration: TextDecoration.none,
                  ),
                ),

                const SizedBox(height: 20),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        style: appFieldTextStyle(context),
                        cursorColor: const Color(0xFF2563EB),
                        decoration: appInputDecoration(
                          context,
                          label: 'Broadcast title',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Title is required';
                          }

                          return null;
                        },
                        onChanged: (_) {
                          setState(() {
                            _createdBroadcast = null;
                          });
                        },
                      ),

                      const SizedBox(height: 14),

                      DropdownButtonFormField<String>(
                        value: _messageType,
                        style: appFieldTextStyle(context),
                        dropdownColor: appCardBackgroundColor(context),
                        iconEnabledColor: appSecondaryTextColor(context),
                        decoration: appInputDecoration(
                          context,
                          label: 'Message type',
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'signal',
                            child: Text(
                              'Signal',
                              style: appFieldTextStyle(context),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'follow_up',
                            child: Text(
                              'Follow-up',
                              style: appFieldTextStyle(context),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'marketing',
                            child: Text(
                              'Marketing',
                              style: appFieldTextStyle(context),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'education',
                            child: Text(
                              'Education',
                              style: appFieldTextStyle(context),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'retention',
                            child: Text(
                              'Retention',
                              style: appFieldTextStyle(context),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'vip',
                            child: Text(
                              'VIP',
                              style: appFieldTextStyle(context),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            _messageType = value;
                            _preview = null;
                            _createdBroadcast = null;
                          });
                        },
                      ),

                      const SizedBox(height: 14),

                      DropdownButtonFormField<String>(
                        value: _targetSegment,
                        style: appFieldTextStyle(context),
                        dropdownColor: appCardBackgroundColor(context),
                        iconEnabledColor: appSecondaryTextColor(context),
                        decoration: appInputDecoration(
                          context,
                          label: 'Target segment',
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'all_users',
                            child: Text(
                              'All Users',
                              style: appFieldTextStyle(context),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'campaign_leads',
                            child: Text(
                              'Campaign Leads',
                              style: appFieldTextStyle(context),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'pending_deposit',
                            child: Text(
                              'Pending Deposit',
                              style: appFieldTextStyle(context),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'deposited',
                            child: Text(
                              'Deposited',
                              style: appFieldTextStyle(context),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'vip',
                            child: Text(
                              'VIP',
                              style: appFieldTextStyle(context),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'hot_lead',
                            child: Text(
                              'Hot Lead',
                              style: appFieldTextStyle(context),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'no_email',
                            child: Text(
                              'No Email',
                              style: appFieldTextStyle(context),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'inactive_7d',
                            child: Text(
                              'Inactive 7d',
                              style: appFieldTextStyle(context),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'inactive_14d',
                            child: Text(
                              'Inactive 14d',
                              style: appFieldTextStyle(context),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'inactive_30d',
                            child: Text(
                              'Inactive 30d',
                              style: appFieldTextStyle(context),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            _targetSegment = value;
                            _preview = null;
                            _createdBroadcast = null;
                          });
                        },
                      ),

                      if (_targetSegment == 'campaign_leads') ...[
                        const SizedBox(height: 14),
                        DropdownButtonFormField<int>(
                          value: _campaignId,
                          style: appFieldTextStyle(context),
                          dropdownColor: appCardBackgroundColor(context),
                          iconEnabledColor: appSecondaryTextColor(context),
                          decoration: appInputDecoration(
                            context,
                            label: 'Campaign',
                          ),
                          items: widget.campaigns
                              .map(
                                (campaign) => DropdownMenuItem<int>(
                                  value: campaign.id,
                                  child: Text(
                                    campaign.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: appFieldTextStyle(context),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _campaignId = value;
                              _preview = null;
                              _createdBroadcast = null;
                            });
                          },
                          validator: (value) {
                            if (_targetSegment == 'campaign_leads' &&
                                value == null) {
                              return 'Campaign is required';
                            }

                            return null;
                          },
                        ),
                      ],

                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _messageController,
                        minLines: 5,
                        maxLines: 10,
                        style: appFieldTextStyle(context),
                        cursorColor: const Color(0xFF2563EB),
                        decoration: appInputDecoration(
                          context,
                          label: 'Message text',
                        ).copyWith(
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Message text is required';
                          }

                          return null;
                        },
                        onChanged: (_) {
                          setState(() {
                            _createdBroadcast = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                _ScheduleCard(
                  scheduleForLater: _scheduleForLater,
                  scheduledDateTime: _scheduledDateTime,
                  onToggle: (value) {
                    setState(() {
                      _scheduleForLater = value;
                      _createdBroadcast = null;

                      if (!value) {
                        _scheduledDateTime = null;
                      }
                    });
                  },
                  onPickDateTime: _pickScheduledDateTime,
                  formatDateTime: _formatScheduledDateTime,
                ),

                const SizedBox(height: 18),

                _MessagePreviewCard(
                  title: _titleController.text,
                  messageType: _messageType,
                  targetSegment: _targetSegment,
                  messageText: _messageController.text,
                  isScheduled: _scheduleForLater,
                  scheduledDateTime: _scheduledDateTime,
                  formatDateTime: _formatScheduledDateTime,
                ),

                const SizedBox(height: 18),

                if (_preview != null) _AudiencePreviewCard(preview: _preview!),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isPreviewing ? null : _previewAudience,
                        icon: _isPreviewing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.people_alt_rounded),
                        label: Text(
                          _isPreviewing ? 'Previewing...' : 'Preview Audience',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isCreating ? null : _createDraft,
                        icon: _isCreating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(
                                _scheduleForLater
                                    ? Icons.schedule_rounded
                                    : Icons.save_rounded,
                              ),
                        label: Text(
                          _isCreating
                              ? 'Creating...'
                              : _scheduleForLater
                                  ? 'Schedule'
                                  : 'Create Draft',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _createdBroadcast == null ||
                            _isSending ||
                            _createdBroadcast!.status.toLowerCase() ==
                                'scheduled'
                        ? null
                        : _sendBroadcast,
                    icon: _isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(
                      _createdBroadcast == null
                          ? 'Create draft before sending'
                          : _createdBroadcast!.status.toLowerCase() ==
                                  'scheduled'
                              ? 'Scheduled - will send automatically'
                              : _isSending
                                  ? 'Sending...'
                                  : 'Send Broadcast',
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final bool scheduleForLater;
  final DateTime? scheduledDateTime;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickDateTime;
  final String Function(DateTime value) formatDateTime;

  const _ScheduleCard({
    required this.scheduleForLater,
    required this.scheduledDateTime,
    required this.onToggle,
    required this.onPickDateTime,
    required this.formatDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: appBorderColor(context),
        ),
      ),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: scheduleForLater,
            activeColor: const Color(0xFF2563EB),
            onChanged: onToggle,
            title: Text(
              'Schedule for later',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: appPrimaryTextColor(context),
              ),
            ),
            subtitle: Text(
              'Create this broadcast now and send it automatically at a specific time.',
              style: TextStyle(
                color: appSecondaryTextColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (scheduleForLater) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onPickDateTime,
              icon: const Icon(Icons.schedule_rounded),
              label: Text(
                scheduledDateTime == null
                    ? 'Choose date and time'
                    : formatDateTime(scheduledDateTime!),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MessagePreviewCard extends StatelessWidget {
  final String title;
  final String messageType;
  final String targetSegment;
  final String messageText;
  final bool isScheduled;
  final DateTime? scheduledDateTime;
  final String Function(DateTime value) formatDateTime;

  const _MessagePreviewCard({
    required this.title,
    required this.messageType,
    required this.targetSegment,
    required this.messageText,
    required this.isScheduled,
    required this.scheduledDateTime,
    required this.formatDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appDarkPreviewColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: appIsDarkMode(context) ? Colors.white12 : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Message Preview',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w800,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title.trim().isEmpty ? 'Untitled broadcast' : title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DarkChip(label: messageType),
              _DarkChip(label: targetSegment),
              if (isScheduled)
                _DarkChip(
                  label: scheduledDateTime == null
                      ? 'scheduled'
                      : 'scheduled ${formatDateTime(scheduledDateTime!)}',
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            messageText.trim().isEmpty
                ? 'Message text will appear here.'
                : messageText,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.45,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _AudiencePreviewCard extends StatelessWidget {
  final BroadcastAudiencePreview preview;

  const _AudiencePreviewCard({
    required this.preview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: appBorderColor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Audience Preview',
            style: TextStyle(
              color: appPrimaryTextColor(context),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PreviewMetric(
                  label: 'Recipients',
                  value: '${preview.count}',
                ),
              ),
              Expanded(
                child: _PreviewMetric(
                  label: 'Deposited',
                  value: '${preview.summary.deposited}',
                ),
              ),
              Expanded(
                child: _PreviewMetric(
                  label: 'Pending',
                  value: '${preview.summary.pending}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _PreviewMetric(
            label: 'Total deposit amount',
            value: _formatMoney(preview.summary.totalDepositAmount),
          ),
          const SizedBox(height: 12),
          ...preview.users.take(5).map(
                (user) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF2563EB),
                        child: Text(
                          user.displayName.substring(0, 1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          user.displayName,
                          style: TextStyle(
                            color: appPrimaryTextColor(context),
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      Text(
                        user.depositCompleted ? 'Deposited' : 'Pending',
                        style: TextStyle(
                          color: user.depositCompleted
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFF59E0B),
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          if (preview.users.length > 5)
            Text(
              '+${preview.users.length - 5} more recipients',
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

class _PreviewMetric extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: appPrimaryTextColor(context),
            fontSize: 20,
            fontWeight: FontWeight.w900,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          label,
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

class _DarkChip extends StatelessWidget {
  final String label;

  const _DarkChip({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        label.replaceAll('_', ' ').toUpperCase(),
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}