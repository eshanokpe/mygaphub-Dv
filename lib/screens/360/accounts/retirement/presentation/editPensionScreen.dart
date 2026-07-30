import 'dart:io';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as legacy;
import '../../SuccessModal.dart';
import '../provider/pension_provider.dart';
import 'widget/currencyInputAge.dart';
import 'widget/currencyInput.dart';
import 'widget/formLabel.dart';
import 'widget/textInput.dart';

class EditPensionScreen extends ConsumerStatefulWidget {
  final Map existingData;
  final String? imagePath;

  const EditPensionScreen({
    super.key,
    required this.existingData,
    this.imagePath,
  });

  @override
  ConsumerState<EditPensionScreen> createState() => _EditPensionScreenState();
}

class _EditPensionScreenState extends ConsumerState<EditPensionScreen> {
  // ✅ Created ONCE, not on every build — keeps the Riverpod family key stable
  late final Map<String, dynamic> existingData;

  @override
  void initState() {
    super.initState();
    existingData = Map<String, dynamic>.from(widget.existingData);
  }

  num toNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) {
      return num.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
    }
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
    final currency = providers.snapshotmodel.currency.toString();
    debugPrint('✅ Edit loaded with: $existingData');

    // ✅ Reactive: updates EVERY time any form value changes
    final formState = ref.watch(editPensionFormProviderFamily(existingData));
    final notifier = ref.read(
      editPensionFormProviderFamily(existingData).notifier,
    );

    // Calculate current user age
    int currentAge = 0;
    try {
      final dob = DateTime.tryParse(providers.details[4]);
      if (dob != null) currentAge = calculateAge(dob);
    } catch (e) {
      debugPrint("DOB parse error: $e");
      currentAge = 0;
    }

    // ✅ LIVE PROJECTED INCOME — recalculates instantly on every change
    double projectedYearlyIncomeRounded = 0.0;
    try {
      final currentBalance = toNum(formState.currentBalance).toDouble();
      final monthlyContribution = toNum(
        formState.monthlyContribution,
      ).toDouble();
      final retirementAge = toNum(formState.retirementAge).toInt();
      const annuityRate = 0.04;
      final yearsToRetirement = retirementAge - currentAge;
      final safeYears = yearsToRetirement > 0 ? yearsToRetirement : 0;
      final futurePotValue =
          currentBalance + (monthlyContribution * 12 * safeYears);
      projectedYearlyIncomeRounded = double.parse(
        (futurePotValue * annuityRate).toStringAsFixed(2),
      );
    } catch (e) {
      debugPrint("Calculation error: $e");
      projectedYearlyIncomeRounded = 0.0;
    }

    // Format numbers for display
    final wholeProjectedYearlyIncome = projectedYearlyIncomeRounded.truncate();
    final decimalProjectedYearlyIncome =
        (projectedYearlyIncomeRounded - wholeProjectedYearlyIncome)
            .toStringAsFixed(2)
            .split('.')
            .last;

    // Validation
    final retirementAge = toNum(formState.retirementAge).toInt();
    final isRetirementAgeValid = retirementAge >= 50 && retirementAge <= 75;
    final showAgeError =
        formState.retirementAge.trim().isNotEmpty && !isRetirementAgeValid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.chevron_left, size: 28, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          existingData['pension_type'] ?? 'Edit Pension',
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
                          width: 24,
                          height: 24,
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Update your pension account information',
                      style: TextStyle(fontSize: 14.sp, color: Colors.black54),
                    ),
                    const SizedBox(height: 28),

                    const FormLabel(text: 'Pension plan name'),
                    TextInput(
                      hint: 'E.g. Personal Pension',
                      value: formState.planName,
                      onChanged: notifier.setPlanName,
                    ),
                    SizedBox(height: 20.h),

                    const FormLabel(text: "Provider’s name"),
                    TextInput(
                      hint: 'E.g. Hargreaves Lansdown, AJ Bell Youinvest, etc.',
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
                            TextSpan(text: ', updates instantly as you type.'),
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
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '.$decimalProjectedYearlyIncome',
                            style: TextStyle(
                              fontSize: 20.sp,
                              color: const Color(0xffCECECE),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    const FormLabel(text: 'How much do you contribute monthly'),
                    CurrencyInput(
                      value: formState.monthlyContribution,
                      onChanged: notifier.setMonthlyContribution,
                    ),
                    SizedBox(height: 20.h),

                    FormLabel(
                      text: 'What is the retirement age in your country?',
                      showInfo: true,
                      infoTitle: 'What is the retirement age in your country?',
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

                    SizedBox(
                      width: double.infinity,
                      height: 54.h,
                      child: ElevatedButton(
                        onPressed: formState.isSubmitting
                            ? null
                            : () async {
                                final recordId = existingData['id'];
                                if (recordId == null) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Error: Record ID not found',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                debugPrint(
                                  "Saving projected: $projectedYearlyIncomeRounded",
                                );
                                final result = await notifier.update(
                                  recordId,
                                  projectedYearlyIncomeRounded.toString(),
                                );
                                if (!context.mounted) return;
                                if (result.success) {
                                  SuccessModal.show(
                                    context: context,
                                    message: 'Pension updated successfully!',
                                    onClose: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result.errorMessage ??
                                            'Failed to update',
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
                        child: formState.isSubmitting
                            ? SizedBox(
                                width: 24.w,
                                height: 24.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
