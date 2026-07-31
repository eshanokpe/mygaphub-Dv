import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider with ChangeNotifier {
  String _baseCurrency = '';
  bool _isLoading = false;

  String get baseCurrency => _baseCurrency;
  bool get isLoading => _isLoading;

  // Fetch the base currency from the API
  Future<void> fetchBaseCurrency() async {
    try {
      _isLoading = true;
      notifyListeners();

      var url = Uri.parse("$baseUrl/app/settings");
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      final response = await http.get(
        url,
        headers: {
          "Authorization": 'Bearer $token',
          "Content-Type": 'application/json',
        },
      ); 
      final body = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        _baseCurrency = body['data']['preferences']['preferred_currency'] ?? '';
        notifyListeners();
      } else {
        throw Exception('Failed to load base currency');
      }
    } catch (e) {
      print('Error fetching base currency: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // This method can be used to update the base currency directly
  void setBaseCurrency(String newCurrency) { 
    _baseCurrency = newCurrency;
    notifyListeners(); 
  } 
}
