import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'search_bathRoom.dart';
import 'search_bedRoom.dart';
import 'search_category.dart';
import 'search_monthlyincome.dart';
import 'search_propertyType.dart';

class SearchFilter extends StatelessWidget {
  final String title;

  const SearchFilter({super.key, required this.title});
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
      constraints: BoxConstraints(maxHeight: height),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
        color: Colors.white, // Background color for the bottom sheet
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Center(
                      child: Container(
                        height: 5,
                        width: width * 0.20,
                        decoration: BoxDecoration(
                          color: const Color(0xffcdcdcd),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: width * .048,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.close,
                          size: 22,
                          color: Color(0xff929292),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Category',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      color: AppColors.grayColor,
                      fontSize: width * .040,
                    ),
                  ),
                  // SizedBox(height: height * .01),
                  SearchCategory(),
                  SizedBox(height: height * .01),
                  Text(
                    'Property Type',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      color: AppColors.grayColor,
                      fontSize: width * .040,
                    ),
                  ),
                  const SearchPropertyType(),
                  SizedBox(height: height * .01),
                  Text(
                    'Bedrooms',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      color: AppColors.grayColor,
                      fontSize: width * .040,
                    ),
                  ),
                  const SearchBedRooms(),
                  SizedBox(height: height * .01),
                  Text(
                    'Bathrooms',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      color: AppColors.grayColor,
                      fontSize: width * .040,
                    ),
                  ),
                  const SearchBathRooms(),
                  SizedBox(height: height * .01),
                  Text(
                    'Monthly Income',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      color: AppColors.grayColor,
                      fontSize: width * .040,
                    ),
                  ),
                  MonthlyIncome(),
                  SizedBox(height: height * .01),
                  Text(
                    'Return on Investment [ROI]',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      color: AppColors.grayColor,
                      fontSize: width * .040,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '4%',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w500,
                          fontSize: width * .040,
                        ),
                      ),
                      Text(
                        '17%',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w500,
                          fontSize: width * .040,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Clear all',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                          fontSize: width * .040,
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: CustomButton(
                          text: 'View Result',
                          borderRadius: 20,
                          fontSize: 16,
                          borderColor: AppColors.primaryColor,
                          onPressed: () {
                            Navigator.pop(context);

                            // Navigator.pushReplacement(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => ReapList(),
                            //     ));
                          },
                          color: AppColors.primaryColor,
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
