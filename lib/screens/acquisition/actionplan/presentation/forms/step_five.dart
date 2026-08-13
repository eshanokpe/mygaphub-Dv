import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/provider/AuthProvider.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../controller/investment_form_controller.dart';
import '../action_plan_strategy.dart';
import '../../provider/investment_form_state.dart';
import '../widgets/continue_strategising_popup.dart';
import '../widgets/investment_categories.dart';
import '../widgets/success_action_Modal.dart';

class StepFive extends ConsumerStatefulWidget {
  const StepFive({super.key});

  @override
  ConsumerState<StepFive> createState() => _StepFiveState();
}

class _StepFiveState extends ConsumerState<StepFive>
    with AutomaticKeepAliveClientMixin<StepFive> {
  late TextEditingController _percentageController;
  bool _hasAllocationPercentage = false;

  // hardcoded as placeholders for now per request.
  final String _monthlyAssetGrowthSavings = "2,200.00";
  final String _alphaBalance = "4,000.00";

  // ✅ NEW: the 4 selectable allocation chips shown on the Allocation
  // (second) screen for both the monthly and lumpsum cards.
  static const List<int> _allocationChoices = [10, 25, 50, 100];

  // Keep this State alive across parent rebuilds (e.g. PageView/IndexedStack
  // swaps) so _percentageController and its text aren't destroyed and
  // re-seeded from stale provider state on every keystroke.
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final state = ref.read(investmentFormControllerProvider);
    _percentageController = TextEditingController(
      text: state.allocationPercentage,
    );
    _hasAllocationPercentage =
        (int.tryParse(_percentageController.text) ?? 0) > 0;
    _percentageController.addListener(_updateAllocationVisibility);
  }

  @override
  void dispose() {
    _percentageController.removeListener(_updateAllocationVisibility);
    _percentageController.dispose();
    super.dispose();
  }

  void _updateAllocationVisibility() {
    final hasAllocationPercentage =
        (int.tryParse(_percentageController.text) ?? 0) > 0;

    if (hasAllocationPercentage != _hasAllocationPercentage) {
      setState(() => _hasAllocationPercentage = hasAllocationPercentage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final providers = context.watch<Providers>();
    final currency = providers.snapshotmodel.currency.trim().isNotEmpty
        ? providers.snapshotmodel.currency
        : providers.currencySymbol.trim().isNotEmpty
        ? providers.currencySymbol
        : providers.currency;
    super.build(context); // required by AutomaticKeepAliveClientMixin

    final state = ref.watch(investmentFormControllerProvider);
    final controller = ref.read(investmentFormControllerProvider.notifier);

    // ✅ NEW: read the live seed data directly (same source StepThree
    // uses) so the Summary screen always reflects the current fund
    // balances instead of whatever was last synced into
    // state.assetGrowthFunds/personalFund/emergencyFund — that stored
    // copy only updates while StepThree itself is on-screen, so it can
    // go stale if the balances change after the user has moved past
    // Step 3. Falls back to the stored copy if seed data isn't
    // available for some reason (e.g. it failed to load).
    final seedData = context.watch<AuthProvider>().seedData;
    String liveAssetGrowthFunds = state.assetGrowthFunds;
    String livePersonalFund = state.personalFund;
    String liveEmergencyFund = state.emergencyFund;
    if (seedData != null && seedData["current_seed"] != null) {
      final currentSeed = seedData["current_seed"];
      liveAssetGrowthFunds = (currentSeed["investment_fund"] ?? '').toString();
      livePersonalFund = (currentSeed["personal_fund"] ?? '').toString();
      liveEmergencyFund = (currentSeed["emergency_fund"] ?? '').toString();
    }

    // ✅ NEW: Alpha balance comes from analytics data
    // (providers.analyticsinfo.alpha["current"]) — the same source
    // StepThree's "Alpha" card reads. It has nothing to do with the
    // seed-data fund fields above, so it's computed separately.
    final alphaMap = providers.analyticsinfo.alpha;
    final String liveAlphaBalance =
        (alphaMap != null && alphaMap["current"] != null)
        ? alphaMap["current"].toString()
        : '';

    // ✅ Show messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.successMessage!),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
        controller.clearMessages();
      }
      if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
        controller.clearMessages();
      }
    });

    // ✅ NEW: show the Summary (third) screen once the user has completed
    // the Allocation screen and tapped its Continue button.
    if (state.step5ShowSummaryScreen) {
      return _buildSummaryScreen(
        context,
        state,
        controller,
        liveAssetGrowthFunds,
        livePersonalFund,
        liveEmergencyFund,
        liveAlphaBalance,
        currency,
      );
    }

    // ✅ swap to the Allocation (second) screen once the user has
    // moved past the percentage question.
    if (state.step5ShowSecondScreen) {
      return _buildAllocationScreen(context, state, controller, currency);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How do you want to invest?',
            style: GoogleFonts.nunitoSans(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'We allocate funds and diversify reasonably! Below is a reminder of funds available to be invested',
            style: GoogleFonts.nunitoSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.blackColor,
              height: 1.4,
            ),
          ),
          SizedBox(height: 24.h),

          // ---------------- Balance reminder card ----------------
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Asset Growth Savings',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grayColor,
                  ),
                ),
                SizedBox(height: 4.h),
                _buildAmountText(_monthlyAssetGrowthSavings, currency),
                SizedBox(height: 16.h),
                Text(
                  'Alpha Balance',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grayColor,
                  ),
                ),
                SizedBox(height: 4.h),
                _buildAmountText(_alphaBalance, currency),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // ---------------- Percentage question card ----------------
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What percentage of your total asset should be invested into this asset category/class or opportunity?',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff272727),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _percentageController,
                  keyboardType: TextInputType.number,
                  onChanged: controller.updateAllocationPercentage,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16.sp,
                    color: AppColors.blackColor,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: GoogleFonts.nunitoSans(
                      fontSize: 16.sp,
                      color: AppColors.blackColor,
                    ),
                    suffixIcon: UnconstrainedBox(
                      child: Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: Text(
                          '%',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.grayColor,
                          ),
                        ),
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: const BorderSide(color: AppColors.grayColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: const BorderSide(
                        color: Color(0xffDFDFDF),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: const BorderSide(
                        color: AppColors.blackColor,
                        width: 1,
                      ),
                    ),
                    contentPadding: EdgeInsets.fromLTRB(8.w, 14.h, 16.w, 14.h),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          if (_hasAllocationPercentage) ...[
            // ---------------- Continue (pill button, matches StepFour's Continue) ----------------
            // switches to the Allocation (second) screen instead of
            // submitting directly.
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.r),
                  ),
                  elevation: 0,
                ),
                onPressed: state.isNavigating
                    ? null
                    : () => controller.setStep5ShowSecondScreen(true),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),

            // ---------------- Save and Continue Later (outline button) ----------------
            Padding(
              padding: EdgeInsets.only(top: 15.h),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                      side: const BorderSide(color: Color(0xffC8CECC)),
                    ),
                  ),
                  onPressed: state.isNavigating
                      ? null
                      : () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24.0),
                                topRight: Radius.circular(24.0),
                              ),
                            ),
                            builder: (_) => const ContinueStrategisingPopup(
                              title:
                                  "Do you want to save and continue strategising later?",
                            ),
                          );
                        },
                  child: state.isNavigating
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor,
                            ),
                          ),
                        )
                      : Text(
                          'Save and Continue Later',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackColor,
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ],
      ),
    );
  }

  // ---------------- Allocation (second) screen ----------------
  Widget _buildAllocationScreen(
    BuildContext context,
    dynamic state,
    dynamic controller,
    String currency,
  ) {
    final bothSelected =
        state.monthlyAllocationPercent != null &&
        state.lumpsumAllocationPercent != null;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Allocation',
            style: GoogleFonts.nunitoSans(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Based on your choice of percentage allocation, the following amount are available for allocation',
            style: GoogleFonts.nunitoSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.blackColor,
              height: 1.4,
            ),
          ),
          SizedBox(height: 24.h),

          // ---------------- Balance reminder card ----------------
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Asset Growth Savings',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grayColor,
                  ),
                ),
                SizedBox(height: 4.h),
                _buildAmountText(_monthlyAssetGrowthSavings, currency),
                SizedBox(height: 16.h),
                Text(
                  'Alpha Balance',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grayColor,
                  ),
                ),
                SizedBox(height: 4.h),
                _buildAmountText(_alphaBalance, currency),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // ---------------- Monthly allocation card ----------------
          _buildAllocationCard(
            question:
                'How much would you allocate to this opportunity monthly?',
            amountLabel: 'Monthly',
            baseBalance: _monthlyAssetGrowthSavings,
            selectedPercent: state.monthlyAllocationPercent,
            onSelect: controller.updateMonthlyAllocationPercent,
          ),
          SizedBox(height: 20.h),

          // ---------------- Lumpsum allocation card ----------------
          _buildAllocationCard(
            question:
                'How much would you allocate to this opportunity as a lumpsum?',
            amountLabel: 'Lumpsum',
            baseBalance: _alphaBalance,
            selectedPercent: state.lumpsumAllocationPercent,
            onSelect: controller.updateLumpsumAllocationPercent,
          ),
          SizedBox(height: 24.h),

          if (bothSelected) ...[
            // ---------------- Continue ----------------
            // ✅ CHANGED: now navigates to the Summary (third) screen
            // instead of calling submitAllItems directly. The final
            // submission happens from the Summary screen's own
            // Continue/Confirm button.
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.r),
                  ),
                  elevation: 0,
                ),
                onPressed: state.isNavigating
                    ? null
                    : () => controller.setStep5ShowSummaryScreen(true),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),

            // ---------------- Save and Continue Later ----------------
            Padding(
              padding: EdgeInsets.only(top: 15.h),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                      side: const BorderSide(color: Color(0xffC8CECC)),
                    ),
                  ),
                  onPressed: state.isNavigating
                      ? null
                      : () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24.0),
                                topRight: Radius.circular(24.0),
                              ),
                            ),
                            builder: (_) => const ContinueStrategisingPopup(
                              title:
                                  "Do you want to save and continue strategising later?",
                            ),
                          );
                        },
                  child: state.isNavigating
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor,
                            ),
                          ),
                        )
                      : Text(
                          'Save and Continue Later',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackColor,
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ],
      ),
    );
  }

  // ✅ NEW: Summary (third) screen —
  Widget _buildSummaryScreen(
    BuildContext context,
    InvestmentFormState state,
    dynamic controller,
    String liveAssetGrowthFunds,
    String livePersonalFund,
    String liveEmergencyFund,
    String liveAlphaBalance,
    String currency,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: GoogleFonts.nunitoSans(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Confirm your investment plan and action steps before saving them as part of your ongoing strategy',
            style: GoogleFonts.nunitoSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.blackColor,
              height: 1.4,
            ),
          ),
          SizedBox(height: 24.h),

          // ---------------- WHY? section ----------------
          _buildSectionHeader(
            'WHY?',
            onEdit: () => controller.setStep5ShowSummaryEditTarget('why'),
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
                _buildSummaryLabel('Investment Name'),
                SizedBox(height: 4.h),
                _buildSummaryTextValue(state.investmentName),
                SizedBox(height: 16.h),
                _buildSummaryLabel('Reason for Investing'),
                SizedBox(height: 4.h),
                _buildSummaryTextValue(state.investmentReason),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // ---------------- Summary of Step Two ----------------
          _buildSectionHeader(
            'WHERE?',
            onEdit: () => controller.setStep2ShowSummaryEditTarget('where'),
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
                _buildSummaryLabel('Category'),
                SizedBox(height: 4.h),
                _buildSummaryTextValue(
                  investmentCategoryTitle(state.selectedCategory),
                ),
                ..._buildStep2FieldRows(state),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          // ---------------- Summary of Step Three----------------
          // In step_five.dart

          // Inside _buildSummaryScreen method...

          // ---------------- Summary of Step Three----------------
          _buildSectionHeader(
            'WHAT?',
            onEdit: () => controller.setStep3ShowSummaryEditTarget('where'),
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
                _buildSummaryLabel('Asset Growth Funds'),
                SizedBox(height: 4.h),
                // Asset Growth Funds usually comes from seed data, keeping liveAssetGrowthFunds here is fine
                _buildSummaryValue(liveAssetGrowthFunds, currency),

                SizedBox(height: 16.h),

                // ✅ UPDATED: Alpha Balance now comes from Step 3's saved data (Index 1)
                _buildSummaryLabel('Alpha Balance'),
                SizedBox(height: 4.h),
                _buildSummaryValue(_noteAt(state.step3Items, 1), currency),

                SizedBox(height: 16.h),

                _buildSummaryLabel('New Monthly Savings Goal'),
                SizedBox(height: 4.h),
                _buildSummaryValue(_newGoalAmount(state.step3Items), currency),

                _buildSummaryLabel(
                  'How do you intend to obtain this additional amount to add to your monthly savings?',
                ),
                SizedBox(height: 4.h),
                _buildSummaryTextValue(_newGoalAmount(state.step4Items)),

                SizedBox(height: 4.h),
              ],
            ),
          ),

          // ---------------- Summary of Step Four----------------
          _buildSectionHeader(
            'WHEN?',
            onEdit: () => controller.setStep3ShowSummaryEditTarget('where'),
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
                _buildSummaryLabel('How old is this opportunity?'),
                SizedBox(height: 4.h),
                _buildSummaryTextValue(_noteAt(state.step4Items, 0)),
                SizedBox(height: 16.h),
                _buildSummaryLabel(
                  'How many people have successfully invested in the last 5 years?',
                ),
                SizedBox(height: 4.h),
                _buildSummaryTextValue(_noteAt(state.step4Items, 1)),
                SizedBox(height: 16.h),
                _buildSummaryLabel(
                  'How experienced are the team behind the opportunity?',
                ),
                SizedBox(height: 4.h),
                _buildSummaryTextValue(_noteAt(state.step4Items, 2)),
                SizedBox(height: 16.h),
                _buildSummaryLabel(
                  'What customer value do they create and who are their customers?',
                ),
                SizedBox(height: 4.h),
                _buildSummaryTextValue(_noteAt(state.step4Items, 3)),
                SizedBox(height: 4.h),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // ---------------- Summary of Step Five First Screen----------------
          _buildSectionHeader(
            'HOW?',
            onEdit: () => controller.setStep5ShowSummaryEditTarget('how'),
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
                _buildSummaryLabel(
                  'What percentage of your total asset should be invested into this asset category/class or opportunity?',
                ),
                SizedBox(height: 4.h),
                _buildSummaryPercent(
                  state.allocationPercentage.trim().isEmpty
                      ? ''
                      : state.allocationPercentage,
                ),
                SizedBox(height: 16.h),
                _buildSummaryLabel('Monthly Asset Growth Savings'),
                SizedBox(height: 4.h),
                _buildSummaryValue(_monthlyAssetGrowthSavings, currency),
                SizedBox(height: 16.h),
                _buildSummaryLabel('Alpha Balance'),
                SizedBox(height: 4.h),
                _buildSummaryValue(_alphaBalance, currency),
                SizedBox(height: 16.h),
                _buildSummaryLabel(
                  'How much would you allocate to this opportunity monthly?',
                ),
                SizedBox(height: 4.h),
                _buildSummaryValueTwo(
                  _allocationSummary(
                    _monthlyAssetGrowthSavings,
                    state.monthlyAllocationPercent,
                  ),
                  _allocationSummaryPercent(state.monthlyAllocationPercent),
                  currency,
                ),
                SizedBox(height: 16.h),
                _buildSummaryLabel(
                  'How much would you allocate to this opportunity as a lumpsum?',
                ),
                SizedBox(height: 4.h),
                _buildSummaryValueTwo(
                  _allocationSummary(
                    _alphaBalance,
                    state.lumpsumAllocationPercent,
                  ),
                  _allocationSummaryPercent(state.lumpsumAllocationPercent),
                  currency,
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // ---------------- Continue (final submit) ----------------
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.r),
                ),
                elevation: 0,
              ),
              onPressed: state.isNavigating
                  ? null
                  : () async {
                      // ✅ Capture the Navigator BEFORE the async gap. NavigatorState
                      // lives higher up the tree than StepFive, so it (and its
                      // .context) stays valid even if StepFive itself gets disposed
                      // while submitAllItems is awaiting.
                      final navigator = Navigator.of(
                        context,
                        rootNavigator: true,
                      );

                      final success = await controller.submitAllItems(
                        context,
                        isFinal: true,
                      );

                      if (success) {
                        SuccessActionModal.show(
                          context: navigator.context,
                          message:
                              'Congratulations! You have successfully created a strategy',
                          onClose: () {
                            navigator.pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const ActionPlanStrategy(),
                              ),
                              (route) => false,
                            );
                          },
                        );
                      }
                    },
              child: state.isNavigating
                  ? SizedBox(
                      height: 22.h,
                      width: 22.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4.w,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Save Strategy',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.white,
                        ),
                      ],
                    ),
            ),
          ),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  String _step2NoteFor(InvestmentFormState state, String subCategory) {
    for (final item in state.step2Items) {
      if (item['sub_category'] == subCategory) {
        return item['note'] ?? '';
      }
    }
    return '';
  }

  List<Widget> _buildStep2FieldRows(InvestmentFormState state) {
    final categoryId = state.selectedCategory;
    if (categoryId == null || categoryId.isEmpty) return [];

    final fields = investmentCategoryChecklists[categoryId];
    if (fields == null) return [];

    final rows = <Widget>[];
    for (final field in fields) {
      rows.add(SizedBox(height: 16.h));
      rows.add(_buildSummaryLabel(field.label));
      rows.add(SizedBox(height: 4.h));
      rows.add(_buildSummaryTextValue(_step2NoteFor(state, field.subCategory)));
    }
    return rows;
  }

  String _noteAt(List<Map<String, String>> items, int index) {
    if (index < 0 || index >= items.length) return '';
    return items[index]['note'] ?? '';
  }

  String _newGoalAmount(List<Map<String, String>> items) {
    final note = _noteAt(items, 0);
    const prefix = 'New Goal: ';
    const sourceMarker = ', Source:';

    if (!note.startsWith(prefix)) return note;

    final sourceIndex = note.indexOf(sourceMarker);
    return sourceIndex == -1
        ? note.substring(prefix.length)
        : note.substring(prefix.length, sourceIndex);
  }

  // ✅ NEW: "WHY?" / "WHERE?" section header row with an Edit link,
  // matching the uploaded design.
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

  Widget _buildSummaryLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.nunitoSans(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.grayColor,
      ),
    );
  }

  Widget _buildSummaryPercent(String text) {
    return Row(
      children: [
        Text(
          text,
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

  Widget _buildSummaryTextValue(String text) {
    final displayText = text.isEmpty
        ? text
        : '${text[0].toUpperCase()}${text.substring(1)}';

    return Text(
      displayText,
      style: GoogleFonts.nunitoSans(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.blackColor,
        height: 1.35,
      ),
    );
  }

  Widget _buildSummaryValue(String text, String currency) {
    final amount = num.tryParse(text.replaceAll(',', '')) ?? 0;

    // Split into whole and decimal parts
    final wholeNumber = amount.truncate(); // e.g. 4000
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

  Widget _buildSummaryValueTwo(String text, String percent, String currency) {
    final amount = num.tryParse(text.replaceAll(',', '')) ?? 0;

    // Split into whole and decimal parts
    final wholeNumber = amount.truncate(); // e.g. 4000
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
          percent,
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

  // ✅ NEW: one allocation card — question, computed amount, and the 4
  // percentage chips.
  Widget _buildAllocationCard({
    required String question,
    required String amountLabel,
    required String baseBalance,
    required int? selectedPercent,
    required void Function(int) onSelect,
  }) {
    final computedAmount = selectedPercent == null
        ? 0.0
        : _parseAmount(baseBalance) * selectedPercent / 100;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: GoogleFonts.nunito(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xff272727),
              height: 1.4,
            ),
          ),
          SizedBox(height: 16.h),
          _buildAllocationAmountText(
            _formatAmount(computedAmount),
            amountLabel,
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: _allocationChoices.map((percent) {
              final isSelected = selectedPercent == percent;
              return GestureDetector(
                onTap: () => onSelect(percent),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 17.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryColor
                          : const Color(0xffEAEAEA),
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$percent',
                          style: GoogleFonts.nunito(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primaryColor
                                : AppColors.blackColor,
                          ),
                        ),
                        TextSpan(
                          text: '%',
                          style: GoogleFonts.nunito(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: isSelected
                                ? AppColors.primaryColor
                                : AppColors.grayColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ✅ NEW: turns a base balance + selected chip percent into a readable
  // "£220.00 (10%)" string for the Summary screen; returns a friendly
  // placeholder if nothing was selected.
  String _allocationSummary(String baseBalance, int? percent) {
    if (percent == null) return '0';
    final amount = _parseAmount(baseBalance) * percent / 100;
    return _formatAmount(amount);
  }

  String _allocationSummaryPercent(int? percent) {
    if (percent == null) return 'Not selected';
    final amount = percent / 100;
    return '$percent%';
  }

  // ✅ NEW: parses a "1,100.00"-style balance string into a double.
  double _parseAmount(String amount) {
    return double.tryParse(amount.replaceAll(',', '')) ?? 0.0;
  }

  // ✅ NEW: formats a double back into a "1,100.00"-style string.
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

  Widget _buildAmountText(String amount, String currency) {
    final parts = amount.split('.');
    final whole = parts[0];
    final decimals = parts.length > 1 ? parts[1] : '00';

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$currency$whole',
            style: GoogleFonts.nunitoSans(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          TextSpan(
            text: '.$decimals',
            style: GoogleFonts.nunitoSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.grayColor,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NEW: same as _buildAmountText but with a trailing label
  // (e.g. "£0.00 Monthly"), matching the Allocation screen design.
  Widget _buildAllocationAmountText(String amount, String label) {
    final parts = amount.split('.');
    final whole = parts[0];
    final decimals = parts.length > 1 ? parts[1] : '00';
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '£$whole',
            style: GoogleFonts.nunitoSans(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
          ),
          TextSpan(
            text: '.$decimals ',
            style: GoogleFonts.nunitoSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grayColor,
            ),
          ),
          TextSpan(
            text: label,
            style: GoogleFonts.nunitoSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grayColor3,
            ),
          ),
        ],
      ),
    );
  }
}
