import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ZoneItemInverted extends StatelessWidget {
  final String imagePath;
  final String text;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;
  final VoidCallback onTap;

  const ZoneItemInverted({
    super.key,
    required this.imagePath,
    required this.text,
    required this.onTap,
    this.padding = const EdgeInsets.fromLTRB(10, 0, 10, 0),
    this.textStyle = const TextStyle(
      fontFamily: 'Nunito',
      fontWeight: FontWeight.w600,
    ),
  });

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: textStyle),
            SizedBox(width: width * .01),
            Image.asset(imagePath, width: 20.w),
          ],
        ),
      ),
    );
  }
}
