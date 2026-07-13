import 'package:flutter/material.dart';
import 'package:dashboard_core/dashboard_core.dart';

class CreateCampaignSheet extends StatefulWidget {
  final String? adminUsername;

  final Future<void> Function({
    required String name,
    required String description,
    required String startDate,
    required String endDate,
    required String status,
    required String targetSegment,
    required String createdByUsername,
  })
  onSubmit;

  const CreateCampaignSheet({
    super.key,
    required this.adminUsername,
    required this.onSubmit,
  });

  @override
  State<CreateCampaignSheet> createState() => _CreateCampaignSheetState();
}

class _CreateCampaignSheetState extends State<CreateCampaignSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController(text: 'New VIP Campaign');

  final _descriptionController = TextEditingController(
    text: 'Campaign for managing VIP trading signals.',
  );

  final _startDateController = TextEditingController(text: '2026-06-01');
  final _endDateController = TextEditingController(text: '2026-06-30');
  final _targetSegmentController = TextEditingController(text: 'vip_users');

  String _status = 'active';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController.addListener(_refreshPreview);
    _descriptionController.addListener(_refreshPreview);
  }

  void _refreshPreview() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_refreshPreview);
    _descriptionController.removeListener(_refreshPreview);

    _nameController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _targetSegmentController.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSubmit(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        startDate: _startDateController.text.trim(),
        endDate: _endDateController.text.trim(),
        status: _status,
        targetSegment: _targetSegmentController.text.trim(),
        createdByUsername: widget.adminUsername ?? 'RadicalaAI',
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create campaign: $e'),
          backgroundColor: const Color(0xFF991B1B),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 720),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: appSheetBackgroundColor(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Create Campaign',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: appPrimaryTextColor(context),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _isSaving
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
                  'Create a campaign to group signals and track performance separately.',
                  style: TextStyle(
                    color: appSecondaryTextColor(context),
                    fontSize: 14,
                    height: 1.4,
                    decoration: TextDecoration.none,
                  ),
                ),

                const SizedBox(height: 20),

                _TextInput(controller: _nameController, label: 'Campaign Name'),

                _TextInput(
                  controller: _descriptionController,
                  label: 'Description',
                  maxLines: 3,
                ),

                const SizedBox(height: 10),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 520;

                    if (isNarrow) {
                      return Column(
                        children: [
                          _TextInput(
                            controller: _startDateController,
                            label: 'Start Date',
                            hint: 'YYYY-MM-DD',
                          ),
                          _TextInput(
                            controller: _endDateController,
                            label: 'End Date',
                            hint: 'YYYY-MM-DD',
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: _TextInput(
                            controller: _startDateController,
                            label: 'Start Date',
                            hint: 'YYYY-MM-DD',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TextInput(
                            controller: _endDateController,
                            label: 'End Date',
                            hint: 'YYYY-MM-DD',
                          ),
                        ),
                      ],
                    );
                  },
                ),

                _TextInput(
                  controller: _targetSegmentController,
                  label: 'Target Segment',
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  initialValue: _status,
                  style: appFieldTextStyle(context),
                  dropdownColor: appCardBackgroundColor(context),
                  iconEnabledColor: appSecondaryTextColor(context),
                  decoration: appInputDecoration(context, label: 'Status'),
                  items: [
                    DropdownMenuItem(
                      value: 'active',
                      child: Text('Active', style: appFieldTextStyle(context)),
                    ),
                    DropdownMenuItem(
                      value: 'paused',
                      child: Text('Paused', style: appFieldTextStyle(context)),
                    ),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text(
                        'Completed',
                        style: appFieldTextStyle(context),
                      ),
                    ),
                  ],
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() {
                            _status = value;
                          });
                        },
                ),

                const SizedBox(height: 18),

                _CampaignPreviewCard(
                  name: _nameController.text.trim(),
                  description: _descriptionController.text.trim(),
                  status: _status,
                  targetSegment: _targetSegmentController.text.trim(),
                  startDate: _startDateController.text.trim(),
                  endDate: _endDateController.text.trim(),
                ),

                const SizedBox(height: 24),

                FilledButton.icon(
                  onPressed: _isSaving ? null : _submit,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_rounded),
                  label: Text(_isSaving ? 'Creating...' : 'Create Campaign'),
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
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;

  const _TextInput({
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: appFieldTextStyle(context),
        cursorColor: const Color(0xFF2563EB),
        decoration: appInputDecoration(context, label: label, hint: hint),
        validator: (value) {
          final text = value?.trim() ?? '';

          if (text.isEmpty) {
            return '$label is required';
          }

          if (label.contains('Date')) {
            final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

            if (!regex.hasMatch(text)) {
              return 'Use YYYY-MM-DD format';
            }
          }

          return null;
        },
      ),
    );
  }
}

class _CampaignPreviewCard extends StatelessWidget {
  final String name;
  final String description;
  final String status;
  final String targetSegment;
  final String startDate;
  final String endDate;

  const _CampaignPreviewCard({
    required this.name,
    required this.description,
    required this.status,
    required this.targetSegment,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appDarkPreviewColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: appIsDarkMode(context) ? Colors.white12 : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preview',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            name.isEmpty ? 'Campaign name' : name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.none,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            description.isEmpty ? 'Campaign description' : description,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.4,
              decoration: TextDecoration.none,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PreviewChip(label: status),
              _PreviewChip(
                label: targetSegment.isEmpty ? 'segment' : targetSegment,
              ),
              _PreviewChip(label: startDate.isEmpty ? 'start date' : startDate),
              _PreviewChip(label: endDate.isEmpty ? 'end date' : endDate),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  final String label;

  const _PreviewChip({required this.label});

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
