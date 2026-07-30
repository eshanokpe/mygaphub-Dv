import 'dart:convert';

SavingAllserver usermodelFromJson(String str) =>
    SavingAllserver.fromJson(json.decode(str));

String usermodelToJson(SavingAllserver data) => json.encode(data.toJson());

class SavingAllserver {
  SavingAllserver({
    required this.id,
    required this.userId,
    required this.label,
    required this.amount,
    required this.totalLeft,
    required this.note,
    required this.seedCategory,
    required this.createdAt,
    required this.updatedAt,
    required this.summary,
  });

  int id;
  int userId;
  String label;
  num amount;
  int totalLeft;
  String note;
  String seedCategory;
  String createdAt;
  String updatedAt;
  Summary summary;

  factory SavingAllserver.fromJson(Map<String, dynamic> json) {
    return SavingAllserver(
      id: json["id"] ?? 0,
      userId: int.tryParse(json["user_id"].toString()) ?? 0,
      label: json["label"] ?? '',
      amount: int.tryParse(json["amount"].toString()) ?? 0,
      totalLeft:
          (json["summary"] != null && json["summary"]["total_left"] != null)
              ? int.tryParse(json["summary"]["total_left"].toString()) ?? 0
              : 0,
      note: json["note"] ?? '',
      seedCategory: json["seed_category"] ?? '',
      createdAt: json["created_at"] ?? '',
      updatedAt: json["updated_at"] ?? '',
      summary: Summary.fromJson(json["summary"] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "label": label,
        "amount": amount,
        "total_left": totalLeft,
        "note": note,
        "seed_category": seedCategory,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "summary": summary.toJson(),
      };
}

class Summary {
  Summary({
    required this.totalSpent,
    required this.totalLeft,
    required this.spentPercentage,
    required this.leftPercentage,
  });

  int totalSpent;
  int totalLeft;
  int spentPercentage;
  int leftPercentage;

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalSpent: json["total_spent"] ?? 0,
      totalLeft: json["total_left"] ?? 0,
      spentPercentage: json["spent_percentage"] ?? 0,
      leftPercentage: json["left_percentage"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "total_spent": totalSpent,
        "total_left": totalLeft,
        "spent_percentage": spentPercentage,
        "left_percentage": leftPercentage,
      };
}
