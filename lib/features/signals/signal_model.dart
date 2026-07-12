class SignalModel {
  final int id;
  final int? campaignId;
  final String? campaignName;
  final String title;
  final String? signalType;
  final String? market;
  final double? entryPrice;
  final double? stopLoss;
  final double? takeProfit1;
  final double? takeProfit2;
  final double? takeProfit3;
  final String? riskLevel;
  final String messageText;
  final String status;
  final String? createdByUsername;
  final DateTime? sentAt;
  final DateTime? createdAt;

  const SignalModel({
    required this.id,
    required this.campaignId,
    required this.campaignName,
    required this.title,
    required this.signalType,
    required this.market,
    required this.entryPrice,
    required this.stopLoss,
    required this.takeProfit1,
    required this.takeProfit2,
    required this.takeProfit3,
    required this.riskLevel,
    required this.messageText,
    required this.status,
    required this.createdByUsername,
    required this.sentAt,
    required this.createdAt,
  });

  factory SignalModel.fromJson(Map<String, dynamic> json) {
    return SignalModel(
      id: NumberParser.toInt(json['id']),
      campaignId: json['campaign_id'] == null
          ? null
          : NumberParser.toInt(json['campaign_id']),
      campaignName: json['campaign_name']?.toString(),
      title: json['title']?.toString() ?? 'Untitled signal',
      signalType: json['signal_type']?.toString(),
      market: json['market']?.toString(),
      entryPrice: NumberParser.toNullableDouble(json['entry_price']),
      stopLoss: NumberParser.toNullableDouble(json['stop_loss']),
      takeProfit1: NumberParser.toNullableDouble(json['take_profit_1']),
      takeProfit2: NumberParser.toNullableDouble(json['take_profit_2']),
      takeProfit3: NumberParser.toNullableDouble(json['take_profit_3']),
      riskLevel: json['risk_level']?.toString(),
      messageText: json['message_text']?.toString() ?? '',
      status: json['status']?.toString() ?? 'unknown',
      createdByUsername: json['created_by_username']?.toString(),
      sentAt: DateParser.toNullableDate(json['sent_at']),
      createdAt: DateParser.toNullableDate(json['created_at']),
    );
  }
}

class NumberParser {
  static int toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
    }
    return 0;
  }

  static double? toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class DateParser {
  static DateTime? toNullableDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
