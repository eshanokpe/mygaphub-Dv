import 'dart:math';
import 'dart:typed_data';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/svg.dart';

import 'wheel/360WheelScreen.dart';
import 'components/RecentlyUpdatedScreen.dart';

class Threesixty extends StatefulWidget {
  final bool unallocated;
  final int balance;
  final List data;
  const Threesixty({
    super.key,
    this.unallocated = false,
    this.balance = 0,
    this.data = const [],
  });
  @override
  _ThreesixtyState createState() => _ThreesixtyState();
}

class _ThreesixtyState extends State<Threesixty> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.add, size: 25, color: AppColors.primaryColor),
          ),
        ],
      ),
      body: Column(
        children: [
          /// ================= HEADER =================
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 8.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Personal Finance in 360°",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontFamily: "Nunito Sans",
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Have a Complete View of your numbers",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xff393737),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 25.h),

                // Tab Bar
                LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth - 32;
                    final firstTabWidth = availableWidth * 0.4;
                    final secondTabWidth = availableWidth * 0.6;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // First tab
                          GestureDetector(
                            onTap: () {
                              _tabController.animateTo(0);
                            },
                            child: Container(
                              width: firstTabWidth,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _tabController.index == 0
                                    ? Colors.black
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/wheel_segments/Wheel.svg',
                                    width: 18.w,
                                    height: 18.h,
                                    fit: BoxFit.contain,
                                    color: _tabController.index == 0
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "360 Wheel",
                                    style: TextStyle(
                                      color: _tabController.index == 0
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Second tab
                          GestureDetector(
                            onTap: () {
                              _tabController.animateTo(1);
                            },
                            child: Container(
                              width: secondTabWidth,
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              decoration: BoxDecoration(
                                color: _tabController.index == 1
                                    ? Colors.black
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/wheel_segments/Tiles.svg',
                                    width: 18.w,
                                    height: 18.h,
                                    fit: BoxFit.contain,
                                    color: _tabController.index == 1
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Recently Updated Tiles",
                                    style: TextStyle(
                                      color: _tabController.index == 1
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: 10.h),
              ],
            ),
          ),

          /// ================= TAB VIEW =================
          Expanded(
            child: Container(
              color: Colors.white,
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                children: [
                  const ThreesSixtyWheelScreen(),
                  RecentlyUpdatedScreen(data: widget.data),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
