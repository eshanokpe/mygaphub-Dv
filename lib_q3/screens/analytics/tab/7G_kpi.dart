import 'dart:async';
import 'dart:convert';
import 'package:GapHub/screens/analytics/edits/alpha.dart';
import 'package:GapHub/screens/analytics/edits/beta.dart';
import 'package:GapHub/screens/analytics/edits/credit.dart';
import 'package:GapHub/screens/analytics/edits/debt.dart';
import 'package:GapHub/screens/analytics/edits/editpage.dart';
import 'package:GapHub/screens/analytics/edits/education.dart';
import 'package:GapHub/screens/analytics/edits/freedom.dart';
import 'package:GapHub/screens/analytics/edits/grand.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/models/chartsmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nimble_charts/flutter.dart' as charts;

class SevenGKPI extends StatefulWidget {
  final double height;
  final double average;
  final double width;
  final List<charts.Series<Kpi, String>> _seriesData;
  final List<int> realColors;
  final bool contains;

  const SevenGKPI({
    super.key,
    required this.height,
    required this.average,
    required this.width,
    required List<charts.Series<Kpi, String>> seriesData,
    required this.realColors,
    required this.contains,
  }) : _seriesData = seriesData;

  @override
  State<SevenGKPI> createState() => _SevenGKPIState();
}

class _SevenGKPIState extends State<SevenGKPI> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: widget.height * .03),
        Visibility(
          visible: !widget.contains,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.width * .03),
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
                _buildAverageValue(),
              ],
            ),
          ),
        ),
        Stack(
          alignment: AlignmentDirectional.center,
          children: [
            SizedBox(
              height: widget.height * .4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: charts.BarChart(
                    widget._seriesData,
                    animate: true,
                    selectionModels: [
                      charts.SelectionModelConfig(
                        type: charts.SelectionModelType.info,
                        changedListener: (model) async {
                          if (model.selectedDatum.first.datum.kpi.data
                              .toString()
                              .isNotEmpty) {
                            var timer = Timer(
                              const Duration(milliseconds: 20000),
                              () {
                                dialogBox.information(
                                  context,
                                  'Status',
                                  'Service timed out',
                                );
                                // Navigator.pop(context);
                                return;
                              },
                            );
                            dialogBox.waiting(context, 'Loading');
                            var url = Uri.parse('$baseUrl/app/seveng/edit');

                            final prefs = await SharedPreferences.getInstance();
                            String? finalToken = prefs.getString('tokenDB');

                            var response = await http.get(
                              url,
                              headers: {"Authorization": 'Bearer $finalToken'},
                            );

                            if (response.statusCode == 200) {
                              //var expendituredata = dd["data"]['grand'];
                              var body = jsonDecode(response.body);
                              var analyticsdata = body["data"];
                              // print('Analyticsdata:$analyticsdata');
                              Analyticsinfo analyticsinfo =
                                  Analyticsinfo.fromJson(analyticsdata);

                              context.read<Providers>().setAnalyticsInfo(
                                analyticsinfo,
                              );

                              switch (model
                                  .selectedDatum
                                  .first
                                  .datum
                                  .kpi
                                  .data) {
                                case 'Grand':
                                  timer.cancel();
                                  Navigator.pop(context);
                                  final mainValue =
                                      analyticsinfo.grand?['main']
                                          ?.toString() ??
                                      '';
                                  final newUser =
                                      mainValue.isEmpty || mainValue == 'null';
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Grand(
                                        grandInfo: analyticsinfo,
                                        contains: newUser,
                                        newUser: newUser,
                                      ),
                                    ),
                                  );
                                  break;
                                case 'Freedom':
                                  timer.cancel();
                                  Navigator.pop(context);
                                  final mainValue =
                                      analyticsinfo.grand?['main']
                                          ?.toString() ??
                                      '';
                                  final newUser =
                                      mainValue.isEmpty || mainValue == 'null';
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Freedom(
                                        freedomInfo: analyticsinfo,
                                        newUser: newUser,
                                      ),
                                    ),
                                  );
                                  break;
                                case 'Education':
                                  timer.cancel();
                                  Navigator.pop(context);
                                  final mainValue =
                                      analyticsinfo.grand?['main']
                                          ?.toString() ??
                                      '';
                                  final newUser =
                                      mainValue.isEmpty || mainValue == 'null';
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Education(
                                        educationInfo: analyticsinfo,
                                        newUser: newUser,
                                        contains: newUser,
                                      ),
                                    ),
                                  );
                                  break;
                                case 'Debt':
                                  timer.cancel();
                                  Navigator.pop(context);
                                  final mainValue =
                                      analyticsinfo.grand?['main']
                                          ?.toString() ??
                                      '';
                                  final newUser =
                                      mainValue.isEmpty || mainValue == 'null';
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Debt(
                                        debtInfo: analyticsinfo,
                                        newUser: newUser,
                                        contains: newUser,
                                      ),
                                    ),
                                  );
                                  break;
                                case 'Credit':
                                  timer.cancel();
                                  Navigator.pop(context);
                                  final mainValue =
                                      analyticsinfo.grand?['main']
                                          ?.toString() ??
                                      '';
                                  final newUser =
                                      mainValue.isEmpty || mainValue == 'null';
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Credit(
                                        creditInfo: analyticsinfo,
                                        newUser: newUser,
                                        contains: newUser,
                                      ),
                                    ),
                                  );
                                  break;
                                case 'Beta':
                                  timer.cancel();
                                  Navigator.pop(context);
                                  final mainValue =
                                      analyticsinfo.grand?['main']
                                          ?.toString() ??
                                      '';
                                  final newUser =
                                      mainValue.isEmpty || mainValue == 'null';
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Beta(
                                        betaInfo: analyticsinfo,
                                        newUser: newUser,
                                        contains: newUser,
                                      ),
                                    ),
                                  );
                                  break;
                                case 'Alpha':
                                  timer.cancel();
                                  Navigator.pop(context);
                                  final mainValue =
                                      analyticsinfo.grand?['main']
                                          ?.toString() ??
                                      '';
                                  final newUser =
                                      mainValue.isEmpty || mainValue == 'null';
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Alpha(
                                        newUser: newUser,
                                        alphaInfo: analyticsinfo,
                                        contains: newUser,
                                      ),
                                    ),
                                  );
                                  break;
                                default:
                              }
                            } else {
                              timer.cancel();
                              Navigator.pop(context);
                            }
                          }
                        },
                      ),
                    ],
                    vertical: false,
                    barRendererDecorator: charts.BarLabelDecorator<String>(),
                    behaviors: [
                      charts.SeriesLegend(
                        position: charts.BehaviorPosition.bottom,
                        outsideJustification:
                            charts.OutsideJustification.middleDrawArea,
                        horizontalFirst: false,
                        cellPadding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        entryTextStyle: const charts.TextStyleSpec(
                          color: charts.MaterialPalette.black,
                          fontSize: 14,
                          fontWeight: 'w700',
                        ),
                      ),
                      // charts.ChartTitle('Your KPI Chart'),
                    ],
                    defaultRenderer: charts.BarRendererConfig<String>(
                      cornerStrategy: const charts.ConstCornerStrategy(12),
                      barRendererDecorator: charts.BarLabelDecorator<String>(),
                      maxBarWidthPx: 30,
                    ),
                    animationDuration: const Duration(milliseconds: 1000),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: widget.height * .4,
              // color: Colors.amber.withOpacity(.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: widget.height * .085),
                  InkWell(
                    onTap: () {
                      _showPickerEdit(
                        context,
                        "Grand",
                        '(A measure of your benevolence)',
                        'Giving is Living! You will be able to measure how much you are giving away to charity as a percentage of how much you are spending on yourself or in your family.',
                      );
                    },
                    child: SizedBox(
                      // color: Colors.green.withOpacity(.5),
                      width: widget.width * .17,
                      height: widget.height * .02,
                    ),
                  ),
                  SizedBox(height: widget.height * .022),
                  InkWell(
                    onTap: () {
                      _showPickerEdit(
                        context,
                        "Freedom",
                        '(A measure of your progress on your path to financial freedom)',
                        'Path to freedom is a measure of the average monthly income from your asset portfolio as a percentage of your average monthly expenditure. ',
                      );
                    },
                    child: SizedBox(
                      // color: Colors.green.withOpacity(.5),
                      width: widget.width * .17,
                      height: widget.height * .02,
                    ),
                  ),
                  SizedBox(height: widget.height * .022),
                  InkWell(
                    onTap: () {
                      _showPickerEdit(
                        context,
                        "Education",
                        '(A measure of how much you have saved up for your kids university education)',
                        'This helps your children avoid debt from student loans. So it tracks how much you are saving towards their university education.',
                      );
                    },
                    child: SizedBox(
                      // color: Colors.green.withOpacity(.5),
                      width: widget.width * .17,
                      height: widget.height * .02,
                    ),
                  ),
                  SizedBox(
                    height: widget.height * .022,
                    width: widget.width * .17,
                  ),
                  InkWell(
                    onTap: () {
                      _showPickerEdit(
                        context,
                        "Debt",
                        '(A measure of what you owe on your primary place of residence - own home)',
                        'This will help you track the progress of the repayment of the mortgage you took out to buy your primary place of residence.',
                      );
                    },
                    child: SizedBox(
                      // color: Colors.green.withOpacity(.5),
                      width: widget.width * .17,
                      height: widget.height * .02,
                    ),
                  ),
                  SizedBox(height: widget.height * .022),
                  InkWell(
                    onTap: () {
                      _showPickerEdit(
                        context,
                        "Credit",
                        '(Loans, credit cards, HPIs, all unsecured debt)',
                        'This tracks the progress you make as you pay off all your unsecured debts with the goal of becoming debt (unsecured) free.',
                      );
                    },
                    child: SizedBox(
                      // color: Colors.green.withOpacity(.5),
                      width: widget.width * .17,
                      height: widget.height * .02,
                    ),
                  ),
                  SizedBox(height: widget.height * .022),
                  InkWell(
                    onTap: () {
                      _showPickerEdit(
                        context,
                        "Beta",
                        '(A measure of your house purchase funds saved up)',
                        'If you are yet to buy your own residential property, this is a measure of money being saved up to buy your own home.',
                      );
                    },
                    child: SizedBox(
                      // color: Colors.green.withOpacity(.5),
                      width: widget.width * .17,
                      height: widget.height * .02,
                    ),
                  ),
                  SizedBox(height: widget.height * .022),
                  InkWell(
                    onTap: () {
                      // dialogBox.information(context, 'title', 'Alpha');

                      _showPickerEdit(
                        context,
                        "Alpha",
                        'A measure of your asset growth fund (AGF)',
                        'This is the measure of your asset growth Fund that is saved up for the sole purpose of covering your living expenses in the case of loss of primary source of income.',
                      );
                    },
                    child: SizedBox(
                      // color: Colors.green.withOpacity(.5),
                      width: widget.width * .17,
                      height: widget.height * .02,
                    ),
                  ),
                  SizedBox(height: widget.height * .022),
                  Container(
                    // color: Colors.green.withOpacity(.5),
                    height: widget.height * .02,
                  ),
                ],
              ),
            ),
          ],
        ),
        // _buildPercentage(),
        _buildEditKPI(),
      ],
    );
  }

  void _showPickerEdit(context, String title, String subtitle, String content) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return GestureDetector(
          onTap: null,
          behavior: HitTestBehavior.opaque,
          child: Modal(title: title, subtitle: subtitle, content: content),
        );
      },
    );
  }

  Widget _buildPercentage() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            right: widget.width * .05,
            left: widget.width * .17,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  height: widget.height * .015,
                  child: Text(
                    '25',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: widget.width * .025,
                      color: Colors.white,
                    ),
                  ),
                  color: const Color(0xffff0000),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  color: const Color(0xffffc200),
                  child: Text(
                    '50',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: widget.width * .025,
                      color: Colors.white,
                    ),
                  ),
                  height: widget.height * .015,
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  color: const Color(0xff00ff00),
                  child: Text(
                    '75',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: widget.width * .025,
                      color: Colors.white,
                    ),
                  ),
                  height: widget.height * .015,
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  child: Text(
                    '100',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: widget.width * .025,
                      color: Colors.white,
                    ),
                  ),
                  color: const Color(0xff65B8E8),
                  height: widget.height * .015,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: widget.height * .01),
      ],
    );
  }

  Widget _buildEditKPI() {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: widget.width * .03),
            Image.asset(
              'assets/icons/rec_info.png',
              width: 16.w,
              fit: BoxFit.contain,
            ),
            Expanded(
              child: Text(
                'Tap any of the KPI names (Alpha, Beta, Credit e.t.c.) to learn more.',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
        Visibility(
          visible: !widget.contains,
          child: SizedBox(height: widget.height * .02),
        ),
        Visibility(
          visible: widget.contains,
          child: SizedBox(height: widget.height * .02),
        ),
        Visibility(
          visible: widget.contains,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Container(
                    height: widget.height * .02,
                    width: widget.width * .04,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xffff0000),
                    ),
                  ),
                  Container(
                    height: widget.height * .02,
                    width: widget.width * .04,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xffffc200),
                    ),
                  ),
                  Container(
                    height: widget.height * .02,
                    width: widget.width * .04,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xff00ff00),
                    ),
                  ),
                  Container(
                    height: widget.height * .02,
                    width: widget.width * .04,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xff65B8E8),
                    ),
                  ),
                  SizedBox(width: widget.width * .02),
                  const Text(
                    'Validated KPI\'s',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    height: widget.height * .02,
                    width: widget.width * .04,
                    color: const Color(0XFF424242),
                  ),
                  SizedBox(width: widget.width * .02),
                  const Text(
                    'Unvalidated KPI\'s',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: widget.height * .05),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.width * .02),
            ),
          ),
          onPressed: () async {
            var timer = Timer(const Duration(milliseconds: 20000), () {
              Navigator.pop(context);
              dialogBox.information(context, 'Status', 'Service timed out');
              return;
            });
            dialogBox.waiting(context, 'Loading');
            var url = Uri.parse('$baseUrl/app/seveng/edit');

            final prefs = await SharedPreferences.getInstance();
            String? finalToken = prefs.getString('tokenDB');

            var response = await http.get(
              url,
              headers: {"Authorization": 'Bearer $finalToken'},
            );

            if (response.statusCode == 200) {
              //var expendituredata = dd["data"]['grand'];
              var body = jsonDecode(response.body);
              var analyticsdata = body["data"];

              Analyticsinfo analyticsinfo = Analyticsinfo.fromJson(
                analyticsdata, 
              );
              context.read<Providers>().setAnalyticsInfo(analyticsinfo);
              Navigator.pop(context);
              timer.cancel();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Editpage(
                    widget.realColors,
                    analyticsinfo,
                    widget.contains,
                  ),
                ),
              );
            }
          },
          child: Container(
            padding: EdgeInsets.zero,
            height: height * .05,
            width: width * .29,
            child: Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/edit_all.png',
                    height: height * .04,
                    width: width * .04,
                  ),
                  SizedBox(width: width * .02),
                  Text(
                    widget.contains ? 'Edit All' : 'View All',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * .04,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAverageValue() {
    String emoji;

    // Determine emoji based on widget.average
    if (widget.average >= 1 && widget.average <= 25) {
      emoji = ' 🥲';
    } else if (widget.average >= 26 && widget.average <= 50) {
      emoji = ' 😐';
    } else if (widget.average >= 51 && widget.average <= 75) {
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

            if (widget.average >= 1 && widget.average <= 25) {
              startColor = const Color(0xffFF0001);
              endColor = const Color(0xffCE0001);
            } else if (widget.average >= 26 && widget.average <= 50) {
              startColor = const Color(0xffF6AE39);
              endColor = const Color(0xffFF7A00);
            } else if (widget.average >= 51 && widget.average <= 75) {
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
            '${widget.average.round()}%',
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
            fontSize: widget.width * .05,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
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
