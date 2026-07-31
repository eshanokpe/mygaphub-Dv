import 'dart:convert';

Analyticsinfo modelFromJson(String str) =>
    Analyticsinfo.fromJson(json.decode(str));
String modelToJson(Analyticsinfo data) => json.encode(data.toJson());

class Analyticsinfo {
  Analyticsinfo(
      {required this.alpha,
      required this.beta,
      required this.credit,
      required this.dept,
      required this.education, 
      required this.freedom,
      required this.grand});
  Map<String, dynamic> alpha;
  Map<String, dynamic> beta;
  Map<String, dynamic> credit;
  Map<String, dynamic> dept;
  Map<String, dynamic> education;
  Map<String, dynamic> freedom;
  Map<String, dynamic> grand;

  factory Analyticsinfo.fromJson(Map<String, dynamic> json) => Analyticsinfo(
        alpha: json['alpha'],
        beta: json["beta"],
        credit: json["credit"],
        dept: json['dept'],
        education: json['education'],
        freedom: json['freedom'],
        grand: json['grand'],
      );

  Map<String, dynamic> toJson() => {
        'alpha': alpha,
        "beta": beta,
        "credit": credit,
        'dept': dept,
        'education': education,
        'freedom': freedom,
        'grand': grand,
      };
}
