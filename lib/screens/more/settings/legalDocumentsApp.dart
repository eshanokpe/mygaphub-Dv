import 'package:GapHub/screens/authentication/privacy/dataSharingScreen.dart';
import 'package:GapHub/screens/authentication/privacy/tnc.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class LegalDocumentsScreen extends StatelessWidget {
  final List<String> documents = [
    'Terms & Conditions',
    'Data Sharing Policy',
    'Privacy Policy',
  ];

   LegalDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Legal Documents",
          style: GoogleFonts.nunitoSans(
            color: Colors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        children: [
          _buildListItem(context, 'Terms & Conditions', const Tnc(tnc: true)),
          SizedBox(height: 24.h),
          _buildListItem(
            context,
            'Data Sharing Policy',
            const DataSharingScreen(),
          ),
          SizedBox(height: 24.h),
          _buildListItem(context, 'Privacy Policy', const Tnc(tnc: false)),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, String title, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      child: Text(
        title,
        style: GoogleFonts.nunitoSans(
          color: Colors.black,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
