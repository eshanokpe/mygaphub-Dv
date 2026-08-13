import 'dart:convert';

ExpenReport usermodelFromJson(String str) =>
    ExpenReport.fromJson(json.decode(str));
String usermodelToJson(ExpenReport data) => json.encode(data.toJson());

class ExpenReport {
  ExpenReport({
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
  var totalleft;
  String note;
  String seed_category;
  String created_at;
  String updated_at;

  ExpenReport.fromJson(Map<String, dynamic> json)
    : userId = json["user_id"],
      label = json["label"],
      created_at = json['created_at'],
      id = json["id"],
      seed_category = json["seed_category"],
      amount = json["amount"],
      // totalleft = json['summary']['total_left'] ?? '0',
      note = json["note"],
      updated_at = json["updated_at"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['id'] = id;
    data['seed_category'] = seed_category;
    data['note'] = note;
    data['amount'] = amount;
    data['summary']['total_left'] = totalleft ?? '0';
    data['updated_at'] = updated_at;
    return data;
  }
}

class Rem {
  Map<String, dynamic> reminders;
  Rem({required this.reminders});
  factory Rem.fromJson(Map<String, dynamic> json) =>
      Rem(reminders: json['reminders']);

  Map<String, dynamic> toJson() => {'reminders': reminders};
}
