import 'package:flutter/material.dart';

class SpecificationInfo extends StatelessWidget {
  final String iconPath;
  final String propertyType;
  final String propertyName;
  final double width;
  final double height;

  const SpecificationInfo({
    super.key,
    required this.iconPath,
    required this.propertyType,
    required this.propertyName,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(iconPath, width: 20),
            SizedBox(width: width * .02),
            Text(
              propertyType,
              style: TextStyle(
                fontFamily: 'Nunito',
                color: const Color(0xff272727),
                fontWeight: FontWeight.w600,
                fontSize: width * .043,
              ),
            ),
          ],
        ),
        SizedBox(height: height * .005),
        Text(
          propertyName.toString(),
          style: TextStyle(
            fontFamily: 'Nunito',
            color: const Color(0xff808080),
            fontWeight: FontWeight.w600,
            fontSize: width * .043,
          ),
        ),
      ],
    );
  }
}
