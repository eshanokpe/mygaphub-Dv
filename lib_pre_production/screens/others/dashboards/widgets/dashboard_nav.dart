import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:GapHub/widgets/customAnimatedBottomNav.dart';

import '../providers/dashboard_providers.dart';

class DashboardNav extends ConsumerWidget {
  const DashboardNav({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watches ONLY tabIndexProvider — nothing else can trigger a rebuild here.
    final tabIndex = ref.watch(tabIndexProvider);

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        selectedFontSize: width * .04,
        unselectedFontSize: width * .03,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: tabIndex,
        onTap: (index) {
          // ref.read = no rebuild on this line, just a state write.
          // The rebuild happens only in widgets watching tabIndexProvider.
          if (ref.read(tabIndexProvider) != index) {
            ref.read(tabIndexProvider.notifier).state = index;
          }
        },
        items: [
          BottomNavigationBarItem(
            backgroundColor: Colors.transparent,
            icon: CustomAnimatedBottomNav(
              isActive: tabIndex == 0,
              child: Image.asset('assets/images/snapshotFFF.png', height: 20.h),
            ),
            activeIcon: CustomAnimatedBottomNav(
              isActive: tabIndex == 0,
              child: Image.asset('assets/images/snapshot000.png', height: 22.h),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.transparent,
            icon: CustomAnimatedBottomNav(
              isActive: tabIndex == 1,
              child: Image.asset(
                'assets/images/analyticsFFF.png',
                height: 20.h,
              ),
            ),
            activeIcon: CustomAnimatedBottomNav(
              isActive: tabIndex == 1,
              child: Image.asset(
                'assets/images/analytics000.png',
                height: 22.h,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.transparent,
            icon: CustomAnimatedBottomNav(
              isActive: tabIndex == 2,
              child: Image.asset(
                'assets/images/acquisitionFFF.png',
                height: 20.h,
              ),
            ),
            activeIcon: CustomAnimatedBottomNav(
              isActive: tabIndex == 2,
              child: Image.asset(
                'assets/images/acquisition000.png',
                height: 22.h,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.transparent,
            icon: CustomAnimatedBottomNav(
              isActive: tabIndex == 3,
              child: Image.asset(
                'assets/images/portfolioFFF.png',
                height: 20.h,
              ),
            ),
            activeIcon: CustomAnimatedBottomNav(
              isActive: tabIndex == 3,
              child: Image.asset(
                'assets/images/portfolio000.png',
                height: 22.h,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.transparent,
            icon: CustomAnimatedBottomNav(
              isActive: tabIndex == 4,
              child: Image.asset('assets/images/more000.png', height: 20.h),
            ),
            activeIcon: CustomAnimatedBottomNav(
              isActive: tabIndex == 4,
              child: Image.asset('assets/images/more000.png', height: 22.h),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
