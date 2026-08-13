import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'currencyPickerSheet.dart';

class CurrencyPickerField extends StatelessWidget {
  final String? value; // symbol only (for storage)
  final String? displayValue; // full display text
  final void Function(
    String? symbol,
    String? displayCurrency, {
    String? displayText,
  })
  onChanged;

  const CurrencyPickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.displayValue,
  });

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.sp),
          topRight: Radius.circular(20.sp),
        ),
      ),
      builder: (_) => CurrencyPickerSheet(
        selectedSymbol: value,
        onCurrencySelected: (fullDisplayText, symbolOnly, displayCurrency) {
          onChanged(symbolOnly, displayText: fullDisplayText, displayCurrency);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = displayValue ?? value;

    return GestureDetector(
      onTap: () => _openSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label ?? '-Select',
                style: TextStyle(
                  fontSize: 14,
                  color: label == null ? Colors.black45 : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.black87),
          ],
        ),
      ),
    );
  }
}
