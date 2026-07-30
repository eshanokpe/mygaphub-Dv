import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:GapHub/models/loginusermodel.dart';
import 'package:GapHub/models/sevengeemodel.dart';
import 'package:GapHub/models/snapshotmodel.dart';
import 'package:GapHub/provider/AuthProvider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/authentication/passcode/setpasscode.dart';
import 'package:GapHub/screens/authentication/touchID/touchid.dart';
import 'package:GapHub/screens/others/dashboards/dashboard.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../registration/calculation/multi_form.dart';
import '../registration/calculation/precalc.dart';
import '../registration/financial_health/prequestions.dart';
import 'login/forgot_password/forgotpword.dart';
import 'login/login.dart';

class Landing extends StatefulWidget {
  final bool? passcode;
  final bool? touch;
  final bool? reset;
  final bool? fromID;

  const Landing({
    super.key,
    this.passcode,
    this.touch,
    this.reset,
    this.fromID,
  });

  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  final TextEditingController _passwordController = TextEditingController();
  final DialogBox _dialogBox = DialogBox();
  final Dio _dio = Dio();

  bool _isPasswordVisible = false;
  bool _isFieldFilled = false;
  Timer? _timeoutTimer;
  final bool _isLoading = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updateFieldState);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _updateFieldState() {
    if (mounted) {
      setState(() {
        _isFieldFilled = _passwordController.text.isNotEmpty;
      });
    }
  }

  void _togglePasswordVisibility() {
    if (mounted) {
      setState(() {
        _isPasswordVisible = !_isPasswordVisible;
      });
    }
  }

  bool get _shouldShowBackButton {
    return widget.reset == true ? false : true;
  }

  String get _buttonText {
    if (widget.passcode == true) return "Authenticate to Set Pass Code";
    if (widget.touch == true) return "Authenticate to Use Touch ID";
    if (widget.reset == true) return "Reset Pass Code";
    return "Sign In";
  }

  bool iii() {
    if (widget.reset!) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    final providers = context.watch<Providers>();
    final email = providers.details[2];
    final firstName = providers.details[0];
    final surName = providers.details[1];
    final imageUrl = providers.details[7];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        // appBar: _buildAppBar(context, width),
        appBar: AppBar(
          leading: Visibility(
            visible: iii(),
            child: GestureDetector(
              onTap: () {
                if (widget.passcode! || widget.reset! || widget.touch!) {
                  Navigator.pop(context);
                  return;
                }
                _handleBackButtonPress();
              },
              child: SizedBox(
                width: 30.w,
                height: 30.h,
                child: Center(
                  child: Image.asset(
                    'assets/settings/lock.png',
                    width: 24.w,
                    height: 24.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          actions: [_buildForgotPasswordButton(context, width)],
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: WillPopScope(
          onWillPop: () async {
            if (!iii()) return true; // reset == true, block back

            if (widget.passcode == true ||
                widget.touch == true ||
                widget.reset == true) {
              Navigator.pop(context);
              return false;
            }

            // Default case: go to Login
            _handleBackButtonPress();
            return false;
          },

          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.03,
                vertical: height * 0.05,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildHeader(
                    width,
                    height,
                    imageUrl,
                    firstName,
                    surName,
                    email,
                  ),
                  SizedBox(height: 5.h),
                  _buildInstructionText(),
                  SizedBox(height: 20.h),
                  _buildPasswordField(width),
                  SizedBox(height: height * 0.05),
                  if (_isFieldFilled) _buildAuthenticateButton(width),
                  SizedBox(height: height * 0.015),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, double width) {
    return AppBar(
      leading: _shouldShowBackButton ? _buildBackButton(context) : null,
      actions: [_buildForgotPasswordButton(context, width)],
      elevation: 0,
      backgroundColor: Colors.white,
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: _handleBackButtonPress,
      child: SizedBox(
        width: 30.w,
        height: 30.h,
        child: Center(
          child: Image.asset(
            'assets/settings/lock.png',
            width: 24.w,
            height: 24.h,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton(BuildContext context, double width) {
    return GestureDetector(
      onTap: () => navigateWithSlideTransition(
        context: context,
        destinationScreen: const Forgotpword(),
        transitionDuration: const Duration(milliseconds: 200),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Text(
          'Forgot Password?',
          style: GoogleFonts.nunitoSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    double width,
    double height,
    String imageUrl,
    String firstName,
    String surName,
    String email,
  ) {
    return Header(
      width: width,
      height: height,
      imgurl: imageUrl,
      firstName: firstName,
      surName: surName,
      email: email,
    );
  }

  Widget _buildInstructionText() {
    return Center(
      child: Text(
        'Please enter your password',
        style: GoogleFonts.nunitoSans(
          fontSize: 16.sp,
          color: AppColors.grayColor,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildPasswordField(double width) {
    return TextFormField(
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w400,
        fontSize: width * 0.045,
      ),
      controller: _passwordController,
      keyboardType: TextInputType.visiblePassword,
      obscureText: !_isPasswordVisible,
      validator: _validatePassword,
      decoration: InputDecoration(
        labelStyle: const TextStyle(color: Colors.black),
        hintText: 'Password',
        hintStyle: TextStyle(fontSize: width * 0.035),
        errorStyle: const TextStyle(),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.red),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: _togglePasswordVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(width * 0.03),
        ),
      ),
    );
  }

  Widget _buildAuthenticateButton(double width) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(width * 0.03),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      onPressed: _isAuthenticating ? null : _handleAuthentication,
      child: Container(
        padding: EdgeInsets.all(width * 0.04),
        child: Align(
          alignment: Alignment.center,
          child: _isAuthenticating
              ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  _buttonText,
                  style: TextStyle(
                    color: const Color(0xfff3f3f4),
                    fontWeight: FontWeight.w700,
                    fontSize: width * 0.045,
                  ),
                ),
        ),
      ),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field cannot be Empty';
    } else if (value.length < 8) {
      return 'Password should be at least 8 characters';
    }
    return null;
  }

  void _handleBackButtonPress() {
    _showLogoutConfirmationDialog(context);
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(
            'Are you sure?',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Please confirm that you\'d like to log out of your account',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w400),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff0F77F0),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              child: Text(
                'Log out',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff0F77F0),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Are you sure?',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Please confirm that you\'d like to log out of your account',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w400),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff0F77F0),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              child: Text(
                'Log out',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff0F77F0),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout(context);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Login()),
      (route) => false,
    );
  }

  Future<void> _handleAuthentication() async {
    if (_isAuthenticating || !mounted) return;

    if (_passwordController.text.isEmpty) {
      _dialogBox.information(context, "Status", "Provide your details");
      return;
    }

    FocusScope.of(context).unfocus();

    final email = context.read<Providers>().details[2];
    final password = _passwordController.text.trim();

    setState(() {
      _isAuthenticating = true;
    });

    try {
      await _performAuthentication(email, password);
    } catch (e) {
      print("Authentication Error: $e");
      _handleError(e);
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  Future<void> _performAuthentication(String email, String password) async {
    final token = await _authenticateAndGetToken(email, password);
    if (!mounted) return;

    await _fetchUserData(token);
    if (!mounted) return;

    await _navigateBasedOnUserState(token);
  }

  Future<String> _authenticateAndGetToken(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/mygap/login"),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-API-KEY': 'pT79hjfC91lG7gViU3tSHixtxlZZfvUBfDFeOFKP',
      },
      body: {"email": email, "password": password},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Login failed: ${response.statusCode}');
    }

    final tokenData = Token.fromJSON(jsonDecode(response.body));
    return tokenData.token;
  }

  Future<void> _fetchUserData(String token) async {
    final headers = {
      "Authorization": 'Bearer $token',
      "Accept": "application/json",
    };

    final results = await Future.wait([
      _fetchUserDetails(token, headers),
      _fetchEditDetails(token, headers),
      _fetchSnapshot(token, headers),
      _fetchSevenG(token, headers),
      _fetchSupport(token, headers),
      _fetchCalculator(token, headers),
    ]);

    if (!mounted) return;
    _updateProviders(results, token);
  }

  Future<List<dynamic>> _fetchUserDetails(
    String token,
    Map<String, String> headers,
  ) async {
    final response = await http.get(
      Uri.parse("$baseUrl/user"),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch user details: ${response.statusCode}');
    }
    return [Loginusermodel.fromJson(jsonDecode(response.body)), token];
  }

  Future<Editdetails> _fetchEditDetails(
    String token,
    Map<String, String> headers,
  ) async {
    final response = await http.get(
      Uri.parse("$baseUrl/app/profile"),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch edit details: ${response.statusCode}');
    }
    return Editdetails.fromJson(jsonDecode(response.body));
  }

  Future<Snapshotmodel> _fetchSnapshot(
    String token,
    Map<String, String> headers,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/app/snapshot'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch snapshot: ${response.statusCode}');
    }
    return Snapshotmodel.fromJson(jsonDecode(response.body));
  }

  Future<Sevengeemodel> _fetchSevenG(
    String token,
    Map<String, String> headers,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/app/seveng'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch 7G data: ${response.statusCode}');
    }
    return Sevengeemodel.fromJson(jsonDecode(response.body));
  }

  Future<List<dynamic>> _fetchSupport(
    String token,
    Map<String, String> headers,
  ) async {
    final response = await http.get(
      Uri.parse("$baseUrl/app/support"),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch support data: ${response.statusCode}');
    }
    final body = jsonDecode(response.body);
    return [body['data']['gap_supports']['data']];
  }

  Future<Map<String, dynamic>> _fetchCalculator(
    String token,
    Map<String, String> headers,
  ) async {
    final response = await http.get(
      Uri.parse("$baseUrl/app/calculator"),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch calculator data: ${response.statusCode}',
      );
    }
    final body = jsonDecode(response.body);
    return body['data'];
  }

  Future<void> _updateProviders(List<dynamic> results, String token) async {
    try {
      final providers = context.read<Providers>();
      final loginusermodel = results[0][0] as Loginusermodel;
      final editdetails = results[1] as Editdetails;
      final snapshotmodel = results[2] as Snapshotmodel;
      final sevengeemodel = results[3] as Sevengeemodel;
      final supportData = results[4][0] as List<dynamic>;
      final calculatorData = results[5] as Map<String, dynamic>;

      providers.setLoginDetails(loginusermodel);
      providers.seToken(token);
      _updateUserDetails(providers, editdetails);
      providers.setSupport(supportData);
      providers.setSnapshot(snapshotmodel);
      providers.setCurrentPortfolio(snapshotmodel.financial["portfolio"]);
      providers.setSevenGee(sevengeemodel);
      providers.setCalculator(calculatorData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tokenDB', token);
    } catch (e) {
      print('Error updating providers: $e');
      rethrow;
    }
  }

  void _updateUserDetails(Providers providers, Editdetails editdetails) {
    final user = editdetails.user;
    final profile = user["profile"];

    providers.setDetailsList(user["firstname"], 0);
    providers.setDetailsList(user["surname"].toString(), 1);
    providers.setDetailsList(user["email"].toString(), 2);
    providers.setDetailsList(profile["phone"].toString(), 3);
    providers.setDetailsList(profile["date_of_birth"].toString(), 4);
    providers.setDetailsList(profile["ancesry"].toString(), 5);
    providers.setDetailsList(profile["country"].toString(), 6);

    String imageUrl = profile["image"].toString();
    if (imageUrl.isNotEmpty && imageUrl.length >= 6) {
      imageUrl = imageUrl.replaceRange(0, 6, 'assets/storage');
      imageUrl = '$imgPrefix/$imageUrl';
    }
    providers.setDetailsList(imageUrl, 7);
    providers.setDetailsList(profile["dob_count"].toString(), 8);
    providers.setDetailsList(user["created_at"].toString(), 9);
  }

  Future<void> _navigateBasedOnUserState(String token) async {
    if (!mounted) return;

    final providers = context.read<Providers>();
    final snapshotmodel = providers.snapshotmodel;
    final sevengeemodel = providers.sevengeemodel;
    final calculatorData = providers.calculatorData;

    final totalSteps = sevengeemodel.steps.fold<int>(
      0,
      (sum, step) => (sum) + (step as int),
    );
    final allBackgroundsGray = sevengeemodel.backgrounds.every(
      (element) => element == '#494949',
    );

    // Check if both passcode and touch are true - this means user wants to set up Touch ID
    // but needs to set passcode first
    if (widget.passcode == true && widget.touch == true) {
      // First navigate to Set Passcode
      _navigateToSetPasscodeForTouchID();
    } else if (widget.passcode == true || widget.reset == true) {
      _navigateToSetPasscode();
    } else if (widget.touch == true) {
      _navigateToTouchID();
    } else if (_shouldNavigateToDashboard(
      totalSteps,
      allBackgroundsGray,
      snapshotmodel,
    )) {
      await _navigateToDashboard(token);
    } else if (_shouldNavigateToPrecalc(totalSteps, snapshotmodel)) {
      _navigateToPrecalc();
    } else {
      _navigateBasedOnCalculatorData(calculatorData);
    }
  }

  void _navigateToSetPasscodeForTouchID() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SetPasscodeScreen(fromTouchID: true),
      ),
    );
  }

  bool _shouldNavigateToDashboard(
    int totalSteps,
    bool allBackgroundsGray,
    Snapshotmodel snapshotmodel,
  ) {
    return (totalSteps != 0 || !allBackgroundsGray) &&
        snapshotmodel.currency.isNotEmpty &&
        widget.passcode != true &&
        widget.reset != true &&
        widget.touch != true;
  }

  bool _shouldNavigateToPrecalc(int totalSteps, Snapshotmodel snapshotmodel) {
    return totalSteps == 0 &&
        snapshotmodel.currency.isEmpty &&
        snapshotmodel.financial["cost"].toString() == "0";
  }

  void _navigateToSetPasscode() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SetPasscodeScreen()),
    );
  }

  void _navigateToTouchID() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TouchID()),
    );
  }

  Future<void> _navigateToDashboard(String token) async {
    if (!mounted) return;

    try {
      final response = await _dio.get(
        "$baseUrl/app/dashboard",
        options: Options(
          headers: {
            "Authorization": 'Bearer $token',
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
        ),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final providers = context.read<Providers>();
        providers.setDashData(response.data);
        providers.setCurrency(response.data["gap_currencies"]["user_currency"]);
        providers.setManualCurrency(
          response.data["gap_currencies"]["manual_currencies"],
        );
        providers.setSystemCurrency(
          response.data["gap_currencies"]["system_currencies"],
        );
        providers.setAssistance(response.data["assistance"]);

        if (!mounted) return;

        // Use pushReplacement to avoid going back to login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard(index: 0)),
        );
      } else {
        if (!mounted) return;
        _showErrorDialog('Failed to load dashboard: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("Dio Error: $e");
      if (mounted) {
        _showErrorDialog('Network error: ${e.message}');
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) {
        _showErrorDialog('An unexpected error occurred');
      }
    }
  }

  void _navigateToPrecalc() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Precalc()),
    );
  }

  void _navigateBasedOnCalculatorData(Map<dynamic, dynamic> calculatorData) {
    if (!mounted) return;

    final currency = calculatorData["currency"]?.toString() ?? "";

    if (currency.isEmpty) {
      _navigateToPrequestions();
      return;
    }

    final values = _parseCalculatorValues(calculatorData);
    final initialPage = _determineInitialPage(values);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MultiStepForm(
          initialPage: initialPage,
          currentPageIndex: initialPage,
        ),
      ),
    );
  }

  Map<String, num> _parseCalculatorValues(
    Map<dynamic, dynamic> calculatorData,
  ) {
    return {
      'savings':
          num.tryParse(calculatorData["periodic_savings"]?.toString() ?? "0") ??
          0,
      'education':
          num.tryParse(calculatorData["education"]?.toString() ?? "0") ?? 0,
      'mortgage':
          num.tryParse(calculatorData["mortgage"]?.toString() ?? "0") ?? 0,
      'mobility':
          num.tryParse(calculatorData["mobility"]?.toString() ?? "0") ?? 0,
      'expenses':
          num.tryParse(calculatorData["expenses"]?.toString() ?? "0") ?? 0,
      'utility':
          num.tryParse(calculatorData["utility"]?.toString() ?? "0") ?? 0,
      'debtRepay':
          num.tryParse(calculatorData["dept_repay"]?.toString() ?? "0") ?? 0,
      'charity':
          num.tryParse(calculatorData["charity"]?.toString() ?? "0") ?? 0,
      'otherIncome':
          num.tryParse(calculatorData["other_income"]?.toString() ?? "0") ?? 0,
      'extraSave':
          num.tryParse(calculatorData["extra_save"]?.toString() ?? "0") ?? 0,
    };
  }

  int _determineInitialPage(Map<String, num> values) {
    if (values['extraSave'] == 0 && values['otherIncome'] == 0) return 1;
    if (values['savings'] == 0 &&
        values['education'] == 0 &&
        values['mortgage'] == 0 &&
        values['mobility'] == 0 &&
        values['expenses'] == 0 &&
        values['utility'] == 0 &&
        values['debtRepay'] == 0 &&
        values['charity'] == 0) {
      return 0;
    }
    if (values['extraSave']! > 0 || values['otherIncome']! > 0) return 2;
    return 1;
  }

  void _navigateToPrequestions() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Prequestions()),
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    _dialogBox.information(context, 'Error', message);
  }

  void _handleError(dynamic error) {
    if (mounted) {
      _dialogBox.information(
        context,
        'Status',
        error is String ? error : 'Password Incorrect',
      );
    }
  }
}

class Header extends StatelessWidget {
  final double? width;
  final double? height;
  final String? imgurl;
  final String? email;
  final String? firstName;
  final String? surName;
  final Loginusermodel? details;

  const Header({
    super.key,
    this.width,
    this.height,
    this.imgurl,
    this.email,
    this.firstName,
    this.surName,
    this.details,
  });

  @override
  Widget build(BuildContext context) {
    final providers = context.watch<Providers>();
    final displayName = providers.details[0];

    return Container(
      constraints: BoxConstraints(
        maxHeight: height ?? 200, // Provide a fallback max height
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildUserAvatar(),
            SizedBox(height: 10.h), // Reduced from dynamic to fixed spacing
            _buildWelcomeMessage(displayName),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    const defaultAvatar1 = '$imgPrefix/assets/storage/avatar/Avatar_Male 1.png';
    const defaultAvatar2 = '$imgPrefix/assets/storage/avatar/default.png';

    final isCustomImage =
        imgurl != 'null' &&
        imgurl!.isNotEmpty &&
        imgurl != defaultAvatar1 &&
        imgurl != defaultAvatar2;

    // Use fixed size or calculated size with constraints
    final avatarSize = (width ?? 100) * 0.3;

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color.fromRGBO(0, 0, 0, 0.08),
          width: 3,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(avatarSize / 2),
        child: Container(
          color: Colors.white,
          child: isCustomImage
              ? CachedNetworkImage(
                  imageUrl: imgurl!,
                  width: avatarSize,
                  height: avatarSize,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, progress) => Center(
                    child: CircularProgressIndicator(value: progress.progress),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.portrait,
                      size: avatarSize,
                      color: Colors.grey,
                    ),
                  ),
                )
              : Image.asset(
                  'assets/settings/avatar.png',
                  width: avatarSize,
                  height: avatarSize,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage(String displayName) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: width ?? 300, // Constrain text width
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: 1.0,
        child: RichText(
          textAlign: TextAlign.center, // Ensure text is centered
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Welcome back $displayName',
                style: GoogleFonts.nunitoSans(
                  fontSize: 20.sp, // Slightly reduced font size
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: '!',
                style: GoogleFonts.nunitoSans(
                  fontSize: 20.sp, // Consistent font size
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
