import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'assistant.dart';

class PersonalAssistant extends StatefulWidget {
  final double? width;
  final double? height;

  const PersonalAssistant({super.key, this.width, this.height});

  @override
  State<PersonalAssistant> createState() => _PersonalAssistantState();
}

class _PersonalAssistantState extends State<PersonalAssistant> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.width! * .04),
          child: RichText(
            text: TextSpan(
              text:
                  '“A man who does not plan long ahead will find trouble right at his door” ',
              style: TextStyle(
                fontSize: 14.sp,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                color: const Color(0xff808080),
                fontFamily: 'Nunito',
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '- Confucius',
                  style: TextStyle(
                    fontStyle: FontStyle.normal,
                    fontFamily: 'Nunito',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 30.h),
        const PersonallAssitance(),
      ],
    );
  }
}
