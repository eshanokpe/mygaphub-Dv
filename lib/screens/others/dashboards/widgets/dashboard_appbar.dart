// widgets/dashboard_appbar.dart
//
// The dynamic AppBar extracted into its own ConsumerWidget.
// Only watches tabIndexProvider — a provider change in Providers()
// (analytics data, currency, etc.) will NEVER trigger a rebuild here.

import 'package:GapHub/screens/acquisition/widget/acquisitionHeader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:GapHub/screens/analytics/analytic_header.dart';
import 'package:GapHub/screens/more/moreHeader.dart';
import 'package:GapHub/screens/portfolio/widget/portfolio_header.dart';
import 'package:GapHub/screens/homepage/widget/homepage_header.dart';
import '../providers/dashboard_providers.dart';

class DashboardAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const DashboardAppBar({
    super.key,
    required this.newUserAnalytics,
    required this.sliderKey,
  });

  final bool newUserAnalytics;
  final GlobalKey sliderKey;

  // Required by PreferredSizeWidget so Scaffold.appBar accepts this widget.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(tabIndexProvider);

    switch (tabIndex) {
      case 0:
        return HomePageHeader(sliderKey: sliderKey);
      case 1:
        return AnalyticHeader(newUserAnalytics: newUserAnalytics);
      case 2:
        return const CustomAppBarAcquisition();
      case 3:
        return const PortfolioHeader();
      case 4:
        return const MoreHeader();
      default:
        // Tabs 2 (Acquisition) has no AppBar — return a zero-height placeholder.
        return const PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: SizedBox.shrink(),
        );
    }
  }
}
