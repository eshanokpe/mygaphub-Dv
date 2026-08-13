import 'package:flutter/material.dart';

class CommonDropdownButton<T> extends StatelessWidget {
  final String hint;
  final T? currentValue;
  final List<T> values;
  final ValueChanged<T>? onChanged;
  final bool isExpanded;
  final bool withoutUnderline;

  const CommonDropdownButton({
    super.key,
    required this.hint,
    required this.currentValue,
    required this.values,
    this.onChanged,
    this.isExpanded = true,
    this.withoutUnderline = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      isExpanded: isExpanded,
      hint: Text(hint),
      value: values.contains(currentValue) ? currentValue : null,
      underline: withoutUnderline ? const SizedBox.shrink() : null,
      onChanged:
          onChanged != null ? (T? value) => onChanged!(value as T) : null,
      selectedItemBuilder: (context) => values
          .map((value) => Align(
                alignment: Alignment.centerLeft,
                child: Text(value.toString(), textAlign: TextAlign.center),
              ))
          .toList(),
      items: values
          .map<DropdownMenuItem<T>>(
            (value) => DropdownMenuItem<T>(
              value: value,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: value == currentValue
                        ? const Icon(Icons.check, size: 18, color: Colors.blue)
                        : const SizedBox(width: 20),
                  ),
                  Expanded(
                    child: Text(
                      value.toString(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
