import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/utils/constants.dart';

class CashState {
  final dynamic cashData;
  final dynamic cashDetail; // The "Lite" version with sums
  final bool loading;
  final String? error;

  const CashState({
    this.cashData,
    this.cashDetail,
    this.loading = false,
    this.error,
  });

  CashState copyWith({
    dynamic cashData,
    dynamic cashDetail,
    bool? loading,
    String? error,
  }) {
    return CashState(
      cashData: cashData ?? this.cashData,
      cashDetail: cashDetail ?? this.cashDetail,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class CashNotifier extends StateNotifier<CashState> {
  CashNotifier({http.Client? httpClient, required this.ref})
    : _http = httpClient ?? http.Client(),
      super(const CashState());

  final http.Client _http;
  final Ref ref;

  Future<void> refreshCash() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      final response = await _http.get(
        Uri.parse('$baseUrl/app/360/cash'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) throw Exception('Failed to load cash');

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body["data"] as Map<String, dynamic>?;

      state = state.copyWith(
        cashData: data?['cash'],
        cashDetail: data?['cash_detail'],
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

final cashProvider = StateNotifierProvider<CashNotifier, CashState>((ref) {
  return CashNotifier(ref: ref);
});
