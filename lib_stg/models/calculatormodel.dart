class Calculatormodel {
  String? currency;
  String? periodic;
  String? education;
  String? mortgage;
  String? mobility;
  String? expenses;
  String? utility;
  String? debtRepay;
  String? charity;
  String? otherIncome;
  String? extraSave;
  String? roce;
  String? investment;

  Calculatormodel(
      {this.currency,
      this.periodic,
      this.education,
      this.mortgage,
      this.mobility,
      this.expenses,
      this.utility,
      this.debtRepay,
      this.charity,
      this.otherIncome,
      this.extraSave,
      this.roce,
      this.investment});

  Map<String, dynamic> toJson() => {
        'currency': currency,
        "periodic": periodic,
        "education": education,
        'mortgage': mortgage,
        'mobility': mobility,
        'expenses': expenses,
        'utility': utility,
        'debtRepay': debtRepay,
        'charity': charity,
        'otherIncome': otherIncome,
        'extraSave': extraSave,
        'roce': roce,
        'investment': investment,
      };
}
