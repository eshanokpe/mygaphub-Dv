// expenditure_distribution_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Category gradients — matched to the bar chart in the screenshot
// ─────────────────────────────────────────────────────────────────────────────
const List<LinearGradient> _kCategoryGradients = [
  LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF134EB2), Color(0xFF0D2D60)],
  ),
  LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFC61A24), Color(0xFF6A1116)],
  ),
  LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF6981E), Color(0xFF825212)],
  ),
  LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF266C26), Color(0xFF173C17)],
  ),
  LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7A009A), Color(0xFF420953)],
  ),
];

LinearGradient _gradientForIndex(int index) =>
    _kCategoryGradients[index % _kCategoryGradients.length];

// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC ENTRY POINT
// ─────────────────────────────────────────────────────────────────────────────
class ExpenditureDistributionCard extends StatelessWidget {
  final Map? expenditureData;
  final String? currency;
  final VoidCallback? onSetBudgetTap;

  const ExpenditureDistributionCard({
    super.key,
    required this.expenditureData,
    required this.currency,
    this.onSetBudgetTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasData = expenditureData != null && expenditureData!.isNotEmpty;

    return hasData
        ? _ExpenditureFilledState(
            expenditureData: expenditureData!,
            currency: currency,
            onSetBudgetTap: onSetBudgetTap,
          )
        : const _ExpenditureEmptyState();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILLED STATE
// ─────────────────────────────────────────────────────────────────────────────
class _ExpenditureFilledState extends StatelessWidget {
  final Map expenditureData;
  final String? currency;
  final VoidCallback? onSetBudgetTap;

  const _ExpenditureFilledState({
    required this.expenditureData,
    required this.currency,
    this.onSetBudgetTap,
  });

  // ── Parse parallel label/value lists from API ────────────────────────────
  List<_ExpenditureItem> _parseItems() {
    final List<dynamic> labels = expenditureData["labels"] is List
        ? expenditureData["labels"] as List<dynamic>
        : [];
    final List<dynamic> values = expenditureData["values"] is List
        ? expenditureData["values"] as List<dynamic>
        : [];

    return labels.asMap().entries.map((entry) {
      final int i = entry.key;
      final String raw = entry.value.toString();

      // ── Humanise label ───────────────────────────────────────────────────
      final String label = raw == 'debt_repayment'
          ? 'Debt Repayment'
          : raw.isEmpty
          ? raw
          : '${raw[0].toUpperCase()}${raw.substring(1)}';

      final num amount = i < values.length
          ? num.tryParse(values[i].toString()) ?? 0
          : 0;

      return _ExpenditureItem(
        label: label,
        amount: amount,
        gradient: _gradientForIndex(i),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<_ExpenditureItem> items = _parseItems();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Title ────────────────────────────────────────────────
        Text(
          "Your average cost of living".toUpperCase(),
          style: GoogleFonts.nunitoSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),

        // ── Main Cost-of-Living Card ─────────────────────────────────────
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xffF7F7F7),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Category Rows ──────────────────────────────────────────
              ...items.asMap().entries.map((entry) {
                final int index = entry.key;
                final _ExpenditureItem item = entry.value;
                final int whole = item.amount.toInt();
                final String decimal = item.amount
                    .toStringAsFixed(2)
                    .split('.')
                    .last;

                return _CategoryRow(
                  label: item.label,
                  whole: whole,
                  decimal: decimal,
                  currency: currency,
                  showDivider: index != items.length - 1,
                );
              }),

              // ── Set Budget Button ──────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: InkWell(
                  onTap: onSetBudgetTap,
                  borderRadius: BorderRadius.circular(50.r),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 18.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.red, size: 20.sp),
                        SizedBox(width: 10.w),
                        Text(
                          "Set Budget in SEED",
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 24.h),

        // ── Distribution Chart Card (NEW) ────────────────────────────────
        _ExpenditureDistributionChartCard(items: items, currency: currency),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────
class _ExpenditureItem {
  final String label;
  final num amount;
  final LinearGradient gradient;

  const _ExpenditureItem({
    required this.label,
    required this.amount,
    required this.gradient,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// DISTRIBUTION CHART CARD  ← NEW WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class _ExpenditureDistributionChartCard extends StatelessWidget {
  final List<_ExpenditureItem> items;
  final String? currency;

  const _ExpenditureDistributionChartCard({
    required this.items,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Title ────────────────────────────────────────────────
        Text(
          "COST OF LIVING DISTRIBUTION",
          style: GoogleFonts.nunitoSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xff808080),
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 12.h),

        // ── Card ─────────────────────────────────────────────────────────
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xffEEEEEE), width: 0.8),
          ),
          child: Column(
            children: [
              // ── Bar Chart ──────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
                child: _BarChart(items: items),
              ),
              // ── Legend Rows ────────────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xffF7F7F7),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r),
                  ),
                  border: Border.all(
                    color: const Color(0xffEEEEEE),
                    width: 0.7,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Column(
                    children: items.asMap().entries.map((entry) {
                      final int index = entry.key;
                      final _ExpenditureItem item = entry.value;
                      final int whole = item.amount.toInt();
                      final String decimal = item.amount
                          .toStringAsFixed(2)
                          .split('.')
                          .last;
                      final bool isLast = index == items.length - 1;

                      return _LegendRow(
                        item: item,
                        whole: whole,
                        decimal: decimal,
                        currency: currency,
                        showDivider: !isLast,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BAR CHART
// ─────────────────────────────────────────────────────────────────────────────
class _BarChart extends StatelessWidget {
  final List<_ExpenditureItem> items;

  const _BarChart({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    // ── Find the max value to normalise bar heights ──────────────────────
    final num maxValue = items
        .map((e) => e.amount)
        .reduce((a, b) => a > b ? a : b);

    // ── Chart height (tallest bar) ───────────────────────────────────────
    const double chartHeight = 160;
    const double minBarHeight = 24;
    const double shiftRatio = 0.62;

    return SizedBox(
      height: chartHeight.h,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final int itemCount = items.length;
          final double availableWidth = constraints.maxWidth;
          final double barWidth =
              availableWidth / (1 + (itemCount - 1) * shiftRatio);
          final double shift = barWidth * shiftRatio;

          final List<int> paintOrder = List.generate(
            itemCount,
            (index) => index,
          ).reversed.toList();

          return Stack(
            children: paintOrder.map((index) {
              final _ExpenditureItem item = items[index];
              final double ratio = maxValue > 0
                  ? (item.amount / maxValue).clamp(0.0, 1.0).toDouble()
                  : 0;
              final double barHeight = (chartHeight * ratio).clamp(
                minBarHeight,
                chartHeight,
              );

              return Positioned(
                left: shift * index,
                bottom: 0,
                child: Container(
                  width: barWidth,
                  height: barHeight.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                    gradient: item.gradient,
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LEGEND ROW  (coloured dot · label · amount)
// ─────────────────────────────────────────────────────────────────────────────
class _LegendRow extends StatelessWidget {
  final _ExpenditureItem item;
  final int whole;
  final String decimal;
  final String? currency;
  final bool showDivider;

  const _LegendRow({
    required this.item,
    required this.whole,
    required this.decimal,
    required this.currency,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            children: [
              // ── Coloured dot ──────────────────────────────────────────
              Container(
                width: 12.w,
                height: 12.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: item.gradient.colors,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 10.w),

              // ── Label ─────────────────────────────────────────────────
              Expanded(
                child: Text(
                  item.label,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),

              // ── Amount ────────────────────────────────────────────────
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          "$currency${whole.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: ".$decimal",
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff777777),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Divider between legend rows ──────────────────────────────────
        // if (showDivider)
        // Divider(height: 0.5, thickness: 0.5, color: const Color(0xffEEEEEE)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SINGLE CATEGORY ROW  (used inside the cost-of-living card)
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryRow extends StatelessWidget {
  final String label;
  final int whole;
  final String decimal;
  final String? currency;
  final bool showDivider;

  const _CategoryRow({
    required this.label,
    required this.whole,
    required this.decimal,
    required this.currency,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.nunitoSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff777777),
                ),
              ),
              SizedBox(height: 6.h),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          "$currency${whole.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                      style: GoogleFonts.nunitoSans(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: ".$decimal",
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff777777),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: const Color(0xffE3E3E3),
            indent: 16.w,
            endIndent: 16.w,
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
class _ExpenditureEmptyState extends StatelessWidget {
  const _ExpenditureEmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "YOUR AVERAGE COST OF LIVING",
          style: GoogleFonts.nunitoSans(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xffEEEEEE), width: 0.7),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 170.h,
                child: Center(
                  child: Text(
                    'Add your expenditure to view distribution',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14.sp,
                      color: const Color(0xff808080),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xffF7F7F7),
                  border: Border.all(
                    color: const Color(0xffEEEEEE),
                    width: 0.7,
                  ),
                ),
                child: const Column(
                  children: [
                    _EmptyAssetRow(label: 'Housing'),
                    _EmptyAssetRow(label: 'Transport'),
                    _EmptyAssetRow(label: 'Food'),
                    _EmptyAssetRow(label: 'Utilities'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY ASSET ROW
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyAssetRow extends StatelessWidget {
  final String label;
  const _EmptyAssetRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.h,
            decoration: const BoxDecoration(
              color: Color(0xFFCECECE),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '0',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: '%',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff808080),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
