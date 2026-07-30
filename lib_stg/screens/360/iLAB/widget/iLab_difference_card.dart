import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ILabDifferenceCard extends StatefulWidget {
  const ILabDifferenceCard({super.key});

  @override
  State<ILabDifferenceCard> createState() => _ILabDifferenceCardState();
}

class _ILabDifferenceCardState extends State<ILabDifferenceCard> {
  int selectedIndex = -1;

  Map<dynamic, dynamic>? _lastRaw;
  bool _scheduledReload = false;

  // ─── Parsed current & target values per category ─────────────────────────
  // Income
  num nonP0 = 0, nonP1 = 0; // non_portfolio
  num port0 = 0, port1 = 0; // portfolio

  // Liabilities
  num credit0 = 0, credit1 = 0;
  num mortgage0 = 0, mortgage1 = 0;

  // Asset
  num investment0 = 0, investment1 = 0;
  num equity0 = 0, equity1 = 0;
  num cash0 = 0, cash1 = 0;

  // Budget
  num periodic0 = 0, periodic1 = 0;
  num education0 = 0, education1 = 0;
  num expenditure0 = 0, expenditure1 = 0;
  num discretionary0 = 0, discretionary1 = 0;

  // ─── Toggle booleans ─────────────────────────────────────────────────────
  bool invTick0 = true, invTick1 = true;
  bool equTick0 = true, equTick1 = true;
  bool savTick0 = true, savTick1 = true;
  bool creTick0 = true, creTick1 = true;
  bool mortTick0 = true, mortTick1 = true;
  bool npTick0 = true, npTick1 = true;
  bool portTick0 = true, portTick1 = true;
  bool eduTick0 = true, eduTick1 = true;
  bool perTick0 = true, perTick1 = true;
  bool discTick0 = true, discTick1 = true;
  bool expenTick0 = true, expenTick1 = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadData();
    });
  }

  // ─── Reads current/target from an array by key ───────────────────────────
  // Response array items: { key, label, current, target }
  num _fromList(List<dynamic> list, String key, String field) {
    for (final item in list) {
      final m = Map<String, dynamic>.from(item as Map);
      if (m['key'] == key) {
        final v = m[field];
        if (v == null) return 0;
        if (v is num) return v;
        return num.tryParse(v.toString().replaceAll(',', '')) ?? 0;
      }
    }
    return 0;
  }

  void _loadData() {
    final raw = context.read<Providers>().ilabdata;
    if (raw.isEmpty) return;

    // ilabdata is the inner data map directly:
    // { income: [...], liabilities: [...], asset: [...], budget: [...] }
    final dataMap = raw.containsKey('data')
        ? Map<String, dynamic>.from(raw['data'] as Map? ?? {})
        : Map<String, dynamic>.from(raw);

    final incomeList = List<dynamic>.from(dataMap['income'] as List? ?? []);
    final liabList = List<dynamic>.from(dataMap['liabilities'] as List? ?? []);
    final assetList = List<dynamic>.from(dataMap['asset'] as List? ?? []);
    final budgetList = List<dynamic>.from(dataMap['budget'] as List? ?? []);

    setState(() {
      // Income
      nonP0 = _fromList(incomeList, 'non_portfolio', 'current');
      nonP1 = _fromList(incomeList, 'non_portfolio', 'target');
      port0 = _fromList(incomeList, 'portfolio', 'current');
      port1 = _fromList(incomeList, 'portfolio', 'target');

      // Liabilities
      credit0 = _fromList(liabList, 'credit', 'current');
      credit1 = _fromList(liabList, 'credit', 'target');
      mortgage0 = _fromList(liabList, 'mortgage', 'current');
      mortgage1 = _fromList(liabList, 'mortgage', 'target');

      // Asset
      investment0 = _fromList(assetList, 'investment', 'current');
      investment1 = _fromList(assetList, 'investment', 'target');
      equity0 = _fromList(assetList, 'equity', 'current');
      equity1 = _fromList(assetList, 'equity', 'target');
      cash0 = _fromList(assetList, 'cash', 'current');
      cash1 = _fromList(assetList, 'cash', 'target');

      // Budget
      periodic0 = _fromList(budgetList, 'periodic_savings', 'current');
      periodic1 = _fromList(budgetList, 'periodic_savings', 'target');
      education0 = _fromList(budgetList, 'education', 'current');
      education1 = _fromList(budgetList, 'education', 'target');
      expenditure0 = _fromList(budgetList, 'expenditure', 'current');
      expenditure1 = _fromList(budgetList, 'expenditure', 'target');
      discretionary0 = _fromList(budgetList, 'discretionary', 'current');
      discretionary1 = _fromList(budgetList, 'discretionary', 'target');

      debugPrint(
        '[ILabDifferenceCard] income     nonP: $nonP0 → $nonP1  port: $port0 → $port1',
      );
      debugPrint(
        '[ILabDifferenceCard] liab       credit: $credit0 → $credit1  mortgage: $mortgage0 → $mortgage1',
      );
      debugPrint(
        '[ILabDifferenceCard] asset      inv: $investment0 → $investment1  eq: $equity0 → $equity1  cash: $cash0 → $cash1',
      );
      debugPrint(
        '[ILabDifferenceCard] budget     per: $periodic0 → $periodic1  edu: $education0 → $education1  exp: $expenditure0 → $expenditure1  disc: $discretionary0 → $discretionary1',
      );
    });
  }

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

    // ── Apply toggles ───────────────────────────────────────────────────────
    final effNonP0 = npTick0 ? nonP0 : 0;
    final effNonP1 = npTick1 ? nonP1 : 0;
    final effPort0 = portTick0 ? port0 : 0;
    final effPort1 = portTick1 ? port1 : 0;

    final effCredit0 = creTick0 ? credit0 : 0;
    final effCredit1 = creTick1 ? credit1 : 0;
    final effMortgage0 = mortTick0 ? mortgage0 : 0;
    final effMortgage1 = mortTick1 ? mortgage1 : 0;

    final effInv0 = invTick0 ? investment0 : 0;
    final effInv1 = invTick1 ? investment1 : 0;
    final effEq0 = equTick0 ? equity0 : 0;
    final effEq1 = equTick1 ? equity1 : 0;
    final effCash0 = savTick0 ? cash0 : 0;
    final effCash1 = savTick1 ? cash1 : 0;

    final effPer0 = perTick0 ? periodic0 : 0;
    final effPer1 = perTick1 ? periodic1 : 0;
    final effEdu0 = eduTick0 ? education0 : 0;
    final effEdu1 = eduTick1 ? education1 : 0;
    final effExp0 = expenTick0 ? expenditure0 : 0;
    final effExp1 = expenTick1 ? expenditure1 : 0;
    final effDisc0 = discTick0 ? discretionary0 : 0;
    final effDisc1 = discTick1 ? discretionary1 : 0;

    // ── Totals ───────────────────────────────────────────────────────────────
    final liabilityTotal0 = effCredit0 + effMortgage0;
    final liabilityTotal1 = effCredit1 + effMortgage1;
    final assetTotal0 = effInv0 + effEq0 + effCash0;
    final assetTotal1 = effInv1 + effEq1 + effCash1;
    final budget0 = effPer0 + effEdu0 + effExp0 + effDisc0;
    final budget1 = effPer1 + effEdu1 + effExp1 + effDisc1;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "iLAB",
                style: TextStyle(
                  color: const Color(0xff979797),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Difference",
                style: TextStyle(
                  color: const Color(0xff979797),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Income (NPi) ───────────────────────────────────────────────────
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 38.w,
              height: 38.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  "assets/wheel_segments/income_icon.png",
                  width: 26.w,
                ),
              ),
            ),
            title: Text(
              "Income (NPi)",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            trailing: _buildFormattedAmount(
              _formatNumber((effNonP0 - effNonP1).toString()),
              isNegative: (effNonP0 - effNonP1) <= 0,
              color: (effNonP0 - effNonP1) <= 0
                  ? AppColors.primaryColor
                  : AppColors.greenColor,
            ),
          ),
          _divider(),

          // ── Income (APi) ───────────────────────────────────────────────────
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Transform.translate(
              offset: Offset(10, -10.h),
              child: SizedBox(
                width: 30.w,
                height: 30.h,
                child: Center(
                  child: Image.asset(
                    "assets/wheel_segments/dotted_line.png",
                    width: 20.w,
                  ),
                ),
              ),
            ),
            title: Padding(
              padding: EdgeInsets.only(left: 7.w),
              child: Text(
                "Income (APi)",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
            trailing: _buildFormattedAmount(
              _formatNumber((effPort0 - effPort1).toString()),
              isNegative: (effPort0 - effPort1) <= 0,
              color: (effPort0 - effPort1) <= 0
                  ? AppColors.primaryColor
                  : AppColors.greenColor,
            ),
          ),
          _divider(),

          // ── Liabilities ────────────────────────────────────────────────────
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 38.w,
              height: 38.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  "assets/wheel_segments/liabilities_icon.png",
                  width: 26.w,
                ),
              ),
            ),
            title: Text(
              "Liabilities",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            trailing: _buildFormattedAmount(
              _formatNumber((liabilityTotal1 - liabilityTotal0).toString()),
              isNegative: (liabilityTotal1 - liabilityTotal0) <= 0,
              color: (liabilityTotal1 - liabilityTotal0) <= 0
                  ? AppColors.primaryColor
                  : AppColors.greenColor,
            ),
          ),
          _divider(),

          // ── Asset ──────────────────────────────────────────────────────────
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 38.w,
              height: 38.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  "assets/wheel_segments/assets_icon.png",
                  width: 26.w,
                ),
              ),
            ),
            title: Text(
              "Asset",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            trailing: _buildFormattedAmount(
              _formatNumber((assetTotal0 - assetTotal1).toString()),
              isNegative: (assetTotal0 - assetTotal1) <= 0,
              color: (assetTotal0 - assetTotal1) <= 0
                  ? AppColors.primaryColor
                  : AppColors.greenColor,
            ),
          ),
          _divider(),

          // ── Budget ─────────────────────────────────────────────────────────
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 38.w,
              height: 38.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  "assets/wheel_segments/expenditure_icon.png",
                  width: 26.w,
                ),
              ),
            ),
            title: Text(
              "Budget",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            trailing: _buildFormattedAmount(
              _formatNumber((budget1 - budget0).toString()),
              isNegative: (budget1 - budget0) <= 0,
              color: (budget1 - budget0) <= 0
                  ? AppColors.primaryColor
                  : AppColors.greenColor,
            ),
          ),
        ],
      ),
    );
  }

  Divider _divider() => Divider(
    color: const Color(0xffefefef),
    thickness: 1.h,
    height: 1.h,
    indent: 50.w,
    endIndent: 0.w,
  );

  String _formatNumber(String amount) {
    final String currency = context.watch<Providers>().snapshotmodel.currency;
    final String clean = amount.replaceAll(RegExp(r'[^0-9.-]'), '');
    try {
      final num value = num.parse(clean);
      final String fixed = value.toStringAsFixed(2);
      final List<String> parts = fixed.split('.');
      final String whole = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
      return '$currency$whole.${parts[1]}';
    } catch (_) {
      return amount;
    }
  }

  Widget _buildFormattedAmount(
    String amount, {
    bool isNegative = false,
    required Color color,
  }) {
    final String currency = context.watch<Providers>().snapshotmodel.currency;
    String clean = amount.replaceAll(RegExp(r'[^0-9.-]'), '');
    if (clean.startsWith('-')) clean = clean.substring(1);

    try {
      final num value = num.parse(clean);
      final String fixed = value.toStringAsFixed(2);
      final List<String> parts = fixed.split('.');
      final String whole = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );

      return RichText(
        text: TextSpan(
          children: [
            if (isNegative)
              TextSpan(
                text: '-',
                style: TextStyle(
                  fontFamily: 'NunitoSans',
                  fontSize: 14.sp,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            TextSpan(
              text: currency,
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontSize: 14.sp,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: whole,
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: 'NunitoSans',
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: '.',
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: 'NunitoSans',
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: parts[1],
              style: TextStyle(
                fontSize: 11.sp,
                fontFamily: 'NunitoSans',
                color: color,
                fontWeight: FontWeight.w700,
                textBaseline: TextBaseline.alphabetic,
              ),
            ),
          ],
        ),
      );
    } catch (_) {
      return Text(
        amount,
        style: TextStyle(
          fontSize: 13.sp,
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w700,
        ),
      );
    }
  }
}
