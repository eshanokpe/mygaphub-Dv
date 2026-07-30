import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FrequencyPickerSheet extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const FrequencyPickerSheet({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(56.0),
          topRight: Radius.circular(56.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 45.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xffCDCDCD),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            "Switch Display Amounts",
            style: GoogleFonts.nunitoSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Choose how your premium will be displayed.",
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xff808080),
            ),
          ),
          SizedBox(height: 24.h),
          // Monthly option
          _FrequencyOption(
            label: 'All',
            isSelected: selected == 'All',
            onTap: () => onSelected('All'),
          ),
          // Divider between options
          Divider(
            color: AppColors.dividerColor,
            thickness: 1.h,
            height: 1.h,
            indent: 0.w,
            endIndent: 0.w,
          ),

          // Monthly option
          _FrequencyOption(
            label: 'Monthly',
            isSelected: selected == 'Monthly',
            onTap: () => onSelected('Monthly'),
          ),
          // Divider between options
          Divider(
            color: AppColors.dividerColor,
            thickness: 1.h,
            height: 1.h,
            indent: 0.w,
            endIndent: 0.w,
          ),

          // Annually option
          _FrequencyOption(
            label: 'Annually',
            isSelected: selected == 'Annually',
            onTap: () => onSelected('Annually'),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}

class _FrequencyOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FrequencyOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 14.h),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.r)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 15.sp,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isSelected ? Colors.black : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20.w,
              height: 20.h,
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 24.sp,
                      color: AppColors.primaryColor,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
