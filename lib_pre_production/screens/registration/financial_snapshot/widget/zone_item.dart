import 'package:flutter/material.dart';

class ZoneItem extends StatelessWidget {
  final String imagePath;
  final String text;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;

  const ZoneItem({
    super.key,
    required this.imagePath,
    required this.text,
    this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 0),
    this.textStyle = const TextStyle(
      fontFamily: 'Nunito',
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Image.asset(imagePath),
          const SizedBox(width: 5),
          Text(text, style: textStyle),
        ],
      ),
    );
  }
}
