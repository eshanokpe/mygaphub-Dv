

import 'dart:convert';

class Income {
  final List<IncomeObject> incomeList;

  Income(this.incomeList);

  factory Income.fromJson(Map<String, dynamic> json) {
    List<IncomeObject> incomelist = [];

    if (json['data'] != null && json['data'] is List) {
      for (var value in json['data']) {
        incomelist.add(IncomeObject(
          id: int.tryParse(value['id'].toString()) ?? 0,
          user_id: int.tryParse(value['user_id'].toString()) ?? 0,
          automated: int.tryParse(value['automated'].toString()) ?? 0,
          income_type: value['income_type'] ?? '',
          income_currency: value['income_currency'] ?? '',
          amount: double.tryParse(value['amount'].toString()) ?? 0.0,
          channel: value['channel'] ?? '',
          income_name: value['income_name'] ?? '',
          income_frequency: value['income_frequency'] ?? '',
          portfolio_asset_id: value['portfolio_asset_id'],
          income_date: value['income_date'],
          status: value['status'] ?? '',
          isArchive: int.tryParse(value['isArchive'].toString()) ?? 0,
          extra: value['extra'],
          other: value['other'],
          currency: value['currency'] ?? '',
          chart: value['chart'] is String
              ? jsonDecode(value['chart'])
              : (value['chart'] ?? {}),
        ));
      }
    }

    return Income(incomelist);
  }
}

class IncomeObject {
  final int id;
  final int user_id;
  final int automated;
  final String income_type;
  final String income_currency;
  final double amount;
  final String channel;
  final String income_name;
  final String income_frequency;
  final dynamic portfolio_asset_id;
  final dynamic income_date;
  final String status;
  final int isArchive;
  final dynamic extra;
  final dynamic other;
  final String currency;
  final Map<String, dynamic> chart;

  IncomeObject({
    required this.id,
    required this.user_id,
    required this.automated,
    required this.income_type,
    required this.income_currency,
    required this.amount,
    required this.channel,
    required this.income_name,
    required this.income_frequency,
    required this.portfolio_asset_id,
    required this.income_date,
    required this.status,
    required this.isArchive,
    required this.extra,
    required this.other,
    required this.currency,
    required this.chart,
  });
}
