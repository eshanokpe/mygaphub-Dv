import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class I360LabScreen extends StatefulWidget {
  const I360LabScreen({super.key});

  @override
  State<I360LabScreen> createState() => _I360LabScreenState();
}

class _I360LabScreenState extends State<I360LabScreen> {
  int selectedIndex = -1;

  void onSegmentTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: ListView(
            children: [
              const SizedBox(height: 20),

              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.arrow_back_ios_new),
                  Image.asset(
                    'assets/wheel_segments/pencil-alt.png',
                    width: 24.w,
                    height: 24.h,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// TITLE
              Center(
                child: Text(
                  "360 iLAB",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              Center(
                child: Text(
                  "Play with your iLAB Clock",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xff393737),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// WHEEL
              GestureDetector(
                onTapUp: (details) {
                  final box = context.findRenderObject() as RenderBox;
                  final local = box.globalToLocal(details.globalPosition);

                  final center = Offset(box.size.width / 2, 320);

                  final dx = local.dx - center.dx;
                  final dy = local.dy - center.dy;

                  final angle = atan2(dy, dx);

                  int index = ((angle + pi) / (pi / 2)).floor() % 4;

                  onSegmentTap(index);
                },
                child: SizedBox(
                  height: 340,
                  width: 340,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        painter: WheelPainter(selectedIndex: selectedIndex),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 75),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _buildCenterContent(),
                            ),
                          ),
                        ),
                      ),

                      /// CANCEL ICON ON ACTIVE SEGMENT
                      if (selectedIndex != -1)
                        Positioned(
                          left: _cancelOffset(selectedIndex).dx,
                          top: _cancelOffset(selectedIndex).dy,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = -1;
                              });
                            },
                            child: SizedBox(
                              width: 26,
                              height: 26,
                              child: Transform.rotate(
                                angle: 45 * 3.14159 / 180,
                                child: Icon(
                                  Icons.close,
                                  size: 16.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// CURRENT POSITION BUTTON
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade400,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${DateTime.now().year} Current Position",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// DATA SECTION
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "iLAB",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Difference",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      buildIncomeTile(
                        title: "Income (NPi)",
                        value: "-£0.00",
                        valueColor: Colors.red,
                      ),

                      buildIncomeTile(
                        title: "Income (APi)",
                        value: "£25,928.31",
                        valueColor: Colors.green,
                      ),

                      buildIncomeTile(
                        title: "Liabilities",
                        value: "-£262,821.00",
                        valueColor: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// CENTER CONTENT
  Widget _buildCenterContent() {
    if (selectedIndex == -1) {
      return Text(
        "Click on any colour to view your current position",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xffC5C5C5),
        ),
      );
    }

    switch (selectedIndex) {
      case 0:
        return _centerTile(
          title: "Assets",
          amount: "£120,450",
          color: Colors.green,
        );

      case 1:
        return _centerTile(
          title: "Liabilities",
          amount: "-£262,821",
          color: Colors.deepPurple,
        );

      case 2:
        return _centerTile(
          title: "Budget",
          amount: "£8,500",
          color: Colors.red,
        );

      case 3:
        return _centerTile(
          title: "Income",
          amount: "£25,928",
          color: Colors.orange,
        );

      default:
        return const SizedBox();
    }
  }

  Widget _centerTile({
    required String title,
    required String amount,
    required Color color,
  }) {
    return Column(
      key: ValueKey(title),
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 8.h),

        Text(
          title,
          style: TextStyle(
            fontSize: 22.sp,
            color: const Color(0xff979797),
            fontWeight: FontWeight.w400,
          ),
        ),

        SizedBox(height: 4.h),

        Text(
          amount,
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            // color: color,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget buildIncomeTile({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Offset _cancelOffset(int index) {
    const double radius = 168; // slightly outside arc
    const double sweep = 0.22;

    final startAngle = -pi / 2 + (index * pi / 2) - 0.85;
    final angle = startAngle + (sweep / 2);

    const centerX = 170;
    const centerY = 170;

    final x = centerX + radius * cos(angle);
    final y = centerY + radius * sin(angle);

    return Offset(x - 13, y - 13);
  }
}

/// WHEEL PAINTER
class WheelPainter extends CustomPainter {
  final int selectedIndex;

  WheelPainter({required this.selectedIndex});

  final List<Color> quadrantColors = [
    const Color(0xFF1B5E20),
    const Color(0xFF6A1B9A),
    const Color(0xFFC62828),
    const Color(0xFFE6891A),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final tickRadius = size.width / 2 - 25;
    final arcRadius = size.width / 2 - 2;

    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const totalTicks = 60;
    const tickAngle = (2 * pi) / totalTicks;

    /// DASHED TICKS
    for (int i = 0; i < totalTicks; i++) {
      final angle = -pi / 1 + tickAngle * i;

      int quadrant = (i ~/ 15);

      tickPaint.color = selectedIndex == -1
          ? quadrantColors[quadrant]
          : quadrant == selectedIndex
          ? quadrantColors[quadrant]
          : quadrantColors[quadrant].withOpacity(0.2);

      tickPaint.strokeWidth = i % 15 == 0 ? 6 : 4;

      final start = Offset(
        center.dx + (tickRadius - 8) * cos(angle),
        center.dy + (tickRadius - 8) * sin(angle),
      );

      final end = Offset(
        center.dx + tickRadius * cos(angle),
        center.dy + tickRadius * sin(angle),
      );

      canvas.drawLine(start, end, tickPaint);
    }

    /// OUTER ARCS
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      arcPaint.color = selectedIndex == -1
          ? quadrantColors[i]
          : i == selectedIndex
          ? quadrantColors[i]
          : quadrantColors[i].withOpacity(0.2);

      final startAngle = -pi / 2 + (i * pi / 2) - 0.85;

      const sweep = 0.22;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: arcRadius),
        startAngle,
        sweep,
        false,
        arcPaint,
      );
    }

    _drawNumber(canvas, center, tickRadius - 30, -pi / 2, "12");
    _drawNumber(canvas, center, tickRadius - 30, 0, "3");
    _drawNumber(canvas, center, tickRadius - 30, pi / 2, "6");
    _drawNumber(canvas, center, tickRadius - 30, pi, "9");
  }

  void _drawNumber(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    String text,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFFD0D0D0),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    painter.layout();

    final offset = Offset(
      center.dx + radius * cos(angle) - painter.width / 2,
      center.dy + radius * sin(angle) - painter.height / 2,
    );

    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
