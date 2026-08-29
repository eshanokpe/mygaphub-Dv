// ---------------------------------------------------------------------------
// Cover Start/End field — platform-aware
// ---------------------------------------------------------------------------

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class TargetDate extends StatelessWidget {
  final DateTime? selectedDate;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<DateTime?> onDateSelected;
  final bool allowFuture;
  final bool darkColor;
  final bool downArrow;

  const TargetDate({
    required this.selectedDate,
    required this.isExpanded,
    required this.onToggle,
    required this.onDateSelected,
    this.allowFuture = false,
    this.darkColor = false,
    this.downArrow = false,
    super.key,
  });

  String get _displayText => selectedDate == null
      ? '-Select Date'
      : DateFormat('dd MMM yyyy').format(selectedDate!);

  Future<void> _showAndroidPicker(BuildContext context) async {
    // Determine the last date based on allowFuture flag
    // Using 2050 is safer for the picker's internal rendering than 2100
    final DateTime lastDate = allowFuture ? DateTime(2050) : DateTime.now();

    final picked = await DatePicker.showSimpleDatePicker(
      context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      // lastDate: lastDate,
      dateFormat: "dd-MMMM-yyyy",

      // ✅ CRITICAL FIX: Set looping to FALSE.
      // Looping causes the month array to glitch and hide Sept-Dec in large ranges.
      looping: false,

      titleText: "Set date",
      confirmText: "SET",
      cancelText: "CANCEL",
      reverse: true,
      itemTextStyle: TextStyle(
        fontSize: 14.sp,
        color: Colors.black,
        fontWeight: FontWeight.w400,
      ),
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            if (Platform.isAndroid) {
              _showAndroidPicker(context);
            } else {
              onToggle();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: darkColor
                  ? const Color(0xFFEAEAEA)
                  : const Color(0xFFF5F5F5),
              borderRadius: (Platform.isIOS && isExpanded)
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    )
                  : BorderRadius.circular(darkColor ? 16 : 10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _displayText,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: selectedDate == null
                          ? Colors.black45
                          : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                darkColor || downArrow
                    ? const SizedBox.shrink()
                    : Icon(
                        Platform.isIOS
                            ? (isExpanded
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down)
                            : Icons.arrow_drop_down,
                        size: 20,
                        color: Colors.black87,
                      ),
              ],
            ),
          ),
        ),
        if (Platform.isIOS && isExpanded)
          Container(
            height: 300.h,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Localizations.override(
              context: context,
              locale: const Locale('en', 'GB'),
              child: CupertinoDatePicker(
                initialDateTime: selectedDate ?? DateTime.now(),
                mode: CupertinoDatePickerMode.date,
                maximumDate: allowFuture ? DateTime(2050) : DateTime.now(),
                minimumYear: 1900,
                onDateTimeChanged: onDateSelected,
              ),
            ),
          ),
      ],
    );
  }
}
