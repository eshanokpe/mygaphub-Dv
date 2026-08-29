import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/360/accounts/assets/presentation/assetdetails.dart';
import 'package:GapHub/screens/360/accounts/cash/cashdetails.dart';
import 'package:GapHub/screens/360/accounts/expenditure/expenditure.dart';
import 'package:GapHub/screens/360/accounts/income/incomedash.dart';
import 'package:GapHub/screens/360/accounts/investment/investdash.dart';
import 'package:GapHub/screens/360/accounts/liabilities/liabilitydetails.dart';
import 'package:GapHub/screens/360/accounts/mortgage/mortgagedetails.dart';
import 'package:GapHub/screens/360/accounts/networth/networth.dart';
import 'package:GapHub/screens/360/accounts/networth/networthdetails.dart';
import 'package:GapHub/screens/360/accounts/philanthropy/philanthropy.dart';
import 'package:GapHub/screens/360/accounts/philanthropy/setgiving.dart';
import 'package:GapHub/screens/360/accounts/protection/protectiondetails.dart';
import 'package:GapHub/screens/360/accounts/retirement/presentation/retiredash.dart';
import 'package:GapHub/screens/360/threesixty.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../accounts/income/income.dart';
import '../models/wheel_item.dart';
import '../models/wheel_side_card.dart';

class WheelController {
  final List<WheelItem> wheelItems;
  final List<WheelItemSideCard> sideCardItems;
  final Function(VoidCallback) setState;
  final BuildContext context;
  final Providers? providers;

  late DialogBox dialogBox;
  late Dio dio;

  static const int _timeoutSeconds = 20;
  static const Color _successColor = Color(0xff00B050);

  WheelController({
    required this.wheelItems,
    required this.sideCardItems,
    required this.setState,
    required this.context,
    this.providers,
  }) {
    dialogBox = DialogBox();
    dio = Dio();
  }

  // ==================== HELPER METHODS ====================

  Future<String> _getCurrency() async {
    try {
      if (context.mounted) {
        return context.read<Providers>().snapshotmodel.currency;
      }
    } catch (e) {
      debugPrint('Error getting currency from context: $e');
    }

    return providers?.snapshotmodel.currency ?? '\$';
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tokenDB');
  }

  Map<String, String> _getHeaders(String token) {
    return {'Authorization': 'Bearer $token'};
  }

  T? _safeParse<T>(
    dynamic value,
    T Function(dynamic) parser, {
    T? defaultValue,
  }) {
    try {
      return parser(value);
    } catch (e) {
      debugPrint('Error parsing value: $e');
      return defaultValue;
    }
  }

  // ==================== API RESPONSE HANDLING ====================

  bool _isSuccessResponse(dynamic response) {
    return response is Map && response['status'] == true;
  }

  dynamic _extractData(dynamic response) {
    return response is Map ? response['data'] : null;
  }

  String _getErrorMessageFromResponse(dynamic response) {
    return response is Map
        ? response['message'] ?? 'Unknown error'
        : 'Unknown error';
  }

  // ==================== NAVIGATION & DIALOG MANAGEMENT ====================

  Future<void> _executeWithLoadingAndTimeout({
    required Future<void> Function() action,
    required String loadingMessage,
    int timeoutSeconds = _timeoutSeconds,
  }) async {
    dialogBox.waiting(context, loadingMessage);

    final timer = Timer(Duration(seconds: timeoutSeconds), () {
      _handleTimeout();
    });

    try {
      await action();
      timer.cancel();
    } catch (e, stackTrace) {
      timer.cancel();
      await _handleError(e, stackTrace: stackTrace);
    }
  }

  void _safePopDialog() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _safeNavigate(Widget screen) {
    if (context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }
  }

  void _safeNavigateReplacement(Widget screen) {
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );
    }
  }

  void _showToast(String message, {Color backgroundColor = _successColor}) {
    Fluttertoast.showToast(
      backgroundColor: backgroundColor,
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  // ==================== MAIN TAP HANDLER ====================

  void handleItemTap(
    int index, {
    bool isActiveCard = false,
    bool isSideCard = false,
  }) {
    final currentItem = wheelItems[index];

    // _showToast('${currentItem.title} selected');

    switch (index) {
      case 0:
        _handleNetWorthTap();
        break;
      case 1:
        handleAssetsTap();
        break;
      case 2:
        handleIncomeTap();
        break;
      case 3:
        handleStrategyTap();
        break;
      case 4:
        handlePhilanthropyTap();
        break;
      case 5:
        handleMortgageTap();
        break;
      case 6:
        handleCashTap();
        break;
      case 7:
        handleInvestmentTap();
        break;
      case 8:
        handleRetirementTap();
        break;
      case 9:
        handleProtectionTap();
        break;
      case 10:
        handleExpenditureTap();
        break;
      case 11:
        handleLiabilitiesTap();
        break;
    }
  }

  // ==================== NET WORTH ====================

  Future<void> _handleNetWorthTap() async {
    await _executeWithLoadingAndTimeout(
      loadingMessage: "Loading",
      action: () async {
        final currency = await _getCurrency();
        final token = await _getToken();

        if (token == null) throw Exception('Authentication token not found');

        final responses = await Future.wait([
          dio.get(
            "$baseUrl/app/360/net-worth",
            options: Options(headers: _getHeaders(token)),
          ),
          dio.get(
            "$baseUrl/app/360/equity",
            options: Options(headers: _getHeaders(token)),
          ),
          // dio.get(
          //   "$baseUrl/app/360/retirement?archive=0&header=&access=&account=",
          //   options: Options(headers: _getHeaders(token)),
          // ),
          dio.get(
            "$baseUrl/app/360/cash?archive=0&header=&access=&account=&kpi=",
            options: Options(headers: _getHeaders(token)),
          ),
          dio.get(
            "$baseUrl/app/360/investment",
            options: Options(headers: _getHeaders(token)),
          ),
          dio.get(
            "$baseUrl/app/360/liability?archive=0&header=&access=&account=&kpi=&crd=&alo=",
            options: Options(headers: _getHeaders(token)),
          ),
        ]);

        final response = responses[0];
        final response2 = responses[1];
        // final retirementResponse = responses[2].data;
        final cashResponse = responses[2].data;
        final investmentResponse = responses[3].data;
        final liabilityResponse = responses[4].data;

        _safePopDialog();

        // Check if responses are successful
        if (response.data['status'] != true ||
            response2.data['status'] != true) {
          throw Exception('API returned error status');
        }

        // Get the data from the response
        final netWorthData = response.data['data'];
        final equityData = response2.data['data'];
        // final retirementData = retirementResponse['data'] as Map? ?? {};
        final cashData = cashResponse['data'] as Map? ?? {};

        final netConfirmValue = netWorthData['isNet']?['net_confirm'];
        final investmentData = investmentResponse['data'] as Map? ?? {};
        final liabilityData = liabilityResponse['data'] as Map? ?? {};

        final List mapList = liabilityData["liabilities"];
        final mapListLite = liabilityData["liabilities_detail"];

        int? isNetConfirmed;

        if (netConfirmValue is String) {
          isNetConfirmed = int.tryParse(netConfirmValue);
        } else if (netConfirmValue is int) {
          isNetConfirmed = netConfirmValue;
        } else if (netConfirmValue is num) {
          isNetConfirmed = netConfirmValue.toInt();
        }
        num equity = 0;

        if (equityData.containsKey('equity') && equityData['equity'] is List) {
          // If you need to calculate sum from equity list
          final equityList = equityData['equity'] as List;
          for (var item in equityList) {
            equity += num.tryParse(item['equity']?.toString() ?? '0') ?? 0;
          }
        }
        context.read<Providers>()
          ..setequityList(equityData['equity'])
          ..setequityDetail(equityData['equity_detail']);
        // ..setpensions(retirementData);
        if (isNetConfirmed == 0) {
          _safeNavigate(
            Networth(
              item: netWorthData,
              seveng: cashData['seveng'],
              bespokes: cashData['bespokes'],
              invSum: investmentData['investment_sum'] ?? 0,
              braidTable: investmentData['braid_table'],
              mapList: mapList,
              mapListLite: mapListLite,
            ),
          );
        } else if (isNetConfirmed == 1) {
          _safeNavigate(
            Networthdetails(
              item: netWorthData, // Pass the full response
              equity: equity,
              currency: currency,
            ),
          );
        } else {
          throw Exception('Invalid net_confirm value: $netConfirmValue');
        }
      },
    );
  }

  // ==================== ASSETS ====================

  Future<void> handleAssetsTap() async {
    await _executeWithLoadingAndTimeout(
      loadingMessage: "Loading",
      action: () async {
        final token = await _getToken();
        if (token == null) throw Exception('Authentication token not found');

        final responses = await Future.wait([
          dio.get(
            "$baseUrl/app/360/cash?archive=0&header=&access=&account=&kpi=",
            options: Options(headers: _getHeaders(token)),
          ),
          dio.get(
            "$baseUrl/app/360/equity",
            options: Options(headers: _getHeaders(token)),
          ),
          // dio.get(
          //   "$baseUrl/app/360/investment",
          //   options: Options(headers: _getHeaders(token)),
          // ),
          // dio.get(
          //   "$baseUrl/app/360/retirement?archive=0&header=&access=&account=",
          //   options: Options(headers: _getHeaders(token)),
          // ),
          dio.get(
            "$baseUrl/app/360/asset",
            options: Options(headers: _getHeaders(token)),
          ),
        ]);

        final cashResponse = responses[0].data;
        final equityResponse = responses[1].data;
        // final investmentResponse = responses[2].data;
        // final retirementResponse = responses[3].data;
        final assetsResponse = responses[2].data;

        // ✅ All three are nested under 'data'
        final cashData = cashResponse['data'] as Map? ?? {};
        final equityData = equityResponse['data'] as Map? ?? {};
        // final investmentData = investmentResponse['data'] as Map? ?? {};
        // final retirementData = retirementResponse['data'] as Map? ?? {};
        final assetsData = assetsResponse['data'] as Map? ?? {};

        if (context.mounted) {
          context.read<Providers>()
            ..setequityList(equityData['equity'])
            ..setequityDetail(equityData['equity_detail'])
            ..setcashDataLite(cashData['cash_detail'])
            ..setcashData(cashData['cash'])
            ..setAssetsData(assetsData);
          // ..setpensions(retirementData);
          _safePopDialog();
        }

        _safeNavigate(
          Assetdetails(
            seveng: cashData['seveng'] ?? [],
            bespokes: cashData['bespokes'] ?? [],
          ),
        );
      },
    );
  }

  // ==================== INCOME ====================
  Future<void> handleIncomeTap() async {
    await _executeWithLoadingAndTimeout(
      loadingMessage: "Loading",
      timeoutSeconds: 20,
      action: () async {
        final token = await _getToken();
        if (token == null) throw Exception('Authentication token not found');

        const url =
            "$baseUrl/app/360/income?archive=0&header=&access=&account=&period=&income=&crd=&alo=";
        final response = await dio.get(
          url,
          options: Options(headers: _getHeaders(token)),
        );

        if (response.statusCode != 200) {
          throw Exception(
            'Failed to load income data (Status: ${response.statusCode})',
          );
        }

        final data = response.data['data'] ?? {};
        final assets = data['portfolio_asset'] as List? ?? [];
        final incomeData = data['incomes'] as List? ?? [];
        final incomeDataLite = data['income_detail'];
        final incomeInfo = data['income_info'] ?? {};
        final incomeAudit = data['income_audit'];
        final incomeChart = data['income_chart'];

        final portfolioDiff = _safeParse<double>(
          incomeInfo['portfolio_diff'],
          (v) => (v as num?)?.toDouble() ?? 0.0,
          defaultValue: 0.0,
        );

        final allocated = _safeParse<num>(
          incomeAudit?['income_allocated'],
          (v) => num.tryParse(v?.toString() ?? '1') ?? 1,
          defaultValue: 1,
        );

        final List<String> listOfAssets = ['-Select-'];
        for (var asset in assets) {
          if (asset['isArchive'] != 1) {
            final name = asset['name'] ?? '';
            final currency = asset['asset_currency'] ?? '';
            final monthlyRoi =
                (asset['monthly_roi'] as num?)?.toDouble() ?? 0.0;
            listOfAssets.add(
              '$name ($currency${monthlyRoi.toStringAsFixed(2)})',
            );
          }
        }

        if (context.mounted) {
          final provider = context.read<Providers>();
          provider.setCurrentPortfolio(
            _safeParse(
              incomeInfo['current_portfolio'],
              (v) => int.parse(v.toString()),
              defaultValue: 0,
            ),
          );
          provider.setPortfolioDiff(portfolioDiff!);
          provider.setAssets(listOfAssets);
          provider.setMapAsset(assets);
          if (incomeChart != null) provider.addIncomeChart(incomeChart);
        }

        _safePopDialog();

        if (portfolioDiff! > 0) {
          _safeNavigate(const Income());
        } else {
          final incomes = response.data['incomes'] ?? [];
          final channels = response.data['income_channels'] ?? {};

          _safeNavigateReplacement(
            Incomedash(
              incomeData,
              incomeDataLite,
              allocated!,
              incomes: incomes,
              channels: channels,
            ),
          );
        }
      },
    );
  }

  // ==================== STRATEGY ====================

  void handleStrategyTap() {
    Navigator.of(context).pushNamed('Actionplan');
    debugPrint('Navigating to Strategy screen');
    // TODO: Implement strategy navigation
  }

  // ==================== PHILANTHROPY ====================

  Future<void> handlePhilanthropyTap() async {
    await _executeWithLoadingAndTimeout(
      loadingMessage: 'Loading',
      action: () async {
        final currency = await _getCurrency();
        final token = await _getToken();
        if (token == null) throw Exception('Authentication token not found');

        final response = await dio.get(
          "$baseUrl/app/360/philantrophy",
          options: Options(headers: _getHeaders(token)),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to load philanthropy data');
        }

        _safePopDialog();

        final data = response.data ?? {};
        final grant = data['grand']?['current'] ?? 0;

        final charity = data['philantrophy']?['charity'] ?? 0;
        final familySupport = data['philantrophy']?['family_support'] ?? 0;
        final personalCommitments =
            data['philantrophy']?['personal_commitments'] ?? 0;
        final others = data['philantrophy']?['others'] ?? 0;
        final setgiving =
            charity + familySupport + personalCommitments + others;

        if (context.mounted) {
          context.read<Providers>().setphilanList(data);
          context.read<Providers>().setcurrency(currency);
        }

        if (grant != setgiving) {
          debugPrint('Setgiving: $data');
          _safeNavigate(Setgiving(data));
        } else {
          debugPrint('Philanthropy');
          _safeNavigate(Philanthropy(data, currency));
        }
      },
    );
  }

  // ==================== MORTGAGE ====================
  Future<void> handleMortgageTap() async {
    await _executeWithLoadingAndTimeout(
      loadingMessage: "Loading",
      timeoutSeconds: 30,
      action: () async {
        final token = await _getToken();
        if (token == null) throw Exception('Authentication token not found');

        const url =
            "$baseUrl/app/360/mortgage?archive=0&header=&access=&account=";
        final response = await dio.get(
          url,
          options: Options(headers: _getHeaders(token)),
        );

        if (response.statusCode != 200) {
          throw Exception(
            'Failed to load mortgage data (Status: ${response.statusCode})',
          );
        }

        // ✅ Extract the nested data object first
        final data = response.data['data'] as Map? ?? {};

        final mortgageList = data['mortgages'];
        if (mortgageList == null) {
          throw Exception('Invalid response format: missing mortgage data');
        }

        _safePopDialog();

        _safeNavigate(
          Mortgagedetails(
            mortgageList,
            // ✅ Fixed: was reading from root, now reading from data
            data['mortgages_detail'] ?? {},
            data['seveng'] ?? [],
          ),
        );
      },
    );
  }

  // ==================== CASH ====================

  Future<void> handleCashTap() async {
    await _executeWithLoadingAndTimeout(
      loadingMessage: "Loading",
      action: () async {
        final token = await _getToken();
        if (token == null) throw Exception('Authentication token not found');

        const url =
            "$baseUrl/app/360/cash?archive=0&header=&access=&account=&kpi=";
        final response = await dio.get(
          url,
          options: Options(headers: _getHeaders(token)),
        );

        if (response.statusCode != 200) {
          throw Exception(
            'Failed to load cash data (Status: ${response.statusCode})',
          );
        }

        if (!_isSuccessResponse(response.data)) {
          throw Exception(_getErrorMessageFromResponse(response.data));
        }

        final cashResponseData = _extractData(response.data) as Map? ?? {};

        final cashData = cashResponseData['cash'] as List? ?? [];
        final sevengData = cashResponseData['seveng'] as List? ?? [];
        final cashDetailData = cashResponseData['cash_detail'] as Map? ?? {};
        final bespokesData = cashResponseData['bespokes'] as List? ?? [];

        if (context.mounted) {
          context.read<Providers>()
            ..setcashData(cashData)
            ..setcashDataLite(cashDetailData)
            ..setcashseveng(sevengData)
            ..setcashbespokes(bespokesData);
        }

        _safePopDialog();

        _safeNavigate(
          Cashdetails(cashData, cashDetailData, sevengData, bespokesData),
        );
      },
    );
  }

  // ==================== INVESTMENT ====================

  Future<void> handleInvestmentTap() async {
    await _executeWithLoadingAndTimeout(
      loadingMessage: 'Loading investment data...',
      timeoutSeconds: 40,
      action: () async {
        final token = await _getToken();
        if (token == null) throw Exception('Authentication token not found');

        final url = Uri.parse('$baseUrl/app/360/investment');
        final response = await http
            .get(
              url,
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 40));

        if (response.statusCode != 200) {
          throw Exception(
            'Failed to load investment data (Status: ${response.statusCode})',
          );
        }

        final Map<String, dynamic> investmentData = jsonDecode(response.body);

        if (!investmentData.containsKey('data')) {
          throw Exception('Invalid response format: missing investment_sum');
        }

        if (context.mounted) {
          context.read<Providers>().setinvSum(
            investmentData['data']['investment_sum'],
          );
        }

        _safePopDialog();

        _safeNavigate(
          Investdash(
            sums: investmentData['data']['investment_sum'],
            braidTable: investmentData['data']['braid_table'],
          ),
        );
      },
    );
  }

  // ==================== RETIREMENT ====================

  Future<void> handleRetirementTap() async {
    _safeNavigate(const Retiredash());
  }

  // ==================== PROTECTION ====================

  Future<void> handleProtectionTap() async {
    await _executeWithLoadingAndTimeout(
      loadingMessage: "Loading",
      action: () async {
        final token = await _getToken();
        if (token == null) throw Exception('Authentication token not found');

        const url =
            "$baseUrl/app/360/protection?archive=0&header=&access=&account=";
        final response = await dio.get(
          url,
          options: Options(headers: _getHeaders(token)),
        );

        if (response.statusCode != 200) {
          throw Exception(
            'Failed to load protection data (Status: ${response.statusCode})',
          );
        }

        if (!_isSuccessResponse(response.data)) {
          debugPrint('Protection endpoint error payload: ${response.data}');
          throw Exception(_getErrorMessageFromResponse(response.data));
        }

        final extracted = _extractData(response.data);
        final Map<String, dynamic> protectionData = extracted is Map
            ? Map<String, dynamic>.from(extracted)
            : {};

        final protectionList = protectionData['protection'] ?? [];
        final protectionDetailList = protectionData['protection_detail'] ?? [];
        final protectionDistribution =
            protectionData['protection_distribution'] ?? {'distribution': []};

        if (protectionList.isEmpty) {
          debugPrint('No protection data found');
        }
        if (context.mounted) {
          context.read<Providers>()
            ..setProtectionList(protectionList)
            ..setProtectionListLite(protectionDetailList)
            ..setProtectionDistribution(protectionDistribution);
        }
        _safePopDialog();

        if (context.mounted) {
          _safeNavigate(const Protectiondetails());
        }
      },
    );
  }

  // ==================== EXPENDITURE ====================

  Future<void> handleExpenditureTap() async {
    await _executeWithLoadingAndTimeout(
      loadingMessage: "Loading",
      action: () async {
        final currency = await _getCurrency();
        final token = await _getToken();
        if (token == null) throw Exception('Authentication token not found');

        const url = "$baseUrl/app/360/expenditure";
        final response = await dio.get(
          url,
          options: Options(headers: _getHeaders(token)),
        );

        if (response.statusCode != 200) {
          throw Exception(
            'Failed to load expenditure data (Status: ${response.statusCode})',
          );
        }

        if (!_isSuccessResponse(response.data)) {
          throw Exception(_getErrorMessageFromResponse(response.data));
        }

        final expenditureData = _extractData(response.data) as Map? ?? {};
        final expenditureList = expenditureData['expenditure'] ?? [];
        final expenditureDetailList = expenditureData['expenditure_detail'];

        if (expenditureList.isEmpty) {
          debugPrint('No expenditure data found');
        }

        if (context.mounted) {
          context.read<Providers>()
            ..setExpenditureList(expenditureList)
            ..setcurrency(currency);

          if (expenditureDetailList != null) {
            context.read<Providers>().setExpenditureListLite(
              expenditureDetailList,
            );
          }
        }

        _safePopDialog();

        _safeNavigate(const Expenditure());
      },
    );
  }

  // ==================== LIABILITIES ====================

  Future<void> handleLiabilitiesTap() async {
    await _executeWithLoadingAndTimeout(
      loadingMessage: "Loading",
      action: () async {
        final token = await _getToken();
        if (token == null) throw Exception('Authentication token not found');

        final url2 = Uri.parse('$baseUrl/app/seveng/edit');
        const url =
            "$baseUrl/app/360/liability?archive=0&header=&access=&account=&kpi=&crd=&alo=";

        final response = await dio.get(
          url,
          options: Options(headers: _getHeaders(token)),
        );
        final response2 = await http.get(url2, headers: _getHeaders(token));

        if (response.statusCode != 200 || response2.statusCode != 200) {
          throw Exception('Failed to load liability data');
        }

        final List mapList = response.data['data']["liabilities"];
        final mapListLite = response.data['data']["liabilities_detail"];
        final List seveng = response.data['data']["seveng"] ?? [];
        final bespokes = response.data['data']["bespokes"];
        final isAllocated = response.data['data']["audit"]["is_allocated"];

        final cc = jsonDecode(response2.body);
        final analyticsinfo = Analyticsinfo.fromJson(cc["data"]);
        var creditCurrent = analyticsinfo.credit["current"].toString();
        final creditCurrentInt = int.tryParse(creditCurrent) ?? 0;

        num total = 0;
        List<num> real = [];

        if (seveng.isNotEmpty) {
          List<num> a = seveng
              .map((e) => num.parse(e["current"].toString()))
              .toList();

          for (var item in a) {
            real.add(int.parse(item.toString()));
          }
          for (var item in a) {
            total = total + item;
          }
        }

        _safePopDialog();

        if (isAllocated.toString() == "1") {
          _safeNavigate(
            Liabilitydetails(
              liabilityData: mapList,
              liabilityDataLite: mapListLite,
              seveng: seveng,
              bespokes: bespokes,
            ),
          );
        } else if (int.parse(creditCurrent.toString()) == 0) {
          _safeNavigate(
            Liabilitydetails(
              liabilityData: mapList,
              liabilityDataLite: mapListLite,
              seveng: seveng,
              bespokes: bespokes,
            ),
          );
        } else if (total != int.parse(creditCurrent.toString())) {
          _safeNavigate(
            Threesixty(
              unallocated: true,
              data: seveng,
              balance: seveng.isEmpty
                  ? creditCurrentInt
                  : (creditCurrentInt - total).toInt(),
            ),
          );
        } else {
          _safeNavigate(
            Liabilitydetails(
              liabilityData: mapList,
              liabilityDataLite: mapListLite,
              seveng: seveng,
              bespokes: bespokes,
            ),
          );
        }
      },
    );
  }

  void _handleTimeout() {
    _safePopDialog();
    dialogBox.information(
      context,
      'Request Timed Out',
      'This is taking longer than expected. Please check your connection and try again.',
    );
  }

  Future<void> _handleError(dynamic error, {StackTrace? stackTrace}) async {
    _safePopDialog();

    _logError(error, stackTrace);

    final classified = _classifyError(error);

    dialogBox.information(context, classified.title, classified.message);
  }

  void _logError(dynamic error, StackTrace? stackTrace) {
    debugPrint('[WheelController] Endpoint failure: $error');
    if (stackTrace != null) {
      debugPrint('[WheelController] $stackTrace');
    }
  }

  /// Maps a raw error (network, HTTP, parsing, or app-level) to a
  /// short professional title and a plain-language message that is
  /// safe to show to the user — never raw exception text or stack
  /// traces.
  ({String title, String message}) _classifyError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return (
            title: 'Request Timed Out',
            message:
                'The server took too long to respond. Please check your connection and try again.',
          );
        case DioExceptionType.connectionError:
          return (
            title: 'Connection Error',
            message:
                'Unable to reach the server. Please check your internet connection and try again.',
          );
        case DioExceptionType.badResponse:
          return (
            title: _statusTitle(error.response?.statusCode),
            message: _statusMessage(error.response?.statusCode),
          );
        case DioExceptionType.cancel:
          return (
            title: 'Request Cancelled',
            message: 'The request was cancelled before it could complete.',
          );
        case DioExceptionType.badCertificate:
        case DioExceptionType.unknown:
          return (
            title: 'Connection Error',
            message:
                'Unable to reach the server. Please check your internet connection and try again.',
          );
      }
    }

    if (error is TimeoutException) {
      return (
        title: 'Request Timed Out',
        message:
            'The server took too long to respond. Please check your connection and try again.',
      );
    }

    if (error is SocketException || error is http.ClientException) {
      return (
        title: 'Connection Error',
        message:
            'Unable to reach the server. Please check your internet connection and try again.',
      );
    }

    if (error is FormatException) {
      return (
        title: 'Data Error',
        message: 'Received an unreadable response from the server.',
      );
    }

    final raw = error?.toString() ?? '';

    if (raw.contains('Authentication token not found')) {
      return (
        title: 'Authentication Required',
        message: 'Your session has expired. Please log in again to continue.',
      );
    }

    final statusMatch = RegExp(r'Status:\s*(\d+)').firstMatch(raw);
    if (statusMatch != null) {
      return (
        title: _statusTitle(int.tryParse(statusMatch.group(1)!)),
        message: _statusMessage(int.tryParse(statusMatch.group(1)!)),
      );
    }

    if (raw.trim().isEmpty) {
      return (
        title: 'Something Went Wrong',
        message: 'An unexpected error occurred. Please try again.',
      );
    }

    return (
      title: 'Something Went Wrong',
      message: 'We couldn\'t complete that request. Please try again shortly.',
    );
  }

  String _statusTitle(int? statusCode) {
    if (statusCode == null) return 'Something Went Wrong';
    if (statusCode == 401 || statusCode == 403)
      return 'Authentication Required';
    if (statusCode == 404) return 'Not Found';
    if (statusCode >= 500) return 'Server Error';
    return 'Something Went Wrong';
  }

  String _statusMessage(int? statusCode) {
    if (statusCode == null) {
      return 'An unexpected error occurred. Please try again.';
    }
    if (statusCode == 401 || statusCode == 403) {
      return 'Your session has expired. Please log in again to continue.';
    }
    if (statusCode == 404) {
      return 'The requested information could not be found.';
    }
    if (statusCode >= 500) {
      return 'Our servers are having trouble right now. Please try again shortly.';
    }
    return 'We couldn\'t complete that request. Please try again shortly.';
  }
}
