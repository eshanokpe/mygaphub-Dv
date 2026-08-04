import 'package:GapHub/provider/acquisiProvider.dart';
import 'package:GapHub/widgets/customBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

import '../utils/colors.dart';

class FiCard2 extends StatefulWidget {
  final double? width;
  final double? height;

  const FiCard2({super.key, this.width, this.height});

  @override
  _FiCard2State createState() => _FiCard2State();
}

class _FiCard2State extends State<FiCard2> {
  double? total;
  double? currentPer;
  double? timePer;
  double? time, current;

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

  @override
  void initState() {
    super.initState();
  }

  // MARK: - Gradient Helper Methods
  List<Color> _getTimeGradient(double timePerValue) {
    if (timePerValue <= 0.25) {
      return _redGradient;
    } else if (timePerValue <= 0.5) {
      return _amberGradient;
    } else if (timePerValue <= 0.75) {
      return _greenGradient;
    } else {
      return _blueGradient;
    }
  }

  List<Color> _getPercentageGradient(double currentPerValue) {
    if (currentPerValue <= 0.25) {
      return _redGradient;
    } else if (currentPerValue <= 0.5) {
      return _amberGradient;
    } else if (currentPerValue <= 0.75) {
      return _greenGradient;
    } else {
      return _blueGradient;
    }
  }

  Color _getIconColor(double percentage) {
    if (percentage <= 0.25) {
      return const Color(0xFFFF0001); // Red
    } else if (percentage <= 0.5) {
      return const Color(0xFFF6AE39); // Amber
    } else if (percentage <= 0.75) {
      return const Color(0xFF005E32); // Green
    } else {
      return const Color(0xFF005E77); // Blue
    }
  }

  // MARK: - Custom Gradient Circular Indicator
  Widget _buildGradientCircularIndicator({
    required double radius,
    required double lineWidth,
    required Color backgroundColor,
    required Widget center,
    required double percent,
    required List<Color> gradientColors,
    Widget? footer,
  }) {
    return Column(
      children: [
        SizedBox(
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
              // Gradient progress arc
              CustomPaint(
                size: Size(radius * 2, radius * 2),
                painter: _GradientCircularProgressPainter(
                  percent: percent.clamp(0, 1),
                  gradientColors: gradientColors,
                  lineWidth: lineWidth,
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Center content
              center,
            ],
          ),
        ),
        if (footer != null) footer,
      ],
    );
  }

  // MARK: - Gradient Text Helper
  Widget _buildGradientText({
    required String text,
    required List<Color> gradientColors,
    required double fontSize,
    FontWeight fontWeight = FontWeight.w900,
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
              fontWeight: fontWeight,
              color: Colors.white,
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calculatorModel = Provider.of<AcquisiProvider>(context);

    var a = double.tryParse(calculatorModel.savings) ?? 0;
    var b = double.tryParse(calculatorModel.education) ?? 0;
    var c = double.tryParse(calculatorModel.mortgage) ?? 0;
    var d = double.tryParse(calculatorModel.mobility) ?? 0;
    var e = double.tryParse(calculatorModel.expenses) ?? 0;
    var f = double.tryParse(calculatorModel.utility) ?? 0;
    var g = double.tryParse(calculatorModel.debtRepay) ?? 0;
    var h = double.tryParse(calculatorModel.charity) ?? 0;
    var rainy = double.tryParse(calculatorModel.rainyDays) ?? 0;
    var other = double.tryParse(calculatorModel.otherWages) ?? 0;

    // Calculate total
    total = a + b + c + d + e + f + g + h;

    time = total != 0 ? (rainy / total!) * 30 : 0;
    current = total != 0 ? (other / total!) * 100 : 0;

    timePer = ((time ?? 0) / 360);
    currentPer = ((current ?? 0) / 100);

    final timePerValue = timePer ?? 0;
    final currentPerValue = currentPer ?? 0;
    final timeValue = time ?? 0;
    final currentValue = current ?? 0;

    // Get gradients based on percentages
    final timeGradient = _getTimeGradient(timePerValue);
    final percentGradient = _getPercentageGradient(currentPerValue);

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            'Financial Independence Snapshot',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20.sp,
              fontStyle: FontStyle.italic,
              color: AppColors.blackColor,
            ),
          ),
        ),
        SizedBox(height: widget.height! * .03),
        Column(
          children: [
            _buildGradientCircularIndicator(
              radius: widget.width! * .2,
              lineWidth: widget.width! * 0.05,
              backgroundColor: Colors.grey.withOpacity(0.25),
              center: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  timeValue > 1000
                      ? _buildGradientText(
                          text: '999+',
                          gradientColors: timeGradient,
                          fontSize: 34.sp,
                          fontWeight: FontWeight.w900,
                        )
                      : _buildGradientText(
                          text: timeValue.round().toString(),
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
              percent: timePerValue,
              gradientColors: timeGradient,
              footer: Column(
                children: [
                  SizedBox(height: widget.height! * .02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Status',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w400,
                          fontSize: 16.sp,
                          color: AppColors.grayColor,
                        ),
                      ),
                      Text(
                        '${timeValue.round()} days',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w400,
                          fontSize: 16.sp,
                          color: AppColors.grayColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Target Status',
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          color: AppColors.blackColor,
                        ),
                      ),
                      Text(
                        '360 days',
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 20),
              child: timePerValue * 360 < 360
                  ? RichText(
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          color: AppColors.blackColor,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                'Your current rainy day savings can only last you ',
                          ),
                          TextSpan(
                            text: '${timeValue.round()} days',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: _getIconColor(timePerValue),
                            ),
                          ),
                          const TextSpan(
                            text: '. Are you comfortable with this?',
                          ),
                        ],
                      ),
                    )
                  : timePerValue * 360 == 360
                  ? RichText(
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          color: AppColors.blackColor,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                'Your current rainy day savings can only last you ',
                          ),
                          TextSpan(
                            text: '${timeValue.round()} days',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: _getIconColor(timePerValue),
                            ),
                          ),
                          const TextSpan(
                            text: '. Are you comfortable with this?',
                          ),
                        ],
                      ),
                    )
                  : RichText(
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          color: AppColors.blackColor,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                'Your current rainy day savings can last you  ',
                          ),
                          TextSpan(
                            text: '${timeValue.round()} days!',
                            style: TextStyle(
                              color: _getIconColor(timePerValue),
                              fontSize: 16.sp,
                            ),
                          ),
                          const TextSpan(
                            text:
                                '. Wow! This is beyond the typical 360-day target. Congratulations you have  more than a year worth of living expenses saved up. Ensure you  maintain at least 300 days worth of savings as a minimum',
                          ),
                        ],
                      ),
                    ),
            ),
            SizedBox(height: 40.h),
            const Divider(
              color: Color.fromARGB(255, 244, 244, 244),
              thickness: 1.5,
              indent: 20,
              endIndent: 20,
            ),
            SizedBox(height: 40.h),
            _buildGradientCircularIndicator(
              radius: widget.width! * .2,
              lineWidth: widget.width! * 0.05,
              backgroundColor: Colors.grey.withOpacity(0.25),
              center: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  currentValue > 1000
                      ? _buildGradientText(
                          text: '999+',
                          gradientColors: percentGradient,
                          fontSize: 34.sp,
                          fontWeight: FontWeight.w900,
                        )
                      : IntrinsicWidth(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildGradientText(
                              text: '${currentValue.round()}%',
                              gradientColors: percentGradient,
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                ],
              ),
              percent: currentPerValue,
              gradientColors: percentGradient,
              footer: Column(
                children: [
                  SizedBox(height: widget.height! * .02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Status',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w400,
                          fontSize: 16.sp,
                          color: AppColors.grayColor,
                        ),
                      ),
                      Text(
                        '${currentValue.round()}%',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w400,
                          fontSize: 16.sp,
                          color: AppColors.grayColor,
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Target Status',
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.blackColor,
                        ),
                      ),
                      Text(
                        '100%',
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
            Padding(
              padding: const EdgeInsets.only(
                right: 10.0,
                left: 10,
                top: 0,
                bottom: 15,
              ),
              child: currentPerValue * 100 == 0
                  ? RichText(
                      textAlign: TextAlign.center,
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          color: AppColors.blackColor,
                        ),
                        children: [
                          const TextSpan(text: 'You are currently meeting '),
                          TextSpan(
                            text: '${(currentPerValue * 100).round()}% ',
                            style: TextStyle(
                              fontFamily: "Nunito",
                              color: _getIconColor(currentPerValue),
                            ),
                          ),
                          const TextSpan(
                            text:
                                'of your monthly expenses from your portfolio income. You do not have any portfolio income. You should seriously consider speaking with one of our financial advisors.',
                          ),
                        ],
                      ),
                    )
                  : currentPerValue * 100 < 100
                  ? RichText(
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          color: AppColors.blackColor,
                        ),
                        children: [
                          const TextSpan(text: 'You are currently meeting '),
                          TextSpan(
                            text: '${(currentPerValue * 100).round()}% ',
                            style: TextStyle(
                              color: _getIconColor(currentPerValue),
                            ),
                          ),
                          const TextSpan(
                            text:
                                'of your monthly expenses from your portfolio income. What happens if you lose your main source of income?',
                          ),
                        ],
                      ),
                    )
                  : RichText(
                      textAlign: TextAlign.center,
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          color: AppColors.blackColor,
                        ),
                        children: [
                          const TextSpan(text: 'You are currently meeting '),
                          TextSpan(
                            text: '${(currentPerValue * 100).round()}% ',
                            style: TextStyle(
                              color: _getIconColor(currentPerValue),
                            ),
                          ),
                          const TextSpan(
                            text:
                                'of your monthly expenses from your portfolio income. Well done! You are financially independent. Always remember to increase your means before increasing the cost of your lifestyle',
                          ),
                        ],
                      ),
                    ),
            ),
            const Divider(
              color: Color.fromARGB(255, 244, 244, 244),
              thickness: 1.5,
              indent: 20,
              endIndent: 20,
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 0.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ZoneItemInverted2(
                        imagePath: 'assets/icons/red_dot.png',
                        text: 'Red Zone     ',
                        padding: const EdgeInsets.fromLTRB(18, 10, 18, 15),
                        textStyle: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16.sp,
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
                      ZoneItemInverted2(
                        imagePath: 'assets/images/green_dot.png',
                        text: 'Green Zone',
                        padding: const EdgeInsets.fromLTRB(18, 10, 18, 15),
                        textStyle: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16.sp,
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
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ZoneItemInverted2(
                        imagePath: 'assets/images/amber_dot.png',
                        text: 'Amber Zone',
                        padding: const EdgeInsets.fromLTRB(18, 10, 18, 15),
                        textStyle: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16.sp,
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
                      ZoneItemInverted2(
                        imagePath: 'assets/images/blue_dot.png',
                        text: 'Blue Zone  ',
                        padding: const EdgeInsets.fromLTRB(18, 10, 18, 15),
                        textStyle: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16.sp,
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
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        const Divider(
          color: Color.fromARGB(255, 244, 244, 244),
          thickness: 1.5,
          indent: 20,
          endIndent: 20,
        ),
      ],
    );
  }
}

// MARK: - Custom Gradient Circular Progress Painter
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

class ZoneItemInverted2 extends StatelessWidget {
  final String imagePath;
  final String text;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;
  final VoidCallback onTap;

  const ZoneItemInverted2({
    super.key,
    required this.imagePath,
    required this.text,
    required this.onTap,
    this.padding = const EdgeInsets.fromLTRB(10, 0, 10, 0),
    this.textStyle = const TextStyle(
      fontFamily: 'Nunito',
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  });

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(imagePath, height: 16.h, width: 16.w),
            SizedBox(width: width * .01),
            Text(text, style: textStyle),
          ],
        ),
      ),
    );
  }
}
