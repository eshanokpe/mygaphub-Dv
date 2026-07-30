// To parse this JSON data, do
//
//     final usermodel = usermodelFromJson(jsonString);

import 'dart:convert';
 
Snapshotmodel snapshotmodelFromJson(String str) =>
    Snapshotmodel.fromJson(json.decode(str));
String snapshotmodelToJson(Snapshotmodel data) => json.encode(data.toJson());

class Snapshotmodel {
  String currency;
  Map<String, dynamic> financial;
  Map<String, dynamic> snapshot;

  Snapshotmodel({
    required this.currency,
    required this.financial,
    required this.snapshot,
  });

  // ✅ Empty factory constructor
  factory Snapshotmodel.empty() {
    return Snapshotmodel(
      currency: '',
      financial: {},
      snapshot: {},
    );
  }

  factory Snapshotmodel.fromJson(Map<String, dynamic> json) {
    // Safely extract the data with null checks
    final data = json['data'] ?? {};
    
    return Snapshotmodel(
      currency: data['currency']?.toString() ?? '',
      financial: (data['financial'] is Map<String, dynamic>) 
          ? Map<String, dynamic>.from(data['financial']) 
          : {},
      snapshot: (data['snapshot'] is Map<String, dynamic>) 
          ? Map<String, dynamic>.from(data['snapshot']) 
          : {},
    );
  }

  Map<String, dynamic> toJson() => {
    'currency': currency,
    'financial': financial,
    'snapshot': snapshot,
  };
}