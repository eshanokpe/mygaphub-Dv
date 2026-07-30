import 'dart:convert';
import 'package:GapHub/models/FinancialHubModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/marketPlace.dart';
import '../utils/constants.dart';

class MarketOpportunitiesProvider with ChangeNotifier {
  List<MarketOpportunity> _marketOpportunities = [];
  List<FinancialHubModel> _financialHubModel = [];

  List<MarketOpportunity> get marketOpportunities => _marketOpportunities;
  List<FinancialHubModel> get financialHubModel => _financialHubModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchMarketOpportunities() async {
    final url = Uri.parse("$baseUrl/app/product/market-opportunities");
    final prefs = await SharedPreferences.getInstance();
    var finalToken = prefs.getString('tokenDB');

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": 'Bearer $finalToken'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true && data['data'] is List) {
          _marketOpportunities = (data['data'] as List)
              .map((item) => MarketOpportunity.fromJson(item))
              .toList();
        }
      } else {
        throw Exception("Failed to load market opportunities");
      }
    } catch (e) {
      print("Error fetching market opportunities: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFinancialIntelligenceHub() async {
    final url = Uri.parse("$baseUrl/app/product/finacial-hub");
    final prefs = await SharedPreferences.getInstance();
    var finalToken = prefs.getString('tokenDB');

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": 'Bearer $finalToken'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true && data['data'] is List) {
          _financialHubModel = (data['data'] as List)
              .map((item) => FinancialHubModel.fromJson(item))
              .toList();
        }
      } else {
        throw Exception("Failed to load market opportunities");
      }
    } catch (e) {
      print("Error fetching market opportunities: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



}
