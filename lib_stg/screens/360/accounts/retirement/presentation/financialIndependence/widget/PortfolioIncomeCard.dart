import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'EditPortfolioIncome.dart';

class PortfolioIncomeCard extends StatefulWidget {
  const PortfolioIncomeCard({super.key});

  @override
  State<PortfolioIncomeCard> createState() => _PortfolioIncomeCardState();
}

class _PortfolioIncomeCardState extends State<PortfolioIncomeCard> {
  bool _isSeedSelected = true;

  /// Safely format amount, returns split parts for styling
  ({String whole, String decimal}) _splitFormattedAmount(dynamic value) {
    final num amount = num.tryParse(value?.toString() ?? '') ?? 0.0;
    final formatted = amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
    final parts = formatted.split('.');
    return (whole: parts[0], decimal: '.${parts[1]}');
  }

  @override
  Widget build(BuildContext context) {
    final providers = context.watch<Providers>();
    final snapshotModel = providers.snapshotmodel;
    final retireData = providers.retiredata;

    final currency = snapshotModel.currency?.toString() ?? '';
    final averageSeed = retireData['improve_status']['average_seed'] ?? 0.0;
    final averageExpenditure =
        retireData['improve_status']['average_expenditure'] ?? 0.0;
    final portfolioIncome = retireData['improve_status']['portfolio'] ?? 0.0;
    final investmentAmount = retireData['improve_status']['investment'] ?? 0.0;
    final roceAmount = retireData['improve_status']['roce'] ?? 0.0;

    final mainValue = _isSeedSelected ? averageSeed : averageExpenditure;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xffEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLabelText('Monthly Asset Portfolio Income (API needed)'),
          SizedBox(height: 4.h),
          _buildStyledAmount(currency, mainValue),
          SizedBox(height: 16.h),

          _buildRadioOption(
            title: 'Average SEED Total',
            selected: _isSeedSelected,
            onTap: () => setState(() => _isSeedSelected = true),
          ),
          SizedBox(height: 12.h),

          _buildRadioOption(
            title: 'Average Monthly Expenditure',
            selected: !_isSeedSelected,
            onTap: () => setState(() => _isSeedSelected = false),
          ),
          SizedBox(height: 20.h),

          _buildLabelText('Your current Asset Portfolio Income'),
          SizedBox(height: 4.h),
          _buildStyledAmount(currency, portfolioIncome),
          SizedBox(height: 20.h),

          _buildLabelText(
            'How much can you set aside monthly for investments?',
          ),
          SizedBox(height: 4.h),
          _buildStyledAmount(currency, investmentAmount),
          SizedBox(height: 20.h),

          _buildLabelText(
            'What is your expected Return on Capital Employed (ROCE)',
          ),
          SizedBox(height: 4.h),
          _buildValueText('$roceAmount'),
          SizedBox(height: 28.h),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditPortfolioIncome(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                  side: const BorderSide(color: Color(0xFFEEEEEE)),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, size: 18.w, color: AppColors.primaryColor),
                  SizedBox(width: 8.w),
                  Text(
                    'Edit Details',
                    style: GoogleFonts.nunito(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelText(String text) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 13.sp,
        color: const Color(0xFF757575),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildValueText(String value) {
    return Row(
      children: [
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 18.sp,
            color: const Color(0xFF212121),
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '%',
          style: GoogleFonts.nunito(
            fontSize: 14.sp,
            color: const Color(0xFF9E9E9E),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Styled amount with different style for decimal part
  Widget _buildStyledAmount(String currency, dynamic value) {
    final parts = _splitFormattedAmount(value);
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(
            text: '$currency${parts.whole}',
            style: GoogleFonts.nunito(
              fontSize: 18.sp,
              color: const Color(0xFF212121),
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: parts.decimal,
            style: GoogleFonts.nunito(
              fontSize: 16.sp, // smaller size
              color: const Color(0xFF9E9E9E), // lighter grey
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? const Color(0xFFD32F2F)
                    : const Color(0xFFBDBDBD),
                width: 1.5,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD32F2F),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          SizedBox(width: 10.w),
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 14.sp,
              color: const Color(0xFF212121),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
