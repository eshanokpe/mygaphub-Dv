import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Custom Widget to represent selectable option (Yes or No)
class BuildRadioButton extends StatelessWidget {
  final String text;
  final int isSelected;
  final Function(int) onSelect;
  final int? value;

  const BuildRadioButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onSelect,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final bool currentlySelected = isSelected == value;

    return GestureDetector(
      onTap: () {
        onSelect(value!);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: currentlySelected
                ? AppColors.blackColor
                : const Color(0xffdbdbdb),
            width: 1.0.w,
          ),
        ),
        child: RadioListTile<int>(
          value: value ?? 0,
          title: Text(
            text,
            style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight:
                    currentlySelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 14.sp,
                color: currentlySelected
                    ? AppColors.blackColor
                    : AppColors.blackColor),
          ),
          activeColor: AppColors.primaryColor,
          groupValue: isSelected,
          onChanged: (int? value) {
            onSelect(value!);
          },
        ),
      ),
    );
  }
}
