import 'dart:async';
import 'dart:convert';
import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/models/loginusermodel.dart';
import 'package:GapHub/models/sevengeemodel.dart';
import 'package:GapHub/models/snapshotmodel.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/custom_appbar_logo.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:GapHub/widgets/question_text_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/utils/constants.dart';

import 'preparing_dashboard.dart';
import 'widget/radio_button.dart';

class Multichoice extends StatefulWidget {
  const Multichoice({super.key});

  @override
  _MultichoiceState createState() => _MultichoiceState();
}

class _MultichoiceState extends State<Multichoice> {
  DialogBox dialogBox = DialogBox();
  int? _selectedRadio1,
      _selectedRadio2,
      _selectedRadio3,
      _selectedRadio4,
      _selectedRadio5,
      _selectedRadio6,
      _selectedRadio7;

  Dio dio = Dio();

  // Add Dio configuration to handle 500 errors gracefully
  @override
  void initState() {
    super.initState();

    // Configure Dio to not throw exceptions for 500 errors
    dio.options.validateStatus = (status) {
      return status! < 500; // Only throw for status codes >= 500
    };

    // Or alternatively, handle all status codes and don't throw
    // dio.options.validateStatus = (status) => true;

    _selectedRadio1 = 0;
    _selectedRadio2 = 0;
    _selectedRadio3 = 0;
    _selectedRadio4 = 0;
    _selectedRadio5 = 0;
    _selectedRadio6 = 0;
    _selectedRadio7 = 0;
  }

  // Simplified radio handlers using a single method
  void setSelectedRadio(int questionNumber, int value) {
    setState(() {
      switch (questionNumber) {
        case 1:
          _selectedRadio1 = value;
          visible2 = true;
          break;
        case 2:
          _selectedRadio2 = value;
          visible3 = true;
          break;
        case 3:
          _selectedRadio3 = value;
          visible4 = true;
          break;
        case 4:
          _selectedRadio4 = value;
          visible5 = true;
          break;
        case 5:
          _selectedRadio5 = value;
          visible6 = true;
          break;
        case 6:
          _selectedRadio6 = value;
          visible7 = true;
          break;
        case 7:
          _selectedRadio7 = value;
          break;
      }
    });
  }

  // Keep individual methods for backward compatibility
  radio1(int val) => setSelectedRadio(1, val);
  radio2(int val) => setSelectedRadio(2, val);
  radio3(int val) => setSelectedRadio(3, val);
  radio4(int val) => setSelectedRadio(4, val);
  radio5(int val) => setSelectedRadio(5, val);
  radio6(int val) => setSelectedRadio(6, val);
  radio7(int val) => setSelectedRadio(7, val);

  int radioValue1 = 0;
  int radioValue2 = 0;
  int radioValue3 = 0;
  int radioValue4 = 0;
  int radioValue5 = 0;
  int radioValue6 = 0;
  int radioValue7 = 0;

  String radioName1 = '';
  String radioName2 = '';
  String radioName3 = '';
  String radioName4 = '';
  String radioName5 = '';
  String radioName6 = '';
  String radioName7 = '';

  void setValue() {
    // Simplified using a helper method
    radioValue1 = _getRadioValue(1, _selectedRadio1);
    radioValue2 = _getRadioValue(2, _selectedRadio2);
    radioValue3 = _getRadioValue(3, _selectedRadio3);
    radioValue4 = _getRadioValue(4, _selectedRadio4);
    radioValue5 = _getRadioValue(5, _selectedRadio5);
    radioValue6 = _getRadioValue(6, _selectedRadio6);
    radioValue7 = _getRadioValue(7, _selectedRadio7);

    radioName1 = _getRadioName(1, _selectedRadio1);
    radioName2 = _getRadioName(2, _selectedRadio2);
    radioName3 = _getRadioName(3, _selectedRadio3);
    radioName4 = _getRadioName(4, _selectedRadio4);
    radioName5 = _getRadioName(5, _selectedRadio5);
    radioName6 = _getRadioName(6, _selectedRadio6);
    radioName7 = _getRadioName(7, _selectedRadio7);
  }

  int _getRadioValue(int questionNumber, int? selectedValue) {
    switch (questionNumber) {
      case 1:
        return selectedValue == 1 ? 100 : 15;
      case 2:
        return selectedValue == 1
            ? 50
            : selectedValue == 2
            ? 15
            : 100;
      case 3:
        return selectedValue == 1 ? 100 : 25;
      case 4:
        return selectedValue == 1
            ? 100
            : selectedValue == 2
            ? 25
            : selectedValue == 3
            ? 50
            : 0;
      case 5:
        return selectedValue == 1
            ? 100
            : selectedValue == 2
            ? 25
            : selectedValue == 3
            ? 15
            : 100;
      case 6:
        return selectedValue == 1 ? 50 : 15;
      case 7:
        return selectedValue == 1 ? 100 : 25;
      default:
        return 0;
    }
  }

  String _getRadioName(int questionNumber, int? selectedValue) {
    switch (questionNumber) {
      case 1:
        return selectedValue == 1 ? 'Yes' : 'No';
      case 2:
        return selectedValue == 1
            ? 'Yes'
            : selectedValue == 2
            ? 'No'
            : 'Already Bought One';
      case 3:
        return selectedValue == 1 ? 'Yes' : 'No';
      case 4:
        return selectedValue == 1
            ? 'Yes'
            : selectedValue == 2
            ? 'No'
            : selectedValue == 3
            ? 'Actively Paying It Off'
            : 'Not Applicable';
      case 5:
        return selectedValue == 1
            ? 'Secured'
            : selectedValue == 2
            ? 'Saving'
            : selectedValue == 3
            ? 'Not Saving'
            : 'Not Applicable';
      case 6:
        return selectedValue == 1 ? 'Yes' : 'No';
      case 7:
        return selectedValue == 1 ? 'Yes' : 'No';
      default:
        return '';
    }
  }

  bool visible2 = false;
  bool visible3 = false;
  bool visible4 = false;
  bool visible5 = false;
  bool visible6 = false;
  bool visible7 = false;

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
      backgroundColor: Colors.white,
      appBar: CustomAppBarLogo(
        title: '',
        onBackPressed: () => Navigator.pop(context),
        actionIconPath: 'assets/logo.png',
        onActionPressed: () {},
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.03),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Financial Health Check 👨🏽‍⚕️',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: height * 0.01),
              Align(
                alignment: Alignment.topLeft,
                child: Column(
                  children: [
                    Text(
                      'Please answer these 7 multiple choice questions ;)',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w500,
                        fontSize: 18.sp,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: height * 0.04),
                  ],
                ),
              ),

              // Question 1
              _buildQuestion(
                questionNumber: 'Question 1:',
                questionText:
                    'Have you got rainy day funds to cover one year\'s worth of living expense?',
                selectedValue: _selectedRadio1,
                options: [
                  {'value': 1, 'text': 'Yes'},
                  {'value': 2, 'text': 'No'},
                ],
                onSelect: radio1,
              ),

              SizedBox(height: height * 0.02),
              _buildDivider(),

              // Question 2
              Visibility(
                visible: visible2,
                child: _buildQuestion(
                  questionNumber: 'Question 2:',
                  questionText:
                      'Are you saving up for your own house or have you already bought one?',
                  selectedValue: _selectedRadio2,
                  options: [
                    {'value': 1, 'text': 'Yes'},
                    {'value': 2, 'text': 'No'},
                    {'value': 3, 'text': 'Already Bought One'},
                  ],
                  onSelect: radio2,
                ),
              ),

              Visibility(visible: visible2, child: _buildDivider()),

              // Question 3
              Visibility(
                visible: visible3,
                child: _buildQuestion(
                  questionNumber: 'Question 3:',
                  questionText:
                      'Are you free from all unsecured debts - credit cards, loans and hire purchases?',
                  selectedValue: _selectedRadio3,
                  options: [
                    {'value': 1, 'text': 'Yes'},
                    {'value': 2, 'text': 'No'},
                  ],
                  onSelect: radio3,
                ),
              ),

              Visibility(visible: visible3, child: _buildDivider()),

              // Question 4
              Visibility(
                visible: visible4,
                child: _buildQuestion(
                  questionNumber: 'Question 4:',
                  questionText: 'Are you mortgage free?',
                  selectedValue: _selectedRadio4,
                  options: [
                    {'value': 1, 'text': 'Yes'},
                    {'value': 2, 'text': 'No'},
                    {'value': 3, 'text': 'Actively Paying It Off'},
                    {'value': 4, 'text': 'Not Applicable'},
                  ],
                  onSelect: radio4,
                ),
              ),

              Visibility(visible: visible4, child: _buildDivider()),

              // Question 5
              Visibility(
                visible: visible5,
                child: _buildQuestion(
                  questionNumber: 'Question 5:',
                  questionText:
                      'Are you currently saving or have you already secured funds for your children\'s university education? If this doesn\'t apply to you, please select "Not applicable"',
                  selectedValue: _selectedRadio5,
                  options: [
                    {'value': 1, 'text': 'Secured'},
                    {'value': 2, 'text': 'Saving'},
                    {'value': 3, 'text': 'Not Saving'},
                    {'value': 4, 'text': 'Not Applicable'},
                  ],
                  onSelect: radio5,
                ),
              ),

              Visibility(visible: visible5, child: _buildDivider()),

              // Question 6
              Visibility(
                visible: visible6,
                child: _buildQuestion(
                  questionNumber: 'Question 6:',
                  questionText:
                      'Have you got an income generating asset portfolio that brings an income equal to or more than your cost of living?',
                  selectedValue: _selectedRadio6,
                  options: [
                    {'value': 1, 'text': 'Yes'},
                    {'value': 2, 'text': 'No'},
                  ],
                  onSelect: radio6,
                ),
              ),

              Visibility(visible: visible6, child: _buildDivider()),

              // Question 7
              Visibility(
                visible: visible7,
                child: _buildQuestion(
                  questionNumber: 'Question 7:',
                  questionText:
                      'Like Warren Buffet and Bill Gates, have you successfully given away to charity or a cause you believe in an amount equal to or more than your cost of living in any particular year?',
                  selectedValue: _selectedRadio7,
                  options: [
                    {'value': 1, 'text': 'Yes'},
                    {'value': 2, 'text': 'No'},
                  ],
                  onSelect: radio7,
                ),
              ),

              SizedBox(height: height * 0.04),

              // Submit Button
              Visibility(
                visible: visible7,
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: CustomButton(
                      text: 'Submit',
                      fontSize: 16.sp,
                      borderRadius: 30,
                      icon: Icons.arrow_forward_ios,
                      iconColor: Colors.white,
                      borderColor: Colors.white,
                      onPressed: _submitForm,
                      color: AppColors.primaryColor,
                      textColor: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion({
    required String questionNumber,
    required String questionText,
    required int? selectedValue,
    required List<Map<String, dynamic>> options,
    required Function(int) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionTextWidget(
          questionNumber: questionNumber,
          questionText: questionText,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Column(
          children: options.map((option) {
            return Column(
              children: [
                BuildRadioButton(
                  value: option['value'],
                  text: option['text'],
                  isSelected: selectedValue ?? 0,
                  onSelect: onSelect,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Color.fromARGB(255, 244, 244, 244),
      thickness: 1.5,
    );
  }

  Future<void> _submitForm() async {
    // Show loading dialog first
    dialogBox.waiting(context, 'Loading');

    try {
      setValue();

      print("radioName1: $radioName1");
      print("radioName2: $radioName2");
      print("radioName3: $radioName3");
      print("radioName4: $radioName4");
      print("radioName5: $radioName5");
      print("radioName6: $radioName6");
      print("radioName7: $radioName7");

      Map<String, dynamic> body = {
        "step1": radioName1,
        "step2": radioName2,
        "step3": radioName3,
        "step4": radioName4,
        "step5": radioName5,
        "step6": radioName6,
        "step7": radioName7,
      };

      var url = Uri.parse("$baseUrl/app/stepquestions");
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      if (token == null) {
        Navigator.pop(context); // Close loading dialog
        dialogBox.information(
          context,
          'Error',
          'Authentication token not found',
        );
        return;
      }
 
      final response = await http
          .post(
            url,
            body: body,
            headers: {
              "Authorization": 'Bearer $token',
              "Accept": "application/json",
              "Content-Type": "application/x-www-form-urlencoded",
            },
            encoding: Encoding.getByName("utf-8"),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        print('Success Stepquestions');
        await _fetchSnapshot(token);

        Navigator.pop(context); // Close loading dialog after successful fetch
        navigateWithSlideTransition(
          context: context,
          destinationScreen: const PreparingDasbaordUI(),
          transitionDuration: const Duration(milliseconds: 200),
        );
      } else if (response.statusCode == 500) {
        Navigator.pop(context); // Close loading dialog
        dialogBox.information(
          context,
          'Server Error',
          'The server is currently experiencing issues. Please try again later.',
        );
      } else {
        print('Error Stepquestions: ${response.statusCode}');
        Navigator.pop(context); // Close loading dialog
        dialogBox.information(
          context,
          'Error',
          'Network or Server Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error: $e');
      Navigator.pop(context); // Close loading dialog

      // Handle http package exceptions correctly
      if (e is http.ClientException) {
        dialogBox.information(
          context,
          'Network Error',
          'Please check your internet connection and try again.',
        );
      } else if (e is TimeoutException) {
        dialogBox.information(
          context,
          'Timeout Error',
          'Request took too long. Please try again.',
        );
      } else {
        dialogBox.information(
          context,
          'Error',
          'An unexpected error occurred: $e',
        );
      }
    }
  }

  Future<Snapshotmodel> _fetchSnapshot(String token) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/app/snapshot'),
          headers: {"Authorization": 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print("Snapshotmodel:$jsonData");

      // Pass the FULL response, let the model handle extraction
      final snapshot = Snapshotmodel.fromJson(jsonData);

      final providers = context.read<Providers>();
      providers.setSnapshot(snapshot); // Pass the object, not raw JSON

      return snapshot;
    } else {
      throw Exception('Failed to load snapshot: ${response.statusCode}');
    }
  }
}
