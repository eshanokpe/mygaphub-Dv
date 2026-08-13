import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MarketingCommunicationSheet extends StatelessWidget {
  final String? selectedOption;
  final ValueChanged<String> onOptionSelected;

  const MarketingCommunicationSheet({
    super.key,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0.h, horizontal: 16.0.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Marketing Communication',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            'Choose your preferred notification method',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp),
          ),
          SizedBox(height: 16.h),
          _buildOption(
            'Email',
            selectedOption == 'email',
            () => onOptionSelected('email'),
          ),
          _buildOption(
            'Push Notifications',
            selectedOption == 'push',
            () => onOptionSelected('push'),
          ),
          _buildOption(
            'All',
            selectedOption == 'all',
            () => onOptionSelected('all'),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildOption(String title, bool isSelected, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check,
              color: AppColors.primaryColor,
            ) // Show checkmark if selected
          : null,
      onTap: onTap,
    );
  }
}
