import 'package:GapHub/models/chartsmodel.dart';
import 'package:GapHub/screens/360/accounts/retirement/presentation/retiredash.dart';
import 'package:flutter/material.dart';
import 'package:nimble_charts/flutter.dart' as charts;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/utils/constants.dart';
import 'dart:async';
import 'package:GapHub/screens/360/accounts/cash/cashitem.dart';
import 'package:GapHub/screens/360/accounts/mortgage/mortgageitem.dart';
import 'package:GapHub/screens/360/accounts/philanthropy/setgiving.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/screens/360/accounts/liabilities/liabilitydetails.dart';
import 'package:GapHub/screens/360/threesixty.dart';

class Seveng extends StatefulWidget {
  final Map data;
  final bool baseline;
  final String title;
  final String subtitle;
  const Seveng({
    super.key,
    required this.data,
    required this.title,
    required this.subtitle,
    this.baseline = false,
  });
  @override
  _SevengState createState() => _SevengState();
}

class _SevengState extends State<Seveng> {
  List<charts.Series<Networths, String>> _seriesBarData = [];
  _generateBarData(List values, bool baseline, String currency) {
    print("value:${values.length}");
    // Check if the values list has at least two elements

    var data = baseline
        ? [
            Networths(
              name: 'Baseline',
              value: values[0],
              colorVal: '0XFF56EC6F',
            ),
            Networths(
              name: 'Current',
              value: values[1],
              colorVal: '0XFFF8373C',
            ),
          ]
        : [
            Networths(
              name: 'Current',
              value: values[0],
              colorVal: '0XFF56EC6F',
            ),
            Networths(name: 'Target', value: values[1], colorVal: '0XFFF8373C'),
          ];

    _seriesBarData.add(
      charts.Series(
        data: data,
        domainFn: (Networths net, _) => net.name,
        measureFn: (Networths net, _) => net.value,
        colorFn: (Networths net, _) =>
            charts.ColorUtil.fromDartColor(Color(int.parse(net.colorVal))),
        fillPatternFn: (_, __) => charts.FillPatternType.solid,
        id: 'Finance Snapshot',
        labelAccessorFn: (Networths net, _) =>
            '$currency${net.value}'.replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            ),
      ),
    );
  }

  Analyticsinfo? creditInfo;
  DialogBox dialogBox = DialogBox();
  Dio dio = Dio();
  @override
  void initState() {
    super.initState();
    _seriesBarData = [];
    String currency = splitit(context.read<Providers>().currency);
    double baselineValue =
        double.tryParse(widget.data["baseline"]?.toString() ?? '0.0') ?? 0.0;
    double currentValue =
        double.tryParse(widget.data["current"]?.toString() ?? '0.0') ?? 0.0;
    double targetValue =
        double.tryParse(widget.data["target"]?.toString() ?? '0.0') ?? 0.0;

    print("baselineValue:$baselineValue");
    print("currentValue:$currentValue");
    print("targetValue:$targetValue");

    if (widget.baseline) {
      _generateBarData(
        [baselineValue, currentValue],
        widget.baseline,
        currency,
      );
    } else {
      if (targetValue == 0.0) {
        targetValue = baselineValue;
      }
      _generateBarData([currentValue, targetValue], widget.baseline, currency);
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

    String currency = context.watch<Providers>().snapshotmodel.currency;
    creditInfo = context.watch<Providers>().analyticsinfo;

    return Column(
      children: [
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
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(width * .02),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: width * .04,
              vertical: height * .03,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: width * .05,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: height * .01),
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontSize: width * .04,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(height: height * .05),
                SizedBox(
                  height: height * .4,
                  width: width * .8,
                  child: charts.BarChart(
                    _seriesBarData,
                    animate: true,
                    vertical: true,
                    animationDuration: const Duration(milliseconds: 1000),
                    barRendererDecorator: charts.BarLabelDecorator<String>(),
                  ),
                ),
                SizedBox(height: height * .02),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child: Text(
                      'View details',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: width * .04,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onPressed: () {
                      switch (widget.title) {
                        case 'Grand':
                          grand(currency);
                          break;
                        case 'Freedom':
                          freedom();
                          break;
                        case 'Education':
                          education();
                          break;
                        case 'Debt':
                          debt();
                          break;
                        case 'Credit':
                          credit();
                          break;
                        case 'Beta':
                          beta();
                          break;
                        case 'Alpha':
                          alpha();
                          break;
                        default:
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: height * .05),
      ],
    );
  }

  credit() async {
    var timer = Timer(const Duration(seconds: 40), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    FocusScope.of(context).requestFocus(FocusNode());

    dialogBox.waiting(context, "Loading");
    var url = "$baseUrl/app/360/liability";
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    if (response.statusCode == 200) {
      print('seveng:${response.data["seveng"]}');
      var mapList = response.data["liabilities"];
      var mapListLite = response.data["liabilities_detail"];
      List seveng = response.data["seveng"];
      var bespokes = response.data["bespokes"];
      var isAllocated = response.data["audit"]["is_allocated"];

      print('isAllocated:$isAllocated');

      var total = 0;
      List<int> real = [];

      if (seveng.isNotEmpty) {
        // Extract "current" values as integers, handling possible nulls
        var a = seveng.map((e) => e["current"] ?? "0").toList();

        for (var item in a) {
          // Safely parse each item to an integer, with a fallback of 0 if parsing fails
          int parsedValue = int.tryParse(item.toString()) ?? 0;
          real.add(parsedValue);
        }

        for (var item in real) {
          total += item;
        }
      }

      // Safely parse creditInfo.credit["current"] to an integer
      int creditCurrent =
          int.tryParse(creditInfo!.credit!["current"]?.toString() ?? "0") ?? 0;

      if (total != creditCurrent) {
        print('total does not match credit current value');
      } else {
        print('total does match credit current value');
      }
      print('total: $total');

      Navigator.pop(context);
      timer.cancel();
      if (isAllocated.toString() == "1") {
        timer.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Liabilitydetails(
              liabilityData: mapList,
              liabilityDataLite: mapListLite,
              seveng: seveng,
              bespokes: bespokes,
            ),
          ),
        );
      } else if (total != creditCurrent) {
        timer.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Threesixty(
              unallocated: true,
              data: seveng,
              balance: seveng.isEmpty
                  ? int.parse(creditInfo!.credit!["current"].toString())
                  : int.parse(creditInfo!.credit!["current"].toString()) -
                        total,
            ),
          ),
        );
      } else
        timer.cancel();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Liabilitydetails(
            liabilityData: mapList,
            liabilityDataLite: mapListLite,
            seveng: seveng,
            bespokes: bespokes,
          ),
        ),
      );
    }
  }

  alpha() async {
    var timer = Timer(const Duration(seconds: 40), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    FocusScope.of(context).requestFocus(FocusNode());

    dialogBox.waiting(context, "Loading");

    var url = "$baseUrl/app/360/cash";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    if (response.statusCode == 200) {
      var seveng = response.data["seveng"];
      Navigator.pop(context);
      timer.cancel();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Cashitem(item: seveng[0], seven: true, bespokes: false),
        ),
      );
    }
  }

  beta() async {
    var timer = Timer(const Duration(seconds: 40), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    FocusScope.of(context).requestFocus(FocusNode());

    dialogBox.waiting(context, "Loading");

    var url = "$baseUrl/app/360/cash";
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    if (response.statusCode == 200) {
      var seveng = response.data["seveng"];
      Navigator.pop(context);
      timer.cancel();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Cashitem(item: seveng[1], seven: true, bespokes: false),
        ),
      );
    }
  }

  debt() async {
    var timer = Timer(const Duration(seconds: 40), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    FocusScope.of(context).requestFocus(FocusNode());

    dialogBox.waiting(context, "Loading");

    var url = "$baseUrl/app/360/mortgage";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      var seveng = response.data["seveng"];
      print("seveng:$seveng");
      timer.cancel();
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Mortgageitem(item: seveng[0], seven: true),
        ),
      );
    } else {
      timer.cancel();
      Navigator.pop(context);
    }
  }

  education() async {
    var timer = Timer(const Duration(seconds: 40), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    FocusScope.of(context).requestFocus(FocusNode());

    dialogBox.waiting(context, "Loading");

    var url = "$baseUrl/app/360/cash";
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    if (response.statusCode == 200) {
      var seveng = response.data["seveng"];
      Navigator.pop(context);
      timer.cancel();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Cashitem(item: seveng[2], seven: true, bespokes: false),
        ),
      );
    }
  }

  freedom() async {
    var timer = Timer(const Duration(seconds: 40), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });

    FocusScope.of(context).requestFocus(FocusNode());

    dialogBox.waiting(context, "Loading");

    var url = "$baseUrl/app/360/retirement/roi";
    var url2 = "$baseUrl/app/360/retirement";
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    try {
      var response = await dio.get(
        url,
        options: Options(headers: {"Authorization": 'Bearer $token'}),
      );

      var response2 = await dio.get(
        url2,
        options: Options(headers: {"Authorization": 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response2.statusCode == 200) {
        context.read<Providers>().setretiredata(response.data['data']);
        context.read<Providers>().setpensions(response2.data['data']);

        Navigator.pop(context);
        timer.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Retiredash(),
          ),
        );
      } else {
        dialogBox.information(context, 'Error', 'Failed to load data');
        timer.cancel();
        Navigator.pop(context);
      }
    } catch (e) {
      dialogBox.information(context, 'Error', 'An error occurred: $e');
      timer.cancel();
      Navigator.pop(context);
    }
  }

  grand(currency) async {
    FocusScope.of(context).requestFocus(FocusNode());

    var timer = Timer(const Duration(seconds: 50), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, 'Loading');
    var url2 = "$baseUrl/app/360/philantrophy";

    final prefs = await SharedPreferences.getInstance();
    String? finalToken = prefs.getString('tokenDB');

    var response2 = await dio.get(
      url2,
      options: Options(headers: {"Authorization": 'Bearer $finalToken'}),
    );
    if (response2.statusCode == 200) {
      timer.cancel();
      Navigator.pop(context);
      if (response2.data['data']["grand"]["current"] !=
          response2.data['data']["philantrophy_detail"]["sum"]) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Setgiving(response2.data)),
        );
      } else {
        context.read<Providers>().setphilanList(response2.data);
        Navigator.of(context).pushNamed('Philanthropy');
      }
    } else {
      timer.cancel();
      Navigator.pop(context);
    }
  }
}
