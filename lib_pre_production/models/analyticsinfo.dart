import 'dart:convert';

Analyticsinfo modelFromJson(String str) =>
    Analyticsinfo.fromJson(json.decode(str));
String modelToJson(Analyticsinfo data) => json.encode(data.toJson());

class Analyticsinfo {
  Analyticsinfo({
    this.alpha,
    this.beta,
    this.credit,
    this.dept,
    this.education,
    this.freedom,
    this.grand,
  });

  Map<String, dynamic>? alpha;
  Map<String, dynamic>? beta;
  Map<String, dynamic>? credit;
  Map<String, dynamic>? dept;
  Map<String, dynamic>? education;
  Map<String, dynamic>? freedom;
  Map<String, dynamic>? grand;

  factory Analyticsinfo.fromJson(Map<String, dynamic> json) {
    return Analyticsinfo(
      alpha: json['alpha'] as Map<String, dynamic>?,
      beta: json['beta'] as Map<String, dynamic>?,
      credit: json['credit'] as Map<String, dynamic>?,
      dept: json['dept'] as Map<String, dynamic>?,
      education: json['education'] as Map<String, dynamic>?,
      freedom: json['freedom'] as Map<String, dynamic>?,
      grand: json['grand'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'alpha': alpha,
    'beta': beta,
    'credit': credit,
    'dept': dept,
    'education': education,
    'freedom': freedom,
    'grand': grand,
  };
}
