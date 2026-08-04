import 'package:flutter/material.dart';

class LabelLegend extends StatelessWidget {
  final Color circleColor;
  final String text;
  const LabelLegend({Key? key, required this.circleColor, required this.text});

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
        Container(
          width: width * 0.03,
          height: height * 0.015,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: circleColor, // Use dynamic color here
          ),
        ),
        SizedBox(width: width * 0.02),
        Text(
          text, // Use dynamic text here
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: width * 0.04,
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }
}
