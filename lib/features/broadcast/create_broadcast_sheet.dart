import 'package:flutter/material.dart';

import '../../app/app_form_styles.dart';
import '../signals/campaign_model.dart';
import 'broadcast_audience_model.dart';
import 'broadcast_media_pick_result.dart';
import 'broadcast_media_picker.dart';
import 'broadcast_model.dart';
import 'broadcast_service.dart';
import 'broadcast_voice_recorder.dart';

class CreateBroadcastSheet extends StatefulWidget {
  final List<CampaignModel> campaigns;
  final String? adminUsername;
  final int? adminTelegramUserId;
  final BroadcastService service;

  const CreateBroadcastSheet({
    super.key,
    required this.campaigns,
    required this.adminUsername,
    this.adminTelegramUserId,
    required this.service,
  });

  @override
  State<CreateBroadcastSheet> createState() => _CreateBroadcastSheetState();
}

class _CreateBroadcastSheetState extends State<CreateBroadcastSheet> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _mediaUrlController = TextEditingController();
  final _mediaFileIdController = TextEditingController();
  final _mediaFileIdFocusNode = FocusNode();
  final _mediaUrlFocusNode = FocusNode();

  String _messageType = 'text';
  String _targetSegment = 'all_users';
  int? _campaignId;

  bool _isPreviewing = false;
  bool _isCreating = false;
  bool _isSending = false;
  bool _isUploadingMedia = false;
  bool _isRecordingVoice = false;
  String? _selectedMediaFileName;
  BroadcastVoiceRecordingSession? _voiceRecordingSession;

  bool _scheduleForLater = false;
  DateTime? _scheduledDateTime;

  BroadcastAudiencePreview? _preview;
  BroadcastModel? _createdBroadcast;

  static const List<String> _messageTypes = ['text', 'photo', 'video', 'voice'];

  static const List<String> _targetSegments = [
    'all_users',
    'pending_deposit',
    'verified_users',
    'qualified_100',
    'qualified_300',
    'vip_500',
    'warm_leads',
    'engaged_leads',
    'new_leads',
    'inactive_7d',
    'inactive_30d',
    'has_email',
    'no_email',
  ];

  @override
  void initState() {
    super.initState();

    _campaignId = widget.campaigns.isEmpty ? null : widget.campaigns.first.id;

    _titleController.text = 'MoneyTherapist Broadcast';
    _messageController.text = 'Hello MoneyTherapist users.';

    for (final controller in [
      _titleController,
      _messageController,
      _mediaUrlController,
      _mediaFileIdController,
    ]) {
      controller.addListener(_onFormChanged);
    }
  }

  void _onFormChanged() {
    if (!mounted) return;

    setState(() {
      _createdBroadcast = null;
    });
  }

  @override
  void dispose() {
    for (final controller in [
      _titleController,
      _messageController,
      _mediaUrlController,
      _mediaFileIdController,
    ]) {
      controller.removeListener(_onFormChanged);
      controller.dispose();
    }

    _mediaFileIdFocusNode.dispose();
    _mediaUrlFocusNode.dispose();

    super.dispose();
  }

  bool get _requiresMedia => _messageType != 'text';

  bool get _isBusy =>
      _isPreviewing ||
      _isCreating ||
      _isSending ||
      _isUploadingMedia ||
      _isRecordingVoice;

  bool get _hasMedia {
    return _hasValue(_mediaUrlController.text) ||
        _hasValue(_mediaFileIdController.text);
  }

  Future<void> _previewAudience() async {
    final formState = _formKey.currentState;
    if (formState != null && !formState.validate()) return;

    setState(() {
      _isPreviewing = true;
      _preview = null;
      _createdBroadcast = null;
    });

    try {
      final result = await widget.service.previewAudience(
        campaignId: _campaignId,
        targetSegment: _targetSegment,
        limit: 10,
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
    final formState = _formKey.currentState;
    if (formState != null && !formState.validate()) return;

    if (_preview == null) {
      _showError('Preview audience first.');
      return;
    }

    if (_preview!.totalRecipients == 0) {
      _showError('No recipients found for this segment.');
      return;
    }

    if (_requiresMedia && !_hasMedia) {
      _showError('This message type needs media URL or Telegram file_id.');
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
        campaignId: _campaignId,
        title: _titleController.text.trim(),
        messageType: _messageType,
        targetSegment: _targetSegment,
        messageText: _messageController.text.trim(),
        createdByUsername: widget.adminUsername ?? 'unknown',
        createdByTelegramId: widget.adminTelegramUserId,
        mediaUrl: _cleanOptional(_mediaUrlController.text),
        mediaFileId: _cleanOptional(_mediaFileIdController.text),
        mediaCaption: _requiresMedia
            ? _cleanOptional(_messageController.text)
            : null,
        sendMode: _scheduleForLater ? 'scheduled' : 'now',
        scheduledAt: _scheduleForLater ? _scheduledDateTime : null,
        limit: _preview!.totalRecipients,
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

  Future<void> _pickAndUploadMedia() async {
    setState(() {
      _createdBroadcast = null;
    });

    try {
      final file = await pickBroadcastMedia(
        allowedExtensions: _allowedMediaExtensions,
      );

      if (file == null) {
        _showError('File picker is only available in the web dashboard.');
        return;
      }

      await _uploadPickedMedia(file);
    } catch (e) {
      if (!mounted) return;
      _showError('Attachment upload failed: $e');
    }
  }

  Future<void> _startVoiceRecording() async {
    if (_messageType != 'voice') return;

    setState(() {
      _createdBroadcast = null;
    });

    try {
      final session = await startBroadcastVoiceRecording();
      if (!mounted) return;

      setState(() {
        _voiceRecordingSession = session;
        _isRecordingVoice = true;
        _selectedMediaFileName = 'Recording voice...';
        _mediaFileIdController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      _showError('Recording failed: $e');
    }
  }

  Future<void> _stopVoiceRecording() async {
    final session = _voiceRecordingSession;
    if (session == null) return;

    setState(() {
      _isRecordingVoice = false;
      _voiceRecordingSession = null;
      _isUploadingMedia = true;
    });

    try {
      final recording = await session.stop();
      if (!mounted) return;

      await _uploadPickedMedia(recording);
    } catch (e) {
      if (!mounted) return;
      _showError('Voice upload failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRecordingVoice = false;
          _isUploadingMedia = false;
        });
      }
    }
  }

  Future<void> _uploadPickedMedia(PickedBroadcastMedia file) async {
    setState(() {
      _isUploadingMedia = true;
      _selectedMediaFileName = file.name;
      _mediaFileIdController.clear();
    });

    try {
      final uploaded = await widget.service.uploadBroadcastMedia(
        messageType: _messageType,
        fileName: file.name,
        bytes: file.bytes,
        contentType: file.contentType,
        adminUsername: widget.adminUsername ?? 'unknown',
        adminTelegramUserId: widget.adminTelegramUserId,
        caption: _messageController.text,
      );

      if (!mounted) return;

      setState(() {
        _mediaFileIdController.text = uploaded.mediaFileId;
        if (_hasValue(uploaded.mediaUrl)) {
          _mediaUrlController.text = uploaded.mediaUrl!;
        }
      });

      _showSuccess('Attachment verified: ${uploaded.fileName ?? file.name}');
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingMedia = false;
        });
      }
    }
  }

  List<String> get _allowedMediaExtensions {
    switch (_messageType) {
      case 'photo':
        return const ['jpg', 'jpeg', 'png', 'webp'];
      case 'video':
        return const ['mp4', 'mov', 'm4v', 'webm'];
      case 'voice':
        return const ['ogg', 'oga', 'opus', 'mp3', 'm4a', 'wav'];
      default:
        return const [];
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
        limit: 100,
      );

      if (!mounted) return;

      _showSuccess(
        'Broadcast ${sent.status}. Sent: ${sent.sentCount}, failed: ${sent.failedCount}.',
      );

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
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _scheduledDateTime ?? now.add(const Duration(minutes: 10)),
      ),
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

  bool _hasValue(String? value) {
    if (value == null) return false;

    final text = value.trim();

    return text.isNotEmpty &&
        text.toLowerCase() != 'null' &&
        text.toLowerCase() != 'undefined';
  }

  String? _cleanOptional(String value) {
    final text = value.trim();

    if (!_hasValue(text)) return null;

    return text;
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
                      onPressed: _isRecordingVoice
                          ? () => _showError('Stop the voice recording first.')
                          : () => Navigator.of(context).pop(false),
                      icon: Icon(
                        Icons.close_rounded,
                        color: appSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Create simple Telegram-style text, photo, video, or voice broadcasts.',
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
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _messageType,
                        style: appFieldTextStyle(context),
                        dropdownColor: appCardBackgroundColor(context),
                        iconEnabledColor: appSecondaryTextColor(context),
                        decoration: appInputDecoration(
                          context,
                          label: 'Message type',
                        ),
                        items: _messageTypes
                            .map(
                              (type) => DropdownMenuItem<String>(
                                value: type,
                                child: Text(
                                  _label(type),
                                  style: appFieldTextStyle(context),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: _isBusy
                            ? null
                            : (value) {
                                if (value == null) return;

                                setState(() {
                                  _messageType = value;
                                  _selectedMediaFileName = null;
                                  _isRecordingVoice = false;
                                  _voiceRecordingSession = null;
                                  _mediaUrlController.clear();
                                  _mediaFileIdController.clear();
                                  _preview = null;
                                  _createdBroadcast = null;
                                });
                              },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _targetSegment,
                        style: appFieldTextStyle(context),
                        dropdownColor: appCardBackgroundColor(context),
                        iconEnabledColor: appSecondaryTextColor(context),
                        decoration: appInputDecoration(
                          context,
                          label: 'Target segment',
                        ),
                        items: _targetSegments
                            .map(
                              (segment) => DropdownMenuItem<String>(
                                value: segment,
                                child: Text(
                                  _label(segment),
                                  style: appFieldTextStyle(context),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            _targetSegment = value;
                            _preview = null;
                            _createdBroadcast = null;
                          });
                        },
                      ),
                      if (widget.campaigns.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        DropdownButtonFormField<int?>(
                          initialValue: _campaignId,
                          style: appFieldTextStyle(context),
                          dropdownColor: appCardBackgroundColor(context),
                          iconEnabledColor: appSecondaryTextColor(context),
                          decoration: appInputDecoration(
                            context,
                            label: 'Campaign filter',
                          ),
                          items: [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text(
                                'No campaign filter',
                                style: appFieldTextStyle(context),
                              ),
                            ),
                            ...widget.campaigns.map(
                              (campaign) => DropdownMenuItem<int?>(
                                value: campaign.id,
                                child: Text(
                                  campaign.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: appFieldTextStyle(context),
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _campaignId = value;
                              _preview = null;
                              _createdBroadcast = null;
                            });
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
                          label: _requiresMedia ? 'Caption' : 'Message text',
                        ).copyWith(alignLabelWithHint: true),
                        validator: (value) {
                          if (!_requiresMedia &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Message text is required';
                          }

                          return null;
                        },
                      ),
                      if (_requiresMedia) ...[
                        const SizedBox(height: 14),
                        _MediaAttachmentCard(
                          messageType: _messageType,
                          mediaUrlController: _mediaUrlController,
                          mediaFileIdController: _mediaFileIdController,
                          mediaUrlFocusNode: _mediaUrlFocusNode,
                          mediaFileIdFocusNode: _mediaFileIdFocusNode,
                          hasMedia: _hasMedia,
                          isUploading: _isUploadingMedia,
                          isRecordingVoice: _isRecordingVoice,
                          selectedFileName: _selectedMediaFileName,
                          onAttach: _isBusy ? null : _pickAndUploadMedia,
                          onStartVoiceRecording:
                              _messageType == 'voice' && !_isBusy
                              ? _startVoiceRecording
                              : null,
                          onStopVoiceRecording:
                              _messageType == 'voice' && _isRecordingVoice
                              ? _stopVoiceRecording
                              : null,
                        ),
                      ],
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
                  mediaUrl: _mediaUrlController.text,
                  mediaFileId: _mediaFileIdController.text,
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
                        onPressed: _isBusy ? null : _previewAudience,
                        icon: _isPreviewing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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
                        onPressed: _isBusy ? null : _createDraft,
                        icon: _isCreating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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
                    onPressed:
                        _createdBroadcast == null ||
                            _isSending ||
                            _isPreviewing ||
                            _isCreating ||
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

  static String _label(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
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
      decoration: _cardDecoration(context),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: scheduleForLater,
            activeThumbColor: const Color(0xFF2563EB),
            onChanged: onToggle,
            title: Text(
              'Schedule for later',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: appPrimaryTextColor(context),
              ),
            ),
            subtitle: Text(
              'Create now and let the scheduled runner send it automatically.',
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

  static BoxDecoration _cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: appCardBackgroundColor(context),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: appBorderColor(context)),
    );
  }
}

class _MediaAttachmentCard extends StatelessWidget {
  final String messageType;
  final TextEditingController mediaUrlController;
  final TextEditingController mediaFileIdController;
  final FocusNode mediaUrlFocusNode;
  final FocusNode mediaFileIdFocusNode;
  final bool hasMedia;
  final bool isUploading;
  final bool isRecordingVoice;
  final String? selectedFileName;
  final VoidCallback? onAttach;
  final VoidCallback? onStartVoiceRecording;
  final VoidCallback? onStopVoiceRecording;

  const _MediaAttachmentCard({
    required this.messageType,
    required this.mediaUrlController,
    required this.mediaFileIdController,
    required this.mediaUrlFocusNode,
    required this.mediaFileIdFocusNode,
    required this.hasMedia,
    required this.isUploading,
    required this.isRecordingVoice,
    required this.selectedFileName,
    required this.onAttach,
    required this.onStartVoiceRecording,
    required this.onStopVoiceRecording,
  });

  @override
  Widget build(BuildContext context) {
    final label = _CreateBroadcastSheetState._label(messageType);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _ScheduleCard._cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                  ),
                ),
                child: const Icon(
                  Icons.attach_file_rounded,
                  color: Color(0xFF60A5FA),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$label attachment',
                  style: TextStyle(
                    color: appPrimaryTextColor(context),
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              if (hasMedia)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF16A34A),
                ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onAttach,
            icon: isUploading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_iconForType(messageType)),
            label: Text(isUploading ? 'Verifying...' : 'Attach $label'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              alignment: Alignment.centerLeft,
            ),
          ),
          if (messageType == 'voice') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onStartVoiceRecording,
                    icon: const Icon(Icons.mic_rounded),
                    label: const Text('Record Voice'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 46),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onStopVoiceRecording,
                    icon: const Icon(Icons.stop_rounded),
                    label: Text(isRecordingVoice ? 'Stop & Upload' : 'Stop'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 46),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (selectedFileName != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  hasMedia
                      ? Icons.verified_rounded
                      : Icons.insert_drive_file_rounded,
                  size: 16,
                  color: hasMedia
                      ? const Color(0xFF16A34A)
                      : appSecondaryTextColor(context),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    selectedFileName!,
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
          const SizedBox(height: 12),
          TextFormField(
            controller: mediaFileIdController,
            focusNode: mediaFileIdFocusNode,
            style: appFieldTextStyle(context),
            cursorColor: const Color(0xFF2563EB),
            decoration: appInputDecoration(context, label: 'Telegram file_id'),
            validator: (_) {
              if (!hasMedia) {
                return '$label needs a media URL or Telegram file_id';
              }

              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: mediaUrlController,
            focusNode: mediaUrlFocusNode,
            style: appFieldTextStyle(context),
            cursorColor: const Color(0xFF2563EB),
            decoration: appInputDecoration(context, label: 'Media URL'),
            validator: (value) {
              final url = value?.trim() ?? '';
              if (url.isNotEmpty &&
                  !url.startsWith('http://') &&
                  !url.startsWith('https://')) {
                return 'Media URL must start with http:// or https://';
              }

              return null;
            },
          ),
          const SizedBox(height: 10),
          Text(
            'Select one ${label.toLowerCase()} file. n8n sends it to Telegram and returns a verified file_id.',
            style: TextStyle(
              color: appSecondaryTextColor(context),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  static IconData _iconForType(String type) {
    switch (type) {
      case 'photo':
        return Icons.image_rounded;
      case 'video':
        return Icons.videocam_rounded;
      case 'voice':
        return Icons.mic_rounded;
      default:
        return Icons.attach_file_rounded;
    }
  }
}

class _MessagePreviewCard extends StatelessWidget {
  final String title;
  final String messageType;
  final String targetSegment;
  final String messageText;
  final String mediaUrl;
  final String mediaFileId;
  final bool isScheduled;
  final DateTime? scheduledDateTime;
  final String Function(DateTime value) formatDateTime;

  const _MessagePreviewCard({
    required this.title,
    required this.messageType,
    required this.targetSegment,
    required this.messageText,
    required this.mediaUrl,
    required this.mediaFileId,
    required this.isScheduled,
    required this.scheduledDateTime,
    required this.formatDateTime,
  });

  @override
  Widget build(BuildContext context) {
    final cleanMedia = mediaFileId.trim().isNotEmpty
        ? 'Telegram file_id'
        : mediaUrl.trim().isNotEmpty
        ? mediaUrl.trim()
        : null;
    final isText = messageType == 'text';

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
              if (!isText) _DarkChip(label: cleanMedia ?? 'media required'),
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
                ? isText
                      ? 'Message text will appear here.'
                      : 'Caption is optional.'
                : messageText,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.45,
              decoration: TextDecoration.none,
            ),
          ),
          if (!isText) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Icon(
                    _MediaAttachmentCard._iconForType(messageType),
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cleanMedia ??
                          '${_CreateBroadcastSheetState._label(messageType)} attachment needed',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AudiencePreviewCard extends StatelessWidget {
  final BroadcastAudiencePreview preview;

  const _AudiencePreviewCard({required this.preview});

  @override
  Widget build(BuildContext context) {
    final users = preview.previewUsers;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: appBorderColor(context)),
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
                  value: '${preview.totalRecipients}',
                ),
              ),
              Expanded(
                child: _PreviewMetric(
                  label: 'Verified',
                  value: '${preview.verifiedRecipients}',
                ),
              ),
              Expanded(
                child: _PreviewMetric(
                  label: 'Pending',
                  value: '${preview.pendingRecipients}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PreviewMetric(
                  label: 'Qualified 100',
                  value: '${preview.qualified100}',
                ),
              ),
              Expanded(
                child: _PreviewMetric(
                  label: 'Qualified 300',
                  value: '${preview.qualified300}',
                ),
              ),
              Expanded(
                child: _PreviewMetric(
                  label: 'VIP 500',
                  value: '${preview.vip500}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _PreviewMetric(
            label: 'Verified amount',
            value: _formatMoney(preview.verifiedAmount),
          ),
          const SizedBox(height: 12),
          ...users
              .take(5)
              .map(
                (user) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF2563EB),
                        child: Text(
                          user.displayName.substring(0, 1).toUpperCase(),
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
                        user.depositCompleted ? 'Verified' : 'Pending',
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
          if (users.length > 5)
            Text(
              '+${users.length - 5} more preview users',
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

  const _PreviewMetric({required this.label, required this.value});

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

  const _DarkChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
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
