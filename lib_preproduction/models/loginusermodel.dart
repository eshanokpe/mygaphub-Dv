// To parse this JSON data, do
//
//     final usermodel = usermodelFromJson(jsonString);
import 'dart:convert';

Loginusermodel usermodelFromJson(String str) =>
    Loginusermodel.fromJson(json.decode(str));
String usermodelToJson(Loginusermodel data) => json.encode(data.toJson());

Regdetails regmodelFromJson(String str) =>
    Regdetails.fromJson(json.decode(str));
String regmodelToJson(Regdetails data) => json.encode(data.toJson());

Editdetails editmodelFromJson(String str) =>
    Editdetails.fromJson(json.decode(str));
String editmodelToJson(Editdetails data) => json.encode(data.toJson());

Error errorFromJson(String str) => Error.fromJson(json.decode(str));
String errorToJson(Error data) => json.encode(data.toJson());

class Loginusermodel {
  int? id;
  String? firstname;
  String? surname;
  String? email;
  String? phone;
  String? extra;
  String? emailVerifiedAt;
  String? createdAt;
  String? updatedAt;
  int? unseenNotifications;

  Loginusermodel({
    this.id,
    this.email,
    this.firstname,
    this.surname,
    this.phone,
    this.extra,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.unseenNotifications,
  });

  // ✅ CORRECT empty factory constructor
  factory Loginusermodel.empty() {
    return Loginusermodel(
      id: 0,
      firstname: '',
      surname: '',
      email: '',
      phone: '',
      extra: '',
      emailVerifiedAt: '',
      createdAt: '',
      updatedAt: '',
      unseenNotifications: 0,
    );
  }

  factory Loginusermodel.fromJson(Map<String, dynamic> json) => Loginusermodel(
        id: json['id'],
        firstname: json["firstname"],
        surname: json["surname"],
        email: json["email"],
        phone: json['phone'],
        extra: json['extra'],
        emailVerifiedAt: json["email_verified_at"],
        createdAt: json["created_at"],
        updatedAt: json['updated_at'],
        unseenNotifications: json['unseen_notifications'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        "firstname": firstname,
        "surname": surname,
        "email": email,
        'phone': phone,
        'extra': extra,
        "email_verified_at": emailVerifiedAt,
        "created_at": createdAt,
        'updated_at': updatedAt,
        'unseen_notifications': unseenNotifications,
      };
}
class Regdetails {
  Loginusermodel user;
  String token;
  Regdetails({required this.user, required this.token});
  factory Regdetails.fromJson(Map<String, dynamic> json) => Regdetails(
        user: json['user'],
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        'user': user,
        "token": token,
      };
}

class Editdetails {
  Map<String, dynamic> user;

  Editdetails({required this.user});

  // ✅ Empty factory constructor
  factory Editdetails.empty() {
    return Editdetails(
      user: {}, // Empty map instead of null
    );
  }

  factory Editdetails.fromJson(Map<String, dynamic> json) => Editdetails(
        user: json['user'] ?? {}, // Add null safety here too
      );

  Map<String, dynamic> toJson() => {
        'user': user,
      };
}

class Error {
  String error;
  Error({required this.error});
  factory Error.fromJson(Map<String, dynamic> json) => Error(
        error: json['error'],
      );

  Map<String, dynamic> toJson() => {
        'error': error,
      };
}
