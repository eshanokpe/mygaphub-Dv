import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math';

class DoughnutChart extends StatelessWidget {
  final List<int> values;
  final List<String> hexColors;
  final List<String> labels;

  const DoughnutChart({
    required this.values,
    required this.hexColors,
    required this.labels,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    assert(values.length == hexColors.length);
    assert(values.length == labels.length);

    final total = values.fold(0, (sum, item) => sum + item);

    final List<ChartData> chartData = List.generate(values.length, (index) {
      final double percentage =
          total == 0 ? 0 : (values[index] / total) * 100.0;
      return ChartData(
        labels[index],
        values[index],
        Color(int.parse(hexColors[index])),
        percentage,
      );
    });

    return Center(
      child: SizedBox(
        height: 270,
        width: 270,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SfCircularChart(
              margin: EdgeInsets.zero,
              series: <CircularSeries<ChartData, String>>[
                DoughnutSeries<ChartData, String>(
                  dataSource: chartData,
                  pointColorMapper: (ChartData data, _) => data.color,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  radius: '70%',
                  innerRadius: '50%',
                  dataLabelSettings:
                      const DataLabelSettings(isVisible: false),
                  enableTooltip: false,
                ),
              ],
              tooltipBehavior: TooltipBehavior(enable: false),
            ),
            CustomPaint(
              size: const Size(270, 270),
              painter: _LabelPainter(chartData),
            ),
          ],
        ),
      ),
    );
  }
}

// Holds computed layout for one label
class _LabelLayout {
  final Offset p1;        // chart edge
  final Offset p2;        // elbow bend
  double labelY;          // mutable — adjusted during collision resolution
  final double labelX;
  final bool isRightSide;
  final String text;
  final double labelHeight;
  final double labelWidth;

  _LabelLayout({
    required this.p1,
    required this.p2,
    required this.labelY,
    required this.labelX,
    required this.isRightSide,
    required this.text,
    required this.labelHeight,
    required this.labelWidth,
  });

  // Rect of the label for overlap detection
  Rect get rect => Rect.fromLTWH(
        labelX,
        labelY - labelHeight / 2,
        labelWidth,
        labelHeight,
      );
}

class _LabelPainter extends CustomPainter {
  final List<ChartData> chartData;

  _LabelPainter(this.chartData);

  @override
  void paint(Canvas canvas, Size size) {
    final total = chartData.fold(0.0, (sum, d) => sum + d.y);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final chartRadius = size.width / 2 * 0.70;
    final elbowRadius = chartRadius + 20;
    const tailLength = 16.0;
    const labelFontSize = 10.0;
    const labelPadding = 3.0;
    const minGap = 2.0; // minimum vertical gap between labels

    // ── 1. Measure text with a TextPainter ──────────────────────────────────
    final tp = TextPainter(
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    // ── 2. Compute raw (pre-collision) layout for every visible label ────────
    final List<_LabelLayout> layouts = [];
    double startAngle = -pi / 2;

    for (final data in chartData) {
      final sweepAngle = (data.y / total) * 2 * pi;
      if (data.percentage < 1) {
        startAngle += sweepAngle;
        continue;
      }

      final midAngle = startAngle + sweepAngle / 2;
      final isRightSide = cos(midAngle) >= 0;

      final p1 = Offset(
        center.dx + chartRadius * cos(midAngle),
        center.dy + chartRadius * sin(midAngle),
      );
      final p2 = Offset(
        center.dx + elbowRadius * cos(midAngle),
        center.dy + elbowRadius * sin(midAngle),
      );
      final p3x = p2.dx + (isRightSide ? tailLength : -tailLength);

      final text = '${data.percentage.toStringAsFixed(0)}%';
      tp.text = TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: labelFontSize,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      );
      tp.layout();

      final labelX = isRightSide
          ? p3x + labelPadding
          : p3x - tp.width - labelPadding;

      layouts.add(_LabelLayout(
        p1: p1,
        p2: p2,
        labelY: p2.dy, // raw Y = elbow Y
        labelX: labelX,
        isRightSide: isRightSide,
        text: text,
        labelHeight: tp.height,
        labelWidth: tp.width,
      ));

      startAngle += sweepAngle;
    }

    // ── 3. Collision resolution — separate left & right independently ────────
    _resolveCollisions(
      layouts.where((l) => l.isRightSide).toList(),
      minGap,
    );
    _resolveCollisions(
      layouts.where((l) => !l.isRightSide).toList(),
      minGap,
    );

    // ── 4. Draw everything ───────────────────────────────────────────────────
    final linePaint = Paint()
      ..color = const Color(0xff777777)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (final l in layouts) {
      final p3 = Offset(
        l.p2.dx + (l.isRightSide ? tailLength : -tailLength),
        l.labelY, // use resolved Y for the tail end
      );

      // Radial line: chart edge → elbow (at original elbow X, resolved Y)
      final elbowResolved = Offset(l.p2.dx, l.labelY);
      canvas.drawLine(l.p1, elbowResolved, linePaint);

      // Horizontal tail: elbow → p3
      canvas.drawLine(elbowResolved, p3, linePaint);

      // Label
      tp.text = TextSpan(
        text: l.text,
        style: const TextStyle(
          fontSize: labelFontSize,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(l.labelX, l.labelY - l.labelHeight / 2));
    }
  }

  /// Iteratively pushes overlapping labels apart (top-to-bottom pass, repeated).
  void _resolveCollisions(List<_LabelLayout> group, double minGap) {
    if (group.length < 2) return;

    // Sort top to bottom by current labelY
    group.sort((a, b) => a.labelY.compareTo(b.labelY));

    // Run multiple passes until stable (max 20 iterations)
    for (int pass = 0; pass < 20; pass++) {
      bool moved = false;
      for (int i = 0; i < group.length - 1; i++) {
        final a = group[i];
        final b = group[i + 1];
        final aBottom = a.labelY + a.labelHeight / 2;
        final bTop = b.labelY - b.labelHeight / 2;
        final overlap = aBottom + minGap - bTop;
        if (overlap > 0) {
          // Push them apart equally
          a.labelY -= overlap / 2;
          b.labelY += overlap / 2;
          moved = true;
        }
      }
      if (!moved) break;
    }
  }

  @override
  bool shouldRepaint(covariant _LabelPainter oldDelegate) =>
      oldDelegate.chartData != chartData;
}

class ChartData {
  final String x;
  final int y;
  final Color color;
  final double percentage;

  ChartData(this.x, this.y, this.color, this.percentage);
}