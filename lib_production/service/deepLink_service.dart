import 'dart:async';
import 'package:GapHub/screens/authentication/login/forgot_password/reset_password.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:GapHub/screens/authentication/login/login.dart';

class DeepLinkService {
  StreamSubscription? _sub;
  final GlobalKey<NavigatorState> navigatorKey;
  bool _isInitialUriHandled = false;
  final appLinks = AppLinks();

  // Define allowed hosts here for easy maintenance
  static const List<String> allowedHosts = [
    'app.mygaphub.com',
    'mygaphub.com',
    'www.mygaphub.com',
    'appstaging.mygaphub.com',
  ];

  DeepLinkService(this.navigatorKey);

  void initDeepLinks() {
    debugPrint('Initializing deep links...');
    _handleInitialUri().then((_) {
      _listenToUriChanges();
    });
  }

  Future<void> _handleInitialUri() async {
    if (_isInitialUriHandled) return;
    debugPrint('Handling initial URI...');

    try {
      final Uri? initialUri = await appLinks.getInitialLink();

      if (initialUri != null) {
        _isInitialUriHandled = true;
        debugPrint('📱 INITIAL DEEP LINK DETECTED: $initialUri');
        await _processDeepLink(initialUri);
      } else {
        debugPrint('No initial URI found');
      }
    } on PlatformException catch (e) {
      debugPrint('PlatformException: $e');
    } on FormatException catch (e) {
      debugPrint('Invalid URI format: $e');
    }
  }

  void _listenToUriChanges() {
    _sub = appLinks.uriLinkStream.listen(
      (Uri? uri) async {
        if (uri != null) {
          await _processDeepLink(uri);
        }
      },
      onError: (err) {
        debugPrint('Error listening to URI changes: $err');
      },
    );
  }

  Future<void> _processDeepLink(Uri uri) async {
    debugPrint('Received deep link: $uri');

    if (!(navigatorKey.currentState?.mounted ?? false)) return;

    final context = navigatorKey.currentContext;
    if (context == null) return;

    // 🔧 FIX the malformed URI first
    final fixedUri = _fixAmpEncoding(uri);

    final String host = fixedUri.host;
    final String path = fixedUri.path;

    debugPrint('Processed Host: $host');
    debugPrint('Processed Path: $path');

    // Check if host is allowed
    if (!allowedHosts.contains(host)) {
      debugPrint('❌ Host not allowed: $host');
      return;
    }

    // 1. Handle Reset Password
    if (path == '/reset-password' || path == '/app/password/reset') {
      final token = fixedUri.queryParameters['token'];
      final email = fixedUri.queryParameters['email'];
      final decodedEmail = email != null ? Uri.decodeComponent(email) : '';

      debugPrint('Token: $token');
      debugPrint('Email: $decodedEmail');

      if (token != null && token.isNotEmpty && decodedEmail.isNotEmpty) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) =>
                ResetPasswordScreen(email: decodedEmail, token: token),
          ),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Invalid reset password link. Please request a new one.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    // 2. Handle App Home
    else if (path == '/app/home') {
      debugPrint('Navigating to Login via /app/home');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Login()),
        (route) => false,
      );
    }
    // 3. Handle Account Home
    else if (path == '/account/home') {
      debugPrint('Navigating to Login via /account/home');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Login()),
        (route) => false,
      );
    } else {
      debugPrint('⚠️ Unknown deep link path: $path');
    }
  }

  // Helper method to fix the &amp; encoding issue
  Uri _fixAmpEncoding(Uri uri) {
    final originalString = uri.toString();
    final fixedString = originalString.replaceAll('&amp;', '&');
    return Uri.parse(fixedString);
  }

  void dispose() {
    _sub?.cancel();
  }
}
