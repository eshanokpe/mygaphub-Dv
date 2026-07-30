import 'dart:convert';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class LifeInsuranceFormState {
  final String provider;
  final String providerContact;
  final String? protectionType;
  final String protectionDetails;
  final String bank;
  final String? currency;
  final String? currencyDisplay;
  final String? displayCurrency;
  final String sumAssured;
  final String premium;
  final String? paymentFrequency;
  final String? paymentType;
  final DateTime? coverStart;
  final DateTime? coverEnd;
  final bool isEndDateExpanded;
  final String? documentPath;
  final String? existingDocumentUrl;
  final bool isDateExpanded;
  final bool isSubmitting;
  final bool removeDocument;

  const LifeInsuranceFormState({
    this.provider = '',
    this.providerContact = '',
    this.protectionType,
    this.protectionDetails = '',
    this.bank = '',
    this.currency,
    this.currencyDisplay,
    this.displayCurrency,
    this.sumAssured = '0',
    this.premium = '0',
    this.paymentFrequency,
    this.paymentType,
    this.coverStart,
    this.coverEnd,
    this.isEndDateExpanded = false,
    this.documentPath,
    this.existingDocumentUrl,
    this.isDateExpanded = false,
    this.isSubmitting = false,
    this.removeDocument = false,
  });
}

class SubmitResult {
  final bool success;
  final String? errorMessage;

  const SubmitResult({required this.success, this.errorMessage});
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class LifeInsuranceFormNotifier extends StateNotifier<LifeInsuranceFormState> {
  final Providers _providers;
  final Dio _dio = Dio();
  bool _editLoaded = false;

  LifeInsuranceFormNotifier(this._providers)
    : super(const LifeInsuranceFormState());

  static const _keep = Object();

  // ── Internal copy-with helper ─────────────────────────────────────────────

  LifeInsuranceFormState _s({
    String? provider,
    String? providerContact,
    Object? protectionType = _keep,
    String? protectionDetails,
    String? bank,
    Object? currency = _keep,
    Object? currencyDisplay = _keep,
    Object? displayCurrency = _keep,
    String? sumAssured,
    String? premium,
    Object? paymentFrequency = _keep,
    Object? paymentType = _keep,
    Object? coverStart = _keep,
    Object? coverEnd = _keep,
    bool? isEndDateExpanded,
    Object? documentPath = _keep,
    Object? existingDocumentUrl = _keep,
    bool? isDateExpanded,
    bool? isSubmitting,
    bool? removeDocument,
  }) {
    return LifeInsuranceFormState(
      provider: provider ?? state.provider,
      providerContact: providerContact ?? state.providerContact,
      protectionType: protectionType == _keep
          ? state.protectionType
          : protectionType as String?,
      protectionDetails: protectionDetails ?? state.protectionDetails,
      bank: bank ?? state.bank,
      currency: currency == _keep ? state.currency : currency as String?,
      currencyDisplay: currencyDisplay == _keep
          ? state.currencyDisplay
          : currencyDisplay as String?,
      displayCurrency:
          displayCurrency ==
              _keep // ← add this
          ? state.displayCurrency
          : displayCurrency as String?,
      sumAssured: sumAssured ?? state.sumAssured,
      premium: premium ?? state.premium,
      paymentFrequency: paymentFrequency == _keep
          ? state.paymentFrequency
          : paymentFrequency as String?,
      paymentType: paymentType == _keep
          ? state.paymentType
          : paymentType as String?,
      coverStart: coverStart == _keep
          ? state.coverStart
          : coverStart as DateTime?,
      coverEnd: coverEnd == _keep ? state.coverEnd : coverEnd as DateTime?,
      isEndDateExpanded: isEndDateExpanded ?? state.isEndDateExpanded,
      documentPath: documentPath == _keep
          ? state.documentPath
          : documentPath as String?,
      existingDocumentUrl: existingDocumentUrl == _keep
          ? state.existingDocumentUrl
          : existingDocumentUrl as String?,
      isDateExpanded: isDateExpanded ?? state.isDateExpanded,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      removeDocument: removeDocument ?? state.removeDocument,
    );
  }

  // ── Field setters ─────────────────────────────────────────────────────────

  void setProvider(String value) => state = _s(provider: value);
  void setProviderContact(String value) => state = _s(providerContact: value);
  void setProtectionType(String? value) => state = _s(protectionType: value);
  void setProtectionDetails(String value) =>
      state = _s(protectionDetails: value);
  void setBank(String value) => state = _s(bank: value);
  void setCurrency(
    String? symbolOnly,
    String? displayCurrency, {
    String? displayText,
  }) {
    state = _s(
      currency: symbolOnly,
      currencyDisplay: displayText,
      displayCurrency: displayCurrency,
    );
  }

  void setSumAssured(String value) => state = _s(sumAssured: value);
  void setPremium(String value) => state = _s(premium: value);
  void setPaymentFrequency(String? value) =>
      state = _s(paymentFrequency: value);
  void setPaymentType(String? value) => state = _s(paymentType: value);

  void setDocumentPath(String? value) {
    state = _s(documentPath: value, removeDocument: false);
  }

  void removeExistingDocument() {
    state = _s(
      documentPath: null,
      existingDocumentUrl: null,
      removeDocument: true,
    );
  }

  void setCoverStart(DateTime? value) =>
      state = _s(coverStart: value, isDateExpanded: false);

  void toggleDateExpanded() =>
      state = _s(isDateExpanded: !state.isDateExpanded);

  void setCoverEnd(DateTime? value) =>
      state = _s(coverEnd: value, isEndDateExpanded: false);

  void toggleEndDateExpanded() =>
      state = _s(isEndDateExpanded: !state.isEndDateExpanded);

  // ── Pre-populate for edit ─────────────────────────────────────────────────

  void loadForEdit({
    required String provider,
    required String providerContact,
    required String? protectionType,
    required String protectionDetails,
    required String bank,
    required String? currency,
    required String sumAssured,
    required String premium,
    required String? paymentFrequency,
    required String? paymentType,
    required DateTime? coverStart,
    required DateTime? coverEnd,
    String? existingDocumentUrl,
  }) {
    if (_editLoaded) return;
    _editLoaded = true;
    state = LifeInsuranceFormState(
      provider: provider,
      providerContact: providerContact,
      protectionType: protectionType,
      protectionDetails: protectionDetails,
      bank: bank,
      currency: currency,
      sumAssured: sumAssured,
      premium: premium,
      paymentFrequency: paymentFrequency,
      paymentType: paymentType,
      coverStart: coverStart,
      coverEnd: coverEnd,
      existingDocumentUrl: existingDocumentUrl,
      documentPath: null,
      removeDocument: false,
    );
  }

  // ── Helper Methods ────────────────────────────────────────────────────────

  Map<String, String> _getHeaders(String token) {
    return {'Authorization': 'Bearer $token', 'Accept': 'application/json'};
  }

  dynamic _extractData(dynamic response) {
    return response is Map ? response['data'] : null;
  }

  Map<String, dynamic> _parseDioResponse(dynamic data) {
    try {
      if (data is String) {
        return jsonDecode(data) as Map<String, dynamic>;
      } else if (data is Map) {
        return Map<String, dynamic>.from(data);
      } else if (data is List) {
        return {'protection': data};
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  List<dynamic> _getSafeList(Map<String, dynamic> map, String key) {
    final value = map[key];
    return value is List ? value : [];
  }

  Map<dynamic, dynamic> _getSafeMapOrEmpty(
    Map<String, dynamic> map,
    String key,
  ) {
    final value = map[key];
    return value is Map ? value : <dynamic, dynamic>{};
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  MediaType _contentType(String path) {
    final lowerPath = path.toLowerCase();
    if (lowerPath.endsWith('.pdf')) return MediaType('application', 'pdf');
    if (lowerPath.endsWith('.doc')) return MediaType('application', 'msword');
    if (lowerPath.endsWith('.docx')) {
      return MediaType(
        'application',
        'vnd.openxmlformats-officedocument.wordprocessingml.document',
      );
    }
    return MediaType('application', 'octet-stream');
  }

  Future<void> _refreshProtectionData(String token, {String? period}) async {
    try {
      final url = (period != null && period.isNotEmpty)
          ? "$baseUrl/app/360/protection?period=$period"
          : "$baseUrl/app/360/protection";

      final response = await _dio.get(
        url,
        options: Options(headers: _getHeaders(token)),
      );

      final parsedResponse = _parseDioResponse(response.data);
      final protectionData =
          parsedResponse['data'] as Map<String, dynamic>? ?? {};

      final protectionList = _getSafeList(protectionData, 'protection');
      final protectionDetail = _getSafeMapOrEmpty(
        protectionData,
        'protection_detail',
      );
      final protectionDistribution =
          protectionData['protection_distribution'] ?? [];

      _providers
        ..setProtectionList(protectionList)
        ..setProtectionListLite(protectionDetail)
        ..setProtectionDistribution(protectionDistribution);
    } catch (e) {
      debugPrint('Protection data refresh error: $e');
    }
  }

  Future<void> _refreshTilesData(String token) async {
    try {
      final tilesResponse = await _dio.get(
        "$baseUrl/app/360/tiles",
        options: Options(headers: _getHeaders(token)),
      );

      Map<String, dynamic> tilesData;
      if (tilesResponse.data is String) {
        tilesData =
            jsonDecode(tilesResponse.data as String) as Map<String, dynamic>;
      } else {
        tilesData = Map<String, dynamic>.from(tilesResponse.data ?? {});
      }

      if (tilesData['tiles'] != null) {
        _providers.setRecent(tilesData['tiles'] as List? ?? []);
      }
    } catch (e) {
      debugPrint('Tiles fetch error: $e');
    }
  }

  // ── Update method ────────────────────────────────────────────────────────
  Future<SubmitResult> update({
    required String? productTitle,
    required String protectionId,
  }) async {
    if (state.isSubmitting) return const SubmitResult(success: false);
    if (protectionId.trim().isEmpty) {
      return const SubmitResult(
        success: false,
        errorMessage: 'Missing record ID. Cannot update.',
      );
    }

    if (!mounted) return const SubmitResult(success: false);
    state = _s(isSubmitting: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null || token.isEmpty) {
        return const SubmitResult(
          success: false,
          errorMessage: 'Session expired. Please log in again.',
        );
      }

      final url = Uri.parse("$baseUrl/app/360/protection/$protectionId");

      const validTypes = [
        'Whole of Life',
        'Term Assurance',
        'Endowment Policy',
        'Annuity Plan',
        'Comprehensive Cover',
        'Gadget/Device Protection',
        'Third Party Cover',
        'Others',
      ];
      String protectionType = state.protectionType ?? '';
      if (!validTypes.contains(protectionType.trim()))
        protectionType = 'Others';

      String payFreq = (state.paymentFrequency ?? '').toLowerCase().trim();
      if (!['monthly', 'annually'].contains(payFreq)) payFreq = 'monthly';

      debugPrint("payFreq: $payFreq");

      final request = http.MultipartRequest('PUT', url)
        ..fields['_method'] = 'PUT'
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json'
        ..fields['type'] = protectionType
        ..fields['provider_policy'] = state.provider.trim()
        ..fields['contact'] = state.providerContact.trim()
        ..fields['details'] = state.protectionDetails.trim().isNotEmpty
            ? state.protectionDetails.trim()
            : 'Not specified'
        ..fields['bank'] = state.bank.trim()
        ..fields['currency'] = state.currencyDisplay?.trim() ?? ''
        ..fields['sum_assured'] = state.sumAssured.trim()
        ..fields['premium_pay'] = state.premium.trim()
        ..fields['pay_freq'] = payFreq
        ..fields['pay_type'] = state.paymentType?.trim() ?? ''
        ..fields['cover_start'] = state.coverStart != null
            ? _formatDate(state.coverStart!)
            : ''
        ..fields['cover_end'] = _formatDate(state.coverEnd ?? DateTime.now());

      if (state.removeDocument) {
        request.fields['remove_document'] = '1';
      } else if (state.documentPath != null && state.documentPath!.isNotEmpty) {
        try {
          final file = await http.MultipartFile.fromPath(
            'document',
            state.documentPath!,
            contentType: _contentType(state.documentPath!),
          );
          request.files.add(file);
        } catch (e) {
          debugPrint('>>> Error preparing document: $e');
        }
      } else {
        debugPrint('>>> No document change — keeping existing file');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.body.isEmpty) {
        return const SubmitResult(
          success: false,
          errorMessage: 'Server returned empty response',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (body['data'] != null) {
          final data = body['data'] as Map<String, dynamic>;
          if (data['protection'] != null) {
            final updated = data['protection'] as Map<String, dynamic>;
            final updatedId = updated['id']?.toString();
            final newList = _providers.protectionList.map((existing) {
              return existing['id']?.toString() == updatedId
                  ? updated
                  : existing;
            }).toList();
            _providers.setProtectionList(newList);
          }
          if (data['protection_detail'] != null) {
            final detailData = data['protection_detail'];
            _providers.setProtectionListLite(
              detailData is Map ? detailData : <dynamic, dynamic>{},
            );
          }
        }

        await _refreshTilesData(token);
        await _refreshProtectionData(token);

        return const SubmitResult(success: true);
      }

      return SubmitResult(
        success: false,
        errorMessage:
            body['message'] as String? ?? 'Failed to update. Please try again.',
      );
    } catch (e, stack) {
      debugPrint('Exception in update: $e\n$stack');
      return const SubmitResult(
        success: false,
        errorMessage: 'Network error. Please check your connection.',
      );
    } finally {
      if (mounted) {
        state = _s(isSubmitting: false);
      }
    }
  }

  // ── Submit method ────────────────────────────────────────────────────────

  Future<SubmitResult> submit(String? productTitle) async {
    if (state.isSubmitting) return const SubmitResult(success: false);
    if (!mounted) return const SubmitResult(success: false);
    state = _s(isSubmitting: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null || token.isEmpty) {
        return const SubmitResult(
          success: false,
          errorMessage: 'Session expired. Please log in again.',
        );
      }

      final url = Uri.parse("$baseUrl/app/360/protection");
      print("currecny : ${state.displayCurrency?.trim()}");

      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json'
        ..fields['category'] = productTitle?.trim() ?? ''
        ..fields['type'] = state.protectionType?.trim() ?? ''
        ..fields['provider_policy'] = state.provider.trim()
        ..fields['policy'] = state.provider.trim()
        ..fields['provider_contact'] = state.providerContact.trim()
        ..fields['contact'] = state.providerContact.trim()
        ..fields['details'] = state.protectionDetails.trim()
        ..fields['bank'] = state.bank.trim()
        ..fields['currency'] = state.currencyDisplay?.trim() ?? ''
        ..fields['sum_assured'] = state.sumAssured.trim()
        ..fields['premium_pay'] = state.premium.trim()
        ..fields['premium'] = state.premium.trim()
        ..fields['pay_freq'] =
            state.paymentFrequency?.toLowerCase().trim() ?? ''
        ..fields['pay_frequency'] =
            state.paymentFrequency?.toLowerCase().trim() ?? ''
        ..fields['pay_type'] = state.paymentType?.trim() ?? ''
        ..fields['cover_start'] = state.coverStart != null
            ? _formatDate(state.coverStart!)
            : ''
        ..fields['cover_end'] = _formatDate(state.coverEnd ?? DateTime.now());

      if (state.documentPath != null && state.documentPath!.isNotEmpty) {
        try {
          final file = await http.MultipartFile.fromPath(
            'document',
            state.documentPath!,
            contentType: _contentType(state.documentPath!),
          );
          request.files.add(file);
        } catch (e) {
          debugPrint('>>> Error preparing document: $e');
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.body.isEmpty) {
        return const SubmitResult(
          success: false,
          errorMessage: 'Server returned empty response',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (body['data'] != null) {
          final data = body['data'] as Map<String, dynamic>;
          if (data['protection'] != null) {
            final newItem = data['protection'] as Map<String, dynamic>;
            final updatedList = [newItem, ..._providers.protectionList];
            _providers.setProtectionList(updatedList);
          }
          if (data['protection_detail'] != null) {
            final detailData = data['protection_detail'];
            _providers.setProtectionListLite(
              detailData is Map ? detailData : <dynamic, dynamic>{},
            );
          }
        }

        await _refreshProtectionData(token);
        await _refreshTilesData(token);

        return const SubmitResult(success: true);
      }

      return SubmitResult(
        success: false,
        errorMessage:
            body['message'] as String? ?? 'Failed to submit. Please try again.',
      );
    } catch (e, stack) {
      debugPrint('Exception in submit: $e\n$stack');
      return const SubmitResult(
        success: false,
        errorMessage: 'Network error. Please check your connection.',
      );
    } finally {
      if (mounted) {
        state = _s(isSubmitting: false);
      }
    }
  }

  // ── Fetch Protection Data by Period ──────────────────────────────────────

  Future<void> fetchProtectionDataByPeriod(String period) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null || token.isEmpty) {
        throw Exception("Session expired. Please log in again.");
      }

      await _refreshProtectionData(token, period: period);
    } catch (e) {
      debugPrint('fetchProtectionDataByPeriod error: $e');
      rethrow;
    }
  }

  /// Reset controller state
  void reset() {
    _editLoaded = false;
    state = const LifeInsuranceFormState();
  }
}
