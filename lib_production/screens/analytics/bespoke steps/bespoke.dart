import 'dart:convert';
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

class Bespoke extends StatefulWidget {
  const Bespoke({super.key});
  @override
  _BespokeState createState() => _BespokeState();
}

class _BespokeState extends State<Bespoke> {
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

  @override
  Widget build(BuildContext context) {
    var total = context.watch<Providers>().sevengeemodel.total_bespoke;
    var bespokes = context.watch<Providers>().sevengeemodel.bespokes;
    // var currency = context.watch<Providers>().snapshotmodel.currency;
    double tots = 0;
    // data = data.reversed.toList();

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
        // domainFn: (Kpi kpi, int a) => kpi.kpi.data,
        domainFn: (Kpi kpi, _) =>
            kpi.kpi.data.toString(), // Ignore the second parameter
        measureFn: (Kpi kpi, _) => kpi.value,
      ),
    );

    _seriesRealData.add(
      charts.Series(
        data: data,
        // domainFn: (Kpi kpi, int a) => kpi.kpi.data,
        domainFn: (Kpi kpi, _) => kpi.kpi.data.toString(),
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

    return SingleChildScrollView(
      key: _pageStrKey6,
      child: Container(
        child: Column(
          children: [
            SizedBox(height: height * .04),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Visibility(
                visible: total != 0,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Average Performance: $percent%",
                    style: TextStyle(
                      fontSize: width * .06,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                SizedBox(
                  height: height * .4,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: charts.BarChart(
                      total == 0 ? _seriesData : _seriesRealData,
                      vertical: false,
                      animate: true,
                      animationDuration: const Duration(milliseconds: 1000),
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

                              final prefs =
                                  await SharedPreferences.getInstance();
                              var token = prefs.getString('tokenDB');

                              var response2 = await http.get(
                                url2,
                                headers: {"Authorization": 'Bearer $token'},
                              );

                              Analyticsinfo analyticsinfo =
                                  Analyticsinfo.fromJson(
                                    jsonDecode(response2.body),
                                  );
                              context.read<Providers>().setAnalyticsInfo(
                                analyticsinfo,
                              );

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
                                  (element) =>
                                      element["kpi_name"] ==
                                      model.selectedDatum.first.datum.kpi.data,
                                );
                                var e2 = bespokes2.where(
                                  (element) =>
                                      element["name"] ==
                                      model.selectedDatum.first.datum.kpi.data,
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
                            }
                          },
                        ),
                      ],
                      barRendererDecorator: charts.BarLabelDecorator<String>(),
                    ),
                  ),
                ),
                Visibility(
                  visible: total == 0,
                  child: Container(
                    height: height * .4,
                    width: width,
                    color: Colors.black.withOpacity(.2),
                  ),
                ),
                Visibility(
                  visible: total == 0,
                  child: Container(
                    width:
                        MediaQuery.of(context).size.width *
                        0.9, // 90% of screen width
                    margin: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.02,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        radio(width, height);
                      },
                      child: Text(
                        'Create your First Bespoke KPI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              MediaQuery.of(context).size.width *
                              0.04, // Responsive font size
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * .1),
            Visibility(
              visible: total != 0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  total < 7 ? radio(width, height) : goToEdit();
                },
                child: Text(
                  total < 7 ? 'Add New KPI' : "View All",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
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
    showDialog(context: context, builder: (context) => Bespoke1());
  }
}
