import 'dart:async';
import 'dart:ui' as ui;

import 'package:GapHub/screens/360/accounts/retirement/viewdetails.dart';
import 'package:GapHub/screens/homepage/widget/row_view_details.dart';
import 'package:GapHub/screens/registration/financial_snapshot/widget/zone_item_inverted.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/customBottomSheet.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/screens/360/accounts/retirement/viewnotes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FiCard extends StatefulWidget {
  const FiCard({
    super.key,
    required this.width,
    required this.height,
    required this.yes,
  });

  final double width;
  final bool yes;
  final double height;

  @override
  _FiCardState createState() => _FiCardState();
}

class _FiCardState extends State<FiCard> {
  DialogBox dialogBox = DialogBox();
  Dio dio = Dio();
  double? a;
  String? b, c;

  // MARK: - Gradient Color Definitions - BOLD COLORS
  static const List<Color> _redGradient = [
    Color(0xFFFF0001),
    Color(0xFFCE0001),
  ];

  static const List<Color> _amberGradient = [
    Color(0xFFF6AE39),
    Color(0xFFFF7A00),
  ];

  static const List<Color> _greenGradient = [
    Color(0xFF005E32),
    Color(0xFF17B26A),
  ];

  static const List<Color> _blueGradient = [
    Color(0xFF005E77),
    Color(0xFF002E77),
  ];

  // MARK: - Gradient Helper Methods
  List<Color> _getGradientForPercentage(double percentage) {
    if (percentage <= 25) {
      return _redGradient;
    } else if (percentage <= 50) {
      return _amberGradient;
    } else if (percentage <= 75) {
      return _greenGradient;
    } else {
      return _blueGradient;
    }
  }

  List<Color> _getGradientForValue(String value) {
    // Remove commas and parse to double
    final cleanValue = value.replaceAll(',', '');
    final numericValue = double.tryParse(cleanValue) ?? 0;

    return _getGradientForPercentage(numericValue);
  }

  double _readSnapshotNumber(Map snapshot, String key) {
    final value = snapshot[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '')) ?? 0;
    return 0;
  }

  String _formatSnapshotValue(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  // Custom CircularPercentIndicator with gradient - BOLD COLORS
  Widget _buildGradientCircularIndicator({
    required double radius,
    required double lineWidth,
    required Color backgroundColor,
    required Widget center,
    required double percent,
    required List<Color> gradientColors,
  }) {
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: backgroundColor, width: lineWidth),
            ),
          ),
          // Gradient progress arc - BOLD COLORS
          CustomPaint(
            size: Size(radius * 2, radius * 2),
            painter: _GradientCircularProgressPainter(
              percent: percent.clamp(0, 1),
              gradientColors: gradientColors,
              lineWidth: lineWidth,
              strokeCap: StrokeCap.round, // Rounded caps for bolder look
            ),
          ),
          // Center content
          center,
        ],
      ),
    );
  }

  // Helper method to create gradient text - BOLD COLORS
  Widget _buildGradientText({
    required String text,
    required List<Color> gradientColors,
    required double fontSize,
    FontWeight fontWeight =
        FontWeight.w900, // Made bolder (was FontWeight.normal)
    TextStyle? style,
  }) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bounds);
      },
      child: Text(
        text,
        style:
            (style ??
            GoogleFonts.nunitoSans(
              fontSize: fontSize,
              fontWeight: fontWeight, // Now using FontWeight.w900 for boldness
              color: Colors.white,
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    // Get snapshot data
    final snapshot = context.watch<Providers>().snapshotmodel.snapshot;

    final currentValue = _readSnapshotNumber(snapshot, "currentper");
    final time360Value = _readSnapshotNumber(snapshot, "currenttime");
    final timeValue = _readSnapshotNumber(snapshot, "timeper");

    String current = _formatSnapshotValue(currentValue);
    String time360 = _formatSnapshotValue(time360Value);

    // String current = 55.toString();
    // String time360 = 80.toString();

    double currentPer = currentValue / 100;
    double timePer = timeValue / 100;

    // Get gradients based on percentage values - BOLD COLORS
    final timeGradient = _getGradientForValue(time360);
    final percentGradient = _getGradientForValue(current);

    return Column(
      children: [
        RowViewDetails(
          mainText: 'Financial Independence Snapshot',
          detailText: 'View',
          onTap: () => _goToIndependence(),
          arrowTap: true,
        ),
        SizedBox(height: widget.height * 0.02),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(
              color: Color.fromARGB(255, 241, 241, 241),
              width: 1.5,
            ),
          ),
          color: const Color.fromARGB(255, 253, 253, 253),
          child: Padding(
            padding: EdgeInsets.only(
              top: widget.height * .01,
              left: widget.width * .01,
              right: widget.width * .01,
            ),
            child: Column(
              children: [
                SizedBox(height: widget.height * .03),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 2.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGradientCircularIndicator(
                            radius: widget.width * .2,
                            lineWidth: widget.width * 0.05,
                            backgroundColor: Colors.grey.withOpacity(0.25),
                            center: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                time360Value > 1000
                                    ? _buildGradientText(
                                        text: '999+',
                                        gradientColors: timeGradient,
                                        fontSize: 34.sp,
                                        fontWeight: FontWeight.w900,
                                      )
                                    : _buildGradientText(
                                        text: time360,
                                        gradientColors: timeGradient,
                                        fontSize: 36.sp,
                                        fontWeight: FontWeight.w900,
                                      ),
                                const SizedBox(width: 2),
                                ShaderMask(
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      colors: timeGradient,
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ).createShader(bounds);
                                  },
                                  child: SvgPicture.asset(
                                    'assets/icons/hourglass.svg',
                                    width: 24.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            percent: timePer,
                            gradientColors: timeGradient,
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Current Status",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16.sp,
                                  color: const Color.fromARGB(255, 39, 39, 39),
                                  fontFamily: 'Nunito',
                                ),
                              ),
                              _buildGradientText(
                                text: "$time360 days".replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (Match m) => '${m[1]},',
                                ),
                                gradientColors: timeGradient,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ],
                          ),
                          SizedBox(height: height * 0.03),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Target Status",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16.sp,
                                  color: const Color.fromARGB(255, 39, 39, 39),
                                  fontFamily: 'Nunito',
                                ),
                              ),
                              Text(
                                "360 days",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18.sp,
                                  color: AppColors.blackColor,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: widget.height * .03),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 2.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGradientCircularIndicator(
                            radius: widget.width * .2,
                            lineWidth: widget.width * 0.05,
                            backgroundColor: Colors.grey.withOpacity(0.25),
                            center: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                currentValue > 1000
                                    ? _buildGradientText(
                                        text: '999+%',
                                        gradientColors: percentGradient,
                                        fontSize: 32.sp,
                                        fontWeight: FontWeight.w900,
                                      )
                                    : _buildGradientText(
                                        text: '$current%',
                                        gradientColors: percentGradient,
                                        fontSize: 36.sp,
                                        fontWeight: FontWeight.w900,
                                      ),
                              ],
                            ),
                            percent: currentPer,
                            gradientColors: percentGradient,
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Current Status",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16.sp,
                                  color: const Color.fromARGB(255, 39, 39, 39),
                                  fontFamily: 'Nunito',
                                ),
                              ),
                              _buildGradientText(
                                text: "$current%",
                                gradientColors: percentGradient,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ],
                          ),
                          SizedBox(height: height * 0.03),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Target Status",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16.sp,
                                  color: const Color.fromARGB(255, 39, 39, 39),
                                  fontFamily: 'Nunito',
                                ),
                              ),
                              Text(
                                "100%",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18.sp,
                                  color: AppColors.blackColor,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: widget.height * 0.02),
                Visibility(
                  visible: widget.yes,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Viewnotes()),
                      );
                    },
                    child: Text(
                      "View Notes",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: height * 0.02),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(
              color: Color.fromARGB(255, 241, 241, 241),
              width: 1.5,
            ),
          ),
          color: const Color.fromARGB(255, 253, 253, 253),
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ZoneItemInverted(
                      imagePath: 'assets/icons/red_zone.png',
                      text: 'Red Zone     ',
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 15),
                      textStyle: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(56.0),
                              topRight: Radius.circular(56.0),
                            ),
                          ),
                          builder: (BuildContext context) {
                            return const CustomBottomSheet(
                              title: 'Red Zone',
                              content:
                                  'This is an undesirable state. It means if you were to lose your job, you have savings to cover you only for a period between 0-90 days. It also means you have an asset portfolio income that is 25% or less of your cost of living.',
                            );
                          },
                        );
                      },
                    ),
                    ZoneItemInverted(
                      imagePath: 'assets/icons/green_infor.png',
                      text: 'Green Zone',
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 15),
                      textStyle: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(56.0),
                              topRight: Radius.circular(56.0),
                            ),
                          ),
                          builder: (BuildContext context) {
                            return const CustomBottomSheet(
                              title: 'Green Zone',
                              content:
                                  'This is a comfortable state. It means if you were to lose your job, you have savings to cover you for a period between 181-270 days. It also means you have an asset portfolio income that is between 51 - 75% of your cost of living.',
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ZoneItemInverted(
                      imagePath: 'assets/icons/amber_zone_infor.png',
                      text: 'Amber Zone',
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 15),
                      textStyle: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(56.0),
                              topRight: Radius.circular(56.0),
                            ),
                          ),
                          builder: (BuildContext context) {
                            return const CustomBottomSheet(
                              title: 'Amber Zone',
                              content:
                                  'This is a progressive state. It means if you were to lose your job, you have savings to cover you for a period between 91-180 days. It also means you have an asset portfolio income that is between 26 - 50% of your cost of living.',
                            );
                          },
                        );
                      },
                    ),
                    ZoneItemInverted(
                      imagePath: 'assets/icons/blue_zone_infor.png',
                      text: 'Blue Zone  ',
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 15),
                      textStyle: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(56.0),
                              topRight: Radius.circular(56.0),
                            ),
                          ),
                          builder: (BuildContext context) {
                            return const CustomBottomSheet(
                              title: 'Blue Zone',
                              content:
                                  'This is a desirable state. It means if you were to lose your job, you have savings to cover you for a period between 271-360 days and possibly beyond. It also means you have an asset portfolio income that is between 76 - 100%+ of your cost of living.',
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _goToIndependence() async {
    var timer = Timer(const Duration(seconds: 40), () {
      if (mounted) {
        Navigator.pop(context);
        dialogBox.information(context, 'Status', 'Service timed out');
      }
      return;
    });

    dialogBox.waiting(context, "Loading");

    var url = "$baseUrl/app/360/retirement/roi";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    try {
      var response = await dio.get(
        url,
        options: Options(headers: {"Authorization": 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        timer.cancel();
        if (mounted) {
          Navigator.pop(context); // Pop loading dialog
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  Viewdetails(response.data, isNotRetirement: true),
            ),
          );
        }
      } else {
        timer.cancel();
        if (mounted) {
          Navigator.pop(context);
          dialogBox.information(context, 'Status', 'Failed to load data');
        }
      }
    } catch (e) {
      timer.cancel();
      if (mounted) {
        Navigator.pop(context);
        dialogBox.information(context, 'Status', 'An error occurred');
      }
    }
  }
}

// MARK: - Custom Gradient Circular Progress Painter - BOLD COLORS
// MARK: - Custom Gradient Circular Progress Painter - BOLD COLORS
class _GradientCircularProgressPainter extends CustomPainter {
  final double percent;
  final List<Color> gradientColors;
  final double lineWidth;
  final StrokeCap strokeCap;

  _GradientCircularProgressPainter({
    required this.percent,
    required this.gradientColors,
    required this.lineWidth,
    this.strokeCap = StrokeCap.round,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - lineWidth) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = strokeCap;

    // Create gradient shader with bold colors
    const startAngle = -90 * 3.14159 / 180;
    final sweepAngle = 360 * percent * 3.14159 / 180;

    // Create a rect for the gradient
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Create sweep gradient with bold colors
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: gradientColors,
      stops: const [0.0, 1.0],
      tileMode: TileMode.clamp,
    ).createShader(rect);

    paint.shader = gradient;

    // Draw the progress arc with bold colors
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientCircularProgressPainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.gradientColors != gradientColors ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.strokeCap != strokeCap;
  }
}
