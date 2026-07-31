import 'dart:convert';

Reapserver reapserverReapserverFromJson(String str) =>
    Reapserver.fromJson(json.decode(str));
String reapserverReapserverToJson(Reapserver data) =>
    json.encode(data.toJson());

class Reapserver {
  int? total;
  Map<String, dynamic>? result;
  Reapserver({ this.result,  this.total});
  factory Reapserver.fromJson(Map<String, dynamic> json) =>
      Reapserver(result: json['result'], total: json['total']);

  Map<String, dynamic> toJson() => {'result': result, 'total': total};
}
 