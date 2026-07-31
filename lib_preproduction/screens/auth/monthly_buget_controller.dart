import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/provider/providers.dart';

class MonthlyBudgetController extends GetxController {
  var savings = ''.obs;
  var education = ''.obs;
  var mortgage = ''.obs;
  var mobility = ''.obs;
  var expenses = ''.obs;
  var utility = ''.obs;
  var debtRepay = ''.obs;
  var charity = ''.obs;
  var total = 0.0.obs;
  var selectedCurrency = ''.obs;

  void initializeControllers() {
    final calculatorData = Get.find<Providers>().calculatorData;
    savings.value = calculatorData["periodic_savings"] == '0'
        ? ''
        : calculatorData["periodic_savings"].toString();
    education.value = calculatorData["education"] == '0'
        ? ''
        : calculatorData["education"].toString();
    mortgage.value = calculatorData["mortgage"] == '0'
        ? ''
        : calculatorData["mortgage"].toString();
    mobility.value = calculatorData["mobility"] == '0'
        ? ''
        : calculatorData["mobility"].toString();
    expenses.value = calculatorData["expenses"] == '0'
        ? ''
        : calculatorData["expenses"].toString();
    utility.value = calculatorData["utility"] == '0'
        ? ''
        : calculatorData["utility"].toString();
    debtRepay.value = calculatorData["dept_repay"] == '0'
        ? ''
        : calculatorData["dept_repay"].toString();
    charity.value = calculatorData["charity"] == '0'
        ? ''
        : calculatorData["charity"].toString();
  }

  void calculateTotal() {
    total.value =
        (double.tryParse(savings.value) ?? 0) +
        (double.tryParse(education.value) ?? 0) +
        (double.tryParse(mortgage.value) ?? 0) +
        (double.tryParse(mobility.value) ?? 0) +
        (double.tryParse(expenses.value) ?? 0) +
        (double.tryParse(utility.value) ?? 0) +
        (double.tryParse(debtRepay.value) ?? 0) +
        (double.tryParse(charity.value) ?? 0);
  }

  Future<void> submitBudget() async {
    var url = Uri.parse("$baseUrl/app/calculator/budget");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    final calculatorData = Get.find<Providers>().calculatorData;

    Map<String, dynamic> body = {
      "currency": selectedCurrency.value,
      "periodic_savings": savings.value.isEmpty ? '0' : savings.value,
      "education": education.value.isEmpty ? '0' : education.value,
      "mortgage": mortgage.value.isEmpty ? '0' : mortgage.value,
      "mobility": mobility.value.isEmpty ? '0' : mobility.value,
      "expenses": expenses.value.isEmpty ? '0' : expenses.value,
      "utility": utility.value.isEmpty ? '0' : utility.value,
      "dept_repay": debtRepay.value.isEmpty ? '0' : debtRepay.value,
      "charity": charity.value.isEmpty ? '0' : charity.value,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        print('Success: ${data['data']}');
      } else {
        Map<String, dynamic> data = jsonDecode(response.body);
        print('Error: ${data['errors']['currency']}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
