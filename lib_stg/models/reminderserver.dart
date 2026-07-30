import 'dart:convert';

Rem remFromJson(String str) => Rem.fromJson(json.decode(str));
String remToJson(Rem data) => json.encode(data.toJson());

Reminderserver usermodelFromJson(String str) =>
    Reminderserver.fromJson(json.decode(str));
String usermodelToJson(Reminderserver data) => json.encode(data.toJson());

class Reminderserver {
  Reminderserver(
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

  factory Reminderserver.fromJson(Map<String, dynamic> json) => Reminderserver(
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

class Rem {
  Map<String, dynamic> reminders;
  Rem({required this.reminders});
  factory Rem.fromJson(Map<String, dynamic> json) => Rem(
        reminders: json['reminders'],
      );

  Map<String, dynamic> toJson() => {
        'reminders': reminders,
      };
}
