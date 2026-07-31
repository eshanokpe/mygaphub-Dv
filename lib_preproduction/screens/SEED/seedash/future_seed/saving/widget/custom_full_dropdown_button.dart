import 'package:flutter/material.dart';
import 'common_dropdown_button.dart';

class CustomFullDropdownButton<T> extends StatelessWidget {
  final String title;
  final T? currentValue;
  final bool isExpanded;
  final List<T> items;
  final ValueChanged<T>? onChanged;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final bool isTranslated;

  const CustomFullDropdownButton({
    super.key,
    required this.title,
    required this.currentValue,
    this.items = const [],
    this.onChanged,
    this.isExpanded = true,
    this.isTranslated = false,
    this.margin = const EdgeInsets.only(bottom: 15),
    this.padding = const EdgeInsets.only(left: 10),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
        border: Border.all(color: const Color.fromARGB(255, 196, 196, 196)),
      ),
      child: CommonDropdownButton<T>(
        hint: title,
        currentValue: currentValue,
        isExpanded: isExpanded,
        withoutUnderline: true,
        values: items,
        onChanged: onChanged != null
            ? (T? value) => onChanged!(value as T)
            : null,
      ),
    );
  }
}
