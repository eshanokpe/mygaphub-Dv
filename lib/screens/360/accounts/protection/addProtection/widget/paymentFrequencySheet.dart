import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaymentFrequencySheet extends StatefulWidget {
  final List<String> items;
  final String? selected;
  final String title;
  final ValueChanged<String> onSelected;

  const PaymentFrequencySheet({
    super.key,
    required this.items,
    required this.selected,
    required this.title,
    required this.onSelected,
  });

  @override
  State<PaymentFrequencySheet> createState() => _PaymentFrequencySheetState();
}

class _PaymentFrequencySheetState extends State<PaymentFrequencySheet> {
  String? _current;

  @override
  void initState() {
    super.initState();
    _current = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Keeps the sheet above the system nav bar / keyboard
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 28,
        bottom: MediaQuery.of(context).viewInsets.bottom + 30,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 45.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFD0D0D0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 18.h),
          ...widget.items.asMap().entries.map(
            (entry) => Column(
              children: [
                _FrequencyOption(
                  label: entry.value,
                  isSelected: entry.value == _current,
                  onTap: () {
                    setState(() => _current = entry.value);
                    widget.onSelected(entry.value);
                  },
                ),
                if (entry.key != widget.items.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.dividerColor,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FrequencyOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FrequencyOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 8.h),
        padding:  EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? const Color(0xFFE53935)
                    : Colors.black87,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFE53935),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}