import 'dart:convert';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EquityState {
  final dynamic equityData; // 'equity' from the API
  final dynamic equityDetail; // 'equity_detail' from the API
  final bool loading;
  final String? error;

  const EquityState({
    this.equityData,
    this.equityDetail,
    this.loading = false,
    this.error,
  });

  EquityState copyWith({
    dynamic equityData,
    dynamic equityDetail,
    bool? loading,
    String? error,
  }) {
    return EquityState(
      equityData: equityData ?? this.equityData,
      equityDetail: equityDetail ?? this.equityDetail,
      loading: loading ?? this.loading,
      // error is intentionally nullable & reset on every explicit copyWith
      // call that doesn't re-supply it, so stale errors don't linger.
      error: error,
    );
  }

  /// Convenience empty check
  bool get isEmpty =>
      equityDetail == null || (equityDetail is Map && equityDetail.isEmpty);
}

class EquityNotifier extends StateNotifier<EquityState> {
  // ✅ FIXED: Inject 'ref' to allow access to other Riverpod providers if needed
  EquityNotifier({http.Client? httpClient, required this.ref})
    : _http = httpClient ?? http.Client(),
      super(const EquityState());

  final http.Client _http;
  final Ref ref;

  Future<bool> refreshEquity() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');
      final url = Uri.parse('$baseUrl/app/360/equity');

      final response = await _http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        state = state.copyWith(
          loading: false,
          error: 'Failed to refresh equity (${response.statusCode})',
        );
        return false;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body["data"] as Map<String, dynamic>?;

      // ✅ FIXED: Update THIS notifier's state directly.
      // No need to call a legacy Provider class from inside here.
      state = state.copyWith(
        equityData: data?['equity'] ?? [],
        equityDetail: data?['equity_detail'] ?? {},
        loading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  void reset() => state = const EquityState();
}

// ✅ FIXED: Pass 'ref' to the notifier
final equityProvider = StateNotifierProvider<EquityNotifier, EquityState>((
  ref,
) {
  return EquityNotifier(ref: ref);
});
