import 'package:GapHub/screens/360/accounts/income/income.dart';
import 'package:GapHub/screens/360/accounts/mortgage/mortgage.dart';
import 'package:flutter/material.dart';
import 'package:GapHub/screens/360/accounts/cash/cash.dart';
import 'package:GapHub/screens/360/accounts/assets/assets.dart';
import 'package:GapHub/screens/360/accounts/protection/addProtection/add_protection.dart';
import 'accounts/liabilities/liabilities.dart';
import 'package:GapHub/screens/360/accounts/retirement/retirement.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/utils/constants.dart';

class Decider extends StatefulWidget {
  final String account;
  const Decider(this.account, {super.key});

  @override
  _DeciderState createState() => _DeciderState();
}

class _DeciderState extends State<Decider> {
  bool _primaryRes = false;
  Map<String, dynamic> _mortgageInfo = {};
  bool mortgageloading = true;

  @override
  void initState() {
    super.initState();
    toMortgage();
  }

  @override
  Widget build(BuildContext context) {
    Widget body() {
      switch (widget.account) {
        case "Cash":
          return const Cash();
        case "Liabilities":
          return const Liabilities();
        case "Mortgage":
          if (!mortgageloading) {
            return Mortgage(
              primaryRes: _primaryRes,
              mortgageInfo: _mortgageInfo,
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            ); // Loading indicator
          }
        case "Protection":
          return const AddProtectionScreen();
        case "Assets":
          return const Assets();
        case "Retirement(Pension)":
          return const Retirement();
        case "Income":
          return const Income();
        default:
          return Center(child: Text("No screen found for ${widget.account}"));
      }
    }

    return Scaffold(body: body());
  }

  Future<void> toMortgage() async {
    EasyLoading.show(status: 'Loading...', dismissOnTap: false);

    try {
      var url = Uri.parse("$baseUrl/app/360/equity/info");
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      var response = await http.get(
        url,
        headers: {"Authorization": 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);

        setState(() {
          _primaryRes = res['primary_exist'] ?? false;
          _mortgageInfo = res['secured_against'] ?? {};
          mortgageloading = false;
        });
      } else {
        _handleError(response.statusCode);
      }
    } catch (e) {
      print("An error occurred: ${e.toString()}");
      Fluttertoast.showToast(
        msg: "An error occurred: ${e.toString()}",
        backgroundColor: Colors.red,
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _handleError(int statusCode) {
    String errorMessage;
    switch (statusCode) {
      case 400:
        errorMessage = "Error: Bad request";
        break;
      case 401:
        errorMessage = "Error: Unauthorized, please login again";
        break;
      case 422:
        errorMessage = "Error: 422, please try again later";
        break;
      case 500:
        errorMessage = "Error: Server error";
        break;
      default:
        errorMessage = "Error: Something went wrong";
    }
    Fluttertoast.showToast(msg: errorMessage, backgroundColor: Colors.red);
  }
}
