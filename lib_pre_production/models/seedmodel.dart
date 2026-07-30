class Seedmodel {
  Map<String, dynamic> dataseed;
  Seedmodel({required this.dataseed});
  factory Seedmodel.fromJson(Map<String, dynamic> json) => Seedmodel(
        dataseed: json['data'],
      );

  Map<String, dynamic> toJson() => {
        'data': dataseed,
      };
}
