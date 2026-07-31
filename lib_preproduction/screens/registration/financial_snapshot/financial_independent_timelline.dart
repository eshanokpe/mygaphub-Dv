import 'package:GapHub/provider/acquisiProvider.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/customBottomSheet.dart';
import 'package:GapHub/widgets/custom_appbar_logo.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:GapHub/widgets/custom_input_field_multistep.dart';
import 'package:GapHub/widgets/custom_input_field_multistep2.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
 
import 'time_financial_independent.dart';

class FinancialIndependentTimeline extends StatefulWidget {
  const FinancialIndependentTimeline({super.key});

  @override
  State<FinancialIndependentTimeline> createState() =>
      _FinancialIndependentTimelineState();
}

class _FinancialIndependentTimelineState
    extends State<FinancialIndependentTimeline> {
  final TextEditingController _roce = TextEditingController();
  final TextEditingController _invest = TextEditingController();
  final now = DateTime.now();

  // Add FocusNodes
  final FocusNode _investFocus = FocusNode();
  final FocusNode _roceFocus = FocusNode();
  bool isFetching = false;
  DialogBox dialogBox = DialogBox();
  bool toggs = true;
  double shortfall = 0.0;
  double avr = 0;
  num t2fi = 0;
  double total = 0;
  double other = 0;
  String selectedCurrency = '';

  @override
  void initState() {
    super.initState();
    addFocusListeners(); // Add focus listeners
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   fetchFinancialRecommendation();
    // });
    getBudget();
  }

  @override
  void dispose() {
    _invest.dispose();
    _roce.dispose();
    _investFocus.dispose(); // Dispose FocusNodes
    _roceFocus.dispose();
    super.dispose();
  }

  // Helper function to format text to two decimal places
  void _formatDecimalField(TextEditingController controller) {
    final text = controller.text;
    if (text.isNotEmpty) {
      final value = double.tryParse(text);
      if (value != null) {
        controller.text = value.toStringAsFixed(2);
      }
    }
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
  });
}

  @override
  Widget build(BuildContext context) {
    final calculatorModel = Provider.of<AcquisiProvider>(context);

    var a = double.tryParse(calculatorModel.savings) ?? 0;
    var b = double.tryParse(calculatorModel.education) ?? 0;
    var c = double.tryParse(calculatorModel.mortgage) ?? 0;
    var d = double.tryParse(calculatorModel.mobility) ?? 0;
    var e = double.tryParse(calculatorModel.expenses) ?? 0;
    var f = double.tryParse(calculatorModel.utility) ?? 0;
    var g = double.tryParse(calculatorModel.debtRepay) ?? 0;
    var h = double.tryParse(calculatorModel.charity) ?? 0;
    var other = double.tryParse(calculatorModel.otherWages) ?? 0;
    total = a + b + c + d + e + f + g + h;

    Orientation orientation = MediaQuery.of(context).orientation;
    final screenWidth = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    const double paddingValue = 16.0;
    final double percentagePadding = paddingValue / screenWidth * 100;
    final double leftPadding = screenWidth * percentagePadding / 100;
    final double rightPadding = screenWidth * percentagePadding / 100;
    now.year.toDouble();
    String symbol;
    var symboll = selectedCurrency.split(" ").toList();
    symbol = symboll[0];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBarLogo(
          title: '',
          onBackPressed: () {
            Navigator.pop(context);
          },
          actionIconPath: 'assets/logo.png',
          onActionPressed: () {},
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(leftPadding, 0, rightPadding, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Financial Independence Timeline',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontFamily: 'NunitoSans',
                      fontSize: 20.sp,
                      color: AppColors.blackColor,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Your status can be improved by saving more for rainy day and acquiring more income-generating assets 💡',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                      color: AppColors.blackColor,
                      height: 1.2.sp,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Monthly Asset Portfolio Income (API) needed',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                      color: AppColors.blackColor,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '$symbol${context.watch<Providers>().totMonExp.toStringAsFixed(2)}'
                        .replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        ),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontFamily: "NunitoSans",
                      fontSize: 20.sp,
                      color: AppColors.greenColordark,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Your Current Monthly Asset Portfolio Income',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                      color: AppColors.blackColor,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '$symbol${double.parse(calculatorModel.otherWages).toStringAsFixed(2)}'
                        .replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        ),
                    style: TextStyle(
                      fontFamily: "NunitoSans",
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 15.h),
                const Divider(
                  color: Color.fromARGB(255, 244, 244, 244),
                  thickness: 1.5,
                  indent: 5,
                  endIndent: 5,
                ),
                SizedBox(height: 15.h),
                Text(
                  'How much can you set aside monthly for investments?',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                CustomInputFieldMultiStep(
                  focusNode: _investFocus,
                  label: '',
                  image: '',
                  maxLines: 1,
                  suffixText: '',
                  currencies: symbol,
                  keyboardType: TextInputType.number,
                  controller: _invest,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the amount';
                    }
                    return null;
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "What is your expected Return On Capital ",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16.sp,
                              color: AppColors.blackColor,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "Employed (ROCE) ?",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16.sp,
                                  color: AppColors.blackColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                child: SvgPicture.asset(
                                  'assets/images/infor.svg',
                                ),
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(56.0),
                                        topRight: Radius.circular(56.0),
                                      ),
                                    ),
                                    builder: (BuildContext context) {
                                      return const CustomBottomSheet(
                                        title:
                                            'What is your expected Return On Capital Employed (ROCE) ?',
                                        content:
                                            'To help you achieve the monthly financial target, you will need to consider investments with adequate returns. Choose a desired return on capital employed (Typical conventional rate of return, is between 3% to 10%)',
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.008),
                CustomInputFieldMultiStep2(
                  label: '',
                  maxLines: 1,
                  image: '',
                  currencies: '',
                  suffixText: '%',
                  keyboardType: TextInputType.number,
                  controller: _roce,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the amount';
                    }
                    return null;
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 10.h, 0, 20.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Find out below how long it will take you to become financially independent based on your affordability.',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w400,
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    bottom: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: CustomButton(
                            text: 'See Result',
                            borderRadius: 30,
                            fontSize: 16.sp,
                            borderSide: false,
                            icon: Icons.arrow_forward_ios,
                            iconColor: Colors.white,
                            borderColor: Colors.white,
                            onPressed: () async {
                              // Prevent multiple submissions
                              if (isFetching) return;

                              // Validate input fields
                              if (_roce.text.isEmpty || _invest.text.isEmpty) {
                                dialogBox.information(
                                  context,
                                  'Status',
                                  'Please fill in all required fields',
                                );
                                return;
                              }

                              try {
                                // Set loading state
                                setState(() => isFetching = true);

                                // Show loading dialog with custom message
                                dialogBox.waiting(
                                  context,
                                  'Calculating your financial independence timeline...',
                                );

                                // Dismiss keyboard
                                FocusScope.of(
                                  context,
                                ).requestFocus(FocusNode());

                                // Parse and validate numeric values
                                final roceValue =
                                    double.tryParse(_roce.text) ?? 0;
                                final investValue =
                                    double.tryParse(_invest.text) ?? 0;

                                if (roceValue <= 0) {
                                  Navigator.pop(
                                    context,
                                  ); // Dismiss loading dialog
                                  dialogBox.information(
                                    context,
                                    'Invalid Input',
                                    'Return on Capital Employed (ROCE) must be greater than 0',
                                  );
                                  return;
                                }

                                if (investValue <= 0) {
                                  Navigator.pop(
                                    context,
                                  ); // Dismiss loading dialog
                                  dialogBox.information(
                                    context,
                                    'Invalid Input',
                                    'Monthly investment amount must be greater than 0',
                                  );
                                  return;
                                }

                                // Calculate financial metrics
                                setState(() {
                                  shortfall = total - other;
                                  avr = (shortfall * 12 * 100) / roceValue;
                                  t2fi = (avr / investValue) / 12;
                                  calculatorModel.roce.text = _roce.text;
                                  calculatorModel.investment.text =
                                      _invest.text;
                                });

                                // Submit investment data to backend
                                await submitInvestment(
                                  calculatorModel.selectedCurrency,
                                  calculatorModel.savings,
                                  calculatorModel.education,
                                  calculatorModel.mortgage,
                                  calculatorModel.mobility,
                                  calculatorModel.expenses,
                                  calculatorModel.utility,
                                  calculatorModel.debtRepay,
                                  calculatorModel.charity,
                                  calculatorModel.otherWages,
                                  calculatorModel.rainyDays,
                                  _roce.text,
                                  _invest.text,
                                );

                                // Fetch financial recommendations
                                await fetchFinancialRecommendation();

                                // Log for debugging (consider removing in production)
                                if (kDebugMode) {
                                  // print(
                                  //   'After fetch - provider data: ${context.read<Providers>().calculatorData}',
                                  // );
                                }

                                final updatedProvider = Provider.of<Providers>(
                                  context,
                                  listen: false,
                                ).calculatorData;

                                if (kDebugMode) {
                                  print(
                                    'Income_updatedProvider: ${updatedProvider['income']}',
                                  );
                                  print(
                                    'Seed cost_updatedProvider: ${updatedProvider['seed_cost']}',
                                  );
                                }

                                // Ensure widget is still mounted before navigation
                                if (!mounted) return;

                                // Dismiss loading dialog before navigation
                                Navigator.pop(context);
   
                                // Navigate to result screen with slide transition
                                navigateWithSlideTransition(
                                  context: context,
                                  destinationScreen: TimeFinancialIndependent(
                                    suggestedInvestment:
                                        updatedProvider['suggested_investment'] ??
                                        0,
                                    seedCost: updatedProvider['seed_cost'] ?? 0,
                                    income: updatedProvider['income'] ?? 0,
                                    shortfalls: 0,
                                    t2fi: t2fi,
                                    timeFiniancial:
                                        updatedProvider['time_finiancial_chart'] ??
                                        0,
                                    currency: selectedCurrency,
                                    roceController: _roce,
                                    investController: _invest,
                                  ),
                                  transitionDuration: const Duration(
                                    milliseconds: 200,
                                  ),
                                );
                              } catch (e) {
                                // Dismiss loading dialog if showing
                                if (mounted && Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }

                                // Handle error with user-friendly message
                                if (mounted) {
                                  print('Exception occurred: $e');

                                  String errorMessage =
                                      'An unexpected error occurred. Please try again.';

                                  if (e.toString().contains('429')) {
                                    errorMessage =
                                        'Too many requests. Please wait a moment and try again.';
                                  } else if (e.toString().contains('timeout')) {
                                    errorMessage =
                                        'Request timed out. Please check your internet connection.';
                                  } else if (e.toString().contains(
                                    'No token found',
                                  )) {
                                    errorMessage =
                                        'Session expired. Please log in again.';
                                  }

                                  dialogBox.information(
                                    context,
                                    'Unable to Calculate',
                                    errorMessage,
                                  );
                                }
                              } finally {
                                // Reset loading state if widget is still mounted
                                if (mounted) {
                                  setState(() {
                                    isFetching = false;
                                    toggs = false;
                                  });
                                }
                              }
                            },
                            color: AppColors.primaryColor,
                            textColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Add listeners to format on focus loss
  void addFocusListeners() {
    _investFocus.addListener(() {
      if (!_investFocus.hasFocus) _formatDecimalField(_invest);
    });
    _roceFocus.addListener(() {
      if (!_roceFocus.hasFocus) _formatDecimalField(_roce);
    });
  }

  Future<void> submitInvestment(
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
    String roce,
    String invest,
  ) async {
    try {
      var url = Uri.parse("$baseUrl/app/calculator/investment");
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB') ?? '';

      Map<String, dynamic> body = {
        "currency": currency,
        "periodic_savings": savings.isNotEmpty ? savings : "0",
        "education": education.isNotEmpty ? education : "0",
        "mortgage": mortgage.isNotEmpty ? mortgage : "0",
        "mobility": mobility.isNotEmpty ? mobility : "0",
        "expenses": expenses.isNotEmpty ? expenses : "0",
        "utility": utility.isNotEmpty ? utility : "0",
        "dept_repay": debtRepay.isNotEmpty ? debtRepay : "0",
        "charity": charity.isNotEmpty ? charity : "0",
        "other_income": otherWages.isNotEmpty ? otherWages : "0",
        "extra_save": rainyDays.isNotEmpty ? rainyDays : "0",
        "roce": roce.isNotEmpty ? roce : "0",
        "investment": invest.isNotEmpty ? invest : "0",
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

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        print('resResponse:${data['data']}');
      } else if (response.statusCode == 429) {
        throw Exception('Too many requests. Please wait before trying again.');
      } else {
        throw Exception('Failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('Error in submitInvestment: $e');
      rethrow;
    }
  }

  Future<void> fetchFinancialRecommendation({int retryCount = 0}) async {
    try {
      // if (isFetching) return;
      setState(() => isFetching = true);

      final url = Uri.parse('$baseUrl/app/financial/recommendations');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null) throw Exception("No token found");

      final response = await http.get(
        url,
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final Map<String, dynamic> dataResponse = data["data"];

        // Debug print
        print('Received data: $dataResponse');

        if (!mounted) return;
        context.read<Providers>().setCalculator(dataResponse);
      } else if (response.statusCode == 429) {
        final delay = Duration(seconds: (retryCount + 1) * 2);
        await Future.delayed(delay);
        if (retryCount < 3) {
          return fetchFinancialRecommendation(retryCount: retryCount + 1);
        }
      }
    } catch (e) {
      print('Error in fetchFinancialRecommendation: $e');
      if (mounted) dialogBox.information(context, 'Error', e.toString());
    } finally {
      if (mounted) setState(() => isFetching = false);
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