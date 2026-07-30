import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'search_content.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  TextEditingController keyword = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose(); // Dispose the FocusNode
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: height * .01),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextField(
                      focusNode: _focusNode,
                      onTap: () {
                        _focusNode.unfocus();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchContent(),
                          ),
                        );
                      },
                      onEditingComplete: () {
                        FocusScope.of(context).unfocus();
                      },
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search for anything you need...',
                        filled: true,
                        fillColor: Colors.white,
                        // contentPadding: EdgeInsets.all(width * .01),
                        isDense:
                            true, // Reduces the overall height of the input
                        contentPadding: EdgeInsets.symmetric(
                          vertical: height * 0.01, // Adjust vertical padding
                          horizontal: width * 0.0, // Adjust horizontal padding
                        ),
                        hintStyle: TextStyle(
                          fontFamily: 'Nunito',
                          color: const Color(0xff808080),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w300,
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(
                            right: width * 0.01,
                            left: width * 0.02,
                          ), // Add right padding to icon
                          child: Image.asset(
                            'assets/images/acquisition/searchIcon.png',
                            width: width * 0.05, // Adjust icon size if needed
                          ),
                        ),
                        prefixIconConstraints: BoxConstraints(
                          minWidth:
                              width * 0.05, // Adjust minimum width for icon
                          minHeight:
                              height * 0.05, // Adjust minimum height for icon
                        ),
                        // 👇 Apply red border to all states
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.grayColor2,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.grayColor2,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: width * .02),
                ],
              ),
            ],
          ),
          SizedBox(height: height * .02),
        ],
      ),
    );
  }
}
