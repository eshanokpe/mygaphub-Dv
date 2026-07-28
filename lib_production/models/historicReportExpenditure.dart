import 'dart:convert';

HistoricReportExpenditure usermodelFromJson(String str) =>
    HistoricReportExpenditure.fromJson(json.decode(str));

String usermodelToJson(HistoricReportExpenditure data) =>
    json.encode(data.toJson());

class HistoricReportExpenditure {
  HistoricReportExpenditure({
    required this.id,
    required this.userId,
    required this.label,
    required this.amount,
    required this.totalleft,
    required this.note,
    required this.seed_category,
    required this.created_at,
    required this.updated_at,
  });

  int id;
  int userId;
  String label;
  var amount;
  int totalleft;
  String note;
  String seed_category;
  String created_at;
  String updated_at;

  factory HistoricReportExpenditure.fromJson(Map<String, dynamic> json) {
    return HistoricReportExpenditure(
      id: json["id"] ?? 0,
      userId: json["user_id"] ?? 0,
      label: json["label"] ?? '',
      amount: json["amount"] ?? 0,
      totalleft: json["totalleft"] ?? 0,
      note: json["note"] ?? '',
      seed_category: json["seed_category"] ?? '',
      created_at: json["created_at"] ?? '',
      updated_at: json["updated_at"] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['label'] = label;
    data['amount'] = amount;
    data['totalleft'] = totalleft;
    data['note'] = note;
    data['seed_category'] = seed_category;
    data['created_at'] = created_at;
    data['updated_at'] = updated_at;
    return data;
  }
}
