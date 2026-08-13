import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:nimble_charts/flutter.dart' as charts;
import 'package:GapHub/models/chartsmodel.dart';
import 'package:GapHub/provider/AuthProvider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/provider/reminderProvider.dart';
import 'package:GapHub/utils/dialog.dart';
import 'providers/dashboard_providers.dart';
import 'widgets/dashboard_appbar.dart';
import 'widgets/dashboard_body.dart';
import 'widgets/dashboard_nav.dart';
import 'widgets/dashboard_page_factory.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key, required this.index});
  final int index;

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends ConsumerState<Dashboard> {
  final Key _pageStrKey1 = const PageStorageKey('pageOne');
  final Key _pageStrKey2 = const PageStorageKey('pageTwo');
  final Key _pageStrKey3 = const PageStorageKey('pageThree');
  final Key _pageStrKey4 = const PageStorageKey('pageFour');
  final Key _pageStrKey5 = const PageStorageKey('pageFive');
  final Key _pageStrKey6 = const PageStorageKey('pageSix');

  List<Widget>? _cachedPages;

  List<charts.Series<Kpi, String>> _seriesData = [];
  double? _lastGrand, _lastFreedom, _lastEducation;
  double? _lastDebt, _lastCredit, _lastBeta, _lastAlpha;

  // Track what the pages were last built with so we know when to invalidate
  bool? _lastNewUserAnalytics;
  List<int>? _lastRealColors;

  final PageStorageBucket _bucket = PageStorageBucket();
  final DialogBox _dialogBox = DialogBox();
  final GlobalKey _sliderKey = GlobalKey();
  bool _hasFetchedReminders = false;

  Timer? _analyticsTimer;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;

      // Check for a tab override passed via Navigator arguments
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      final targetTab = args?['targetTab'] as int?;
      final resolvedIndex = targetTab ?? widget.index;

      if (resolvedIndex != ref.read(tabIndexProvider)) {
        ref.read(tabIndexProvider.notifier).state = resolvedIndex;
      }

      _maybeFetchReminders();
      _fetchAnalytics();
    });

    _analyticsTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _fetchAnalytics(),
    );
  }

  @override
  void dispose() {
    _analyticsTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchAnalytics() async {
    if (!mounted) return;
    await context.read<AuthProvider>().fetchAnalyticsInfo(context);
  }

  void _maybeFetchReminders() {
    if (_hasFetchedReminders || !mounted) return;
    final currency = context.read<Providers>().snapshotmodel.currency;
    if (currency.isEmpty) return;
    _hasFetchedReminders = true;
    context.read<ReminderProvider>().fetchReminders(currency);
  }

  Color _safeColor(String raw) {
    try {
      final cleaned = raw.replaceAll('#', '').trim();
      if (cleaned.length == 6) return Color(int.parse('0xff$cleaned'));
      if (cleaned.length == 8) return Color(int.parse('0x$cleaned'));
    } catch (_) {}
    return const Color(0xff000000);
  }

  double _safeStep(List<String> list, int index) {
    if (index >= list.length) return 0;
    return double.tryParse(list[index]) ?? 0;
  }

  void _maybeRebuildSeries({
    required double grand,
    required double freedom,
    required double education,
    required double debt,
    required double credit,
    required double beta,
    required double alpha,
  }) {
    if (grand == _lastGrand &&
        freedom == _lastFreedom &&
        education == _lastEducation &&
        debt == _lastDebt &&
        credit == _lastCredit &&
        beta == _lastBeta &&
        alpha == _lastAlpha) {
      return;
    }
    _lastGrand = grand;
    _lastFreedom = freedom;
    _lastEducation = education;
    _lastDebt = debt;
    _lastCredit = credit;
    _lastBeta = beta;
    _lastAlpha = alpha;

    _seriesData = [
      charts.Series<Kpi, String>(
        id: '7G KPI',
        data: [
          Kpi(
            kpi: const Text('Grand'),
            value: grand,
            gradientColors: [const Color(0xffff0001), const Color(0xffCE0001)],
          ),
          Kpi(
            kpi: const Text('Freedom'),
            value: freedom,
            gradientColors: [const Color(0xffff0001), const Color(0xffCE0001)],
          ),
          Kpi(
            kpi: const Text('Education'),
            value: education,
            gradientColors: [const Color(0xffF6AE39), const Color(0xffFF7A00)],
          ),
          Kpi(
            kpi: const Text('Debt'),
            value: debt,
            gradientColors: [const Color(0xffF6AE39), const Color(0xffFF7A00)],
          ),
          Kpi(
            kpi: const Text('Credit'),
            value: credit,
            gradientColors: [const Color(0xff005E32), const Color(0xff17B26A)],
          ),
          Kpi(
            kpi: const Text('Beta'),
            value: beta,
            gradientColors: [const Color(0xff005E32), const Color(0xff17B26A)],
          ),
          Kpi(
            kpi: const Text('Alpha'),
            value: alpha,
            gradientColors: [const Color(0xff005E77), const Color(0xff002E77)],
          ),
        ],
        domainFn: (kpi, _) => kpi.kpi.data.toString(),
        measureFn: (kpi, _) => kpi.value,
        colorFn: (kpi, _) =>
            charts.ColorUtil.fromDartColor(kpi.gradientColors.first),
        outsideLabelStyleAccessorFn: (_, __) => charts.TextStyleSpec(
          color: charts.MaterialPalette.red.shadeDefault,
        ),
        fillPatternFn: (_, __) => charts.FillPatternType.solid,
        labelAccessorFn: (kpi, _) => '${kpi.value.toInt()}%',
      ),
    ];
  }

  Future<bool> _onWillPop() => _dialogBox.options(
    context,
    'Exit',
    'Are you sure you want to exit?',
    () => SystemNavigator.pop(),
  );

  @override
  Widget build(BuildContext context) {
    final steps = context.select<Providers, List>((p) => p.sevengeemodel.steps);
    final colors = context.select<Providers, List>(
      (p) => p.sevengeemodel.backgrounds,
    );
    final analyticsInfo = context.select<Providers, dynamic>(
      (p) => p.analyticsinfo,
    );

    final List<int> realColors = colors
        .map((e) => _safeColor(e.toString()).value)
        .toList();

    final List<String> sevenGees = steps.map((e) => e.toString()).toList();
    final double grand = _safeStep(sevenGees, 0);
    final double freedom = _safeStep(sevenGees, 1);
    final double education = _safeStep(sevenGees, 2);
    final double debt = _safeStep(sevenGees, 3);
    final double credit = _safeStep(sevenGees, 4);
    final double beta = _safeStep(sevenGees, 5);
    final double alpha = _safeStep(sevenGees, 6);

    _maybeRebuildSeries(
      grand: grand,
      freedom: freedom,
      education: education,
      debt: debt,
      credit: credit,
      beta: beta,
      alpha: alpha,
    );

    final sectionValues = [
      analyticsInfo.grand?['main'],
      analyticsInfo.freedom?['main'],
      analyticsInfo.education?['main'],
      analyticsInfo.dept?['main'],
      analyticsInfo.credit?['main'],
      analyticsInfo.beta?['main'],
      analyticsInfo.alpha?['main'],
    ];
    final bool newUserAnalytics = sectionValues.every(
      (v) => v != null && v.toString() == '1',
    );

    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final size = MediaQuery.of(context).size;
    final height = isPortrait ? size.height : size.width;
    final width = isPortrait ? size.width : size.height;

    // ── Invalidate page cache when meaningful data changes ─────────────────
    // This is the key fix: pages are rebuilt when newUserAnalytics flips
    // (e.g. user completes setup and returns) or colors change.
    // The ??= guard still prevents unnecessary rebuilds on every frame.
    if (_lastNewUserAnalytics != newUserAnalytics ||
        _lastRealColors?.join() != realColors.join()) {
      _cachedPages = null;
      _lastNewUserAnalytics = newUserAnalytics;
      _lastRealColors = realColors;
    }

    _cachedPages ??= DashboardPageFactory.build(
      newUserAnalytics: newUserAnalytics,
      height: height,
      width: width,
      realColors: realColors,
      grand: grand,
      freedom: freedom,
      education: education,
      debt: debt,
      credit: credit,
      beta: beta,
      alpha: alpha,
      analyticsInfo: analyticsInfo,
      seriesData: _seriesData,
      sliderKey: _sliderKey,
      pageStrKey1: _pageStrKey1,
      pageStrKey2: _pageStrKey2,
      pageStrKey3: _pageStrKey3,
      pageStrKey4: _pageStrKey4,
      pageStrKey5: _pageStrKey5,
      pageStrKey6: _pageStrKey6,
    );
    DialogBox dialogBox = DialogBox();
    pop() {
      SystemNavigator.pop();
    }

    return WillPopScope(
      onWillPop: () async {
        return await dialogBox.options(
          context,
          'Exit',
          'Are you sure you want to exit?',
          pop,
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: DashboardAppBar(
          newUserAnalytics: newUserAnalytics,
          sliderKey: _sliderKey,
        ),
        body: DashboardBody(
          pages: _cachedPages!,
          bucket: _bucket,
          onWillPop: _onWillPop,
        ),
        bottomNavigationBar: DashboardNav(width: width),
      ),
    );
  }
}
