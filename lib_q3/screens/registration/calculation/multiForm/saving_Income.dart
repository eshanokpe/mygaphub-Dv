import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/models/calculatormodel.dart';
import 'package:GapHub/screens/registration/calculation/calculating_loading.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:GapHub/widgets/custom_input_field_multistep.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
 
class SavingIncome extends StatefulWidget {
  final VoidCallback onPrevious;
  final Calculatormodel parameters;

  const SavingIncome({
    super.key,
    required this.onPrevious,
    required this.parameters,
  });

  @override
  State<SavingIncome> createState() => _SavingIncomeState(parameters);
}

class _SavingIncomeState extends State<SavingIncome> {
  Calculatormodel parameters;
  _SavingIncomeState(this.parameters)
    : selectedCurrency = '',
      savings = '',
      education = '',
      mortgage = '',
      mobility = '',
      expenses = '',
      utility = '',
      debtRepay = '',
      charity = '';
  final TextEditingController _otherWages = TextEditingController(text: '');
  final TextEditingController _rainyDays = TextEditingController(text: '');
  String savings,
      education,
      mortgage,
      mobility,
      expenses,
      utility,
      debtRepay,
      charity;
  DialogBox dialogBox = DialogBox();
  double total = 0;
  String selectedCurrency;

  // Add FocusNodes
  final FocusNode _otherWagesFocus = FocusNode();
  final FocusNode _rainyDaysFocus = FocusNode();

  increment() {
    setState(() {
      double a = _otherWages.text.isEmpty
          ? 0
          : double.tryParse(_otherWages.text) ?? 0;
      double b = _rainyDays.text.isEmpty
          ? 0
          : double.tryParse(_rainyDays.text.trim()) ?? 0;

      total = a + b;
    });
  }

  // Helper function to format text to two decimal places
  void _formatCurrencyField(TextEditingController controller) {
    final text = controller.text;
    if (text.isNotEmpty) {
      final value = double.tryParse(text);
      if (value != null) {
        controller.text = value.toStringAsFixed(2);
      }
    }
  }

  // Helper to get and format initial value from string
  String _getFormattedInitialValue(dynamic value) {
    if (value == null || value == '0' || value == 0) return '';
    final numValue = double.tryParse(value.toString());
    return numValue != null ? numValue.toStringAsFixed(2) : '';
  }

  @override
  void initState() {
    super.initState();
    _initializeCurrency(); // set currency immediately from provider/calculatorData

    final calculatorData = context.read<Providers>().calculatorData;
    _otherWages.text = _getFormattedInitialValue(
      calculatorData["other_income"],
    );
    _rainyDays.text = _getFormattedInitialValue(calculatorData["extra_save"]);

    _otherWages.addListener(increment);
    _rainyDays.addListener(increment);
    addFocusListeners();
    getBudget(); // still runs in background to sync with server
  }

  void _initializeCurrency() {
    final providers = context.read<Providers>();
    String fullCurrencyString = providers.currencySymbol ?? '';

    // Fallback to calculatorData currency
    if (fullCurrencyString.isEmpty) {
      fullCurrencyString =
          providers.calculatorData['currency']?.toString() ?? '';
    }

    if (fullCurrencyString.isNotEmpty) {
      setState(() { 
        selectedCurrency = fullCurrencyString.contains(' ')
            ? fullCurrencyString.split(' ')[0]
            : fullCurrencyString;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _otherWages.dispose();
    _rainyDays.dispose();
  }

  // Add listeners to format on focus loss
  void addFocusListeners() {
    _otherWagesFocus.addListener(() {
      if (!_otherWagesFocus.hasFocus) _formatCurrencyField(_otherWages);
    });
    _rainyDaysFocus.addListener(() {
      if (!_rainyDaysFocus.hasFocus) _formatCurrencyField(_rainyDays);
    });
  }

  bool _isLoadingBudget = false;

Future<void> getBudget() async {
  if (_isLoadingBudget) return;

  setState(() => _isLoadingBudget = true);

  try {
    final token = await _getToken();
    final data = await _fetchBudgetFromApi(token);
    if (!mounted) return;
    _applyBudgetToState(data);
  } on _AuthException {
    debugPrint('getBudget: No auth token found.');
  } on _ApiException catch (e) {
    debugPrint('getBudget: API error ${e.statusCode} — ${e.message}');
  } catch (e) {
    debugPrint('getBudget: Unexpected error — $e');
  } finally {
    if (mounted) setState(() => _isLoadingBudget = false);
  }
}

Future<String> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('tokenDB');
  if (token == null) throw const _AuthException();
  return token;
}

Future<Map<String, dynamic>> _fetchBudgetFromApi(String token) async {
  final url = Uri.parse('$baseUrl/app/calculator');
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  final body = jsonDecode(response.body) as Map<String, dynamic>;

  if (response.statusCode != 200) {
    throw _ApiException(
      statusCode: response.statusCode,
      message: body['errors']?.toString() ?? 'Unknown error',
    );
  }
  print('savingResponse ${body['data']}');
  return body['data'] as Map<String, dynamic>;
}

void _applyBudgetToState(Map<String, dynamic> data) {
  final currency = data['currency']?.toString() ?? '';
  final symbol = currency.contains(' ') ? currency.split(' ')[0] : currency;

  // Persist resolved currency into provider so it survives navigation
  if (symbol.isNotEmpty) {
    context.read<Providers>().calculatorData['currency'] = symbol;
  }

  setState(() {
    if (symbol.isNotEmpty) selectedCurrency = symbol;
    savings   = data['periodic_savings']?.toString() ?? '0';
    education = data['education']?.toString()        ?? '0';
    mortgage  = data['mortgage']?.toString()         ?? '0';
    mobility  = data['mobility']?.toString()         ?? '0';
    expenses  = data['expenses']?.toString()         ?? '0';
    utility   = data['utility']?.toString()          ?? '0';
    debtRepay = data['dept_repay']?.toString()       ?? '0';
    charity   = data['charity']?.toString()          ?? '0';

    _otherWages.text = _getFormattedInitialValue(data['other_income']);
    _rainyDays.text  = _getFormattedInitialValue(data['extra_save']);
  });
}

  @override
  Widget build(BuildContext context) {
    increment();
    String symbol;
    var symboll = selectedCurrency.split(" ").toList();
    symbol = symboll[0];

    Orientation orientation = MediaQuery.of(context).orientation;
    final screenheight = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final screenWidth = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    const double paddingValue = 16.0;
    final double percentagePadding = paddingValue / screenWidth * 100;
    final double leftPadding = screenWidth * percentagePadding / 100;
    final double rightPadding = screenWidth * percentagePadding / 100;
    final double bottomPadding = screenWidth * percentagePadding / 100;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        leftPadding,
        20.h,
        rightPadding,
        bottomPadding,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  Text(
                    'Savings & Portfolio Income ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 22.sp,
                      color: AppColors.blackColor,
                    ),
                  ),
                  Image.asset(
                    'assets/images/portfolio_income.png',
                    width: 22.w,
                    height: 32.h,
                  ),
                ],
              ),
            ),
            SizedBox(height: screenheight * 0.01),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'You’re almost there—just one more step!',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w500,
                  fontSize: 16.sp,
                  color: AppColors.blackColor,
                ),
              ),
            ),
            SizedBox(height: screenheight * 0.04),
            Text(
              'How much monthly income do you earn from sources (assets) other than your wages?',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: screenheight * 0.01),
            CustomInputFieldMultiStep(
              focusNode: _otherWagesFocus, // Pass FocusNode
              label: '',
              image: '',
              currencies: symbol,
              suffixText: '',
              keyboardType: TextInputType.number,
              controller: _otherWages,
              // Allow decimals, use amountValidator if needed for more complex validation
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (value) {
                print('_otherWages:${_otherWages.text}');

                submitPorfolio(
                  parameters.currency!,
                  parameters.periodic!,
                  parameters.education!,
                  parameters.mortgage!,
                  parameters.mobility!,
                  parameters.expenses!,
                  parameters.utility!,
                  parameters.debtRepay!,
                  parameters.charity!,
                  _rainyDays.text,
                  _otherWages.text,
                );
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the amount';
                }
                return null;
              },
            ),
            SizedBox(height: screenheight * 0.03),
            Text(
              'How much do you have in savings for rainy day?',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: screenheight * 0.01),
            CustomInputFieldMultiStep(
              focusNode: _rainyDaysFocus, // Pass FocusNode
              label: '',
              image: '',
              currencies: symbol,
              suffixText: '',
              keyboardType: TextInputType.number,
              controller: _rainyDays,
              // Allow decimals, use amountValidator if needed for more complex validation
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (value) {
                print('_rainyDays:${_rainyDays.text}');
                submitPorfolio(
                  parameters.currency!,
                  parameters.periodic!,
                  parameters.education!,
                  parameters.mortgage!,
                  parameters.mobility!,
                  parameters.expenses!,
                  parameters.utility!,
                  parameters.debtRepay!,
                  parameters.charity!,
                  _rainyDays.text,
                  _otherWages.text,
                );
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the amount';
                }
                return null;
              },
            ),
            SizedBox(height: 180.h),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: CustomButton(
                  text: 'View Results',
                  fontSize: 16.sp,
                  borderRadius: 30,
                  icon: Icons.arrow_forward_ios,
                  borderSide: false,
                  borderColor: Colors.white,
                  iconColor: Colors.white,
                  onPressed: () {
                    getBudget();
                    if (_rainyDays.text.isEmpty && _otherWages.text.isEmpty) {
                      FocusScope.of(context).requestFocus(FocusNode());
                      dialogBox.information(
                        context,
                        'Status',
                        'Fields cannot be empty. If you do not have a value for any field, kindly input "0"',
                      );
                      return;
                    }
                    if (_rainyDays.text.isEmpty) {
                      _rainyDays.text = '0';
                    }
                    if (_otherWages.text.isEmpty) {
                      _otherWages.text = '0';
                    }

                    // Set parameters before calling submitPortfolio
                    setState(() {
                      parameters.otherIncome = _otherWages.text;
                      parameters.extraSave = _rainyDays.text;
                      parameters.currency = selectedCurrency;
                      parameters.periodic = savings;
                      parameters.education = education;
                      parameters.mortgage = mortgage;
                      parameters.mobility = mobility;
                      parameters.expenses = expenses;
                      parameters.utility = utility;
                      parameters.debtRepay = debtRepay;
                      parameters.charity = charity;
                    });

                    submitPorfolio(
                      parameters.currency!,
                      parameters.periodic!,
                      parameters.education!,
                      parameters.mortgage!,
                      parameters.mobility!,
                      parameters.expenses!,
                      parameters.utility!,
                      parameters.debtRepay!,
                      parameters.charity!,
                      _rainyDays.text,
                      _otherWages.text,
                    );

                    navigateWithSlideTransition(
                      context: context,
                      destinationScreen: CalculatingLoading(
                        widget.parameters,
                        false,
                      ),
                      transitionDuration: const Duration(milliseconds: 200),
                    );
                  },
                  color: AppColors.primaryColor,
                  textColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> submitPorfolio(
    String currency,
    String savings,
    String education,
    String mortgage,
    String mobility,
    String expenses,
    String utility,
    String debtRepay,
    String charity,
    String rainyDays,
    String otherWages,
  ) async {
    if (rainyDays.isEmpty) rainyDays = '0';
    if (otherWages.isEmpty) otherWages = '0';

    var url = Uri.parse("$baseUrl/app/calculator/portfolio");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    Map<String, dynamic> body = {
      "other_income": otherWages,
      "extra_save": rainyDays,
    };
    final response = await http.post(
      url,
      headers: {
        "Authorization": 'Bearer $token',
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: body,
    );
    print("body:$body");
    print('resRegPortflio:${response.statusCode}');
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      print('resResponseSaving_income:${data['data']}');
    } else {
      Map<String, dynamic> data = jsonDecode(response.body);
      print('resResponse:${data['data']}');
    }
  }
}


class _AuthException implements Exception {
  const _AuthException();
}

class _ApiException implements Exception {
  final int statusCode;
  final String message;
  const _ApiException({required this.statusCode, required this.message});
}