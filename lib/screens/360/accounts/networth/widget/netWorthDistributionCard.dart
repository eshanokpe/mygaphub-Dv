import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NetWorthDistributionCard extends StatelessWidget {
  final Map<String, dynamic> netDetail;

  const NetWorthDistributionCard({super.key, required this.netDetail});

  // ✅ FIX: each label now maps to a [topColor, bottomColor] pair for the
  // gradient, instead of a single Color (Color() only accepts one ARGB int,
  // it can't take two color values like the original had).
  static const Map<String, List<Color>> _barGradients = {
    'Assets': [Color(0xFF134EB2), Color(0xFF0D2D60)],
    'Liabilities': [Color(0xFFC61A24), Color(0xFF6A1116)],
    'Pensions': [Color(0xFFF6981E), Color(0xFF825212)],
    'Home Equity': [Color(0xFF266C26), Color(0xFF173C17)],
  };

  // Used for the legend dot, which only needs a single solid color —
  // the top (lighter/brighter) shade of each gradient reads best there.
  Color _dotColorFor(String label) =>
      _barGradients[label]?.first ?? Colors.grey;

  /// Splits a number into "1,234" and ".56" so the decimals can be
  /// rendered smaller/lighter, matching the reference design.
  (String whole, String decimals) _splitAmount(num value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final wholePart = parts[0].replaceAll('-', '');
    final withCommas = wholePart.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return (withCommas, '.${parts[1]}');
  }

  @override
  Widget build(BuildContext context) {
    final providers = context.watch<Providers>();
    final List<String> labels =
        (netDetail['labels'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final List<num> values =
        (netDetail['values'] as List?)?.map((e) => (e as num)).toList() ?? [];

    final symbol = providers.snapshotmodel.currency;

    final num maxValue = values.isEmpty
        ? 1
        : values.reduce((a, b) => a > b ? a : b).clamp(1, double.infinity);

    const double chartHeight = 180;
    const double minBarHeight = 24; // keeps zero-value bars visibly present

    // How far each subsequent bar is shifted, as a fraction of bar width.
    // Lower = more overlap between bars (matches the cascading look in the UI).
    const double shiftRatio = 0.62;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Bar chart area (overlapping, cascading bars) ----
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
            child: SizedBox(
              height: chartHeight.h,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final n = labels.length;
                  if (n == 0) return const SizedBox.shrink();

                  final availableWidth = constraints.maxWidth;
                  final barWidth = availableWidth / (1 + (n - 1) * shiftRatio);
                  final shift = barWidth * shiftRatio;

                  // Build bars in original left-to-right order, but reverse
                  // the PAINT order so index 0 (first item) ends up on top,
                  // with each subsequent item layered behind it.
                  final paintOrder = List.generate(n, (i) => i).reversed;

                  return Stack(
                    children: paintOrder.map((index) {
                      final label = labels[index];
                      final value = index < values.length ? values[index] : 0;
                      final gradientColors =
                          _barGradients[label] ?? [Colors.grey, Colors.grey];
                      final ratio = (value / maxValue).clamp(0.0, 1.0);
                      final barHeight = (chartHeight * ratio).clamp(
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
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: gradientColors,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // ---- Legend rows ----
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: List.generate(labels.length, (index) {
                final label = labels[index];
                final value = index < values.length ? values[index] : 0;
                final dotColor = _dotColorFor(label);
                final (whole, decimals) = _splitAmount(value);

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          label,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$symbol$whole',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: decimals,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}
