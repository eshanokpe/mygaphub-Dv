import 'dart:convert';
import 'package:GapHub/models/calculatormodel.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/customBottomSheet.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:GapHub/widgets/custom_input_field_multistep.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
 
class MonthlyBudget extends StatefulWidget {
  final VoidCallback nextPage;
  final Map<String, dynamic>? selectedCurrency;
  final void Function(Calculatormodel parameters) onSave;

  const MonthlyBudget({
    super.key,
    required this.nextPage,
    this.selectedCurrency,
    required this.onSave,
  });

  @override
  _MonthlyBudgetState createState() => _MonthlyBudgetState();
}

class _MonthlyBudgetState extends State<MonthlyBudget> {
  DialogBox dialogBox = DialogBox();
  TextEditingController savings = TextEditingController(text: '');
  TextEditingController education = TextEditingController(text: '');
  TextEditingController mortgage = TextEditingController(text: '');
  TextEditingController mobility = TextEditingController(text: '');
  TextEditingController expenses = TextEditingController(text: '');
  TextEditingController utility = TextEditingController(text: '');
  TextEditingController debtRepay = TextEditingController(text: '');
  TextEditingController charity = TextEditingController(text: '');

  // FocusNodes
  final FocusNode _savingsFocus = FocusNode();
  final FocusNode _educationFocus = FocusNode();
  final FocusNode _mortgageFocus = FocusNode();
  final FocusNode _mobilityFocus = FocusNode();
  final FocusNode _expensesFocus = FocusNode();
  final FocusNode _utilityFocus = FocusNode();
  final FocusNode _debtRepayFocus = FocusNode();
  final FocusNode _charityFocus = FocusNode();

  double total = 0;
  String selectedCurrency = '';

 
  @override
  void initState() {
    super.initState();
    _initializeCurrency();
    _initializeControllers();
    _addListeners();
    _addFocusListeners();
    total = _calculateTotal();
  }

void _initializeCurrency() {
  final providers = context.read<Providers>();

  String fullCurrencyString = providers.currencySymbol ?? '';

  if (widget.selectedCurrency != null) {
    fullCurrencyString =
        widget.selectedCurrency!['symbol'] ??
        widget.selectedCurrency!['code'] ??
        fullCurrencyString;
  }

  if (fullCurrencyString.isEmpty) {
    fullCurrencyString =
        providers.calculatorData['currency']?.toString() ?? '';
  }

  selectedCurrency = _extractCurrencySymbol(fullCurrencyString);
}

  String _extractCurrencySymbol(String fullCurrencyString) {
    if (fullCurrencyString.isEmpty) return '';

    if (fullCurrencyString.contains(' ')) {
      return fullCurrencyString.split(' ')[0];
    }

    return fullCurrencyString;
  }

  void _initializeControllers() {
    final calculatorData = context.read<Providers>().calculatorData;

    String getInitialValue(String key) {
      print('Initializing $key with value: ${calculatorData[key]}');
      final value = calculatorData[key];
      if (value == null || value == '0' || value == 0) return '';
      final numValue = double.tryParse(value.toString());
      return numValue != null ? numValue.toStringAsFixed(2) : '';
    }

    savings.text = getInitialValue("periodic_savings");
    education.text = getInitialValue("education");
    mortgage.text = getInitialValue("mortgage");
    mobility.text = getInitialValue("mobility");
    expenses.text = getInitialValue("expenses");
    utility.text = getInitialValue("utility");
    debtRepay.text = getInitialValue("dept_repay");
    charity.text = getInitialValue("charity");
  }

  void _addListeners() {
    savings.addListener(_updateTotal);
    education.addListener(_updateTotal);
    mortgage.addListener(_updateTotal);
    mobility.addListener(_updateTotal);
    expenses.addListener(_updateTotal);
    utility.addListener(_updateTotal);
    debtRepay.addListener(_updateTotal);
    charity.addListener(_updateTotal);
  }

  void _addFocusListeners() {
    _savingsFocus.addListener(() {
      if (!_savingsFocus.hasFocus) _formatCurrencyField(savings);
    });
    _educationFocus.addListener(() {
      if (!_educationFocus.hasFocus) _formatCurrencyField(education);
    });
    _mortgageFocus.addListener(() {
      if (!_mortgageFocus.hasFocus) _formatCurrencyField(mortgage);
    });
    _mobilityFocus.addListener(() {
      if (!_mobilityFocus.hasFocus) _formatCurrencyField(mobility);
    });
    _expensesFocus.addListener(() {
      if (!_expensesFocus.hasFocus) _formatCurrencyField(expenses);
    });
    _utilityFocus.addListener(() {
      if (!_utilityFocus.hasFocus) _formatCurrencyField(utility);
    });
    _debtRepayFocus.addListener(() {
      if (!_debtRepayFocus.hasFocus) _formatCurrencyField(debtRepay);
    });
    _charityFocus.addListener(() {
      if (!_charityFocus.hasFocus) _formatCurrencyField(charity);
    });
  }

  void _updateTotal() {
    setState(() {
      total = _calculateTotal();
    });
  }

  double _calculateTotal() {
    return (double.tryParse(savings.text) ?? 0) +
        (double.tryParse(education.text) ?? 0) +
        (double.tryParse(mortgage.text) ?? 0) +
        (double.tryParse(mobility.text) ?? 0) +
        (double.tryParse(expenses.text) ?? 0) +
        (double.tryParse(utility.text) ?? 0) +
        (double.tryParse(debtRepay.text) ?? 0) +
        (double.tryParse(charity.text) ?? 0);
  }

  void _formatCurrencyField(TextEditingController controller) {
    final text = controller.text;
    if (text.isNotEmpty) {
      final value = double.tryParse(text);
      if (value != null) {
        controller.text = value.toStringAsFixed(2);
      }
    }
  }

  @override
  void dispose() {
    savings.removeListener(_updateTotal);
    education.removeListener(_updateTotal);
    mortgage.removeListener(_updateTotal);
    mobility.removeListener(_updateTotal);
    expenses.removeListener(_updateTotal);
    utility.removeListener(_updateTotal);
    debtRepay.removeListener(_updateTotal);
    charity.removeListener(_updateTotal);

    _savingsFocus.dispose();
    _educationFocus.dispose();
    _mortgageFocus.dispose();
    _mobilityFocus.dispose();
    _expensesFocus.dispose();
    _utilityFocus.dispose();
    _debtRepayFocus.dispose();
    _charityFocus.dispose();

    savings.dispose();
    education.dispose();
    mortgage.dispose();
    mobility.dispose();
    expenses.dispose();
    utility.dispose();
    debtRepay.dispose();
    charity.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providers = context.watch<Providers>();
    final rawCurrency = providers.currencySymbol?.isNotEmpty == true
      ? providers.currencySymbol!
      : providers.calculatorData['currency']?.toString() ?? '';
     final symbol = _extractCurrencySymbol(rawCurrency).isNotEmpty
      ? _extractCurrencySymbol(rawCurrency)
      : selectedCurrency; // fallback to cached value from initState

   

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
        child: Column(
          children: [
            _buildHeader(),
            _buildInputField(symbol),
            _buildTotalSection(symbol),
            _buildContinueButton(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.08),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Row(
            children: [
              Text(
                'Monthly Budget ',
                style: TextStyle(
                  fontFamily: 'NunitoSans',
                  fontWeight: FontWeight.w800,
                  fontSize: 22.sp,
                  color: AppColors.blackColor,
                ),
              ),
              Image.asset(
                'assets/images/monthly_buget.png',
                width: 22.w,
                height: 32.h,
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Compute your Monthly Budget and provide figures for your savings and portfolio income',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w500,
              fontSize: 17.sp,
              color: AppColors.blackColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(selectedCurrency) {
    return Column(
      children: [
        SizedBox(height: 32.h),
        CustomInputFieldMultiStep(
          focusNode: _savingsFocus,
          label: 'How much do you set aside for savings?',
          image: '',
          maxLines: 1,
          suffixText: '',
          currencies: selectedCurrency,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          controller: savings,
          onChanged: (value) {},
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the amount';
            }
            return null;
          },
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "How much do you spend on your personal",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 17.sp,
                    color: AppColors.blackColor,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "development?",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 17.sp,
                        color: AppColors.blackColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      child: SvgPicture.asset(
                        'assets/images/infor.svg',
                        height: 20.h,
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
                                  'How much do you spend on your personal development?',
                              content:
                                  'This includes Seminars, training, courses, books, e.t.c',
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        CustomInputFieldMultiStep(
          focusNode: _educationFocus,
          label: '',
          image: '',
          maxLines: 1,
          suffixText: '',
          currencies: selectedCurrency,
          onChanged: (value) {},
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          controller: education,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the amount';
            }
            return null;
          },
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        CustomInputFieldMultiStep(
          focusNode: _mortgageFocus,
          label: 'How much is your Rent or Mortgage?',
          currencies: selectedCurrency,
          suffixText: '',
          maxLines: 1,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          controller: mortgage,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the amount';
            }
            return null;
          },
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        CustomInputFieldMultiStep(
          focusNode: _mobilityFocus,
          label: 'What is your total Mobility Cost?',
          image: 'assets/images/infor.svg',
          suffixText: '',
          maxLines: 1,
          currencies: selectedCurrency,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          controller: mobility,
          onChanged: (value) {},
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the amount';
            }
            return null;
          },
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
                  title: 'What is your total Mobility Cost?',
                  content: 'This includes Car Insurance, MOT, Fuel, e.t.c',
                );
              },
            );
          },
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        CustomInputFieldMultiStep(
          focusNode: _expensesFocus,
          label: 'How much is your Home Expenses?',
          image: 'assets/images/infor.svg',
          suffixText: '',
          maxLines: 1,
          currencies: selectedCurrency,
          onChanged: (value) {},
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          controller: expenses,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the amount';
            }
            return null;
          },
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
                  title: 'How much is your Home Expenses?',
                  content:
                      'This includes Groceries, Clothes, Insurances, e.t.c',
                );
              },
            );
          },
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        CustomInputFieldMultiStep(
          focusNode: _utilityFocus,
          label: 'How much is your monthly Utility Costs?',
          image: 'assets/images/infor.svg',
          currencies: selectedCurrency,
          maxLines: 1,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          suffixText: '',
          controller: utility,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the amount';
            }
            return null;
          },
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
                  title: 'How much is your monthly Utility Costs?',
                  content:
                      'This includes Council Tax, Energy, TV, Mobile, e.t.c',
                );
              },
            );
          },
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How much is your monthly Debt Repayment',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                Text(
                  'Cost?',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 5.w),
                InkWell(
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
                              'How much is your monthly Debt Repayment Cost?',
                          content:
                              'This includes Credit Cards, Loans, Hire Purchase, e.t.c',
                        );
                      },
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/images/infor.svg',
                    height: 20.h,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 10.h),
        CustomInputFieldMultiStep(
          focusNode: _debtRepayFocus,
          label: '',
          image: '',
          suffixText: '',
          maxLines: 1,
          currencies: selectedCurrency,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          controller: debtRepay,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the amount';
            }
            return null;
          },
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'How much do you spend on giving to others including charity?',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 5.w),
              ],
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        CustomInputFieldMultiStep(
          focusNode: _charityFocus,
          label: '',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          currencies: selectedCurrency,
          controller: charity,
          maxLines: 1,
          suffixText: '',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the amount';
            }
            return null;
          },
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        SizedBox(height: MediaQuery.of(context).size.height * .03),
      ],
    );
  }

  Widget _buildTotalSection(selectedCurrency) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "TOTAL",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.blackColor,
              ),
            ),
            Row(
              children: [
                Text(
                  '$selectedCurrency ${total.toStringAsFixed(2)}'
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.blackColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.only(right: 150.0),
            child: Text(
              "This is the TARGET income for your Asset Portfolio income",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w300,
                fontSize: 14,
                color: AppColors.blackColor,
              ),
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
      ],
    );
  }

  Widget _buildContinueButton() {
    return CustomButton(
      text: _isSubmitting ? 'Saving...' : 'Continue',
      borderRadius: 30,
      fontSize: 16.sp,
      borderSide: false,
      icon: _isSubmitting ? null : Icons.arrow_forward_ios,
      borderColor: Colors.white,
      iconColor: Colors.white,
      onPressed: _isSubmitting ? null : _handleContinue,
      color: _isSubmitting
          ? AppColors.primaryColor.withOpacity(0.6)
          : AppColors.primaryColor,
      textColor: Colors.white,
    );
  }

  bool _isSubmitting = false;

void _handleContinue() async {
  if (_isSubmitting) return;

  final providers = context.read<Providers>();
  FocusScope.of(context).unfocus();

  if (!_validateFields()) return;
  if (!_validateTotal()) return;

  setState(() => _isSubmitting = true);

  try {
    final budgetData = _buildBudgetPayload(providers);
    final parameters = _buildCalculatorModel(providers, budgetData);

    providers.setTotMonthly(total);
    providers.updateBudgetData(budgetData);

    await _submitBudget(budgetData);

    if (!mounted) return;

    widget.onSave(parameters);
    widget.nextPage();
  } catch (e) {
    debugPrint('_handleContinue error: $e');
    if (!mounted) return;
    dialogBox.information(
      context,
      'Error',
      'Something went wrong while saving your budget. Please try again.',
    );
  } finally {
    if (mounted) setState(() => _isSubmitting = false);
  }
}

bool _validateFields() {
  final fields = {
    'savings': savings.text,
    'education': education.text,
    'mortgage': mortgage.text,
    'mobility': mobility.text,
    'expenses': expenses.text,
    'utility': utility.text,
    'debt repayment': debtRepay.text,
    'charity': charity.text,
  };

  final hasEmpty = fields.values.any((v) => v.trim().isEmpty);

  if (hasEmpty) {
    dialogBox.information(
      context,
      'Incomplete Fields',
      'Fields cannot be empty. If you do not have a value for any field, kindly input "0".',
    );
    return false;
  }
  return true;
}

  bool _validateTotal() {
    if (total <= 0) {
      dialogBox.information(
        context,
        'Invalid Total',
        'Total Monthly Expenditure cannot be 0.',
      );
      return false;
    }
    return true;
  }

  Map<String, String> _buildBudgetPayload(Providers providers) {
    // Use the FULL currency string (e.g. "£ GBP"), not just the symbol
    final fullCurrency = providers.currencySymbol?.isNotEmpty == true
        ? providers.currencySymbol!
        : providers.calculatorData['currency']?.toString() ?? selectedCurrency;

    // Persist so it survives navigation back to this screen
    providers.calculatorData['currency'] = fullCurrency;

    return {
      'currency': fullCurrency,  // <-- was: _extractCurrencySymbol(rawCurrency)
      'periodic_savings': _valueOrZero(savings.text),
      'education': _valueOrZero(education.text),
      'mortgage': _valueOrZero(mortgage.text),
      'mobility': _valueOrZero(mobility.text),
      'expenses': _valueOrZero(expenses.text),
      'utility': _valueOrZero(utility.text),
      'dept_repay': _valueOrZero(debtRepay.text),
      'charity': _valueOrZero(charity.text),
    };
  }

Calculatormodel _buildCalculatorModel(
  Providers providers,
  Map<String, String> budgetData,
) {
  final calculatorData = providers.calculatorData;
  return Calculatormodel(
    currency: budgetData['currency']!,
    periodic: budgetData['periodic_savings']!,
    education: budgetData['education']!,
    mortgage: budgetData['mortgage']!,
    mobility: budgetData['mobility']!,
    expenses: budgetData['expenses']!,
    utility: budgetData['utility']!,
    debtRepay: budgetData['dept_repay']!,
    charity: budgetData['charity']!,
    extraSave: calculatorData['extra_save']?.toString() ?? '0',
    otherIncome: calculatorData['other_income']?.toString() ?? '0',
  );
}

  String _valueOrZero(String text) => text.isEmpty ? '0' : text;

  Future<void> _submitBudget(Map<String, String> budgetData) async {
    var url = Uri.parse("$baseUrl/app/calculator/budget");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    Map<dynamic, dynamic>? calculatorData = {};

    if (mounted) {
      calculatorData = context.read<Providers>().calculatorData;
    }

    String currencyy = calculatorData["currency"] ?? budgetData["currency"]!;
    print('currencyy: $currencyy');

    Map<String, String> body = {
      "currency": currencyy,
      "periodic_savings": budgetData["periodic_savings"]!,
      "education": budgetData["education"]!,
      "mortgage": budgetData["mortgage"]!,
      "mobility": budgetData["mobility"]!,
      "expenses": budgetData["expenses"]!,
      "utility": budgetData["utility"]!,
      "dept_repay": budgetData["dept_repay"]!,
      "charity": budgetData["charity"]!,
    };

    debugPrint("body: $body");

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

      debugPrint('SuccessresReg: ${response.statusCode}');

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        print('SuccessresReg: ${data['data']}');
      } else {
        Map<String, dynamic> data = jsonDecode(response.body);
        String errorMessage = "Failed to submit budget.";
        if (data['errors'] != null && data['errors'] is Map) {
          errorMessage += " ${data['errors'].values.first}";
        }
        if (mounted) {
          DialogBox().information(context, 'Error', errorMessage);
        }
      }
    } catch (e) {
      if (mounted) {
        DialogBox().information(
          context,
          'Error',
          'Check your internet connection',
        );
      }
    }
  }
}
