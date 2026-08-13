import 'dart:convert';

import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'delete_account_thank_you.dart';

class DeletionRequest extends StatefulWidget {
  final String? reason;
  const DeletionRequest({super.key, required this.reason});

  @override
  State<DeletionRequest> createState() => _DeletionRequestState();
}

class _DeletionRequestState extends State<DeletionRequest> {
  bool _isLoading = false;

  Future<void> _submitDeletionRequest({bool isEnquiry = false}) async {
    if (widget.reason!.length < 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least 30 characters')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      var url = Uri.parse("$baseUrl/app/account");

      var response = await http.delete(
        url,
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
        },
        body: {'reason': widget.reason!},
      );
      print('body:${response.body}');
      print('statusCode:${response.statusCode}');
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DeleteAccountThankYou(),
          ),
        );
      } else {
        var body = jsonDecode(response.body);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${body['message']}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),

        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Illustration
                Image.asset(
                  'assets/icons/sad_heart.png', // Replace with your asset
                  height: 150,
                ),
                SizedBox(height: 32.h),

                // Title
                Text(
                  "It's sad to see you leave",
                  style: GoogleFonts.nunito(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 12.h),

                // Subtitle
                Text(
                  'If you delete, you will no longer be able to have a full view of your finances',
                  style: GoogleFonts.nunito(
                    fontSize: 16.sp,
                    color: AppColors.grayColor,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Keep using button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'I want to keep using myGAPhub',
                      style: GoogleFonts.nunito(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Delete account button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    // onPressed: () {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => const DeleteAccountThankYou(),
                    //     ),
                    //   );
                    // },
                    onPressed: _isLoading
                        ? null
                        : () => _submitDeletionRequest(isEnquiry: false),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      side: const BorderSide(color: AppColors.grayColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'I want to delete my account',
                      style: GoogleFonts.nunito(
                        fontSize: 16.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
