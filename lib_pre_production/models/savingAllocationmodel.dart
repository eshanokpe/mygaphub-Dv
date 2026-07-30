
import 'dart:convert';

class SavingAllocationmodel {
  int amount;
  String note;
  String label;
  String userid;
  String id;

  SavingAllocationmodel({
    required this.amount,
    required this.id,
    required this.label,
    required this.userid,
    required this.note,
  });
}

Savall usermodelFromJson(String str) => Savall.fromJson(json.decode(str));
String usermodelToJson(Savall data) => json.encode(data.toJson());

class Savall {
  Savall(
      {
      required this.id,
      required this.user_id,
      required this.name,
      required this.amount,
      required this.date,
      required this.note,
      required this.alert,
      required this.created_at,
      required this.updated_at});
  int id;
  String user_id;
  String name;
  String amount;
  String date;
  String note;
  String alert;
  String created_at;
  String updated_at;

  factory Savall.fromJson(Map<String, dynamic> json) => Savall(
      id: json['id'],
      user_id: json["user_id"],
      name: json["name"],
      amount: json['amount'],
      date: json['date'],
      note: json["note"],
      alert: json["alert"],
      created_at: json["created_at"],
      updated_at: json['updated_at']);

  Map<String, dynamic> toJson() => {
        'id': id,
        "user_id": user_id,
        "name": name,
        'amount': amount,
        'date': date,
        "note": note,
        "alert": alert,
        "created_at": created_at,
        'updated_at': updated_at
      };
}
