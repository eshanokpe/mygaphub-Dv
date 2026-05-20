import 'dart:convert';

Actionplanserver usermodelFromJson(String str) =>
    Actionplanserver.fromJson(json.decode(str));
String usermodelToJson(Actionplanserver data) => json.encode(data.toJson());

Todayplanserver todaymodelFromJson(String str) =>
    Todayplanserver.fromJson(json.decode(str));
String todayodelToJson(Todayplanserver data) => json.encode(data.toJson());

class Actionplanserver {
  Actionplanserver({
    required this.business,
    required this.risk,
    required this.intellectual,
    required this.appreciating,
    required this.depreciating,
  });
  List<dynamic> business;
  List<dynamic> risk;
  List<dynamic> intellectual;
  List<dynamic> appreciating;
  List<dynamic> depreciating;

  factory Actionplanserver.fromJson(Map<String, dynamic> json) =>
      Actionplanserver(
        business: json['business'],
        risk: json["risk"],
        intellectual: json["intellectual"],
        appreciating: json['appreciating'],
        depreciating: json['depreciating'],
      );

  Map<String, dynamic> toJson() => {
        'business': business,
        "risk": risk,
        "intellectual": intellectual,
        'appreciating': appreciating,
        'depreciating': depreciating,
      };
}

class Todayplanserver {
  Todayplanserver({
    required this.business,
    required this.risk,
    required this.intellectual,
    required this.appreciating,
    required this.depreciating,
  });

  Map<String, dynamic> business;
  Map<String, dynamic> risk;
  Map<String, dynamic> intellectual;
  Map<String, dynamic> appreciating;
  Map<String, dynamic> depreciating;

  factory Todayplanserver.fromJson(Map<String, dynamic> json) => Todayplanserver(
        business: json['business'] ?? {},  // Provide a default empty map
        risk: json["risk"] ?? {},
        intellectual: json["intellectual"] ?? {},
        appreciating: json['appreciating'] ?? {},
        depreciating: json['depreciating'] ?? {},
      );

  Map<String, dynamic> toJson() => {
        'business': business,
        "risk": risk,
        "intellectual": intellectual,
        'appreciating': appreciating,
        'depreciating': depreciating,
      };
}
