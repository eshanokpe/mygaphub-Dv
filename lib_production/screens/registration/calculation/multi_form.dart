import 'dart:convert';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/helpWidget/help_widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/models/calculatormodel.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'multiForm/currency.dart';
import 'multiForm/monthly_budget.dart';
import 'multiForm/saving_Income.dart';

class MultiStepForm extends StatefulWidget {
  final int currentPageIndex;
  final int initialPage;

  const MultiStepForm({
    super.key,
    required this.initialPage,
    required this.currentPageIndex,
  });

  @override
  _MultiStepFormState createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<MultiStepForm> {
  PageController? _pageController;
  int? _currentPageIndex;

  // Calculatormodel _parameters;
  Calculatormodel _parameters = Calculatormodel(
    currency: '0',
    periodic: '0',
    education: '0',
    mortgage: '0',
    mobility: '0',
    expenses: '0',
    utility: '0',
    debtRepay: '0',
    charity: '0',
    extraSave: '0', // Default value
    otherIncome: '0', // Default value
  );
  Map<String, dynamic> selectedCurrency = {};

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.currentPageIndex;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  void _setSelectedCurrency(Map<String, dynamic> currency) {
    setState(() {
      selectedCurrency = currency;
    });
    submitCurrency();
  }

  void _saveParameters(Calculatormodel parameters) {
    setState(() {
      _parameters = parameters;
    });
  }

  void _nextPage() {
    if (_currentPageIndex! < _pages.length - 1) {
      _pageController!.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }
  }

  Future<void> submitCurrency() async {
    var url = Uri.parse("$baseUrl/app/calculator/currency");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    print('Submitting symbol: ${selectedCurrency['symbol']}');
    print('Submitting code: ${selectedCurrency['code']}');
    Provider.of<Providers>(
      context,
      listen: false,
    ).setSymbol('${selectedCurrency['symbol']} ${selectedCurrency['code']}');

    String symbo = Provider.of<Providers>(
      context,
      listen: false,
    ).currencySymbol;
    print('symbo: $symbo');

    // Prepare URL-encoded body
    Map<String, String> body = {"currency": symbo};

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: body,
      );

      print('submitCurrency Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        print('Response Data: ${data['data']}');
      } else {
        Map<String, dynamic> errorData = jsonDecode(response.body);
        print('Error Response: $errorData');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  List<Widget> get _pages => [
    Currency(nextPage: _nextPage, onCurrencySelected: _setSelectedCurrency),
    MonthlyBudget(nextPage: _nextPage, onSave: _saveParameters),
    SavingIncome(parameters: _parameters, onPrevious: _nextPage),
  ];

  Widget _buildBackButton() {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios, size: 20.w, color: Colors.black),
      onPressed: _currentPageIndex == 0
          ? () => Navigator.pop(context)
          : () => _pageController!.previousPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
            ),
    );
  }

  pop() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    // onWillPop: () {
    //   return dialogBox.options(
    //       context, 'Close', 'Are you sure you want to exit?', pop);
    // },
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: _buildBackButton(),
          actions: const [HelpWidget()],
        ),
        body: Column(
          children: [
            Container(
              height: 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: LinearProgressIndicator(
                value: (_currentPageIndex! + 1) / _pages.length,
                minHeight: 3,
                backgroundColor: Colors.white,
                color: AppColors.greenColor,
              ),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                children: _pages,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController!.dispose();
    super.dispose();
  }
}
