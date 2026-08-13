import 'dart:async';

import 'package:GapHub/models/network_checker.dart';
import 'package:GapHub/screens/authentication/login/login.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/spaces.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasscode extends StatefulWidget {
  final bool settings;
  const ChangePasscode({super.key, required this.settings});

  @override
  _ChangePasscodeState createState() => _ChangePasscodeState();
}

class _ChangePasscodeState extends State<ChangePasscode> {
  TextEditingController currentPasscode = TextEditingController();
  TextEditingController newPasscode = TextEditingController();
  TextEditingController confirmPasscode = TextEditingController();
  bool visible = true;
  bool visible2 = true;
  bool visible3 = true;
  final _key = GlobalKey<FormState>();
  DialogBox dialogBox = DialogBox();
  Dio dio = Dio();
  void _toggle() {
    setState(() {
      visible = !visible;
    });
  }

  void _toggle2() {
    setState(() {
      visible2 = !visible2;
    });
  }

  void _toggle3() {
    setState(() {
      visible3 = !visible3;
    });
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
        title: const Text(
          'GAPhub',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: const BottomNav(4),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: width * .02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * .02),
              Text(
                'Update Passcode',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: width * .08,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height * .1),
              Form(
                key: _key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current passcode',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: width * .035,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: height * .005),
                    TextFormField(
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w400,
                        fontSize: width * .045,
                      ),
                      controller: currentPasscode,
                      maxLength: 4,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      keyboardType: TextInputType.phone,
                      obscureText: visible,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Field cannot be Empty';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelStyle: const TextStyle(color: Colors.black),
                        hintText: 'Enter your current code',
                        hintStyle: TextStyle(fontSize: width * .035),
                        errorStyle: const TextStyle(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            !visible ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => _toggle(),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(width * .03),
                        ),
                      ),
                    ),
                    SizedBox(height: height * .005),
                    Text(
                      'New passcode',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: width * .035,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: height * .005),
                    TextFormField(
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w400,
                        fontSize: width * .045,
                      ),
                      controller: newPasscode,
                      maxLength: 4,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      keyboardType: TextInputType.phone,
                      obscureText: visible2,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Field cannot be Empty';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelStyle: const TextStyle(color: Colors.black),
                        hintText: 'Enter new code',
                        hintStyle: TextStyle(fontSize: width * .035),
                        errorStyle: const TextStyle(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            !visible2 ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => _toggle2(),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(width * .03),
                        ),
                      ),
                    ),
                    SizedBox(height: height * .005),
                    Text(
                      'Confirm new passcode',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: width * .035,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: height * .005),
                    TextFormField(
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w400,
                        fontSize: width * .045,
                      ),
                      controller: confirmPasscode,
                      maxLength: 4,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      keyboardType: TextInputType.phone,
                      obscureText: visible3,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Field cannot be Empty';
                        } else if (val != newPasscode.text) {
                          return 'Code doesn\'t match';
                        } else
                          return null;
                      },
                      decoration: InputDecoration(
                        labelStyle: const TextStyle(color: Colors.black),
                        hintText: 'Retype code',
                        hintStyle: TextStyle(fontSize: width * .035),
                        errorStyle: const TextStyle(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            !visible3 ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => _toggle3(),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(width * .03),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Hspace(height * .05),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width * .03),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                onPressed: () async {
                  EasyLoading.show(status: 'Loading', dismissOnTap: false);
                  // bool result = await isInternetAvailable();
                  // if (!result) {

                  //   dialogBox.information(context, 'Status','Check your Internet Connection');
                  //   EasyLoading.dismiss();
                  //   return;
                  // }
                  final isPasscode = await _getPasscode(currentPasscode.text);
                  if (!isPasscode) {
                    dialogBox.information(
                      context,
                      'Status',
                      'Wrong current passcode',
                    );
                    EasyLoading.dismiss();

                    return;
                  }
                  if (newPasscode.text.trim() == confirmPasscode.text.trim() &&
                      ![null, ""].contains(newPasscode.text.trim()) &&
                      ![null, ""].contains(confirmPasscode.text.trim()) &&
                      currentPasscode.text.trim() != newPasscode.text.trim()) {
                    update();
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(width * .04),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Update Passcode',
                      style: TextStyle(
                        color: const Color(0xfff3f3f4),
                        fontWeight: FontWeight.w700,
                        fontSize: width * .05,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _getPasscode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('tokenDB');
    String url = '$baseUrl/confirm/passcode';
    Map data = {"pass": value};
    var response = await dio.post(
      url,
      data: data,
      options: Options(
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
        },
      ),
    );

    if (response.statusCode == 200 && response.data['success'] == false) {
      return false;
    } else if (response.statusCode == 200 && response.data['success'] == true) {
      return true;
    } else {
      return false;
    }
  }

  update() async {
    EasyLoading.show(status: 'Loading', dismissOnTap: false);

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('tokenDB');
    String setpasscode = '$baseUrl/mygap/securemobile';

    Map data = {
      'passcode': confirmPasscode.text,
      'security': 'agvabnvdnbsnvdbnvsjnbnffv',
    };

    var timer = Timer(const Duration(milliseconds: 31000), () {
      EasyLoading.dismiss();
      return;
    });

    var response = await dio.post(
      setpasscode,
      data: data,
      options: Options(
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
        },
      ),
    );

    if (response.statusCode == 200) {
      EasyLoading.dismiss();
      var res = response.data;
      var succ = ![null, ""].contains(res["success"]) ? true : false;
      var err = res["error"] ?? false;
      if (succ) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('tokenDB', 'logout');
        Fluttertoast.showToast(msg: 'Successfully reset passcode');
        EasyLoading.dismiss();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      } else {
        EasyLoading.dismiss();
        Fluttertoast.showToast(
          toastLength: Toast.LENGTH_LONG,
          msg: "$err",
          backgroundColor: Theme.of(context).primaryColor,
        );
      }
    } else {
      EasyLoading.dismiss();
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: "Unknown Error",
        backgroundColor: Theme.of(context).primaryColor,
      );
      EasyLoading.dismiss();
    }
  }
}
