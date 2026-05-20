// widgets/bottom_nav.dart
//
// ROOT CAUSE FIX:
//
// The original used Navigator.pushReplacement() on every tab tap:
//
//   Navigator.pushReplacement(
//     context,
//     MaterialPageRoute(builder: (context) => Dashboard(index: value)),
//   );
//
// This DESTROYS and RECREATES the entire Dashboard widget tree on every
// single tab tap — including all 5 pages, all providers, all state.
// That is why navigation felt slow: it was doing a full cold-start rebuild
// every time the user switched tabs.
//
// FIX:
//   Replace pushReplacement with a single Riverpod state write.
//   tabIndexProvider update → DashboardNav + DashboardBody + DashboardAppBar
//   repaint (show/hide only) — the 5 pages are never reconstructed.
//
// NOTE: If you use DashboardNav from dashboard_nav.dart, you do not need
// this file at all — DashboardNav already does everything here.
// Keep this file only if BottomNav is used from other parts of the app
// (e.g. non-Dashboard screens that still need a nav bar).

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
    // Watch tabIndexProvider — this is the single source of truth.
    // When it changes, only this widget repaints (icon highlight swap).
    final activeIndex = ref.watch(tabIndexProvider);

    void goTo(int value) {
      // ✅ One state write — no Navigator, no rebuild of Dashboard or any page.
      // tabIndexProvider notifies DashboardBody to show the correct child
      // in IndexedStack. All 5 pages stay alive and mounted.
      if (ref.read(tabIndexProvider) != value) {
        ref.read(tabIndexProvider.notifier).state = value;
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
      // ✅ onTap lives HERE on BottomNavigationBar — not inside the icon widgets.
      // This is the only gesture recognizer for taps — no competition, no delay.
      onTap: goTo,
    );
  }
}
