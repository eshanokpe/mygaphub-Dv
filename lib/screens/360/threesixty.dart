import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:google_fonts/google_fonts.dart';

import 'components/RecentlyUpdatedScreen.dart';
import 'wheel/360WheelScreen.dart';

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
  // ignore: library_private_types_in_public_api
  _ThreesixtyState createState() => _ThreesixtyState();
}

class _ThreesixtyState extends State<Threesixty> with TickerProviderStateMixin {
  late TabController _tabController;
  late ValueNotifier<int> _tabIndexNotifier;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabIndexNotifier = ValueNotifier<int>(0);

    // Add listener to sync the notifier with controller
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _tabIndexNotifier.value = _tabController.index;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _tabIndexNotifier.dispose();
    super.dispose();
  }

  void _changeTab(int index) {
    if (_tabController.index != index) {
      HapticFeedback.lightImpact(); // Add haptic feedback
      _tabController.animateTo(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              showHelpDialog(context);
            },
            child: Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Icon(Icons.add, size: 25.w, color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          /// ================= HEADER =================
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 8.h),
            child: Column(
              children: [
                Text(
                  "Personal Finance in 360°",
                  style: GoogleFonts.nunitoSans(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Have a Complete View of your numbers",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xff393737),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 25.h),

                /// ================= PROFESSIONAL TAB BAR =================
                ValueListenableBuilder<int>(
                  valueListenable: _tabIndexNotifier,
                  builder: (context, currentIndex, child) {
                    return SizedBox(
                      height: 48.h,
                      child: Row(
                        children: [
                          /// First Tab (40%)
                          Expanded(
                            flex: 4,
                            child: _buildTab(
                              index: 0,
                              currentIndex: currentIndex,
                              icon: 'assets/wheel_segments/Wheel.svg',
                              label: "360 Wheel",
                              onTap: () => _changeTab(0),
                            ),
                          ),

                          /// Divider (optional - shows between tabs when none selected)
                          if (currentIndex == -1)
                            Container(
                              width: 1,
                              height: 30.h,
                              color: Colors.grey.shade300,
                            ),

                          /// Second Tab (60%)
                          Expanded(
                            flex: 6,
                            child: _buildTab(
                              index: 1,
                              currentIndex: currentIndex,
                              icon: 'assets/wheel_segments/Tiles.svg',
                              label: "Recently Updated Tiles",
                              onTap: () => _changeTab(1),
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
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                ThreesSixtyWheelScreen(),
                RecentlyUpdatedScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required int index,
    required int currentIndex,
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 7.w),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment(-1.2, 0.9), // 76.17deg equivalent
                  end: Alignment(1.0, -2.9),
                  colors: [
                    Color(0xFF000000), // #000000 at 14.32%
                    Color(0xFF404040), // #404040 at 43.83%
                    Color(0xFF000000), // #000000 at 73.33%
                  ],
                  stops: [0.2432, 0.4383, 0.6333],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              width: 18.w,
              height: 18.h,
              fit: BoxFit.contain,
              color: isSelected ? Colors.white : Colors.black,
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 30.w),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15.h),
                Text(
                  "Need help?",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 10.h),

                /// Report Bug
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  isThreeLine: true,
                  leading: const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(Icons.bug_report, color: Colors.black),
                  ),
                  title: Text(
                    "Report a bug",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    "Something in the app is broken or doesn’t work as expected",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                // const SizedBox(height: 10),

                /// Suggest Improvement
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  isThreeLine: true,
                  leading: const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(Icons.campaign, color: Colors.black),
                  ),
                  title: Text(
                    "Suggest an improvement",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    "New ideas or desired enhancements for this app",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                const SizedBox(height: 10),

                /// Cancel Button
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
