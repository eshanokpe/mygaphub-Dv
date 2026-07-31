import 'dart:async';
import 'dart:convert';

import 'package:GapHub/screens/SEED/seedash/seedash.dart';
import 'package:GapHub/screens/others/dashboards/average_seed/doughnut_chart.dart';
import 'package:GapHub/screens/homepage/widget/row_view_details.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widget/label_legend.dart';

class AverageSeed extends StatefulWidget {
  final double? height;
  final double? width;
  final String? currency;
  final Map? seeData;

  const AverageSeed({
    this.height,
    this.currency,
    this.seeData,
    this.width,
    super.key,
  });

  @override
  State<AverageSeed> createState() => _AverageSeedState();
}

class _AverageSeedState extends State<AverageSeed> {
  // MARK: - Constants
  static const int _timeoutDuration = 40;
  static const String _loadingMessage = 'Loading';
  static const String _timeoutMessage = 'Service timed out';

  // MARK: - Dependencies
  late final DialogBox _dialogBox;

  // MARK: - Color Constants
  static const List<String> _chartHexColors = [
    '0xff4CAF50', // Savings - Green
    '0xffFF9800', // Education - Orange
    '0xFFF44336', // Expenditure - Red
    '0xff009688', // Discretionary - Teal
  ];

  static const List<String> _chartLabels = [
    "Savings",
    "Education",
    "Expenditure",
    "Discretionary",
  ];

  @override
  void initState() {
    super.initState();
    _initializeDependencies();
  }

  // MARK: - Initialization
  void _initializeDependencies() {
    _dialogBox = DialogBox();
  }

  // MARK: - Data Processing
  int _safeParseNumber(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.round();
    return int.tryParse(value.toString()) ?? 0;
  }

  List<int> _calculatePercentages({
    required int savings,
    required int education,
    required int expenditure,
    required int discretionary,
  }) {
    final total = savings + education + expenditure + discretionary;

    // Handle zero total case
    if (total == 0) return [0, 100, 0, 0];

    // Calculate raw percentages
    var percentages = [
      ((savings / total) * 100).round(),
      ((education / total) * 100).round(),
      ((expenditure / total) * 100).round(),
      ((discretionary / total) * 100).round(),
    ];

    // Adjust for rounding errors to ensure total is exactly 100
    final sum = percentages.reduce((a, b) => a + b);
    if (sum != 100) {
      percentages[0] += 100 - sum;
    }

    return percentages;
  }

  Map<String, dynamic> _extractTableData() {
    final tableData = widget.seeData?["table"] ?? {};
    return {
      'savings': _safeParseNumber(tableData["savings"]),
      'education': _safeParseNumber(tableData["education"]),
      'expenditure': _safeParseNumber(tableData["expenditure"]),
      'discretionary': _safeParseNumber(tableData["discretionary"]),
    };
  }

  // MARK: - Chart Data
  bool _isAllSeedDataZero() {
    final list = widget.seeData?["seed_web"] ?? [];
    return list.every((element) => element == 0);
  }

  // MARK: - Navigation
  Future<void> _navigateToSeedDetails() async {
    final isLoading = _DialogStateManager(context, _dialogBox);

    try {
      await isLoading.show();

      final token = await _getAuthToken();
      if (token == null) {
        await isLoading.hide();
        _showAuthenticationError();
        return;
      }

      final response = await _fetchSeedData(token);
      await isLoading.hide();

      if (response != null) {
        await _handleSuccessfulResponse(response);
      }
    } catch (e) {
      await isLoading.hide();
      _showError('An error occurred: ${e.toString()}');
    }
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tokenDB');
  }

  Future<Map<String, dynamic>?> _fetchSeedData(String token) async {
    try {
      final url = Uri.parse("$baseUrl/app/seed");
      final response = await http
          .get(url, headers: {"Authorization": 'Bearer $token'})
          .timeout(const Duration(seconds: _timeoutDuration));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        _showError('Failed to load data: ${response.statusCode}');
        return null;
      }
    } on TimeoutException catch (_) {
      _showError(_timeoutMessage);
      return null;
    } catch (e) {
      _showError('Network error: ${e.toString()}');
      return null;
    }
  }

  Future<void> _handleSuccessfulResponse(Map<String, dynamic> data) async {
    if (!mounted) return;

    context.read<Providers>().setSeeData(data);
    Navigator.push(context, MaterialPageRoute(builder: (context) => Seedash()));
  }

  void _showAuthenticationError() {
    if (!mounted) return;
    _dialogBox.information(
      context,
      'Error',
      'Authentication token not found. Please log in again.',
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    _dialogBox.information(context, 'Error', message);
  }

  // MARK: - UI Builders
  Widget _buildQuoteText() {
    return Text(
      'How currency flows through your life is the personality of your money!',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.grayColor,
        fontFamily: 'Nunito',
        fontStyle: FontStyle.italic,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildDoughnutChart(List<int> percentages) {
    return DoughnutChart(
      hexColors: _chartHexColors,
      labels: _chartLabels,
      values: _isAllSeedDataZero() ? [0, 100, 0, 0] : percentages,
    );
  }

  Widget _buildLegendRow1() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.width! * 0.05),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          LabelLegend(circleColor: Color(0xff4CAF50), text: 'Savings'),
          LabelLegend(circleColor: Color(0xFFF44336), text: 'Expenditure  '),
        ],
      ),
    );
  }

  Widget _buildLegendRow2() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.width! * 0.05),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          LabelLegend(circleColor: Color(0xffFF9800), text: 'Education'),
          LabelLegend(circleColor: Color(0xff009688), text: 'Discretionary'),
        ],
      ),
    );
  }

  Widget _buildCardContent(List<int> percentages) {
    return Column(
      children: [
        SizedBox(height: widget.height! * .03),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _buildQuoteText(),
        ),
        SizedBox(height: widget.height! * .03),
        _buildDoughnutChart(percentages),
        SizedBox(height: widget.height! * .02),
        _buildLegendRow1(),
        SizedBox(height: widget.height! * .02),
        _buildLegendRow2(),
        SizedBox(height: widget.height! * .03),
      ],
    );
  }

  // MARK: - Build Method
  @override
  Widget build(BuildContext context) {
    final tableData = _extractTableData();

    final percentages = _calculatePercentages(
      savings: tableData['savings'] as int,
      education: tableData['education'] as int,
      expenditure: tableData['expenditure'] as int,
      discretionary: tableData['discretionary'] as int,
    );
    return Column(
      children: [
        RowViewDetails(
          mainText: 'Average Seed',
          detailText: 'View Details',
          onTap: _navigateToSeedDetails,
          arrowTap: true,
        ),
        SizedBox(height: widget.height! * .02),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(
              color: Color.fromARGB(255, 241, 241, 241),
              width: 1.5,
            ),
          ),
          child: _buildCardContent(percentages),
        ),
        SizedBox(height: widget.height! * .02),
      ],
    );
  }
}

// MARK: - Helper Class for Dialog State Management
class _DialogStateManager {
  final BuildContext context;
  final DialogBox dialogBox;
  bool _isDialogPopped = false;
  Timer? _timer;

  _DialogStateManager(this.context, this.dialogBox);

  Future<void> show() async {
    dialogBox.waiting(context, 'Loading');

    _timer = Timer(const Duration(seconds: 40), () {
      if (context.mounted && !_isDialogPopped) {
        Navigator.pop(context);
        _isDialogPopped = true;
        dialogBox.information(context, 'Status', 'Service timed out');
      }
    });
  }

  Future<void> hide() async {
    _timer?.cancel();
    if (context.mounted && !_isDialogPopped) {
      Navigator.pop(context);
      _isDialogPopped = true;
    }
  }
}
