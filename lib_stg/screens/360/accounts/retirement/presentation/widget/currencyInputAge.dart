import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CurrencyInputAge extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const CurrencyInputAge({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<CurrencyInputAge> createState() => _CurrencyInputAgeState();
}

class _CurrencyInputAgeState extends State<CurrencyInputAge> {
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
  void didUpdateWidget(CurrencyInputAge oldWidget) {
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

  // Updated formatter: only whole numbers, no decimals
  String _formatValue(String raw) {
    if (raw.isEmpty) return '0';
    final num = int.tryParse(raw) ?? 0;
    return num.toString();
  }

  @override
  Widget build(BuildContext context) {
    final displayText = _formatValue(_controller.text);
    final hasValue = _controller.text.isNotEmpty && displayText != '0';

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(
                      fontSize: 20.sp,
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
                        fontSize: 20.sp,
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
              'years',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
