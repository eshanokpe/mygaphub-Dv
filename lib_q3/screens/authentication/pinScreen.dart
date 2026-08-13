import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Models
import 'package:GapHub/models/loginusermodel.dart';

// Screens
import 'package:GapHub/screens/authentication/default.dart';
import 'package:GapHub/screens/authentication/login/login.dart';
import 'package:GapHub/screens/authentication/passcode/setpasscode.dart';
import 'package:GapHub/screens/lockscreen/passcode22.dart';
import 'package:GapHub/screens/lockscreen/touchid22.dart';

// Utils & Providers
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';

import '../lockscreen/faceID22.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final Dio _dio = Dio();
  final DialogBox _dialogBox = DialogBox();
  final _logger = _PinScreenLogger();

  Timer? _loadingTimer;
  bool _isLoading = true;
  bool _isInitializing = true;

  // Authentication states
  String _token = '';
  String _signinPreference = '';
  bool _hasPasscode = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _dio.close();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      await _loadUserPreferences();
      await _fetchUserData();
      _navigateBasedOnPreferences();
    } catch (error) {
      _logger.error('Initialization error: $error');
      _handleInitializationError(error);
    } finally {
      setState(() {
        _isInitializing = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('tokenDB') ?? '';

    if (_token.isEmpty || _token == 'logout') {
      _navigateToLogin();
      return;
    }
  }

  Future<void> _fetchUserData() async {
    if (_token.isEmpty) return;

    try {
      await Future.wait([
        _fetchUserDetails(),
        _fetchUserProfile(),
        _fetchSecurityPreferences(),
      ]);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> _fetchUserDetails() async {
    final response = await http
        .get(
          Uri.parse("$baseUrl/user"),
          headers: {"Authorization": 'Bearer $_token'},
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final loginUserModel = Loginusermodel.fromJson(jsonDecode(response.body));
      context.read<Providers>().setLoginDetails(loginUserModel);
    } else {
      throw HttpException(
        'Failed to fetch user details: ${response.statusCode}',
      );
    }
  }

  Future<void> _fetchUserProfile() async {
    final response = await http
        .get(
          Uri.parse("$baseUrl/app/profile"),
          headers: {
            "Authorization": 'Bearer $_token',
            "Accept": "application/json",
          },
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final editDetails = Editdetails.fromJson(responseBody);
      _updateUserProfile(editDetails);
    } else {
      throw HttpException(
        'Failed to fetch user profile: ${response.statusCode}',
      );
    }
  }

  void _updateUserProfile(Editdetails editDetails) {
    final user = editDetails.user;
    final profile = user["profile"];
    final providers = context.read<Providers>();

    providers.setDetailsList(user["firstname"].toString(), 0);
    providers.setDetailsList(user["surname"].toString(), 1);
    providers.setDetailsList(user["email"].toString(), 2);
    providers.setDetailsList(profile["phone"].toString(), 3);
    providers.setDetailsList(profile["date_of_birth"].toString(), 4);
    providers.setDetailsList(profile["ancesry"].toString(), 5);
    providers.setDetailsList(profile["country"].toString(), 6);

    // Handle profile image
    String imageUrl = profile["image"].toString();
    if (imageUrl.isNotEmpty && imageUrl.length >= 6) {
      imageUrl = imageUrl.replaceRange(0, 6, 'assets/storage');
      imageUrl = '$imgPrefix/$imageUrl';
    }
    providers.setDetailsList(imageUrl, 7);

    providers.setDetailsList(profile["dob_count"].toString(), 8);
    providers.setDetailsList(user["created_at"].toString(), 9);
  }

  Future<void> _fetchSecurityPreferences() async {
    try {
      final securityResponse = await _dio
          .get(
            "$baseUrl/app/settings",
            options: Options(
              headers: {
                "Authorization": 'Bearer $_token',
                "Accept": "application/json",
              },
            ),
          )
          .timeout(const Duration(seconds: 30));

      final passcodeResponse = await http
          .get(
            Uri.parse("$baseUrl/mygap/biometric"),
            headers: {
              "Authorization": 'Bearer $_token',
              "Accept": "application/json",
            },
          )
          .timeout(const Duration(seconds: 30));

      _processSecurityData(securityResponse.data, passcodeResponse.body);
    } catch (error) {
      throw HttpException('Failed to fetch security preferences: $error');
    }
  }

  void _processSecurityData(dynamic securityData, String passcodeBody) {
    final passcodeData = jsonDecode(passcodeBody);
    final passcodeHash =
        passcodeData['data']['biometric']['passcode']?.toString() ?? '';

    _hasPasscode = passcodeHash.isNotEmpty;
    _signinPreference = securityData['data']['preferences']['signin_preference']
        .toString();

    context.read<Providers>().setPref(int.parse(_signinPreference));

    _logger.info(
      'Sign-in preference: $_signinPreference, Has passcode: $_hasPasscode',
    );
  }

  void _navigateBasedOnPreferences() {
    switch (_signinPreference) {
      case '0': // Default authentication
        if (!_hasPasscode) {
          _navigateToScreen(Default());
        } else {
          _navigateToScreen(Passcode22());
        }
        break;
      case '1': // Passcode authentication
        if (!_hasPasscode) {
          _navigateToScreen(const SetPasscodeScreen(settings: false));
        } else {
          _navigateToScreen(const Touchid22());
        }
        break;
      case '2': // Touch ID authentication
        _navigateToScreen(const FaceID22());
        break;
      default:
        _navigateToLogin();
    }
  }

  void _navigateToScreen(Widget screen) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    });
  }

  void _navigateToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    });
  }

  void _handleInitializationError(dynamic error) {
    _logger.error('Initialization failed: $error');

    String errorMessage = 'An unexpected error occurred';

    if (error is DioException) {
      errorMessage = _handleDioError(error);
    } else if (error is TimeoutException) {
      errorMessage = 'Connection timeout. Please try again.';
    } else if (error is HttpException) {
      errorMessage = error.message;
    }

    Fluttertoast.showToast(
      msg: errorMessage,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );

    // Retry after delay or navigate to login
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _navigateToLogin();
      }
    });
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.badResponse:
        return _handleResponseError(error.response?.statusCode);
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.unknown:
        return 'Network error. Please check your connection.';
      default:
        return 'An unexpected error occurred.';
    }
  }

  String _handleResponseError(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please try again.';
      case 401:
        return 'Session expired. Please login again.';
      case 404:
        return 'Resource not found.';
      case 422:
        return 'Validation error. Please check your data.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'An error occurred (Code: $statusCode).';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: _buildContent());
  }

  Widget _buildContent() {
    if (_isInitializing || _isLoading) {
      return _buildLoadingScreen();
    }

    return _buildMainContent();
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SpinKitCircle(color: Colors.black, size: 60.0),
          const SizedBox(height: 20),
          Text(
            _isInitializing ? 'Initializing...' : 'Loading...',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    // This will typically navigate away quickly, but provide a fallback
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          // Text(
          //   'Authentication',
          //   style: TextStyle(
          //     fontSize: 18,
          //     fontWeight: FontWeight.w600,
          //     color: Colors.black54,
          //   ),
          // ),
          SizedBox(height: 10),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
}

// Logger utility class
class _PinScreenLogger {
  void info(String message) {
    print('🔐 PinScreen INFO: $message');
  }

  void error(String message) {
    print('❌ PinScreen ERROR: $message');
  }

  void warning(String message) {
    print('⚠️ PinScreen WARNING: $message');
  }
}

// Custom exception for HTTP errors
class HttpException implements Exception {
  final String message;
  HttpException(this.message);

  @override
  String toString() => 'HttpException: $message';
}
