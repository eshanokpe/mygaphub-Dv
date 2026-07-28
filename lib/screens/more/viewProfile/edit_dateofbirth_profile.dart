import 'dart:convert';
import 'dart:io';

import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'view_profile.dart';

class EditDateOfBirthScreen extends StatefulWidget {
  final String initialDate;
  final List<String> details;
  final String? sourcePage;

  const EditDateOfBirthScreen({
    super.key,
    required this.initialDate,
    required this.details,
    this.sourcePage,
  });

  @override
  _EditDateOfBirthScreenState createState() => _EditDateOfBirthScreenState();
}

class _EditDateOfBirthScreenState extends State<EditDateOfBirthScreen> {
  late DateTime _selectedDate;
  bool _isSaving = false;
  final bool _pickerShown = false;

  @override
  void initState() {
    super.initState();
    _selectedDate =
        DateTime.tryParse(widget.initialDate) ?? DateTime(1997, 9, 27);
    // Show the material date picker immediately for Android (not iOS)
    if (!Platform.isIOS) {
      // Delay to ensure context is available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMaterialDatePicker();
      });
    }
  }

  Widget _buildPlatformDatePicker() {
    if (Platform.isIOS) {
      return Container(
        height: 300.h,
        decoration: const BoxDecoration(color: Color(0xffd0d3da)),
        child: Localizations.override(
          context: context,
          locale: const Locale('en', 'GB'), // UK English uses day-month-year
          child: CupertinoDatePicker(
            initialDateTime: _selectedDate,
            mode: CupertinoDatePickerMode.date,
            maximumDate: DateTime.now(),
            minimumYear: 1900,
            onDateTimeChanged: (DateTime newDate) {
              setState(() => _selectedDate = newDate);
            },
          ),
        ),
      );
    } else {
      // For Android, you can use a custom date picker or show buttons to open the dialog
      // Since flutter_holo_date_picker only works as a dialog, we'll use a different approach
      return const SizedBox.shrink();
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy').format(date);
  }

  // String _formatDateDDMMMMYYYY(DateTime date) {
  //   return DateFormat(
  //     'dd-MMMM-yyyy',
  //   ).format(date); // This will output "27-September-1997"
  // }

  Future<void> _saveDateOfBirth() async {
    setState(() => _isSaving = true);

    try {
      final provider = Provider.of<Providers>(context, listen: false);
      provider.updateDateOfBirth(_selectedDate.toIso8601String());

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      var url = Uri.parse("$baseUrl/app/editprofile");
      var response = await http.post(
        url,
        body: {
          "firstname": widget.details[0],
          "surname": widget.details[1],
          "date_of_birth": _selectedDate.toIso8601String(),
        },
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Date of birth updated successfully')),
        );
        // ✅ Only close both screens if coming from Retirement page
        if (widget.sourcePage == 'retirement') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ViewProfile(),
            ),
          );
        } else {
          // ✅ Normal flow for all other pages
          Navigator.pop(context);
        }
      } else if (response.statusCode == 429) {
        final body = jsonDecode(response.body);
        print('Error 429: ${body['message']}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${body['message']}')));
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        var error = responseBody['errors']?['date_of_birth'];
        if (error is List && error.isNotEmpty) {
          error = error.first;
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error?.toString() ?? 'Unknown error')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: MediaQuery.of(context).viewInsets.bottom == 0
                    ? 150.h
                    : 100.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Center(
                  child: Text(
                    "Add your Date of Birth",
                    style: GoogleFonts.nunitoSans(
                      fontSize: 15.sp,
                      color: AppColors.grayColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatDate(_selectedDate),
                    style: GoogleFonts.nunitoSans(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              // Adjust spacing based on whether picker is shown
              // This creates space at the bottom when picker is not shown
              SizedBox(height: _pickerShown ? 100.h : 100.h),

              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),

                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveDateOfBirth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Save',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 17.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              _buildPlatformDatePicker(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMaterialDatePicker() async {
    final picked = await DatePicker.showSimpleDatePicker(
      context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      dateFormat: "dd-MMMM-yyyy",
      looping: true,
      titleText: "Set date",
      confirmText: "SET",
      cancelText: "CANCEL",
      reverse: true,
      itemTextStyle: TextStyle(
        fontSize: 14.sp,
        color: Colors.black,
        fontWeight: FontWeight.w400,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
