import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/utils/constants.dart';

class InvestmentState {
  final num investmentSum;
  final dynamic braidTable;
  final dynamic investmentData; // The full raw data if needed elsewhere
  final bool loading;
  final String? error;

  const InvestmentState({
    this.investmentSum = 0,
    this.braidTable,
    this.investmentData,
    this.loading = false,
    this.error,
  });

  InvestmentState copyWith({
    num? investmentSum,
    dynamic braidTable,
    dynamic investmentData,
    bool? loading,
    String? error,
  }) {
    return InvestmentState(
      investmentSum: investmentSum ?? this.investmentSum,
      braidTable: braidTable ?? this.braidTable,
      investmentData: investmentData ?? this.investmentData,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class InvestmentNotifier extends StateNotifier<InvestmentState> {
  InvestmentNotifier({http.Client? httpClient, required this.ref})
    : _http = httpClient ?? http.Client(),
      super(const InvestmentState());

  final http.Client _http;
  final Ref ref;

  Future<void> refreshInvestments() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      final response = await _http.get(
        Uri.parse('$baseUrl/app/360/investment'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load investments: ${response.statusCode}');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body["data"] as Map<String, dynamic>?;

      state = state.copyWith(
        investmentSum: data?['investment_sum'] ?? 0,
        braidTable: data?['braid_table'],
        investmentData: data,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

final investmentProvider =
    StateNotifierProvider<InvestmentNotifier, InvestmentState>((ref) {
      return InvestmentNotifier(ref: ref);
    });
