import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PortfolioIncomeChart extends StatefulWidget {
  const PortfolioIncomeChart({
    super.key,
    required this.data,
    required this.small,
    required this.labelsAsset,
    required this.showingBarGroups,
  });

  final Map data;
  final small;
  final List labelsAsset;
  final List<BarChartGroupData> showingBarGroups;

  @override
  State<PortfolioIncomeChart> createState() => _PortfolioIncomeChartState();
}

class _PortfolioIncomeChartState extends State<PortfolioIncomeChart> {
  List assetValues = [];
  String selectedMonth = '';
  int touchedIndex = 0;
  List labels = [];
  List labelAsset = [];
  var chartData;
  // List aVal = [];
  List<String> selectedBarLabel = [];
  String barLabel = '';
  int selectedBarIndex = 0;
  double selectedBarValue = 0;
  bool selectedIndex = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    selectedMonth = "Last 6 Months";
    chartData = widget.data["existing_details"];
    assetValues = chartData["asset_incomes"] ?? [];
    selectedBarLabel = List<String>.from(chartData["label_asset"] ?? []);

    labels = chartData["labels"];
    labelAsset = chartData["label_asset"];
  }

  Future<void> fetchChartData(String month) async {
    if (month == 'Last 6 Months') {
      setState(() {
        chartData = widget.data["existing_details"];
        assetValues =
            chartData["asset_incomes"] as List? ?? []; // Ensure it's a list
        labels = chartData["labels"] as List? ?? []; // Ensure it's a list
        selectedBarLabel = List<String>.from(chartData["label_asset"] ?? []);
      });
      return;
    }
    String url =
        "$baseUrl/app/portfolio/business?month=$month"; // Replace with the actual URL
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          final newChartDetails = responseData["existing_details"];
          if (newChartDetails is Map) {
            chartData = newChartDetails;
            assetValues = newChartDetails["asset_incomes"] as List? ?? [];
            labels = newChartDetails["labels"] as List? ?? [];
            selectedBarLabel = List<String>.from(
              newChartDetails["label_asset"] as List? ?? [],
            );
          } else {
            // Handle case where existing_details is not a map or is null
            chartData = {}; // Or revert to widget.data["existing_details"]
            assetValues = [];
            labels = [];
            selectedBarLabel = [];
          }
        });
      } else {
        throw Exception('Failed to load chart data');
      }
    } catch (error) {}
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
    List colors = [
      0xff005E77,
      0xff002E77,
      0xff002E77,
      0xff005E77,
      0xff002E77,
      0xff005E77,
    ];
    String currency = context.watch<Providers>().snapshotmodel.currency;
    List<Widget> indicators = [];
    for (var i = 0; i < labels.length; i++) {
      indicators.add(Indicators(name: "${labels[i]}", color: colors[i]));
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * .01),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Card(
          elevation: 0,
          color: AppColors.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(color: Color(0xffD8D8D8), width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildHeader(width, height),
              Text(
                '${widget.small} Asset Portfolio Value',
                style: TextStyle(
                  color: const Color(0xff77839a),
                  fontSize: width * .05,
                ),
              ),
              SizedBox(height: height * .02),
              Expanded(child: _buildBarChart(width, height)),
              SizedBox(height: height * .01),
              if (selectedIndex)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: EdgeInsets.symmetric(
                    horizontal: width * .03,
                    vertical: height * .01,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                barLabel,
                                style: TextStyle(
                                  fontSize: width * .04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Image.asset(
                            'assets/analytic/money_value.png',
                            width: width * .06,
                          ),
                          SizedBox(height: height * .01),
                          Text(
                            "$currency$selectedBarValue".replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            ),
                            style: TextStyle(
                              fontSize: width * .04,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              SizedBox(height: height * .01),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double width, double height) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * .04,
        vertical: height * .02,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              DropdownButton<String>(
                value: selectedMonth,
                dropdownColor: Colors.white,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedMonth = newValue;
                      if (selectedMonth != "Last Six Months") {
                        fetchChartData(selectedMonth);
                      }
                    });
                  }
                },
                underline: const SizedBox.shrink(),
                items: [
                  DropdownMenuItem<String>(
                    value: "Last 6 Months",
                    child: Text(
                      "Last 6 Months",
                      style: TextStyle(
                        fontSize: width * .04,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ...labelAsset.map<DropdownMenuItem<String>>((dynamic name) {
                    return DropdownMenuItem<String>(
                      value: name,
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: width * .04,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
          Text(
            '${DateTime.now().year}',
            style: TextStyle(
              fontSize: width * .04,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  _buildBarChart(double width, double height) {
    double buffer = 300;
    double maxValue;
    double minValue;

    if (assetValues.isNotEmpty) {
      maxValue = assetValues
          .map((e) => (e is num ? e.toDouble() : 0.0))
          .reduce((a, b) => a > b ? a : b);
      minValue = assetValues
          .map((e) => (e is num ? e.toDouble() : 0.0))
          .reduce((a, b) => a < b ? a : b);
      maxValue += buffer;
      minValue -= buffer;
    } else {
      // Default values if assetValues is empty
      maxValue = buffer; // Or some other sensible default
      minValue = -buffer; // Or 0, or -buffer
    }
    double yInterval = (maxValue - minValue) / 5;

    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          enabled: false,
          touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
            if (response != null && response.spot != null) {
              int xIndex = response.spot!.touchedBarGroup.x;

              setState(() {
                // Toggle selection: If the same bar is clicked, reset values
                if (selectedBarIndex == response.spot!.touchedBarGroupIndex &&
                    selectedIndex) {
                  selectedIndex = false;
                  selectedBarIndex = -1;
                  barLabel = "";
                  selectedBarValue = 0;
                } else {
                  selectedIndex = true;
                  selectedBarIndex = response.spot!.touchedBarGroupIndex;
                  barLabel = selectedBarLabel[xIndex].split(" ")[0];
                  selectedBarValue =
                      response.spot!.touchedBarGroup.barRods.first.toY;
                }
              });
            }
          },
        ),

        alignment: BarChartAlignment.spaceAround,
        //  groupsSpace: 10,
        gridData: const FlGridData(
          show: true,
          drawHorizontalLine: false,
          drawVerticalLine: false,
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                String monthYear = labels[value.toInt()];
                String monthAbbreviation = monthYear
                    .split(' ')[0]
                    .substring(0, 3)
                    .toUpperCase();
                return Text(
                  monthAbbreviation,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: width * .030,
                  ),
                );
              },
              // margin: 16,
              interval: yInterval,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: yInterval / 5,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Hide right axis
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Hide right axis
          ),
        ),

        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: Color(0xff808080), width: .5),
            left: BorderSide(color: Colors.transparent),
            right: BorderSide(color: Colors.transparent),
            top: BorderSide(color: Colors.transparent),
          ),
        ),
        maxY: maxValue, // Set dynamic maxY
        minY: minValue,

        barGroups: (labels.isNotEmpty && assetValues.length == labels.length)
            ? List.generate(labels.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: (assetValues[index] is num)
                          ? assetValues[index].toDouble()
                          : 0.0, // Ensure value is a double
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff005E77), // Start color
                          Color(0xff002E77), // End color
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                      width: width * .04,
                    ),
                  ],
                );
              })
            : [], // Return an empty list if labels is empty or lengths don't match
      ),
    );
  }
}

class Indicators extends StatelessWidget {
  const Indicators({super.key, required this.color, required this.name});

  final int color;
  final String name;

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: width * .03),
        Text(
          formatMonth(name).toUpperCase(),
          style: TextStyle(fontSize: width * .035),
        ),
      ],
    );
  }

  String formatMonth(String name) {
    // Extract the first three letters (month name only)
    return name.replaceAll(RegExp(r'\d+'), '').trim();
  }
}
