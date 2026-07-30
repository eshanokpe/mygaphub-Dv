import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:intl/intl.dart'; // For number parsing
import 'package:GapHub/screens/360/accounts/mortgage/mortgagedetails.dart';

class Mortgage extends StatefulWidget {
  final bool primaryRes;
  final Map<String, dynamic> mortgageInfo;

  const Mortgage({
    super.key,
    required this.primaryRes,
    required this.mortgageInfo,
  });
  @override
  _MortgageState createState() => _MortgageState();
}

class _MortgageState extends State<Mortgage> {
  var key = GlobalKey<FormState>();
  TextEditingController creditor = TextEditingController();
  TextEditingController details = TextEditingController();
  TextEditingController current = TextEditingController();
  TextEditingController monthly = TextEditingController();
  TextEditingController interest = TextEditingController();
  TextEditingController opening = TextEditingController();
  TextEditingController repayment = TextEditingController();
  Dio dio = Dio();
  bool show = false;
  DateTime? datealert;
  var dateDB = "";
  DialogBox dialogBox = DialogBox();
  bool _isLoadingDialogPopped = false; // Flag to manage loading dialog state
  bool primaryRes = false;

  // _MortgageState({ this.primaryRes});

  static const descList = <String>[
    '-Select-',
    'First Charge Mortgage',
    'Second Charge Mortgage',
    'Secured Loan',
  ];
  String description = '-Select-';
  final List<DropdownMenuItem<String>> _mortDesc = descList
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
      )
      .toList();

  List<String> assetAgainstList = <String>[];
  String against = '-Select-';
  late List<DropdownMenuItem<String>> _assetAgainst;

  String currency = '-Select-';

  final List<DropdownMenuItem<String>> _currency = currencyList
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
      )
      .toList();

  @override
  void initState() {
    super.initState();
    primaryRes = widget.primaryRes;
    setState(() => primaryRes = context.read<Providers>().primaryRes);
    setState(
      () => assetAgainstList = primaryRes
          ? <String>[
              '-Select-',
              'Secondary Residence',
              'Holiday Home',
              'Investment Property',
              'Vacant Land',
              'Others',
            ]
          : <String>[
              '-Select-',
              'Primary Residential Home',
              'Secondary Residence',
              'Holiday Home',
              'Investment Property',
              'Vacant Land',
              'Others',
            ],
    );

    _assetAgainst =
        assetAgainstList
            .map(
              (String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ),
            )
            .toList() ??
        [];
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

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Add Account: Mortgage",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: width * .040,
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(4),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[200],
          padding: EdgeInsets.symmetric(vertical: height * .02),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .04),
                child: Form(
                  key: key,
                  child: Column(
                    children: [
                      Text(
                        "(Complete the form below for your credit reduction target)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: width * .035,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: width * .045,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              const TextSpan(text: 'Who is the creditor:'),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  fontSize: width * .045,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      TextFormField(
                        controller: creditor,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.name,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: 'E.g. Barclaycard',
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: TextStyle(fontSize: width * .03),
                          contentPadding: EdgeInsets.all(width * .03),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: width * .045,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              const TextSpan(text: 'Description of Mortgage:'),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  fontSize: width * .045,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      Container(
                        padding: EdgeInsets.only(
                          left: width * .015,
                          right: width * .015,
                        ),
                        width: width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(width * .01),
                          color: Colors.white,
                          border: Border.all(),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            focusColor: Theme.of(context).primaryColor,
                            value: description,
                            items: _mortDesc,
                            dropdownColor: Colors.white,
                            onChanged: (subval) {
                              setState(() {
                                description = subval!;
                              });
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: width * .043,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    'What asset is this mortgage secured against:',
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  fontSize: width * .045,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      Container(
                        padding: EdgeInsets.only(
                          left: width * .015,
                          right: width * .015,
                        ),
                        width: width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(width * .01),
                          color: Colors.white,
                          border: Border.all(),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            focusColor: Theme.of(context).primaryColor,
                            value: against,
                            items: _assetAgainst,
                            dropdownColor: Colors.white,
                            onChanged: (subval) {
                              setState(() {
                                if (subval == "Primary Residential Home") {
                                  against = subval!;
                                  //details.text =widget.mortgageInfo["residential"]["location"];
                                } else {
                                  details.clear();
                                }
                                against = subval!;
                              });
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Address of property linked to this mortgage: ',
                          style: TextStyle(
                            fontSize: width * .045,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      TextFormField(
                        controller: details,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'E.g. My residential property at 123 Downing Street',
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: TextStyle(fontSize: width * .03),
                          contentPadding: EdgeInsets.all(width * .03),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      // SizedBox(
                      //   height: height * .03,
                      // ),
                      // Align(
                      //     alignment: Alignment.centerLeft,
                      //     child: RichText(
                      //       text: TextSpan(
                      //           style: TextStyle(
                      //               fontSize: width * .045,
                      //               color: Colors.black,
                      //               fontWeight: FontWeight.w700),
                      //           children: [
                      //             TextSpan(
                      //                 text:
                      //                     'Which currency is the money borrowed:'),
                      //             TextSpan(
                      //                 text: " *",
                      //                 style: TextStyle(
                      //                     fontSize: width * .045,
                      //                     color: Theme.of(context).primaryColor,
                      //                     fontWeight: FontWeight.w700))
                      //           ]),
                      //     )),
                      // SizedBox(
                      //   height: height * .005,
                      // ),
                      // Container(
                      //   padding: EdgeInsets.only(
                      //       top: width * .015,
                      //       bottom: width * .015,
                      //       left: width * .015,
                      //       right: width * .015),
                      //   width: width,
                      //   decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(width * .01),
                      //       color: Colors.grey[100],
                      //       border: Border.all()),
                      //   child: DropdownButtonHideUnderline(
                      //     child: DropdownButton(
                      //         focusColor: Theme.of(context).primaryColor,
                      //         value: currency,
                      //         items: _currency,
                      //         onChanged: (subval) {
                      //           setState(() {
                      //             currency = subval;
                      //           });
                      //           FocusScope.of(context)
                      //               .requestFocus(FocusNode());
                      //         }),
                      //   ),
                      // ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: width * .043,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              const TextSpan(
                                text: 'What was the mortgage opening balance:',
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  fontSize: width * .045,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      TextFormField(
                        controller: opening,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          }
                          return null;
                        },
                        inputFormatters: [amountValidator],
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(fontSize: width * .03),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(width * .03),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: width * .045,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              const TextSpan(
                                text: 'What is the current mortgage balance:',
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  fontSize: width * .045,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          }
                          return null;
                        },
                        controller: current,
                        inputFormatters: [amountValidator],
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintStyle: TextStyle(fontSize: width * .03),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(width * .03),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: width * .045,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              const TextSpan(
                                text: 'What is the monthly payment amount:',
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  fontSize: width * .045,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          }
                          return null;
                        },
                        controller: monthly,
                        inputFormatters: [amountValidator],
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintStyle: TextStyle(fontSize: width * .03),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(width * .03),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'What is the interest rate on this mortgage:',
                          style: TextStyle(
                            fontSize: width * .045,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      TextFormField(
                        controller: interest,
                        inputFormatters: [amountValidator],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        // keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(fontSize: width * .03),
                          suffixText: '%',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(width * .03),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some value';
                          }
                          final double? interestValue = double.tryParse(value);
                          if (interestValue == null || interestValue > 100) {
                            return 'Interest Rate value must be less than or equal to 100';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'What is your accelerated mortgage repayment plan:',
                          style: TextStyle(
                            fontSize: width * .045,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: repayment,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(fontSize: width * .03),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(width * .03),
                          border: const OutlineInputBorder(),
                        ),
                      ),

                      SizedBox(height: height * .05),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(width * .01),
                          ),
                        ),
                        onPressed: () {
                          if (key.currentState!.validate()) {
                            saveCash();
                          }
                        },
                        child: Text(
                          "Submit",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: width * .045,
                          ),
                        ),
                      ),
                      SizedBox(height: height * .01),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: width * .035,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              TextSpan(
                                text: "* ",
                                style: TextStyle(
                                  fontSize: width * .035,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const TextSpan(text: 'Fields are mandatory'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * .05),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to parse formatted currency string (e.g., "1,234.56") to a clean string "1234.56"
  String _cleanFormattedNumber(String? text) {
    if (text == null || text.isEmpty) {
      return "";
    }
    return text.replaceAll(',', '');
  }

  // Helper to safely pop the loading dialog
  void _safePopLoadingDialog() {
    if (mounted && !_isLoadingDialogPopped) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pop(); // Pop the "Saving" dialog
      _isLoadingDialogPopped = true;
    }
  }

  // Helper to show an information dialog safely
  void _showInfoDialog(String title, String message) {
    if (mounted) {
      dialogBox.information(context, title, message);
    }
  }

  saveCash22() async {
    FocusScope.of(context).unfocus(); // Dismiss keyboard

    if (description == "-Select-" || against == "-Select-") {
      _showInfoDialog(
        'Status',
        "Please select an option for all mandatory fields",
      );
      return;
    }

    // Validate form fields
    if (!key.currentState!.validate()) {
      _showInfoDialog(
        'Validation Error',
        "Please correct the errors in the form.",
      );
      return;
    }

    dialogBox.waiting(context, "Saving");
    _isLoadingDialogPopped = false; // Reset flag

    Timer? timer;
    timer = Timer(const Duration(seconds: 50), () {
      if (mounted && !_isLoadingDialogPopped) {
        _safePopLoadingDialog(); // Pop the "Saving" dialog
        _showInfoDialog('Status', 'Service timed out');
      }
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null) {
        _safePopLoadingDialog();
        timer.cancel();
        _showInfoDialog(
          'Authentication Error',
          'Session expired. Please log in again.',
        );
        return;
      }

      Map<String, dynamic> data = {
        "creditor_name": creditor.text,
        "description": description,
        "detail": details.text,
        "secure_against": against,
        "open_balance": _cleanFormattedNumber(opening.text),
        "current": _cleanFormattedNumber(current.text),
        "current_balance": _cleanFormattedNumber(current.text),
        "interest": _cleanFormattedNumber(interest.text),
        "month_pay": _cleanFormattedNumber(monthly.text),
        "repayment": repayment.text,
        "analytics": show.toString(),
      };
      if (dateDB.isNotEmpty) {
        data["target_date"] = dateDB;
      }

      const saveUrl = "$baseUrl/app/360/mortgage";
      Response saveResponse = await dio.post(
        saveUrl,
        data: data,
        options: Options(headers: {"Authorization": 'Bearer $token'}),
      );

      if (saveResponse.statusCode == 200) {
        // Successfully saved, now fetch updated data
        const fetchMortgagesUrl =
            "$baseUrl/app/360/mortgage"; // Same URL for GET
        Response fetchMortgagesResponse = await dio.get(
          fetchMortgagesUrl,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );

        if (fetchMortgagesResponse.statusCode != 200) {
          _safePopLoadingDialog();
          timer.cancel();
          _showInfoDialog(
            'Fetch Error',
            'Failed to retrieve updated mortgage data: ${fetchMortgagesResponse.statusMessage}',
          );
          return;
        }

        final mortgagesData = fetchMortgagesResponse.data;
        final mapList = mortgagesData["mortgages"];
        final mapListLite = mortgagesData["mortgages_detail"];
        final seveng = mortgagesData["seveng"];

        const fetchTilesUrl = "$baseUrl/app/360/tiles";
        Response fetchTilesResponse = await dio.get(
          fetchTilesUrl,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );

        if (mounted && fetchTilesResponse.statusCode == 200) {
          context.read<Providers>().setRecent(fetchTilesResponse.data["tiles"]);
        } else if (fetchTilesResponse.statusCode != 200) {
          // print(
          //     "Warning: Failed to fetch tiles - ${fetchTilesResponse.statusMessage}");
        }

        _safePopLoadingDialog(); // Pop "Saving" dialog
        timer.cancel();

        if (mounted) {
          Navigator.pop(context); // Pop current Mortgage page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  Mortgagedetails(mapList, mapListLite, seveng),
            ),
          );
          Fluttertoast.showToast(msg: 'Account saved successfully');
        }
      } else {
        // Handle non-200 responses from the save operation
        _safePopLoadingDialog();
        timer.cancel();
        String errorMessage = "Failed to save: ${saveResponse.statusCode}";
        if (saveResponse.data != null &&
            saveResponse.data is Map &&
            saveResponse.data['message'] != null) {
          errorMessage += " - ${saveResponse.data['message']}";
        } else if (saveResponse.data != null) {
          errorMessage += " - ${saveResponse.data.toString()}";
        }
        _showInfoDialog('Save Error', errorMessage);
      }
    } on DioException catch (e) {
      _safePopLoadingDialog();
      timer.cancel();
      String dioErrorMessage = "An error occurred: ${e.message}";
      if (e.response != null && e.response?.data != null) {
        dioErrorMessage =
            "Error: ${e.response?.statusCode} - ${e.response?.data['message'] ?? e.response?.data.toString()}";
      }
      _showInfoDialog('Network Error', dioErrorMessage);
    } catch (e) {
      _safePopLoadingDialog();
      timer.cancel();
      _showInfoDialog('Error', 'An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<void> saveCash() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Validate required selections
    if (!_validateRequiredSelections()) {
      return;
    }

    // Validate form fields
    if (!_validateFormFields()) {
      return;
    }

    // Show loading dialog and set up timeout
    await _showLoadingDialog();

    // Set up timeout timer
    final timer = _setupTimeoutTimer();

    try {
      final token = await _getAuthToken();
      if (token == null) {
        await _handleAuthenticationError(timer);
        return;
      }

      // Prepare request data
      final requestData = _buildRequestData();

      // Save mortgage data
      final saveSuccess = await _saveMortgageData(requestData, token, timer);

      if (saveSuccess && mounted) {
        await _handleSuccessfulSave(token, timer);
      }
    } on DioException catch (e) {
      await _handleDioError(e, timer);
    } catch (e) {
      await _handleUnexpectedError(e, timer);
    }
  }

  // MARK: - Private Helper Methods

  bool _validateRequiredSelections() {
    if (description == "-Select-" || against == "-Select-") {
      _showInfoDialog(
        'Status',
        'Please select an option for all mandatory fields',
      );
      return false;
    }
    return true;
  }

  bool _validateFormFields() {
    if (!key.currentState!.validate()) {
      _showInfoDialog(
        'Validation Error',
        'Please correct the errors in the form.',
      );
      return false;
    }
    return true;
  }

  Future<void> _showLoadingDialog() async {
    dialogBox.waiting(context, 'Saving');
    _isLoadingDialogPopped = false;
  }

  Timer _setupTimeoutTimer() {
    return Timer(const Duration(seconds: 50), () async {
      if (mounted && !_isLoadingDialogPopped) {
        _safePopLoadingDialog();
        if (mounted) {
          _showInfoDialog('Status', 'Service timed out');
        }
      }
    });
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tokenDB');
  }

  Map<String, dynamic> _buildRequestData() {
    final data = {
      'creditor': creditor.text,
      'description': description,
      'detail': details.text,
      'secure_against': against,
      'open_bal': _cleanFormattedNumber(opening.text),
      'current': _cleanFormattedNumber(current.text),
      'current_bal': _cleanFormattedNumber(current.text),
      'interest': _cleanFormattedNumber(interest.text),
      'month_pay': _cleanFormattedNumber(monthly.text),
      'repayment': repayment.text,
      'analytics': show.toString(),
      'seveng': 'pakmamkanknmjkmnzkmnjmnd',
    };

    if (dateDB.isNotEmpty) {
      data['target_date'] = dateDB;
    }

    return data;
  }

  Future<bool> _saveMortgageData(
    Map<String, dynamic> data,
    String token,
    Timer timer,
  ) async {
    const saveUrl = '$baseUrl/app/360/mortgage';

    try {
      final saveResponse = await dio.post(
        saveUrl,
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return saveResponse.statusCode == 200;
    } catch (e) {
      await _cleanupAfterError(timer);
      rethrow;
    }
  }

  Future<void> _handleSuccessfulSave(String token, Timer timer) async {
    try {
      // Fetch updated mortgage data
      final mortgagesData = await _fetchMortgagesData(token);

      if (mortgagesData == null) {
        await _cleanupAfterError(timer);
        return;
      }

      // Fetch tiles data (non-critical)
      await _fetchAndUpdateTiles(token);

      // Clean up and navigate
      await _cleanupAfterSuccess(timer);

      if (mounted) {
        _navigateToMortgageDetails(mortgagesData);
        Fluttertoast.showToast(msg: 'Account saved successfully');
      }
    } catch (e) {
      await _cleanupAfterError(timer);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _fetchMortgagesData(String token) async {
    const fetchUrl = '$baseUrl/app/360/mortgage';

    try {
      final response = await dio.get(
        fetchUrl,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200) {
        _safePopLoadingDialog();
        _showInfoDialog(
          'Fetch Error',
          'Failed to retrieve updated mortgage data: ${response.statusMessage}',
        );
        return null;
      }

      return response.data;
    } catch (e) {
      _safePopLoadingDialog();
      _showInfoDialog(
        'Fetch Error',
        'Failed to retrieve updated mortgage data',
      );
      return null;
    }
  }

  Future<void> _fetchAndUpdateTiles(String token) async {
    try {
      const tilesUrl = '$baseUrl/app/360/tiles';
      final response = await dio.get(
        tilesUrl,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (mounted && response.statusCode == 200) {
        context.read<Providers>().setRecent(response.data['tiles']);
      } else if (response.statusCode != 200) {
        // debugPrint('Warning: Failed to fetch tiles - ${response.statusMessage}');
      }
    } catch (e) {
      // debugPrint('Warning: Failed to fetch tiles - $e');
    }
  }

  void _navigateToMortgageDetails(Map<String, dynamic> mortgagesData) {
    final mapList = mortgagesData['mortgages'];
    final mapListLite = mortgagesData['mortgages_detail'];
    final seveng = mortgagesData['seveng'];

    Navigator.pop(context); // Pop current Mortgage page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Mortgagedetails(mapList, mapListLite, seveng),
      ),
    );
  }

  Future<void> _handleAuthenticationError(Timer timer) async {
    await _cleanupAfterError(timer);
    if (mounted) {
      _showInfoDialog(
        'Authentication Error',
        'Session expired. Please log in again.',
      );
    }
  }

  Future<void> _handleDioError(DioException e, Timer timer) async {
    await _cleanupAfterError(timer);

    String errorMessage = _buildDioErrorMessage(e);

    if (mounted) {
      _showInfoDialog('Network Error', errorMessage);
    }
  }

  String _buildDioErrorMessage(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response?.data;
      final message = data is Map
          ? data['message'] ?? data.toString()
          : data.toString();
      return 'Error: ${e.response?.statusCode} - $message';
    }
    return 'An error occurred: ${e.message}';
  }

  Future<void> _handleUnexpectedError(Object e, Timer timer) async {
    await _cleanupAfterError(timer);

    if (mounted) {
      _showInfoDialog('Error', 'An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<void> _cleanupAfterError(Timer timer) async {
    timer.cancel();
    _safePopLoadingDialog();
  }

  Future<void> _cleanupAfterSuccess(Timer timer) async {
    timer.cancel();
    _safePopLoadingDialog();
  }
}
