import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextInput extends StatefulWidget {
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;
  final bool expandable;
  final double border;
  final bool prefixIcon;

  const TextInput({
    super.key,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.expandable = false,
    this.prefixIcon = false,
    this.border = 10,
  });

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(TextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      maxLines: widget.expandable ? null : 1,
      keyboardType: widget.expandable
          ? TextInputType.multiline
          : TextInputType.text,
      style: TextStyle(fontSize: 15.sp, color: Colors.black87),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(
          color: Colors.black38,
          fontSize: 13.sp,
          fontWeight: FontWeight.w300,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.border),
          borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.border),
          borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.border),
          borderSide: const BorderSide(
            color: AppColors.borderColor,
            width: 1.5,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIconConstraints: BoxConstraints(
          minWidth: 40.w,
          minHeight: 0,
          maxWidth: 40.w,
        ),
        prefixIcon: widget.prefixIcon
            ? Padding(
                padding: EdgeInsets.only(left: 12.w, right: 8.w),
                child: SizedBox(
                  width: 20.sp,
                  height: 20.sp,
                  child: Image.asset(
                    'assets/settings/search.png',
                    fit: BoxFit.contain,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
