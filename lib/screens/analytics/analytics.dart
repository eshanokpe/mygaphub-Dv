import 'dart:async';
import 'dart:convert';
import 'package:GapHub/screens/analytics/edits/editpage.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/models/chartsmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nimble_charts/flutter.dart' as charts;
import 'tab/progress_list.dart';
 
class Analytics extends StatefulWidget {
  const Analytics({
    super.key,
    this.tabPages,
    required this.height,
    required this.width,
    required this.average,
    required this.newUserAnalytics,
    required this.realColors,
    required List<charts.Series<Kpi, String>> seriesData,
  }) : _seriesData = seriesData;

  final double height;
  final double width;
  final List<Widget>? tabPages;
  final double average;
  final List<int> realColors;
  final bool newUserAnalytics;
  final List<charts.Series<Kpi, String>> _seriesData;

  @override
  _AnalyticsState createState() => _AnalyticsState();
}

pop() {
  SystemNavigator.pop();
}

class _AnalyticsState extends State<Analytics> {
  DialogBox dialogBox = DialogBox();
  Analyticsinfo? analyticsinfo;
  Timer? _requestTimer;
  bool isLoading = false;

  @override
  void dispose() {
    _requestTimer?.cancel(); // Cancel timer on dispose
    super.dispose();
  }

  void _fetchAnalyticsData() async {
    // Cancel any previous timer
    _requestTimer?.cancel();

    _requestTimer = Timer(const Duration(milliseconds: 20000), () {
      if (mounted) {
        Navigator.pop(context);
        dialogBox.information(context, 'Status', 'Service timed out');
      }
    });

    if (mounted) {
      dialogBox.waiting(context, 'Loading');
    }

    var url = Uri.parse('$baseUrl/app/seveng/edit');

    final prefs = await SharedPreferences.getInstance();
    String? finalToken = prefs.getString('tokenDB');

    try {
      var response = await http.get(
        url,
        headers: {"Authorization": 'Bearer $finalToken'},
      );

      if (!mounted) {
        _requestTimer?.cancel();
        return;
      }

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        var analyticsdata = body["data"];

        print('Analytics data: $analyticsdata');

        if (analyticsdata != null && analyticsdata is Map<String, dynamic>) {
          setState(() {
            analyticsinfo = Analyticsinfo.fromJson(analyticsdata);
            isLoading = false;
          });

          if (analyticsinfo != null) {
            context.read<Providers>().setAnalyticsInfo(analyticsinfo!);

            _requestTimer?.cancel();

            if (mounted) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Editpage(
                    widget.realColors,
                    analyticsinfo!,
                    widget.newUserAnalytics,
                  ),
                ),
              );
            }
          }
        } else {
          if (mounted) {
            Navigator.pop(context);
            dialogBox.information(
              context,
              'Error',
              'Invalid data format received from server',
            );
          }
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
          dialogBox.information(
            context,
            'Error',
            'Failed to fetch analytics: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        dialogBox.information(context, 'Error', 'Error: ${e.toString()}');
      }
      _requestTimer?.cancel();
    }
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

    return WillPopScope(
      onWillPop: () async {
        return await dialogBox.options(
          context,
          'Exit',
          'Are you sure you want to exit?',
          pop,
        );
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.width * .03),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Visibility(
                visible: !widget.newUserAnalytics,
                child: SizedBox(height: widget.height * .03),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Visibility(
                  visible: !widget.newUserAnalytics,
                  child: Text(
                    'Analytics',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SizedBox(height: widget.height * .01),
              Visibility(
                visible: widget.newUserAnalytics,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Average Performance',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    _buildAverageValue(widget.average.round(), width),
                  ],
                ),
              ),
              Visibility(
                visible: !widget.newUserAnalytics,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'Nunito',
                        ),
                        children: const <TextSpan>[
                          TextSpan(
                            text:
                                'Your multiple-choice answers have provided an assumption of your ',
                          ),
                          TextSpan(
                            text: 'Key Performance Indicators',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text:
                                '. Please click on any of the bars below to validate these assumptions.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 26.h),

              // Only show ProgressListUI if analyticsinfo is loaded
              Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  ProgressListUI(
                    // analyticsinfo: analyticsinfo!,
                    realColors: widget.realColors,
                    newUser: widget.newUserAnalytics,
                  ),
                ],
              ),
              SizedBox(height: widget.height * .04),
              Visibility(
                visible: !widget.newUserAnalytics,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * .02,
                    vertical: height * .01,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/kpi_color.png',
                            height: 16.h,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: widget.width * .02),
                          Text(
                            'Validated KPI\'s',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: 12.sp,
                            width: 12.sp,
                            decoration: const BoxDecoration(
                              color: Color(0XFF444444),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: widget.width * .01),
                          Text(
                            'Unvalidated KPI\'s',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: !widget.newUserAnalytics,
                child: SizedBox(height: widget.height * .05),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .01),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/icons/rec_info.png',
                      width: 16.w,
                      height: 16.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: width * .02),
                    Expanded(
                      child: Text(
                        'Tap any of the KPI names (Alpha, Beta, Credit e.t.c.) to learn more.',
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: !widget.newUserAnalytics,
                child: SizedBox(height: widget.height * .02),
              ),

              SizedBox(height: widget.height * .05),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 8.w,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(widget.width * .02),
                  ),
                ),
                onPressed: _fetchAnalyticsData,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widget.newUserAnalytics
                        ? Icon(
                            Icons.remove_red_eye,
                            size: 16.w,
                            color: Colors.white,
                          ) 
                        : Image.asset(
                            'assets/icons/pencil-alt.png',
                            width: 16.w,
                            height: 16.h,
                            fit: BoxFit.contain,
                          ),
                    SizedBox(width: width * .02),
                    Text(
                      widget.newUserAnalytics ? 'View All' : ' Edit All',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: widget.height * .02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAverageValue(int percent, double width) {
    String emoji;

    // Determine emoji based on percent
    if (percent >= 1 && percent <= 25) {
      emoji = ' 🥲';
    } else if (percent >= 26 && percent <= 50) {
      emoji = ' 😐';
    } else if (percent >= 51 && percent <= 75) {
      emoji = ' 🙂';
    } else {
      emoji = ' 😃';
    }

    return Row(
      children: [
        ShaderMask(
          shaderCallback: (bounds) {
            Color startColor;
            Color endColor;

            if (percent >= 1 && percent <= 25) {
              startColor = const Color(0xffFF0001);
              endColor = const Color(0xffCE0001);
            } else if (percent >= 26 && percent <= 50) {
              startColor = const Color(0xffF6AE39);
              endColor = const Color(0xffFF7A00);
            } else if (percent >= 51 && percent <= 75) {
              startColor = const Color(0xff005E32);
              endColor = const Color(0xff17B26A);
            } else {
              startColor = const Color(0xff005E77);
              endColor = const Color(0xff002E77);
            }

            return LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Text(
            '${percent.round()}%',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          emoji,
          style: TextStyle(
            fontSize: 15.w,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Color _hexToColor(String hexColor) {
    if (hexColor.isEmpty) return Colors.grey;
    hexColor = hexColor.replaceAll("#", "");
    return Color(int.parse("0xFF$hexColor"));
  }
}

class Modal extends StatelessWidget {
  final String title;
  final String subtitle;
  final String content;

  const Modal({
    required this.title,
    required this.subtitle,
    required this.content,
    super.key,
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

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: width * .02),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: width * .1),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: width * .06,
                  ),
                ),
                IconButton(
                  icon: Image.asset('assets/images/cancel.png'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: width * .04,
              ),
            ),
            SizedBox(height: height * .01),
            Text(
              content,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w300),
            ),
            SizedBox(height: height * .025),
            SizedBox(height: height * .03),
          ],
        ),
      ),
    );
  }
}
