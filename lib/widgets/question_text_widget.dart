import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuestionTextWidget extends StatelessWidget {
  final String questionNumber;
  final String questionText;

  const QuestionTextWidget({
    super.key,
    required this.questionNumber,
    required this.questionText,
  });
 
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '$questionNumber ',
                  style:  TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: questionText,
                  style:  TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 7,
          ),
        )
      ],
    );
  }
}
