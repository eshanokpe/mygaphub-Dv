import 'package:GapHub/screens/helpWidget/help_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [ 
        Image.asset(
          'assets/logo.png',
          width: 40.h, 
          height: 40.h,
          fit: BoxFit.contain,
        ),
        const HelpWidget(),
      ],
    );
  }
}
