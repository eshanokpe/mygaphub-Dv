import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RowViewDetails extends StatelessWidget {
  final String mainText;
  final String detailText;
  final VoidCallback? onTap;
  final bool arrowTap;

  const RowViewDetails({ 
    super.key,
    required this.arrowTap,
    required this.mainText,
    required this.detailText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            mainText.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              color: const Color(0xff525252),
              fontFamily: 'Nunito',
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  detailText,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    color: const Color(0xff272727),
                    fontFamily: 'Nunito',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              arrowTap == true
                  ? Icon(
                      Icons.arrow_forward_ios,
                      size: 14.w,
                      color: AppColors.primaryColor,
                    )
                  : const SizedBox(width: 8)
            ],
          ),
        ),
      ],
    );
  }
}
