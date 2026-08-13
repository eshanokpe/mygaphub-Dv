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
          hint: "E.g. Research private pension provider, etc.",
        ),
        const InvestmentChecklistField(
          subCategory: "company_pension",
          label: "Company Pension",
          hint: "E.g. Speak to HR on how to maximise pension",
        ),
        const InvestmentChecklistField(
          subCategory: "state_pension",
          label: "State Pension",
          hint: "E.g. Review NI contribution with tax authorities...",
        ),
        const InvestmentChecklistField(
          subCategory: "other_pensions",
          label: "Other Pensions",
          hint: "Any other details",
        ),
      ],
      "cash": [
        const InvestmentChecklistField(
          subCategory: "isa",
          label: "Individual Savings Account (ISA)",
          hint: "E.g. Review ISA contribution limits and set up...",
        ),
        const InvestmentChecklistField(
          subCategory: "fixed_income",
          label: "Fixed Income Account",
          hint: "E.g. Compare interest rates or fixed deposit terms",
        ),
        const InvestmentChecklistField(
          subCategory: "easy_asset",
          label: "Easy Asset Account",
          hint: "E.g. Review account flexibility and emergency...",
        ),
      ],
      "investment": [
        const InvestmentChecklistField(
          subCategory: "business_asset",
          label: "Business Asset",
          hint: "E.g. Explore business opportunities or equity...",
        ),
        const InvestmentChecklistField(
          subCategory: "appreciating_asset",
          label: "Appreciating Asset",
          hint: "E.g. Research property or collectible investments",
        ),
        const InvestmentChecklistField(
          subCategory: "risk_asset",
          label: "Risk Asset",
          hint: "E.g. Assess comfort with higher-risk investments...",
        ),
      ],
      "equity": [
        const InvestmentChecklistField(
          subCategory: "wholly_owned_home",
          label: "Wholly-Owned Home",
          hint: "E.g. Actions to increase home value or leverage...",
        ),
        const InvestmentChecklistField(
          subCategory: "jointly_owned_home",
          label: "Jointly-Owned Home",
          hint: "E.g. Review co-ownership structure or shared...",
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
