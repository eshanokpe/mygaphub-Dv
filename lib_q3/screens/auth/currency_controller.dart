import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyController extends GetxController {
  var currencies = <Map<String, dynamic>>[].obs;
  var buttonEnabled = false.obs;
  var dataCurrency = ''.obs;
  var currencySymbol = ''.obs;
  var calculatorData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final Providers providers = Get.put(Providers());
    loadCurrencyData();
    calculatorData.value = Map<String, dynamic>.from(
      providers.calculatorData,
    ); // Explicit cast
    dataCurrency.value = calculatorData.value["currency"];
  }

  Future<void> loadCurrencyData() async {
    try {
      final data = await rootBundle.loadString(
        'assets/currencywithsymbols.json',
      );
      final jsonData = jsonDecode(data) as List;
      currencies.value = jsonData
          .cast<Map<String, dynamic>>()
          .map((currency) => {...currency, 'isSelected': false})
          .toList();
      _selectCurrencyFromData();
    } catch (e) {
      print("Error loading currency data: $e");
    }
  }

  void _selectCurrencyFromData() {
    if (currencies.isNotEmpty) {
      for (int i = 0; i < currencies.length; i++) {
        var symboll = dataCurrency.value.split(" ").toList();
        var symbol = symboll[0];
        if (currencies[i]['symbol'] == symbol) {
          toggleSelection(i);
          break;
        }
      }
    }
  }

  void toggleSelection(int index) {
    for (var currency in currencies) {
      currency['isSelected'] = false;
    }
    currencies[index]['isSelected'] = true;
    currencies.refresh();

    Get.find<Providers>().setSymbol(
      '${currencies[index]['symbol']} ${currencies[index]['code']}',
    );
    buttonEnabled.value = true;
  }

  Future<void> submitBudget(String currencySymbol) async {
    var url = Uri.parse("$baseUrl/app/calculator/budget");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    Map<String, dynamic> body = {
      "currency": currencySymbol,
      "periodic_savings": (calculatorData["periodic_savings"] ?? 0).toString(),
      "education": (calculatorData["education"] ?? 0).toString(),
      "mortgage": (calculatorData["mortgage"] ?? 0).toString(),
      "mobility": (calculatorData["mobility"] ?? 0).toString(),
      "expenses": (calculatorData["expenses"] ?? 0).toString(),
      "utility": (calculatorData["utility"] ?? 0).toString(),
      "dept_repay": (calculatorData["dept_repay"] ?? 0).toString(),
      "charity": (calculatorData["charity"] ?? 0).toString(),
      "extra": (calculatorData["extra"] ?? 0).toString(),
      "extra1": (calculatorData["extra1"] ?? 0).toString(),
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

    if (response.statusCode == 200) {
      final bodyCalculator = jsonDecode(response.body);
      final dataCalculator = bodyCalculator['data'];
      Get.find<Providers>().setCalculator(dataCalculator);
      print('SuccessresReg:$dataCalculator');
    } else {
      print('Eror R:${response.statusCode}');
    }
  }
}
