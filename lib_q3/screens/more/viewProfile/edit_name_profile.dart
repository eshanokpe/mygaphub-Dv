// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/show_success_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditNameScreen extends StatefulWidget {
  final String initialName;
  final bool isFirstName;

  const EditNameScreen({
    super.key,
    required this.initialName,
    required this.isFirstName,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditNameScreenState createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  late TextEditingController _nameController;
  bool _isSaving = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // 1. First update the provider
      final provider = Provider.of<Providers>(context, listen: false);
      final updatedName = _nameController.text.trim();

      if (widget.isFirstName) {
        provider.updateFirstName(updatedName);
      } else {
        provider.updateLastName(updatedName);
      }

      // 2. Then save to API
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      var url = Uri.parse("$baseUrl/app/editprofile");
      var response = await http.post(
        url,
        body: {
          "firstname": widget.isFirstName ? updatedName : provider.details[0],
          "surname": !widget.isFirstName ? updatedName : provider.details[1],
        },
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, updatedName); // Return the updated name
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return const SuccessModal(message: "Name updated successfully");
          },
        );
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('TesttName updated successfully')),
        // );
      } else if (response.statusCode == 429) {
        final body = jsonDecode(response.body);
        print('Error 429: ${body['message']}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${body['message']}')));
      } else {
        final body = jsonDecode(response.body);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${body['message']}')));
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
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom == 0
                        ? 150.h
                        : 100.h,
                  ),
                  Center(
                    child: Text(
                      widget.isFirstName
                          ? "Edit your First Name"
                          : "Edit your Last Name",
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grayColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  TextFormField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.name,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 14.h,
                        horizontal: 20.w,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom == 0
                        ? 380.h
                        : 120.h,
                  ),

                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveName,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      minimumSize: Size.fromHeight(60.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Save',
                            style: GoogleFonts.nunitoSans(
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
