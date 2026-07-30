import 'dart:math';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'wheel_painter.dart';

class WheelPainterWidget extends StatefulWidget {
  const WheelPainterWidget({super.key});

  @override
  State<WheelPainterWidget> createState() => _WheelPainterWidgetState();
}

class _WheelPainterWidgetState extends State<WheelPainterWidget> {
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

  // ─── Sub-item clicked state ───────────────────────────────────────────────
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

  // ─── Clicked subtracted amounts ───────────────────────────────────────────
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

  // ─── Current values parsed from API ──────────────────────────────────────
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

  // ─── Reads `current` field by key from an API array ──────────────────────
  num _currentFor(List<dynamic> list, String key) {
    for (final item in list) {
      final map = Map<String, dynamic>.from(item as Map);
      if (map['key'] == key) {
        final v = map['current'];
        if (v == null) return 0;
        if (v is num) return v;
        return num.tryParse(v.toString().replaceAll(',', '')) ?? 0;
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
    // Guard in case full envelope {status, data, message} was stored.
    final Map<String, dynamic> dataMap = raw.containsKey('income')
        ? Map<String, dynamic>.from(raw)
        : Map<String, dynamic>.from(raw['data'] as Map? ?? {});

    final incomeList = List<dynamic>.from(dataMap['income'] as List? ?? []);
    final liabList = List<dynamic>.from(dataMap['liabilities'] as List? ?? []);
    final assetList = List<dynamic>.from(dataMap['asset'] as List? ?? []);
    final budgetList = List<dynamic>.from(dataMap['budget'] as List? ?? []);

    setState(() {
      _investment = _currentFor(assetList, 'investment');
      _equity = _currentFor(assetList, 'equity');
      _cash = _currentFor(assetList, 'cash');
      _credit = _currentFor(liabList, 'credit');
      _mortgage = _currentFor(liabList, 'mortgage');
      _portfolio = _currentFor(incomeList, 'portfolio');
      _nonPortfolio = _currentFor(incomeList, 'non_portfolio');
      _periodicSavings = _currentFor(budgetList, 'periodic_savings');
      _education = _currentFor(budgetList, 'education');
      _expenditure = _currentFor(budgetList, 'expenditure');
      _discretionary = _currentFor(budgetList, 'discretionary');
    });

    debugPrint(
      '[WheelPainterWidget] Loaded — '
      'inv: $_investment  eq: $_equity  cash: $_cash  '
      'credit: $_credit  mortgage: $_mortgage  '
      'port: $_portfolio  nonPort: $_nonPortfolio  '
      'per: $_periodicSavings  edu: $_education  '
      'exp: $_expenditure  disc: $_discretionary',
    );
  }

  // ─── Toggle helpers ───────────────────────────────────────────────────────

  void toggleAssetTransfer(String type) {
    setState(() {
      switch (type) {
        case 'investment':
          investmentAssetClicked = !investmentAssetClicked;
          break;
        case 'homeEquity':
          homeEquityAssetClicked = !homeEquityAssetClicked;
          break;
        case 'cash':
          cashAssetClicked = !cashAssetClicked;
          break;
      }
    });
  }

  void toggleLiabilitiesClicked(String type) {
    setState(() {
      switch (type) {
        case 'credit':
          cashLiabilitiesClicked = !cashLiabilitiesClicked;
          break;
        case 'mortgage':
          mortageLiabilitiesClicked = !mortageLiabilitiesClicked;
          break;
      }
    });
  }

  void toggleIncomeClick(String type) {
    setState(() {
      switch (type) {
        case 'non-portfolio':
          nonPortfolioIncomeClicked = !nonPortfolioIncomeClicked;
          break;
        case 'portfolio':
          portfolioIncomeClicked = !portfolioIncomeClicked;
          break;
      }
    });
  }

  void toggleBudgetClick(String type) {
    setState(() {
      switch (type) {
        case 'periodic':
          periodicClicked = !periodicClicked;
          break;
        case 'education':
          educationClicked = !educationClicked;
          break;
        case 'expenditure':
          expenditureClicked = !expenditureClicked;
          break;
        case 'discretionary':
          discretionaryClicked = !discretionaryClicked;
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

  // ─── Safe number formatter — takes num, no context.watch ─────────────────
  String _formatNumber(num value) {
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

    // ── Totals ───────────────────────────────────────────────────────────────

    // ── Totals ───────────────────────────────────────────────────────────────
    final inv0 = (invTick0 && !investmentAssetClicked) ? _investment : 0;
    final eq0 = (equTick0 && !homeEquityAssetClicked) ? _equity : 0;
    final sav0 = (savTick0 && !cashAssetClicked) ? _cash : 0;
    final num assetTotal0 = inv0 + eq0 + sav0;

    final cre0 = (creTick0 && !cashLiabilitiesClicked) ? _credit : 0;
    final mort0 = (mortTick0 && !mortageLiabilitiesClicked) ? _mortgage : 0;
    final num liabilityTotal0 = cre0 + mort0;

    final nonP0 = (npTick0 && !nonPortfolioIncomeClicked) ? _nonPortfolio : 0;
    final port0 = (portTick0 && !portfolioIncomeClicked) ? _portfolio : 0;
    final num incomeTotal0 = nonP0 + port0;

    final per0 = (perTick0 && !periodicClicked) ? _periodicSavings : 0;
    final edu0 = (eduTick0 && !educationClicked) ? _education : 0;
    final exp0 = (expenTick0 && !expenditureClicked) ? _expenditure : 0;
    final disc0 = (discTick0 && !discretionaryClicked) ? _discretionary : 0;
    final num budget0 = per0 + edu0 + exp0 + disc0;

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
                      // AbsorbPointer()
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
    final formatted = _formatNumber(total);
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
                _tag(
                  label: "Investments",
                  activeColor: const Color(0xff256825),
                  value: _investment,
                  isClicked: investmentAssetClicked,
                  currency: currency,
                  onTap: () => toggleAssetTransfer('investment'),
                ),
                SizedBox(width: 8.w),
                _tag(
                  label: "Home Equity",
                  activeColor: const Color(0xff256825),
                  value: _equity,
                  isClicked: homeEquityAssetClicked,
                  currency: currency,
                  onTap: () => toggleAssetTransfer('homeEquity'),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            _tag(
              label: "Cash",
              activeColor: const Color(0xff256825),
              value: _cash,
              isClicked: cashAssetClicked,
              currency: currency,
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
            _tag(
              label: "Credit",
              activeColor: const Color(0xff530182),
              value: _credit,
              isClicked: cashLiabilitiesClicked,
              currency: currency,
              onTap: () => toggleLiabilitiesClicked('credit'),
            ),
            SizedBox(width: 8.w),
            _tag(
              label: "Mortgage",
              activeColor: const Color(0xff530182),
              value: _mortgage,
              isClicked: mortageLiabilitiesClicked,
              currency: currency,
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
                _tag(
                  label: "Savings Periodic",
                  activeColor: const Color(0xffB71922),
                  value: _periodicSavings,
                  isClicked: periodicClicked,
                  currency: currency,
                  onTap: () => toggleBudgetClick('periodic'),
                ),
                SizedBox(width: 8.w),
                _tag(
                  label: "Education",
                  activeColor: const Color(0xffB71922),
                  value: _education,
                  isClicked: educationClicked,
                  currency: currency,
                  onTap: () => toggleBudgetClick('education'),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _tag(
                  label: "Expenditure",
                  activeColor: const Color(0xffB71922),
                  value: _expenditure,
                  isClicked: expenditureClicked,
                  currency: currency,
                  onTap: () => toggleBudgetClick('expenditure'),
                ),
                SizedBox(width: 8.w),
                _tag(
                  label: "Discretionary",
                  activeColor: const Color(0xffB71922),
                  value: _discretionary,
                  isClicked: discretionaryClicked,
                  currency: currency,
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
            _tag(
              label: "Non-Portfolio",
              activeColor: const Color(0xffE08B1C),
              value: _nonPortfolio,
              isClicked: nonPortfolioIncomeClicked,
              currency: currency,
              onTap: () => toggleIncomeClick('non-portfolio'),
            ),
            SizedBox(width: 8.w),
            _tag(
              label: "Portfolio",
              activeColor: const Color(0xffE08B1C),
              value: _portfolio,
              isClicked: portfolioIncomeClicked,
              currency: currency,
              onTap: () => toggleIncomeClick('portfolio'),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Tag widget ───────────────────────────────────────────────────────────
  // isClicked = true  → grey background, no icon, bold text (item removed from total)
  // isClicked = false → activeColor background, check icon shown

  Widget _tag({
    required String label,
    required Color activeColor,
    required num value,
    required bool isClicked,
    required String currency,
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
          // ── KEY FIX: colour driven by isClicked directly ──────────────
          color: isClicked ? const Color(0xffD2D2D2) : activeColor,
        ),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: isClicked ? 0.95 : 1.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── KEY FIX: icon hidden when isClicked == true ───────────
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
                  // ── bolder when clicked to signal it's deducted ───────
                  fontWeight: isClicked ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
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
