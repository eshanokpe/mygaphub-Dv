import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:provider/provider.dart';
import '../controller/investment_form_controller.dart';
import 'investment_form_screen.dart';
import 'widgets/investment_categories.dart';

/// Read-only "view" screen for a single saved investment strategy.
///
/// Mirrors the data-retrieval and formatting logic used by StepFive's
/// `_buildSummaryScreen` (same `_noteAt` / `_newGoalAmount` /
/// `_allocationSummary` / money-formatting helpers), but reads from the
/// persisted `strategy` map returned by the API instead of the live
/// `InvestmentFormState`.
class InvestmentViewScreen extends ConsumerWidget {
  final Map<String, dynamic> strategy;

  const InvestmentViewScreen(this.strategy, {super.key});

  // Step indices matching InvestmentFormController.canProceed()'s switch:
  // 0 = name/reason, 1 = category+checklist, 2 = savings goal,
  // 3 = investigation, 4 = allocation.
  static const int _stepWhy = 0;
  static const int _stepWhere = 1;
  static const int _stepWhat = 2;
  static const int _stepWhen = 3;
  static const int _stepHow = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = _stringOf(strategy['currency'], fallback: '£');
    final providers = context.watch<Providers>();
    final dashboardData = providers.dashdata;
    final analyticsData = providers.analyticsinfo;

    // ✅ Same source items list StepFive filters per-category from
    // (state.step2Items there; the persisted `items` array here).
    final items = _itemsList();

    // ✅ Asset Growth Funds: eligible to be sent as a normal item by
    // submitAllItems (no sub_category exclusion for it), so check items
    // first, same way _step2NoteFor searches by sub_category. Falls back
    // to a top-level field in case your API returns it separately.
    final assetGrowthFunds = _stringOf(dashboardData["income"]["saving"]);

    // ✅ Alpha Balance: submitAllItems explicitly EXCLUDES sub_category
    // 'alpha_balance' from what gets persisted as an item, so it can only
    // come from a top-level field on the strategy record (if your API
    // returns one) — it will never be found inside `items`.
    final alphaBalance = _stringOf(analyticsData.alpha["current"]);

    // ✅ New Monthly Savings Goal / obtain plan: persisted as dedicated
    // top-level fields via the /savings-goal endpoint
    // (_applyStrategyData reads new_monthly_savings + obtain_plan the
    // same way), not embedded in `items`.
    final newMonthlySavingsGoal = _stringOf(strategy['new_monthly_savings']);
    final obtainPlan = _stringOf(strategy['obtain_plan']);

    // ✅ Investigation answers: persisted as dedicated top-level fields
    // via the /investigation endpoint (opportunity_age,
    // investors_last_5yr, team_experience, customer_value) — same keys
    // _getStep4NoteBySubCat's payload uses in the controller.
    final opportunityAge = _stringOf(
      strategy['investigation']['opportunity_age'],
    );
    final investorsLast5yr = _stringOf(
      strategy['investigation']['investors_last_5yr'],
    );
    final teamExperience = _stringOf(
      strategy['investigation']['team_experience'],
    );
    final customerValue = _stringOf(
      strategy['investigation']['customer_value'],
    );

    // ✅ Allocation: only percentages are persisted (monthly_percent,
    // lumpsum_percent, asset_percentage) — the £ amounts shown on
    // StepFive's Summary screen are always computed client-side from
    // baseBalance * percent / 100, never stored. Reproduce that here
    // with the same _allocationSummary/_allocationSummaryPercent helpers.
    final assetPercentage = _stringOf(strategy['asset_percentage']);
    final monthlyPercent = strategy['monthly_percent'];
    final lumpsumPercent = strategy['lumpsum_percent'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios, size: 20.sp, color: Colors.black),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 17.w),
            child: GestureDetector(
              onTap: () => _goToStep(context, ref, _stepWhy),
              child: Image.asset(
                'assets/wheel_segments/pencil-alt.png',
                height: 20.h,
                width: 20.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: 16.h, bottom: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                SizedBox(height: 24.h),

                // ---------------- WHY? ----------------
                _buildSectionHeader(
                  'WHY?',
                  onEdit: () => _goToStep(context, ref, _stepWhy),
                ),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Investment Name'),
                      SizedBox(height: 4.h),
                      _buildTextValue(_stringOf(strategy['name'])),
                      SizedBox(height: 16.h),
                      _buildLabel('Reason for Investing'),
                      SizedBox(height: 4.h),
                      _buildTextValue(_stringOf(strategy['reason'])),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // ---------------- WHERE? ----------------
                _buildSectionHeader(
                  'WHERE?',
                  onEdit: () => _goToStep(context, ref, _stepWhere),
                ),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Category'),
                      SizedBox(height: 4.h),
                      _buildTextValue(
                        investmentCategoryTitle(
                          _stringOf(strategy['category']),
                        ),
                      ),
                      ..._buildCategoryFieldRows(items),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // ---------------- WHAT? ----------------
                _buildSectionHeader(
                  'WHAT?',
                  onEdit: () => _goToStep(context, ref, _stepWhat),
                ),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Asset Growth Funds'),
                      SizedBox(height: 4.h),
                      _buildMoneyValue(assetGrowthFunds, currency),
                      SizedBox(height: 16.h),
                      _buildLabel('Alpha Balance'),
                      SizedBox(height: 4.h),
                      _buildMoneyValue(alphaBalance, currency),
                      SizedBox(height: 16.h),
                      _buildLabel('New Monthly Savings Goal'),
                      SizedBox(height: 4.h),
                      _buildMoneyValue(newMonthlySavingsGoal, currency),
                      SizedBox(height: 16.h),
                      _buildLabel(
                        'How do you intend to obtain this additional '
                        'amount to add to your monthly savings?',
                      ),
                      SizedBox(height: 4.h),
                      _buildTextValue(obtainPlan),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // ---------------- WHEN? ----------------
                _buildSectionHeader(
                  'WHEN?',
                  onEdit: () => _goToStep(context, ref, _stepWhen),
                ),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('How old is this opportunity?'),
                      SizedBox(height: 4.h),
                      _buildTextValue(opportunityAge),
                      SizedBox(height: 16.h),
                      _buildLabel(
                        'How many people have successfully invested in the '
                        'last 5 years?',
                      ),
                      SizedBox(height: 4.h),
                      _buildTextValue(investorsLast5yr),
                      SizedBox(height: 16.h),
                      _buildLabel(
                        'How experienced are the team behind the '
                        'opportunity?',
                      ),
                      SizedBox(height: 4.h),
                      _buildTextValue(teamExperience),
                      SizedBox(height: 16.h),
                      _buildLabel(
                        'What customer value do they create and who are '
                        'their customers?',
                      ),
                      SizedBox(height: 4.h),
                      _buildTextValue(customerValue),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // ---------------- HOW? ----------------
                _buildSectionHeader(
                  'HOW?',
                  onEdit: () => _goToStep(context, ref, _stepHow),
                ),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(
                        'What percentage of your total asset should be '
                        'invested into this asset category/class or '
                        'opportunity?',
                      ),
                      SizedBox(height: 4.h),
                      _buildPercentValue(assetPercentage),
                      SizedBox(height: 16.h),
                      _buildLabel('Monthly Asset Growth Savings'),
                      SizedBox(height: 4.h),
                      _buildMoneyValue(assetGrowthFunds, currency),
                      SizedBox(height: 16.h),
                      _buildLabel('Alpha Balance'),
                      SizedBox(height: 4.h),
                      _buildMoneyValue(alphaBalance, currency),
                      SizedBox(height: 16.h),
                      _buildLabel(
                        'How much would you allocate to this opportunity '
                        'monthly?',
                      ),
                      SizedBox(height: 4.h),
                      // ✅ Same computation StepFive does — % is stored,
                      // £ amount is always derived from baseBalance.
                      _buildMoneyValueWithPercent(
                        _allocationSummary(assetGrowthFunds, monthlyPercent),
                        _allocationSummaryPercent(monthlyPercent),
                        currency,
                      ),
                      SizedBox(height: 16.h),
                      _buildLabel(
                        'How much would you allocate to this opportunity '
                        'as a lumpsum?',
                      ),
                      SizedBox(height: 4.h),
                      _buildMoneyValueWithPercent(
                        _allocationSummary(alphaBalance, lumpsumPercent),
                        _allocationSummaryPercent(lumpsumPercent),
                        currency,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Edit navigation ----------------
  // ✅ Loads this strategy's data into the live form state, jumps the
  // controller to the matching step, then opens the form screen — same
  // mechanism the pencil icon already uses (InvestmentFormScreen takes
  // strategyId and is responsible for calling fetchStrategyData/
  // loadFromStrategySummary on init). goToStep() already exists on the
  // controller for exactly this purpose.
  void _goToStep(BuildContext context, WidgetRef ref, int step) {
    final controller = ref.read(investmentFormControllerProvider.notifier);
    controller.loadFromStrategySummary(strategy);
    controller.goToStep(step);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            InvestmentFormScreen(strategyId: strategy['id']?.toString()),
      ),
    );
  }

  // ---------------- Header card: icon, date, title, category ----------------
  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/action_plan/target22.png',
                height: 44.h,
                width: 44.w,
                fit: BoxFit.cover,
              ),
              Text(
                _formatDate(strategy['created_at']),
                style: GoogleFonts.nunitoSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grayColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            _stringOf(strategy['name'], fallback: 'Unnamed Strategy'),
            style: GoogleFonts.nunitoSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            _capitalize(
              investmentCategoryTitle(_stringOf(strategy['category'])),
            ),
            style: GoogleFonts.nunitoSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.grayColor,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Section header with Edit link ----------------
  Widget _buildSectionHeader(String title, {required VoidCallback onEdit}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.nunitoSans(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grayColor,
            letterSpacing: 0.5,
          ),
        ),
        GestureDetector(
          onTap: onEdit,
          child: Row(
            children: [
              Text(
                'Edit',
                style: GoogleFonts.nunitoSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blackColor,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.chevron_right,
                size: 16.sp,
                color: AppColors.primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- Items list + lookups (mirrors _step2NoteFor) ----------------
  List<Map<String, String>> _itemsList() {
    return (strategy['items'] as List?)
            ?.whereType<Map>()
            .map<Map<String, String>>(
              (it) => {
                'sub_category': (it['sub_category'] ?? '').toString(),
                'note': (it['note'] ?? '').toString(),
              },
            )
            .toList() ??
        [];
  }

  String _noteFor(List<Map<String, String>> items, String subCategory) {
    for (final item in items) {
      if (item['sub_category'] == subCategory) return item['note'] ?? '';
    }
    return '';
  }

  List<Widget> _buildCategoryFieldRows(List<Map<String, String>> items) {
    final categoryId = _stringOf(strategy['category']);
    if (categoryId.isEmpty) return [];

    final fields = investmentCategoryChecklists[categoryId];
    if (fields == null) return [];

    final rows = <Widget>[];
    for (final field in fields) {
      rows.add(SizedBox(height: 16.h));
      rows.add(_buildLabel(field.label));
      rows.add(SizedBox(height: 4.h));
      rows.add(_buildTextValue(_noteFor(items, field.subCategory)));
    }
    return rows;
  }

  // ---------------- Ported verbatim from StepFive._buildSummaryScreen ----------------
  String _allocationSummary(String baseBalance, dynamic percent) {
    final parsedPercent = percent is int
        ? percent
        : int.tryParse(percent?.toString() ?? '');
    if (parsedPercent == null) return '0';
    final amount = _parseAmount(baseBalance) * parsedPercent / 100;
    return _formatAmount(amount);
  }

  String _allocationSummaryPercent(dynamic percent) {
    final parsedPercent = percent is int
        ? percent
        : int.tryParse(percent?.toString() ?? '');
    if (parsedPercent == null) return 'Not selected';
    return '$parsedPercent%';
  }

  double _parseAmount(String amount) {
    return double.tryParse(amount.replaceAll(',', '')) ?? 0.0;
  }

  String _formatAmount(double value) {
    final wholePart = value.truncate();
    final decimalPart = ((value - wholePart) * 100).round().abs();
    final wholeStr = wholePart.abs().toString();

    final buffer = StringBuffer();
    for (int i = 0; i < wholeStr.length; i++) {
      if (i != 0 && (wholeStr.length - i) % 3 == 0) buffer.write(',');
      buffer.write(wholeStr[i]);
    }

    final sign = value < 0 ? '-' : '';
    return '$sign${buffer.toString()}.${decimalPart.toString().padLeft(2, '0')}';
  }

  // ---------------- Value builders (mirrors StepFive summary styling) ----------------
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.nunitoSans(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.grayColor,
      ),
    );
  }

  Widget _buildTextValue(String text) {
    return Text(
      _capitalize(text),
      style: GoogleFonts.nunitoSans(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.blackColor,
        height: 1.35,
      ),
    );
  }

  Widget _buildPercentValue(String text) {
    final percent = text.trim().isEmpty ? '0' : text.trim();
    return Row(
      children: [
        Text(
          percent,
          style: GoogleFonts.nunitoSans(
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
            height: 1.35,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Text(
            '%',
            style: GoogleFonts.nunitoSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff888888),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoneyValue(String text, String currency) {
    final amount = num.tryParse(text.replaceAll(',', '')) ?? 0;
    final wholeNumber = amount.truncate();
    final decimalPart = (amount - wholeNumber)
        .toStringAsFixed(2)
        .split('.')
        .last;

    return Row(
      children: [
        Text(
          '$currency${NumberFormat("#,##0").format(wholeNumber)}',
          style: GoogleFonts.nunitoSans(
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
            height: 1.35,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Text(
            '.$decimalPart',
            style: GoogleFonts.nunitoSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff888888),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoneyValueWithPercent(
    String text,
    String percentLabel,
    String currency,
  ) {
    final amount = num.tryParse(text.replaceAll(',', '')) ?? 0;
    final wholeNumber = amount.truncate();
    final decimalPart = (amount - wholeNumber)
        .toStringAsFixed(2)
        .split('.')
        .last;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              '$currency${NumberFormat("#,##0").format(wholeNumber)}',
              style: GoogleFonts.nunitoSans(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
                height: 1.35,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                '.$decimalPart',
                style: GoogleFonts.nunitoSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff888888),
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
        Text(
          percentLabel,
          style: GoogleFonts.nunitoSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xffBBBBBB),
            height: 1.35,
          ),
        ),
      ],
    );
  }

  // ---------------- Small helpers ----------------
  String _stringOf(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString();
    return text.trim().isEmpty ? fallback : text;
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  String _formatDate(dynamic rawDate) {
    if (rawDate == null) return '';
    final date = DateTime.tryParse(rawDate.toString());
    if (date == null) return rawDate.toString();
    return DateFormat('dd MMM yyyy').format(date);
  }
}
