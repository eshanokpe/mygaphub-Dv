import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:GapHub/utils/constants.dart';

class SavingIncomeController extends GetxController {
  var otherWages = ''.obs;
  var rainyDays = ''.obs;
  var total = 0.0.obs;
  var selectedCurrency = ''.obs;
  var savings = ''.obs;
  var education = ''.obs;
  var mortgage = ''.obs;
  var mobility = ''.obs;
  var expenses = ''.obs;
  var utility = ''.obs;
  var debtRepay = ''.obs;
  var charity = ''.obs;

  void increment() {
    double a = otherWages.value.isEmpty
        ? 0
        : double.tryParse(otherWages.value) ?? 0;
    double b = rainyDays.value.isEmpty
        ? 0
        : double.tryParse(rainyDays.value) ?? 0;
    total.value = a + b;
  }

  Future<void> getBudget() async {
    var url = Uri.parse("$baseUrl/app/calculator");

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('tokenDB');
      if (token == null) {
        throw Exception("No token found in SharedPreferences");
      }
      final http.Response response = await http.get(
        url,
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final Map<String, dynamic> dataResponse = data["data"];
        otherWages.value = dataResponse['other_income'] == '0'
            ? ''
            : dataResponse["other_income"].toString();
        rainyDays.value = dataResponse['extra_save'] == '0'
            ? ''
            : dataResponse["extra_save"].toString();
        savings.value = dataResponse['periodic_savings'].toString();
        education.value = dataResponse['education'].toString();
        mortgage.value = dataResponse['mortgage'].toString();
        mobility.value = dataResponse['mobility'].toString();
        expenses.value = dataResponse['expenses'].toString();
        utility.value = dataResponse['utility'].toString();
        debtRepay.value = dataResponse['dept_repay'].toString();
        charity.value = dataResponse['charity'].toString();
        selectedCurrency.value = dataResponse['currency'];
      } else {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Error: ${response.statusCode}');
        print('Response Body: ${data['errors']}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  Future<void> submitPortfolio(
    String currency,
    String savings,
    String education,
    String mortgage,
    String mobility,
    String expenses,
    String utility,
    String debtRepay,
    String charity,
    String rainyDays,
    String otherWages,
  ) async {
    if (rainyDays.isEmpty) rainyDays = '0';
    if (otherWages.isEmpty) otherWages = '0';

    var url = Uri.parse("$baseUrl/app/calculator/portfolio");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    Map<String, dynamic> body = {
      "other_income": otherWages,
      "extra_save": rainyDays,
    };
    final response = await http.post(
      url,
      headers: {
        "Authorization": 'Bearer $token',
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: body,
    );
    print("body:$body");
    print('resRegPortfolio:${response.statusCode}');
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      print('resResponseSaving_income:${data['data']}');
    } else {
      Map<String, dynamic> data = jsonDecode(response.body);
      print('resResponse:${data['data']}');
    }
  }
}
