import 'dart:async';
import 'dart:convert';
import 'package:GapHub/screens/SEED/seedash/seedash.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nimble_charts/flutter.dart' as charts;
import 'package:http/http.dart' as http;
import 'package:GapHub/models/chartsmodel.dart';
import 'package:GapHub/widgets/clock_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Expenditure extends StatefulWidget {
  const Expenditure({super.key});
  @override
  _ExpenditureState createState() => _ExpenditureState();
}

class _ExpenditureState extends State<Expenditure> {
  DialogBox dialogBox = DialogBox();
  final List<charts.Series<Kpi, String>> _seriesData = [];
  Map? expenditureData;
  Map? expenditureDataLite;
  String? currency;

  addData(value, currency) {
    _seriesData.add(
      charts.Series(
        data: [
          Kpi(
            kpi: const Text("Accomodat..."),
            value: double.parse(value[0].toString()),
            gradientColors: [const Color(0xff8C8D86), const Color(0xff8C8D86)],
          ),
          Kpi(
            kpi: const Text("Mobility"),
            value: double.parse(value[1].toString()),
            gradientColors: [const Color(0xff8C8D86), const Color(0xff8C8D86)],
          ),
          Kpi(
            kpi: const Text("General"),
            value: double.parse(value[2].toString()),
            gradientColors: [const Color(0xff8C8D86), const Color(0xff8C8D86)],
          ),

          Kpi(
            kpi: const Text("Utilities"),
            value: double.parse(value[3].toString()),
            gradientColors: [const Color(0xff8C8D86), const Color(0xff8C8D86)],
          ),
          Kpi(
            kpi: const Text("Debt"),
            value: double.parse(value[4].toString()),
            gradientColors: [const Color(0xff8C8D86), const Color(0xff8C8D86)],
          ),
          // Kpi(kpi: '', value: 100, colorVal: 0xfffffff)
        ],
        // domainFn: (Kpi kpi, int a) => kpi.kpi.data,
        domainFn: (Kpi kpi, _) => kpi.kpi.data!,
        measureFn: (Kpi kpi, _) => kpi.value,
        colorFn: (Kpi kpi, _) =>
            charts.ColorUtil.fromDartColor(kpi.gradientColors.first),
        // outsideLabelStyleAccessorFn: (Kpi kpi, _) =>
        //     charts.TextStyleSpec(color: charts.MaterialPalette.red.shadeDefault),
        // fillPatternFn: (_, __) => charts.FillPatternType.solid,
        id: 'Expenditure',
        domainLowerBoundFn: (datum, index) => datum.kpi.data,
        labelAccessorFn: (Kpi kpi, _) =>
            '$currency${(kpi.value).toInt()}'.replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            ),
      ),
    );
  }

  @override
  void initState() {
    setState(() => expenditureData = context.read<Providers>().expenditureList);
    setState(
      () => expenditureDataLite = context.read<Providers>().expenditureListLite,
    );
    currency = context.read<Providers>().currency;
    print("expenditureDataLite: ${expenditureDataLite!["values"]}");
    addData(expenditureDataLite!["values"], currency);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var expenditureDataLite = widget.expenditureDataLite;
    expenditureDataLite!["values"];
    List<dynamic> lists = expenditureDataLite!["values"];
    var sum = lists.reduce((value, current) => value + current);

    print(sum);
    String currency = context.watch<Providers>().snapshotmodel.currency;

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expenditure',
          style: TextStyle(fontSize: width * .06, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNav(4),
      body: ListView(
        children: [
          SizedBox(height: height * .01),
          Center(
            child: Text(
              "Cost of Living: $currency${sum.toStringAsFixed(2)}"
                  .replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  ),
              style: TextStyle(
                fontSize: width * .06,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: height * .01),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * .02,
                vertical: height * .02,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width * .01),
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                child: Text(
                  "This is the amount you spend on your upkeep as an individual or a family.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: width * .04,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: height * .03),
          Center(
            child: Text(
              "Your Average Cost of Living",
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontSize: width * .06,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(height: height * .01),
          ListView.builder(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemCount: expenditureDataLite!["labels"].length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .02),
              child: Card(
                elevation: 3,
                color: const Color(0xff989898),
                child: ListTile(
                  onTap: () {},
                  title: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "${expenditureDataLite!["labels"][index] == "debt_repayment" ? "Debt Repayment" : expenditureDataLite!["labels"][index].replaceFirst(expenditureDataLite!["labels"][index][0], expenditureDataLite!["labels"][index][0].toUpperCase())} - ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * .04,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        TextSpan(
                          text:
                              "$currency${expenditureDataLite!["values"][index].toStringAsFixed(2)} "
                                  .replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]},',
                                  ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * .04,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: height * .05),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * .02),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(width * .03),
                ),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              onPressed: seed,
              child: Container(
                padding: EdgeInsets.zero,
                height: height * .06,
                // width: width * .5,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Set Budget in SEED',
                    style: TextStyle(
                      color: const Color(0xfff3f3f4),
                      fontWeight: FontWeight.w900,
                      fontSize: width * .05,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: height * .05, child: const Divider(thickness: 2)),
          Center(
            child: Text(
              "Cost of Living Distribution",
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontSize: width * .06,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(height: height * .01),
          Container(
            height: height * .4,
            padding: const EdgeInsets.all(8),
            child: charts.BarChart(
              _seriesData,
              animate: true,
              vertical: true,
              barRendererDecorator: charts.BarLabelDecorator<String>(),
              animationDuration: const Duration(milliseconds: 1000),
            ),
          ),
          SizedBox(height: height * .05, child: const Divider(thickness: 2)),
          const ClockWidget(3),
          SizedBox(height: height * .05),
        ],
      ),
    );
  }

  seed() async {
    var url = Uri.parse("$baseUrl/app/seed");
    var timer = Timer(const Duration(seconds: 50), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, 'Loading');
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await http.get(
      url,
      headers: {"Authorization": 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);

      context.read<Providers>().setSeeData(body);
      timer.cancel();
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Seedash()),
      );
    } else {
      timer.cancel();
      Navigator.pop(context);
    }
  }
}
