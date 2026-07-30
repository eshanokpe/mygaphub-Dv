import 'dart:convert';

Ganpcountries ganpcountriesFromJson(String str) =>
    Ganpcountries.fromJson(json.decode(str));
String ganpcountriesToJson(Ganpcountries data) => json.encode(data.toJson());

Ganpcountriesasset ganpcountriesassetFromJson(String str) =>
    Ganpcountriesasset.fromJson(json.decode(str));
String ganpcountriesassetToJson(Ganpcountriesasset data) =>
    json.encode(data.toJson());

class Ganpcountries {
  List<dynamic> countries;
  Ganpcountries({required this.countries});
  factory Ganpcountries.fromJson(Map<String, dynamic> json) =>
      Ganpcountries(countries: json['countries']);
  Map<String, dynamic> toJson() => {
        'countries': countries,
      };
}

class Ganpcountriesasset {
  Map<String, dynamic> cultivations;
  Ganpcountriesasset({required this.cultivations});
  factory Ganpcountriesasset.fromJson(Map<String, dynamic> json) =>
      Ganpcountriesasset(cultivations: json['cultivations']);
  Map<String, dynamic> toJson() => {
        'cultivations': cultivations,
      };
}
