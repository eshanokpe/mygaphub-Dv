import 'dart:convert';

import 'package:GapHub/provider/providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:GapHub/utils/constants.dart';

import 'dart:convert';

import 'package:GapHub/provider/providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:GapHub/utils/constants.dart';

import 'dart:convert';
import 'package:GapHub/provider/providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/utils/constants.dart';

class HomeEquityFormState {
  final String? id; // Added for updates
  final String mortgageProperty;
  final String mortgageDescription;
  final String mortgageSecured;
  final String mortgageOpeningBalance;
  final String mortgageCurrentBalance;
  final String mortgageInterestRate;
  final String monthlyPayment;
  final String payOffStrategy;
  final String country;
  final String homeAddress;
  final String townCity;
  final String zipcode;
  final String currentValue;
  final String address;
  final String address2;
  final String creditor;

  final DateTime? targetDate; // Payoff Target Date
  final bool isTargetDateExpanded;

  final DateTime?
  dateAcquired; // Date Acquired (Fixed duplicate targetDate bug)
  final bool isDateAcquiredExpanded;

  final List<dynamic> mortgages;
  final List<dynamic> mortgagesList;
  final bool loading;
  final String? error;
  final bool zipVerified;

  const HomeEquityFormState({
    this.id,
    this.mortgageProperty = '-Select-',
    this.mortgageDescription = '-Select-',
    this.mortgageSecured = '-Select-',
    this.mortgageOpeningBalance = '',
    this.mortgageCurrentBalance = '',
    this.mortgageInterestRate = '',
    this.monthlyPayment = '',
    this.payOffStrategy = '',
    this.country = '-Select-',
    this.homeAddress = '',
    this.townCity = '',
    this.zipcode = '',
    this.currentValue = '',
    this.address = '',
    this.address2 = '',
    this.creditor = '',
    this.targetDate,
    this.isTargetDateExpanded = false,
    this.dateAcquired,
    this.isDateAcquiredExpanded = false,
    this.mortgages = const [],
    this.mortgagesList = const [],
    this.loading = false,
    this.error,
    this.zipVerified = false,
  });

  HomeEquityFormState copyWith({
    String? id,
    String? mortgageProperty,
    String? mortgageDescription,
    String? mortgageSecured,
    String? mortgageOpeningBalance,
    String? mortgageCurrentBalance,
    String? mortgageInterestRate,
    String? monthlyPayment,
    String? payOffStrategy,
    String? country,
    String? homeAddress,
    String? townCity,
    String? zipcode,
    String? currentValue,
    String? address,
    String? address2,
    String? creditor,
    DateTime? targetDate,
    bool? isTargetDateExpanded,
    DateTime? dateAcquired,
    bool? isDateAcquiredExpanded,
    List<dynamic>? mortgages,
    List<dynamic>? mortgagesList,
    bool? loading,
    String? error,
    bool? zipVerified,
  }) {
    return HomeEquityFormState(
      id: id ?? this.id,
      mortgageProperty: mortgageProperty ?? this.mortgageProperty,
      mortgageDescription: mortgageDescription ?? this.mortgageDescription,
      mortgageSecured: mortgageSecured ?? this.mortgageSecured,
      mortgageOpeningBalance:
          mortgageOpeningBalance ?? this.mortgageOpeningBalance,
      mortgageCurrentBalance:
          mortgageCurrentBalance ?? this.mortgageCurrentBalance,
      mortgageInterestRate: mortgageInterestRate ?? this.mortgageInterestRate,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      payOffStrategy: payOffStrategy ?? this.payOffStrategy,
      country: country ?? this.country,
      homeAddress: homeAddress ?? this.homeAddress,
      townCity: townCity ?? this.townCity,
      zipcode: zipcode ?? this.zipcode,
      currentValue: currentValue ?? this.currentValue,
      address: address ?? this.address,
      address2: address2 ?? this.address2,
      creditor: creditor ?? this.creditor,
      targetDate: targetDate ?? this.targetDate,
      isTargetDateExpanded: isTargetDateExpanded ?? this.isTargetDateExpanded,
      dateAcquired: dateAcquired ?? this.dateAcquired,
      isDateAcquiredExpanded:
          isDateAcquiredExpanded ?? this.isDateAcquiredExpanded,
      mortgages: mortgages ?? this.mortgages,
      mortgagesList: mortgagesList ?? this.mortgagesList,
      loading: loading ?? this.loading,
      error: error,
      zipVerified: zipVerified ?? this.zipVerified,
    );
  }

  bool get requiresZip =>
      country == 'Canada' ||
      country == 'United States' ||
      country == 'United Kingdom';

  bool get isValid =>
      mortgageProperty != '-Select-' &&
      country != '-Select-' &&
      homeAddress.trim().isNotEmpty &&
      townCity.trim().isNotEmpty &&
      currentValue.trim().isNotEmpty &&
      zipcode.trim().isNotEmpty;

  bool get isSubmitting => loading;
}

class HomeEquitySubmitResult {
  final bool success;
  final String? errorMessage;
  final dynamic equityData;
  final dynamic equityDetail;

  const HomeEquitySubmitResult({
    required this.success,
    this.errorMessage,
    this.equityData,
    this.equityDetail,
  });
}

class HomeEquityFormNotifier extends StateNotifier<HomeEquityFormState> {
  HomeEquityFormNotifier({Dio? dio, http.Client? httpClient})
    : _dio = dio ?? Dio(),
      _http = httpClient ?? http.Client(),
      super(const HomeEquityFormState());

  final Dio _dio;
  final http.Client _http;

  static const List<String> mortgagePropertyOptions = ['Yes', 'No'];
  static const List<String> mortgageDescriptionOptions = [
    'First Charge Mortgage',
    'Second Charge Mortgage',
    'Secured Loan',
  ];
  static const List<String> mortgageSecuredOptions = [
    'Primary Residential Home',
    'Secondary Residence',
    'Holiday Home',
    'Investment Property',
    'Vacant Land',
    'Others',
  ];

  static final RegExp _zipRegex = RegExp(
    r'^[a-z0-9][a-z0-9\- ]{0,10}[a-z0-9]$',
    caseSensitive: false,
  );

  // ---- field setters -----------------------------------------------------
  void setMortgageProperty(String value) =>
      state = state.copyWith(mortgageProperty: value);
  void setMortgageDescription(String value) =>
      state = state.copyWith(mortgageDescription: value);
  void setMortgageSecured(String value) =>
      state = state.copyWith(mortgageSecured: value);
  void setMortgageOpeningBalance(String value) =>
      state = state.copyWith(mortgageOpeningBalance: value);
  void setMortgageCurrentBalance(String value) =>
      state = state.copyWith(mortgageCurrentBalance: value);
  void setMortgageInterestRate(String value) =>
      state = state.copyWith(mortgageInterestRate: value);
  void setMonthlyPayment(String value) =>
      state = state.copyWith(monthlyPayment: value);
  void setPayOffStrategy(String value) =>
      state = state.copyWith(payOffStrategy: value);
  void setCountry(String value) =>
      state = state.copyWith(country: value, zipcode: '', zipVerified: false);
  void setHomeAddress(String value) =>
      state = state.copyWith(homeAddress: value);
  void setTownCity(String value) => state = state.copyWith(townCity: value);
  void setCreditor(String value) => state = state.copyWith(creditor: value);
  void setZipcode(String value) =>
      state = state.copyWith(zipcode: value, zipVerified: false);
  void setCurrentValue(String value) =>
      state = state.copyWith(currentValue: value);
  void setAddress(String value) => state = state.copyWith(address: value);
  void setAddress2(String value) => state = state.copyWith(address2: value);

  void setCoverStart(DateTime? value) =>
      state = state.copyWith(targetDate: value, isTargetDateExpanded: false);

  void toggleTargetDateExpanded() =>
      state = state.copyWith(isTargetDateExpanded: !state.isTargetDateExpanded);

  void setDateAcquired(DateTime? value) => state = state.copyWith(
    dateAcquired: value,
    isDateAcquiredExpanded: false,
  );
  void toggleDateAcquiredExpanded() => state = state.copyWith(
    isDateAcquiredExpanded: !state.isDateAcquiredExpanded,
  );

  // ---- initialization for Edit Screen ------------------------------------
  void initializeFromMap(Map<String, dynamic> data) {
    final addressMap = data['address'] is Map
        ? Map<String, dynamic>.from(data['address'] as Map)
        : <String, dynamic>{};

    final mortgageMap = data['mortgage'] is Map
        ? Map<String, dynamic>.from(data['mortgage'] as Map)
        : <String, dynamic>{};

    final addressLine1 =
        (addressMap['address_line_1'] ?? data['address_line_1'] ?? '')
            .toString();
    final addressLine2 =
        (addressMap['address_line_2'] ?? data['address_line_2'] ?? '')
            .toString();
    final townCity = (addressMap['town_city'] ?? data['town_city'] ?? '')
        .toString();
    final postcode = (addressMap['postcode'] ?? data['postcode'] ?? '')
        .toString();

    final fullAddress = [
      addressLine1,
      addressLine2,
      // townCity,
      // postcode,
    ].where((e) => e.trim().isNotEmpty).join(', ');

    state = state.copyWith(
      id: data['id']?.toString(),
      mortgageProperty:
          (data['ismortgage'] == true ||
              data['ismortgage'] == 'true' ||
              data['ismortgage'] == 'Yes')
          ? 'Yes'
          : 'No',
      creditor: (mortgageMap['creditor_name'] ?? data['creditor'] ?? '')
          .toString(),
      mortgageDescription:
          (mortgageMap['description'] ?? data['description'] ?? '-Select-')
              .toString(),
      mortgageSecured:
          (mortgageMap['secured_against'] ??
                  data['secured_against'] ??
                  '-Select-')
              .toString(),
      mortgageOpeningBalance:
          (mortgageMap['open_balance'] ?? data['open_balance'])?.toString() ??
          '',
      mortgageCurrentBalance:
          (mortgageMap['current_balance'] ?? data['current_balance'])
              ?.toString() ??
          '',
      monthlyPayment:
          (mortgageMap['monthly_pay'] ?? data['monthly_pay'])?.toString() ?? '',
      mortgageInterestRate:
          (mortgageMap['interest_rate'] ?? data['interest_rate'])?.toString() ??
          '',
      payOffStrategy: data['payoff_strategy'] ?? '',
      country: data['country'] ?? '-Select-',
      homeAddress: fullAddress,
      townCity: townCity,
      zipcode: postcode,
      currentValue: data['market_value']?.toString() ?? '',
      address: addressLine1,
      address2: addressLine2,
      targetDate: (mortgageMap['target_date'] ?? data['target_date']) != null
          ? DateTime.tryParse(
              (mortgageMap['target_date'] ?? data['target_date']).toString(),
            )
          : null,
      dateAcquired: data['date_acquired'] != null
          ? DateTime.tryParse(data['date_acquired'].toString())
          : null,
    );
  }

  // ---- outstanding mortgages / debt --------------------------------------
  Future<void> loadDebt(String currency) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');
      final response = await _http.get(
        Uri.parse('$baseUrl/app/360/equity/info'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        state = state.copyWith(
          loading: false,
          error: 'Failed to load mortgages (${response.statusCode})',
        );
        return;
      }

      final Map body = jsonDecode(response.body) as Map;
      final List mortgages = (body['mortgages_available'] as List?) ?? [];

      final mortgagesList = mortgages.map((e) {
        final creditorName = e['creditor_name'];
        final num currentBalance = e['current_balance'];
        final formattedBalance = currentBalance.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
        return '$creditorName ($currency$formattedBalance)';
      }).toList()..insert(0, '-Select-');

      state = state.copyWith(
        mortgages: mortgages,
        mortgagesList: mortgagesList,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  // ---- DELETE ----------------------------------------------------------
  Future<HomeEquitySubmitResult> delete(String id) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      final response = await _http.delete(
        Uri.parse('$baseUrl/app/360/equity/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final success = response.statusCode == 200 || response.statusCode == 204;

      if (success) {
        state = state.copyWith(loading: false);
        return const HomeEquitySubmitResult(success: true);
      }

      String message = 'Failed to delete home equity (${response.statusCode}).';
      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          message = (decoded is Map && decoded['message'] != null)
              ? decoded['message'].toString()
              : response.body;
        } catch (_) {
          message = response.body;
        }
      }
      state = state.copyWith(loading: false, error: message);
      return HomeEquitySubmitResult(success: false, errorMessage: message);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return HomeEquitySubmitResult(success: false, errorMessage: e.toString());
    }
  }

  // ---- SUBMIT (Create) ---------------------------------------------------
  Future<HomeEquitySubmitResult> submit() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');
      print('Submitting Home Equity: ${state.address.toString()}');
      final body = <String, dynamic>{
        'postcode': state.zipcode == '' ? '0' : state.zipcode,
        'town_city': state.townCity.trim(),
        'ismortgage': state.mortgageProperty == 'Yes',
        'market_value': state.currentValue,
        'country': state.country,
        'location': state.homeAddress,
        'date_acquired': state.dateAcquired?.toIso8601String(),
        'address_line_1': state.address.trim().isEmpty
            ? null
            : state.address.trim(),
        'address_line_2': state.address2.trim().isEmpty
            ? null
            : state.address2.trim(),
        'creditor': state.creditor,
        'description': state.mortgageDescription,
        'secured_against': state.mortgageSecured,
        'open_balance': state.mortgageOpeningBalance,
        'current_balance': state.mortgageCurrentBalance,
        'monthly_pay': state.monthlyPayment,
        'interest_rate': state.mortgageInterestRate,
        'repayment_plan': state.payOffStrategy,
        'target_date': state.targetDate?.toIso8601String(),
      };

      final response = await _http.post(
        Uri.parse('$baseUrl/app/360/equity'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      return _handleResponse(response, isNew: true);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return HomeEquitySubmitResult(success: false, errorMessage: e.toString());
    }
  }

  // ---- UPDATE (Edit) -----------------------------------------------------
  Future<HomeEquitySubmitResult> update(String id) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      final body = <String, dynamic>{
        'postcode': state.zipcode.trim(),
        'town_city': state.townCity.trim(),
        'ismortgage': state.mortgageProperty == 'Yes',
        'market_value': state.currentValue,
        'country': state.country,
        'location': state.homeAddress,
        'date_acquired': state.dateAcquired?.toIso8601String(),
        'address_line_1': state.address == '' ? '' : state.address.trim(),
        'address_line_2': state.address2 == '' ? '' : state.address2.trim(),
        'creditor': state.creditor,
        'description': state.mortgageDescription,
        'secured_against': state.mortgageSecured,
        'open_balance': state.mortgageOpeningBalance,
        'current_balance': state.mortgageCurrentBalance,
        'monthly_pay': state.monthlyPayment,
        'interest_rate': state.mortgageInterestRate,
        'repayment_plan': state.payOffStrategy,
        'target_date': state.targetDate?.toIso8601String(),
      };

      // NOTE: If your backend uses POST for updates instead of PUT, change _http.put to _http.post
      final response = await _http.put(
        Uri.parse('$baseUrl/app/360/equity/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      print('Update Response: ${response.statusCode} - ${response.body}');
      return _handleResponse(response, isNew: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return HomeEquitySubmitResult(success: false, errorMessage: e.toString());
    }
  }

  // ---- Shared Response Handler -------------------------------------------
  Future<HomeEquitySubmitResult> _handleResponse(
    http.Response response, {
    required bool isNew,
  }) async {
    final success = response.statusCode == 200 || response.statusCode == 201;

    if (success) {
      dynamic equityData;
      dynamic equityDetail;
      try {
        final equityResponse = await _dio.get(
          "$baseUrl/app/360/equity",
          options: Options(
            headers: {
              "Authorization":
                  'Bearer ${await SharedPreferences.getInstance().then((p) => p.getString('tokenDB'))}',
            },
          ),
        );
        equityData = equityResponse.data["equity"];
        equityDetail = equityResponse.data["equity_detail"];
      } catch (_) {}

      state = state.copyWith(loading: false);
      return HomeEquitySubmitResult(
        success: true,
        equityData: equityData,
        equityDetail: equityDetail,
      );
    }

    String message =
        'Failed to ${isNew ? 'save' : 'update'} home equity (${response.statusCode}).';
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        message = (decoded is Map && decoded['message'] != null)
            ? decoded['message'].toString()
            : response.body;
      } catch (_) {
        message = response.body;
      }
    }

    state = state.copyWith(loading: false, error: message);
    return HomeEquitySubmitResult(success: false, errorMessage: message);
  }

  void reset() => state = const HomeEquityFormState();
}

final homeEquityFormProvider =
    StateNotifierProvider.autoDispose<
      HomeEquityFormNotifier,
      HomeEquityFormState
    >((ref) {
      return HomeEquityFormNotifier();
    });
