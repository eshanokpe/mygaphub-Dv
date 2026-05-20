class IncomeChartModel {
  final List<dynamic>? periods;
  final List<dynamic>? nonPortfolioValues;
  final List<dynamic>? portfolioValues;
  final bool? hasImprove;

  IncomeChartModel(
      {this.periods,
      this.nonPortfolioValues,
      this.portfolioValues,
      this.hasImprove});

  factory IncomeChartModel.fromJson(Map<String, dynamic> json) {
    return IncomeChartModel(
        periods: json["periods"],
        nonPortfolioValues: json["non_portfolio_values"],
        portfolioValues: json["portfolio_values"],
        hasImprove: json["hasImprove"]);
  }
}
