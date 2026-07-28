import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/customBottomSheet.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'editPensionScreen.dart';

class Retirementdetails extends StatelessWidget {
  final Map data;
  final String imagePath;
  const Retirementdetails({
    super.key,
    required this.data,
    required this.imagePath,
  });

  // Helper to safely convert any value to String
  String _safeToString(dynamic value) {
    if (value == null) return '7'; // default integer
    if (value is num) {
      // Round double to nearest integer
      return value.round().toString();
    }
    if (value is String) {
      // Try parsing string to number first, then round
      final parsed = num.tryParse(value.replaceAll('%', '').trim());
      if (parsed != null) return parsed.round().toString();
      return value;
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final currency = context
        .watch<Providers>()
        .snapshotmodel
        .currency
        .toString();
    print("data:$data");
    // Extract values safely
    final planName = data['name'] ?? 'N/A';
    final providerName = data['provider'] ?? 'N/A';
    final pensionType = data['pension_type'] ?? 'Private Pension';
    final balance = _formatAmount(data['current']);
    final accruedIncome = _formatAmount(data['assured_income']);
    final projectedRetirementBalance = _formatAmount(
      data['retirement_balance'] ?? 169000,
    );
    final projectedYearlyIncome = _formatAmount(data['assured_income'] ?? 6760);
    final monthlyContribution = _formatAmount(data['monthly_contribution']);
    final yearsRetirement = data['retirement_age'] ?? 27;
    // ✅ Convert percentage to String safely
    final budgetPercentage = _safeToString(data['percentage_cos'] ?? '7%');

    const String infoContent =
        'This amount is automatically computed based on your provided balance, using an assumed <b>annuity rate of 4%.</b>';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPensionScreen(
                    existingData: data,
                    imagePath: imagePath,
                  ),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Image.asset(
                'assets/wheel_segments/pencil_alt_black.png',
                width: 24.w,
                height: 24.w,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(4),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.cardBorderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 50.w,
                              height: 50.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.contentColorWhite,
                                border: Border.all(
                                  color: AppColors.cardBorderColor2,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  width: 26.w,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.shield_outlined,
                                    color: Colors.black54,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFF9B423),
                                    Color(0xFFF7A800),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                pensionType,
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFFFFFFF),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          planName,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          providerName,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 14.sp,
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
              ),
            ),
            SizedBox(height: 30.h),

            // Current Year Details Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.cardBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Year',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  _buildDetailRow(
                    label: 'Balance',
                    value: balance,
                    isAmount: true,
                    currency: currency,
                  ),
                  SizedBox(height: 24.h),

                  _buildDetailRow(
                    label: 'Accrued Yearly Income',
                    value: accruedIncome,
                    isAmount: true,
                    currency: currency,
                    showInfo: true,
                    context: context,
                    title: 'Projected Yearly Income',
                    content: infoContent,
                  ),
                  SizedBox(height: 24.h),

                  _buildDetailRow(
                    label: 'Monthly Contribution',
                    value: monthlyContribution,
                    isAmount: true,
                    currency: currency,
                  ),
                  SizedBox(height: 24.h),

                  _buildDetailRow(
                    label: 'Years till Retirement',
                    value: _safeToString(yearsRetirement),
                    isYear: true,
                  ),
                  SizedBox(height: 24.h),

                  _buildDetailRow(
                    label: 'Percentage of Current Budget',
                    value: budgetPercentage,
                  ),
                ],
              ),
            ),

            SizedBox(height: 30.h),

            // Retirement Year Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.cardBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Retirement Year',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  _buildDetailRow(
                    label: 'Balance',
                    value: projectedRetirementBalance,
                    isAmount: true,
                    currency: currency,
                  ),
                  SizedBox(height: 24.h),

                  _buildDetailRow(
                    label: 'Projected Yearly Income',
                    value: projectedYearlyIncome,
                    isAmount: true,
                    currency: currency,
                    showInfo: true,
                    context: context,
                    title: 'Projected Yearly Income',
                    content: infoContent,
                  ),
                ],
              ),
            ),

            SizedBox(height: 40.h),

            // Edit Information Section
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPensionScreen(
                        existingData: data,
                        imagePath: imagePath,
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: Image.asset(
                  'assets/wheel_segments/pencil_alt_red.png',
                  width: 20.w,
                  height: 20.w,
                  color: AppColors.primaryColor,
                ),
                label: Text(
                  'Edit Information',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    bool showInfo = false,
    bool isAmount = false,
    bool isYear = false,
    String currency = '',
    BuildContext? context,
    String title = '',
    String content = '',
  }) {
    List<String> amountParts = [];
    if (isAmount) {
      amountParts = value.split('.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.nunitoSans(
                fontSize: 14.sp,
                color: Colors.black54,
              ),
            ),
            if (showInfo && context != null)
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(56.0),
                        topRight: Radius.circular(56.0),
                      ),
                    ),
                    builder: (BuildContext sheetContext) {
                      return Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(56.0),
                            topRight: Radius.circular(56.0),
                          ),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () => Navigator.pop(sheetContext),
                                    child: Center(
                                      child: Container(
                                        height: 5.h,
                                        width: 45.w,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffcdcdcd),
                                          borderRadius: BorderRadius.circular(
                                            10.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20.h),
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  _buildStyledContent(content),
                                  SizedBox(height: 40.h),
                                  CustomButton(
                                    text: 'Close',
                                    fontSize: 16.sp,
                                    borderRadius: 30,
                                    icon: null,
                                    iconColor: AppColors.primaryColor,
                                    borderColor: const Color(0xffC8CECC),
                                    onPressed: () =>
                                        Navigator.pop(sheetContext),
                                    color: Colors.white,
                                    textColor: AppColors.blackColor,
                                  ),
                                  SizedBox(height: 32.h),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 6.w),
                  child: Image.asset('assets/icons/red_zone.png', width: 16.w),
                ),
              ),
          ],
        ),
        SizedBox(height: 4.h),
        isAmount
            ? RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$currency${amountParts[0]}.',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: amountParts.length > 1 ? amountParts[1] : '00',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              )
            : isYear
            ? RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value.replaceAll(RegExp(r'[^\d]'), ''),
                      style: GoogleFonts.nunitoSans(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: ' years',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              )
            : RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      // ✅ Keep % if already present, else add it
                      text: value.contains('%')
                          ? value
                          : '${value.replaceAll(RegExp(r'[^\d.]'), '')}%',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildStyledContent(String content) {
    final parts = content.split(RegExp(r'<b>|</b>'));
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w400,
          color: AppColors.grayColor,
          fontSize: 14.sp,
          height: 1.5,
        ),
        children: parts.asMap().entries.map((entry) {
          final index = entry.key;
          final text = entry.value;
          return TextSpan(
            text: text,
            style: index.isOdd
                ? const TextStyle(fontWeight: FontWeight.w700)
                : null,
          );
        }).toList(),
      ),
    );
  }

  String _formatAmount(dynamic value) {
    if (value == null) return '0.00';
    num? parsedValue;

    if (value is num) {
      parsedValue = value;
    } else if (value is String) {
      parsedValue = num.tryParse(value.replaceAll(',', ''));
    }

    if (parsedValue == null) return '0.00';

    final formatter = NumberFormat('#,##0.00');
    return formatter.format(parsedValue);
  }
}
