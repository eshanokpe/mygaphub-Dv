import 'dart:async';
import 'package:GapHub/models/propertyModel.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:GapHub/utils/constants.dart';
import 'package:dio/dio.dart';

import '../provider/pension_provider.dart';

class PensionFormController extends StateNotifier<PensionFormState> {
  final Providers providers;
  final Dio _dio = Dio();

  PensionFormController(this.providers, Map<String, dynamic>? existingData)
    : super(const PensionFormState()) {
    if (existingData != null) {
      state = state.copyWith(
        planName: existingData['name']?.toString() ?? '',
        providerName: existingData['provider']?.toString() ?? '',
        currentBalance: existingData['current']?.toString() ?? '0',
        monthlyContribution:
            existingData['monthly_contribution']?.toString() ?? '0',
        retirementAge: existingData['retirement_age']?.toString() ?? '50',
      );
    }
  }

  void setPlanType(String value) => state = state.copyWith(planType: value);
  void setPlanName(String value) => state = state.copyWith(planName: value);
  void setProviderName(String value) =>
      state = state.copyWith(providerName: value);
  void setCurrentBalance(String value) =>
      state = state.copyWith(currentBalance: value);
  void setMonthlyContribution(String value) =>
      state = state.copyWith(monthlyContribution: value);
  void setRetirementAge(String value) =>
      state = state.copyWith(retirementAge: value);

  void reset() {
    state = const PensionFormState();
  }

  // ------------------------------------------------------------------
  // Safe helper: only assigns `state` if this StateNotifier hasn't been
  // disposed. Assigning to `state` on a disposed StateNotifier throws,
  // so every `state = ...` in submit()/update() should go through this
  // instead of being gated directly in the calling code.
  // ------------------------------------------------------------------
  void _safeSetState(PensionFormState Function(PensionFormState) updater) {
    if (mounted) {
      state = updater(state);
    }
  }

  // ✅ SUBMIT METHOD (For New Pensions)
  //
  // IMPORTANT: `mounted` here only tells us whether it's SAFE to write to
  // `state` (a disposed StateNotifier throws if you assign to `state`).
  // It does NOT tell us whether the network operation succeeded. We must
  // never let "the controller got disposed after the request finished"
  // downgrade a real success into a reported failure — otherwise the
  // caller (the widget) never gets to show the SuccessModal even though
  // the pension WAS saved on the server.
  //
  // So: track `wasSuccessful` locally from the actual HTTP result, and
  // return based on that — using `mounted`/`_safeSetState` only to guard
  // the `state = ...` writes, never to decide the return value.
  Future<({bool success, String? errorMessage})> submit(
    String? title,
    String? projectedIncome,
  ) async {
    bool wasSuccessful = false;
    String? errorMsg;

    _safeSetState(
      (s) => s.copyWith(isSubmitting: true, success: false, errorMessage: null),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');
      if (token == null || token.isEmpty) {
        throw Exception("Authentication token not found");
      }

      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };

      final url = Uri.parse("$baseUrl/app/360/retirement");
      final payload = {
        "pension_type": title ?? "pension",
        "pension_name": state.planName.trim(),
        "pension_provider": state.providerName.trim(),
        "monthly_cont": _parseDouble(state.monthlyContribution),
        "current": _parseDouble(state.currentBalance) ?? 0,
        "assured_income": projectedIncome,
        "retire_age": _parseInt(state.retirementAge) ?? 0,
      };

      final responsePost = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      if (responsePost.statusCode < 200 || responsePost.statusCode >= 300) {
        final responseData = jsonDecode(responsePost.body);
        throw Exception(responseData['message'] ?? "Failed to save");
      }

      // The save itself succeeded — lock this in regardless of what
      // happens with the controller/state afterwards.
      wasSuccessful = true;

      // Best-effort cache refresh. If this throws, we still report the
      // original save as successful (see catch block below).
      await _refreshRetirementData(headers);

      _safeSetState((s) => s.copyWith(isSubmitting: false, success: true));

      return (success: true, errorMessage: null);
    } catch (e) {
      errorMsg = e.toString().replaceAll("Exception: ", "").replaceAll('"', '');

      _safeSetState(
        (s) => s.copyWith(
          isSubmitting: false,
          success: wasSuccessful,
          errorMessage: wasSuccessful ? null : errorMsg,
        ),
      );

      // If the save already succeeded before something else (e.g. the
      // refresh call, or disposal) threw, still report success to the
      // caller so the SuccessModal shows.
      return (
        success: wasSuccessful,
        errorMessage: wasSuccessful ? null : errorMsg,
      );
    }
  }

  // ✅ UPDATE METHOD (For Editing Existing Pensions)
  // Same principle as submit(): only `mounted` gates state writes, never
  // the returned result.
  Future<({bool success, String? errorMessage})> update(
    dynamic recordId,
    String? projectedIncome,
  ) async {
    bool wasSuccessful = false;
    String? errorMsg;

    _safeSetState(
      (s) => s.copyWith(isSubmitting: true, success: false, errorMessage: null),
    );

    try {
      if (recordId == null || recordId.toString().isEmpty) {
        throw Exception("Record ID missing");
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');
      if (token == null || token.isEmpty) {
        throw Exception("Authentication token not found");
      }

      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };

      final url = Uri.parse("$baseUrl/app/360/retirement/$recordId");
      final payload = {
        "pension_name": state.planName.trim(),
        "provider": state.providerName.trim(),
        "monthly": _parseDouble(state.monthlyContribution),
        "current": _parseDouble(state.currentBalance) ?? 0,
        "assured_income": projectedIncome ?? state.projectedYearlyIncome,
        "retirement": _parseInt(state.retirementAge) ?? 0,
        "retire_age": _parseInt(state.retirementAge) ?? 0,
      };

      final responsePut = await http.put(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      if (responsePut.statusCode < 200 || responsePut.statusCode >= 300) {
        final responseData = jsonDecode(responsePut.body);
        throw Exception(responseData['message'] ?? "Failed to update");
      }

      wasSuccessful = true;

      await _refreshRetirementData(headers);

      _safeSetState((s) => s.copyWith(isSubmitting: false, success: true));

      return (success: true, errorMessage: null);
    } catch (e) {
      errorMsg = e.toString().replaceAll("Exception: ", "").replaceAll('"', '');

      _safeSetState(
        (s) => s.copyWith(
          isSubmitting: false,
          success: wasSuccessful,
          errorMessage: wasSuccessful ? null : errorMsg,
        ),
      );

      return (
        success: wasSuccessful,
        errorMessage: wasSuccessful ? null : errorMsg,
      );
    }
  }

  // ------------------------------
  // ✅ fetchProperties
  // ------------------------------
  Future<List<PropertyModel>> fetchProperties() async {
    debugPrint('🔄 Fetching properties...');
    final client = HttpClient();

    try {
      final uri = Uri.parse('$assetBaseUrl/property-listing');
      debugPrint('🌐 URL: $uri');

      final request = await client.getUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');

      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      debugPrint('📥 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final body = jsonDecode(responseBody);

        final List<PropertyModel> loadedProperties = [];
        if (body['properties_list'] != null) {
          for (var propertyJson in body['properties_list']) {
            try {
              loadedProperties.add(PropertyModel.fromJson(propertyJson));
            } catch (e) {
              debugPrint('⚠️ Parse skip: $e');
            }
          }
        }

        debugPrint('✅ Loaded ${loadedProperties.length} properties');
        return loadedProperties;
      } else {
        debugPrint('❌ Failed: ${response.statusCode}');
        return [];
      }
    } on TimeoutException {
      debugPrint('❌ Timeout');
      return [];
    } on SocketException catch (e) {
      debugPrint('❌ Network: $e');
      return [];
    } catch (e) {
      debugPrint('❌ Error: $e');
      return [];
    } finally {
      client.close();
    }
  }

  Future<void> _refreshRetirementData(Map<String, String> headers) async {
    try {
      final results = await Future.wait([
        _dio.get(
          '$baseUrl/app/360/retirement/roi',
          options: Options(headers: headers),
        ),
        _dio.get(
          '$baseUrl/app/360/retirement?archive=0',
          options: Options(headers: headers),
        ),
      ]);
      if (results[0].statusCode == 200 && results[1].statusCode == 200) {
        final roiData = results[0].data['data'] as Map? ?? {};
        final retirementData = results[1].data['data'] as Map? ?? {};

        providers
          ..setretiredata(roiData)
          ..setpensions(retirementData);
        debugPrint("✅ Retirement data refreshed successfully");
      }
    } catch (e) {
      // Deliberately swallowed: a failed cache refresh should never
      // cause the calling submit()/update() to report failure when the
      // actual save/update already succeeded.
      debugPrint("Refresh error: $e");
    }
  }

  double? _parseDouble(String value) =>
      double.tryParse(value.replaceAll(',', ''));
  int? _parseInt(String value) => int.tryParse(value.replaceAll(',', ''));
}

class RetiredashController extends StateNotifier<RetiredashState> {
  RetiredashController() : super(const RetiredashState(selectedTabIndex: 0));
  void selectTab(int index) {
    if (index != state.selectedTabIndex)
      state = state.copyWith(selectedTabIndex: index);
  }
}
