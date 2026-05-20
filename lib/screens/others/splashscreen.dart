import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:GapHub/models/loginusermodel.dart';
import 'package:GapHub/screens/authentication/default.dart';
import 'package:GapHub/screens/authentication/faceID/faceID.dart';
import 'package:GapHub/screens/authentication/login/login.dart';
import 'package:GapHub/screens/authentication/passcode/passcode.dart';
import 'package:GapHub/screens/authentication/touchID/touchid.dart';
import 'package:GapHub/screens/onboarding/onboarding.dart';
import 'package:GapHub/service/navigation_service.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../provider/notification_provider.dart';

// Add the missing Editdetails model
class Editdetails {
  final Map<String, dynamic> user;

  Editdetails({required this.user});

  factory Editdetails.fromJson(Map<String, dynamic> json) {
    return Editdetails(user: json['user'] ?? {});
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  Dio dio = Dio();
  DialogBox dialogBox = DialogBox();
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  bool _isInitializing = false; // Prevent duplicate initialization
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 SplashScreen initState called');

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('📱 Post-frame callback - starting app initialization');
      _startAppInitialization();
    });
  }

  Future<void> _startAppInitialization() async {
    // Prevent multiple simultaneous initializations
    if (_isInitializing) {
      debugPrint('⚠️ Initialization already in progress, skipping');
      return;
    }

    _isInitializing = true;

    try {
      debugPrint('🔄 Starting app initialization sequence');

      // Start animation
      _animationController.forward();

      // Run initialization tasks in sequence
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Brief delay for smoothness

      await _checkForInitialDeepLink();
      await _initializeNotifications();
      await _determineNavigation();

      debugPrint('✅ App initialization completed successfully');
    } catch (e) {
      debugPrint('❌ Initialization error: $e');
      _handleInitializationError(e.toString());
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _checkForInitialDeepLink() async {
    try {
      debugPrint('🔗 Checking for initial deep link');
      final appLinks = AppLinks();
      final Uri? initialUri = await appLinks.getInitialLink();

      if (initialUri != null) {
        debugPrint('📲 App launched with deep link: $initialUri');

        // Store the deep link to process after auth
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_deep_link', initialUri.toString());
      } else {
        debugPrint('📱 No initial deep link found');
      }
    } catch (e) {
      debugPrint('⚠️ Error checking initial deep link: $e');
      // Don't fail initialization for deep link errors
    }
  }

  Future<void> _initializeNotifications() async {
    try {
      debugPrint('🔔 Initializing notifications');
      final context = NavigationService2.navigatorKey.currentContext;
      var currency = context?.watch<Providers>().snapshotmodel.currency;

      if (context != null) {
        final provider = Provider.of<NotificationProvider>(
          context,
          listen: false,
        );
        await provider.ensureInitialLoad(currency!);
        debugPrint('✅ Notifications initialized');
      } else {
        debugPrint('⚠️ Notification context not available yet');
      }
    } catch (e) {
      debugPrint('⚠️ Error loading notifications: $e');
      // Don't fail the whole app if notifications fail
    }
  }

  Future<void> _determineNavigation() async {
    debugPrint('🧭 Determining navigation path');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');

    debugPrint('🔑 Token status: ${token != null ? "Found" : "Not found"}');

    if (token == null || token == 'logout' || token.isEmpty) {
      debugPrint('➡️ Navigating to Onboarding (no valid token)');
      _navigateToOnboarding();
      return;
    }

    try {
      // Set loading state
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      debugPrint('🔄 Validating token and fetching user data');
      await getUserData(token);
    } catch (e) {
      debugPrint('❌ Token validation failed: $e');
      await prefs.remove('tokenDB');
      _navigateToLogin();
    }
  }

  Future<void> getUserData(String token) async {
    try {
      debugPrint('📊 Starting getUserData with token');

      // User details
      final userResponse = await http
          .get(
            Uri.parse("$baseUrl/user"),
            headers: {"Authorization": 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('👤 User response status: ${userResponse.statusCode}');

      if (userResponse.statusCode != 200) {
        throw Exception('Failed to get user data: ${userResponse.statusCode}');
      }

      final Map<String, dynamic> userData = jsonDecode(userResponse.body);
      final loginusermodel = Loginusermodel.fromJson(userData);

      if (!mounted) return;

      context.read<Providers>().setLoginDetails(loginusermodel);

      // Profile details
      final profileResponse = await http
          .get(
            Uri.parse("$baseUrl/app/profile"),
            headers: {
              "Authorization": 'Bearer $token',
              "Accept": "application/json",
            },
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('📋 Profile response status: ${profileResponse.statusCode}');

      if (profileResponse.statusCode != 200) {
        throw Exception(
          'Failed to get profile data: ${profileResponse.statusCode}',
        );
      }

      final Map<String, dynamic> profileBody = jsonDecode(profileResponse.body);
      final Editdetails editdetails = Editdetails.fromJson(profileBody);

      // Set profile details
      setProfileDetails(editdetails);

      // Get security preferences
      final securityResponse = await dio
          .get(
            "$baseUrl/app/settings",
            options: Options(
              headers: {
                "Authorization": 'Bearer $token',
                "Accept": "application/json",
              },
            ),
          )
          .timeout(const Duration(seconds: 30));

      // Get passcode status
      final passcodeResponse = await http
          .get(
            Uri.parse("$baseUrl/mygap/biometric"),
            headers: {
              "Authorization": 'Bearer $token',
              "Accept": "application/json",
            },
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('🔐 Passcode response status: ${passcodeResponse.statusCode}');

      if (passcodeResponse.statusCode != 200) {
        throw Exception(
          'Failed to get passcode status: ${passcodeResponse.statusCode}',
        );
      }

      final Map<String, dynamic> responseData = jsonDecode(
        passcodeResponse.body,
      );
      final Map<String, dynamic> biometricData =
          responseData['data']?['biometric'] ?? {};
      final passcodeHash = biometricData['passcode']?.toString() ?? '';
      debugPrint(
        '🔑 Passcode hash: ${passcodeHash.isNotEmpty ? "Exists" : "Empty"}',
      );
      final hasPasscode = passcodeHash.isNotEmpty;

      // Safely get signin preference
      String signinPreference = '0'; // default value
      try {
        final Map<String, dynamic> securityData =
            securityResponse.data?['data'] ?? {};
        final Map<String, dynamic> preferences =
            securityData['preferences'] ?? {};
        signinPreference = preferences['signin_preference']?.toString() ?? '0';
      } catch (e) {
        debugPrint('⚠️ Error parsing security preferences: $e');
      }

      debugPrint('⚙️ Signin preference: $signinPreference');
      debugPrint('🔐 Has passcode: $hasPasscode');

      if (mounted) {
        context.read<Providers>().setPref(int.parse(signinPreference));
      }

      // Navigate based on preferences
      _navigateBasedOnPreferences(signinPreference, hasPasscode);
    } on TimeoutException {
      _showErrorAndNavigate('Connection timeout');
    } on SocketException {
      _showErrorAndNavigate('No internet connection');
    } on DioException catch (e) {
      _handleDioError(e);
      _showErrorAndNavigate('Network error occurred');
    } catch (e) {
      debugPrint('❌ Unexpected error in getUserData: $e');
      _showErrorAndNavigate('An unexpected error occurred');
    }
  }

  void setProfileDetails(Editdetails editdetails) {
    try {
      final Map<String, dynamic> user = editdetails.user;
      final Map<String, dynamic> profile = user["profile"] is Map
          ? Map<String, dynamic>.from(user["profile"])
          : {};

      if (!mounted) return;

      final providers = context.read<Providers>();

      providers.setDetailsList(user["firstname"]?.toString() ?? '', 0);
      providers.setDetailsList(user["surname"]?.toString() ?? '', 1);
      providers.setDetailsList(user["email"]?.toString() ?? '', 2);
      providers.setDetailsList(profile["phone"]?.toString() ?? '', 3);
      providers.setDetailsList(profile["date_of_birth"]?.toString() ?? '', 4);
      providers.setDetailsList(profile["ancesry"]?.toString() ?? '', 5);
      providers.setDetailsList(profile["country"]?.toString() ?? '', 6);

      // Handle profile image
      String imgurl = profile["image"]?.toString() ?? '';
      if (imgurl.isNotEmpty && imgurl.length >= 6) {
        imgurl = imgurl.replaceRange(0, 6, 'assets/storage');
        imgurl = '$imgPrefix/$imgurl';
      }
      providers.setDetailsList(imgurl, 7);

      debugPrint('✅ Profile details loaded successfully');
    } catch (e) {
      debugPrint('⚠️ Error setting profile details: $e');
      // Initialize with empty values if there's an error
      if (mounted) {
        final providers = context.read<Providers>();
        for (int i = 0; i < 8; i++) {
          providers.setDetailsList('', i);
        }
      }
    }
  }

  void _navigateBasedOnPreferences(String signinPreference, bool hasPasscode) {
    debugPrint('🚦 Navigating based on preferences');
    debugPrint('- Signin preference: $signinPreference');
    debugPrint('- Has passcode: $hasPasscode');

    if (!mounted) return;

    Widget nextScreen;

    switch (signinPreference) {
      case '0': // Default authentication
        if (!hasPasscode) {
          debugPrint('➡️ Navigating to Default authentication');
          nextScreen = Default();
        } else {
          debugPrint('➡️ Navigating to Passcode authentication');
          nextScreen = Passcode();
        }
        break;
      case '1': // Touch ID authentication
        debugPrint('➡️ Navigating to Touch ID authentication');
        nextScreen = const TouchID(settings: false);
        break;
      case '2': // Face ID authentication
        debugPrint('➡️ Checking device for Face ID authentication');
        if (Platform.isIOS) {
          debugPrint('📱 iOS device - Navigating to Face ID authentication');
          nextScreen = const FaceIDScreen();
        } else {
          debugPrint(
            '📱 Android device - Face ID not available, navigating to default authentication',
          );
          if (!hasPasscode) {
            nextScreen = Default();
          } else {
            nextScreen = Passcode();
          }
        }
        break;
      default:
        debugPrint('➡️ Navigating to Login (invalid preference)');
        nextScreen = Login();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  void _handleDioError(DioException e) {
    debugPrint('🌐 Dio error: ${e.type}');

    String message = 'Network error';
    if (e.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      message = 'Receive timeout';
    } else if (e.type == DioExceptionType.badResponse) {
      switch (e.response?.statusCode) {
        case 400:
          message = 'Bad request';
          break;
        case 401:
          message = 'Unauthorized - Please login again';
          break;
        case 404:
          message = 'Not found';
          break;
        case 500:
          message = 'Server error';
          break;
        default:
          message = 'Request failed';
      }
    }

    Fluttertoast.showToast(msg: message);
  }

  void _navigateToOnboarding() {
    if (mounted) {
      debugPrint('➡️ Navigating to Onboarding');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Onboarding(false)),
      );
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      debugPrint('➡️ Navigating to Login');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }

  void _handleInitializationError(String error) {
    if (mounted) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Failed to initialize app. Please restart.';
      });

      debugPrint('❌ Initialization error: $error');

      // Auto-recover after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _navigateToLogin();
        }
      });
    }
  }

  void _showErrorAndNavigate(String message) {
    if (mounted) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = message;
      });

      Fluttertoast.showToast(msg: message);
      debugPrint('❌ Error: $message');

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _navigateToLogin();
        }
      });
    }
  }

  Widget _buildLogo() {
    try {
      return Lottie.asset(
        'assets/images/logoo.json',
        height: 400.h,
        controller: _animationController,
        onLoaded: (composition) {
          _animationController
            ..duration = composition.duration
            ..forward();
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Lottie error: $error');
          return Container(
            height: 400.h,
            width: 400.h,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Icon(Icons.error_outline, size: 80.h, color: Colors.grey),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('❌ Error loading Lottie animation: $e');
      return Container(
        height: 400.h,
        width: 400.h,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Icon(Icons.error_outline, size: 80.h, color: Colors.grey),
        ),
      );
    }
  }

  @override
  void dispose() {
    debugPrint('🗑️ SplashScreen dispose called');
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(),
            SizedBox(height: 20.h),
            if (isLoading)
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            if (hasError && errorMessage != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Redirecting to login...',
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
