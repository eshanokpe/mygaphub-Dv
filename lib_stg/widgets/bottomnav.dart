import 'package:GapHub/screens/others/dashboards/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:GapHub/utils/extensions.dart';

import 'customAnimatedBottomNav.dart';

class BottomNav extends StatefulWidget {
  final int index;

  const BottomNav(this.index, {super.key});

  @override
  _BottomNavState createState() => _BottomNavState();
} 

class _BottomNavState extends State<BottomNav> {
  late int index;
 
  @override
  void initState() {
    super.initState();
    index = widget.index;
  }

  @override
  void didUpdateWidget(BottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      setState(() => index = widget.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
 
    final bottomItems = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: CustomAnimatedBottomNav(
          isActive: index == 0,
          onTap: () => _navigateToIndex(0),
          child: Image.asset(
            'assets/images/snapshotFFF.png',
            height: height * .03,
          ),
        ),
        activeIcon: CustomAnimatedBottomNav(
          isActive: index == 0,
          onTap: () => _navigateToIndex(0),
          child: Image.asset(
            'assets/images/snapshot000.png',
            height: height * .04,
          ),
        ),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: CustomAnimatedBottomNav(
          isActive: index == 1,
          onTap: () => _navigateToIndex(1),
          child: Image.asset(
            'assets/images/analyticsFFF.png',
            height: height * .03,
          ),
        ),
        activeIcon: CustomAnimatedBottomNav(
          isActive: index == 1,
          onTap: () => _navigateToIndex(1),
          child: Image.asset(
            'assets/images/analytics000.png',
            height: height * .04,
          ),
        ),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: CustomAnimatedBottomNav(
          isActive: index == 2,
          onTap: () => _navigateToIndex(2),
          child: Image.asset(
            'assets/images/acquisitionFFF.png',
            height: height * .03,
          ),
        ),
        activeIcon: CustomAnimatedBottomNav(
          isActive: index == 2,
          onTap: () => _navigateToIndex(2),
          child: Image.asset(
            'assets/images/acquisition000.png',
            height: height * .04,
          ),
        ),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: CustomAnimatedBottomNav(
          isActive: index == 3,
          onTap: () => _navigateToIndex(3),
          child: Image.asset(
            'assets/images/portfolioFFF.png',
            height: height * .03,
          ),
        ),
        activeIcon: CustomAnimatedBottomNav(
          isActive: index == 3,
          onTap: () => _navigateToIndex(3),
          child: Image.asset(
            'assets/images/portfolio000.png',
            height: height * .04,
          ),
        ),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: CustomAnimatedBottomNav(
          isActive: index == 4,
          onTap: () => _navigateToIndex(4),
          child: Image.asset(
            'assets/images/more000.png',
            height: height * .03,
          ),
        ),
        activeIcon: CustomAnimatedBottomNav(
          isActive: index == 4,
          onTap: () => _navigateToIndex(4),
          child: Image.asset(
            'assets/images/more000.png',
            height: height * .04,
          ),
        ),
        label: '',
      ),
    ];

    return BottomNavigationBar(
      selectedFontSize: context.width() * .04,
      unselectedFontSize: context.width() * .03,
      items: bottomItems,
      backgroundColor: Colors.white,
      elevation: 0, // Removes the shadow
      currentIndex: index,
      type: BottomNavigationBarType.fixed,
      // Remove the onTap callback since it's now handled by CustomAnimatedBottomNav
      // onTap: (value) { 
      //   if (index != value) {
      //     Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => Dashboard(index: value),
      //       ),
      //     );
      //   }
      // },
      // Add these properties to disable the default ripple effect
      enableFeedback: false,
      selectedItemColor: Colors.transparent,
      unselectedItemColor: Colors.transparent,
    );
  }

  void _navigateToIndex(int value) {
    if (index != value) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Dashboard(index: value),
        ),
      );
    }
  }
}

