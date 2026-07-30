import 'dart:convert';

SavingAllexpenditure usermodelFromJson(String str) =>
    SavingAllexpenditure.fromJson(json.decode(str));
String usermodelToJson(SavingAllexpenditure data) => json.encode(data.toJson());

class SavingAllexpenditure {
  SavingAllexpenditure({
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
  int amount;
  int totalleft;
  String note;
  String seed_category;
  String created_at;
  String updated_at;

  SavingAllexpenditure.fromJson(Map<String, dynamic> json)
    : id = int.tryParse(json["id"].toString()) ?? 0,
      userId = int.tryParse(json["user_id"].toString()) ?? 0,
      label = json["label"] ?? '',
      amount = int.tryParse(json["amount"].toString()) ?? 0,
      totalleft = int.tryParse(json["totalleft"].toString()) ?? 0,
      note = json["note"] ?? '',
      seed_category = json["seed_category"] ?? '',
      created_at = json['created_at'] ?? '',
      updated_at = json["updated_at"] ?? '';

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['id'] = id;
    data['seed_category'] = seed_category;
    data['note'] = note;
    data['total_left'] = totalleft;
    data['amount'] = amount;
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
