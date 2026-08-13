import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CurrencyInputYearlyIncome extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const CurrencyInputYearlyIncome({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<CurrencyInputYearlyIncome> createState() => _CurrencyInputState();
}

class _CurrencyInputState extends State<CurrencyInputYearlyIncome> {
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
  void didUpdateWidget(CurrencyInputYearlyIncome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      // Preserve cursor at end
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

  _Parts _split(String raw) {
    if (raw.isEmpty) return const _Parts(whole: '0', decimal: '.00');

    String whole;
    String decimal;

    if (raw.contains('.')) {
      final parts = raw.split('.');
      whole = parts[0].isEmpty ? '0' : parts[0];
      decimal = '.${parts[1].padRight(2, '0').substring(0, 2)}';
    } else {
      whole = raw;
      decimal = '.00';
    }

    final wholeInt = int.tryParse(whole) ?? 0;
    whole = wholeInt.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );

    return _Parts(whole: whole, decimal: decimal);
  }

  @override
  Widget build(BuildContext context) {
    final parts = _split(_controller.text);

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Currency symbol
          Text(
            '£',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 2.w),

          // The actual TextField — fully visible text, real blinking cursor
          // sized to match the display style
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Invisible real TextField — handles input and cursor
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: (v) {
                    widget.onChanged(v);
                    setState(() {});
                  },
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  // Transparent text — we render our own display below
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: Colors.transparent,
                    height: 1.4,
                  ),
                  cursorColor: Colors.grey,
                  cursorWidth: 2,
                  cursorHeight: 24,
                  showCursor: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),

                // Visual display overlaid on top — same font metrics
                // as the transparent TextField so cursor aligns perfectly
                IgnorePointer(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        parts.whole,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      Text(
                        parts.decimal,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black45,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Parts {
  final String whole;
  final String decimal;
  const _Parts({required this.whole, required this.decimal});
}
