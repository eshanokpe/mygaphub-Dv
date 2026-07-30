import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:GapHub/utils/constants.dart';
import 'edit_asset_state.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

final editAssetProvider =
    NotifierProvider.autoDispose<EditAssetNotifier, EditAssetState>(
      EditAssetNotifier.new,
    );

// ─── Callback bridge providers ────────────────────────────────────────────────

final ilabDataUpdateCallbackProvider =
    StateProvider<void Function(Map<dynamic, dynamic>)?>((_) => null);

final setTargetUpdateCallbackProvider =
    StateProvider<void Function(Map<dynamic, dynamic>)?>((_) => null);

// ─── Notifier ─────────────────────────────────────────────────────────────────

class EditAssetNotifier extends Notifier<EditAssetState> {
  @override
  EditAssetState build() => const EditAssetState();

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _valueFromAsset(List<dynamic> assetList, String key, String field) {
    for (final item in assetList) {
      final map = Map<String, dynamic>.from(item as Map);
      if (map['key'] == key) return map[field]?.toString() ?? '0';
    }
    return '0';
  }

  String _formatNumber(String rawValue) {
    final num = double.tryParse(rawValue) ?? 0;
    return num.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  String? _parseToIntOrNull(String value) {
    final clean = value.replaceAll(',', '').trim();
    if (clean.isEmpty) return null;

    final parsed = double.tryParse(clean);
    if (parsed == null || parsed == 0) return null;

    final normalized = clean.endsWith('.')
        ? clean.substring(0, clean.length - 1)
        : clean.replaceAll(RegExp(r'\.0+$'), '');
    return normalized;
  }

  String _resolveValue(String? targetParsed, String currentText) {
    if (targetParsed != null) return targetParsed;
    final clean = currentText.replaceAll(',', '').trim();
    if (clean.isEmpty) return '0';

    final normalized = clean.endsWith('.')
        ? clean.substring(0, clean.length - 1)
        : clean.replaceAll(RegExp(r'\.0+$'), '');

    return normalized.isEmpty ? '0' : normalized;
  }

  String _dioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timed out. Please check your connection.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please try again.';
      default:
        return e.response?.data?['message']?.toString() ??
            'Something went wrong. Please try again.';
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  PopulatedControllerValues? populateFromProviderData(
    Map<dynamic, dynamic> providerData,
  ) {
    if (providerData.isEmpty) return null;

    Map<String, dynamic> raw = Map<String, dynamic>.from(providerData);
    if (raw['asset'] == null && raw['data'] is Map) {
      raw = Map<String, dynamic>.from(raw['data'] as Map);
    }

    debugPrint(
      '[EditAssetNotifier] asset key present: ${raw["asset"] != null}',
    );

    if (raw['asset'] == null) {
      debugPrint(
        '[EditAssetNotifier] WARNING: asset still null. keys: ${raw.keys.toList()}',
      );
    }

    return _buildPopulatedValues(raw);
  }

  PopulatedControllerValues _buildPopulatedValues(Map<String, dynamic> raw) {
    final List<dynamic> assetList = raw['asset'] != null
        ? List<dynamic>.from(raw['asset'] as List)
        : [];

    final investCurrent = _formatNumber(
      _valueFromAsset(assetList, 'investment', 'current'),
    );
    final equityCurrent = _formatNumber(
      _valueFromAsset(assetList, 'equity', 'current'),
    );
    final cashCurrent = _formatNumber(
      _valueFromAsset(assetList, 'cash', 'current'),
    );

    final investTarget = _formatNumber(
      _valueFromAsset(assetList, 'investment', 'target'),
    );
    final equityTarget = _formatNumber(
      _valueFromAsset(assetList, 'equity', 'target'),
    );
    final cashTarget = _formatNumber(
      _valueFromAsset(assetList, 'cash', 'target'),
    );

    debugPrint(
      '[EditAssetNotifier] Populated —\n'
      '  investment  current: $investCurrent  target: $investTarget\n'
      '  equity      current: $equityCurrent  target: $equityTarget\n'
      '  cash        current: $cashCurrent    target: $cashTarget',
    );

    state = state.copyWith(
      investmentDisplay: investCurrent,
      homeEquityDisplay: equityCurrent,
      cashDisplay: cashCurrent,
    );

    return PopulatedControllerValues(
      investCurrentText: investCurrent,
      equityCurrentText: equityCurrent,
      cashCurrentText: cashCurrent,
      investTargetText: investTarget,
      equityTargetText: equityTarget,
      cashTargetText: cashTarget,
    );
  }

  void onFocusChanged({required bool hasFocus}) {
    if (hasFocus && !state.isDirty) {
      state = state.copyWith(isDirty: true);
    }
  }

  Future<SaveResult> saveTargets({
    required String investTargetText,
    required String equityTargetText,
    required String cashTargetText,
    required String investCurrentText,
    required String equityCurrentText,
    required String cashCurrentText,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final url = Uri.parse('$baseUrl/app/360/ilab');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null) {
        state = state.copyWith(isLoading: false);
        return SaveResult.authError();
      }

      final investTarget = _parseToIntOrNull(investTargetText);
      final equityTarget = _parseToIntOrNull(equityTargetText);
      final cashTarget = _parseToIntOrNull(cashTargetText);

      final investValue = _resolveValue(investTarget, investCurrentText);
      final equityValue = _resolveValue(equityTarget, equityCurrentText);
      final cashValue = _resolveValue(cashTarget, cashCurrentText);

      debugPrint(
        '[EditAssetNotifier] Saving — '
        'investment: $investValue, equity: $equityValue, cash: $cashValue',
      );

      final response = await http.post(
        url,
        body: {
          'investment': investValue,
          'equity': equityValue,
          'cash': cashValue,
          'category': 'asset',
          'period': 'current',
        },
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint(
        '[EditAssetNotifier] POST ${response.statusCode}: ${response.body}',
      );

      if (response.statusCode == 400) {
        state = state.copyWith(isLoading: false);
        return SaveResult.serverError('Something went wrong');
      }

      if (response.statusCode == 200) {
        final getResponse = await Dio().get(
          '$baseUrl/app/360/ilab?period=current',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
          ),
        );

        if (getResponse.statusCode == 200) {
          final responseData = getResponse.data;

          if (responseData is Map &&
              (responseData['status'] == true ||
                  responseData['status'] == null)) {
            final Map<String, dynamic> freshData = Map<String, dynamic>.from(
              responseData['data'] ?? responseData,
            );

            // Push to legacy Provider bridge
            ref.read(ilabDataUpdateCallbackProvider)?.call(freshData);

            final populated = _buildPopulatedValues(freshData);
            state = state.copyWith(isDirty: false, isLoading: false);

            return SaveResult.success(
              freshData: freshData,
              populated: populated,
            );
          } else {
            state = state.copyWith(isLoading: false);
            return SaveResult.serverError(
              responseData['message']?.toString() ??
                  'Failed to set iLab target',
            );
          }
        }
      }

      state = state.copyWith(isLoading: false);
      return SaveResult.serverError('Unexpected response');
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false);
      return SaveResult.serverError(_dioErrorMessage(e));
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return SaveResult.serverError('An error occurred: ${e.toString()}');
    }
  }

  Future<HandleSuccessResult> handleSuccess() async {
    if (state.isLoading) return HandleSuccessResult.alreadyLoading();
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null) {
        state = state.copyWith(isLoading: false);
        return HandleSuccessResult.error(
          'Authentication failed. Please log in again.',
        );
      }

      final response = await Dio().get(
        '$baseUrl/app/360/ilab?period=current',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map &&
            (responseData['status'] == true ||
                responseData['status'] == null)) {
          final Map<dynamic, dynamic> freshData =
              responseData['data'] ?? responseData;
          // Push to legacy Provider bridges
          ref.read(ilabDataUpdateCallbackProvider)?.call(freshData);
          ref.read(setTargetUpdateCallbackProvider)?.call(freshData);

          state = state.copyWith(isLoading: false);
          return HandleSuccessResult.success();
        } else {
          state = state.copyWith(isLoading: false);
          return HandleSuccessResult.error(
            responseData['message']?.toString() ?? 'Failed to load iLab data.',
          );
        }
      } else {
        state = state.copyWith(isLoading: false);
        return HandleSuccessResult.error(
          'Request failed (${response.statusCode}). Please try again.',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false);
      return HandleSuccessResult.error(_dioErrorMessage(e));
    } catch (_) {
      state = state.copyWith(isLoading: false);
      return HandleSuccessResult.error(
        'An unexpected error occurred. Please try again.',
      );
    }
  }
}

// ─── Result types ─────────────────────────────────────────────────────────────

class PopulatedControllerValues {
  const PopulatedControllerValues({
    required this.investCurrentText,
    required this.equityCurrentText,
    required this.cashCurrentText,
    required this.investTargetText,
    required this.equityTargetText,
    required this.cashTargetText,
  });

  final String investCurrentText;
  final String equityCurrentText;
  final String cashCurrentText;
  final String investTargetText;
  final String equityTargetText;
  final String cashTargetText;
}

class SaveResult {
  const SaveResult._({
    required _SaveResultType type,
    this.freshData,
    this.populated,
    this.errorMessage,
  }) : _type = type;

  factory SaveResult.success({
    required Map<String, dynamic> freshData,
    required PopulatedControllerValues populated,
  }) => SaveResult._(
    type: _SaveResultType.success,
    freshData: freshData,
    populated: populated,
  );

  factory SaveResult.authError() =>
      const SaveResult._(type: _SaveResultType.authError);

  factory SaveResult.serverError(String message) =>
      SaveResult._(type: _SaveResultType.serverError, errorMessage: message);

  final _SaveResultType _type;
  final Map<String, dynamic>? freshData;
  final PopulatedControllerValues? populated;
  final String? errorMessage;

  bool get isSuccess => _type == _SaveResultType.success;
  bool get isAuthError => _type == _SaveResultType.authError;
  bool get isServerError => _type == _SaveResultType.serverError;
}

enum _SaveResultType { success, authError, serverError }

class HandleSuccessResult {
  const HandleSuccessResult._({
    required _HandleSuccessType type,
    this.errorMessage,
  }) : _type = type;

  factory HandleSuccessResult.success() =>
      const HandleSuccessResult._(type: _HandleSuccessType.success);

  factory HandleSuccessResult.alreadyLoading() =>
      const HandleSuccessResult._(type: _HandleSuccessType.alreadyLoading);

  factory HandleSuccessResult.error(String message) => HandleSuccessResult._(
    type: _HandleSuccessType.error,
    errorMessage: message,
  );

  final _HandleSuccessType _type;
  final String? errorMessage;

  bool get isSuccess => _type == _HandleSuccessType.success;
}

enum _HandleSuccessType { success, alreadyLoading, error }
