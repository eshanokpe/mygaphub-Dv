

// ignore_for_file: prefer_typing_uninitialized_variables

class AssetAcquisition {
  AssetAcquisition({
    this.id,
    this.name,
    this.fullname, 
    this.photo, 
    this.description, 
  }); 
  final id; 
  final name;
  final fullname;
  final photo;
  final description;

  factory AssetAcquisition.fromJson(Map<String, dynamic> json) {
    return AssetAcquisition(
      id: json["id"],
      name: json["name"],
      fullname: json["fullname"],
      photo: json["photo"],
      description: json["description"],
    );
  }

  Map toMap() {
    return {
      "id": id,
      "name": name,
      "fullname": fullname,
      "photo": photo,
      "description": description,
    };
  }
}
