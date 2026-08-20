// lib/models/investment_categories.dart

class InvestmentCategoryOption {
  final String id;
  final String title;
  final String imageAsset;

  const InvestmentCategoryOption({
    required this.id,
    required this.title,
    required this.imageAsset,
  });
}

class InvestmentChecklistField {
  final String subCategory;
  final String label;
  final String hint;

  const InvestmentChecklistField({
    required this.subCategory,
    required this.label,
    required this.hint,
  });
}

/// The four top-level categories shown on StepTwo's selection screen.
const List<InvestmentCategoryOption> investmentCategoryOptions = [
  InvestmentCategoryOption(
    id: "retirement",
    title: "Retirement",
    imageAsset: 'assets/wheel_segments/retirement_icon.png',
  ),
  InvestmentCategoryOption(
    id: "investment",
    title: "Investment",
    imageAsset: 'assets/wheel_segments/investment_icon.png',
  ),
  InvestmentCategoryOption(
    id: "cash",
    title: "Cash",
    imageAsset: 'assets/wheel_segments/income_icon.png',
  ),
  InvestmentCategoryOption(
    id: "equity",
    title: "Equity",
    imageAsset: 'assets/wheel_segments/house.png',
  ),
];

/// Per-category checklist fields, keyed by category id.
/// Order matters — it drives both StepTwo's form field order and StepFive's summary order.
final Map<String, List<InvestmentChecklistField>> investmentCategoryChecklists =
    {
      "retirement": [
        const InvestmentChecklistField(
          subCategory: "private_pension",
          label: "Private Pension",
          hint:
              "E.g. Research Vanguard and Fidelity private pension providers.",
        ),
        const InvestmentChecklistField(
          subCategory: "company_pension",
          label: "Company Pension",
          hint: "E.g. Speak to HR about maximising employer match.",
        ),
        const InvestmentChecklistField(
          subCategory: "state_pension",
          label: "State Pension",
          hint: "E.g. Review NI contribution record on HMRC portal.",
        ),
        const InvestmentChecklistField(
          subCategory: "other_pensions",
          label: "Other Pensions",
          hint: "E.g. Trace old workplace pensions.",
        ),
      ],
      "cash": [
        const InvestmentChecklistField(
          subCategory: "isa",
          label: "ISA",
          hint: "E.g. Open a Stocks and Shares ISA.",
        ),
        const InvestmentChecklistField(
          subCategory: "fixed_income",
          label: "Fixed Income",
          hint: "E.g. Compare fixed-rate bonds.",
        ),
        const InvestmentChecklistField(
          subCategory: "easy_asset",
          label: "Easy Access Asset",
          hint: "E.g. Move emergency fund to high-interest account.",
        ),
      ],
      "investment": [
        const InvestmentChecklistField(
          subCategory: "business_asset",
          label: "Business Asset",
          hint: "E.g. Explore buying equity in a business.",
        ),
        const InvestmentChecklistField(
          subCategory: "appreciating_asset",
          label: "Appreciating Asset",
          hint: "E.g. Research buy-to-let property.",
        ),
        const InvestmentChecklistField(
          subCategory: "risk_asset",
          label: "Risk Asset",
          hint: "E.g. Allocate portfolio to high-growth ETFs.",
        ),
      ],
      "equity": [
        const InvestmentChecklistField(
          subCategory: "wholly_owned_home",
          label: "Wholly Owned Home",
          hint: "E.g. Get a home valuation and explore remortgaging.",
        ),
        const InvestmentChecklistField(
          subCategory: "jointly_owned_home",
          label: "Jointly Owned Home",
          hint: "E.g. Review co-ownership agreement.",
        ),
      ],
    };

/// Looks up a category's display title by id.
String investmentCategoryTitle(String? categoryId) {
  if (categoryId == null || categoryId.isEmpty) return '';
  final match = investmentCategoryOptions.firstWhere(
    (o) => o.id == categoryId,
    orElse: () => InvestmentCategoryOption(
      id: categoryId,
      title: categoryId.isEmpty
          ? categoryId
          : '${categoryId[0].toUpperCase()}${categoryId.substring(1)}',
      imageAsset: '',
    ),
  );
  return match.title;
}
