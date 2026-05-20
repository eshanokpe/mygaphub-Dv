import 'dart:convert';
import 'dart:math' as math;
import 'package:GapHub/provider/acquisiProvider.dart';
import 'package:GapHub/screens/registration/financial_health/prequestions.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/custom_appbar_logo.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TimeFinancialIndependent extends StatefulWidget {
  final dynamic shortfalls;
  final dynamic suggestedInvestment;
  final dynamic seedCost;
  final dynamic income;
  final num t2fi;
  final dynamic timeFiniancial;
  final String currency;

  final TextEditingController roceController;
  final TextEditingController investController;

  const TimeFinancialIndependent({
    super.key,
    required this.seedCost,
    required this.suggestedInvestment,
    required this.income,
    required this.shortfalls,
    required this.t2fi,
    required this.timeFiniancial,
    this.currency = '',
    required this.roceController,
    required this.investController,
  });

  @override
  State<TimeFinancialIndependent> createState() =>
      _TimeFinancialIndependentState();
}

class _TimeFinancialIndependentState extends State<TimeFinancialIndependent> {
  num avr = 0;
  num shortfall = 0;
  num t2fi = 0;
  dynamic income = 0;
  dynamic suggestedInvestment = 0;
  dynamic seedCost = '0';
  String timeFiniancial = '';
  num? timeChart;
  late TextEditingController _roceController;
  late TextEditingController _investController;
  Map<dynamic, dynamic> calculatorData = {};

  @override
  void initState() {
    super.initState();
    t2fi = widget.t2fi;
    // shortfall = widget.shortfalls;
    // timeFiniancial = widget.timeFiniancial;
    _roceController = widget.roceController;
    _investController = widget.investController;
    selectedCurrency = widget.currency;
    getBudget();
  }

  String selectedCurrency = '';
  Future<void> getBudget() async {
    var url = Uri.parse("$baseUrl/app/calculator");

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('tokenDB');
      if (token == null) {
        throw Exception("No token found in SharedPreferences");
      }
      final http.Response response = await http.get(
        url,
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );
      print('Error: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final Map<String, dynamic> dataResponse = data["data"];
        // final providers = Provider.of<Providers>(context, listen: false);
        if (!mounted) return;
        final providers = context.read<Providers>();

        providers.setCurrency(dataResponse['currency'] ?? '');
        setState(() {
          selectedCurrency = dataResponse['currency'];
        });
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    calculatorData = context.read<Providers>().calculatorData;
    print("calculatorData:$calculatorData");
    timeChart = calculatorData['time_finiancial_chart'] ?? '0.00';
    timeFiniancial = calculatorData['time_finiancial'] ?? '0.00';

    shortfall = calculatorData['shortfall'] ?? 0;
    avr = calculatorData['average'] ?? 0;
    income = widget.income;
    print('Income: $income');
    seedCost = widget.seedCost;
    seedCost = widget.seedCost;

    final providers = context.watch<Providers>();
    final currency = selectedCurrency.isNotEmpty
        ? selectedCurrency
        : providers.currency;
    final symbol = currency.isEmpty ? '' : currency.split(" ").first;

    final orientation = MediaQuery.of(context).orientation;
    final screenHeight = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;

    final userEmail = providers.loginDetails.email;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBarLogo(
        title: '',
        onBackPressed: () async {
          Navigator.pop(context);
        },
        actionIconPath: 'assets/logo.png',
        onActionPressed: () {},
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeader(timeFiniancial),
              SizedBox(height: 30.h),
              _buildChart(symbol, context),
              SizedBox(height: screenHeight * 0.03),
              _buildSummary(symbol),
              SizedBox(height: screenHeight * 0.07),
              _buildContinueButton(userEmail!, symbol),
              SizedBox(height: screenHeight * 0.08),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String timeFiniancial) {
    double timeValue = double.tryParse(timeFiniancial) ?? 0.0;
    int timeAsInt = timeValue.round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Time to Financial Independence:',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontFamily: 'NunitoSans',
              fontSize: 20.sp,
              color: AppColors.blackColor,
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Text(
          '$timeAsInt Years 😕',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20.sp,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildChart(String symbol, BuildContext context) {
  final now = DateTime.now();
  double timeValue = double.tryParse(timeFiniancial) ?? 0.0;
  int timeAsInt = timeValue.round();
  final double chartYears = _parseDouble(timeChart);
  final double investmentTarget = _parseDouble(seedCost);
  final double maxX = chartYears <= 0 ? 1.0 : chartYears;
  final double maxYAxisValue = _calculateChartMaxY(investmentTarget);

  final double startingY = _calculateOptimalInterval(maxYAxisValue);
  final int segments = math.max(50, (maxX * 10).ceil());
 
  final List<FlSpot> curvedSpots = List.generate(segments + 1, (index) {
    final double year = (maxX * index) / segments;
    final double progress = index / segments;

    const List<List<double>> keyPoints = [
      [0.000, 0.000], // ← was 0.254, now starts at 0 so it maps to exactly startingY
      [0.200, 0.158],
      [0.272, 0.325],
      [0.353, 0.395],
      [0.515, 0.508],
      [0.603, 0.647],
      [0.739, 0.695],
      [0.801, 0.819],
      [0.897, 0.893],
      [1.000, 1.000],
    ];

    int lower = 0;
    for (int k = 0; k < keyPoints.length - 1; k++) {
      if (progress >= keyPoints[k][0]) lower = k;
    }
    final int upper = (lower + 1).clamp(0, keyPoints.length - 1);

    final double segProgress = lower == upper
        ? 1.0
        : (progress - keyPoints[lower][0]) /
            (keyPoints[upper][0] - keyPoints[lower][0]);

    final double t = segProgress.clamp(0.0, 1.0);
    final double smoothT = t * t * (3 - 2 * t);

    final double normalizedY =
        keyPoints[lower][1] + (keyPoints[upper][1] - keyPoints[lower][1]) * smoothT;

    // normalizedY 0.0 → startingY, normalizedY 1.0 → maxYAxisValue
    final double yValue = index == 0
        ? startingY
        : index == segments
            ? maxYAxisValue
            : startingY + (maxYAxisValue - startingY) * normalizedY;

    return FlSpot(year, yValue.clamp(startingY, maxYAxisValue).toDouble());
  });

  final double maxY = maxYAxisValue;
  const double minY = 0.0;
  const double minX = 0.0;
  final double xInterval = maxX <= 4 ? 1 : (maxX / 3).ceilToDouble();

  return Container(
    height: 250.h,
    width: double.infinity,
    padding: const EdgeInsets.only(right: 16, top: 16, bottom: 0),
    child: LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
  enabled: true,
  touchTooltipData: LineTouchTooltipData(
    getTooltipItems: (touchedSpots) {
      return touchedSpots.map((spot) {
        String displayText;
        if (spot.y >= 1000000) {
          displayText = '$symbol${(spot.y / 1000000).round()}M';
        } else if (spot.y >= 1000) {
          displayText = '$symbol${(spot.y / 1000).round()}k';
        } else {
          displayText = '$symbol${spot.y.round()}';
        }
        return LineTooltipItem(
          displayText,
          const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        );
      }).toList();
    },
  ),
  getTouchedSpotIndicator: (barData, spotIndexes) {
    return spotIndexes.map((spotIndex) {
      return TouchedSpotIndicatorData(
        // Dashed vertical line at touch point
        FlLine(
          color: Colors.blueGrey[700]!,
          strokeWidth: 1.5,
          dashArray: [6, 4], // ← dashed line pattern
        ),
        // Dot at the touched spot
        FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 6,
              color: Colors.white,
              strokeWidth: 2.5,
              strokeColor: Colors.blueGrey[700]!,
            );
          },
        ),
      );
    }).toList();
  },
),
        clipData: const FlClipData.all(),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          horizontalInterval: _calculateOptimalInterval(maxY),
          getDrawingVerticalLine: (value) {
            if (value == minX || value == maxX) {
              return const FlLine(color: Color(0xff37434d), strokeWidth: 0.5);
            }
            return const FlLine(color: Colors.transparent, strokeWidth: 1);
          },
          getDrawingHorizontalLine: (value) {
            return const FlLine(color: Color(0xff37434d), strokeWidth: 0.05);
          },
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: maxY,
              color: const Color(0xff37434d),
              strokeWidth: 0.08,
            ),
          ],
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              interval: _calculateOptimalInterval(maxY),
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return Padding(
                    padding: EdgeInsets.only(right: 25.w),
                    child: Text(
                      '0',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                String displayText;
                if (value >= 1000000) {
                  displayText = '${(value / 1000000).round()}M';
                } else if (value >= 1000) {
                  displayText = '${(value / 1000).round()}k';
                } else {
                  displayText = value.round().toString();
                }
                return Text(
                  '$symbol$displayText',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: xInterval,
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return Padding(
                    padding: EdgeInsets.only(left: 15.w),
                    child: Text(
                      '${now.year}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                if ((value - maxX).abs() < 0.01) {
                  return Text(
                    '${now.year + timeAsInt}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }
                return const Text('');
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
        lineBarsData: [
          LineChartBarData(
            spots: curvedSpots,
            isCurved: true,
            curveSmoothness: 0.35, // ← smooth curves, no harsh edges
            preventCurveOverShooting: true, // ← stops spikes at transitions
            barWidth: 2,
            color: Colors.blueGrey[700],
            belowBarData: BarAreaData(
              show: true,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xff477282), Colors.white],
              ),
            ),
            dotData: const FlDotData(show: false),
          ),
        ],
        minY: minY,
        maxY: maxY,
        minX: minX,
        maxX: maxX,
      ),
    ),
  );
}


  Widget _buildSummary(String symbol) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary & Recommendations 💡',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
            color: AppColors.blackColor,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Text(
          'You have a shortfall of $symbol${parsed(shortfall.toDouble())} in your asset portfolio income. In order to become financially independent, you will need to acquire assets to the value of $symbol${parsed(avr.toDouble())} generating income at ${_roceController.text}% ROCE to make up this shortfall.',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w300,
            fontSize: 14.sp,
            color: AppColors.blackColor,
          ),
        ),
        SizedBox(height: 10.h),
        RichText(
          text: TextSpan(
            style: TextStyle(
              // Default text style
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w300,
              fontSize: 14.sp,
              color: AppColors.blackColor,
            ),
            children: <TextSpan>[
              TextSpan(
                text:
                    'Setting aside $symbol${parsed(double.tryParse(_investController.text) ?? 0.0)} monthly for investment will allow you to become financially independent in ',
              ),
              TextSpan(
                text:
                    '${(double.tryParse(timeFiniancial) ?? 0.0).round()} years', // Parse, round, and display as integer
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ), // Example: slightly bolder years
              const TextSpan(
                text:
                    '. Explore the opportunities listed by our partners from your GAPhub account. Also, visit the acquisition section of your account and start using myGAPhub to build a profitable asset portfolio globally.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(String userEmail, String symbol) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: CustomButton(
        text: 'Continue',
        fontSize: 16.sp,
        borderRadius: 30,
        icon: Icons.arrow_forward_ios,
        iconColor: Colors.white,
        borderColor: Colors.white,
        onPressed: () async {
          dialogBox.waiting(context, 'Loading');
          try {
            final calculatorModel = Provider.of<AcquisiProvider>(
              context,
              listen: false,
            );
            final response = await _submitCalculatorData(calculatorModel);
            if (response.statusCode == 200) {
              await sendinblue(userEmail);
              if (!mounted) return;
              Navigator.pop(context);
              navigateWithSlideTransition(
                context: context,
                destinationScreen: const Prequestions(),
                transitionDuration: const Duration(milliseconds: 200),
              );
            } else {
              if (!mounted) return;
              Navigator.pop(context);
              final Map<String, dynamic> data = jsonDecode(response.body);
              dialogBox.information(
                context,
                'Server Error',
                'Failed with status: ${response.statusCode}. ${data['message']}',
              );
            }
          } catch (e) {
            if (!mounted) return;
            Navigator.pop(context);
            dialogBox.information(
              context,
              'Status',
              'Please try again. Something went wrong.',
            );
          }
        },
        color: AppColors.primaryColor,
        textColor: Colors.white,
      ),
    );
  }

  Future<http.Response> _submitCalculatorData(
    AcquisiProvider calculatorModel,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');
    print("calculatorModel${calculatorModel.selectedCurrency}");
    final body = {
      "currency": calculatorModel.selectedCurrency,
      "periodic_savings": calculatorModel.savings,
      "education": calculatorModel.education,
      "mortgage": calculatorModel.mortgage,
      "mobility": calculatorModel.mobility,
      "expenses": calculatorModel.expenses,
      "utility": calculatorModel.utility,
      "dept_repay": calculatorModel.debtRepay,
      "charity": calculatorModel.charity,
      "other_income": calculatorModel.otherWages,
      "extra_save": calculatorModel.rainyDays,
      "roce": _roceController.text,
      "investment": _investController.text,
    };

    return await http.post(
      Uri.parse("$baseUrl/app/calculator"),
      body: body,
      headers: {
        "Authorization": 'Bearer $token',
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      encoding: Encoding.getByName("utf-8"),
    );
  }

  double _calculateOptimalInterval(double maxValue) {
    if (maxValue <= 5) return 1;
    if (maxValue <= 10) return 2;
    if (maxValue <= 20) return 5;
    if (maxValue <= 50) return 10;
    return maxValue / 5;
  }

  double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  double _calculateChartMaxY(double targetValue) {
    if (targetValue <= 0) return 1.0;

    final double paddedTarget = targetValue * 1.1;
    final double magnitude = math
        .pow(10, (math.log(paddedTarget) / math.ln10).floor())
        .toDouble();
    final double normalized = paddedTarget / magnitude;
    final double niceNormalized;

    if (normalized <= 1) {
      niceNormalized = 1;
    } else if (normalized <= 1.2) {
      niceNormalized = 1.2;
    } else if (normalized <= 1.5) {
      niceNormalized = 1.5;
    } else if (normalized <= 2) {
      niceNormalized = 2;
    } else if (normalized <= 2.5) {
      niceNormalized = 2.5;
    } else if (normalized <= 3) {
      niceNormalized = 3;
    } else if (normalized <= 4) {
      niceNormalized = 4;
    } else if (normalized <= 5) {
      niceNormalized = 5;
    } else if (normalized <= 6) {
      niceNormalized = 6;
    } else if (normalized <= 8) {
      niceNormalized = 8;
    } else {
      niceNormalized = 10;
    }

    return niceNormalized * magnitude;
  }

  String parsed(double value) {
    return '${value.round()}'.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Future<void> sendinblue(String email) async {
    final url = Uri.parse("https://api.sendinblue.com/v3/contacts");
    final body = {
      "email": email,
      "Firstname": "",
      "listIds": [26],
      "updateEnabled": false,
    };

    await http.post(
      url,
      body: jsonEncode(body),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "api-key":
            "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",
      },
    );
  }
}
