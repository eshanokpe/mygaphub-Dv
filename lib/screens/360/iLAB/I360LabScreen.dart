import 'dart:math';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/customBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'widget/iLab_difference_card.dart';
import 'threesixty_category_bottomSheet.dart';
import 'widget/wheel_painter_target_position.dart';
import 'widget/wheel_painter_widget.dart';

class I360LabScreen extends StatefulWidget {
  const I360LabScreen({super.key});

  @override
  State<I360LabScreen> createState() => _I360LabScreenState();
}

// ─── Strongly-typed model ────────────────────────────────────────────────────

class ILabItem {
  final String key;
  final String label;
  final num current;
  final num? target;

  const ILabItem({
    required this.key,
    required this.label,
    required this.current,
    this.target,
  });

  factory ILabItem.fromMap(Map<dynamic, dynamic> map) {
    return ILabItem(
      key: map['key']?.toString() ?? '',
      label: map['label']?.toString() ?? '',
      current: num.tryParse(map['current']?.toString() ?? '0') ?? 0,
      target: map['target'] != null
          ? num.tryParse(map['target'].toString())
          : null,
    );
  }
}

class ILabData {
  final List<ILabItem> income;
  final List<ILabItem> liabilities;
  final List<ILabItem> asset;
  final List<ILabItem> budget;

  const ILabData({
    required this.income,
    required this.liabilities,
    required this.asset,
    required this.budget,
  });

  factory ILabData.fromMap(Map<dynamic, dynamic> raw) {
    List<ILabItem> parse(String key) {
      final list = raw[key];
      if (list == null || list is! List) return [];
      return list.map((e) => ILabItem.fromMap(e as Map)).toList();
    }

    return ILabData(
      income: parse('income'),
      liabilities: parse('liabilities'),
      asset: parse('asset'),
      budget: parse('budget'),
    );
  }

  // ── Convenience getters ──────────────────────────────────────────────────

  ILabItem? _find(List<ILabItem> list, String key) => list
      .cast<ILabItem?>()
      .firstWhere((e) => e?.key == key, orElse: () => null);

  // Income
  num get portfolioIncome => _find(income, 'portfolio')?.current ?? 0;
  num get nonPortfolioIncome => _find(income, 'non_portfolio')?.current ?? 0;

  // Liabilities
  num get creditLiability => _find(liabilities, 'credit')?.current ?? 0;
  num get mortgageLiability => _find(liabilities, 'mortgage')?.current ?? 0;

  // Assets
  num get investmentAsset => _find(asset, 'investment')?.current ?? 0;
  num get equityAsset => _find(asset, 'equity')?.current ?? 0;
  num get cashAsset => _find(asset, 'cash')?.current ?? 0;

  // Budget
  num get periodicSavings => _find(budget, 'periodic_savings')?.current ?? 0;
  num get educationBudget => _find(budget, 'education')?.current ?? 0;
  num get expenditure => _find(budget, 'expenditure')?.current ?? 0;
  num get discretionary => _find(budget, 'discretionary')?.current ?? 0;

  /// All items flattened in API order: income → liabilities → asset → budget
  List<ILabItem> get allItems => [
    ...income,
    ...liabilities,
    ...asset,
    ...budget,
  ];
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class _I360LabScreenState extends State<I360LabScreen> {
  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final raw = context.watch<Providers>().ilabdata;

    if (raw.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final Map<dynamic, dynamic> dataMap = (raw['income'] != null)
        ? raw
        : (raw['data'] as Map? ?? raw);

    final _ = ILabData.fromMap(dataMap);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: ListView(
            children: [
              // ── Header ───────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios_new, size: 18.w),
                  ),
                  InkWell(
                    onTap: _showCategorySheet,
                    child: Image.asset(
                      'assets/wheel_segments/pencil-alt.png',
                      width: 24.w,
                      height: 24.h,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // ── Title ────────────────────────────────────────────────────
              Center(
                child: Text(
                  "360 iLAB",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Center(
                child: Text(
                  "Play with your iLAB Clock",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xff393737),
                  ),
                ),
              ),

              // ── Summary cards ─────────────────────────────────────────────
              // _ILabSummaryGrid(data: _ilabData),
              SizedBox(height: 30.h),

              // ── Current Position Wheel ────────────────────────────────────
              const WheelPainterWidget(),
              SizedBox(height: 20.h),

              _PositionButton(
                year: DateTime.now().year,
                label: 'Current Position',
                colors: const [Color(0xFF4A5668), Color(0xFF7D8898)],
                onTap: () => _showInfoSheet('Current Position'),
              ),

              SizedBox(height: 40.h),
              const ILabDifferenceCard(),
              SizedBox(height: 20.h),

              // ── Target Position Wheel ─────────────────────────────────────
              const WheelPainterTargetPosition(),
              SizedBox(height: 40.h),

              _PositionButton(
                year: DateTime.now().year,
                label: 'Target Position',
                colors: const [Color(0xFF333E4F), Color(0xFF677283)],
                onTap: () => _showInfoSheet('Target Position'),
              ),

              SizedBox(height: 40.h),

              // ── Edit Target button ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: Material(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20.r),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.r),
                    onTap: _showCategorySheet,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/wheel_segments/pencil-alt.png',
                            color: Colors.white,
                            width: 24.w,
                            height: 24.h,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Edit Target',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 70.h),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  void _showCategorySheet() {
    ThreesixtyCategoryBottomSheet(
      context,
      context.read<Providers>().ilabdata,
    ).show();
  }

  void _showInfoSheet(String title) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(56),
          topRight: Radius.circular(56),
        ),
      ),
      builder: (_) => CustomBottomSheet(
        title: title,
        content:
            'Lorem ipsum dolor sit amet consectetur. Nunc pellentesque odio '
            'nibh porttitor sit id non. Commodo a rhoncus scelerisque tincidunt '
            'in mattis placerat.',
      ),
    );
  }
}

// ─── Summary grid widget ─────────────────────────────────────────────────────

// ignore: unused_element
class _ILabSummaryGrid extends StatelessWidget {
  final ILabData data;

  const _ILabSummaryGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final sections = [
      _SummarySection(
        title: 'Income',
        items: [
          _SummaryRow('Portfolio', data.portfolioIncome),
          _SummaryRow('Non-Portfolio', data.nonPortfolioIncome),
        ],
      ),
      _SummarySection(
        title: 'Liabilities',
        items: [
          _SummaryRow('Credit', data.creditLiability),
          _SummaryRow('Mortgage', data.mortgageLiability),
        ],
      ),
      _SummarySection(
        title: 'Assets',
        items: [
          _SummaryRow('Investments', data.investmentAsset),
          _SummaryRow('Home Equity', data.equityAsset),
          _SummaryRow('Cash', data.cashAsset),
        ],
      ),
      _SummarySection(
        title: 'Budget',
        items: [
          _SummaryRow('Savings Periodic', data.periodicSavings),
          _SummaryRow('Education', data.educationBudget),
          _SummaryRow('Expenditure', data.expenditure),
          _SummaryRow('Discretionary', data.discretionary),
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections
          .map(
            (s) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _buildSection(context, s),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSection(BuildContext context, _SummarySection section) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Text(
              section.title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
            ),
          ),
          // Rows
          ...section.items.map(
            (row) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    row.label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF555555),
                    ),
                  ),
                  Text(
                    row.value > 0 ? row.value.toStringAsFixed(0) : '—',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: row.value > 0
                          ? Colors.black
                          : const Color(0xFFAAAAAA),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummarySection {
  final String title;
  final List<_SummaryRow> items;
  const _SummarySection({required this.title, required this.items});
}

class _SummaryRow {
  final String label;
  final num value;
  const _SummaryRow(this.label, this.value);
}

// ─── Reusable position button ─────────────────────────────────────────────────

class _PositionButton extends StatelessWidget {
  final int year;
  final String label;
  final List<Color> colors;
  final VoidCallback onTap;

  const _PositionButton({
    required this.year,
    required this.label,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(56.r),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
              stops: const [0.2033, 1.0],
              transform: const GradientRotation(182 * pi / 180),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x120F1828),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/wheel_segments/information-circle.svg'),
              SizedBox(width: 8.w),
              Text(
                '$year $label',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
