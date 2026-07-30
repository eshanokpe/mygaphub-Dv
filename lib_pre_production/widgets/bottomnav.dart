import 'package:GapHub/screens/others/dashboards/providers/dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:GapHub/utils/extensions.dart';
import 'customAnimatedBottomNav.dart';

class BottomNav extends ConsumerWidget {
  final int index;
  const BottomNav(this.index, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On Dashboard, use the live provider value.
    // On other screens, use the index passed in — so the correct tab appears active.
    final bool onDashboard = index == -1; // use -1 as a sentinel for Dashboard
    final activeIndex = onDashboard
        ? ref.watch(tabIndexProvider)
        : index;

    void goTo(int value) {
      ref.read(tabIndexProvider.notifier).state = value;

      // If we're not on Dashboard, pop back to it
      if (!onDashboard) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }

    final bottomItems = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: CustomAnimatedBottomNav(
          isActive: activeIndex == 0,
          child: Image.asset('assets/images/snapshotFFF.png', height: 20.h),
        ),
        activeIcon: CustomAnimatedBottomNav(
          isActive: activeIndex == 0,
          child: Image.asset('assets/images/snapshot000.png', height: 22.h),
        ),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: CustomAnimatedBottomNav(
          isActive: activeIndex == 1,
          child: Image.asset('assets/images/analyticsFFF.png', height: 20.h),
        ),
        activeIcon: CustomAnimatedBottomNav(
          isActive: activeIndex == 1,
          child: Image.asset('assets/images/analytics000.png', height: 22.h),
        ),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: CustomAnimatedBottomNav(
          isActive: activeIndex == 2,
          child: Image.asset('assets/images/acquisitionFFF.png', height: 20.h),
        ),
        activeIcon: CustomAnimatedBottomNav(
          isActive: activeIndex == 2,
          child: Image.asset('assets/images/acquisition000.png', height: 22.h),
        ),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: CustomAnimatedBottomNav(
          isActive: activeIndex == 3,
          child: Image.asset('assets/images/portfolioFFF.png', height: 20.h),
        ),
        activeIcon: CustomAnimatedBottomNav(
          isActive: activeIndex == 3,
          child: Image.asset('assets/images/portfolio000.png', height: 22.h),
        ),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: CustomAnimatedBottomNav(
          isActive: activeIndex == 4,
          child: Image.asset('assets/images/more000.png', height: 20.h),
        ),
        activeIcon: CustomAnimatedBottomNav(
          isActive: activeIndex == 4,
          child: Image.asset('assets/images/more000.png', height: 22.h),
        ),
        label: '',
      ),
    ];

    return BottomNavigationBar(
      selectedFontSize: context.width() * .04,
      unselectedFontSize: context.width() * .03,
      items: bottomItems,
      backgroundColor: Colors.white,
      elevation: 0,
      currentIndex: activeIndex,
      type: BottomNavigationBarType.fixed,
      enableFeedback: false,
      selectedItemColor: Colors.transparent,
      unselectedItemColor: Colors.transparent,
      onTap: goTo,
    );
  }
}