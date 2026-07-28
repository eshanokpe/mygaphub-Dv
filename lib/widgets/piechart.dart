import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Piechart extends StatefulWidget {
  final List values;
  final List labels;
  final List? colors;
  final List percent;
  final List<List<Color>>? gradients;
  final bool doiwant;

  const Piechart({
    super.key,
    required this.values,
    required this.labels,
    this.colors,
    required this.percent,
    this.gradients,
    this.doiwant = false,
  });

  @override
  _PiechartState createState() => _PiechartState();
}

class _PiechartState extends State<Piechart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    // Safety: return empty if no data
    if (widget.labels.isEmpty ||
        widget.values.isEmpty ||
        widget.percent.isEmpty) {
      return const SizedBox(
        height: 240,
        child: Center(child: Text('No data available')),
      );
    }

    // Step 1: Deduplicate by label
    final seen = <String>{};
    final uniqueIndices = <int>[];
    for (var i = 0; i < widget.labels.length; i++) {
      final label = widget.labels[i].toString();
      if (seen.add(label)) uniqueIndices.add(i);
    }

    // ✅ Step 2: Sort unique indices by PERCENTAGE from HIGHEST to LOWEST
    uniqueIndices.sort((a, b) {
      final pctA = double.tryParse(widget.percent[a].toString()) ?? 0;
      final pctB = double.tryParse(widget.percent[b].toString()) ?? 0;
      return pctB.compareTo(pctA); // descending order
    });

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(
          color: Color.fromARGB(255, 241, 241, 241),
          width: 1.5,
        ),
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(top: 20.h),
        child: Column(
          children: [
            // Donut chart
            SizedBox(
              height: 240.h,
              child: PieChart(
                PieChartData(
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 60.r,
                  startDegreeOffset: -150,
                  sections: _buildSections(uniqueIndices),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Legend list
            Container(
              decoration: const BoxDecoration(color: Color(0xFFF7F7F7)),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: uniqueIndices.length,
                itemBuilder: (context, i) {
                  final idx = uniqueIndices[i];

                  // ✅ Safe color/gradient handling
                  final gradient =
                      widget.gradients != null && idx < widget.gradients!.length
                      ? widget.gradients![idx]
                      : null;

                  final solidColor = _getSolidColor(idx);

                  final pct =
                      double.tryParse(
                        widget.percent[idx].toString(),
                      )?.round() ??
                      0;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12.r,
                          height: 12.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: gradient != null
                                ? LinearGradient(
                                    colors: gradient,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: gradient == null ? solidColor : null,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            () {
                              final text = widget.labels[idx].toString();
                              if (text.isEmpty) return text;
                              return '${text[0].toUpperCase()}${text.substring(1)}';
                            }(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF1A1A1A),
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '$pct',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1A1A1A),
                                  fontFamily: 'Nunito',
                                ),
                              ),
                              TextSpan(
                                text: '%',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF888888),
                                  fontFamily: 'Nunito',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to safely get solid color or fallback
  Color _getSolidColor(int index) {
    const fallback = Colors.grey;
    if (widget.colors == null || widget.colors!.isEmpty) return fallback;
    try {
      final colorValue = widget.colors![index % widget.colors!.length]
          .toString();
      return Color(int.parse(colorValue));
    } catch (_) {
      return fallback;
    }
  }

  List<PieChartSectionData> _buildSections(List<int> sortedIndices) {
    return sortedIndices.map((i) {
      final fallbackColor = _getSolidColor(i);
      final gradientColors =
          (widget.gradients != null && i < widget.gradients!.length)
          ? widget.gradients![i]
          : [fallbackColor, fallbackColor];

      return PieChartSectionData(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        value: double.tryParse(widget.values[i].toString()) ?? 0.0,
        title: '',
        radius: 50.r,
      );
    }).toList();
  }
}
