class CampaignModel {
  final int id;
  final String name;
  final String? description;
  final String status;
  final String? targetSegment;

  final int totalSignals;
  final int sentSignals;

  final int newLeads;
  final int newDeposits;
  final double depositAmount;
  final double leadToDepositRate;

  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? lastSignalAt;

  const CampaignModel({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.targetSegment,
    required this.totalSignals,
    required this.sentSignals,
    required this.newLeads,
    required this.newDeposits,
    required this.depositAmount,
    required this.leadToDepositRate,
    required this.startDate,
    required this.endDate,
    required this.lastSignalAt,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? 'Untitled campaign',
      description: json['description']?.toString(),
      status: json['status']?.toString() ?? 'unknown',
      targetSegment: json['target_segment']?.toString(),

      totalSignals: _toInt(json['total_signals']),
      sentSignals: _toInt(json['sent_signals']),

      newLeads: _toInt(json['new_leads']),
      newDeposits: _toInt(json['new_deposits']),
      depositAmount: _toDouble(json['deposit_amount']),
      leadToDepositRate: _toDouble(json['lead_to_deposit_rate']),

      startDate: _toDate(json['start_date']),
      endDate: _toDate(json['end_date']),
      lastSignalAt: _toDate(json['last_signal_at']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
    }
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}