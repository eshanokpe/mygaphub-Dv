// ignore_for_file: non_constant_identifier_names

class AssetType {
  int id;
  dynamic acqusition_id;
  String acqusition;
  String name;
  String description;
  String status;

  AssetType({
    required this.id,
    required this.acqusition_id,
    required this.acqusition,
    required this.name,
    required this.description,
    required this.status,
  });

  factory AssetType.fromJson(Map<String, dynamic> json) => AssetType(
        id: json["id"] ?? 0,  // Default to 0 if null
        acqusition_id: json["acqusition_id"] ?? "",  // Default to empty string
        acqusition: json["acqusition"] ?? "",  // Default to empty string
        name: json["name"] ?? "",  // Default to empty string
        description: json["description"] ?? "", // Default to empty string
        status: json["status"]?.toString() ?? "Unknown", // Convert to string, default "Unknown"
      );
}
