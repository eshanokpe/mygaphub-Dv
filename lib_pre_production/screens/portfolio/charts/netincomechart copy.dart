import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NetIncomeChart extends StatefulWidget {
  final List<BarChartGroupData> showingBarGroups;
  final List names;
  final String id;
  final String type;
  final String currency;
  final String imgPrefixAssets;
  final String imgurl;
  final Map data;

  const NetIncomeChart({
    super.key,
    required this.showingBarGroups,
    required this.names,
    required this.id,
    required this.type,
    required this.data,
    required this.currency,
    required this.imgurl,
    required this.imgPrefixAssets,
  });

  @override
  State<NetIncomeChart> createState() => _NetIncomeChartState();
}

class _NetIncomeChartState extends State<NetIncomeChart> {
  List assetValues = [];
  String selectedMonth = '';
  int touchedIndex = 0;
  List labels = [];
  List labelAsset = [];
  List chartData = [];
  List<double> values = [];
  List<String> month = [];
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
    chartData =
        widget.data['data']["asset_financial_detail"]["expenditure_labels"];
    assetValues = widget.data['data']["asset_financial_detail"]["net"];
    labels =
        widget.data['data']["asset_financial_detail"]["expenditure_labels"];
    selectedBarLabel = List<String>.from(
      widget.data['data']["asset_financial_detail"]["expenditure_labels"],
    );
    print("Assetdata:${widget.data['data']["asset_financial_detail"]}");
    labels =
        widget.data['data']["asset_financial_detail"]["expenditure_labels"];
  }

  double getBigNumValue(double maxValue) {
    if (maxValue >= 0 && maxValue <= 100) {
      return 100;
    } else if (maxValue >= 101 && maxValue <= 1000) {
      return 1000;
    } else if (maxValue >= 1001 && maxValue <= 10000) {
      return 10000;
    } else if (maxValue >= 10001 && maxValue <= 100000) {
      return 100000;
    } else if (maxValue >= 100001 && maxValue <= 1000000) {
      return 1000000;
    } else if (maxValue >= 1000001 && maxValue <= 10000000) {
      return 10000000;
    } else if (maxValue >= 10000001 && maxValue <= 100000000) {
      return 100000000;
    } else {
      return maxValue;
    }
  }

  Future<void> fetchChartData(String month) async {
    if (month == 'Last 6 Months') {
      setState(() {
        chartData = widget.data['data']["asset_financial_detail"];
        assetValues =
            widget.data['data']["asset_financial_detail"]["net"] ?? [];

        labels =
            widget
                .data['data']["asset_financial_detail"]["expenditure_labels"] ??
            [];
        selectedBarLabel =
            List<String>.from(
              widget
                  .data['data']["asset_financial_detail"]["expenditure_labels"],
            ) ??
            [];
      });
      return;
    }
    final url =
        "$baseUrl/app/portfolio/${widget.type}/${widget.id}?month=$month";
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          labels =
              responseData['data']["asset_financial_record"]["expenditure_labels"];
          assetValues = responseData['data']["asset_financial_detail"]["net"];
        });
      } else {
        throw Exception('Failed to load chart data');
      }
    } catch (error) {
      print('Error fetching chart data: $error');
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
    Future<String> getImg() async {
      return widget.imgurl;
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
                              widget.imgurl != widget.imgPrefixAssets
                                  ? FutureBuilder<String>(
                                      future: getImg(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        } else if (snapshot.hasError) {
                                          return const Center(
                                            child: Icon(Icons.portrait),
                                          );
                                        } else if (snapshot.hasData) {
                                          return ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: widget.imgurl,
                                              imageBuilder:
                                                  (context, imageProvider) {
                                                    return Container(
                                                      width: width * .08,
                                                      height: width * .08,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                              placeholder: (context, url) =>
                                                  const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 0.5,
                                                        ),
                                                  ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(
                                                        Icons.portrait,
                                                      ),
                                            ),
                                          );
                                        } else {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                      },
                                    )
                                  : Image.asset(
                                      'assets/images/add_photo.jpg',
                                      width: width * .08,
                                      height: width * .08,
                                      fit: BoxFit.cover,
                                    ),
                              const SizedBox(width: 10),
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
                  ...widget.names.map<DropdownMenuItem<String>>((dynamic name) {
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
    double maxY = getBigNumValue(
      assetValues.map((e) => e.toDouble()).reduce((a, b) => a > b ? a : b),
    ).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: false,
          touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
            if (response != null &&
                response.spot != null &&
                response.spot!.touchedBarGroupIndex != -1) {
              setState(() {
                int xIndex = response.spot!.touchedBarGroup.x;

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
                  selectedBarValue = response
                      .spot!
                      .touchedBarGroup
                      .barRods
                      .first
                      .toY; // `y` → `toY`
                }
              });
            }
          },
        ),
        alignment: BarChartAlignment.spaceAround,
        gridData: const FlGridData(
          show: true,
          drawHorizontalLine: false,
          drawVerticalLine: false,
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              interval: maxY > 0 ? maxY / 5 : 1, // Prevent division by zero
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    formatValue(value),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: width * .03,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Hide right axis
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Hide right axis
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                String month = widget.names[value.toInt()];
                return Text(
                  month.length >= 3
                      ? month.substring(0, 3).toUpperCase()
                      : month,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: width * .03,
                  ),
                );
              },
            ),
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
        barGroups: List.generate(labels.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: assetValues[index].toDouble(), // Changed `y` to `toY`
                gradient: const LinearGradient(
                  colors: [Color(0xff005E77), Color(0xff002E77)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ), // `colors` replaced with `gradient`
                borderRadius: BorderRadius.circular(6),
                width: width * .04,
              ),
            ],
          );
        }),
      ),
    );
  }

  String formatValue(double value) {
    if (value >= 1000000) {
      return "${(value / 1000000).toStringAsFixed(1)}M";
    } else if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(1)}K";
    } else {
      return value.toStringAsFixed(0);
    }
  }
}

class Indicators extends StatelessWidget {
  const Indicators({
    super.key,
    required this.color,
    required this.month,
    required this.values,
    required this.currency,
  });

  final int color;
  final String month;
  final String currency;
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * .005,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: width * .03,
                width: width * .03,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(color),
                ),
              ),
              SizedBox(width: width * .01),
              Text(month, style: TextStyle(fontSize: width * .04)),
            ],
          ),
          SizedBox(width: width * .01),
          Expanded(
            child: Wrap(
              spacing: width * .02, // Adjust the spacing between items
              runSpacing: 4.0, // Adjust the spacing between lines
              alignment: WrapAlignment.end,
              children: values.isNotEmpty
                  ? values.map((value) {
                      return Text(
                        '$currency${value.toStringAsPrecision(2)}',
                        style: TextStyle(
                          fontSize: width * .035,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }).toList()
                  : [
                      Text(
                        '${currency}0.0',
                        style: TextStyle(
                          fontSize: width * .04,
                          color: Color(color),
                        ),
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}
