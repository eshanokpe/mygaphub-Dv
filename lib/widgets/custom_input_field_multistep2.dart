import 'package:GapHub/utils/colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class CustomInputFieldMultiStep2 extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool obscureText;
  final int maxLines;
  final VoidCallback? onTapVisibilityToggle;
  final ValueChanged<String>? onChanged;
  final String? image;
  final String currencies;
  final String? suffixText;
  final VoidCallback? onTap;
  final List<TextInputFormatter> inputFormatters;
  final FocusNode? focusNode; // Define the focusNode parameter

  const CustomInputFieldMultiStep2({
    super.key,
    this.label,
    this.hintText,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.image,
    this.isPassword = false,
    this.obscureText = false,
    this.onTapVisibilityToggle,
    this.onChanged,
    this.currencies = '',
    this.suffixText,
    this.onTap,
    this.maxLines = 1,
    this.inputFormatters = const [], // Default to an empty list
    this.focusNode, // Add to constructor
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty)
          Wrap(
            spacing: 5.0,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  if (image != null && image!.isNotEmpty)
                    InkWell(
                      onTap: onTap,
                      child: SvgPicture.asset(image!, height: 20.h),
                    ),
                ],
              ),

              // Text('$image'),
            ],
          ),
        if (label != null && label!.isNotEmpty) const SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 3.w),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (currencies.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    currencies,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              Expanded(
                child: TextFormField(
                  focusNode: focusNode, // Assign the focusNode here
                  controller: controller,
                  obscureText: obscureText ?? false,
                  onChanged: onChanged,
                  validator: validator,

                  keyboardType: keyboardType,
                  textAlign: TextAlign.start,
                  maxLines: maxLines,
                  inputFormatters:
                      inputFormatters, // Apply inputFormatters here
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(left: 10),
                    hintStyle: TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    labelStyle: TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              if (suffixText != null && suffixText!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    suffixText!,
                    style: TextStyle(
                      color: AppColors
                          .primaryColor, // Example color for suffix text
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
