import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/utils/constants.dart';

class PensionState {
  final dynamic pensionData;
  final dynamic pensionDetail; // Contains the sum
  final bool loading;
  final String? error;

  const PensionState({
    this.pensionData,
    this.pensionDetail,
    this.loading = false,
    this.error,
  });

  PensionState copyWith({
    dynamic pensionData,
    dynamic pensionDetail,
    bool? loading,
    String? error,
  }) {
    return PensionState(
      pensionData: pensionData ?? this.pensionData,
      pensionDetail: pensionDetail ?? this.pensionDetail,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class PensionNotifier extends StateNotifier<PensionState> {
  PensionNotifier({http.Client? httpClient, required this.ref})
    : _http = httpClient ?? http.Client(),
      super(const PensionState());

  final http.Client _http;
  final Ref ref;

  Future<void> refreshPensions() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      final response = await _http.get(
        Uri.parse('$baseUrl/app/360/retirement'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200)
        throw Exception('Failed to load pensions');

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body["data"] as Map<String, dynamic>?;

      state = state.copyWith(
        pensionData: data,
        pensionDetail: data?['retirement_detail'],
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

final pensionProvider = StateNotifierProvider<PensionNotifier, PensionState>((
  ref,
) {
  return PensionNotifier(ref: ref);
});
