import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/provider/AuthProvider.dart';
import 'package:GapHub/provider/acquisitionProvider.dart';
import 'package:GapHub/provider/signin_preferences_provider.dart';
import 'package:GapHub/screens/authentication/passcode/setpasscode.dart';
import 'package:GapHub/screens/authentication/touchID/touchid.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/spaces.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/models/loginusermodel.dart';
import 'package:GapHub/models/sevengeemodel.dart';
import 'package:GapHub/models/snapshotmodel.dart';
import 'package:GapHub/screens/authentication/login/forgot_password/forgotpword.dart';
import 'package:GapHub/screens/authentication/login/login.dart';
import 'package:GapHub/screens/registration/calculation/precalc.dart';
import 'package:GapHub/screens/registration/financial_health/prequestions.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../registration/calculation/multi_form.dart';

class Landing22 extends StatefulWidget {
  final bool? passcode;
  final bool? touch;
  final bool? reset;
  final bool? fromID;
  const Landing22({
    super.key,
    this.passcode,
    this.touch,
    this.reset,
    this.fromID,
  });
  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing22> {
  var details = Loginusermodel(
    id: 0,
    email: '',
    firstname: '',
    surname: '',
    phone: '',
    extra: '',
    emailVerifiedAt: '',
    createdAt: '',
    updatedAt: '',
    unseenNotifications: 0,
  );

  DialogBox dialogBox = DialogBox();
  bool visible = true;
  Dio dio = Dio();
  void _toogle() {
    setState(() {
      visible = !visible;
    });
  }

  TextEditingController passCon = TextEditingController();
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    var details = context.watch<Providers>().loginDetails;
    String email = context.watch<Providers>().details[2];
    String firstName = context.watch<Providers>().details[0];
    String surName = context.watch<Providers>().details[1];

    // Future<String> getImgUrl(BuildContext context) async {
    //   String imgurl_ = context.watch<Providers>().details[7];
    //   // String imgurl = imgurl_.replaceFirst("mygaphub.com/app/", "mygaphub.com/");
    //   return imgurl_;
    // }

    String imgurl = context.watch<Providers>().details[7];
    print("imgurl_Login$imgurl");

    // String imgurl_;

    // if (imgurl != null) {
    //   imgurl_ = imgurl.replaceFirst(
    //     'https://mygaphub.com/assets/storage',
    //     // 'https://appstaging.mygaphub.com/assets/storage',
    //     '/app/assets',
    //   );
    //   imgurl = '$imgPrefix$imgurl_';
    //   if (imgurl_.contains('$imgPrefix')) {
    //     imgurl = imgurl_;
    //   }
    // }
    bool iii() {
      if (widget.reset!) {
        return false;
      } else {
        return true;
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: Visibility(
          visible: iii(),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: _handleBackButtonPress,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: WillPopScope(
        onWillPop: () async => false,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * .03,
                vertical: height * .02,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Header(
                    width: width,
                    height: height,
                    imgurl: imgurl,
                    details: details,
                    email: email,
                    firstName: firstName,
                    surName: surName,
                  ),
                  TextFormField(
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w400,
                      fontSize: width * .045,
                    ),
                    controller: passCon,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: visible,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Field cannot be Empty';
                      } else if (val.length < 8) {
                        return 'Password should be at least 8 characters';
                      } else
                        return null;
                    },
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.black),
                      hintText: 'Password',
                      hintStyle: TextStyle(fontSize: width * .035),
                      errorStyle: const TextStyle(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          !visible ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: _toogle,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(width * .03),
                      ),
                    ),
                  ),
                  Hspace(height * .05),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(width * .03),
                      ),
                      backgroundColor: AppColors.primaryColor,
                    ),
                    onPressed: () async {
                      if (passCon.text.isEmpty) {
                        dialogBox.information(
                          context,
                          "Status",
                          "Provide your details",
                        );
                        return;
                      }
                      FocusScope.of(context).requestFocus(FocusNode());
                      // bool result = await isInternetAvailable();
                      // if (!result) {
                      //   dialogBox.information(context, 'Status',
                      //       'Check your Internet Connection');
                      //   return;
                      // }

                      if (true) {
                        final String peeword = passCon.text.trim();
                        FocusScope.of(context).requestFocus(FocusNode());
                        context.read<AcquisitionProvider>();
                        signIn(email, peeword);
                        passCon.clear();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(width * .04),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          widget.passcode!
                              ? "Authenticate to Set Pass Code"
                              : widget.touch!
                              ? "Authenticate to Use Touch ID"
                              : widget.reset!
                              ? "Reset Pass Code"
                              : "Sign In",
                          style: TextStyle(
                            color: const Color(0xfff3f3f4),
                            fontWeight: FontWeight.w700,
                            fontSize: width * .045,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Hspace(height * .015),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Forgotpword(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.none,
                        color: Colors.black,
                        fontSize: width * .04,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signIn(String email, String password) async {
    // final urLogin = Uri.parse("$baseUrl/mygap/login");
    var urLogin = Uri.parse("$baseUrl/mygap/login");
    final urlDetails = Uri.parse("$baseUrl/user");
    final url7G = Uri.parse('$baseUrl/app/seveng');
    final urlEditDetails = Uri.parse("$baseUrl/app/profile");
    const urlr = "$baseUrl/app/360/tiles";
    const url = "$baseUrl/app/portfolio";
    final urlEdit = Uri.parse('$baseUrl/app/seveng/edit');
    const urld = "$baseUrl/app/dashboard";
    final urlSnapshot = Uri.parse('$baseUrl/app/snapshot');
    final urlSupport = Uri.parse("$baseUrl/app/support");
    final urlCalculator = Uri.parse("$baseUrl/app/calculator");

    void showTimeoutError() {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
    }

    // Show loading dialog
    dialogBox.waiting(
      context,
      widget.passcode! || widget.touch! || widget.reset!
          ? "Checking"
          : 'Preparing your dashboard',
    );

    final timer = Timer(const Duration(milliseconds: 50000), showTimeoutError);

    try {
      print("email:$email");
      // Step 1: Login
      final loginResponse = await http.post(
        urLogin,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-API-KEY': 'pT79hjfC91lG7gViU3tSHixtxlZZfvUBfDFeOFKP',
        },
        body: {"email": email, "password": password},
      );
      if (loginResponse.statusCode != 200 && loginResponse.statusCode != 201) {
        throw Exception('Login failed: ${loginResponse.statusCode}');
      }

      final token = Token.fromJSON(
        jsonDecode(loginResponse.body),
      ).toString().substring(3).trim();

      final headers = {
        "Authorization": 'Bearer $token',
        "Accept": "application/json",
      };

      // Step 2: Get user details
      final detailsResponse = await http.get(urlDetails, headers: headers);
      if (detailsResponse.statusCode != 200) {
        throw Exception('Failed to get user details');
      }

      final loginusermodel = Loginusermodel.fromJson(
        jsonDecode(detailsResponse.body),
      );
      context.read<Providers>().setLoginDetails(loginusermodel);
      context.read<Providers>().seToken(token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tokenDB', token);

      // Step 3: Get additional user data
      final editDetailsResponse = await http.get(
        urlEditDetails,
        headers: headers,
      );
      final Map<String, dynamic> responseBody = jsonDecode(
        editDetailsResponse.body,
      );
      Editdetails editdetails = Editdetails.fromJson(responseBody);

      print('ckecing');
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
      print("loginResponse:66");

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
      print("loginResponse:77");

      var imgurl = editdetails.user["profile"]["image"].toString();
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

      final snapshotResponse = await http.get(urlSnapshot, headers: headers);
      final supportResponse = await http.get(urlSupport, headers: headers);
      final calculatorResponse = await http.get(
        urlCalculator,
        headers: headers,
      );

      final snapshotmodel = Snapshotmodel.fromJson(
        jsonDecode(snapshotResponse.body),
      );
      final bodySupport = jsonDecode(supportResponse.body);

      final dataSupport = bodySupport['data']['gap_supports']['data'];
      context.read<Providers>().setSupport(dataSupport);
      context.read<Providers>().setSnapshot(snapshotmodel);
      context.read<Providers>().setCurrentPortfolio(
        snapshotmodel.financial["portfolio"],
      );

      // Step 4: Fetch additional data
      final sevengeeResponse = await http.get(url7G, headers: headers);
      final sevengeemodel = Sevengeemodel.fromJson(
        jsonDecode(sevengeeResponse.body),
      );
      context.read<Providers>().setSevenGee(sevengeemodel);

      final portfolioResponse = await dio.get(
        url,
        options: Options(headers: headers),
      );
      final recentResponse = await dio.get(
        urlr,
        options: Options(headers: headers),
      );
      final editResponse = await http.get(urlEdit, headers: headers);

      if (portfolioResponse.statusCode == 200) {
        context.read<Providers>().setPortfolio(portfolioResponse.data);
      }
      if (recentResponse.statusCode == 200) {
        context.read<Providers>().setRecent(recentResponse.data["tiles"]);
      }
      if (editResponse.statusCode == 200) {
        final data = jsonDecode(editResponse.body);
        final analyticsinfo = Analyticsinfo.fromJson(data['data']);
        context.read<Providers>().setAnalyticsInfo(analyticsinfo);
      }

      // Step 5: Handle navigation based on conditions
      int tot = sevengeemodel.steps.fold(
        0,
        (sum, step) => (sum + step).toInt(),
      );

      bool col = sevengeemodel.backgrounds.every(
        (element) => element == '#494949',
      );
      if (loginResponse.statusCode == 200 &&
          detailsResponse.statusCode == 200) {
        if ((tot != 0 || !col) &&
            snapshotmodel.currency.isNotEmpty &&
            widget.passcode != true &&
            widget.reset != true &&
            widget.touch != true) {
          final dashResponse = await dio.get(
            urld,
            options: Options(headers: headers),
          );
          if (dashResponse.statusCode == 200 ||
              dashResponse.statusCode == 201) {
            context.read<Providers>().setDashData(dashResponse.data);
            context.read<Providers>().setCurrency(
              dashResponse.data["gap_currencies"]["user_currency"],
            );
            context.read<Providers>().setManualCurrency(
              dashResponse.data["gap_currencies"]["manual_currencies"],
            );
            context.read<Providers>().setSystemCurrency(
              dashResponse.data["gap_currencies"]["system_currencies"],
            );
            context.read<Providers>().setAssistance(
              dashResponse.data["assistance"],
            );
            context.read<SignInPreferencesProvider>().fetchSignInPreferences();
            context.read<SignInPreferencesProvider>().fetchPasscodeStatus();
            timer.cancel();
            _navigatorKey.currentState!.pop();
          } else {
            Fluttertoast.showToast(
              backgroundColor: Colors.red,
              textColor: Colors.white,
              msg: 'Gapproperties Hub is Down',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          }
        } else if (widget.passcode == true || widget.reset == true) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SetPasscodeScreen()),
          );
        } else if (widget.touch == true) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TouchID()),
          );
        } else if (tot == 0 &&
            snapshotmodel.currency.isEmpty &&
            snapshotmodel.financial["cost"].toString() == "0") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Precalc()),
          );
        } else {
          final bodyCalculator = jsonDecode(calculatorResponse.body);
          final dataCalculator = bodyCalculator['data'];

          context.read<Providers>().setCalculator(dataCalculator);
          final calculatorData = context.read<Providers>().calculatorData;
          print('calculatorData:$calculatorData');

          String currency = calculatorData["currency"];
          final savingsValue =
              num.tryParse(calculatorData["periodic_savings"]) ?? 0;
          final educationValue = num.tryParse(calculatorData["education"]) ?? 0;
          final mortgageValue = num.tryParse(calculatorData["mortgage"]) ?? 0;
          final mobilityValue = num.tryParse(calculatorData["mobility"]) ?? 0;
          final expensesValue = num.tryParse(calculatorData["expenses"]) ?? 0;
          final utilityValue = num.tryParse(calculatorData["utility"]) ?? 0;
          final debtRepayValue =
              num.tryParse(calculatorData["dept_repay"]) ?? 0;
          final charityValue = num.tryParse(calculatorData["charity"]) ?? 0;
          final otherIncomeValue =
              num.tryParse(calculatorData["other_income"]) ?? 0;
          final extraSaveValue =
              num.tryParse(calculatorData["extra_save"]) ?? 0;

          if (currency.isNotEmpty) {
            timer.cancel();
            if (extraSaveValue == 0 && otherIncomeValue == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const MultiStepForm(initialPage: 1, currentPageIndex: 1),
                ),
              );
              return;
            } else if (savingsValue == 0 &&
                educationValue == 0 &&
                mortgageValue == 0 &&
                mobilityValue == 0 &&
                expensesValue == 0 &&
                utilityValue == 0 &&
                debtRepayValue == 0 &&
                charityValue == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const MultiStepForm(initialPage: 0, currentPageIndex: 0),
                ),
              );
              return;
            } else if (extraSaveValue > 0 || otherIncomeValue > 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const MultiStepForm(initialPage: 2, currentPageIndex: 2),
                ),
              );
              return;
            } else if (savingsValue > 0 ||
                educationValue > 0 ||
                mortgageValue > 0 ||
                mobilityValue > 0 ||
                expensesValue > 0 ||
                utilityValue > 0 ||
                debtRepayValue > 0 ||
                charityValue > 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const MultiStepForm(initialPage: 1, currentPageIndex: 1),
                ),
              );
              return;
            }
          } else {
            timer.cancel();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Prequestions()),
            );
          }
        }
      } else {
        throw Exception('Password Incorrect');
      }
    } catch (e) {
      print("Error:$e");
      Navigator.pop(context);
      // dialogBox.information(context, 'Status', 'Error: $e');
      dialogBox.information(context, 'Status', 'Password Incorrect');
    } finally {
      timer.cancel();
    }
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
            'Please confirm that you’d like to log out of your account',
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
                Navigator.of(context).pop(); // dismiss dialog
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context).pop(); // dismiss dialog
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
            'Please confirm that you’d like to log out of your account',
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
                Navigator.of(context).pop(); // dismiss dialog
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop(); // dismiss dialog
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
}

class Header extends StatefulWidget {
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

  final double? width;
  final double? height;
  final String? imgurl;
  final String? email;
  final String? firstName;
  final String? surName;
  final Loginusermodel? details;

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  DialogBox dialogBox = DialogBox();
  @override
  Widget build(BuildContext context) {
    print("image__landing: ${widget.imgurl}");
    Future getImg() async {
      return Image.network(
        widget.imgurl!,
        width: widget.width! * .14,
        height: widget.width! * .14,
        fit: BoxFit.cover,
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Important: Use min to avoid expanding
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.imgurl == 'null'
              ? Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromRGBO(0, 0, 0, 0.08),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      'assets/images/default.png',
                      width: widget.width! * .3,
                      height: widget.width! * .3,
                    ),
                  ),
                )
              : FutureBuilder(
                  future: getImg(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        width: widget.width! * .3,
                        height: widget.width! * .3,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromRGBO(0, 0, 0, 0.08),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CachedNetworkImage(
                            imageUrl: widget.imgurl!,
                            progressIndicatorBuilder:
                                (context, url, progress) => Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: .5,
                                    value: progress.progress,
                                  ),
                                ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.portrait),
                            width: widget.width! * .3,
                            height: widget.width! * .3,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
          SizedBox(height: widget.height! * .02),

          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: 1.0,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          'Welcome back ${context.watch<Providers>().details[1]}',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: '!',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 20.sp,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
