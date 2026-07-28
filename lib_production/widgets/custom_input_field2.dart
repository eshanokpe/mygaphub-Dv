import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class CustomInputField2 extends StatefulWidget {
  final bool labelText;
  final String? label;
  final String? hintText;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final VoidCallback? onTapVisibilityToggle;
  final ValueChanged<String>? onChanged;
  final Widget? prefix;
  final Icon? suffixIcon;
  final String? type;
  final List<TextInputFormatter> inputFormatters;
  final VoidCallback? onGeneratePassword;
  final bool hasError;
  final FocusNode? focusNode;

  const CustomInputField2({
    super.key,
    this.labelText = true,
    this.label,
    this.hintText,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onTapVisibilityToggle,
    this.onChanged,
    this.prefix,
    this.type,
    this.suffixIcon,
    this.inputFormatters = const [],
    this.onGeneratePassword,
    this.hasError = false,
    this.focusNode,
  });

  @override
  State<CustomInputField2> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField2> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.labelText
            ? Text(
                widget.label!,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color: AppColors.blackColor,
                ),
              )
            : Container(),
        widget.labelText ? const SizedBox(height: 10) : Container(),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          onChanged: widget.onChanged,
          focusNode: widget.focusNode,
          inputFormatters: widget.inputFormatters,
          decoration: InputDecoration(
            hintText: widget.hintText,
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
            // Change border color based on error state
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: widget.hasError ? Colors.red : AppColors.grayColor,
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: widget.hasError ? Colors.red : Colors.black,
                width: 1.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 15.h,
              horizontal: 10.w,
            ),
            prefix: widget.prefix,
            suffixIcon:
                widget.onTapVisibilityToggle != null ||
                    widget.onGeneratePassword != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.onGeneratePassword != null)
                        IconButton(
                          icon: const Icon(
                            Icons.autorenew,
                            color: AppColors.grayColor,
                          ),
                          onPressed: widget.onGeneratePassword,
                          tooltip: 'Generate password',
                        ),
                      if (widget.onTapVisibilityToggle != null)
                        IconButton(
                          icon: Icon(
                            widget.obscureText
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.grayColor,
                          ),
                          onPressed: widget.onTapVisibilityToggle,
                          tooltip: 'Toggle visibility',
                        ),
                    ],
                  )
                : widget.suffixIcon,
          ),
          validator: widget.validator,
          keyboardType: widget.keyboardType,
        ),
      ],
    );
  }
}
