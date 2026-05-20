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
  // ─── Page storage keys — stable for the life of this widget ──────────────
  final Key _pageStrKey1 = const PageStorageKey('pageOne');
  final Key _pageStrKey2 = const PageStorageKey('pageTwo');
  final Key _pageStrKey3 = const PageStorageKey('pageThree');
  final Key _pageStrKey4 = const PageStorageKey('pageFour');
  final Key _pageStrKey5 = const PageStorageKey('pageFive');
  final Key _pageStrKey6 = const PageStorageKey('pageSix');

  // ─── Page cache — built exactly once on first frame ───────────────────────
  List<Widget>? _cachedPages;

  // ─── Chart series — only rebuilt when 7G values change ───────────────────
  List<charts.Series<Kpi, String>> _seriesData = [];
  double? _lastGrand, _lastFreedom, _lastEducation;
  double? _lastDebt, _lastCredit, _lastBeta, _lastAlpha;

  // ─── Misc ─────────────────────────────────────────────────────────────────
  final PageStorageBucket _bucket = PageStorageBucket();
  final DialogBox _dialogBox = DialogBox();
  final GlobalKey _sliderKey = GlobalKey();
  bool _hasFetchedReminders = false;

  // ─── Real-time analytics ──────────────────────────────────────────────────
  // Fetches fresh data from GET /app/seveng/edit immediately on mount,
  // then every 30 seconds. AuthProvider.fetchAnalyticsInfo() calls
  // providers.setAnalyticsInfo() which notifies context.select listeners,
  // so only widgets that read analyticsInfo rebuild — nothing else.
  Timer? _analyticsTimer;

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Seed tab index from widget parameter
      if (widget.index != ref.read(tabIndexProvider)) {
        ref.read(tabIndexProvider.notifier).state = widget.index;
      }

      _maybeFetchReminders();

      // First fetch — runs after the first frame so context.mounted is true
      _fetchAnalytics();
    });

    // Periodic refresh — keeps analyticsInfo in sync with the server
    _analyticsTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _fetchAnalytics(),
    );
  }

  @override
  void dispose() {
    // Must cancel — prevents setState being called on a dead widget
    _analyticsTimer?.cancel();
    super.dispose();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Future<void> _fetchAnalytics() async {
    if (!mounted) return;
    // Delegates to AuthProvider which hits GET /app/seveng/edit,
    // parses the response into Analyticsinfo, and calls
    // providers.setAnalyticsInfo() — triggering a targeted rebuild
    // only in widgets that watch analyticsinfo.
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
    // Skip series reconstruction if values haven't changed —
    // avoids unnecessary chart data allocation on every build()
    if (grand == _lastGrand &&
        freedom == _lastFreedom &&
        education == _lastEducation &&
        debt == _lastDebt &&
        credit == _lastCredit &&
        beta == _lastBeta &&
        alpha == _lastAlpha) return;

    _lastGrand     = grand;
    _lastFreedom   = freedom;
    _lastEducation = education;
    _lastDebt      = debt;
    _lastCredit    = credit;
    _lastBeta      = beta;
    _lastAlpha     = alpha;

    _seriesData = [
      charts.Series<Kpi, String>(
        id: '7G KPI',
        data: [
          Kpi(kpi: const Text('Grand'),     value: grand,     gradientColors: [const Color(0xffff0001), const Color(0xffCE0001)]),
          Kpi(kpi: const Text('Freedom'),   value: freedom,   gradientColors: [const Color(0xffff0001), const Color(0xffCE0001)]),
          Kpi(kpi: const Text('Education'), value: education, gradientColors: [const Color(0xffF6AE39), const Color(0xffFF7A00)]),
          Kpi(kpi: const Text('Debt'),      value: debt,      gradientColors: [const Color(0xffF6AE39), const Color(0xffFF7A00)]),
          Kpi(kpi: const Text('Credit'),    value: credit,    gradientColors: [const Color(0xff005E32), const Color(0xff17B26A)]),
          Kpi(kpi: const Text('Beta'),      value: beta,      gradientColors: [const Color(0xff005E32), const Color(0xff17B26A)]),
          Kpi(kpi: const Text('Alpha'),     value: alpha,     gradientColors: [const Color(0xff005E77), const Color(0xff002E77)]),
        ],
        domainFn:  (kpi, _) => kpi.kpi.data.toString(),
        measureFn: (kpi, _) => kpi.value,
        colorFn:   (kpi, _) => charts.ColorUtil.fromDartColor(kpi.gradientColors.first),
        outsideLabelStyleAccessorFn: (_, __) =>
            charts.TextStyleSpec(color: charts.MaterialPalette.red.shadeDefault),
        fillPatternFn:   (_, __) => charts.FillPatternType.solid,
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

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final steps = context.select<Providers, List>((p) => p.sevengeemodel.steps);
    final colors = context.select<Providers, List>((p) => p.sevengeemodel.backgrounds);

    // analyticsInfo: context.select ensures ONLY this widget rebuilds when
    // analyticsinfo changes — not the entire subtree.
    // The actual data is always fresh because _analyticsTimer calls
    // _fetchAnalytics() → AuthProvider.fetchAnalyticsInfo() →
    // providers.setAnalyticsInfo() on a 30-second cycle.
    final analyticsInfo = context.select<Providers, dynamic>(
      (p) => p.analyticsinfo,
    );

    // ── Parse colors safely ────────────────────────────────────────────────
    final List<int> realColors = colors
        .map((e) => _safeColor(e.toString()).value)
        .toList();

    // ── Parse 7G values safely ─────────────────────────────────────────────
    final List<String> sevenGees = steps.map((e) => e.toString()).toList();
    final double grand     = _safeStep(sevenGees, 0);
    final double freedom   = _safeStep(sevenGees, 1);
    final double education = _safeStep(sevenGees, 2);
    final double debt      = _safeStep(sevenGees, 3);
    final double credit    = _safeStep(sevenGees, 4);
    final double beta      = _safeStep(sevenGees, 5);
    final double alpha     = _safeStep(sevenGees, 6);

    // ── Memoised series rebuild ────────────────────────────────────────────
    _maybeRebuildSeries(
      grand: grand, freedom: freedom, education: education,
      debt: debt, credit: credit, beta: beta, alpha: alpha,
    );

    // ── newUserAnalytics flag ──────────────────────────────────────────────
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

    // ── Screen dimensions ──────────────────────────────────────────────────
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final size   = MediaQuery.of(context).size;
    final height = isPortrait ? size.height : size.width;
    final width  = isPortrait ? size.width  : size.height;

    // ── Build page cache ONCE ──────────────────────────────────────────────
    // After this point, IndexedStack handles all tab visibility.
    // Tab switches never reach this code path again.
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

    // ── Scaffold ───────────────────────────────────────────────────────────
    return Scaffold(
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
    );
  }
}