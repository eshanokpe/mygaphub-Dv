import 'dart:convert';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
 
class Currency extends StatefulWidget {
  final VoidCallback nextPage;
  final Function(Map<String, dynamic>) onCurrencySelected;

  const Currency({
    super.key,
    required this.onCurrencySelected,
    required this.nextPage,
  });

  @override
  _CurrencyState createState() => _CurrencyState();
}

class _CurrencyState extends State<Currency> {
  DialogBox dialogBox = DialogBox();
  List<Map<String, dynamic>> _currencies = [];
  bool _buttonEnabled = false;
  String? dataCurrency;
  String? currencySymbol;
  Map calculatorData = {};
  // Removed unused variables: savings, education, etc.
  // int? savings,
  //     education,
  //     mortgage,
  //     mobility,
  //     expenses,
  //     utility,
  //     debtRepay,
  //     charity;

  @override
  void initState() {
    super.initState();
    // Avoid calling async methods directly in initState without handling the future
    // Use WidgetsBinding.instance.addPostFrameCallback or FutureBuilder if needed for UI updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadCurrencyData();
      calculatorData = context.read<Providers>().calculatorData;
      dataCurrency = calculatorData["currency"];
      // Call _selectCurrencyFromData after currencies are loaded
    });
  }

  Future<void> loadCurrencyData() async {
    try {
      final data = await rootBundle.loadString(
        'assets/currencywithsymbols.json',
      );
      final jsonData = jsonDecode(data) as List;
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          _currencies = jsonData
              .cast<Map<String, dynamic>>()
              .map((currency) => {...currency, 'isSelected': false})
              .toList();
        });
        // Now that currencies are loaded, try selecting the initial one
        _selectCurrencyFromData();
      }
    } catch (e) {
      print("Error loading currency data: $e");
      // Consider showing an error message to the user
    }
  }

  String? symbol;
  void _selectCurrencyFromData() {
    dataCurrency = context.read<Providers>().calculatorData["currency"];

    if (dataCurrency != null && _currencies.isNotEmpty) {
      for (int i = 0; i < _currencies.length; i++) {
        // Use try-catch for safety if split might fail
        try {
          var symbolParts = dataCurrency!.split(" ");
          if (symbolParts.isNotEmpty) {
            symbol = symbolParts[0];
            if (_currencies[i]['symbol'] == symbol) {
              // Call _toggleSelection within setState if it modifies state
              // Since _toggleSelection calls setState, it's okay here
              _toggleSelection(i);
              break; // Exit loop once found
            }
          }
        } catch (e) {
          print("Error parsing dataCurrency: $e");
        }
      }
    }
  }

  void _toggleSelection(int index) {
    // Check if the widget is still mounted before calling setState
    if (!mounted) return;
    setState(() {
      // More efficient way to update selection
      for (int i = 0; i < _currencies.length; i++) {
        _currencies[i]['isSelected'] = (i == index);
      }
      // Update button state directly after selection changes
      _buttonEnabled = true;
    });

    // Call the callback *after* setState completes
    widget.onCurrencySelected(_currencies[index]);
    // Call submitBudget here if you want it triggered on selection
    // submitBudget('${_currencies[index]['symbol']} ${_currencies[index]['code']}');
  }

  @override
  Widget build(BuildContext context) {
    // Update button state based on current _currencies state
    _buttonEnabled = _currencies.any(
      (currency) => currency['isSelected'] == true,
    );

    // Wrap the Column with SingleChildScrollView
    return SingleChildScrollView(
      child: Padding(
        // Add padding around the scrollable content if needed
        padding: EdgeInsets.only(bottom: 30.h), // Ensure space below button
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                16.w,
                16.h,
                16.w,
                0,
              ), // Add top padding
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Choose Your Preferred Currency',
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 20.sp,
                    color: AppColors.blackColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h), // Adjusted spacing
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Select your currency to begin calculating your financial independence status :)',
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp,
                    color: AppColors
                        .blackColor, // Consider a slightly less prominent color like gray
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final currency = _currencies[index];
                final bool isSelected = currency['isSelected'] ?? false;

                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 4.h,
                      ), // Adjust padding
                      onTap: () {
                        context.read<Providers>().setSymbol(
                          '${currency['symbol']} ${currency['code']}',
                        );
                        _toggleSelection(index);
                        submitBudget(
                          '${currency['symbol']} ${currency['code']}',
                        );
                      },
                      trailing: isSelected
                          ? Icon(
                              Icons.check,
                              color: AppColors.primaryColor,
                              size: 16.sp,
                            ) // Use check_circle for better visibility
                          : null,
                      leading: Container(
                        width: 30, // Slightly larger for better tap target
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFF03222F),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Text(
                            currency['symbol']?.toString() ?? '',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunitoSans(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        currency['name']?.toString() ?? 'Unknown Currency',
                        style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                    // Use Divider widget for standard separators
                    if (index != _currencies.length - 1)
                      Divider(
                        height: 1.h,
                        thickness: 1.h,
                        color: Colors.grey[200], // Lighter divider color
                        indent: 16.w,
                        endIndent: 16.w,
                      ),
                  ],
                );
              },
              itemCount: _currencies.length,
            ),
            SizedBox(height: 50.h),

            // Align the button to the right
            Align(
              alignment:
                  Alignment.centerRight, // This pushes the child to the right
              child: Padding(
                padding: EdgeInsets.only(
                  left: 240.w,
                  right: 16.w,
                ), // Keep your horizontal padding
                child: CustomButton(
                  text: 'Next',
                  fontSize: 16.sp,
                  borderSide: false,
                  icon: Icons.arrow_forward_ios,
                  iconColor: Colors.white,
                  borderColor: Colors.white,
                  onPressed: _buttonEnabled ? widget.nextPage : null,
                  color: _buttonEnabled
                      ? AppColors.primaryColor
                      : AppColors.grayColor,
                  textColor: Colors.white,
                ),
              ),
            ),

            // Removed the outer Container as SingleChildScrollView handles the layout
          ],
        ),
      ),
    );
  }

  void submitBudget(String currencySymbol) async {
    // Prevent submission if symbol is empty or null
    if (currencySymbol.trim().isEmpty) {
      print("Currency symbol is empty, skipping budget submission.");
      return;
    }

    var url = Uri.parse("$baseUrl/app/calculator/budget");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    // Ensure token exists
    if (token == null) {
      print("Error: Auth token not found.");
      // Handle missing token (e.g., navigate to login)
      return;
    }

    // Fetch latest calculator data right before submitting
    // This ensures you have the most recent values if they can change elsewhere
    final currentCalculatorData = context.read<Providers>().calculatorData;

    // Helper function to safely get and convert values to string
    String getStringValue(String key) {
      return (currentCalculatorData[key] ?? 0).toString();
    }

    Map<String, String> body = {
      // Use String keys and values for form encoding
      "currency": currencySymbol,
      "periodic_savings": getStringValue("periodic_savings"),
      "education": getStringValue("education"),
      "mortgage": getStringValue("mortgage"),
      "mobility": getStringValue("mobility"),
      "expenses": getStringValue("expenses"),
      "utility": getStringValue("utility"),
      "dept_repay": getStringValue("dept_repay"),
      "charity": getStringValue("charity"),
      // Ensure keys match API expectations ("extra", "extra1"?)
      "extra": getStringValue(
        "extra_save",
      ), // Assuming extra_save maps to extra
      "extra1": getStringValue(
        "other_income",
      ), // Assuming other_income maps to extra1
    };

    print("Submitting Budget - Currency: $currencySymbol");
    print("Submitting Budget - Body: $body");

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: body,
      ); // http.post handles encoding map bodies for this content type

      if (response.statusCode == 200) {
        final bodyCalculator = jsonDecode(response.body);
        final dataCalculator = bodyCalculator['data'];
        print('Budget Submission Success: $dataCalculator');
        // Update Provider state only if necessary and widget is still mounted
        if (mounted) {
          final provider = Provider.of<Providers>(context, listen: false);
          provider.setCalculator(dataCalculator);
        }
      } else {
        print('Budget Submission Error - Status Code: ${response.statusCode}');
        print('Budget Submission Error - Response: ${response.body}');
        // Optionally show an error message to the user
      }
    } catch (e) {
      print('Budget Submission Exception: $e');
      // Optionally show an error message to the user
    }
  }
}
