import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemsHealthChart extends StatefulWidget {
  const ItemsHealthChart({
    super.key,
    required this.data,
    required this.names,
    this.id,
    required this.type,
    required this.currency,
  });

  final String? id;
  final String type;
  final Map data;
  final List names;
  final String currency;

  @override
  State<ItemsHealthChart> createState() => _ItemsHealthChartState();
}

class _ItemsHealthChartState extends State<ItemsHealthChart> {
  List<double> revenueValues = [];
  List<double> expenditureValues = [];
  List<double> netIncomeValues = [];
  String selectedMonth = "Last 6 Months";
  List<String> labels = [];
  List<double> yAxis = [];
  List<double> net = [];
  List<double> expe = [];
  List<double> rev = [];
  double bigNumHealth = 0;
  bool isLoading = false;

  final Color leftBarColorHealth = const Color(0xff479CC6);
  final Color centerBarColorHealth = const Color(0xffBBC3A4);
  final Color rightBarColorHealth = const Color(0xffFF8F28);
  final double barWidth = 8;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    try {
      final financialDetail =
          widget.data['data']?["asset_financial_detail"] ?? {};

      // Safely initialize all lists with proper type conversion
      labels = List<String>.from(
        financialDetail["expenditure_labels"]?.map((e) => e.toString()) ?? [],
      );
      rev = _safeCastToDoubleList(financialDetail["revenue"] ?? []);
      expe = _safeCastToDoubleList(financialDetail["expenditure"] ?? []);
      net = _safeCastToDoubleList(financialDetail["net"] ?? []);

      // Calculate the maximum value for scaling
      final maxRev = rev.isNotEmpty ? rev.reduce((a, b) => a > b ? a : b) : 0;
      final maxExpe = expe.isNotEmpty
          ? expe.reduce((a, b) => a > b ? a : b)
          : 0;
      final maxNet = net.isNotEmpty ? net.reduce((a, b) => a > b ? a : b) : 0;
      final maxValue = [
        maxRev,
        maxExpe,
        maxNet,
      ].reduce((a, b) => a > b ? a : b).toDouble();

      // Set appropriate scale
      bigNumHealth = _calculateScale(maxValue);

      // Initialize y-axis values
      yAxis = List.generate(6, (i) => (bigNumHealth / 5) * i);
    } catch (e) {
      print('Initialization error: $e');
      // Fallback to empty data
      labels = [];
      rev = [];
      expe = [];
      net = [];
      bigNumHealth = 1000;
      yAxis = [0, 200, 400, 600, 800, 1000];
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

  double _calculateScale(double maxValue) {
    if (maxValue <= 100) return 100;
    if (maxValue <= 1000) return 1000;
    if (maxValue <= 10000) return 10000;
    if (maxValue <= 100000) return 100000;
    if (maxValue <= 1000000) return 1000000;
    if (maxValue <= 10000000) return 10000000;
    if (maxValue <= 100000000) return 100000000;
    return maxValue * 1.2; // Add 20% buffer
  }

  List<BarChartGroupData> get barGroups {
    return List.generate(labels.length, (index) {
      final x = index + 1; // x starts from 1
      final revValue = index < rev.length ? (rev[index] / bigNumHealth) * 5 : 0;
      final expeValue = index < expe.length
          ? (expe[index] / bigNumHealth) * 5
          : 0;
      final netValue = index < net.length ? (net[index] / bigNumHealth) * 5 : 0;

      return BarChartGroupData(
        x: x,
        barsSpace: 4,
        barRods: [
          BarChartRodData(
            toY: revValue.clamp(0, double.infinity).toDouble(),
            color: leftBarColorHealth,
            width: barWidth,
            borderRadius: BorderRadius.zero,
          ),
          BarChartRodData(
            toY: expeValue.clamp(0, double.infinity).toDouble(),
            color: centerBarColorHealth,
            width: barWidth,
            borderRadius: BorderRadius.zero,
          ),
          BarChartRodData(
            toY: netValue.clamp(0, double.infinity).toDouble(),
            color: rightBarColorHealth,
            width: barWidth,
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    });
  }

  Future<void> fetchChartData(String month) async {
    // if (month == selectedMonth) return;
    if (month == 'Last 6 Months') {
      final financialDetail =
          widget.data['data']?["asset_financial_detail"] ?? {};
      setState(() {
        labels = List<String>.from(
          financialDetail["expenditure_labels"]?.map((e) => e.toString()) ?? [],
        );
        rev = _safeCastToDoubleList(financialDetail["revenue"] ?? []);
        expe = _safeCastToDoubleList(financialDetail["expenditure"] ?? []);
        net = _safeCastToDoubleList(financialDetail["net"] ?? []);
      });
      return;
    }

    setState(() {
      isLoading = true;
      selectedMonth = month;
    });

    try {
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
          labels = List<String>.from(
            financialDetail["expenditure_labels"]?.map((e) => e.toString()) ??
                [],
          );
          rev = _safeCastToDoubleList(financialDetail["revenue"] ?? []);
          expe = _safeCastToDoubleList(financialDetail["expenditure"] ?? []);
          net = _safeCastToDoubleList(financialDetail["net"] ?? []);

          // Recalculate scale for new data
          final maxValue = [
            ...rev,
            ...expe,
            ...net,
          ].fold(0.0, (prev, curr) => curr > prev ? curr : prev).toDouble();
          bigNumHealth = _calculateScale(maxValue);
          yAxis = List.generate(6, (i) => (bigNumHealth / 5) * i);
        });
      } else {
        throw Exception('Failed with status ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load data: $error')));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return AspectRatio(
      aspectRatio: 0.85,
      child: Card(
        color: AppColors.cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: const BorderSide(color: Color(0xffD8D8D8), width: 0.5),
        ),
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            _buildHeader(width, height),
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(child: _buildChart(width)),
            _buildLegend(width, height),
            SizedBox(height: height * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double width, double height) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.02,
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
              ...widget.names.where((name) => name != "Last 6 Months").map((
                name,
              ) {
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

  Widget _buildChart(double width) {
    final displayGroups = labels.isEmpty
        ? List.generate(6, (index) => makeGroupDataHealth(index + 1, 0, 0, 0))
        : barGroups;
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        groupsSpace: width * 0.07,
        alignment: BarChartAlignment.center,
        maxY: 6,
        minY: 0,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt() - 1;
                if (index >= 0 && index < labels.length) {
                  return Text(
                    labels[index].length > 3
                        ? labels[index].substring(0, 3).toUpperCase()
                        : labels[index].toUpperCase(),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: width * 0.04,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 20,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < yAxis.length) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      NumberFormat.compact().format(yAxis[index]),
                      style: TextStyle(
                        color: const Color(0xff7589a2),
                        fontWeight: FontWeight.w400,
                        fontSize: width * 0.035,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: Color(0xff37434d), width: 0.5),
            left: BorderSide(color: Colors.transparent),
            right: BorderSide(color: Colors.transparent),
            top: BorderSide(color: Colors.transparent),
          ),
        ),
        barGroups: displayGroups,
        barTouchData: BarTouchData(
          enabled: true,
          touchCallback: (FlTouchEvent event, response) {
            if (response != null && response.spot != null) {
              final groupIndex = response.spot!.touchedBarGroupIndex;
              if (groupIndex >= 0 && groupIndex < barGroups.length) {
                final group = barGroups[groupIndex];
                setState(() {
                  revenueValues = group.barRods
                      .where((rod) => rod.color == leftBarColorHealth)
                      .map((rod) => (rod.toY / 5) * bigNumHealth)
                      .toList();
                  expenditureValues = group.barRods
                      .where((rod) => rod.color == centerBarColorHealth)
                      .map((rod) => (rod.toY / 5) * bigNumHealth)
                      .toList();
                  netIncomeValues = group.barRods
                      .where((rod) => rod.color == rightBarColorHealth)
                      .map((rod) => (rod.toY / 5) * bigNumHealth)
                      .toList();
                });
              }
            }
          },
        ),
      ),
    );
  }

  BarChartGroupData makeGroupDataHealth(
    int x,
    double y1,
    double y2,
    double y3,
  ) {
    return BarChartGroupData(
      x: x,
      barsSpace: 4,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: leftBarColorHealth,
          width: barWidth,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        BarChartRodData(
          toY: y2,
          color: centerBarColorHealth,
          width: barWidth,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        BarChartRodData(
          toY: y3,
          color: rightBarColorHealth,
          width: barWidth,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(double width, double height) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: Color(0xffD8D8D8), width: 0.2),
      ),
      margin: EdgeInsets.symmetric(horizontal: width * 0.05),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.05,
          vertical: height * 0.005,
        ),
        child: Column(
          children: [
            _buildIndicator("Revenue", leftBarColorHealth, revenueValues),
            _buildIndicator(
              "Expenditure",
              centerBarColorHealth,
              expenditureValues,
            ),
            _buildIndicator("Net Income", rightBarColorHealth, netIncomeValues),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(String name, Color color, List<double> values) {
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: width * 0.03,
                height: width * 0.03,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              SizedBox(width: width * 0.01),
              Text(name, style: TextStyle(fontSize: width * 0.04)),
            ],
          ),
          if (values.isNotEmpty)
            Text(
              '${widget.currency}${values.first.toStringAsFixed(2)}',
              style: TextStyle(fontSize: width * 0.04, color: color),
            )
          else
            Text(
              '${widget.currency}0.00',
              style: TextStyle(fontSize: width * 0.04, color: color),
            ),
        ],
      ),
    );
  }
}
