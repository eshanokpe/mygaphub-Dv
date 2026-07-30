import 'package:GapHub/provider/acquisiProvider.dart';
import 'package:GapHub/screens/acquisition/reap/reaplist.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:provider/provider.dart';

import 'searchFilter.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Dio dio = Dio();
  DialogBox dialogBox = DialogBox();
  bool filterToggle = true;
  String keywordText = '';
  TextEditingController keywordController = TextEditingController();
  late final Debouncer _debouncer; // Fixed initialization

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(delay: const Duration(milliseconds: 500));
    keywordController.text = context.read<AcquisiProvider>().keyword;
  }

  @override
  void dispose() {
    _debouncer.cancel();
    keywordController.dispose();
    super.dispose();
  }

  void _performSearch(String keyword) {
    final provider = context.read<AcquisiProvider>();
    provider.updateKeyword(keyword);
    provider.filterProperties(
      provider.selectedCategory,
      provider.selectedProperType,
      provider.selectedBedrooms,
      provider.selectedBathrooms,
      provider.minPrice,
      provider.maxPrice,
      keyword.trim(),
    );
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
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Real Estate Asset Program ',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
              Text(
                '[REAP]',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  color: const Color(0xff808080),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: height * .01),
        SizedBox(
          width: width * .9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: TextField(
                        style: TextStyle(fontSize: width * .035),
                        controller: keywordController,
                        onChanged: (value) {
                          _debouncer.call(() => _performSearch(value));
                        },
                        onEditingComplete: () {
                          // context.watch<AcquisiProvider>().properties;
                          _performSearch(keywordController.text);
                        },
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xff808080),
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          // Border when the TextField is focused
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.0,
                            ), // Change color as needed
                            borderRadius: BorderRadius.circular(14),
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xff808080),
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          hintText: 'Enter a street address, postcode, e.t.c',
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
                  ),
                  SizedBox(width: width * .02),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15.0),
                            topRight: Radius.circular(15.0),
                          ),
                        ),
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return SizedBox(
                            height: height * .80,
                            child: const SearchFilter(title: 'Filter By'),
                          );
                        },
                      );
                    },
                    child: filterToggle
                        ? Image.asset(
                            'assets/images/acquisition/filter.png',
                            height: height * .03,
                          )
                        : Image.asset(
                            'assets/images/acquisition/filter.png',
                            height: height * .03,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
