import 'package:GapHub/screens/acquisition/reap/reap.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class AppreciatingAssetUI extends StatelessWidget {
  const AppreciatingAssetUI({super.key});

  @override
  Widget build(BuildContext context) {
   
    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
          child: SizedBox(
            height: 230.h,
            child: Image.asset(
              'assets/images/acquisition/oppor.png',
              fit: BoxFit.fill,
              width: double.infinity,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0),
            ),
            color: Color.fromARGB(186, 238, 238, 238),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                context,
                'Category',
                'Real Estate Asset Program (REAP)',
              ),
              SizedBox(height: 10.h),
              _buildInfoRow(
                context,
                'Country',
                'Multiple',
              ),
              SizedBox(height: 10.h),
              _buildInfoRow(
                context,
                'Minimum Capital',
                '£10,000',
              ),
              SizedBox(height: 10.h),
              _buildInfoRow(
                context,
                'ROI',
                'Up to 20%',
              ),
              SizedBox(height: 24.h),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: CustomButton(
                    text: 'Explore',
                    borderSide: false,
                    borderRadius: 10,
                    fontSize: 16.sp,
                    icon: Icons.arrow_forward_ios,
                    borderColor: AppColors.grayColor,
                    iconColor: Colors.white,
                    onPressed: () {
                      navigateWithSlideTransition(
                        context: context,
                        destinationScreen: const Reap(),
                        transitionDuration: const Duration(milliseconds: 200),
                      );
                    },
                    color: AppColors.primaryColor,
                    textColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String title,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w300,
            fontSize: 15.sp,
            color: const Color(0xff808080),
          ),
        ),
      ],
    );
  }
}
