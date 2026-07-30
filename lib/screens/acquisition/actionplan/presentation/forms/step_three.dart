import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/provider/AuthProvider.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../controller/investment_form_controller.dart';
import '../widgets/continue_strategising_popup.dart';

class StepThree extends ConsumerStatefulWidget {
  const StepThree({super.key});

  @override
  ConsumerState<StepThree> createState() => _StepThreeState();
}

class _StepThreeState extends ConsumerState<StepThree> {
  final _formKey = GlobalKey<FormState>();
  final _newAmountController = _AmountTextController();
  final _explanationController = TextEditingController();

  // Track which view to show
  bool _showIncreaseForm = false;

  @override
  void dispose() {
    _newAmountController.dispose();
    _explanationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchSeedData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final providers = context.watch<Providers>();
    final dashboardData = providers.dashdata;
    final analyticsData = providers.analyticsinfo;

    final seedData = context.watch<AuthProvider>().seedData;
    // Guard: bail out to a loading UI until everything needed is actually available
    if (seedData == null ||
        seedData["current_seed"] == null ||
        dashboardData == null ||
        dashboardData["income"] == null ||
        analyticsData.alpha == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final currentSeed = seedData["current_seed"];
    final investmentFund = currentSeed["investment_fund"];
    final personalFund = currentSeed["personal_fund"];
    final emergencyFund = currentSeed["emergency_fund"];
    final totalMonthlySaving = dashboardData["income"]["saving"];
    final analyticsAlpha = analyticsData.alpha["current"];

    final currency = providers.snapshotmodel.currency.trim().isNotEmpty
        ? providers.snapshotmodel.currency
        : providers.currencySymbol.trim().isNotEmpty
        ? providers.currencySymbol
        : providers.currency;
    final state = ref.watch(investmentFormControllerProvider);
    final controller = ref.read(investmentFormControllerProvider.notifier);

    if (state.assetGrowthFunds != investmentFund.toString() ||
        state.personalFund != personalFund.toString() ||
        state.emergencyFund != emergencyFund.toString()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.updateSavingsFunds(
          assetGrowthFunds: investmentFund.toString(),
          personalFund: personalFund.toString(),
          emergencyFund: emergencyFund.toString(),
        );
      });
    }

    // Show messages
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

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'What do you want to invest?',
              style: GoogleFonts.nunitoSans(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.blackColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Allocating income to savings ensures financial security and helps manage unexpected expenses or emergencies.',
              style: GoogleFonts.nunitoSans(
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.blackColor,
                height: 1.4,
              ),
            ),
            SizedBox(height: 28.h),

            // Current Average Savings Positions Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF7f7f7),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.cardBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Average Savings Positions',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Total Monthly Savings
                  _buildColumn(
                    'Total Monthly Savings',
                    currency,
                    num.tryParse(totalMonthlySaving.toString()) ?? 0,
                    isBold: true,
                  ),
                  SizedBox(height: 16.h),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: AppColors.contentColorWhite,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.cardBorderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildColumn2(
                          'Asset Growth Funds',
                          currency,
                          investmentFund,
                        ),
                        SizedBox(height: 12.h),
                        _buildColumn2(
                          'Personal Project Funds',
                          currency,
                          personalFund,
                        ),
                        SizedBox(height: 12.h),
                        _buildColumn2(
                          'Emergency & Holiday Savings',
                          currency,
                          emergencyFund,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Alpha Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Alpha',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blackColor,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          GestureDetector(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              _openInfoBottomSheet(context);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: Center(
                                child: Image.asset(
                                  'assets/icons/red_zone.png',
                                  width: 20.w,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      _buildColumn(
                        'Balance',
                        currency,
                        num.tryParse(analyticsAlpha.toString()) ?? 0,
                        isBold: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Question & Buttons
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Text(
                    'Would you like to increase the amount available for you to invest?',
                    style: GoogleFonts.nunito(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.blackColor,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 24.h),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44.h,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: _showIncreaseForm
                                  ? AppColors.primaryColor
                                  : Colors.white,
                              foregroundColor: _showIncreaseForm
                                  ? Colors.white
                                  : AppColors.primaryColor,

                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32.r),
                                side: const BorderSide(
                                  color: Color(0xffEFEFEF),
                                ),
                              ),
                            ),
                            onPressed: state.isNavigating
                                ? null
                                : () {
                                    controller.clearMessages();
                                    setState(() => _showIncreaseForm = true);
                                  },
                            child: Text(
                              'Increase Amount',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: SizedBox(
                          height: 44.h,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32.r),
                                side: const BorderSide(
                                  color: Color(0xffEFEFEF),
                                ),
                              ),
                            ),
                            // ✅ UPDATED: Saves both Savings Decision (Index 0) and Alpha Balance (Index 1)
                            onPressed: state.isNavigating
                                ? null
                                : () async {
                                    setState(() => _showIncreaseForm = false);

                                    final alphaValue = analyticsData
                                        .alpha["current"]
                                        .toString();

                                    // Save Savings Decision at Index 0
                                    controller.updateStep3Item(
                                      0,
                                      "keep_savings",
                                      "Kept existing monthly savings amount: $currency${totalMonthlySaving.toString()}",
                                    );

                                    // Save Alpha Balance at Index 1
                                    controller.updateStep3Item(
                                      1,
                                      "alpha_balance",
                                      alphaValue,
                                    );

                                    await controller.goToNextStep(context);
                                  },
                            child: state.isNavigating
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    'Keep Amount',
                                    style: GoogleFonts.nunitoSans(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- NEW: Show Increase Form when selected ---
            if (_showIncreaseForm) ...[
              SizedBox(height: 24.h),
              _buildIncreaseForm(currency, totalMonthlySaving),
              SizedBox(height: 24.h),
              // Save button for increase form
              if (_newAmountController.text.isNotEmpty &&
                  _explanationController.text.isNotEmpty) ...[
                SizedBox(
                  width: double.infinity,
                  height: 60.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    // ✅ UPDATED: Saves both New Goal (Index 0) and Alpha Balance (Index 1)
                    onPressed: state.isNavigating
                        ? null
                        : () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              final alphaValue = analyticsData.alpha["current"]
                                  .toString();
                              final newGoalText = _newAmountController.text
                                  .trim();
                              final sourceText = _explanationController.text
                                  .trim();

                              // Save New Goal at Index 0
                              controller.updateStep3Item(
                                0,
                                "increase_savings",
                                "New Goal: £$newGoalText, Source: $sourceText",
                              );

                              // Save Alpha Balance at Index 1
                              controller.updateStep3Item(
                                1,
                                "alpha_balance",
                                alphaValue,
                              );

                              await controller.goToNextStep(context);
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
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Icon(Icons.chevron_right, size: 20.w),
                            ],
                          ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.w, 15.h, 0.w, 16.h),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                          side: const BorderSide(color: Color(0xffC8CECC)),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
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
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill all required fields"),
                            ),
                          );
                        }
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
              ],
            ],

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  // Build the increase form UI
  Widget _buildIncreaseForm(String currency, dynamic value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How much would you like to increase your monthly savings to?',
            style: GoogleFonts.nunito(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 16.h),

          // Current amount
          _buildColumn(
            'Current Monthly Savings',
            currency,
            num.tryParse(value.toString()) ?? 0,
            isBold: true,
          ),

          SizedBox(height: 16.h),

          // New amount input
          Text(
            'New Monthly Savings Goal',
            style: GoogleFonts.nunitoSans(
              fontSize: 14.sp,
              color: AppColors.grayColor3,
            ),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: _newAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [_CurrencyInputFormatter()],
            style: TextStyle(fontSize: 16.sp, color: AppColors.blackColor),
            decoration: InputDecoration(
              filled: true, // ✅ Must have this
              fillColor: Colors.white,
              focusColor: Colors.white,
              prefixIcon: currency.isEmpty
                  ? null
                  : Padding(
                      padding: EdgeInsets.only(left: 14.w, right: 0.w),
                      child: Text(
                        currency,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              hint: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '0',
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '.00',
                      style: TextStyle(
                        color: AppColors.grayColor,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: AppColors.cardBorderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: AppColors.cardBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: AppColors.cardBorderColor),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter an amount';
              }
              return null;
            },
          ),
          SizedBox(height: 24.h),

          // Explanation input
          Text(
            'How do you intend to obtain this additional amount to add to your monthly savings?',
            style: GoogleFonts.nunitoSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: _explanationController,
            minLines: 1,
            maxLines: 4,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              fillColor: AppColors.contentColorWhite,
              hintText: 'E.g. I\'ll adjust my spending each month',
              hintStyle: TextStyle(color: AppColors.grayColor, fontSize: 14.sp),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: AppColors.cardBorderColor),
              ),
              focusColor: AppColors.contentColorWhite,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: AppColors.cardBorderColor),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please explain how you will get this amount';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Helper for list rows
  Widget _buildColumn(
    String label,
    String currency,
    dynamic value, {
    bool isBold = false,
  }) {
    // Convert safely to number first — fixes the String error
    final amount = num.tryParse(value.toString()) ?? 0;

    // Split into whole and decimal parts
    final wholeNumber = amount.truncate(); // e.g. 4000
    final decimalPart = (amount - wholeNumber)
        .toStringAsFixed(2)
        .split('.')
        .last; // e.g. "00"

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunitoSans(
            fontSize: 14.sp,
            color: AppColors.counterColor,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Row(
          children: [
            Text(
              '$currency${NumberFormat("#,##0").format(wholeNumber)}',
              style: GoogleFonts.nunitoSans(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                ".$decimalPart",
                style: GoogleFonts.nunitoSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff777777),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColumn2(
    String label,
    String currency,
    dynamic value, {
    bool isBold = false,
  }) {
    // Convert safely to number first — fixes the String error
    final amount = num.tryParse(value.toString()) ?? 0;

    // Split into whole and decimal parts
    final wholeNumber = amount.truncate(); // e.g. 4000
    final decimalPart = (amount - wholeNumber)
        .toStringAsFixed(2)
        .split('.')
        .last; // e.g. "00"
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunitoSans(
            fontSize: 14.sp,
            color: AppColors.counterColor,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Row(
          children: [
            Text(
              '$currency${NumberFormat("#,##0").format(wholeNumber)}',
              style: GoogleFonts.nunitoSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                ".$decimalPart",
                style: GoogleFonts.nunitoSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff777777),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _openInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
        ),
      ),
      builder: (BuildContext sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24.w, 15.h, 24.w, 40.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    height: 5.h,
                    width: 45.w,
                    decoration: BoxDecoration(
                      color: const Color(0xffcdcdcd),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Info Title
                Text(
                  'Alpha',
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 20.sp,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Asset Growth Fund (AGF)',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: const Color(0xff393737),
                  ),
                ),
                SizedBox(height: 15.h),
                Text(
                  'This is the money you set aside to invest into various asset categories such as Retirement, Investments, Cash and Equity.',
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    color: AppColors.grayColor,
                  ),
                ),
                SizedBox(height: 32.h),

                // Close Button
                CustomButton(
                  text: 'Close',
                  fontSize: 16.sp,
                  borderRadius: 30,
                  onPressed: () => Navigator.pop(sheetContext),
                  color: Colors.white,
                  textColor: AppColors.blackColor,
                  borderColor: const Color(0xffC8CECC),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow full clear
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Only allow digits and a single decimal point
    String raw = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');

    // Prevent more than one decimal point
    final parts = raw.split('.');
    if (parts.length > 2) {
      raw = '${parts[0]}.${parts.sublist(1).join('')}';
    }

    // Limit to 2 decimal places as user types them
    if (raw.contains('.')) {
      final split = raw.split('.');
      String decimals = split[1];
      if (decimals.length > 2) {
        decimals = decimals.substring(0, 2);
      }
      raw = '${split[0]}.$decimals';
    }

    // Split whole number part and decimal part (if any)
    String wholePart = raw.contains('.') ? raw.split('.')[0] : raw;
    String decimalPart = raw.contains('.') ? '.${raw.split('.')[1]}' : '';
    final hasTrailingDot = raw.endsWith('.');

    // Strip leading zeros (but keep a single "0" if that's all there is)
    wholePart = wholePart.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (wholePart.isEmpty) wholePart = '0';

    // Add thousands separators to the whole part only
    final formattedWhole = NumberFormat("#,##0").format(int.parse(wholePart));

    final formatted = hasTrailingDot && decimalPart.isEmpty
        ? '$formattedWhole.'
        : '$formattedWhole$decimalPart';

    // Calculate cursor offset: how many digits were before the old cursor,
    // then place the new cursor after the same number of digits in the new string
    int oldCursor = newValue.selection.end;
    int digitsBeforeCursor = 0;
    for (int i = 0; i < oldCursor && i < newValue.text.length; i++) {
      if (RegExp(r'[0-9.]').hasMatch(newValue.text[i])) {
        digitsBeforeCursor++;
      }
    }

    int newCursor = 0;
    int digitsSeen = 0;
    while (newCursor < formatted.length && digitsSeen < digitsBeforeCursor) {
      if (RegExp(r'[0-9.]').hasMatch(formatted[newCursor])) {
        digitsSeen++;
      }
      newCursor++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursor),
    );
  }
}

class _AmountTextController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final match = RegExp(r'^([+-]?[\d,]*)(\..*)?$').firstMatch(text);
    final wholeNumber = match?.group(1) ?? text;
    final decimal = match?.group(2) ?? '';

    return TextSpan(
      style: style,
      children: [
        TextSpan(
          text: wholeNumber,
          style: style?.copyWith(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: decimal,
          style: style?.copyWith(
            color: AppColors.grayColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
