import 'package:flutter/material.dart';
import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/models/chartsmodel.dart';
import 'package:GapHub/screens/acquisition/preacquisition.dart';
import 'package:GapHub/screens/portfolio/portdashboard.dart';
import 'package:GapHub/screens/more/more.dart';
import 'package:GapHub/screens/analytics/kpistab.dart';
import 'package:GapHub/screens/analytics/analytics.dart';
import 'package:GapHub/screens/homepage/homepage.dart';
import 'package:GapHub/screens/analytics/tab/bespoke_KPI.dart';
import 'package:nimble_charts/flutter.dart' as charts;

class DashboardPageFactory {
  DashboardPageFactory._(); // static-only class

  static List<Widget> build({
    required bool newUserAnalytics,
    required double height,
    required double width,
    required List<int> realColors,
    required double grand,
    required double freedom,
    required double education,
    required double debt,
    required double credit,
    required double beta,
    required double alpha,
    required Analyticsinfo analyticsInfo,
    required List<charts.Series<Kpi, String>> seriesData,
    required GlobalKey sliderKey,
    // Page storage keys passed in so they stay stable across hot reloads
    required Key pageStrKey1,
    required Key pageStrKey2,
    required Key pageStrKey3,
    required Key pageStrKey4,
    required Key pageStrKey5,
    required Key pageStrKey6,
  }) {
    final double average =
        (alpha + beta + credit + debt + education + freedom + grand) / 7;

    final tabPages = <Widget>[
      Analytics(
        key: pageStrKey2,
        height: height,
        newUserAnalytics: newUserAnalytics,
        average: average,
        realColors: realColors,
        seriesData: seriesData,
        width: width,
      ),
      BespokeKPI(key: pageStrKey6),
    ];

    final Widget analyticsPage = !newUserAnalytics
        ? Analytics(
            key: pageStrKey2,
            height: height,
            newUserAnalytics: newUserAnalytics,
            average: average,
            realColors: realColors,
            seriesData: seriesData,
            width: width,
            tabPages: tabPages,
          )
        : Kpistab(
            tabPages: tabPages,
            height: height,
            width: width,
            contains: newUserAnalytics,
          );

    return <Widget>[
      Homepage(
        key: pageStrKey1,
        width: width,
        height: height,
        newUserAnalytics: newUserAnalytics,
        analyticsInfo: analyticsInfo,
        sliderKey: sliderKey,
        realColors: realColors,
      ),
      analyticsPage,
      Preacquisition(key: pageStrKey3),
      Portdashboard(key: pageStrKey4),
      More(key: pageStrKey5),
    ];
  }
}
