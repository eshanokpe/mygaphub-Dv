import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PercentageInput extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const PercentageInput({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<PercentageInput> createState() => _PercentageInputState();
}

class _PercentageInputState extends State<PercentageInput> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value == '0' || widget.value.isEmpty ? '' : widget.value,
    );
    _controller.addListener(() {
      final text = _controller.text;
      if (_controller.selection.end != text.length) {
        _controller.selection = TextSelection.collapsed(offset: text.length);
      }
    });
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void didUpdateWidget(PercentageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value == '0' || widget.value.isEmpty
          ? ''
          : widget.value;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatValue(String raw) {
    if (raw.isEmpty) return '0';
    return raw;
  }

  static final _decimalInputFormatter = TextInputFormatter.withFunction((
    oldValue,
    newValue,
  ) {
    final isValid = RegExp(r'^\d*\.?\d*$').hasMatch(newValue.text);
    return isValid ? newValue : oldValue;
  });

  @override
  Widget build(BuildContext context) {
    final displayText = _formatValue(_controller.text);
    final hasValue = _controller.text.isNotEmpty && displayText != '0';

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: _isFocused ? Colors.black87 : const Color(0xFFD0D0D0),
            width: _isFocused ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Input area
            Expanded(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Invisible actual input field
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: (v) {
                      widget.onChanged(v);
                      setState(() {});
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [_decimalInputFormatter],
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.transparent,
                      height: 1.4,
                    ),
                    cursorColor: Colors.grey[700],
                    cursorWidth: 2,
                    cursorHeight: 24.h,
                    showCursor: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  // Visible text
                  IgnorePointer(
                    child: Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        // color: Colors.black87,
                        color: hasValue
                            ? Colors.black87
                            : const Color(0xFFCECECE),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Right-side "years" label
            Text(
              '%',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
