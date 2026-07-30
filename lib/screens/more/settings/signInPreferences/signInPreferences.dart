import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/provider/signin_preferences_provider.dart';
import 'package:GapHub/screens/authentication/passcode/setpasscode.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../passcode/enterPasscode.dart';
import 'custom_toggle.dart';
import 'faceID/enableFaceId.dart';
import 'touchID/enabletouchID.dart';

class SignInPreferences extends StatefulWidget {
  final SignInPreferencesProvider provider; // ✅ final added
  const SignInPreferences({super.key, required this.provider});

  @override
  _SignInPreferencesState createState() => _SignInPreferencesState();
}

class _SignInPreferencesState extends State<SignInPreferences> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // ✅ No loading state — refresh silently in background
    widget.provider
        .forceRefreshAllData()
        .then((_) {
          if (mounted) setState(() {});
        })
        .catchError((error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to load preferences')),
            );
          }
        });
  }

  Map<String, dynamic> _getPasscodeInfo(SignInPreferencesProvider provider) {
    if (provider.signinPreference == '1' || provider.signinPreference == '2') {
      if (provider.hasPasscode) {
        return {
          'text': 'Change passcode',
          'color': Colors.black,
          'isClickable': true,
        };
      } else {
        return {
          'text': 'Set up your passcode now',
          'color': AppColors.primaryColor,
          'isClickable': true,
        };
      }
    }

    if (provider.hasPasscode) {
      return {
        'text': 'Change passcode',
        'color': Colors.black,
        'isClickable': true,
      };
    } else {
      return {
        'text': 'Set up your passcode now',
        'color': AppColors.primaryColor,
        'isClickable': true,
      };
    }
  }

  void _handlePasscodeAction(SignInPreferencesProvider provider) {
    print('🔥 _handlePasscodeAction called');
    print('🔥 hasPasscode: ${provider.hasPasscode}');

    if (provider.hasPasscode) {
      print('🔥 navigating to EnterPasscodeScreen');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EnterPasscodeScreen()),
      ).then((result) {
        if (result == true) _showSuccessModal();
      });
    } else {
      print('🔥 navigating to SetPasscodeScreen');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SetPasscodeScreen(settings: false),
        ),
      ).then((result) {
        if (result == true) _showSuccessModal();
        provider.forceRefreshAllData().then((_) {
          if (mounted) setState(() {});
        });
      });
    }
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBFBFB),
                    border: Border.all(
                      color: const Color(0xFFEEEEEE),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 120.w,
                    vertical: 5.w,
                  ),
                  child: Image.asset(
                    'assets/images/thankYou.png',
                    height: 100.h,
                    width: 100.w,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Congratulations! You have successfully changed your sign-in passcode.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.provider.forceRefreshAllData().then((_) {
                        if (mounted) setState(() {});
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                        side: BorderSide(
                          color: AppColors.borderColor,
                          width: 0.5.w,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBiometricToggle(
    String title,
    String description,
    String biometricType,
    SignInPreferencesProvider provider,
  ) {
    final displayState = provider.getBiometricDisplayState(biometricType);
    final bool isSupported = displayState.isSupported;
    final bool isEnabled = displayState.isEnabled;
    final bool isInteractive = displayState.isInteractive;

    String statusMessage = '';
    Color statusColor = Colors.grey;

    if (!isSupported) {
      statusMessage = 'Not supported on this device';
      statusColor = Colors.orange;
    } else if (!provider.hasPasscode) {
      statusMessage = 'Set up passcode to enable';
      statusColor = Colors.orange;
    } else if (!isInteractive) {
      statusMessage = 'Disabled';
      statusColor = Colors.grey;
    }

    return Opacity(
      opacity: isSupported ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !isInteractive,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        description,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 14.sp,
                          color: AppColors.grayColor,
                        ),
                      ),
                      if (statusMessage.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          statusMessage,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12.sp,
                            color: statusColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                InkWell(
                  onTap: () {
                    if (!isInteractive) return;
                    _handleBiometricToggleTap(
                      biometricType,
                      isEnabled,
                      provider,
                    );
                  },
                  child: AbsorbPointer(
                    child: CustomToggle(
                        key: ValueKey('$biometricType-$isEnabled'),
                        onChanged: (_) {},
                        value: isEnabled,
                        type: CustomToggleType.ios,
                        trackWidth: 44,
                        enabledTrackColor: AppColors.primaryColor,
                        disabledTrackColor: Colors.grey[300],
                        enabledThumbColor: Colors.white,
                        disabledThumbColor: Colors.white,
                      
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  void _handleBiometricToggleTap(
    String biometricType,
    bool isEnabled,
    SignInPreferencesProvider provider,
  ) {
    final newValue = !isEnabled;
    if (kDebugMode) {
      print('$biometricType toggle tapped: $newValue');
    }

    if (biometricType == 'face' && newValue) {
      _navigateToEnableFaceIdScreen(provider);
    } else if (biometricType == 'touch' && newValue) {
      _navigateToEnableTouchIdScreen(provider);
    } else {
      provider.handleBiometricToggle(biometricType, newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SignInPreferencesProvider>(
      builder: (context, provider, child) {
        _checkMutualExclusionState(provider);
        final passcodeInfo = _getPasscodeInfo(provider);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black),
            title: Text(
              'Sign-In Preferences',
              style: GoogleFonts.nunitoSans(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
                size: 20.sp,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Passcode',
                            style: GoogleFonts.nunitoSans(
                              color: passcodeInfo['color'],
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Use this to log in each time',
                            style: GoogleFonts.nunitoSans(
                              color: AppColors.grayColor,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: passcodeInfo['isClickable']
                            ? () => _handlePasscodeAction(provider)
                            : null,
                        child: Text(
                          passcodeInfo['text'],
                          style: GoogleFonts.nunitoSans(
                            color: AppColors.primaryColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40.h),

                _buildBiometricToggle(
                  'Face ID',
                  'Access your account easily with one scan',
                  'face',
                  provider,
                ),

                _buildBiometricToggle(
                  'Touch ID',
                  'Access your account easily with one touch',
                  'touch',
                  provider,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToEnableFaceIdScreen(SignInPreferencesProvider provider) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EnableFaceIdScreen()),
    );

    await provider.forceRefreshAllData();
    if (mounted) setState(() {});
  }

  void _navigateToEnableTouchIdScreen(
    SignInPreferencesProvider provider,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EnableTouchIdScreen()),
    );

    await provider.forceRefreshAllData();
    if (mounted) setState(() {});

    if (result == true && kDebugMode) {
      print("After Touch ID enabled:");
      print("  - signinPreference: ${provider.signinPreference}");
      print("  - Face ID enabled: ${provider.isFaceIdEnabled}");
      print("  - Touch ID enabled: ${provider.isTouchIdEnabled}");
    }
  }

  void _checkMutualExclusionState(SignInPreferencesProvider provider) {}
}
