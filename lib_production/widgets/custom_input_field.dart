import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class CustomInputField extends StatefulWidget {
  final bool labelText;
  final String? label;
  final String? hintText;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onTapVisibilityToggle;
  final ValueChanged<String>? onChanged;
  final Widget? prefix;
  final Icon? suffixIcon;
  final String? type;
  final List<TextInputFormatter> inputFormatters;
  final bool hasError;

  const CustomInputField({
    super.key,
    this.labelText = true,
    this.label,
    this.hintText,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.obscureText = false,
    this.onTapVisibilityToggle,
    this.onChanged,
    this.prefix,
    this.type,
    this.suffixIcon,
    this.inputFormatters = const [],
    this.hasError = false,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
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
          inputFormatters: widget.inputFormatters,
          autofillHints: widget.isPassword
              ? [
                  AutofillHints.newPassword,
                ] // or AutofillHints.password for login
              : null,
          decoration: InputDecoration(
            hintText: widget.hintText,
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
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
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
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 10,
            ),
            prefix: widget.prefix,

            suffixIcon: widget.isPassword
                ? (widget.controller.text.isNotEmpty &&
                          widget.validator != null &&
                          widget.validator!(widget.controller.text) == null
                      ? widget.type == 'password'
                            ? IconButton(
                                icon: Icon(
                                  widget.obscureText
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.grayColor,
                                ),
                                onPressed: widget.onTapVisibilityToggle,
                              )
                            : Icon(
                                Icons.check_circle_outline,
                                color: AppColors.greenColor,
                                size: 24.sp,
                              )
                      : IconButton(
                          icon: Icon(
                            widget.obscureText
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.grayColor,
                          ),
                          onPressed: widget.onTapVisibilityToggle,
                        ))
                : null,
          ),
          validator: widget.validator,
          keyboardType: widget.keyboardType,
        ),
      ],
    );
  }
}
