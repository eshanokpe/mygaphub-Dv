import 'dart:convert';

HistoricSeedReport usermodelFromJson(String str) =>
    HistoricSeedReport.fromJson(json.decode(str));
String usermodelToJson(HistoricSeedReport data) => json.encode(data.toJson());

class HistoricSeedReport {
  HistoricSeedReport({
    required this.id,
    required this.userId,
    required this.label,
    required this.amount,
    required this.actual,
    required this.note,
    required this.seed_category,
    required this.created_at,
    required this.updated_at,
  });

  int id;
  int userId;
  String label;
  var amount;
  var actual;
  String note;
  String seed_category;
  String created_at;
  String updated_at;

  HistoricSeedReport.fromJson(Map<String, dynamic> json)
    : userId = int.tryParse(json["user_id"].toString()) ?? 0,
      label = json["label"],
      created_at = json['created_at'],
      id = json["id"],
      seed_category = json["seed_category"],
      amount = json["amount"],
      actual = json['actual'],
      note = json["note"] ?? "",
      updated_at = json["updated_at"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['id'] = id;
    data['seed_category'] = seed_category;
    data['note'] = note;
    data['amount'] = amount;
    data['actual'] = actual;
    data['updated_at'] = updated_at;
    return data;
  }
}
