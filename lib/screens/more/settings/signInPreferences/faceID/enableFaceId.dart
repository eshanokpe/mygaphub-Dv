import 'dart:convert';

import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../../../provider/signin_preferences_provider.dart';

class EnableFaceIdScreen extends StatefulWidget {
  const EnableFaceIdScreen({super.key});

  @override
  State<EnableFaceIdScreen> createState() => _EnableFaceIdScreenState();
}

class _EnableFaceIdScreenState extends State<EnableFaceIdScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final signInPrefsProvider = Provider.of<SignInPreferencesProvider>(
      context,
      listen: false,
    );
    signInPrefsProvider.fetchSignInPreferences();
    signInPrefsProvider.fetchPasscodeStatus();
  }

  Future<void> enableFaceID() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');

    if (token != null && token != 'logout') {
      try {
        var url = Uri.parse('$baseUrl/app/settings/preferences');

        var response = await http.put(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: json.encode({'signin_preference': '2'}),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Face ID enabled successfully')),
          );
          // Return true to indicate successful enabling
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to enable Face ID')),
          );
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Show the custom pre-permission dialog
  void showFaceIDPermissionDialog() {
    showCupertinoDialog(
      context: context,
      builder: (_) => Container(
        width: 420.w,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40.r),
          child: CupertinoAlertDialog(
            title: Text(
              'Do you want to allow "GAPhub" to use Face ID?',
              style: GoogleFonts.nunitoSans(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Text(
                "In order to allow for quick and secure login, we need your permission to use Face ID. Would you like to continue?",
                style: GoogleFonts.nunitoSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(
                    context,
                  ); // Just pop the dialog, don't return false
                  setState(() {
                    isLoading = false;
                  });
                },
                isDefaultAction: false,
                isDestructiveAction: true,
                child: Text(
                  "Don't Allow",
                  style: GoogleFonts.nunitoSans(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff0f77f0),
                  ),
                ),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                  enableFaceID();
                },
                isDefaultAction: true,
                child: Text(
                  "Allow",
                  style: GoogleFonts.nunitoSans(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff0f77f0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 150.h),

            // Face ID icon
            Image.asset('assets/settings/faceId_enable.png', width: 100.w),

            SizedBox(height: 40.h),

            // Title
            Text(
              'Would you like to use Face ID to sign in every time?',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 16.h),

            // Subtitle
            Text(
              'This will simplify the process, allowing you to access your app without the need for your password or passcode.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                fontSize: 16.sp,
                color: AppColors.grayColor,
                fontWeight: FontWeight.w400,
              ),
            ),

            const Spacer(),

            // Enable Face ID button triggers the custom dialog
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : showFaceIDPermissionDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : Text(
                        'Enable Face ID',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
