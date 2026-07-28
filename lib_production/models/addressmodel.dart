import 'dart:convert';

Addressmodel addressmodelFromJson(String str) =>
    Addressmodel.fromJSON(json.decode(str));
String addressmodelToJson(Addressmodel data) => json.encode(data.toJson());

class Addressmodel {
  String id;
  String type;
  String text;
  String highlight;
  String description;

  Addressmodel(
      {required this.id, required this.type, required this.text, 
      required this.highlight, 
      required this.description});

  factory Addressmodel.fromJSON(Map<String, dynamic> parsedJSON) {
    return Addressmodel(
      id: parsedJSON["Id"],
      type: parsedJSON["Type"],
      text: parsedJSON["Text"],
      highlight: parsedJSON["Highlight"],
      description: parsedJSON["Description"],
    );
  }
  Map<String, dynamic> toJson() =>
      {'Id': id, "Type": type, "Text": text, "Dexcription": description};
}
