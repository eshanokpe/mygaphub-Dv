import 'dart:math';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class I360LabScreen extends StatefulWidget {
  const I360LabScreen({super.key});

  @override
  State<I360LabScreen> createState() => _I360LabScreenState();
}

class _I360LabScreenState extends State<I360LabScreen> {
  int selectedIndex = -1;
  Map<String, dynamic> data = {};
  List<dynamic> b = []; // Declare b as a class variable
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
  bool expenTick1 = true;
  bool expenTick0 = true;

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // Get the data from provider
        final providerData = context.read<Providers>().ilabdata;
        print("iLab raw data: $providerData");

        // Check if providerData has the expected structure
        if (providerData['status'] == true && providerData['data'] != null) {
          // Extract the actual data from the response
          data = Map<String, dynamic>.from(providerData['data'] as Map);
        } else {
          // If it's already the data structure without status wrapper
          data = Map<String, dynamic>.from(providerData);
        }

        print("Processed data: $data");

        // Process the ilab data after it's loaded
        if (data.isNotEmpty && data["ilab"] != null) {
          // Cast the map to the correct type
          Map<String, dynamic> a = Map<String, dynamic>.from(
            data["ilab"] as Map,
          );
          b = a.values.toList();
          debugPrint("b ${b.toString()}");

          if (b.length >= 17) {
            b.removeRange(0, 2);
            b.removeRange(11, 15);
          }
        }
      });
    });
  }

  void onSegmentTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    String currency =
        data["currency"] ??
        context.watch<Providers>().snapshotmodel.currency ??
        '£';

    // Get current_ilab data with null safety
    final Map<String, dynamic> currentIlab = data["current_ilab"] is Map
        ? Map<String, dynamic>.from(data["current_ilab"] as Map)
        : {};

    var investment0 = invTick0
        ? (num.tryParse(currentIlab["investment"]?.toString() ?? "0") ?? 0)
        : 0;

    var equity0 = equTick0
        ? (num.tryParse(currentIlab["equity"]?.toString() ?? "0") ?? 0)
        : 0;

    var savings0 = savTick0
        ? (num.tryParse(currentIlab["savings"]?.toString() ?? "0") ?? 0)
        : 0;

    num assetTotal0 = investment0 + equity0 + savings0;

    var credit0 = creTick0
        ? (num.tryParse(currentIlab["credit"]?.toString() ?? "0") ?? 0)
        : 0;
    var mortgage0 = mortTick0
        ? (num.tryParse(currentIlab["mortgage"]?.toString() ?? "0") ?? 0)
        : 0;
    num liabilityTotal0 = credit0 + mortgage0;

    var nonP0 = npTick0
        ? (num.tryParse(currentIlab["non_portfolio"]?.toString() ?? "0") ?? 0)
        : 0;
    var port0 = portTick0
        ? (num.tryParse(currentIlab["portfolio"]?.toString() ?? "0") ?? 0)
        : 0;
    var incomeTotal0 = nonP0 + port0;

    var periodic0 = perTick0
        ? (num.tryParse(currentIlab["periodic_saving"]?.toString() ?? "0") ?? 0)
        : 0;
    var education0 = eduTick0
        ? (num.tryParse(currentIlab["education"]?.toString() ?? "0") ?? 0)
        : 0;
    var expenditure0 = expenTick0
        ? (num.tryParse(currentIlab["expenditure"]?.toString() ?? "0") ?? 0)
        : 0;
    var discretionary0 = discTick0
        ? (num.tryParse(currentIlab["discretionary"]?.toString() ?? "0") ?? 0)
        : 0;
    var budget0 = periodic0 + education0 + expenditure0 + discretionary0;

    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: ListView(
            children: [
              SizedBox(height: 20.h),

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

              SizedBox(height: 20.h),

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

              SizedBox(height: 30.h),

              /// WHEEL
              GestureDetector(
                onTapUp: (details) {
                  final box = context.findRenderObject() as RenderBox;
                  final local = box.globalToLocal(details.globalPosition);

                  final center = Offset(box.size.width / 2, 320.h);

                  final dx = local.dx - center.dx;
                  final dy = local.dy - center.dy;

                  final angle = atan2(dy, dx);

                  int index = ((angle + pi) / (pi / 2)).floor() % 4;

                  // onSegmentTap(index);
                  // Calculate distance from center to tap position
                  final distanceFromCenter = sqrt(dx * dx + dy * dy);

                  // Only trigger if tap is in the outer ring area (not in the center)
                  if (distanceFromCenter > 100) {
                    // Adjust threshold as needed
                    final angle = atan2(dy, dx);
                    int index = ((angle + pi) / (pi / 2)).floor() % 4;
                    onSegmentTap(index);
                  }
                },
                child: SizedBox(
                  height: 340.h,
                  width: 340.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        painter: WheelPainter(selectedIndex: selectedIndex),
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

                      /// CANCEL ICON ON ACTIVE SEGMENT
                      if (selectedIndex != -1)
                        Positioned(
                          left: _cancelOffset(selectedIndex).dx.w,
                          top: _cancelOffset(selectedIndex).dy.h,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = -1;
                              });
                            },
                            child: SizedBox(
                              width: 26.w,
                              height: 26.h,
                              child: Transform.rotate(
                                angle: 45 * pi / 180,
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

              SizedBox(height: 20.h),

              /// CURRENT POSITION BUTTON
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(56.r),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF333E4F), // Top color
                        Color(0xFF677283), // Bottom color
                      ],
                      stops: [0.2033, 1.9251], // 20.33% and 192.51%
                      transform: GradientRotation(
                        182 * pi / 180,
                      ), // 182 degrees
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x120F1828), // rgba(16, 24, 40, 0.07)
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/wheel_segments/information-circle.svg',
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "${DateTime.now().year} Current Position",
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

              SizedBox(height: 30.h),

              /// DATA SECTION
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
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

                    SizedBox(height: 20.h),

                    _buildIncomeTile(
                      title: "Income (NPi)",
                      value: "-$currency${_formatNumber(nonP0.toString())}",
                      valueColor: Colors.red,
                    ),

                    _buildIncomeTile(
                      title: "Income (APi)",
                      value: "$currency${_formatNumber(port0.toString())}",
                      valueColor: Colors.green,
                    ),

                    _buildIncomeTile(
                      title: "Liabilities",
                      value:
                          "-$currency${_formatNumber(liabilityTotal0.toString())}",
                      valueColor: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// CENTER CONTENT
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
          amount: "$currency${_formatNumber(assetTotal0.toString())}",
          color: Colors.green,
        );

      case 1:
        return _centerTile(
          key: const ValueKey('liabilities'),
          title: "Liabilities",
          amount: "$currency${_formatNumber(liabilityTotal0.toString())}",
          color: Colors.deepPurple,
        );

      case 2:
        return _centerTile(
          key: const ValueKey('budget'),
          title: "Budget",
          amount: "$currency${_formatNumber(budget0.toString())}",
          color: Colors.red,
        );

      case 3:
        return _centerTile(
          key: const ValueKey('income'),
          title: "Income",
          amount: "$currency${_formatNumber(incomeTotal0.toString())}",
          color: Colors.orange,
        );

      default:
        return const SizedBox();
    }
  }

  Widget _centerTileAssets({
    required Key key,
    required String title,
    required String amount,
    required Color color,
  }) {
    return Column(
      key: key,
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
          _formatNumber(amount),
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 12.h),

        /// Wrap the tags in a Wrap widget to handle overflow
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTag(
              label: "Investment",
              iconPath: 'assets/wheel_segments/check-circle.svg',
            ),
            SizedBox(width: 8.h),
            _buildTag(
              label: "Home Equity",
              iconPath: 'assets/wheel_segments/check-circle.svg',
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _buildTag(
          label: "Cash",
          iconPath: 'assets/wheel_segments/check-circle.svg',
        ),
      ],
    );
  }

  /// Helper method to build consistent tags
  Widget _buildTag({required String label, required String iconPath}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: const Color(0xff256825),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(iconPath, width: 16.w, height: 16.h),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _centerTile({
    required Key key,
    required String title,
    required String amount,
    required Color color,
  }) {
    return Column(
      key: key,
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
          _formatNumber(amount),
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  String _formatNumber(String amount) {
    return amount.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Widget _buildIncomeTile({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
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
    const double radius = 168;
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

  const WheelPainter({required this.selectedIndex});

  final List<Color> quadrantColors = const [
    Color(0xFF1B5E20), // Green
    Color(0xFF6A1B9A), // Purple
    Color(0xFFC62828), // Red
    Color(0xFFE6891A), // Orange
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
      final angle = -pi + tickAngle * i;
      int quadrant = i ~/ 15;

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
  bool shouldRepaint(covariant WheelPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex;
  }
}
