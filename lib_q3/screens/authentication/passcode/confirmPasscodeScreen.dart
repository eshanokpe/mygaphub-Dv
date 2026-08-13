import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/models/sevengeemodel.dart';
import 'package:GapHub/models/snapshotmodel.dart';
import 'package:GapHub/provider/AuthProvider.dart';
import 'package:GapHub/provider/acquisiProvider.dart';
import 'package:GapHub/provider/currencyProvider.dart';
import 'package:GapHub/screens/more/settings/settings.dart';
import 'package:GapHub/screens/others/dashboards/dashboard.dart';
import 'package:GapHub/screens/registration/calculation/multi_form.dart';
import 'package:GapHub/screens/registration/calculation/precalc.dart';
import 'package:GapHub/screens/registration/financial_health/prequestions.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/models/loginusermodel.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/helpWidget/help_widget.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../touchID/touchid.dart';

class ConfirmPasscodeScreen extends StatefulWidget {
  final String originalPin;
  final bool? settings;
  final bool? fromTouchID;

  const ConfirmPasscodeScreen({
    super.key,
    required this.originalPin,
    this.settings,
    this.fromTouchID,
  });

  @override
  _ConfirmPasscodeScreenState createState() => _ConfirmPasscodeScreenState();
}

class _ConfirmPasscodeScreenState extends State<ConfirmPasscodeScreen> {
  final TextEditingController passcode2 = TextEditingController();

  final dio = Dio();
  String _currentPin = "";
  bool _isProcessing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    passcode2.addListener(() {
      if (mounted) {
        setState(() {
          _currentPin = passcode2.text;
        });
      }
    });
  }

  @override
  void dispose() {
    passcode2.dispose();
    super.dispose();
  }

  void _handleNumberPressed(int number) {
    if (!mounted || _isProcessing) return;

    if (_currentPin.length < 6) {
      setState(() {
        _currentPin += number.toString();
        passcode2.text = _currentPin;
      });

      if (_currentPin.length == 6) {
        _onPinCompleted(_currentPin);
      }
    }
  }

  void _handleClearPressed() {
    if (!mounted || _isProcessing) return;

    setState(() {
      _currentPin = "";
      passcode2.text = _currentPin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [HelpWidget()],
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          height:
              MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              kToolbarHeight -
              MediaQuery.of(context).padding.bottom,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Re-type your ',
                      style: GoogleFonts.nunitoSans(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 22.sp,
                      ),
                    ),
                    TextSpan(
                      text: 'GAPhub',
                      style: GoogleFonts.nunitoSans(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 22.sp,
                      ),
                    ),
                    TextSpan(
                      text: ' passcode',
                      style: GoogleFonts.nunitoSans(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 22.sp,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10.h),

              // Subtitle
              Text(
                "Let's make sure it's correct",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grayColor,
                ),
              ),

              SizedBox(height: 80.h),

              // Pin Dots
              _buildPinDots(),

              SizedBox(height: 100.h),

              // Loading Indicator
              if (_isProcessing) ...[
                const SpinKitCircle(color: Colors.black, size: 40.0),
                // SizedBox(height: 20.h),
              ],

              // Number Pad
              _buildNumPad(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final bool isFilled = index < _currentPin.length;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutQuad,
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          width: isFilled ? 16.w : 12.w,
          height: isFilled ? 16.w : 12.w,
          decoration: BoxDecoration(
            color: isFilled ? Colors.black : Colors.grey[300],
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildNumPad() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNumberRow(['1', '2', '3']),
          SizedBox(height: 12.h),
          _buildNumberRow(['4', '5', '6']),
          SizedBox(height: 12.h),
          _buildNumberRow(['7', '8', '9']),
          SizedBox(height: 12.h),
          _buildNumberRow(['', '0', 'Clear'], isLastRow: true),
        ],
      ),
    );
  }

  Widget _buildNumberRow(List<String> values, {bool isLastRow = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: values.map((value) {
        if (value.isEmpty) {
          return SizedBox(width: 70.w, height: 70.h);
        }
        if (value == 'Clear') {
          return _buildClearButton();
        }
        return _buildNumberButton(int.parse(value));
      }).toList(),
    );
  }

  Widget _buildNumberButton(int number) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleNumberPressed(number),
        borderRadius: BorderRadius.circular(50.r),
        child: Container(
          width: 90.w,
          height: 90.h,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Center(
            child: Text(
              number.toString(),
              style: GoogleFonts.nunitoSans(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleClearPressed,
        borderRadius: BorderRadius.circular(35.r),
        child: Container(
          width: 70.w,
          height: 70.h,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Center(
            child: Text(
              'Clear',
              style: GoogleFonts.nunitoSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onPinCompleted(String enteredPin) async {
    if (enteredPin != widget.originalPin) {
      _showErrorBottomSheet('Passcodes do not match. Please try again.');
      _handleClearPressed();
      return;
    }

    if (!mounted) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await _setPasscodeAndPreference(enteredPin);
      if (mounted) {
        if (widget.fromTouchID == true) {
          enableTouchID();
          // Navigate directly to TouchID after passcode is set
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TouchID()),
          );
        } else {
          _showSuccessModal(context);
        }
      }
      if (mounted) _showSuccessModal(context);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ??
          e.response?.statusMessage ??
          'An error occurred while setting your passcode. Please try again.';
      if (mounted) _showErrorBottomSheet(message);
    } catch (e) {
      print('Error setting passcode: $e');
      if (mounted) {
        _showErrorBottomSheet(
          'An unexpected error occurred. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> enableTouchID() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');

    if (token != null && token != 'logout') {
      try {
        var url = Uri.parse('$baseUrl/app/settings/preferences');

        var response = await http.put(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: json.encode({'signin_preference': '1'}),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Touch ID enabled successfully')),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to enable Touch ID')),
          );
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _setPasscodeAndPreference(String pin) async {
    const String urlSettings = '$baseUrl/app/settings';
    const String urlPasscode = '$baseUrl/mygap/biometric/passcode';

    Map<String, dynamic> dataPasscode = {
      'passcode': pin,
      'security': 'agvabnvdnbsnvdbnvsjnbnffv',
    };

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('tokenDB');

    if (token == null) {
      throw Exception('User token not found.');
    }

    final responsePasscode = await dio.post(
      urlPasscode,
      data: dataPasscode,
      options: Options(
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
        },
      ),
    );

    if (responsePasscode.statusCode == 200 &&
        responsePasscode.data['success'] == true) {
      print('Passcode set response: ${responsePasscode.data}');

      final responsePreference = await dio.get(
        urlSettings,
        options: Options(
          headers: {
            "Authorization": 'Bearer $token',
            "Accept": "application/json",
          },
        ),
      );

      if (responsePreference.statusCode == 200 &&
          responsePreference.data['success'] == true) {
        final preferences = responsePreference.data['data']?['preferences'];
        if (preferences != null) {
          final signinPref = preferences['signin_preference'];
          if (signinPref != null) {
            print('Preference updated successfully: $signinPref');
            context.read<Providers>().setPref(signinPref);
          } else {
            _showErrorBottomSheet('Preference data incomplete.');
            return;
          }
        } else {
          _showErrorBottomSheet('Failed to retrieve preferences data.');
          return;
        }
      } else {
        _showErrorBottomSheet('Passcode set, but failed to update preference.');
        return;
      }
    } else {
      setState(() {
        _isProcessing = false;
      });
      String errorMessage = "Failed to set passcode.";
      if (responsePasscode.data != null &&
          responsePasscode.data['message'] != null) {
        errorMessage = responsePasscode.data['message'];
      } else if (responsePasscode.statusCode != 200) {
        errorMessage =
            "Failed to set passcode. Status: ${responsePasscode.statusCode}";
      }
      _showErrorBottomSheet(errorMessage);
      return;
    }
  }

  void _showErrorBottomSheet(String message) {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.only(top: 20.h),
          padding: EdgeInsets.symmetric(horizontal: 24.h, vertical: 20.w),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Error',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 15.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 14.sp,
                  color: AppColors.grayColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: Text(
                  "Go back",
                  style: GoogleFonts.nunitoSans(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessModal(BuildContext context) {
    if (!mounted) return;
    final parentContext = context;

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/thankYou.gif',
                  height: 100.h,
                  width: 100.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Congratulations! You have successfully created your sign-in passcode.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();

                      if (widget.settings == true) {
                        final String baseCurrency =
                            Provider.of<CurrencyProvider>(
                              parentContext,
                              listen: false,
                            ).baseCurrency;

                        Navigator.push(
                          parentContext,
                          MaterialPageRoute(
                            builder: (context) =>
                                Settings(baseCurrency: baseCurrency),
                          ),
                        );
                        return;
                      }

                      await loadEssentialData();

                      // signIn();
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        side: BorderSide(
                          color: AppColors.borderColor,
                          width: 0.5.w,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      'Close ',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> loadEssentialData() async {
    if (!mounted) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null || token == 'logout') {
        _showErrorBottomSheet('Session expired. Please login again.');
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.loadEssentialData(token, context);

      if (!mounted) return;

      if (result['success'] == true) {
        _navigateBasedOnResult(result);
      } else if (result['workflowIncomplete'] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Precalc()),
          (route) => false,
        );
      } else {
        _showErrorBottomSheet(
          result['error']?.toString() ?? 'Failed to load user data.',
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorBottomSheet(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _navigateBasedOnResult(Map<String, dynamic> result) {
    if (!mounted) return;

    switch (result['route']) {
      case 'dashboard':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard(index: 0)),
          (route) => false,
        );
        break;
      case 'prequestions':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Prequestions()),
          (route) => false,
        );
        break;
      case 'precalc':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Precalc()),
          (route) => false,
        );
        break;
      case 'multiStepForm':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MultiStepForm(
              initialPage: result['initialPage'] ?? 0,
              currentPageIndex: result['currentPageIndex'] ?? 0,
            ),
          ),
          (route) => false,
        );
        break;
      default:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard(index: 0)),
          (route) => false,
        );
    }
  }

  signIn() async {
    var urlDetails = Uri.parse("$baseUrl/user");
    var urlSnapshot = Uri.parse('$baseUrl/app/snapshot');
    var url7G = Uri.parse('$baseUrl/app/seveng');
    var urlEditDetails = Uri.parse("$baseUrl/app/profile");
    var urlr = "$baseUrl/app/360/tiles";
    var url = "$baseUrl/app/portfolio";
    var urld = "$baseUrl/app/dashboard";
    var urlEdit = Uri.parse('$baseUrl/app/seveng/edit');
    var urlSupport = Uri.parse("$baseUrl/app/support");
    final urlCalculator = Uri.parse("$baseUrl/app/calculator");

    dialogBox.waiting(context, 'Signing In');
    var timer = Timer(const Duration(milliseconds: 50000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });

    final prefs = await SharedPreferences.getInstance();
    var finalToken = prefs.getString('tokenDB');
    final response2 = await http.get(
      urlDetails,
      headers: {"Authorization": 'Bearer $finalToken'},
    );

    try {
      Loginusermodel loginusermodel = Loginusermodel.fromJson(
        jsonDecode(response2.body),
      );
      context.read<Providers>().setLoginDetails(loginusermodel);
      context.read<Providers>().setDetailsList(loginusermodel.firstname!, 0);
      context.read<Providers>().setDetailsList(loginusermodel.surname!, 1);
      context.read<Providers>().setDetailsList(loginusermodel.email!, 2);

      final responseDetails = await http.get(
        urlEditDetails,
        headers: {
          "Authorization": 'Bearer $finalToken',
          "Accept": "application/json",
        },
      );
      final Map<String, dynamic> responseBody = jsonDecode(
        responseDetails.body,
      );
      Editdetails editdetails = Editdetails.fromJson(responseBody);

      context.read<Providers>().setDetailsList(
        editdetails.user["firstname"],
        0,
      );
      context.read<Providers>().setDetailsList(
        editdetails.user["surname"].toString(),
        1,
      );
      context.read<Providers>().setDetailsList(
        editdetails.user["email"].toString(),
        2,
      );
      context.read<Providers>().setDetailsList(
        editdetails.user["profile"]["phone"].toString(),
        3,
      );
      context.read<Providers>().setDetailsList(
        editdetails.user["profile"]["date_of_birth"].toString(),
        4,
      );
      context.read<Providers>().setDetailsList(
        editdetails.user["profile"]["ancesry"].toString(),
        5,
      );
      context.read<Providers>().setDetailsList(
        editdetails.user["profile"]["country"].toString(),
        6,
      );
      String imgurl = editdetails.user["profile"]["image"].toString();
      if (imgurl.length >= 6) {
        imgurl = imgurl.replaceRange(0, 6, 'assets/storage');
        imgurl = '$imgPrefix/$imgurl';
      }

      context.read<Providers>().setDetailsList(imgurl, 7);
      context.read<Providers>().setDetailsList(
        editdetails.user["profile"]["dob_count"].toString(),
        8,
      );
      context.read<Providers>().setDetailsList(
        editdetails.user["created_at"].toString(),
        9,
      );

      final response3 = await http.get(
        urlSnapshot,
        headers: {"Authorization": 'Bearer $finalToken'},
      );

      var responseSupport = await http.get(
        urlSupport,
        headers: {"Authorization": 'Bearer $finalToken'},
      );
      final calculatorResponse = await http.get(
        urlCalculator,
        headers: {"Authorization": 'Bearer $finalToken'},
      );
      var bodySupport = jsonDecode(responseSupport.body);
      List dataSupport = bodySupport['data']['gap_supports']['data'];
      context.read<Providers>().setSupport(dataSupport);
      Snapshotmodel snapshotmodel = Snapshotmodel.fromJson(
        jsonDecode(response3.body),
      );
      context.read<Providers>().setSnapshot(snapshotmodel);
      context.read<Providers>().setCurrentPortfolio(
        snapshotmodel.financial["portfolio"],
      );

      final response4 = await http.get(
        url7G,
        headers: {"Authorization": 'Bearer $finalToken'},
      );
      Sevengeemodel sevengeemodel = Sevengeemodel.fromJson(
        jsonDecode(response4.body),
      );
      context.read<Providers>().setSevenGee(sevengeemodel);
      var response5 = await dio.get(
        url,
        options: Options(headers: {"Authorization": 'Bearer $finalToken'}),
      );
      if (response5.statusCode == 200) {
        context.read<Providers>().setPortfolio(response5.data);
      }
      var response6 = await dio.get(
        urlr,
        options: Options(headers: {"Authorization": 'Bearer $finalToken'}),
      );
      if (response6.statusCode == 200) {
        context.read<Providers>().setRecent(response6.data["tiles"]);
      }

      var responsEdit = await http.get(
        urlEdit,
        headers: {"Authorization": 'Bearer $finalToken'},
      );
      if (responsEdit.statusCode == 200) {
        var data = jsonDecode(responsEdit.body);
        //print("data:${data['data']}");
        Analyticsinfo analyticsinfo = Analyticsinfo.fromJson(data['data']);
        context.read<Providers>().setAnalyticsInfo(analyticsinfo);
      }

      num? tot = 0;
      for (var a in sevengeemodel.steps) {
        tot = (tot! + a);
      }
      bool col = sevengeemodel.backgrounds.every(
        (element) => element == '#494949',
      );
      if (response2.statusCode == 200 &&
          (tot != 0 || !col) &&
          snapshotmodel.currency != "" &&
          snapshotmodel.financial["cost"] != "0") {
        var responseD = await dio.get(
          urld,
          options: Options(headers: {"Authorization": 'Bearer $finalToken'}),
        );
        if (responseD.statusCode == 200) {
          context.read<Providers>().setDashData(responseD.data);
          context.read<Providers>().setCurrency(
            responseD.data["gap_currencies"]["user_currency"],
          );
          context.read<Providers>().setManualCurrency(
            responseD.data["gap_currencies"]["manual_currencies"],
          );
          context.read<Providers>().setSystemCurrency(
            responseD.data["gap_currencies"]["system_currencies"],
          );
          context.read<Providers>().setAssistance(responseD.data["assistance"]);
          Navigator.pop(context);
          timer.cancel();
        } else {
          Fluttertoast.showToast(
            backgroundColor: AppColors.primaryColor,
            textColor: Colors.white,
            msg: 'Gapproperties Hub is Down',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }

        //check if seveng assumption questions are filled
        if ([null, "", "0", 0].contains(sevengeemodel.questions.step1) ||
            [null, "", "0", 0].contains(sevengeemodel.questions.step2) ||
            [null, "", "0", 0].contains(sevengeemodel.questions.step3) ||
            [null, "", "0", 0].contains(sevengeemodel.questions.step4) ||
            [null, "", "0", 0].contains(sevengeemodel.questions.step5) ||
            [null, "", "0", 0].contains(sevengeemodel.questions.step6) ||
            [null, "", "0", 0].contains(sevengeemodel.questions.step7)) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Prequestions()),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard(index: 0)),
        );
      } else if (response2.statusCode == 200 &&
          tot == 0 &&
          snapshotmodel.currency == "" &&
          snapshotmodel.financial["cost"] == "0") {
        timer.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Precalc()),
        );
      } else if (response2.statusCode == 200 &&
          tot == 0 &&
          snapshotmodel.currency != "" &&
          snapshotmodel.financial["cost"] != "0") {
        final bodyCalculator = jsonDecode(calculatorResponse.body);
        final dataCalculator = bodyCalculator['data'];
        context.read<Providers>().setCalculator(dataCalculator);
        final calculatorData = Provider.of<Providers>(
          context,
          listen: false,
        ).calculatorData;
        String currency = calculatorData["currency"];
        final savingsValue =
            num.tryParse(calculatorData["periodic_savings"]) ?? 0;
        final educationValue = num.tryParse(calculatorData["education"]) ?? 0;
        final mortgageValue = num.tryParse(calculatorData["mortgage"]) ?? 0;
        final mobilityValue = num.tryParse(calculatorData["mobility"]) ?? 0;
        final expensesValue = num.tryParse(calculatorData["expenses"]) ?? 0;
        final utilityValue = num.tryParse(calculatorData["utility"]) ?? 0;
        final debtRepayValue = num.tryParse(calculatorData["dept_repay"]) ?? 0;
        final charityValue = num.tryParse(calculatorData["charity"]) ?? 0;
        final otherIncomeValue =
            num.tryParse(calculatorData["other_income"]) ?? 0;
        final extraSaveValue = num.tryParse(calculatorData["extra_save"]) ?? 0;
        if (currency.isNotEmpty) {
          if (extraSaveValue == 0 && otherIncomeValue == 0) {
            timer.cancel();
            return Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const MultiStepForm(initialPage: 1, currentPageIndex: 1),
              ),
            );
          }

          if (savingsValue == 0 &&
              educationValue == 0 &&
              mortgageValue == 0 &&
              mobilityValue == 0 &&
              expensesValue == 0 &&
              utilityValue == 0 &&
              debtRepayValue == 0 &&
              charityValue == 0) {
            timer.cancel();
            return Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const MultiStepForm(initialPage: 0, currentPageIndex: 0),
              ),
            );
          } else if (extraSaveValue > 0 || otherIncomeValue > 0) {
            timer.cancel();
            return Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const MultiStepForm(initialPage: 2, currentPageIndex: 2),
              ),
            );
          } else {
            timer.cancel();
            return Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const MultiStepForm(initialPage: 1, currentPageIndex: 1),
              ),
            );
          }
        } else {
          timer.cancel();
          navigateWithSlideTransition(
            context: context,
            destinationScreen: const Prequestions(),
            transitionDuration: const Duration(
              milliseconds: 200,
            ), // Optional: Adjust transition duration
          );
        }

        timer.cancel();

        final calculatorModel = context.read<AcquisiProvider>();
      }
    } on TimeoutException catch (_) {
      Navigator.pop(context);
      dialogBox.information(
        context,
        'Error',
        'Connection took too long to respond.',
      );
    } on SocketException catch (_) {
      Navigator.pop(context);
      dialogBox.information(
        context,
        'Error',
        'Connection took too long to respond.',
      );
    } catch (e) {
      // print(e);
      if (e is DioException) {
        if (e.type == DioExceptionType.unknown) {
          Navigator.pop(context);
          dialogBox.information(context, 'Error', 'Invalid format');
        } else if (e.type == DioExceptionType.cancel) {
          Navigator.pop(context);
          dialogBox.information(context, 'Error', 'Connection Canclled');
        } else if (e.type == DioExceptionType.receiveTimeout) {
          Navigator.pop(context);
          dialogBox.information(
            context,
            'Error',
            'Connection took too long to respond.',
          );
        } else if (e.type == DioExceptionType.badResponse) {
          switch (e.response!.statusCode) {
            case 400:
              Navigator.pop(context);
              dialogBox.information(context, 'Error', 'Incorrect Details');
              break;
            case 401:
              Navigator.pop(context);
              dialogBox.information(context, 'Error', 'You are Unauthorized');
              break;
            case 405:
              Navigator.pop(context);
              dialogBox.information(context, 'Error', 'Wrong method used.');
              break;
            case 404:
              Navigator.pop(context);
              dialogBox.information(context, 'Error', 'Url/Data not found');
              break;
            case 422:
              Navigator.pop(context);
              dialogBox.information(context, 'Error', '422: Critical error');
              break;
            case 500:
              Navigator.pop(context);
              dialogBox.information(context, 'Error', 'Server Error');
              break;
            default:
              Navigator.pop(context);
              dialogBox.information(context, 'Error', 'An error occured');
          }
        } else if (e.type == DioExceptionType.cancel) {
          Fluttertoast.showToast(msg: 'Connecton Canclled');
        }
      }
    }
  }
}
