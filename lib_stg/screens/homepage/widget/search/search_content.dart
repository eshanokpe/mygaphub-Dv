import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'search_appBar_header.dart';

class SearchContent extends StatefulWidget {
  const SearchContent({super.key});

  @override
  State<SearchContent> createState() => _SearchContentState();
}

class _SearchContentState extends State<SearchContent> {
  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: SearchWidgetAppBar(sliderKey: null),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .03),
        child: Column(
          children: [
            SizedBox(height: height * .03),
            SizedBox(
              width: width * .9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: TextField(
                          onEditingComplete: () {
                            FocusScope.of(context).unfocus();
                            // search();
                          },
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.blackColor,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.grayColor,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            hintText: 'What are you looking for today?',
                            filled: true,
                            contentPadding: EdgeInsets.all(width * .01),
                            hintStyle: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14.sp,
                              color: const Color(0xff808080),
                              fontWeight: FontWeight.w300,
                            ),
                            prefixIcon: Image.asset(
                              'assets/images/acquisition/searchIcon.png',
                            ),
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: width * .02),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14.sp,
                            color: AppColors.blackColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: height * .03),
            // Center text vertically in the page
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * .18),
                    child: Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: width * 0.08,
                            backgroundColor: const Color(0xffededed),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/acquisition/search_avatar.png',
                                fit: BoxFit.cover,
                                width: width * 0.15,
                                height: width * 0.15,
                              ),
                            ),
                          ),
                          SizedBox(height: height * .01),
                          Text(
                            'Hi ${context.watch<Providers>().details[0]}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16.sp,
                              color: AppColors.blackColor,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: height * .01),
                          Text(
                            'I can assist in finding exactly what you need',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14.sp,
                              fontStyle: FontStyle.italic,
                              color: AppColors.grayColor,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(2),
    );
  }
}
