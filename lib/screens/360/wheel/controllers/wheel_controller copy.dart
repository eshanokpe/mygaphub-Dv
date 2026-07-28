import 'dart:async';
import 'dart:convert';

import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/360/accounts/assetsAcc/assetdetails.dart';
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
import '../../accounts/protection/widget/retirement_dob_bottomsheet.dart';
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
    } catch (e) {
      timer.cancel();
      await _handleError(e);
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
        ]);

        final response = responses[0];
        final response2 = responses[1];

        _safePopDialog();

        // Check if responses are successful
        if (response.data['status'] != true ||
            response2.data['status'] != true) {
          throw Exception('API returned error status');
        }

        // Get the data from the response
        final netWorthData = response.data['data'];
        final equityData = response2.data['data'];

        // Get net_confirm value from the data object
        final netConfirmValue = netWorthData['isNet']?['net_confirm'];

        // Handle type conversion (it's coming as String "1")
        int? isNetConfirmed;

        if (netConfirmValue is String) {
          isNetConfirmed = int.tryParse(netConfirmValue);
        } else if (netConfirmValue is int) {
          isNetConfirmed = netConfirmValue;
        } else if (netConfirmValue is num) {
          isNetConfirmed = netConfirmValue.toInt();
        }

        debugPrint(
          'isNetConfirmed: $isNetConfirmed (original type: ${netConfirmValue.runtimeType})',
        );

        // Get equity sum - based on your response structure
        num equity = 0;

        // Your equity response has equity array, but you need the sum from somewhere
        // You might need to calculate the sum from the equity array or get it from another source
        if (equityData.containsKey('equity') && equityData['equity'] is List) {
          // If you need to calculate sum from equity list
          final equityList = equityData['equity'] as List;
          for (var item in equityList) {
            equity += num.tryParse(item['equity']?.toString() ?? '0') ?? 0;
          }
        }

        // If you need the equity from netWorthData instead
        // final equity = netWorthData['net_detail']?['equity'] ?? 0;

        if (isNetConfirmed == 0) {
          _safeNavigate(Networth(netWorthData));
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
          dio.get(
            "$baseUrl/app/360/investment",
            options: Options(headers: _getHeaders(token)),
          ),
        ]);

        final cashResponse = responses[0].data;
        final equityResponse = responses[1].data;
        final investmentResponse = responses[2].data;

        // ✅ All three are nested under 'data'
        final cashData = cashResponse['data'] as Map? ?? {};
        final equityData = equityResponse['data'] as Map? ?? {};
        final investmentData = investmentResponse['data'] as Map? ?? {};

        _safePopDialog();

        _safeNavigate(
          Assetdetails(
            cashData: cashData['cash'] ?? [],
            cashDataLite: cashData['cash_detail'] ?? {},
            seveng: cashData['seveng'] ?? [],
            equityData: equityData['equity'] ?? [],
            equityDataLite: equityData['equity_detail'] ?? {},
            bespokes: cashData['bespokes'] ?? [],
            // ✅ Fixed: was reading from wrong level
            invSum: investmentData['investment_sum'] ?? 0,
            braidTable: investmentData['braid_table'] ?? {},
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
          print("Setgiving:$data");
          _safeNavigate(Setgiving(data));
        } else {
          print("Philanthropy");
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

  void handleInvestmentTap() async {
    DialogBox dialogBox = DialogBox();

    // Set timeout timer
    Timer timer = Timer(const Duration(seconds: 40), () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      dialogBox.information(
        context,
        'Timeout Error',
        'Request timed out. Please check your internet connection and try again.',
      );
    });

    try {
      // Show loading dialog
      dialogBox.waiting(context, 'Loading investment data...');

      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('tokenDB');

      // Validate token
      if (token == null) {
        timer.cancel();
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        dialogBox.information(
          context,
          'Authentication Error',
          'Please log in again to continue.',
        );
        return;
      }

      // Make API request
      final url = Uri.parse('$baseUrl/app/360/investment');
      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 40),
            onTimeout: () {
              timer.cancel();
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              throw TimeoutException('Request timeout');
            },
          );

      // Cancel timer as request completed
      timer.cancel();

      // Handle response
      if (response.statusCode == 200) {
        final Map<String, dynamic> investmentData = jsonDecode(response.body);

        // Validate response data
        if (investmentData.containsKey('data')) {
          // Update provider
          context.read<Providers>().setinvSum(
            investmentData['data']['investment_sum'],
          );

          // Dismiss loading dialog
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          // Navigate to Investdash
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Investdash(
                sums: investmentData['data']['investment_sum'],
                braidTable: investmentData['data']['braid_table'],
              ),
            ),
          );
        } else {
          throw Exception('Invalid response format: missing investment_sum');
        }
      } else {
        // Handle error response
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        await _handleInvestmentError(response.statusCode);
      }
    } on TimeoutException catch (_) {
      // Timeout already handled in onTimeout callback
      debugPrint('Investment request timed out');
    } on http.ClientException catch (e) {
      // Handle network errors
      timer.cancel();
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      debugPrint('Network error: $e');

      dialogBox.information(
        context,
        'Connection Error',
        'Unable to connect to server. Please check your internet connection.',
      );
    } on FormatException catch (e) {
      // Handle JSON parsing errors
      timer.cancel();
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      debugPrint('JSON parsing error: $e');

      dialogBox.information(
        context,
        'Data Error',
        'Received invalid data format from server.',
      );
    } catch (e) {
      // Handle any other errors
      timer.cancel();
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      debugPrint('Unexpected error: $e');

      dialogBox.information(
        context,
        'Error',
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  Future<void> _handleInvestmentError(int statusCode) async {
    DialogBox dialogBox = DialogBox();
    String title = 'Error $statusCode';
    String message = _getErrorMessage(statusCode);

    dialogBox.information(context, title, message);
  }

  // ==================== RETIREMENT ====================

Future<void> handleRetirementTap() async {
  await _executeWithLoadingAndTimeout(
    loadingMessage: "Loading",
    action: () async {
      final token = await _getToken();
      if (token == null) throw Exception('Authentication token not found');

      final headers = _getHeaders(token);
      final results = await Future.wait([
        dio.get('$baseUrl/app/360/retirement/roi', options: Options(headers: headers)),
        dio.get('$baseUrl/app/360/retirement?archive=0&header=&access=&account=', options: Options(headers: headers)),
      ]);

      final roiResponse = results[0];
      final retirementResponse = results[1];

      debugPrint("roiResponse.statusCode: ${roiResponse.statusCode}");
      debugPrint("retirementResponse.statusCode: ${retirementResponse.statusCode}");

      // ✅ FIRST: Close loading dialog no matter what happens next
      _safePopDialog();

      // ✅ Fixed condition: show bottom sheet ONLY if EITHER status is NOT 200
      if (roiResponse.statusCode != 200 || retirementResponse.statusCode != 200) {
        if (context.mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(56.0),
                topRight: Radius.circular(56.0),
              ),
            ),
            builder: (BuildContext context) {
              return const RetirementDOBBottomSheet(title: "Date of Birth");
            },
          );
        }
        // Stop further execution here
        return;
      }

      // ✅ Only run this if BOTH statuses are 200
      final roiData = roiResponse.data['data'] as Map? ?? {};
      final retirementData = retirementResponse.data['data'] as Map? ?? {};

      debugPrint('roiData: $roiData');
      debugPrint('retirementData: $retirementData');

      if (context.mounted) {
        context.read<Providers>()
          ..setretiredata(roiData)
          ..setpensions(retirementData);

        _safeNavigate(const Retiredash());
      }
    },
  );
}

  // ==================== PROTECTION ====================

  Future<void> handleProtectionTap() async {
    await _executeWithLoadingAndTimeout(
      loadingMessage: "Loading",
      action: () async {
        final token = await _getToken();
        if (token == null) throw Exception('Authentication token not found');

        const url =
            "$baseUrl/app/360/protection";
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
          throw Exception(_getErrorMessageFromResponse(response.data));
        }

        final protectionData = _extractData(response.data) as Map? ?? {};
        final protectionList = protectionData['protection'] ?? [];
        final protectionDetailList = protectionData['protection_detail'] ?? [];
        final protectionDistribution = protectionData['protection_distribution'] ?? [];

        if (protectionList.isEmpty) {
          debugPrint('No protection data found');
        }
        print("protectionList:$protectionList");

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
    var timer = Timer(const Duration(seconds: 20), () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });

    dialogBox.waiting(context, "Loading");

    try {
      var url2 = Uri.parse('$baseUrl/app/seveng/edit');
      var url =
          "$baseUrl/app/360/liability?archive=0&header=&access=&account=&kpi=&crd=&alo=";

      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      var response = await dio.get(
        url,
        options: Options(headers: {"Authorization": 'Bearer $token'}),
      );
      var response2 = await http.get(
        url2,
        headers: {"Authorization": 'Bearer $token'},
      );

      if (response.statusCode == 200 && response2.statusCode == 200) {
        List mapList = response.data['data']["liabilities"];
        var mapListLite = response.data['data']["liabilities_detail"];
        List seveng = response.data['data']["seveng"] ?? [];
        var bespokes = response.data['data']["bespokes"];
        var isAllocated = response.data['data']["audit"]["is_allocated"];
        var creditCurrent = "0";
        int creditCurrentInt = int.tryParse(creditCurrent) ?? 0;
        var cc = jsonDecode(response2.body);
        Analyticsinfo analyticsinfo = Analyticsinfo.fromJson(cc["data"]);
        creditCurrent = analyticsinfo.credit["current"].toString();

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

        timer.cancel();

        if (isAllocated.toString() == "1") {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Liabilitydetails(
                liabilityData: mapList,
                liabilityDataLite: mapListLite,
                seveng: seveng,
                bespokes: bespokes,
              ),
            ),
          );
        } else if (int.parse(creditCurrent.toString()) == 0) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Liabilitydetails(
                liabilityData: mapList,
                liabilityDataLite: mapListLite,
                seveng: seveng,
                bespokes: bespokes,
              ),
            ),
          );
        } else if (total != int.parse(creditCurrent.toString())) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Threesixty(
                unallocated: true,
                data: seveng,
                balance: seveng.isEmpty
                    ? creditCurrentInt
                    : (creditCurrentInt - total).toInt(),
              ),
            ),
          );
        } else {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Liabilitydetails(
                liabilityData: mapList,
                liabilityDataLite: mapListLite,
                seveng: seveng,
                bespokes: bespokes,
              ),
            ),
          );
        }
      } else {
        throw Exception('Failed to load liability data');
      }
    } catch (e) {
      print('Error:$e');
      timer.cancel();

      await _handleError(e);
    }
  }

  // ==================== ERROR HANDLING ====================

  void _handleTimeout() {
    _safePopDialog();
    dialogBox.information(
      context,
      'Status',
      'Service timed out. Please try again.',
    );
  }

  Future<void> _handleError(dynamic error) async {
    _safePopDialog();

    String errorMessage = _getErrorMessage(error);

    dialogBox.information(context, 'Error', errorMessage);
  }

  String _getErrorMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred';

    if (error is Exception) {
      final errorString = error.toString();

      if (errorString.contains('token')) {
        return 'Authentication failed. Please log in again.';
      } else if (errorString.contains('timeout')) {
        return 'Connection timeout. Please check your internet connection.';
      } else if (errorString.contains('SocketException')) {
        return 'Network error. Please check your internet connection.';
      } else if (errorString.contains('format')) {
        return 'Invalid data format received from server.';
      }

      return errorString
          .replaceAll('Exception:', '')
          .replaceAll('FormatException:', '')
          .replaceAll('DioException:', '')
          .trim();
    }

    return 'An error occurred: $error';
  }
}
