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

  @override
  void initState() {
    super.initState();
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

    // Function to determine the gradient colors based on time percentage
    List<Color> getTimeColor(double timePer) {
      if (timePer <= .25) {
        return [
          AppColors.primaryColor, // Lighter red
          const Color(0xffCE0001), // Darker red
        ];
      } else if (timePer > .25 && timePer <= .5) {
        return [
          AppColors.educationColor, // Darker orange
          AppColors.educationColor.withOpacity(0.8),
        ];
      } else if (timePer > .5 && timePer <= .75) {
        return [AppColors.savingColor, AppColors.savingColor.withOpacity(0.8)];
      } else if (timePer > .75) {
        return [
          AppColors.discretionaryColor, // Darker blue
          AppColors.discretionaryColor.withOpacity(0.8), // Lighter blue
        ];
      }
      // Default gradient (e.g., gray)
      return [AppColors.grayColor, AppColors.grayColor.withOpacity(0.8)];
    }

    Color getIconColor(double timePer) {
      if (timePer <= .25) {
        return AppColors.primaryColor; // Red
      } else if (timePer > .25 && timePer <= .5) {
        return AppColors.educationColor; // Orange
      } else if (timePer > .5 && timePer <= .75) {
        return AppColors.savingColor; // Green
      } else if (timePer > .75) {
        return AppColors.discretionaryColor; // Blue
      }
      return AppColors.grayColor; // Default gray
    }

    List<Color> getPerColor(double currentPer) {
      if (currentPer <= .25) {
        return [
          AppColors.primaryColor, // Lighter red
          const Color(0xffCE0001), // Darker red
        ];
      } else if (currentPer > .25 && currentPer <= .5) {
        return [
          AppColors.educationColor, // Darker orange
          AppColors.educationColor.withOpacity(0.8),
        ];
      } else if (currentPer > .5 && currentPer <= .75) {
        return [AppColors.savingColor, AppColors.savingColor.withOpacity(0.8)];
      } else if (currentPer > .75) {
        return [
          AppColors.discretionaryColor, // Darker blue
          AppColors.discretionaryColor.withOpacity(0.8), // Lighter blue
        ];
      }
      // Default gradient (e.g., gray)
      return [AppColors.grayColor, AppColors.grayColor.withOpacity(0.8)];
    }

    Color getPerIconColor(double currentPer) {
      if (currentPer <= .25) {
        return AppColors.primaryColor;
      } else if (currentPer > .25 && currentPer <= .5) {
        return AppColors.educationColor;
      } else if (currentPer > .5 && currentPer <= .75) {
        return AppColors.savingColor;
      } else if (currentPer > .75) {
        return AppColors.discretionaryColor;
      }
      return AppColors.grayColor; // Replace null with a default color
    }

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    final Gradient textGradient = LinearGradient(
      colors: getTimeColor(timePer!),
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final Gradient textPerGradient = LinearGradient(
      colors: getPerColor(currentPer!),
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
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
            CircularPercentIndicator(
              backgroundColor: Colors.grey.withOpacity(0.25),
              radius: widget.width! * .2,
              lineWidth: widget.width! * 0.05,
              center: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  time! > 1000
                      ? ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) => textGradient.createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                          child: Text(
                            '999+',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 34.sp,
                              // fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) => textGradient.createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                          child: Text(
                            '${time!.round()}',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                  const SizedBox(width: 2),
                  SvgPicture.asset(
                    'assets/icons/hourglass.svg',
                    width: 24.sp,
                    // height: 26.h,
                    color: getIconColor(timePer!),
                  ),
                ],
              ),

              progressColor: getIconColor(timePer!),
              animation: true,
              animateFromLastPercent: true,
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
                        '${time!.round()} days',
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
              animationDuration: 1500,
              percent: timePer! > 1 ? 1 : timePer!,
              circularStrokeCap: CircularStrokeCap.round,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 20),
              child: timePer! * 360 < 360
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
                            text: '${(time!).round()} days',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const TextSpan(
                            text: '. Are you comfortable with this?',
                          ),
                        ],
                      ),
                    )
                  : timePer! * 360 == 360
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
                            text: '${(time!).round()} days',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.primaryColor,
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
                            text: '${(time!).round()} days!',
                            style: TextStyle(
                              color: AppColors.primaryColor,
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
            CircularPercentIndicator(
              backgroundColor: Colors.grey.withOpacity(0.25),
              radius: widget.width! * .2,
              lineWidth: widget.width! * 0.05,
              center: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  current! > 1000
                      ? ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) =>
                              textPerGradient.createShader(
                                Rect.fromLTWH(
                                  0,
                                  0,
                                  bounds.width,
                                  bounds.height,
                                ),
                              ),
                          child: Text(
                            '999+',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 34.sp,
                              // fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : IntrinsicWidth(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (bounds) =>
                                  textPerGradient.createShader(
                                    Rect.fromLTWH(
                                      0,
                                      0,
                                      bounds.width,
                                      bounds.height,
                                    ),
                                  ),
                              child: Text(
                                '${current!.round()}%',
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.visible,
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 36.sp,
                                  // fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                  // Padding(
                  //   padding: const EdgeInsets.all(2.0),
                  //   child: SvgPicture.asset(
                  //     'assets/icons/percentage.svg',
                  //     color: getPerIconColor(currentPer!),
                  //   ),
                  // ),
                ],
              ),
              animation: true,
              animateFromLastPercent: false,
              animationDuration: 1500,
              percent: currentPer! > 1 ? 1 : currentPer!,
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: getPerIconColor(currentPer!),
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
                        '${current!.round()}%',
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
              child: currentPer! * 100 == 0
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
                            text: '${(currentPer! * 100).round()}% ',
                            style: const TextStyle(
                              fontFamily: "Nunito",
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const TextSpan(
                            text:
                                'of your monthly expenses from your portfolio income. You do not have any portfolio income. You should seriously consider speaking with one of our financial advisors.',
                          ),
                        ],
                      ),
                    )
                  : currentPer! * 100 < 100
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
                            text: '${(currentPer! * 100).round()}% ',
                            style: const TextStyle(
                              color: AppColors.primaryColor,
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
                            text: '${(currentPer! * 100).round()}% ',
                            style: const TextStyle(
                              color: AppColors.primaryColor,
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
