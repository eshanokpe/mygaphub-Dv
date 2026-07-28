import 'package:GapHub/models/calculatormodel.dart';
import 'package:GapHub/screens/registration/savingsincomecalc.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SimpleThousandSeparatorAndDecimalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;

    if (newText.isEmpty) {
      return newValue;
    }

    // 1. Filter to allow only digits and at most one decimal point.
    String filtered = '';
    bool decimalFound = false;
    for (int i = 0; i < newText.length; i++) {
      if (RegExp(r'\d').hasMatch(newText[i])) {
        filtered += newText[i];
      } else if (newText[i] == '.' && !decimalFound) {
        filtered += newText[i];
        decimalFound = true;
      }
    }

    // 2. Split into integer and decimal parts.
    List<String> parts = filtered.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';

    // 3. Limit decimal part to 2 digits.
    if (decimalPart.length > 2) {
      decimalPart = decimalPart.substring(0, 2);
    }

    // 4. Sanitize and Format integer part with commas.
    String formattedIntegerPart = "";
    if (integerPart.isNotEmpty) {
      integerPart = BigInt.parse(
        integerPart,
      ).toString(); // Handles leading zeros like "007" -> "7", "0" -> "0"
      int len = integerPart.length;
      for (int i = 0; i < len; i++) {
        formattedIntegerPart += integerPart[i];
        if ((len - 1 - i) % 3 == 0 && (len - 1 - i) != 0) {
          formattedIntegerPart += ',';
        }
      }
    } else if (filtered.contains('.')) {
      // Input was like ".5"
      formattedIntegerPart = "0";
    }

    // 5. Reconstruct the text.
    String resultText = formattedIntegerPart;
    if (filtered.contains('.')) {
      // If original filtered text had a decimal
      resultText += '.$decimalPart';
    }

    // 6. Adjust cursor position (basic adjustment).
    int cursorPosition =
        newValue.selection.end + (resultText.length - newText.length);
    cursorPosition = cursorPosition.clamp(0, resultText.length);

    return TextEditingValue(
      text: resultText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

class Costoflivingcalc extends StatefulWidget {
  const Costoflivingcalc({super.key});

  @override
  _CostoflivingcalcState createState() => _CostoflivingcalcState();
}

class _CostoflivingcalcState extends State<Costoflivingcalc> {
  DialogBox dialogBox = DialogBox();
  TextEditingController savings = TextEditingController();
  TextEditingController education = TextEditingController();
  TextEditingController mortgage = TextEditingController();
  TextEditingController mobility = TextEditingController();
  TextEditingController expenses = TextEditingController();
  TextEditingController utility = TextEditingController();
  TextEditingController debtRepay = TextEditingController();
  TextEditingController charity = TextEditingController();

  double total = 0;

  increment() {
    setState(() {
      double a = savings.text.isEmpty ? 0 : double.parse(savings.text);
      double b = education.text.isEmpty ? 0 : double.parse(education.text);
      double c = mortgage.text.isEmpty ? 0 : double.parse(mortgage.text);
      double d = mobility.text.isEmpty ? 0 : double.parse(mobility.text);
      double e = expenses.text.isEmpty ? 0 : double.parse(expenses.text);
      double f = utility.text.isEmpty ? 0 : double.parse(utility.text);
      double g = debtRepay.text.isEmpty ? 0 : double.parse(debtRepay.text);
      double h = charity.text.isEmpty ? 0 : double.parse(charity.text);

      total = a + b + c + d + e + f + g + h;
    });
  }

  @override
  void initState() {
    super.initState();
    savings.addListener(increment);
    education.addListener(increment);
    mortgage.addListener(increment);
    mobility.addListener(increment);
    expenses.addListener(increment);
    utility.addListener(increment);
    debtRepay.addListener(increment);
    charity.addListener(increment);
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

    String symbo = context.watch<Providers>().currencySymbol;
    var symboll = symbo.split(" ").toList();
    String symbol = symboll[0];
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: const Text(
          "Monthly Budget",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * .02,
            vertical: width * .01,
          ),
          child: Column(
            children: [
              Column(
                children: [
                  Text(
                    "To calculate your Financial Independence status, compute your Monthly Budget and provide figures for your savings and portfolio income.",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: height * .04,
                    child: Divider(
                      color: Theme.of(context).primaryColor,
                      height: 20,
                    ),
                  ),
                  Fiforms(
                    width: width,
                    name: "How much do you set aside for savings?",
                    height: height,
                    controller: savings,
                    symbol: symbol,
                  ),
                  Spaces(height: height),
                  Fiforms(
                    name:
                        'How much do you spend on your personal development (e.g. Seminars, training, courses, books, e.t.c)?',
                    width: width,
                    height: height,
                    controller: education,
                    symbol: symbol,
                  ),
                  Spaces(height: height),
                  Fiforms(
                    name: 'How much is your Rent or Mortgage?',
                    width: width,
                    height: height,
                    controller: mortgage,
                    symbol: symbol,
                  ),
                  Spaces(height: height),
                  Fiforms(
                    width: width,
                    name:
                        'What is your total Mobility Cost (including Car Insurance, MOT, Fuel, etc.)?',
                    height: height,
                    controller: mobility,
                    symbol: symbol,
                  ),
                  Spaces(height: height),
                  Fiforms(
                    width: width,
                    name:
                        'How much is your monthly Home Expenses (including Groceries, Clothes, Insurances, etc.)?',
                    height: height,
                    controller: expenses,
                    symbol: symbol,
                  ),
                  Spaces(height: height),
                  Fiforms(
                    name:
                        'How much is your monthly Utility Costs (including Council Tax, Energy, TV, Mobile, etc.)?',
                    width: width,
                    height: height,
                    controller: utility,
                    symbol: symbol,
                  ),
                  Spaces(height: height),
                  Fiforms(
                    name:
                        'How much is your monthly Debt Repayment Cost (including Credit Cards, Loan, Hire Purchase, etc.)?',
                    width: width,
                    height: height,
                    controller: debtRepay,
                    symbol: symbol,
                  ),
                  Spaces(height: height),
                  Fiforms(
                    width: width,
                    name:
                        'How much do you spend on giving to others including charity?',
                    height: height,
                    controller: charity,
                    symbol: symbol,
                  ),
                  SizedBox(height: height * .03),
                ],
              ),
              Card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Total Monthly Budget: ',
                            style: TextStyle(
                              fontSize: width * .04,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'This is the TARGET income for',
                            style: TextStyle(fontSize: width * .03),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            ' your Asset Portfolio Income',
                            style: TextStyle(fontSize: width * .03),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: width * .03),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(width * .01),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(width * .02),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$symbol${total.toStringAsFixed(2)}'
                                  .replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]},',
                                  ),
                              style: TextStyle(
                                color: const Color(0xfff3f3f4),
                                fontSize: width * .07,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * .03),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width * .02),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  if (savings.text.isEmpty ||
                      education.text.isEmpty ||
                      mortgage.text.isEmpty ||
                      mobility.text.isEmpty ||
                      expenses.text.isEmpty ||
                      utility.text.isEmpty ||
                      debtRepay.text.isEmpty ||
                      charity.text.isEmpty) {
                    FocusScope.of(context).requestFocus(FocusNode());

                    dialogBox.information(
                      context,
                      'Status',
                      'Fields cannot be empty. If you do not have a value for any field, kindly input "0"',
                    );
                    return;
                  }
                  if (total <= 0) {
                    FocusScope.of(context).requestFocus(FocusNode());

                    dialogBox.information(
                      context,
                      'Status',
                      'Total Monthly Expenditure cannot be 0',
                    );
                    return;
                  } else {
                    FocusScope.of(context).requestFocus(FocusNode());

                    try {
                      context.read<Providers>().setTotMonthly(total);
                      dialogBox.waiting(context, 'Saving');

                      Calculatormodel parameters = Calculatormodel(
                        currency: symbo,
                        periodic: savings.text,
                        education: education.text,
                        mortgage: mortgage.text,
                        mobility: mobility.text,
                        expenses: expenses.text,
                        utility: utility.text,
                        debtRepay: debtRepay.text,
                        charity: charity.text,
                      );
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Savingsincomecalc(parameters),
                        ),
                      );
                    } catch (e) {
                      dialogBox.information(
                        context,
                        'title',
                        'An error occured',
                      );
                    }
                  }
                },
                child: Container(
                  padding: EdgeInsets.zero,
                  height: height * .05,
                  width: width * .5,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        color: const Color(0xfff3f3f4),
                        fontWeight: FontWeight.w700,
                        fontSize: width * .05,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * .03),
            ],
          ),
        ),
      ),
    );
  }
}

class Spaces extends StatelessWidget {
  const Spaces({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height * .03);
  }
}

// Helper function to format the number for display
String formatDisplayNumber(String text) {
  final number = double.tryParse(text.replaceAll(',', ''));
  if (number == null) return text;
  return NumberFormat("#,##0.00", "en_US").format(number);
}

void formatInputToTwoDecimals(TextEditingController controller) {
  final number = double.tryParse(controller.text.replaceAll(',', ''));

  if (number == null) return;

  // Split into integer and decimal parts
  final fixed = number.toStringAsFixed(2);
  final parts = fixed.split('.');
  final integerPart = parts[0];
  final decimalPart = parts[1];

  // Re-apply thousand separators to the integer part
  String formattedInteger = '';
  final len = integerPart.length;
  for (int i = 0; i < len; i++) {
    formattedInteger += integerPart[i];
    if ((len - 1 - i) % 3 == 0 && (len - 1 - i) != 0) {
      formattedInteger += ',';
    }
  }

  final formattedText = '$formattedInteger.$decimalPart';

  controller.value = TextEditingValue(
    text: formattedText,
    selection: TextSelection.collapsed(offset: formattedText.length),
  );
}


class Fiforms extends StatefulWidget {
  const Fiforms({
    super.key,
    required this.width,
    required this.height,
    required this.name,
    this.subtitle,
    this.enabled,
    required this.controller,
    required this.symbol,
  });

  final double width;
  final bool? enabled;
  final String name;
  final String? subtitle;
  final double height;
  final TextEditingController controller;
  final String symbol;

  @override
  State<Fiforms> createState() => _FiformsState();
}

class _FiformsState extends State<Fiforms> {
  @override
  void initState() {
    super.initState();
    // Rebuild whenever controller text changes
    widget.controller.addListener(_onControllerChanged);
    // Format initial value on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      formatInputToTwoDecimals(widget.controller);
    });
  }

  void _onControllerChanged() {
    setState(() {}); // triggers rebuild so display text updates
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // replace all widget.xxx references below
    return Padding(
      padding: EdgeInsets.all(widget.width * .01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.name,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp),
          ),
          SizedBox(height: widget.height * .005),
          Text(
            '${widget.subtitle}',
            style: TextStyle(
              color: const Color(0xff888888),
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: widget.height * .01),
          widget.enabled!
              ? Container(
                  padding: EdgeInsets.all(widget.width * .0),
                  child: Row(
                    children: [
                      Text(
                        '${widget.symbol} ',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 32.sp,
                        ),
                      ),
                      Text(
                        widget.controller.text.isEmpty
                            ? 'N/A'
                            : formatDisplayNumber(widget.controller.text),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                          fontSize: 32.sp,
                        ),
                      ),
                      SizedBox(width: widget.width * .01),
                      Icon(Icons.lock, size: widget.width * .05),
                    ],
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        '${widget.symbol} ',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 32.sp,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Focus(
                        onFocusChange: (hasFocus) {
                          if (!hasFocus) {
                            formatInputToTwoDecimals(widget.controller);
                          }
                        },
                        child: TextField(
                          enabled: !widget.enabled!,
                          inputFormatters: [
                            SimpleThousandSeparatorAndDecimalFormatter(),
                          ],
                          keyboardType: TextInputType.number,
                          controller: widget.controller,
                          onTap: () {
                            if (widget.controller.text == "0.00") {
                              widget.controller.clear();
                            }
                          },
                          onEditingComplete: () {
                            formatInputToTwoDecimals(widget.controller);
                            FocusScope.of(context).unfocus();
                          },
                          onTapOutside: (_) {
                            FocusScope.of(context).unfocus();
                          },
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 32.sp,
                          ),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: const Color(0xffcacaca),
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}