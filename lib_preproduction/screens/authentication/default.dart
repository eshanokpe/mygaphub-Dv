import 'package:GapHub/models/loginusermodel.dart';
import 'package:GapHub/screens/authentication/landing.dart';
import 'package:GapHub/screens/authentication/login/login.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/widgets/spaces.dart';
import 'package:local_auth/local_auth.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class Default extends StatefulWidget {
  const Default({super.key});

  @override
  _DefaultState createState() => _DefaultState();
}

class _DefaultState extends State<Default> {
  DialogBox dialogBox = DialogBox();
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  Future<bool> _isBiometricAvailable() async {
    bool isAvailable = false;
    try {
      isAvailable = await _localAuthentication.canCheckBiometrics;
    } on PlatformException catch (e) {
      dialogBox.information(context, 'Error', e.toString());
    }
    if (!mounted) return isAvailable;
    return isAvailable;
  }

  /// Reusable Logout Confirmation Dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Confirmation"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove(
                  'tokenDB',
                ); // Directly remove — no need to set to 'logout' first
                await prefs.remove('signin');
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                  (route) => false,
                );
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
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
    String email = context.watch<Providers>().details[2];
    String imgurl = context.watch<Providers>().details[7];
    print("image__: $imgurl");

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: _showLogoutDialog, // Use the shared function
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: WillPopScope(
        // Handle device/keyboard back button
        onWillPop: () async {
          _showLogoutDialog();
          return false; // Prevent default back navigation
        },
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: width * .02,
              vertical: height * .01,
            ),
            child: Column(
              children: [
                Header(
                  email: email,
                  imgurl: imgurl,
                  height: height,
                  width: width,
                  details: Loginusermodel(),
                  firstName: '',
                  surName: '',
                ),
                Hspace(height * .01),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * .03),
                    ),
                    backgroundColor: AppColors.primaryColor,
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString('signin', 'passcode');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Landing(
                          passcode: true,
                          touch: false,
                          reset: false,
                          fromID: false,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(width * .04),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'SET PASS CODE',
                        style: TextStyle(
                          color: const Color(0xfff3f3f4),
                          fontWeight: FontWeight.w900,
                          fontSize: width * .04,
                        ),
                      ),
                    ),
                  ),
                ),
                Hspace(height * .03),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * .03),
                    ),
                    backgroundColor: AppColors.primaryColor,
                  ),
                  onPressed: () async {
                    if (await _isBiometricAvailable()) {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString('signin', 'touchid');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Landing(
                            passcode: true,
                            touch: true,
                            reset: false,
                            fromID: false,
                          ),
                        ),
                      );
                    } else {
                      dialogBox.information(
                        context,
                        'Status',
                        'This device does not have a biometric system',
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(width * .04),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'USE TOUCH ID',
                        style: TextStyle(
                          color: const Color(0xfff3f3f4),
                          fontWeight: FontWeight.w900,
                          fontSize: width * .04,
                        ),
                      ),
                    ),
                  ),
                ),
                Hspace(height * .02),
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Container(
                      width: width * .15,
                      height: width * .15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: width * .005,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        size: width * .1,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Landing(
                              touch: false,
                              passcode: false,
                              reset: false,
                              fromID: false,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Hspace(height * .01),
                Text(
                  'Go to account',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: width * .06,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
