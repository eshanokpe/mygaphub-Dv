class IncomeChannelsValues {
  final  primary;
  final  hustle;
  final  business;
  final  risk;
  final  appreciating;
  final  intellectual;
  final  depreciating;
  IncomeChannelsValues(
      {this.primary,
      this.hustle,
      this.business,
      this.risk,
      this.appreciating,
      this.intellectual,
      this.depreciating});

  factory IncomeChannelsValues.fromJson(Map<String, dynamic> json) {
    return IncomeChannelsValues(
      primary: json["primary"],
      hustle: json["hustle"],
      business: json["business"],
      risk: json["risk"],
      appreciating: json["appreciating"],
      intellectual: json["intellectual"],
      depreciating: json["depreciating"]
    );
  }
}


class IncomeChannelsPercent{ 
  final  primary;
  final  hustle;
  final  business;
  final  risk;
  final  appreciating;
  final  intellectual;
  final  depreciating;
  IncomeChannelsPercent(
      {this.primary,
      this.hustle,
      this.business,
      this.risk,
      this.appreciating,
      this.intellectual,
      this.depreciating});

  factory IncomeChannelsPercent.fromJson(Map<String, dynamic> json) {
    return IncomeChannelsPercent(
      primary: json["primary"],
      hustle: json["hustle"],
      business: json["business"],
      risk: json["risk"],
      appreciating: json["appreciating"],
      intellectual: json["intellectual"],
      depreciating: json["depreciating"]
    );
  }
}
