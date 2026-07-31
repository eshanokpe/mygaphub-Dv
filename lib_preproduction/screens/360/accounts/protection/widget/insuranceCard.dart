import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class InsuranceCard extends StatelessWidget {
  final String currency;
  final String title;
  final String subTitle;
  final String imagePath;
  final dynamic value;
  final dynamic income;
  final String payFrequency;
  final VoidCallback onTap;

  const InsuranceCard({
    super.key,
    required this.currency,
    required this.title,
    required this.subTitle,
    required this.imagePath,
    required this.value,
    required this.income,
    required this.payFrequency,
    required this.onTap,
  });

  /// Extract only the currency symbol from strings like "$ USD", "₦ NGN"
  String get _currencySymbol {
    final trimmed = currency.trim();
    // Split on space and take the first part (the symbol)
    final parts = trimmed.split(' ');
    return parts.isNotEmpty ? parts.first : '';
  }

  String get _frequency {
    final freqStr = payFrequency.toString().trim().toLowerCase();
    if (freqStr.contains('annually') || freqStr.contains('yearly')) {
      return 'Annually';
    }
    return 'Monthly';
  }

  bool get _isAnnually => _frequency == 'Annually';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(14.w, 0.h, 0.w, 0.h),
        decoration: BoxDecoration(
          color: const Color(0xffF3F3F3),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xffEAEAEA), width: 1.w),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: _isAnnually
                        ? const [Color(0xFF020202), Color(0xFF020202)]
                        : const [Color(0xFF355C7D), Color(0xFF6C5B7B)],
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16.r),
                    topLeft: Radius.circular(10.r),
                    bottomLeft: Radius.circular(10.r),
                    bottomRight: Radius.zero,
                  ),
                ),
                child: Text(
                  _frequency,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Row(
                children: [
                  Container(
                    width: 46.w,
                    height: 46.h,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(8.w),
                    child: Image.asset(imagePath, fit: BoxFit.contain),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          subTitle,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w300,
                            color: const Color(0xFF808080),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _AmountText(
                        currencySymbol: _currencySymbol,
                        amount: income,
                      ),
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.chevron_right,
                        size: 20.w,
                        color: const Color(0xFFA6A6A6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountText extends StatelessWidget {
  final String currencySymbol;
  final dynamic amount;

  const _AmountText({required this.currencySymbol, required this.amount});

  @override
  Widget build(BuildContext context) {
    final num numValue = double.tryParse(amount.toString()) ?? 0;
    final formatted = numValue.toStringAsFixed(2);
    final parts = formatted.split('.');
    final whole = '$currencySymbol${_formatNumber(parts[0])}';
    final decimal = '.${parts[1]}';

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: whole,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          TextSpan(
            text: decimal,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(String? valueStr) {
    if (valueStr == null || valueStr.isEmpty) return '0';
    final num numValue = num.tryParse(valueStr) ?? 0;
    return NumberFormat('#,###').format(numValue);
  }
}
