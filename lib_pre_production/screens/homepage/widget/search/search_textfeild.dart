import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';

import 'search_content.dart';

class SearchTextFeild extends StatelessWidget {
  const SearchTextFeild({super.key});

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    return SizedBox(
      width: width * .9,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                flex: 4,
                child: TextField(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchContent(),
                      ),
                    );
                  },
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                    // search();
                  },
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: AppColors.grayColor,
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
                    hintStyle: const TextStyle(
                      fontFamily: 'Nunito',
                      color: Color(0xff808080),
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
            ],
          ),
        ],
      ),
    );
  }
}
