import 'dart:convert';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/models/chartsmodel.dart';
import 'package:GapHub/screens/analytics/bespoke%20steps/bespoke1.dart';
import 'package:GapHub/screens/analytics/bespoke%20steps/bespokedetails.dart';
import 'package:GapHub/screens/analytics/bespoke%20steps/editbespoke.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:nimble_charts/flutter.dart' as charts;
import 'package:provider/provider.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../../../widgets/custom_button.dart';

class BespokeKPI extends StatefulWidget {
  const BespokeKPI({super.key});
  @override
  _BespokeKPIState createState() => _BespokeKPIState();
}

class _BespokeKPIState extends State<BespokeKPI> {
  final Key _pageStrKey6 = const PageStorageKey('pagesix');
  List<charts.Series<Kpi, String>> _seriesData = [];
  List<charts.Series<Kpi, String>> _seriesRealData = [];
  DialogBox dialogBox = DialogBox();
  Dio dio = Dio();

  int selectedRadio = 0;
  @override
  void initState() {
    super.initState();
    _seriesData = [];
    _seriesRealData = [];
  }

  final colors = [
    Colors.red,
    Colors.redAccent,
    Colors.orange,
    Colors.orange,
    Colors.green,
    Colors.green,
    Colors.blue,
  ];

  @override
  Widget build(BuildContext context) {
    var total = context.watch<Providers>().sevengeemodel.total_bespoke;
    var bespokes = context.watch<Providers>().sevengeemodel.bespokes;
    double tots = 0;

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    _seriesData = [];
    _seriesRealData = [];
    for (var i = 0; i < 7; i++) {
      var ans = bespokes[i]["value"].toString().isEmpty
          ? 0
          : double.parse(bespokes[i]["value"].toString());
      tots = (tots + ans);
    }
    var percent = tots == 0 ? 0 : (tots / total).round();
    var data = [
      Kpi(
        kpi: Text(bespokes[0]["name"]),
        value: bespokes[0]["name"].isEmpty
            ? 100
            : double.parse(bespokes[0]["value"].toString()),
        gradientColors: bespokes[0]["bg"].isEmpty
            ? [const Color(0xff00ff001c)]
            : [
                Color(
                  int.parse("0xff${bespokes[0]["bg"].toString().substring(1)}"),
                ),
              ],
      ),
      Kpi(
        kpi: Text(bespokes[1]["name"]),
        value: bespokes[1]["name"].isEmpty
            ? 90
            : double.parse(bespokes[1]["value"].toString()),
        gradientColors: bespokes[1]["bg"].isEmpty
            ? [const Color(0xff00ff001c)]
            : [
                Color(
                  int.parse("0xff${bespokes[1]["bg"].toString().substring(1)}"),
                ),
              ],
      ),
      Kpi(
        kpi: Text(bespokes[2]["name"]),
        value: bespokes[2]["name"].isEmpty
            ? 100
            : double.parse(bespokes[2]["value"].toString()),
        gradientColors: bespokes[2]["bg"].isEmpty
            ? [const Color(0xff00ff001c)]
            : [
                Color(
                  int.parse("0xff${bespokes[2]["bg"].toString().substring(1)}"),
                ),
              ],
      ),
      Kpi(
        kpi: Text(bespokes[3]["name"]),
        value: bespokes[3]["name"].isEmpty
            ? 99
            : double.parse(bespokes[3]["value"].toString()),
        gradientColors: bespokes[3]["bg"].isEmpty
            ? [const Color(0xff00ff001c)]
            : [
                Color(
                  int.parse("0xff${bespokes[3]["bg"].toString().substring(1)}"),
                ),
              ],
      ),
      Kpi(
        kpi: Text(bespokes[4]["name"]),
        value: bespokes[4]["name"].isEmpty
            ? 80
            : double.parse(bespokes[4]["value"].toString()),
        gradientColors: bespokes[4]["bg"].isEmpty
            ? [const Color(0xff00ff001c)]
            : [
                Color(
                  int.parse("0xff${bespokes[4]["bg"].toString().substring(1)}"),
                ),
              ],
      ),
      Kpi(
        kpi: Text(bespokes[5]["name"]),
        value: bespokes[5]["name"].isEmpty
            ? 90
            : double.parse(bespokes[5]["value"].toString()),
        gradientColors: bespokes[5]["bg"].isEmpty
            ? [const Color(0xff00ff001c)]
            : [
                Color(
                  int.parse("0xff${bespokes[5]["bg"].toString().substring(1)}"),
                ),
              ],
      ),
      Kpi(
        kpi: Text(bespokes[6]["name"]),
        value: bespokes[6]["name"].isEmpty
            ? 100
            : double.parse(bespokes[6]["value"].toString()),
        gradientColors: bespokes[6]["bg"].isEmpty
            ? [const Color(0xff00ff001c)]
            : [
                Color(
                  int.parse("0xff${bespokes[6]["bg"].toString().substring(1)}"),
                ),
              ],
      ),
      Kpi(
        kpi: const Text(''),
        value: 100,
        gradientColors: [const Color(0xff00ff001c)],
      ),
    ];
    _seriesData.add(
      charts.Series(
        id: "",
        data: [
          Kpi(
            kpi: const Text(''),
            value: 100,
            gradientColors: [const Color(0xff00ff001c)],
          ),
          Kpi(
            kpi: const Text(''),
            value: 100,
            gradientColors: [const Color(0xff00ff001c)],
          ),
          Kpi(
            kpi: const Text(''),
            value: 100,
            gradientColors: [const Color(0xff00ff001c)],
          ),
          Kpi(
            kpi: const Text(''),
            value: 100,
            gradientColors: [const Color(0xff000000)],
          ),
          Kpi(
            kpi: const Text(''),
            value: 100,
            gradientColors: [const Color(0xff00ff001c)],
          ),
          Kpi(
            kpi: const Text(''),
            value: 100,
            gradientColors: [const Color(0xff00ff001c)],
          ),
          Kpi(
            kpi: const Text(''),
            value: 100,
            gradientColors: [const Color(0xff00ff001c)],
          ),
        ],
        domainFn: (Kpi kpi, _) => kpi.kpi.data!,
        measureFn: (Kpi kpi, _) => kpi.value,
      ),
    );

    _seriesRealData.add(
      charts.Series(
        data: data,
        domainFn: (Kpi kpi, _) => kpi.kpi.data!,
        measureFn: (Kpi kpi, _) => kpi.value,
        colorFn: (Kpi kpi, _) =>
            charts.ColorUtil.fromDartColor((kpi.gradientColors.first)),
        outsideLabelStyleAccessorFn: (Kpi kpi, _) => charts.TextStyleSpec(
          color: charts.MaterialPalette.red.shadeDefault,
        ),
        fillPatternFn: (_, __) => charts.FillPatternType.solid,

        id: 'Bespoke KPI',
        // domainLowerBoundFn: (datum, index) => datum.kpi.data,
        labelAccessorFn: (Kpi kpi, _) => '${(kpi.value).toInt()}%',
      ),
    );

    return ListView(
      key: _pageStrKey6,
      children: [
        SizedBox(height: height * .02),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * .03),
          child: Visibility(
            visible: total != 0,
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .0),
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
                    _buildAverageValue(percent, width),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: height * .03),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bespokes.length,
          itemBuilder: (context, index) {
            final item = bespokes[index];

            int progress = int.tryParse(item["value"].toString()) ?? 0;
            if (item["name"].toString().isEmpty) {
              return const SizedBox.shrink();
            }
            return ProgressCard(
              title: item["name"],
              progress: progress,
              // color: _hexToColor(item["bg"]),
              color: colors[index],
            );
          },
        ),
        Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Visibility(
              visible: total == 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/analytic/bespoke.png',
                    width: width * .60,
                  ),
                  SizedBox(height: height * .04),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(
                      horizontal: width * 0.07,
                      vertical: height * 0.013,
                    ),
                    height:
                        height *
                        0.06, // increased slightly for better touch target
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.04,
                          vertical: height * 0.01,
                        ),
                      ),
                      onPressed: () {
                        radio(width, height);
                      },
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add, color: Colors.white),
                            SizedBox(width: width * 0.02),
                            Text(
                              "Create your First Bespoke KPI",
                              style: TextStyle(
                                color: const Color(0xfff3f3f4),
                                fontWeight: FontWeight.w600,
                                fontSize: width * 0.04, // responsive font size
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
          ],
        ),
        SizedBox(height: height * .1),
        Visibility(
          visible: total != 0,
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/info.png', width: 16.w),
                  SizedBox(width: width * .01),
                  Text(
                    "Tap on the KPI's to learn more",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grayColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * .03),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 8.w,
                  ),
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    // Added shape
                    borderRadius: BorderRadius.circular(width * .02),
                  ), // Reduced borderRadius
                ),
                onPressed: () {
                  total < 7 ? radio(width, height) : goToEdit();
                },
                child: Row(
                  mainAxisSize: MainAxisSize
                      .min, // Ensure button size is just enough for content
                  children: [
                    Icon(
                      Icons.add, // Use your desired icon here
                      color: Colors.white,
                      size: 20.h,
                    ),
                    const SizedBox(width: 8), // Space between the icon and text
                    Text(
                      total < 7 ? ' Add KPI' : "View All",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void goToEdit() async {
    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, 'Loading');
    String url = "$baseUrl/app/bespoke";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    if (response.statusCode == 200) {
      List bespokes = response.data["user_bespokes"];
      List bespokes2 = response.data["bespokes"];
      int total = response.data["total_bespoke"];
      Navigator.pop(context);
      timer.cancel();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Editbespoke(
            total: total,
            bespokes: bespokes,
            bespokes2: bespokes2,
          ),
        ),
      );
    } else {
      Navigator.pop(context);
      timer.cancel();
    }
  }

  void radio(width, height) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled:
          true, // Allows the sheet to be larger and adapt more flexibly
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(
          context,
        ).size.width, // Ensure the sheet can use the full screen width
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Bespoke1(),
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
            fontSize: width * .05,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Color _hexToColor(String hexColor) {
    if (hexColor.isEmpty) return Colors.grey; // Default color for empty bg
    hexColor = hexColor.replaceAll("#", "");
    return Color(int.parse("0xFF$hexColor"));
  }
}

class ProgressCard extends StatelessWidget {
  final String title;
  final int progress;
  final Color color;

  const ProgressCard({
    super.key,
    required this.title,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    DialogBox dialogBox = DialogBox();
    Dio dio = Dio();
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    Color endColor;
    Color startColor;

    if (progress >= 1 && progress <= 25) {
      startColor = const Color(0xffFF0001);
      endColor = const Color(0xffCE0001);
    } else if (progress >= 26 && progress <= 50) {
      startColor = const Color(0xffF6AE39);
      endColor = const Color(0xffFF7A00);
    } else if (progress >= 51 && progress <= 75) {
      startColor = const Color(0xff005E32);
      endColor = const Color(0xff17B26A);
    } else if (progress >= 76 && progress <= 100) {
      startColor = const Color(0xff005E77);
      endColor = const Color(0xff002E77);
    } else {
      // Default colors if progress is outside the range
      startColor = Colors.grey;
      endColor = Colors.grey.withOpacity(0.9);
    }
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * .03,
        vertical: height * .005,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _showBottomSheet(context, title);
            },
            child: SizedBox(
              width: width * 0.16,
              child: Text(
                title,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: width * 0.04,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(width: width * .02),
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 29.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress / 100, // Progress in percentage
                  child: GestureDetector(
                    onTap: () async {
                      var timer = Timer(
                        const Duration(milliseconds: 20000),
                        () {
                          Navigator.pop(context);
                          dialogBox.information(
                            context,
                            'Status',
                            'Service timed out',
                          );
                          return;
                        },
                      );
                      dialogBox.waiting(context, 'Loading');
                      String url = "$baseUrl/app/bespoke";
                      var url2 = Uri.parse('$baseUrl/app/seveng/edit');

                      final prefs = await SharedPreferences.getInstance();
                      var token = prefs.getString('tokenDB');

                      var response2 = await http.get(
                        url2,
                        headers: {"Authorization": 'Bearer $token'},
                      );
                      var data = jsonDecode(response2.body);
                      Analyticsinfo analyticsinfo = Analyticsinfo.fromJson(
                        data['data'],
                      );
                      context.read<Providers>().setAnalyticsInfo(analyticsinfo);

                      var response = await dio.get(
                        url,
                        options: Options(
                          headers: {"Authorization": 'Bearer $token'},
                        ),
                      );
                      if (response.statusCode == 200) {
                        List bespokes = response.data["user_bespokes"];
                        List bespokes2 = response.data["bespokes"];

                        var e = bespokes.where(
                          (element) => element["kpi_name"] == title,
                        );
                        var e2 = bespokes2.where(
                          (element) => element["name"] == title,
                        );

                        Navigator.pop(context);
                        timer.cancel();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Bespokedetails(e.toList(), e2.toList()),
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                        timer.cancel();
                      }
                    },
                    child: Container(
                      height: 29.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [startColor, endColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        // gradient: LinearGradient(
                        //   colors: [color.withOpacity(0.7), color],
                        //   begin: Alignment.topLeft,
                        //   end: Alignment.bottomRight,
                        // ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Row(
                          children: [
                            Text(
                              "$progress%",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: width * .035,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  right: 0,
                  child: Icon(Icons.chevron_right, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      // isDismissible: false,
      backgroundColor: Colors.white,
      isScrollControlled:
          true, // Allows the sheet to be larger and adapt more flexibly
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(
          context,
        ).size.width, // Ensure the sheet can use the full screen width
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        Orientation orientation = MediaQuery.of(context).orientation;
        final height = orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height
            : MediaQuery.of(context).size.width;
        final width = orientation == Orientation.portrait
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.height;
        return Padding(
          padding: EdgeInsets.all(width * .03),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Divider(
                    color: const Color(0xffcdcdcd),
                    height: height * .02,
                    thickness: 5,
                    indent: width * .38,
                    endIndent: width * .38,
                  ),
                ),
              ),
              Text(
                title,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height * .005),
              Text(
                'Saving up Target',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: height * .01),
              Text(
                'We truly regret any inconvenience you may have faced. Kindly provide us with the details of your inquiry, and our support team will get in touch with you promptly.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: height * .02),
              CustomButton(
                text: 'Close',
                fontSize: 16.sp,
                isLoading: false,
                borderRadius: 30,
                borderColor: const Color(0xffC8CECC),
                onPressed: () => Navigator.pop(context),
                color: Colors.white,
                textColor: Colors.black,
              ),
              SizedBox(height: height * 0.03),
            ],
          ),
        );
      },
    );
  }
}
