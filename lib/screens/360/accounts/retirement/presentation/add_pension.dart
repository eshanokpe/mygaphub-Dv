import 'dart:io';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:GapHub/screens/360/accounts/retirement/presentation/retiredash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as legacy;
import '../../SuccessModal.dart';
import '../provider/pension_provider.dart';
import 'widget/currencyInputAge.dart';
import 'widget/currencyInput.dart';
import 'widget/formLabel.dart';
import '../../../widget/textInput.dart';

class AddPensionScreen extends ConsumerStatefulWidget {
  final String? title;
  final String? imagePath;
  final VoidCallback? onRefresh;

  const AddPensionScreen({
    super.key,
    this.title,
    this.imagePath,
    this.onRefresh,
  });

  @override
  ConsumerState<AddPensionScreen> createState() => _AddPensionScreenState();
}

class _AddPensionScreenState extends ConsumerState<AddPensionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _hasReset = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasReset) {
      _hasReset = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(addPensionFormProvider.notifier).reset();
        }
      });
    }
  }

  num toNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String)
      return num.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
    return 0;
  }

  int calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final providers = legacy.Provider.of<Providers>(context, listen: false);
    final formState = ref.watch(addPensionFormProvider);
    final notifier = ref.read(addPensionFormProvider.notifier);
    final currency = providers.snapshotmodel.currency.toString();

    int currentAge = 0;
    try {
      final dob = DateTime.tryParse(providers.details[4]);

      if (dob != null) currentAge = calculateAge(dob);
    } catch (e) {
      debugPrint("Failed to parse DOB: $e");
      currentAge = 0;
    }

    double projectedYearlyIncomeRounded = 0.0;
    try {
      final currentBalance = toNum(formState.currentBalance).toDouble();
      final monthlyContribution = toNum(
        formState.monthlyContribution,
      ).toDouble();
      final retirementAge = toNum(formState.retirementAge).toInt();
      const annuityRate = 0.04;
      final yearsToRetirement = retirementAge - currentAge;
      final futurePotValue =
          currentBalance +
          (monthlyContribution *
              12 *
              (yearsToRetirement > 0 ? yearsToRetirement : 0));
      projectedYearlyIncomeRounded = double.parse(
        (futurePotValue * annuityRate).toStringAsFixed(2),
      );
    } catch (e) {
      debugPrint("Calculation error: $e");
      projectedYearlyIncomeRounded = 0.0;
    }

    final wholeProjectedYearlyIncome = projectedYearlyIncomeRounded.truncate();
    final decimalProjectedYearlyIncome =
        (projectedYearlyIncomeRounded - wholeProjectedYearlyIncome)
            .toStringAsFixed(2)
            .split('.')
            .last;

    final retirementAge = toNum(formState.retirementAge).toInt();
    final isRetirementAgeValid = retirementAge >= 50 && retirementAge <= 75;
    final showAgeError =
        formState.retirementAge.trim().isNotEmpty && !isRetirementAgeValid;

    final isFormValid =
        formState.planName.trim().isNotEmpty &&
        formState.providerName.trim().isNotEmpty &&
        toNum(formState.currentBalance) >= 10 &&
        toNum(formState.monthlyContribution) > 0 &&
        isRetirementAgeValid;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: const Icon(Icons.chevron_left, size: 28, color: Colors.black),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.title != null && widget.title != 'Others'
                                ? widget.title!
                                : 'Other Insurance Types',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Image.asset(
                            widget.imagePath ??
                                'assets/wheel_segments/default.png',
                            width: 24.w,
                            height: 24.h,
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Fill out the form to add your pension account',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 28),

                      const FormLabel(text: 'Give your Pension plan a name'),
                      TextInput(
                        hint: 'E.g. Personal Pension',
                        value: formState.planName,
                        onChanged: notifier.setPlanName,
                      ),
                      SizedBox(height: 20.h),

                      const FormLabel(text: "What is the provider’s name?"),
                      TextInput(
                        hint:
                            'E.g. Hargreaves Lansdown, AJ Bell Youinvest, etc.',
                        value: formState.providerName,
                        onChanged: notifier.setProviderName,
                      ),
                      SizedBox(height: 20.h),

                      FormLabel(
                        text: 'What is the current balance?',
                        showInfo: true,
                        infoTitle: 'What is the current balance?',
                        infoContent: RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            style: GoogleFonts.nunitoSans(
                              fontSize: 14.sp,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    'The lowest allowable current balance is ${currency}1,000',
                              ),
                            ],
                          ),
                        ),
                      ),
                      CurrencyInput(
                        value: formState.currentBalance,
                        onChanged: notifier.setCurrentBalance,
                      ),
                      SizedBox(height: 20.h),

                      FormLabel(
                        text: 'Projected Yearly Income',
                        showInfo: true,
                        infoTitle: 'Projected Yearly Income',
                        infoContent: RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            style: GoogleFonts.nunitoSans(
                              fontSize: 14.sp,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                            children: const [
                              TextSpan(text: 'Calculated as: '),
                              TextSpan(
                                text: 'Future pot value × 4% annuity rate',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text:
                                    ', based on your balance, contributions and age.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 0.w,
                          vertical: 0.h,
                        ),
                        child: Row(
                          children: [
                            Text(
                              currency,
                              style: TextStyle(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              NumberFormat(
                                "#,##0",
                              ).format(wholeProjectedYearlyIncome),
                              style: TextStyle(
                                fontSize: 28.sp,
                                color: wholeProjectedYearlyIncome > 0
                                    ? Colors.black
                                    : const Color(0xffCECECE),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                '.$decimalProjectedYearlyIncome',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  color: const Color(0xffCECECE),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),

                      const FormLabel(
                        text: 'How much do you contribute monthly?',
                      ),
                      CurrencyInput(
                        value: formState.monthlyContribution,
                        onChanged: notifier.setMonthlyContribution,
                      ),
                      SizedBox(height: 20.h),

                      FormLabel(
                        text: 'What is the retirement age in your country?',
                        showInfo: true,
                        infoTitle:
                            'What is the retirement age in your country?',
                        infoContent: RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            style: GoogleFonts.nunitoSans(
                              fontSize: 14.sp,
                              height: 1.5,
                            ),
                            children: const [
                              TextSpan(
                                text:
                                    'Please ensure your response falls within a 50 to 75-year range.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      CurrencyInputAge(
                        value: formState.retirementAge,
                        onChanged: notifier.setRetirementAge,
                      ),
                      if (showAgeError)
                        Padding(
                          padding: EdgeInsets.only(top: 6.h, left: 4.w),
                          child: Text(
                            'Age must be between 50 and 75 years',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      SizedBox(height: 40.h),

                      if (isFormValid && !formState.isSubmitting)
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            // Inside the onPressed of the Submit Button:
                            onPressed: () async {
                              if (!mounted) return;

                              final result = await notifier.submit(
                                widget.title,
                                projectedYearlyIncomeRounded.toString(),
                              );

                              // ✅ CRITICAL: Check mounted again after the async operation
                              if (!mounted) return;
                              FocusScope.of(context).unfocus();
                              if (result.success) {
                                SuccessModal.show(
                                  context: context,
                                  message: 'Pension added successfully!',
                                  onRefresh: widget.onRefresh,
                                  onClose: () {
                                    widget.onRefresh?.call();
                                  },
                                );
                              } else {
                                // ✅ Safe SnackBar display
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      result.errorMessage ?? 'Failed to save',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Add Pension Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      else if (formState.isSubmitting)
                        const Center(child: CircularProgressIndicator())
                      else
                        const SizedBox.shrink(),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
