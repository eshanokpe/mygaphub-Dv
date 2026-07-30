// To parse this JSON data, do
//
//     final usermodel = usermodelFromJson(jsonString);

import 'dart:convert';

Usermodel usermodelFromJson(String str) => Usermodel.fromJson(json.decode(str));

String usermodelToJson(Usermodel data) => json.encode(data.toJson());

class Usermodel {
  Usermodel(
      {required this.email,
      required this.firstname,
      required this.surname,
      required this.password,
      required this.password_confirmation});

  String email;
  String firstname;
  String surname;
  String password;
  String password_confirmation;

  factory Usermodel.fromJson(Map<String, dynamic> json) => Usermodel(
        email: json["email"],
        firstname: json["firstname"],
        surname: json["surname"],
        password: json["password"],
        password_confirmation: json["password_confirmation"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "firstname": firstname,
        "surname": surname,
        "password": password,
        "password_confirmation": password_confirmation,
      };
}
