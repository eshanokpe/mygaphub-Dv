// providers/auth_provider.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:GapHub/screens/more/settings/signInPreferences/changePasscode.dart';
import 'package:GapHub/screens/others/dashboards/dashboard.dart';
import 'package:GapHub/screens/registration/calculation/multi_form.dart';
import 'package:GapHub/screens/registration/calculation/precalc.dart';
import 'package:GapHub/screens/registration/financial_health/prequestions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/models/loginusermodel.dart';
import 'package:GapHub/models/sevengeemodel.dart';
import 'package:GapHub/models/snapshotmodel.dart';
import 'package:GapHub/models/token_model.dart';
import 'package:GapHub/utils/constants.dart';
import 'providers.dart';

class AuthProvider with ChangeNotifier {
  final Dio _dio = Dio();
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isAuthenticated = false;
  String? _authToken;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  String? get authToken => _authToken;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _setError('');
  }

  // ─── Real-time analytics refresh ─────────────────────────────────────────
  // Called from Dashboard on mount and every 30 seconds via Timer.periodic.
  // Hits GET /app/seveng/edit, parses the response, and pushes the result
  // into Providers via setAnalyticsInfo — triggering only the widgets that
  // watch analyticsinfo to rebuild, leaving everything else untouched.
  Future<void> fetchAnalyticsInfo(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      // Guard: no token or logged out — nothing to fetch
      if (token == null || token == 'logout' || token.isEmpty) return;

      final analytics = await _fetchAnalytics(token);

      if (analytics != null && context.mounted) {
        Provider.of<Providers>(context, listen: false)
            .setAnalyticsInfo(analytics);
      }
    } catch (e) {
      // Silent fail — dashboard already has cached data from login,
      // so a failed refresh should never disrupt the UI
      print('fetchAnalyticsInfo error: $e');
    }
  }

  Future<bool> signIn(
    String email,
    String password,
    BuildContext context,
  ) async {
    _setLoading(true);
    _setError('');

    try {
      // await logout(context);
      // final providers = Provider.of<Providers>(context, listen: false);
      // providers.clearAllData();
      await _clearStoredToken();
      Provider.of<Providers>(context, listen: false).clearAllData();


      final token = await _authenticateUser(email, password);
      print('Authenticated token: $token');

      await _clearStoredToken();
      await _storeToken(token);
      _authToken = token;

      final additionalData = await _loadEssentialData(token, context);

      _isAuthenticated = true;
      _setLoading(false);

      if (additionalData['success'] == true) {
        print('additionalData: ${additionalData['success']}');
        _navigateBasedOnData(context, additionalData);
        return true;
      } else {
        _setError(additionalData['error'] ?? 'Failed to load user data');
        return false;
      }
    } on TimeoutException catch (_) {
      _setError('Connection timed out. Please try again.');
      _setLoading(false);
      return false;
    } on SocketException catch (_) {
      _setError('Network connection failed. Please check your internet.');
      _setLoading(false);
      return false;
    } catch (e) {
      print('SignIn Error: $e');
      _handleError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<Map<String, dynamic>> loadEssentialData(
    String token,
    BuildContext context,
  ) async {
    return await _loadEssentialData(token, context);
  }

  Future<Map<String, dynamic>> _loadEssentialData(
    String token,
    BuildContext context,
  ) async {
    try {
      final providers = Provider.of<Providers>(context, listen: false);

      final results = await Future.wait([
        _fetchUserDetails(
          token,
        ).catchError((e) => _handleApiError('UserDetails', e)),
        _fetchEditDetails(
          token,
        ).catchError((e) => _handleApiError('EditDetails', e)),
        _fetchSnapshot(token).catchError((e) => _handleApiError('Snapshot', e)),
        _fetchSevenG(token).catchError((e) => _handleApiError('SevenG', e)),
        _fetchCalculator(
          token,
        ).catchError((e) => _handleApiError('Calculator', e)),
        _fetchSupport(token).catchError((e) => _handleApiError('Support', e)),
        _fetchDashboard(
          token,
        ).catchError((e) => _handleApiError('Dashboard', e)),
        _fetchPortfolio(
          token,
        ).catchError((e) => _handleApiError('Portfolio', e)),
        _fetchRecentTiles(
          token,
        ).catchError((e) => _handleApiError('RecentTiles', e)),
        _fetchAnalytics(
          token,
        ).catchError((e) => _handleApiError('Analytics', e)),
      ], eagerError: true);

      final loginusermodel =
          results[0] as Loginusermodel? ?? Loginusermodel.empty();
      final editdetails = results[1] as Editdetails? ?? Editdetails.empty();
      final snapshotmodel =
          results[2] as Snapshotmodel? ?? Snapshotmodel.empty();
      final sevengeemodel =
          results[3] as Sevengeemodel? ?? Sevengeemodel.empty();
      final calculatorData = results[4] ?? {};
      final supportData = results[5] ?? [];
      final dashboardData = results[6] as Map<String, dynamic>? ?? {};
      final portfolioData = results[7] ?? {};
      final recentData = results[8] ?? [];
      final analyticsData = results[9];

      // Set login details and user info
      providers.setLoginDetails(loginusermodel);
      providers.setDetailsList(loginusermodel.firstname ?? '', 0);
      providers.setDetailsList(loginusermodel.surname ?? '', 1);
      providers.setDetailsList(loginusermodel.email ?? '', 2);

      // Process edit details
      _processEditDetails(editdetails, providers);

      // Set all other data
      providers.setSupport(supportData);
      providers.setSnapshot(snapshotmodel);
      providers.setCurrentPortfolio(snapshotmodel.financial["portfolio"] ?? 0);
      providers.setSevenGee(sevengeemodel);
      providers.setCalculator(calculatorData);
      providers.setDashData(dashboardData);

      if (portfolioData != null) providers.setPortfolio(portfolioData);
      if (recentData != null) providers.setRecent(recentData);
      if (analyticsData != null) providers.setAnalyticsInfo(analyticsData);

      // Calculate total steps for navigation logic
      num tot = 0;
      for (var a in sevengeemodel.steps) {
        tot = tot + (a ?? 0);
      }

      bool allBackgroundsGray = sevengeemodel.backgrounds.every(
        (element) => element == '#494949',
      );
      String currency = snapshotmodel.currency;

      if ((tot != 0 || !allBackgroundsGray) && currency != "") {
        print("correct");

        if (_isSevenGIncomplete(sevengeemodel)) {
          print("7G questions incomplete, redirecting to prequestions");
          return {'success': true, 'route': 'prequestions'};
        }

        if (dashboardData.isNotEmpty &&
            dashboardData["gap_currencies"] != null) {
          final gapCurrencies = dashboardData["gap_currencies"] as Map? ?? {};
          providers.setCurrency(gapCurrencies["user_currency"] ?? '');
          providers.setManualCurrency(gapCurrencies["manual_currencies"] ?? {});
          providers.setSystemCurrency(gapCurrencies["system_currencies"] ?? {});
          providers.setAssistance(dashboardData["assistance"] ?? {});
        }

        print("All checks passed, redirecting to dashboard");
        return {'success': true, 'route': 'dashboard', 'index': 0};
      } else if (tot == 0 && currency == "") {
        print("No steps and no currency, redirecting to precalc");
        return {'success': true, 'route': 'precalc'};
      } else if (tot == 0 && currency != "") {
        final String calculatorCurrency = calculatorData["currency"] ?? "";
        print("Calculator currency: $calculatorCurrency");

        if (calculatorCurrency.isNotEmpty) {
          final num savingsValue = _parseNum(
            calculatorData["periodic_savings"],
          );
          final num educationValue = _parseNum(calculatorData["education"]);
          final num mortgageValue = _parseNum(calculatorData["mortgage"]);
          final num mobilityValue = _parseNum(calculatorData["mobility"]);
          final num expensesValue = _parseNum(calculatorData["expenses"]);
          final num utilityValue = _parseNum(calculatorData["utility"]);
          final num debtRepayValue = _parseNum(calculatorData["dept_repay"]);
          final num charityValue = _parseNum(calculatorData["charity"]);
          final num otherIncomeValue = _parseNum(
            calculatorData["other_income"],
          );
          final num extraSaveValue = _parseNum(calculatorData["extra_save"]);

          print(
            "Calculator values - extraSave: $extraSaveValue, otherIncome: $otherIncomeValue",
          );

          if (extraSaveValue == 0 && otherIncomeValue == 0) {
            print('Redirecting to multiStepForm page 1');
            return {
              'success': true,
              'route': 'multiStepForm',
              'initialPage': 1,
              'currentPageIndex': 1,
            };
          } else if (savingsValue == 0 &&
              educationValue == 0 &&
              mortgageValue == 0 &&
              mobilityValue == 0 &&
              expensesValue == 0 &&
              utilityValue == 0 &&
              debtRepayValue == 0 &&
              charityValue == 0) {
            print('Redirecting to multiStepForm page 0');
            return {
              'success': true,
              'route': 'multiStepForm',
              'initialPage': 0,
              'currentPageIndex': 0,
            };
          } else if (extraSaveValue > 0 || otherIncomeValue > 0) {
            print("Redirecting to multiStepForm page 2");
            return {
              'success': true,
              'route': 'multiStepForm',
              'initialPage': 2,
              'currentPageIndex': 2,
            };
          } else {
            print('Redirecting to multiStepForm page 1 (fallback)');
            return {
              'success': true,
              'route': 'multiStepForm',
              'initialPage': 1,
              'currentPageIndex': 1,
            };
          }
        } else {
          print('Calculator currency empty, redirecting to prequestions');
          return {'success': true, 'route': 'precalc'};
        }
      } else {
        print('No specific condition matched, defaulting to dashboard');
        return {'success': true, 'route': 'dashboard', 'index': 0};
      }
    } catch (e) {
      print('Error loading essential data: $e');
      print('Stack trace: ${e.toString()}');
      return {'success': false, 'error': e.toString()};
    }
  }

  num _parseNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) {
      return num.tryParse(value) ?? 0;
    }
    return 0;
  }

  bool _isSevenGIncomplete(Sevengeemodel sevengeemodel) {
    final questions = sevengeemodel.questions;

    return [null, "", "0", 0].contains(questions.step1) ||
        [null, "", "0", 0].contains(questions.step2) ||
        [null, "", "0", 0].contains(questions.step3) ||
        [null, "", "0", 0].contains(questions.step4) ||
        [null, "", "0", 0].contains(questions.step5) ||
        [null, "", "0", 0].contains(questions.step6) ||
        [null, "", "0", 0].contains(questions.step7);
  }

  void _navigateBasedOnData(BuildContext context, Map<String, dynamic> data) {
    final route = data['route'];
    print('route: $route');
    switch (route) {
      case 'dashboard':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard(index: 0)),
        );
        break;
      case 'prequestions':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Prequestions()),
        );
        break;
      case 'precalc':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Precalc()),
        );
        break;
      case 'multiStepForm':
        final initialPage = data['initialPage'] ?? 0;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MultiStepForm(
              initialPage: initialPage,
              currentPageIndex: initialPage,
            ),
          ),
        );
        break;
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard(index: 0)),
        );
    }
  }

  Future<void> _clearStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tokenDB');
  }

  Future<bool> signInPassCode(
    String email,
    String password,
    BuildContext context,
    String source,
  ) async {
    _setLoading(true);
    _setError('');

    try {
      final token = await _authenticateUser(email, password);

      await _storeToken(token);
      _authToken = token;

      final results = await Future.wait([
        _fetchUserDetails(token),
      ], eagerError: true);

      final loginusermodel = results[0];
      final providers = Provider.of<Providers>(context, listen: false);
      providers.setLoginDetails(loginusermodel);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangePasscodeScreen(source: source),
        ),
      );
      _isAuthenticated = true;
      _setLoading(false);

      return true;
    } on TimeoutException catch (_) {
      _setError('Connection timed out. Please try again.');
      _setLoading(false);
      return false;
    } on SocketException catch (_) {
      _setError('Network connection failed. Please check your internet.');
      _setLoading(false);
      return false;
    } catch (e) {
      _handleError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<Map<String, dynamic>> signInDetails(BuildContext context) async {
    _setLoading(true);
    _setError('');

    Timer? timer;
    try {
      final prefs = await SharedPreferences.getInstance();
      var finalToken = prefs.getString('tokenDB');

      if (finalToken == null || finalToken.isEmpty) {
        _setError('No authentication token found');
        _setLoading(false);
        return {'success': false, 'error': 'No authentication token found'};
      }

      timer = Timer(const Duration(milliseconds: 50000), () {
        _setError('Service timed out');
        _setLoading(false);
      });

      await _storeToken(finalToken);
      _authToken = finalToken;

      final results = await Future.wait([
        _fetchUserDetails(
          finalToken,
        ).catchError((e) => _handleApiError('UserDetails', e)),
        _fetchEditDetails(
          finalToken,
        ).catchError((e) => _handleApiError('EditDetails', e)),
        _fetchSnapshot(
          finalToken,
        ).catchError((e) => _handleApiError('Snapshot', e)),
        _fetchSevenG(
          finalToken,
        ).catchError((e) => _handleApiError('SevenG', e)),
        _fetchCalculator(
          finalToken,
        ).catchError((e) => _handleApiError('Calculator', e)),
        _fetchSupport(
          finalToken,
        ).catchError((e) => _handleApiError('Support', e)),
        _fetchDashboard(
          finalToken,
        ).catchError((e) => _handleApiError('Dashboard', e)),
        _fetchPortfolio(
          finalToken,
        ).catchError((e) => _handleApiError('Portfolio', e)),
        _fetchRecentTiles(
          finalToken,
        ).catchError((e) => _handleApiError('RecentTiles', e)),
        _fetchAnalytics(
          finalToken,
        ).catchError((e) => _handleApiError('Analytics', e)),
      ], eagerError: true);

      final loginusermodel =
          results[0] as Loginusermodel? ?? Loginusermodel.empty();
      final editdetails = results[1] as Editdetails? ?? Editdetails.empty();
      final snapshotmodel =
          results[2] as Snapshotmodel? ?? Snapshotmodel.empty();
      final sevengeemodel =
          results[3] as Sevengeemodel? ?? Sevengeemodel.empty();
      final calculatorData = results[4] ?? {};
      final supportData = results[5] ?? [];
      final dashboardData = results[6] as Map<String, dynamic>? ?? {};
      final portfolioData = results[7] ?? {};
      final recentData = results[8] ?? [];
      final analyticsData = results[9];

      if (dashboardData.containsKey('workflowComplete') &&
          dashboardData['workflowComplete'] == false) {
        final workflowMessage =
            dashboardData['message'] ??
            'The calculator workflow has not been completed yet';

        print('🔔 Workflow incomplete: $workflowMessage');

        timer.cancel();
        _setLoading(false);

        return {
          'success': false,
          'error': workflowMessage,
          'workflowIncomplete': true,
          'message': workflowMessage,
        };
      }

      final providers = Provider.of<Providers>(context, listen: false);

      providers.setLoginDetails(loginusermodel);
      providers.setDetailsList(loginusermodel.firstname ?? '', 0);
      providers.setDetailsList(loginusermodel.surname ?? '', 1);
      providers.setDetailsList(loginusermodel.email ?? '', 2);

      _processEditDetails(editdetails, providers);

      providers.setSupport(supportData);
      providers.setSnapshot(snapshotmodel);
      providers.setCurrentPortfolio(snapshotmodel.financial["portfolio"] ?? 0);
      providers.setSevenGee(sevengeemodel);
      providers.setCalculator(calculatorData);
      providers.setDashData(dashboardData);

      if (portfolioData != null) providers.setPortfolio(portfolioData);
      if (recentData != null) providers.setRecent(recentData);
      if (analyticsData != null) providers.setAnalyticsInfo(analyticsData);

      final gapCurrencies = dashboardData["gap_currencies"] as Map? ?? {};
      providers.setCurrency(gapCurrencies["user_currency"] ?? '');
      providers.setManualCurrency(gapCurrencies["manual_currencies"] ?? {});
      providers.setSystemCurrency(gapCurrencies["system_currencies"] ?? {});
      providers.setAssistance(dashboardData["assistance"] ?? {});

      num tot = 0;
      for (var a in sevengeemodel.steps) {
        tot = (tot + (a ?? 0));
      }

      bool allBackgroundsGray = sevengeemodel.backgrounds.every(
        (element) => element == '#494949',
      );

      final hasSevenGQuestions = !_isSevenGIncomplete(sevengeemodel);

      timer.cancel();
      _isAuthenticated = true;
      _setLoading(false);
      print("tot:$tot");
      print("allBackgroundsGray:$allBackgroundsGray");
      print("currency:${snapshotmodel.currency}");
      print("financial:${snapshotmodel.financial["cost"]}");
      print("hasSevenGQuestions:$hasSevenGQuestions");

      if (tot != 0 &&
          snapshotmodel.currency != "" &&
          snapshotmodel.financial["cost"] != "0") {
        print("dashboard:");
        if (hasSevenGQuestions) {
          return {'success': true, 'route': 'dashboard', 'index': 0};
        } else {
          print("prequestions:");
          return {'success': true, 'route': 'prequestions'};
        }
      } else if (tot == 0 &&
          snapshotmodel.currency == "" &&
          snapshotmodel.financial["cost"].toString() == "0") {
        return {'success': true, 'route': 'precalc'};
      } else {
        final String currency = calculatorData["currency"] ?? "";
        final num savingsValue = _parseNum(calculatorData["periodic_savings"]);
        final num educationValue = _parseNum(calculatorData["education"]);
        final num mortgageValue = _parseNum(calculatorData["mortgage"]);
        final num mobilityValue = _parseNum(calculatorData["mobility"]);
        final num expensesValue = _parseNum(calculatorData["expenses"]);
        final num utilityValue = _parseNum(calculatorData["utility"]);
        final num debtRepayValue = _parseNum(calculatorData["dept_repay"]);
        final num charityValue = _parseNum(calculatorData["charity"]);
        final num otherIncomeValue = _parseNum(calculatorData["other_income"]);
        final num extraSaveValue = _parseNum(calculatorData["extra_save"]);

        if (currency.isNotEmpty) {
          if (extraSaveValue == 0 && otherIncomeValue == 0) {
            print('multiStepForm1');
            return {
              'success': true,
              'route': 'multiStepForm',
              'initialPage': 1,
              'currentPageIndex': 1,
            };
          } else if (savingsValue == 0 &&
              educationValue == 0 &&
              mortgageValue == 0 &&
              mobilityValue == 0 &&
              expensesValue == 0 &&
              utilityValue == 0 &&
              debtRepayValue == 0 &&
              charityValue == 0) {
            print('multiStepForm0');
            return {
              'success': true,
              'route': 'multiStepForm',
              'initialPage': 0,
              'currentPageIndex': 0,
            };
          } else if (extraSaveValue == 0 || otherIncomeValue == 0) {
            print("extraSaveValue:$extraSaveValue");
            print("otherIncomeValue:$otherIncomeValue");
            print('multiStepForm2');
            return {
              'success': true,
              'route': 'multiStepForm',
              'initialPage': 2,
              'currentPageIndex': 2,
            };
          } else {
            return {'success': true, 'route': 'prequestions'};
          }
        } else {
          return {'success': true, 'route': 'prequestions'};
        }
      }
    } on TimeoutException catch (_) {
      timer?.cancel();
      _setError('Connection took too long to respond.');
      _setLoading(false);
      return {'success': false, 'error': 'Connection timeout'};
    } on SocketException catch (_) {
      timer?.cancel();
      _setError('Connection took too long to respond.');
      _setLoading(false);
      return {'success': false, 'error': 'Network error'};
    } catch (e) {
      timer?.cancel();
      _handleDetailedError(e, context);
      _setLoading(false);
      return {'success': false, 'error': e.toString()};
    }
  }

  void _handleDetailedError(dynamic e, BuildContext context) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          _setError('Connection timeout. Please try again.');
          break;
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          switch (statusCode) {
            case 400:
              _setError('Incorrect Details');
              break;
            case 401:
              _setError('You are Unauthorized');
              break;
            case 405:
              _setError('Wrong method used.');
              break;
            case 404:
              _setError('Url/Data not found');
              break;
            case 422:
              _setError('422: Critical error');
              break;
            case 500:
              _setError('Server Error');
              break;
            default:
              _setError('An error occurred');
          }
          break;
        case DioExceptionType.cancel:
          _setError('Connection Cancelled');
          break;
        case DioExceptionType.receiveTimeout:
          _setError('Connection took too long to respond.');
          break;
        case DioExceptionType.unknown:
          _setError('Invalid format');
          break;
        default:
          _setError('Network connection failed');
      }
    } else if (e is TimeoutException) {
      _setError('Connection took too long to respond.');
    } else if (e is SocketException) {
      _setError('Connection took too long to respond.');
    } else {
      _setError(e.toString());
    }
  }

  Future<String> _authenticateUser(String email, String password) async {
    final client = http.Client(); // fresh client, no stale keep-alive
    try {
      final response = await client
          .post(
            Uri.parse("$baseUrl/mygap/login"),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'X-API-KEY': 'pT79hjfC91lG7gViU3tSHixtxlZZfvUBfDFeOFKP',
              'Connection': 'close', // tell server not to keep-alive
            },
            body: {"email": email, "password": password},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final tokenData = Token.fromJSON(jsonDecode(response.body));
        return tokenData.token;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else if (response.statusCode == 400) {
        var error = jsonDecode(response.body)['message'];
        throw Exception(error);
      } else {
        throw Exception('Failed to authenticate: ${response.statusCode}');
      }
    } finally {
      client.close(); // always release the connection
    }
  }

  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tokenDB', token);
  }

  void _processEditDetails(Editdetails editdetails, Providers providers) {
    providers.setDetailsList(editdetails.user["firstname"] ?? '', 0);
    providers.setDetailsList(editdetails.user["surname"]?.toString() ?? '', 1);
    providers.setDetailsList(editdetails.user["email"]?.toString() ?? '', 2);
    providers.setDetailsList(
      editdetails.user["profile"]?["phone"]?.toString() ?? '',
      3,
    );
    providers.setDetailsList(
      editdetails.user["profile"]?["date_of_birth"]?.toString() ?? '',
      4,
    );
    providers.setDetailsList(
      editdetails.user["profile"]?["ancesry"]?.toString() ?? '',
      5,
    );
    providers.setDetailsList(
      editdetails.user["profile"]?["country"]?.toString() ?? '',
      6,
    );

    String imgurl = editdetails.user["profile"]?["image"]?.toString() ?? '';
    if (imgurl.isNotEmpty && imgurl.length >= 6) {
      imgurl = imgurl.replaceRange(0, 6, 'assets/storage');
      imgurl = '$imgPrefix/$imgurl';
    }
    providers.setDetailsList(imgurl, 7);

    providers.setDetailsList(
      editdetails.user["profile"]?["dob_count"]?.toString() ?? '',
      8,
    );
    providers.setDetailsList(
      editdetails.user["created_at"]?.toString() ?? '',
      9,
    );
  }

  Future<Loginusermodel> _fetchUserDetails(String token) async {
    final response = await http
        .get(
          Uri.parse("$baseUrl/user"),
          headers: {"Authorization": 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print("Loginusermodel:$jsonData");
      return Loginusermodel.fromJson(jsonData);
    } else {
      print("${response.statusCode}");
      throw Exception('Too many response');
    }
  }

  Future<Editdetails> _fetchEditDetails(String token) async {
    final response = await http
        .get(
          Uri.parse("$baseUrl/app/profile"),
          headers: {
            "Authorization": 'Bearer $token',
            "Accept": "application/json",
          },
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Editdetails.fromJson(jsonData);
    } else {
      throw Exception('Failed to load edit details: ${response.statusCode}');
    }
  }

  Future<Snapshotmodel> _fetchSnapshot(String token) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/app/snapshot'),
          headers: {"Authorization": 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print("Snapshotmodel:$jsonData");

      final dataField = jsonData['data'];
      if (dataField == null) {
        throw Exception('No data field in response');
      }

      return Snapshotmodel.fromJson(dataField);
    } else {
      throw Exception('Failed to load snapshot: ${response.statusCode}');
    }
  }

  Future<Sevengeemodel> _fetchSevenG(String token) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/app/seveng'),
          headers: {"Authorization": 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Sevengeemodel.fromJson(jsonData);
    } else {
      throw Exception('Failed to load 7G data: ${response.statusCode}');
    }
  }

  Future<dynamic> _fetchSupport(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/app/support"),
            headers: {"Authorization": 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['data']?['gap_supports']?['data'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching support: $e');
      return [];
    }
  }

  Future<dynamic> _fetchCalculator(String token) async {
    try {
      final response = await http
          .get( 
            Uri.parse("$baseUrl/app/calculator"),
            headers: {"Authorization": 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));
      print("_fetchCalculator:${response}");
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['data'] ?? {};
      } else {
        return {};
      }
    } catch (e) {
      print('Error fetching calculator: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> _fetchDashboard(String token) async {
    try {
      final response = await _dio.get(
        "$baseUrl/app/dashboard",
        options: Options(
          headers: {"Authorization": 'Bearer $token'},
          validateStatus: (status) => status! < 500,
        ),
      );

      var result = response.data;
      print("_fetchDashboard Result:$result");
      if (result == null) {
        print('⚠️ Dashboard API returned null');
        return _getEmptyDashboardResponse();
      }

      if (result is! Map) {
        print('⚠️ Dashboard API returned non-map response: $result');
        return _getEmptyDashboardResponse();
      }

      if (result.containsKey('status') &&
          result['status'] == true &&
          result.containsKey('message') &&
          result['message'] ==
              'The calculator workflow has not been completed yet') {
        print('ℹ️ Dashboard workflow incomplete: ${result['message']}');

        return {
          'status': true,
          'message': result['message'],
          'workflowComplete': false,
          'gap_currencies': {},
          'assistance': {},
          'dashboard': {},
        };
      }

      final Map<String, dynamic> safeResult = {};

      if (result['gap_currencies'] is Map) {
        safeResult['gap_currencies'] = Map<String, dynamic>.from(
          result['gap_currencies'] as Map,
        );
      } else {
        safeResult['gap_currencies'] = {};
      }

      if (result['assistance'] is Map) {
        safeResult['assistance'] = Map<String, dynamic>.from(
          result['assistance'] as Map,
        );
      } else {
        safeResult['assistance'] = {};
      }

      safeResult['workflowComplete'] = true;

      result.forEach((key, value) {
        if (key != 'gap_currencies' && key != 'assistance') {
          safeResult[key] = value;
        }
      });

      return safeResult;
    } on DioException catch (e) {
      print('❌ DioError in _fetchDashboard: ${e.message}');
      return _getEmptyDashboardResponse();
    } catch (e) {
      print('❌ Unexpected error in _fetchDashboard: $e');
      return _getEmptyDashboardResponse();
    }
  }

  Map<String, dynamic> _getEmptyDashboardResponse() {
    return {
      'status': false,
      'workflowComplete': false,
      'gap_currencies': {},
      'assistance': {},
      'dashboard': {},
    };
  }

  Future<dynamic> _fetchPortfolio(String token) async {
    try {
      final response = await _dio
          .get(
            "$baseUrl/app/portfolio",
            options: Options(headers: {"Authorization": 'Bearer $token'}),
          )
          .timeout(const Duration(seconds: 15));

      return response.data ?? {};
    } catch (e) {
      print('Error fetching portfolio: $e');
      return {};
    }
  }

  Future<dynamic> _fetchRecentTiles(String token) async {
    try {
      final response = await _dio
          .get(
            "$baseUrl/app/360/tiles",
            options: Options(headers: {"Authorization": 'Bearer $token'}),
          )
          .timeout(const Duration(seconds: 15));

      return response.data?["tiles"] ?? [];
    } catch (e) {
      print('Error fetching recent tiles: $e');
      return [];
    }
  }

  Future<Analyticsinfo?> _fetchAnalytics(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/app/seveng/edit'),
            headers: {"Authorization": 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Analyticsinfo.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching analytics: $e');
      return null;
    }
  }

  void _handleError(dynamic e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          _setError('Connection timeout. Please try again.');
          break;
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          switch (statusCode) {
            case 400:
              _setError('Incorrect login details');
              break;
            case 401:
              _setError(
                'Authentication failed. Please check your credentials.',
              );
              break;
            case 404:
              _setError('Service not available');
              break;
            case 500:
              _setError('Server error. Please try again later.');
              break;
            default:
              _setError('Network error: $statusCode');
          }
          break;
        default:
          _setError('Network connection failed');
      }
    } else if (e is TimeoutException) {
      _setError('Request timed out. Please try again.');
    } else if (e.toString().contains('Invalid email or password')) {
      _setError('Invalid email or password. Please try again.');
    } else {
      _setError(e.toString());
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tokenDB', 'logout');
    await prefs.remove('tokenDB');
    _authToken = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  dynamic _handleApiError(
    String apiName,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    print('Error in $apiName API: $error');
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
    throw error;
  }
}