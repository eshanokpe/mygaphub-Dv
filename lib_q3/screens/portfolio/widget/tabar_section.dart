import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TabarSection extends StatefulWidget {
  TabController? tabController;
  TabarSection({super.key, this.tabController});

  @override
  State<TabarSection> createState() => _TabarSectionState();
}

class _TabarSectionState extends State<TabarSection> {
  @override
  void initState() {
    super.initState();
    // Add listener to trigger rebuilds when tab changes
    widget.tabController?.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    widget.tabController?.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    setState(() {}); // Force rebuild when tab changes
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 40.w : 40.w),
      child: Theme(
        data: Theme.of(context).copyWith(
          tabBarTheme: TabBarThemeData(
            indicatorSize: TabBarIndicatorSize.tab,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            labelPadding: EdgeInsets.symmetric(
              horizontal: isTablet ? 15.w : 15.w,
            ),
          ),
        ),
        child: TabBar(
          controller: widget.tabController,
          indicator: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20.r),
          ),
          labelColor: Colors.white,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? 18.sp : 14.sp,
          ),
          indicatorColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 5.h),
          indicatorPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 10.w : 15.w,
            vertical: 0.h,
          ),
          unselectedLabelColor: Colors.black,
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? 14.sp : 14.sp,
          ),
          dividerColor: Colors.transparent,
          tabs: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: _buildTab(
                context,
                iconPath: 'assets/images/globe_view.png',
                activeIconPath: 'assets/images/globe_view_active.png',
                label: 'Global View',
                isActive: widget.tabController?.index == 0,
                isTablet: isTablet,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: _buildTab(
                context,
                iconPath: 'assets/images/chart-pie.png',
                activeIconPath: 'assets/images/chart-pie-active.png',
                label: 'BAR View',
                isActive: widget.tabController?.index == 1,
                isTablet: isTablet,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context, {
    String? iconPath,
    String? activeIconPath,
    required String label,
    required bool isActive,
    required bool isTablet,
  }) {
    return Tab(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 0.h : 8.h,
          // horizontal: isTablet ? 20.w : 12.w, // More padding on tablet
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          border: isActive
              ? null
              : Border.all(color: Colors.black.withOpacity(0.3), width: 1.0.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconPath != null)
              Image.asset(
                isActive ? activeIconPath ?? iconPath : iconPath,
                height: isTablet ? 24.h : 20.h, // Larger icon on tablet
                width: isTablet ? 24.h : 20.h, // Larger icon on tablet
                fit: BoxFit.contain,
                color: isActive ? Colors.white : Colors.black,
              ),
            SizedBox(width: isTablet ? 12.w : 8.w), // More space on tablet
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isTablet ? 14.sp : 14.sp, // Larger font on tablet
                fontFamily: 'Nunito',
                color: isActive ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
