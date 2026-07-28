import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class SignInPreferencesProvider with ChangeNotifier {
  bool _isFaceIdEnabled = false;
  bool _isTouchIdEnabled = false;
  String? _signinPreference;
  bool _hasPasscode = false;
  bool _isLoading = true;
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Biometric capabilities
  bool _supportsFaceId = false;
  bool _supportsTouchId = false;
  bool _biometricsChecked = false;

  bool get isFaceIdEnabled => _isFaceIdEnabled;
  bool get isTouchIdEnabled => _isTouchIdEnabled;
  String? get signinPreference => _signinPreference;
  bool get hasPasscode => _hasPasscode;
  bool get isLoading => _isLoading;
  bool get supportsFaceId => _supportsFaceId;
  bool get supportsTouchId => _supportsTouchId;
  bool get hasBiometricCapability => _supportsFaceId || _supportsTouchId;

  /// Update toggle states based ONLY on the current signin preference
  /// Ignore device biometric capabilities for toggle state
  void _updateToggleStatesFromPreference() {
    if (_signinPreference == null) {
      _isFaceIdEnabled = false;
      _isTouchIdEnabled = false;
      return;
    }

    // Reset both to false first
    _isFaceIdEnabled = false;
    _isTouchIdEnabled = false;

    switch (_signinPreference) {
      case '1': // Touch ID selected
        _isTouchIdEnabled = true;
        _isFaceIdEnabled = false; // Ensure Face ID is off
        break;
      case '2': // Face ID selected
        _isFaceIdEnabled = true;
        _isTouchIdEnabled = false; // Ensure Touch ID is off
        break;
      case '0': // None selected
      default:
        _isFaceIdEnabled = false;
        _isTouchIdEnabled = false;
        break;
    }
  }

  /// Check device biometric capabilities
  Future<void> checkDeviceCapabilities() async {
    try {
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;

      if (kDebugMode) {
        print("Device supported: $isDeviceSupported");
        print("Can check biometrics: $canCheckBiometrics");
      }

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (kDebugMode) {
        print("Available biometrics: $availableBiometrics");
      }

      // Reset capabilities
      _supportsFaceId = false;
      _supportsTouchId = false;

      // Check specific biometric types
      for (final biometric in availableBiometrics) {
        switch (biometric) {
          case BiometricType.face:
            _supportsFaceId = true;
            break;
          case BiometricType.fingerprint:
            _supportsTouchId = true;
            break;
          case BiometricType.iris:
            _supportsFaceId = true;
            break;
          default:
            break;
        }
      }

      // Android-specific fallback
      if (defaultTargetPlatform == TargetPlatform.android) {
        if (isDeviceSupported && !_supportsFaceId && !_supportsTouchId) {
          _supportsTouchId = true;
        }
      }

      _biometricsChecked = true;

      if (kDebugMode) {
        print("Device capabilities:");
        print("  - Supports Face ID: $_supportsFaceId");
        print("  - Supports Touch ID: $_supportsTouchId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in checkDeviceCapabilities: $e");
      }
      _supportsFaceId = false;
      _supportsTouchId = false;
      _biometricsChecked = true;
    }
  }

  /// Fetch all preferences and capabilities
  Future<void> fetchAllPreferences() async {
    _setLoading(true);

    try {
      await checkDeviceCapabilities();
      await Future.wait([fetchSignInPreferences(), fetchPasscodeStatus()]);

      // Update toggle states based on preference (regardless of device capabilities)
      _updateToggleStatesFromPreference();
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch signin preference from backend
  Future<void> fetchSignInPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      if (token != null && token != 'logout') {
        var securityUrl = Uri.parse("$baseUrl/app/settings");

        var response = await http.get(
          securityUrl,
          headers: {
            "Authorization": 'Bearer $token',
            "Accept": "application/json",
          },
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final newSigninPreference =
              responseData['data']['preferences']['signin_preference']
                  ?.toString();

          if (kDebugMode) {
            print(
              "Fetched from backend - signinPreference: $newSigninPreference",
            );
          }

          _signinPreference = newSigninPreference;

          // Update toggle states based on the preference
          _updateToggleStatesFromPreference();

          if (kDebugMode) {
            print("After fetch:");
            print("  - signinPreference: $_signinPreference");
            print("  - Face ID toggle: $_isFaceIdEnabled");
            print("  - Touch ID toggle: $_isTouchIdEnabled");
          }
        } else {
          if (kDebugMode) {
            print("Failed to fetch preferences: ${response.statusCode}");
          }
        }
      } else {
        if (kDebugMode) {
          print("No valid token found");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to fetch signin preferences: $e");
      }
    }
  }

  /// Check if passcode has been set
  Future<void> fetchPasscodeStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      if (token != null && token != 'logout') {
        var passcodeUrl = Uri.parse("$baseUrl/mygap/biometric");

        var response = await http.get(
          passcodeUrl,
          headers: {
            "Authorization": 'Bearer $token',
            "Accept": "application/json",
          },
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final passcodeHash = responseData['data']['biometric']['passcode'];

          _hasPasscode =
              passcodeHash != null && passcodeHash.toString().isNotEmpty;

          if (kDebugMode) {
            print("Passcode status: $_hasPasscode");
          }
        } else {
          _hasPasscode = false;
          if (kDebugMode) {
            print("Failed to fetch passcode status: ${response.statusCode}");
          }
        }
      } else {
        _hasPasscode = false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to fetch passcode status: $e");
      }
      _hasPasscode = false;
    }
  }

  /// Update signin preference
  Future<void> updateSignInPreference(String newPreference) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      if (token != null && token != 'logout') {
        var url = Uri.parse("$baseUrl/app/settings/preferences");

        if (kDebugMode) {
          print("Updating preference to: $newPreference");
        }

        var response = await http.put(
          url,
          headers: {
            "Authorization": 'Bearer $token',
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
          body: jsonEncode({"signin_preference": newPreference}),
        );

        if (response.statusCode == 200) {
          _signinPreference = newPreference;
          _updateToggleStatesFromPreference();

          if (kDebugMode) {
            print("Successfully updated preference:");
            print("  - New signinPreference: $_signinPreference");
            print("  - Face ID toggle: $_isFaceIdEnabled");
            print("  - Touch ID toggle: $_isTouchIdEnabled");
          }

          notifyListeners(); // Ensure UI is updated
        } else {
          if (kDebugMode) {
            print(
              "Failed to update preference: ${response.statusCode} - ${response.body}",
            );
          }
          // Force refresh from server on failure
          await fetchSignInPreferences();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error saving preference: $e");
      }
      // Force refresh from server on error
      await fetchSignInPreferences();
    }
  }

  /// Handle biometric toggle with INSTANT UI response and proper mutual exclusion
  /// Handle biometric toggle with INSTANT UI response and proper mutual exclusion
  void handleBiometricToggle(String biometricType, bool newValue) async {
    if (kDebugMode) {
      print("=== HANDLE BIOMETRIC TOGGLE ===");
      print("  - Type: $biometricType");
      print("  - NewValue: $newValue");
      print("  - Current signinPreference: $_signinPreference");
      print("  - Current Face ID enabled: $_isFaceIdEnabled");
      print("  - Current Touch ID enabled: $_isTouchIdEnabled");
      print("  - Has passcode: $_hasPasscode");
    }

    // Store current state in case we need to revert
    final String? previousPreference = _signinPreference;
    final bool previousFaceIdState = _isFaceIdEnabled;
    final bool previousTouchIdState = _isTouchIdEnabled;

    await fetchPasscodeStatus();

    // Check if passcode is required for enabling
    if (!_hasPasscode && newValue) {
      if (kDebugMode) {
        print("Cannot enable biometric without passcode");
      }
      // Re-fetch to ensure UI is in sync
      await fetchSignInPreferences();
      notifyListeners();
      return;
    }

    String newPreference;

    if (newValue) {
      // Enabling a biometric - set the corresponding preference and disable the other
      if (biometricType == 'face') {
        newPreference = '2'; // Face ID
        if (kDebugMode) {
          print("Enabling Face ID, disabling Touch ID");
        }
      } else {
        newPreference = '1'; // Touch ID
        if (kDebugMode) {
          print("Enabling Touch ID, disabling Face ID");
        }
      }
    } else {
      // Disabling a biometric - set preference to none
      newPreference = '0';
      if (kDebugMode) {
        print("Disabling biometric - setting preference to none");
      }
    }

    // INSTANT UI UPDATE: Update state optimistically before API call
    if (kDebugMode) {
      print("Before optimistic update:");
      print("  - signinPreference: $_signinPreference");
      print("  - Face ID enabled: $_isFaceIdEnabled");
      print("  - Touch ID enabled: $_isTouchIdEnabled");
    }

    _signinPreference = newPreference;
    _updateToggleStatesFromPreference();

    if (kDebugMode) {
      print("After optimistic update (MUTUAL EXCLUSION CHECK):");
      print("  - signinPreference: $_signinPreference");
      print("  - Face ID enabled: $_isFaceIdEnabled");
      print("  - Touch ID enabled: $_isTouchIdEnabled");
      print("  - Expected: Only one should be true");
    }

    notifyListeners(); // Force UI update immediately

    // Then make the API call
    try {
      await updateSignInPreference(newPreference);

      // After API call, ensure UI is in sync by refreshing all data
      await fetchAllPreferences();

      if (kDebugMode) {
        print("After API call and refresh (FINAL STATE):");
        print("  - signinPreference: $_signinPreference");
        print("  - Face ID enabled: $_isFaceIdEnabled");
        print("  - Touch ID enabled: $_isTouchIdEnabled");
      }
    } catch (e) {
      if (kDebugMode) {
        print("API call failed, reverting UI state: $e");
      }
      // Revert to previous state on failure
      _signinPreference = previousPreference;
      _isFaceIdEnabled = previousFaceIdState;
      _isTouchIdEnabled = previousTouchIdState;
      notifyListeners();
    }

    if (kDebugMode) {
      print("=== END HANDLE BIOMETRIC TOGGLE ===");
    }
  }

  /// Check if a biometric toggle should be interactive
  /// Now only depends on passcode, not device capabilities/// Check if a biometric toggle should be interactive
  bool isBiometricToggleInteractive(String biometricType) {
    // The toggle should be interactive only if:
    // 1. The device supports this biometric type
    // 2. User has set up a passcode
    final bool isSupported = biometricType == 'face'
        ? _supportsFaceId
        : _supportsTouchId;

    return isSupported && _hasPasscode;
  }

  /// Get the display state for a biometric option
  BiometricDisplayState getBiometricDisplayState(String biometricType) {
    final bool isSupported = biometricType == 'face'
        ? _supportsFaceId
        : _supportsTouchId;
    final bool isEnabled = biometricType == 'face'
        ? _isFaceIdEnabled
        : _isTouchIdEnabled;
    final bool isInteractive = isBiometricToggleInteractive(biometricType);

    return BiometricDisplayState(
      isSupported: isSupported,
      isEnabled: isEnabled,
      isInteractive: isInteractive,
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Refresh all data and ensure UI is updated
  Future<void> refreshAllData() async {
    await fetchAllPreferences();
    notifyListeners(); // Force UI update
  }

  /// Force refresh all data and update UI
  Future<void> forceRefreshAllData() async {
    _setLoading(true);
    try {
      await checkDeviceCapabilities();
      await Future.wait([fetchSignInPreferences(), fetchPasscodeStatus()]);
      _updateToggleStatesFromPreference();
    } finally {
      _setLoading(false);
    }
    notifyListeners(); // Force UI update
  }

  
}

class BiometricDisplayState {
  final bool isSupported;
  final bool isEnabled;
  final bool isInteractive;

  BiometricDisplayState({
    required this.isSupported,
    required this.isEnabled,
    required this.isInteractive,
  });
}
