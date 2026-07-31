// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:GapHub/utils/dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'dart:convert';
import 'package:GapHub/models/loginusermodel.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  TextEditingController _textEditingController = TextEditingController();
  Dio dio = Dio();
  DialogBox dialogBox = DialogBox();
  bool isChanging = true;
  Timer? t;
  String token = '';
  dynamic signin = '';
  String passcode = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      AppLock.of(context)!.enable();
    });
    whatToDo();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  whatToDo() async {
    Timer(const Duration(milliseconds: 5), () {
      setState(() {
        isChanging = false;
      });
    });
    getDetails();
    print("loading");
  }

  getDetails() async {
    var urlDetails = Uri.parse("$baseUrl/user");
    var urlEditDetails = Uri.parse("$baseUrl/app/profile");
    // String security = "$baseUrl/mygap/security";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    if (token != 'logout' && token != null) {
      try {
        final response2 = await http.get(
          urlDetails,
          headers: {"Authorization": 'Bearer $token'},
        );
        print("userDetails: ${response2.statusCode}");
        Loginusermodel loginusermodel = Loginusermodel.fromJson(
          jsonDecode(response2.body),
        );
        context.read<Providers>().setLoginDetails(loginusermodel);
        final responseDetails = await http.get(
          urlEditDetails,
          headers: {
            "Authorization": 'Bearer $token',
            "Accept": "application/json",
          },
        );
        print("profileDetails: ${responseDetails.statusCode}");
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              key: const Key('PasswordField'),
              controller: _textEditingController,
            ),
            ElevatedButton(
              key: const Key('UnlockButton'),
              child: const Text('Go'),
              onPressed: () {
                if (_textEditingController.text == '0000') {
                  AppLock.of(context)!.didUnlock('some data');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
