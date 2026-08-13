import 'package:GapHub/screens/analytics/bespoke%20steps/bespoke2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../widgets/custom_button.dart';

class Bespoke1 extends StatefulWidget {
  const Bespoke1({super.key});

  @override
  _Bespoke1State createState() => _Bespoke1State();
}

class _Bespoke1State extends State<Bespoke1> {
  int selectedRadio = 0;

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0), // Example: rounds top-left and top-right
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                height: 5,
                width: 45.w,
                decoration: BoxDecoration(
                  color: const Color(0xffcdcdcd),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
          ),
          SizedBox(height: 15.h),
          Text(
            'Bespoke KPI',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: height * .005),
          Text(
            'What are you trying to measure?',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400),
          ),
          SizedBox(height: height * .002),
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () {
              setState(() {
                selectedRadio = 1;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Bespoke2(selected: selectedRadio),
                  ),
                );
              });
            },
            leading: Image.asset('assets/analytic/saving.png', width: 40.w),
            title: Text(
              'Saving',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              'A target you need to save up for',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xff808080),
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          SizedBox(height: height * .01),
          Container(
            height: 1,
            width: 277.w,
            margin: EdgeInsets.only(left: 60.w),
            decoration: BoxDecoration(
              color: const Color(0xffefefef),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          SizedBox(height: height * .01),
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () {
              setState(() {
                selectedRadio = 2;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Bespoke2(selected: selectedRadio),
                  ),
                );
              });
            },
            leading: Image.asset(
              'assets/analytic/eliminating_debt.png',
              width: 40.w,
            ),
            title: Text(
              'Eliminating Debt',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              'A target of debt you need to eliminate',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xff808080),
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          SizedBox(height: height * .03),
          CustomButton(
            text: 'Close',
            fontSize: 16,
            isLoading: false,
            borderRadius: 30,
            borderColor: const Color(0xffC8CECC),
            onPressed: () => Navigator.pop(context),
            color: Colors.white,
            textColor: Colors.black,
          ),
          SizedBox(height: height * .03),
        ],
      ),
    );
  }
}
