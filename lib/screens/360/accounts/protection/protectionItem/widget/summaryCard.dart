import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../protection_item_model.dart';

class SummaryCard extends StatelessWidget {
  final ProtectionItemModel item;
  final String imagePath; 
  
  const SummaryCard({super.key, 
    required this.imagePath,
    required this.item});

  // Icon per category — extend as needed.
  static const Map<String, IconData> _iconByCategory = {
    'Life Insurance': Icons.favorite_border,
    'Home Insurance': Icons.home_outlined,
    'Car Insurance': Icons.directions_car_outlined,
    'Health Insurance': Icons.health_and_safety_outlined,
    'Critical Illness': Icons.monitor_heart_outlined,
    'Income Protection': Icons.account_balance_wallet_outlined,
    'Gadget/Device Protection': Icons.devices_outlined,
    'Others': Icons.shield_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final icon =
        _iconByCategory[item.protectionCategory] ?? Icons.shield_outlined;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + badge row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.contentColorWhite,
                  border: Border.all(color: AppColors.cardBorderColor2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  ),
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                   gradient: const LinearGradient(
                    colors:[
                      Color(0xffF06708), Color(0xffC61A24)],
                      stops: [0.0, 0.8],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  item.protectionCategory,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Type name
          if (item.providerPolicy != null && item.providerPolicy!.isNotEmpty)
          Text(
            item.providerPolicy!,
            style: GoogleFonts.nunitoSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),

          SizedBox(height: 2.h),

          // Category sub-label
          Text(
            item.providerContact!,
            style: GoogleFonts.nunitoSans(
              fontSize: 14.sp,
              color: const Color(0xff707070),
            ),
          ),

          // Details / description
          if (item.details != null && item.details!.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              item.details!,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunitoSans(
                fontSize: 14.sp,
                color: const Color(0xff272727),
                height: 1.5,
              ),
            ),
          ],

          SizedBox(height: 8.h),

          // Cover date range
          Text(
            item.protectionType,
            style: GoogleFonts.nunitoSans(
              fontSize: 14.sp,
              color: const Color(0xff707070),
            ),
          ),
        ],
      ),
    );
  }
}