import 'package:flutter/material.dart';

import '../../app/app_form_styles.dart';
import 'campaign_model.dart';

class CreateSignalSheet extends StatefulWidget {
  final List<CampaignModel> campaigns;

  final Future<void> Function({
    required int campaignId,
    required String title,
    required String signalType,
    required String market,
    required double entryPrice,
    required double stopLoss,
    required double takeProfit1,
    required double takeProfit2,
    required double takeProfit3,
    required String riskLevel,
    required String messageText,
    required int targetChatId,
    required String adminUsername,
  }) onSubmit;

  const CreateSignalSheet({
    super.key,
    required this.campaigns,
    required this.onSubmit,
  });

  @override
  State<CreateSignalSheet> createState() => _CreateSignalSheetState();
}

class _CreateSignalSheetState extends State<CreateSignalSheet> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController(text: 'BTC Test Signal');
  final _signalTypeController = TextEditingController(text: 'crypto');
  final _marketController = TextEditingController(text: 'BTC/USDT');
  final _entryController = TextEditingController(text: '67200');
  final _stopLossController = TextEditingController(text: '66400');
  final _tp1Controller = TextEditingController(text: '68000');
  final _tp2Controller = TextEditingController(text: '69500');
  final _tp3Controller = TextEditingController(text: '70500');
  final _targetChatIdController = TextEditingController(text: '7376947596');
  final _adminUsernameController = TextEditingController(text: 'RadicalaAI');

  int? _selectedCampaignId;
  String _riskLevel = 'medium';
  bool _isSending = false;

  @override
  void initState() {
    super.initState();

    if (widget.campaigns.isNotEmpty) {
      _selectedCampaignId = widget.campaigns.first.id;
    }

    _titleController.addListener(_refreshPreview);
    _marketController.addListener(_refreshPreview);
    _entryController.addListener(_refreshPreview);
    _stopLossController.addListener(_refreshPreview);
    _tp1Controller.addListener(_refreshPreview);
    _tp2Controller.addListener(_refreshPreview);
    _tp3Controller.addListener(_refreshPreview);
  }

  void _refreshPreview() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_refreshPreview);
    _marketController.removeListener(_refreshPreview);
    _entryController.removeListener(_refreshPreview);
    _stopLossController.removeListener(_refreshPreview);
    _tp1Controller.removeListener(_refreshPreview);
    _tp2Controller.removeListener(_refreshPreview);
    _tp3Controller.removeListener(_refreshPreview);

    _titleController.dispose();
    _signalTypeController.dispose();
    _marketController.dispose();
    _entryController.dispose();
    _stopLossController.dispose();
    _tp1Controller.dispose();
    _tp2Controller.dispose();
    _tp3Controller.dispose();
    _targetChatIdController.dispose();
    _adminUsernameController.dispose();

    super.dispose();
  }

  String get _riskDisplay {
    return _riskLevel[0].toUpperCase() + _riskLevel.substring(1);
  }

  String get _messagePreview {
    return '''
🚀 <b>${_titleController.text.trim()}</b>

Market: ${_marketController.text.trim()}
Entry: ${_entryController.text.trim()}
TP1: ${_tp1Controller.text.trim()}
TP2: ${_tp2Controller.text.trim()}
TP3: ${_tp3Controller.text.trim()}
SL: ${_stopLossController.text.trim()}
Risk: $_riskDisplay

This is a test signal.
''';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCampaignId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a campaign first.'),
          backgroundColor: Color(0xFF991B1B),
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await widget.onSubmit(
        campaignId: _selectedCampaignId!,
        title: _titleController.text.trim(),
        signalType: _signalTypeController.text.trim(),
        market: _marketController.text.trim(),
        entryPrice: double.parse(_entryController.text.trim()),
        stopLoss: double.parse(_stopLossController.text.trim()),
        takeProfit1: double.parse(_tp1Controller.text.trim()),
        takeProfit2: double.parse(_tp2Controller.text.trim()),
        takeProfit3: double.parse(_tp3Controller.text.trim()),
        riskLevel: _riskLevel,
        messageText: _messagePreview,
        targetChatId: int.parse(_targetChatIdController.text.trim()),
        adminUsername: _adminUsernameController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send signal: $e'),
          backgroundColor: const Color(0xFF991B1B),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCampaign = widget.campaigns
        .where((campaign) => campaign.id == _selectedCampaignId)
        .cast<CampaignModel?>()
        .firstOrNull;

    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 780),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: appSheetBackgroundColor(context),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Create New Signal',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: appPrimaryTextColor(context),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _isSending
                          ? null
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
                  'Select a campaign, prepare the signal, preview the message, then send it to Telegram.',
                  style: TextStyle(
                    color: appSecondaryTextColor(context),
                    fontSize: 14,
                    height: 1.4,
                    decoration: TextDecoration.none,
                  ),
                ),

                const SizedBox(height: 20),

                const _SectionTitle('Campaign'),

                const SizedBox(height: 10),

                DropdownButtonFormField<int>(
                  value: _selectedCampaignId,
                  isExpanded: true,
                  style: appFieldTextStyle(context),
                  dropdownColor: appCardBackgroundColor(context),
                  iconEnabledColor: appSecondaryTextColor(context),
                  decoration: appInputDecoration(
                    context,
                    label: 'Campaign',
                  ),
                  items: widget.campaigns.map((campaign) {
                    return DropdownMenuItem<int>(
                      value: campaign.id,
                      child: Text(
                        '${campaign.name} (${campaign.sentSignals}/${campaign.totalSignals} sent)',
                        overflow: TextOverflow.ellipsis,
                        style: appFieldTextStyle(context),
                      ),
                    );
                  }).toList(),
                  onChanged: _isSending
                      ? null
                      : (value) {
                          setState(() {
                            _selectedCampaignId = value;
                          });
                        },
                  validator: (value) {
                    if (value == null) {
                      return 'Campaign is required';
                    }
                    return null;
                  },
                ),

                if (selectedCampaign != null) ...[
                  const SizedBox(height: 10),
                  _CampaignInfoCard(campaign: selectedCampaign),
                ],

                const SizedBox(height: 18),

                const _SectionTitle('Basic Info'),

                const SizedBox(height: 10),

                _TextInput(
                  controller: _titleController,
                  label: 'Signal Title',
                ),

                _TextInput(
                  controller: _signalTypeController,
                  label: 'Signal Type',
                ),

                _TextInput(
                  controller: _marketController,
                  label: 'Market / Pair',
                ),

                const SizedBox(height: 16),

                const _SectionTitle('Trade Setup'),

                const SizedBox(height: 10),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 560;

                    if (isNarrow) {
                      return Column(
                        children: [
                          _TextInput(
                            controller: _entryController,
                            label: 'Entry',
                            keyboardType: TextInputType.number,
                            isNumber: true,
                          ),
                          _TextInput(
                            controller: _stopLossController,
                            label: 'Stop Loss',
                            keyboardType: TextInputType.number,
                            isNumber: true,
                          ),
                          _TextInput(
                            controller: _tp1Controller,
                            label: 'TP1',
                            keyboardType: TextInputType.number,
                            isNumber: true,
                          ),
                          _TextInput(
                            controller: _tp2Controller,
                            label: 'TP2',
                            keyboardType: TextInputType.number,
                            isNumber: true,
                          ),
                          _TextInput(
                            controller: _tp3Controller,
                            label: 'TP3',
                            keyboardType: TextInputType.number,
                            isNumber: true,
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _TextInput(
                                controller: _entryController,
                                label: 'Entry',
                                keyboardType: TextInputType.number,
                                isNumber: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _TextInput(
                                controller: _stopLossController,
                                label: 'Stop Loss',
                                keyboardType: TextInputType.number,
                                isNumber: true,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _TextInput(
                                controller: _tp1Controller,
                                label: 'TP1',
                                keyboardType: TextInputType.number,
                                isNumber: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _TextInput(
                                controller: _tp2Controller,
                                label: 'TP2',
                                keyboardType: TextInputType.number,
                                isNumber: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _TextInput(
                                controller: _tp3Controller,
                                label: 'TP3',
                                keyboardType: TextInputType.number,
                                isNumber: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: _riskLevel,
                  style: appFieldTextStyle(context),
                  dropdownColor: appCardBackgroundColor(context),
                  iconEnabledColor: appSecondaryTextColor(context),
                  decoration: appInputDecoration(
                    context,
                    label: 'Risk Level',
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'low',
                      child: Text(
                        'Low',
                        style: appFieldTextStyle(context),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'medium',
                      child: Text(
                        'Medium',
                        style: appFieldTextStyle(context),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'high',
                      child: Text(
                        'High',
                        style: appFieldTextStyle(context),
                      ),
                    ),
                  ],
                  onChanged: _isSending
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() {
                            _riskLevel = value;
                          });
                        },
                ),

                const SizedBox(height: 16),

                const _SectionTitle('Delivery'),

                const SizedBox(height: 10),

                _TextInput(
                  controller: _targetChatIdController,
                  label: 'Target Chat ID',
                  keyboardType: TextInputType.number,
                  isInteger: true,
                ),

                _TextInput(
                  controller: _adminUsernameController,
                  label: 'Admin Username',
                ),

                const SizedBox(height: 16),

                const _SectionTitle('Message Preview'),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: appDarkPreviewColor(context),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: appIsDarkMode(context)
                          ? Colors.white12
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    _cleanHtml(_messagePreview),
                    style: const TextStyle(
                      color: Colors.white,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                FilledButton.icon(
                  onPressed: _isSending ? null : _submit,
                  icon: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(_isSending ? 'Sending...' : 'Send Signal'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _cleanHtml(String value) {
    return value.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}

class _CampaignInfoCard extends StatelessWidget {
  final CampaignModel campaign;

  const _CampaignInfoCard({
    required this.campaign,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appBorderColor(context),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.folder_rounded,
            color: Color(0xFF2563EB),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              campaign.description?.trim().isNotEmpty == true
                  ? campaign.description!
                  : 'Active campaign',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: appSecondaryTextColor(context),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${campaign.sentSignals}/${campaign.totalSignals}',
            style: TextStyle(
              color: appPrimaryTextColor(context),
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool isNumber;
  final bool isInteger;

  const _TextInput({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.isNumber = false,
    this.isInteger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: appFieldTextStyle(context),
        cursorColor: const Color(0xFF2563EB),
        decoration: appInputDecoration(
          context,
          label: label,
        ),
        validator: (value) {
          final text = value?.trim() ?? '';

          if (text.isEmpty) {
            return '$label is required';
          }

          if (isInteger && int.tryParse(text) == null) {
            return '$label must be a valid integer';
          }

          if (isNumber && double.tryParse(text) == null) {
            return '$label must be a valid number';
          }

          return null;
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: appPrimaryTextColor(context),
        fontSize: 16,
        fontWeight: FontWeight.w900,
        decoration: TextDecoration.none,
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