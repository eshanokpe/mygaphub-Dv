import 'dart:convert';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssetValueChart extends StatefulWidget {
  const AssetValueChart({
    super.key,
    required this.data,
    this.id,
    this.type,
    required this.names,
  });

  final Map data;
  final String? id;
  final String? type;
  final List names;

  @override
  State<AssetValueChart> createState() => _AssetValueChartState();
}

class _AssetValueChartState extends State<AssetValueChart> {
  String? selectedMonth;
  List<double> valu = [];
  List<double> rev = [];
  List<double> expe = [];
  List<double> net = [];
  List<String> labels = [];

  String? barLabel;
  int? selectedBarIndex;
  double? selectedBarValue;
  bool selectedIndex = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedMonth = "Last 6 Months";
    _initializeData();
  }

  void _initializeData() {
    try {
      final financialDetail =
          widget.data['data']?["asset_financial_detail"] ?? {};
      valu = _safeCastToDoubleList(financialDetail["asset_values"] ?? []);
      rev = _safeCastToDoubleList(financialDetail["revenue"] ?? []);
      expe = _safeCastToDoubleList(financialDetail["expenditure"] ?? []);
      net = _safeCastToDoubleList(financialDetail["net"] ?? []);
      labels = List<String>.from(
        widget.data['data']?["asset_financial_record"]?["expenditure_labels"]
                ?.map((e) => e.toString()) ??
            [],
      );
    } catch (e) {
      print('Initialization error: $e');
      // Fallback to empty data
      valu = [];
      rev = [];
      expe = [];
      net = [];
      labels = [];
    }
  }

  List<double> _safeCastToDoubleList(dynamic input) {
    try {
      if (input is List) {
        return input.map((e) => double.tryParse(e.toString()) ?? 0.0).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> fetchChartData2(String month) async {
    if (month == 'Last 6 Months') {
      _initializeData();
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
        final financialDetail =
            responseData['data']?["asset_financial_detail"] ?? {};
        setState(() {
          valu = _safeCastToDoubleList(financialDetail["asset_values"] ?? []);
          rev = _safeCastToDoubleList(financialDetail["revenue"] ?? []);
          expe = _safeCastToDoubleList(financialDetail["expenditure"] ?? []);
          net = _safeCastToDoubleList(financialDetail["net"] ?? []);
          labels = List<String>.from(
            responseData['data']?["asset_financial_record"]?["expenditure_labels"]
                    ?.map((e) => e.toString()) ??
                [],
          );
        });
      } else {
        throw Exception('Failed to load chart data');
      }
    } catch (error) {
      print('Error fetching chart data: $error');
    }
  }

  Future<void> fetchChartData(String month) async {
    if (month == selectedMonth) return;

    setState(() {
      isLoading = true;
      selectedMonth = month;
    });

    try {
      if (month == 'Last 6 Months') {
        _initializeData();
      } else {
        final url =
            "$baseUrl/app/portfolio/${widget.type}/${widget.id}?month=$month";
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('tokenDB') ?? '';

        final response = await http.get(
          Uri.parse(url),
          headers: {"Authorization": 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final financialDetail =
              responseData['data']?["asset_financial_detail"] ?? {};
          setState(() {
            valu = _safeCastToDoubleList(financialDetail["asset_values"] ?? []);
            rev = _safeCastToDoubleList(financialDetail["revenue"] ?? []);
            expe = _safeCastToDoubleList(financialDetail["expenditure"] ?? []);
            net = _safeCastToDoubleList(financialDetail["net"] ?? []);
            labels = List<String>.from(
              responseData['data']?["asset_financial_record"]?["expenditure_labels"]
                      ?.map((e) => e.toString()) ??
                  [],
            );
          });
        } else {
          throw Exception('Failed with status ${response.statusCode}');
        }
      }
    } catch (error) {
      print('Error fetching chart data: $error');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load data: $error')));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  double getMaxY() {
    if (valu.isEmpty) return 1000.0; // Default max when no data
    return valu.reduce((a, b) => a > b ? a : b) * 1.2; // 20% buffer
  }

  @override
  Widget build(BuildContext context) {
    final maxY = getMaxY();
    final currency = context.watch<Providers>().snapshotmodel.currency;
    final orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Card(
      elevation: 0,
      color: AppColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: Color(0xffD8D8D8), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(width, height),
            SizedBox(height: height * 0.02),
            AspectRatio(
              aspectRatio: 1.7,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: maxY > 0 ? maxY / 5 : 1,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  formatValue(value),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: width * 0.03,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 20,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < widget.names.length) {
                                  final month = widget.names[index];
                                  return Text(
                                    month.length >= 3
                                        ? month.substring(0, 3).toUpperCase()
                                        : month,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: width * 0.03,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                              interval: 1,
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: (widget.names.length - 1).toDouble(),
                        minY: 0,
                        maxY: maxY,
                        lineBarsData: [
                          LineChartBarData(
                            spots: valu.asMap().entries.map((entry) {
                              return FlSpot(entry.key.toDouble(), entry.value);
                            }).toList(),
                            isCurved: true,
                            color: const Color(0xff78A0BA),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: const LinearGradient(
                                colors: [Color(0xff78A0BA), Colors.white],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            dotData: const FlDotData(show: false),
                            barWidth: 3,
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (spot) => Colors.black26,
                          ),
                          touchCallback: (event, response) {
                            if (response?.lineBarSpots != null &&
                                response!.lineBarSpots!.isNotEmpty) {
                              final spot = response.lineBarSpots!.first;
                              setState(() {
                                selectedIndex = true;
                                selectedBarIndex = spot.spotIndex;
                                selectedBarValue = spot.y;
                                barLabel = widget.names[spot.x.toInt()];
                              });
                            } else {
                              setState(() => selectedIndex = false);
                            }
                          },
                          handleBuiltInTouches: true,
                        ),
                      ),
                    ),
            ),
            if (selectedIndex) _buildSelectionInfo(width, height, currency),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double width, double height) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButton<String>(
            value: selectedMonth,
            onChanged: (String? newValue) {
              if (newValue != null) {
                fetchChartData(newValue);
              }
            },
            underline: const SizedBox.shrink(),
            items: [
              const DropdownMenuItem<String>(
                value: "Last 6 Months",
                child: Text("Last 6 Months"),
              ),
              ...widget.names.map<DropdownMenuItem<String>>((name) {
                return DropdownMenuItem<String>(
                  value: name.toString(),
                  child: Text(name.toString()),
                );
              }),
            ],
          ),
          Text(
            '${DateTime.now().year}',
            style: TextStyle(
              fontSize: width * 0.04,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionInfo(double width, double height, String currency) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(
        horizontal: width * 0.03,
        vertical: height * 0.01,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/analytic/money_value.png',
                width: width * 0.06,
              ),
              SizedBox(width: width * 0.02),
              Text(
                barLabel ?? '',
                style: TextStyle(
                  fontSize: width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.arrow_upward, size: 17, color: Colors.green),
              Text(
                "3.7%",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: width * 0.03,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: width * 0.01),
              Text(
                "$currency${formatNumber(selectedBarValue ?? 0)}",
                style: TextStyle(
                  fontSize: width * 0.04,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String formatNumber(double value) {
    // First format to string with 2 decimal places
    final numStr = value.toStringAsFixed(2);

    // Split into whole and decimal parts
    final parts = numStr.split('.');
    final wholePart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    // Add thousands separators to whole number part
    final formattedWhole = wholePart.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return '$formattedWhole$decimalPart';
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
