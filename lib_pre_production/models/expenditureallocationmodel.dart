import 'dart:convert';

ExpenditureAllocationModel usermodelFromJson(String str) =>
    ExpenditureAllocationModel.fromJson(json.decode(str));
String usermodelToJson(ExpenditureAllocationModel data) =>
    json.encode(data.toJson());

class ExpenditureAllocationModel {
  ExpenditureAllocationModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.amount,
    required this.expenditure,
    required this.note,
    required this.seed_category,
    required this.created_at,
    required this.updated_at,
  });

  int id;
  int userId;
  String label;
  int amount;
  String note;
  String expenditure;
  String seed_category;
  String created_at;
  String updated_at;

  ExpenditureAllocationModel.fromJson(Map<String, dynamic> json)
    : userId = json["user_id"],
      label = json["label"],
      expenditure = json["expenditure"],
      created_at = json['created_at'],
      id = json["id"],
      seed_category = json["seed_category"],
      amount = json["amount"],
      note = json["note"],
      updated_at = json["updated_at"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['id'] = id;
    data['expenditure'] = expenditure;
    data['seed_category'] = seed_category;
    data['note'] = note;
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
