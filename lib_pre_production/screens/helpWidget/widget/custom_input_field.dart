import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomInputFieldHelpUI extends StatefulWidget {
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
  final Widget? suffixIcon;
  final Widget? prefix;
  final List<TextInputFormatter> inputFormatters;
  final bool showValidationIcon;
  final bool hasError;

  const CustomInputFieldHelpUI({
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
    this.suffixIcon,
    this.prefix,
    this.inputFormatters = const [],
    this.showValidationIcon = false,
    this.hasError = false,
  });

  @override
  State<CustomInputFieldHelpUI> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputFieldHelpUI> {
  bool _isValid = false;
  final _emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+(com|com\.uk|net|org|edu|gov|mil|co|info|biz|io|me|tv|live|gmail|yahoo|hotmail)$',
    caseSensitive: false,
  );

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validateInput);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validateInput);
    super.dispose();
  }

  void _validateInput() {
    final text = widget.controller.text;
    bool newValidity;

    if (widget.keyboardType == TextInputType.emailAddress) {
      newValidity = _emailRegex.hasMatch(text);
    } else {
      newValidity = text.isNotEmpty;
    }

    if (newValidity != _isValid) {
      setState(() {
        _isValid = newValidity;
      });
    }
  }

  Widget? _buildSuffixIcon() {
    if (!widget.showValidationIcon) return widget.suffixIcon;

    if (_isValid) {
      return const Icon(Icons.check_circle_outline, color: Colors.green);
    }
    return widget.suffixIcon;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
              color: AppColors.blackColor,
            ),
          ),
          const SizedBox(height: 10),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          onChanged: (value) {
            _validateInput();
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
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
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: widget.hasError ? Colors.red : Colors.black,
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
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 10,
            ),
            prefix: widget.prefix,
            suffixIcon: _buildSuffixIcon(),
          ),
          validator: widget.validator,
          keyboardType: widget.keyboardType,
        ),
      ],
    );
  }
}
