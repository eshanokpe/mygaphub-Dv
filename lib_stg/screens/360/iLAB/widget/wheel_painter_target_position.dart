import 'dart:math';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'wheel_painter.dart';

class WheelPainterTargetPosition extends StatefulWidget {
  const WheelPainterTargetPosition({super.key});

  @override
  State<WheelPainterTargetPosition> createState() =>
      _WheelPainterTargetPositionState();
}

class _WheelPainterTargetPositionState
    extends State<WheelPainterTargetPosition> {
  int selectedIndex = -1;

  Map<dynamic, dynamic>? _lastRaw;
  bool _scheduledReload = false;

  // ─── Toggle booleans ──────────────────────────────────────────────────────
  bool invTick0 = true;
  bool equTick0 = true;
  bool savTick0 = true;
  bool creTick0 = true;
  bool mortTick0 = true;
  bool npTick0 = true;
  bool portTick0 = true;
  bool eduTick0 = true;
  bool perTick0 = true;
  bool discTick0 = true;
  bool expenTick0 = true;

  bool investmentAssetClicked = false;
  bool homeEquityAssetClicked = false;
  bool cashAssetClicked = false;
  bool cashLiabilitiesClicked = false;
  bool mortageLiabilitiesClicked = false;
  bool nonPortfolioIncomeClicked = false;
  bool portfolioIncomeClicked = false;
  bool periodicClicked = false;
  bool educationClicked = false;
  bool expenditureClicked = false;
  bool discretionaryClicked = false;

  num investmentAssets = 0;
  num equityAssets = 0;
  num savingsAssets = 0;
  num creditLiability = 0;
  num mortageLiability = 0;
  num clickedNonPortfolio = 0;
  num clickedPortfolio = 0;
  num clickedPeriodic = 0;
  num clickedEducation = 0;
  num clickedExpenditure = 0;
  num clickedDiscretionary = 0;

  // ─── Target values parsed from API response ───────────────────────────────
  // Response: { asset: [{key, label, current, target}], ... }
  // These are the TARGET fields — null becomes 0
  num _investment = 0;
  num _equity = 0;
  num _cash = 0;
  num _credit = 0;
  num _mortgage = 0;
  num _portfolio = 0;
  num _nonPortfolio = 0;
  num _periodicSavings = 0;
  num _education = 0;
  num _expenditure = 0;
  num _discretionary = 0;

  // ─── Reads the `target` field by key from a response array ───────────────
  num _targetFor(List<dynamic> list, String key) {
    for (final item in list) {
      final map = Map<String, dynamic>.from(item as Map);
      if (map['key'] == key) {
        final t = map['target'];
        if (t == null) return 0;
        if (t is num) return t;
        return num.tryParse(t.toString().replaceAll(',', '')) ?? 0;
      }
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadData();
    });
  }

  void _loadData() {
    final raw = context.read<Providers>().ilabdata;
    if (raw.isEmpty) return;

    // ilabdata stores the inner data map directly:
    // { income: [...], liabilities: [...], asset: [...], budget: [...] }
    // Guard in case full envelope {status, data, message} was stored instead.
    final Map<String, dynamic> dataMap = raw.containsKey('income')
        ? Map<String, dynamic>.from(raw)
        : Map<String, dynamic>.from(raw['data'] as Map? ?? {});

    final incomeList = List<dynamic>.from(dataMap['income'] as List? ?? []);
    final liabList = List<dynamic>.from(dataMap['liabilities'] as List? ?? []);
    final assetList = List<dynamic>.from(dataMap['asset'] as List? ?? []);
    final budgetList = List<dynamic>.from(dataMap['budget'] as List? ?? []);

    setState(() {
      // ── Asset targets ─────────────────────────────────────────────────────
      _investment = _targetFor(assetList, 'investment');
      _equity = _targetFor(assetList, 'equity');
      _cash = _targetFor(assetList, 'cash');

      // ── Liability targets ─────────────────────────────────────────────────
      _credit = _targetFor(liabList, 'credit');
      _mortgage = _targetFor(liabList, 'mortgage');

      // ── Income targets ────────────────────────────────────────────────────
      _portfolio = _targetFor(incomeList, 'portfolio');
      _nonPortfolio = _targetFor(incomeList, 'non_portfolio');

      // ── Budget targets ────────────────────────────────────────────────────
      _periodicSavings = _targetFor(budgetList, 'periodic_savings');
      _education = _targetFor(budgetList, 'education');
      _expenditure = _targetFor(budgetList, 'expenditure');
      _discretionary = _targetFor(budgetList, 'discretionary');
    });

    debugPrint(
      '[WheelPainterTargetPosition] Targets — '
      'investment: $_investment  equity: $_equity  cash: $_cash  '
      'credit: $_credit  mortgage: $_mortgage  '
      'portfolio: $_portfolio  nonPortfolio: $_nonPortfolio  '
      'periodic: $_periodicSavings  education: $_education  '
      'expenditure: $_expenditure  discretionary: $_discretionary',
    );
  }

  // ─── Toggle helpers ───────────────────────────────────────────────────────

  void toggleLiabilitiesClicked(String type) {
    setState(() {
      switch (type) {
        case 'credit':
          cashLiabilitiesClicked = !cashLiabilitiesClicked;
          creditLiability = cashLiabilitiesClicked ? _credit : 0;
          break;
        case 'mortgage':
          mortageLiabilitiesClicked = !mortageLiabilitiesClicked;
          mortageLiability = mortageLiabilitiesClicked ? _mortgage : 0;
          break;
      }
    });
  }

  void toggleAssetTransfer(String type) {
    setState(() {
      switch (type) {
        case 'investment':
          investmentAssetClicked = !investmentAssetClicked;
          investmentAssets = investmentAssetClicked ? _investment : 0;
          break;
        case 'homeEquity':
          homeEquityAssetClicked = !homeEquityAssetClicked;
          equityAssets = homeEquityAssetClicked ? _equity : 0;
          break;
        case 'cash':
          cashAssetClicked = !cashAssetClicked;
          savingsAssets = cashAssetClicked ? _cash : 0;
          break;
      }
    });
  }

  void toggleIncomeClick(String type) {
    setState(() {
      switch (type) {
        case 'non-portfolio':
          nonPortfolioIncomeClicked = !nonPortfolioIncomeClicked;
          clickedNonPortfolio = nonPortfolioIncomeClicked ? _nonPortfolio : 0;
          break;
        case 'portfolio':
          portfolioIncomeClicked = !portfolioIncomeClicked;
          clickedPortfolio = portfolioIncomeClicked ? _portfolio : 0;
          break;
      }
    });
  }

  void toggleBudgetClick(String type) {
    setState(() {
      switch (type) {
        case 'periodic':
          periodicClicked = !periodicClicked;
          clickedPeriodic = periodicClicked ? _periodicSavings : 0;
          break;
        case 'education':
          educationClicked = !educationClicked;
          clickedEducation = educationClicked ? _education : 0;
          break;
        case 'expenditure':
          expenditureClicked = !expenditureClicked;
          clickedExpenditure = expenditureClicked ? _expenditure : 0;
          break;
        case 'discretionary':
          discretionaryClicked = !discretionaryClicked;
          clickedDiscretionary = discretionaryClicked ? _discretionary : 0;
          break;
      }
    });
  }

  void onSegmentTap(int index) => setState(() => selectedIndex = index);

  void _resetAllToggles() {
    investmentAssetClicked = false;
    homeEquityAssetClicked = false;
    cashAssetClicked = false;
    investmentAssets = 0;
    equityAssets = 0;
    savingsAssets = 0;
    cashLiabilitiesClicked = false;
    mortageLiabilitiesClicked = false;
    creditLiability = 0;
    mortageLiability = 0;
    nonPortfolioIncomeClicked = false;
    portfolioIncomeClicked = false;
    clickedNonPortfolio = 0;
    clickedPortfolio = 0;
    periodicClicked = false;
    educationClicked = false;
    expenditureClicked = false;
    discretionaryClicked = false;
    clickedPeriodic = 0;
    clickedEducation = 0;
    clickedExpenditure = 0;
    clickedDiscretionary = 0;
  }

  // ─── Number formatter (no context.watch — safe to call from build) ────────
  String _formatNumber(num value, String currency) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$whole.${parts[1]}';
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final raw = context.watch<Providers>().ilabdata;
    if (raw.isNotEmpty && !identical(raw, _lastRaw)) {
      _lastRaw = raw;
      if (!_scheduledReload) {
        _scheduledReload = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scheduledReload = false;
          if (!mounted) return;
          _loadData();
        });
      }
    }

    final String currency = context.watch<Providers>().snapshotmodel.currency;

    // ── Apply toggles to get effective totals ─────────────────────────────
    final inv0 = invTick0 ? _investment : 0;
    final eq0 = equTick0 ? _equity : 0;
    final sav0 = savTick0 ? _cash : 0;
    final num assetTotal0 =
        (inv0 - investmentAssets) +
        (eq0 - equityAssets) +
        (sav0 - savingsAssets);

    final cre0 = creTick0 ? _credit : 0;
    final mort0 = mortTick0 ? _mortgage : 0;
    final num liabilityTotal0 =
        (cre0 - creditLiability) + (mort0 - mortageLiability);

    final nonP0 = npTick0 ? _nonPortfolio : 0;
    final port0 = portTick0 ? _portfolio : 0;
    final num incomeTotal0 =
        (nonP0 - clickedNonPortfolio) + (port0 - clickedPortfolio);

    final per0 = perTick0 ? _periodicSavings : 0;
    final edu0 = eduTick0 ? _education : 0;
    final exp0 = expenTick0 ? _expenditure : 0;
    final disc0 = discTick0 ? _discretionary : 0;
    final num budget0 =
        (per0 - clickedPeriodic) +
        (edu0 - clickedEducation) +
        (exp0 - clickedExpenditure) +
        (disc0 - clickedDiscretionary);

    return GestureDetector(
      onTapUp: (details) {
        final box = context.findRenderObject() as RenderBox;
        final local = box.globalToLocal(details.globalPosition);
        final center = Offset(box.size.width / 2, box.size.height / 2);
        final dx = local.dx - center.dx;
        final dy = local.dy - center.dy;
        final dist = sqrt(dx * dx + dy * dy);

        if (dist > 80) {
          int index;
          if (dx > 0 && dy < 0) {
            index = 1;
          } else if (dx > 0 && dy > 0)
            index = 2;
          else if (dx < 0 && dy > 0)
            index = 3;
          else
            index = 0;

          if (index == selectedIndex) {
            HapticFeedback.lightImpact();
            setState(() {
              selectedIndex = -1;
              _resetAllToggles();
            });
          } else {
            onSegmentTap(index);
          }
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wheelSize = constraints.maxWidth > 0
              ? constraints.maxWidth
              : 300.w;

          return SizedBox(
            width: wheelSize,
            height: wheelSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  painter: WheelPainter(selectedIndex: selectedIndex),
                  size: Size(wheelSize, wheelSize),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildCenterContent(
                        currency,
                        assetTotal0,
                        liabilityTotal0,
                        budget0,
                        incomeTotal0,
                      ),
                    ),
                  ),
                ),

                if (selectedIndex != -1)
                  Positioned(
                    left: _getIconPosition(selectedIndex, wheelSize).dx,
                    top: _getIconPosition(selectedIndex, wheelSize).dy,
                    child: AbsorbPointer(
                      absorbing: true,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            selectedIndex = -1;
                            _resetAllToggles();
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          width: 25.w,
                          height: 25.h,
                          child: Image.asset(
                            'assets/wheel_segments/xiLab.png',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Center content dispatcher ────────────────────────────────────────────

  Widget _buildCenterContent(
    String currency,
    num assetTotal0,
    num liabilityTotal0,
    num budget0,
    num incomeTotal0,
  ) {
    if (selectedIndex == -1) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 75),
        child: Text(
          "Click on any colour to view your current position",
          textAlign: TextAlign.center,
          key: const ValueKey('default'),
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xffC5C5C5),
          ),
        ),
      );
    }

    switch (selectedIndex) {
      case 0:
        return _centerTileAssets(
          key: const ValueKey('assets'),
          title: "Asset",
          total: assetTotal0,
          color: const Color(0xff256825),
          currency: currency,
        );
      case 1:
        return _centerTileLiabilities(
          key: const ValueKey('liabilities'),
          title: "Liabilities",
          total: liabilityTotal0,
          color: const Color(0xff530182),
          currency: currency,
        );
      case 2:
        return _centerTileBudget(
          key: const ValueKey('budget'),
          title: "Budget",
          total: budget0,
          color: const Color(0xffB71922),
          currency: currency,
        );
      case 3:
        return _centerTileIncome(
          key: const ValueKey('income'),
          title: "Income",
          total: incomeTotal0,
          color: const Color(0xffE08B1C),
          currency: currency,
        );
      default:
        return const SizedBox();
    }
  }

  // ─── Shared amount header ─────────────────────────────────────────────────

  Widget _amountHeader(String title, num total, String currency) {
    final formatted = _formatNumber(total, currency);
    final parts = formatted.split('.');
    final whole = parts[0];
    final decimal = parts.length > 1 ? '.${parts[1]}' : '';

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22.sp,
            color: const Color(0xff979797),
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 4.h),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$currency$whole',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: decimal,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.grayColor,
                  textBaseline: TextBaseline.alphabetic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Tile: Assets ─────────────────────────────────────────────────────────

  Widget _centerTileAssets({
    required Key key,
    required String title,
    required num total,
    required Color color,
    required String currency,
  }) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 8.h),
        _amountHeader(title, total, currency),
        SizedBox(height: 12.h),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInteractiveTag(
                  label: "Investments",
                  backgroundColor: investmentAssetClicked
                      ? const Color(0xffD2D2D2)
                      : const Color(0xff256825),
                  value: _investment,
                  currency: currency,
                  isClicked: investmentAssetClicked,
                  onTap: () => toggleAssetTransfer('investment'),
                ),
                SizedBox(width: 8.w),
                _buildInteractiveTag(
                  label: "Home Equity",
                  backgroundColor: homeEquityAssetClicked
                      ? const Color(0xffD2D2D2)
                      : const Color(0xff256825),
                  value: _equity,
                  currency: currency,
                  isClicked: homeEquityAssetClicked,
                  onTap: () => toggleAssetTransfer('homeEquity'),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            _buildInteractiveTag(
              label: "Cash",
              backgroundColor: cashAssetClicked
                  ? const Color(0xffD2D2D2)
                  : const Color(0xff256825),
              value: _cash,
              currency: currency,
              isClicked: cashAssetClicked,
              onTap: () => toggleAssetTransfer('cash'),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Tile: Liabilities ────────────────────────────────────────────────────

  Widget _centerTileLiabilities({
    required Key key,
    required String title,
    required num total,
    required Color color,
    required String currency,
  }) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 8.h),
        _amountHeader(title, total, currency),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildInteractiveTag(
              label: "Credit",
              backgroundColor: cashLiabilitiesClicked
                  ? const Color(0xffD2D2D2)
                  : const Color(0xff530182),
              value: _credit,
              currency: currency,
              isClicked: cashLiabilitiesClicked,
              onTap: () => toggleLiabilitiesClicked('credit'),
            ),
            SizedBox(width: 8.w),
            _buildInteractiveTag(
              label: "Mortgage",
              backgroundColor: mortageLiabilitiesClicked
                  ? const Color(0xffD2D2D2)
                  : const Color(0xff530182),
              value: _mortgage,
              currency: currency,
              isClicked: mortageLiabilitiesClicked,
              onTap: () => toggleLiabilitiesClicked('mortgage'),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Tile: Budget ─────────────────────────────────────────────────────────

  Widget _centerTileBudget({
    required Key key,
    required String title,
    required num total,
    required Color color,
    required String currency,
  }) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        _amountHeader(title, total, currency),
        SizedBox(height: 10.h),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInteractiveTag(
                  label: "Savings Periodic",
                  backgroundColor: periodicClicked
                      ? const Color(0xffD2D2D2)
                      : const Color(0xffB71922),
                  value: _periodicSavings,
                  currency: currency,
                  isClicked: periodicClicked,
                  onTap: () => toggleBudgetClick('periodic'),
                ),
                SizedBox(width: 8.w),
                _buildInteractiveTag(
                  label: "Education",
                  backgroundColor: educationClicked
                      ? const Color(0xffD2D2D2)
                      : const Color(0xffB71922),
                  value: _education,
                  currency: currency,
                  isClicked: educationClicked,
                  onTap: () => toggleBudgetClick('education'),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInteractiveTag(
                  label: "Expenditure",
                  backgroundColor: expenditureClicked
                      ? const Color(0xffD2D2D2)
                      : const Color(0xffB71922),
                  value: _expenditure,
                  currency: currency,
                  isClicked: expenditureClicked,
                  onTap: () => toggleBudgetClick('expenditure'),
                ),
                SizedBox(width: 8.w),
                _buildInteractiveTag(
                  label: "Discretionary",
                  backgroundColor: discretionaryClicked
                      ? const Color(0xffD2D2D2)
                      : const Color(0xffB71922),
                  value: _discretionary,
                  currency: currency,
                  isClicked: discretionaryClicked,
                  onTap: () => toggleBudgetClick('discretionary'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ─── Tile: Income ─────────────────────────────────────────────────────────

  Widget _centerTileIncome({
    required Key key,
    required String title,
    required num total,
    required Color color,
    required String currency,
  }) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 8.h),
        _amountHeader(title, total, currency),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildInteractiveTag(
              label: "Non-Portfolio",
              backgroundColor: nonPortfolioIncomeClicked
                  ? const Color(0xffD2D2D2)
                  : const Color(0xffE08B1C),
              value: _nonPortfolio,
              currency: currency,
              isClicked: nonPortfolioIncomeClicked,
              onTap: () => toggleIncomeClick('non-portfolio'),
            ),
            SizedBox(width: 8.w),
            _buildInteractiveTag(
              label: "Portfolio",
              backgroundColor: portfolioIncomeClicked
                  ? const Color(0xffD2D2D2)
                  : const Color(0xffE08B1C),
              value: _portfolio,
              currency: currency,
              isClicked: portfolioIncomeClicked,
              onTap: () => toggleIncomeClick('portfolio'),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Shared tag widget ────────────────────────────────────────────────────

  Widget _buildInteractiveTag({
    required String label,
    required Color backgroundColor,
    required num value,
    required String currency,
    required bool isClicked,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: backgroundColor,
        ),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: isClicked ? 0.95 : 1.0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: 1.0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isClicked) ...[
                  SvgPicture.asset(
                    'assets/wheel_segments/check-circle.svg',
                    width: 16.w,
                    height: 16.h,
                    color: Colors.white,
                  ),
                  SizedBox(width: 5.w),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: isClicked ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Icon position helper ─────────────────────────────────────────────────

  Offset _getIconPosition(int index, double wheelSize) {
    final center = wheelSize / 2;
    final arcRadius = wheelSize / 2 - 2;
    final iconSize = 24.w;

    final startAngle = -pi / 2 + (index * pi / 2) - 0.85;
    const sweep = 0.22;
    final middleAngle = startAngle + (sweep / 2);

    final x = center + arcRadius * cos(middleAngle);
    final y = center + arcRadius * sin(middleAngle);

    double ox = 0, oy = 0;
    switch (index) {
      case 0:
        ox = -1;
        oy = 1;
        break;
      case 1:
        ox = -2;
        oy = -2;
        break;
      case 2:
        ox = 2;
        oy = -2;
        break;
      case 3:
        ox = 0;
        oy = 0;
        break;
    }

    return Offset(x - (iconSize / 2) + ox, y - (iconSize / 2) + oy);
  }
}
