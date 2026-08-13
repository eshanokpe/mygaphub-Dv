import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PortfolioRowWidget extends StatelessWidget {
  final String label;
  final num value;
  final String currency;
  final Color color;

  const PortfolioRowWidget({
    super.key,
    required this.label,
    required this.value,
    required this.currency,
    required this.color,
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
    return Row(
      children: [
        ClipOval(
          child: Container(
            color: Colors.grey[200],
            child: Container(
              width: 12,
              height: 12,
              color: color, // Dynamically set the color
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label, // Dynamically set the label
            style:  TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 14.sp,
              color: Colors.black,
              fontFamily: 'Nunito',
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$currency${value.toStringAsFixed(2)}'.replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (match) => '${match[1]},'),
              style:  TextStyle(
                fontSize: width * .040,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
