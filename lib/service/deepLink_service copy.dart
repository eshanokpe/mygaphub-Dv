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
        debugPrint('Initial URI received: $initialUri');
        debugPrint('📱 INITIAL DEEP LINK DETECTED: $initialUri');
        debugPrint('Scheme: ${initialUri.scheme}');
        debugPrint('Host: ${initialUri.host}');
        debugPrint('Path: ${initialUri.path}');
        debugPrint('Query: ${initialUri.query}');
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
    debugPrint('Received deep host: ${uri.host}');
    debugPrint('Received deep path: ${uri.path}');

    if (!(navigatorKey.currentState?.mounted ?? false)) return;

    final context = navigatorKey.currentContext;
    if (context == null) return;

    // 🔧 FIX the malformed URI first
    final fixedUri = _fixAmpEncoding(uri);
    debugPrint('Fixed URI: $fixedUri');
    debugPrint('Fixed query parameters: ${fixedUri.queryParameters}');

    // Deep link route matching
    final isResetPasswordLink =
        (fixedUri.host == 'mygaphub.com' ||
            fixedUri.host == 'app.mygaphub.com' ||
            fixedUri.host == 'https://app.mygaphub.com' ||
            fixedUri.host == 'www.mygaphub.com' ||
            fixedUri.host == 'appstaging.mygaphub.com' ||
            fixedUri.host == 'app') &&
        (fixedUri.path == '/reset-password' ||
            fixedUri.path == '/app/password/reset');

    if (isResetPasswordLink) {
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
    // Handle other links
    else if ((fixedUri.host == 'mygaphub.com' ||
            fixedUri.host == 'app.mygaphub.com' ||
            fixedUri.host == 'www.mygaphub.com' ||
            fixedUri.host == 'https://app.mygaphub.com' ||
            fixedUri.host == 'appstaging.mygaphub.com') &&
        fixedUri.path == '/app/home') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Login()),
        (route) => false,
      );
    } else if ((fixedUri.host == 'mygaphub.com' ||
            fixedUri.host == 'www.mygaphub.com' ||
            fixedUri.host == 'app.mygaphub.com' ||
            fixedUri.host == 'https://app.mygaphub.com' ||
            fixedUri.host == 'appstaging.mygaphub.com') &&
        fixedUri.path == '/account/home') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Login()),
        (route) => false,
      );
    } else {
      debugPrint('Unknown deep link: $fixedUri');
    }
  }

  // Helper method to fix the &amp; encoding issue
  Uri _fixAmpEncoding(Uri uri) {
    final originalString = uri.toString();
    // Replace &amp; with & to fix the encoding issue
    final fixedString = originalString.replaceAll('&amp;', '&');
    return Uri.parse(fixedString);
  }

  void dispose() {
    _sub?.cancel();
  }
}
