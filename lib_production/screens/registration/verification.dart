import 'package:GapHub/screens/authentication/login/login.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class Verification extends StatefulWidget {
  const Verification({super.key});

  // final List<String> details;

  // Verification(this.details);
  @override
  // _VerificationState createState() => _VerificationState(this.details);
  _VerificationState createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  late List<String> details;
  // _VerificationState(this.details);
  // _VerificationState();

  DialogBox dialogBox = DialogBox();

  @override
  void initState() {
    super.initState();
    const MethodChannel("com.prismcheck.GapHub.goToLogin").setMethodCallHandler(
      (MethodCall call) async {
        if (call.method == "goToLoginFromVerification") {
          print("receiving from goToLoginFromVerification");
          var routeName = ModalRoute.of(context)!.settings.name;
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if (routeName == "Verification" && routeName != null) {
              Timer(const Duration(milliseconds: 200), () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(fromAppLink: true),
                  ),
                );
              });
            }
          });
        }
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

    pop() {
      SystemNavigator.pop();
    }

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: const Text(
          'GAPhub',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: WillPopScope(
        onWillPop: () {
          return dialogBox.options(
            context,
            'Close',
            'Are you sure you want to exit?',
            pop,
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * .02,
            vertical: height * .02,
          ),
          child: Card(
            elevation: 5,
            child: Center(
              child: SizedBox(
                height: height,
                width: width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: height * .3,
                      width: width * .3,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xff646464),
                      ),
                      child: Image.asset(
                        'assets/images/check.jpg',
                        height: height * 3,
                        width: width * .2,
                      ),
                    ),
                    SizedBox(height: height * .01),
                    Text(
                      'Thank you for your registration',
                      style: TextStyle(
                        fontSize: width * .055,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: height * .01),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Text(
                        'Please check your email (including your spam folder) to verify your account. if you did not receive the email, click here to request another.',
                        style: TextStyle(
                          fontSize: width * .04,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(height: height * .05),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Didn\'t receive any email? Resend',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: width * .04,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: height * .05),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                      child: Text(
                        'Go back to Login',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: width * .04,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
