import 'dart:convert';
import 'dart:io';

import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_picker/country_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';

class EditCountryScreen extends StatefulWidget {
  final String initialCountryCode;
  final List<String> details;

  const EditCountryScreen({
    super.key,
    required this.initialCountryCode,
    required this.details,
  });

  @override
  _EditCountryScreenState createState() => _EditCountryScreenState();
}

class _EditCountryScreenState extends State<EditCountryScreen> {
  late Country _selectedCountry;
  late List<Country> _allCountries;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _allCountries = CountryService().getAll();

    try {
      _selectedCountry = widget.initialCountryCode.isNotEmpty
          ? Country.parse(widget.initialCountryCode)
          : Country.parse('US');
    } catch (e) {
      _selectedCountry = Country.parse('US');
    }
  }

  void _openCountryPicker() {
    if (Platform.isIOS) {
      _showMaterialCountryPicker(); // Use Material for iOS as well
    } else {
      _showMaterialCountryPicker();
    }
  }

  void _showMaterialCountryPicker() {
    List<Country> filteredCountries = List.from(_allCountries);
    TextEditingController searchController = TextEditingController();
    bool hasText = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void filterCountries(String query) {
              setModalState(() {
                filteredCountries = _allCountries
                    .where(
                      (country) => country.name.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                    )
                    .toList();
              });
            }

            searchController.addListener(() {
              setModalState(() {
                hasText = searchController.text.isNotEmpty;
              });
            });

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.80,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle bar
                      Container(
                        width: 45.w,
                        height: 5.h,
                        decoration: BoxDecoration(
                          color: const Color(0xffcdcdcd),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Search Field
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              onChanged: filterCountries,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: const BorderSide(
                                    color: Color(0xffdddddd),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 0.5,
                                  ),
                                ),
                                hintText: 'Search ',
                                hintStyle: GoogleFonts.nunitoSans(
                                  fontSize: 14.sp,
                                  color: AppColors.grayColor,
                                ),
                                prefixIcon: IconButton(
                                  icon: Image.asset(
                                    'assets/settings/search.png',
                                    width: 20.sp,
                                    height: 20.sp,
                                    fit: BoxFit.contain,
                                  ),
                                  onPressed: () {},
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(
                                    maxWidth: 40.sp,
                                    maxHeight: 40.sp,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.h,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          hasText
                              ? GestureDetector(
                                  onTap: () {
                                    searchController.clear();
                                    filterCountries('');
                                  },
                                  child: Text(
                                    "Cancel",
                                    style: GoogleFonts.nunitoSans(
                                      color: Colors.black,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Image.asset(
                                    'assets/settings/xcancel.png',
                                    width: 20.sp,
                                    height: 20.sp,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                          SizedBox(width: 10.w),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // Country List
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredCountries.length,
                          itemBuilder: (context, index) {
                            final country = filteredCountries[index];
                            return ListTile(
                              leading: Text(
                                country.flagEmoji,
                                style: TextStyle(fontSize: 20.sp),
                              ),
                              title: Text(
                                country.name,
                                style: GoogleFonts.nunitoSans(fontSize: 16.sp),
                              ),
                              onTap: () {
                                setState(() => _selectedCountry = country);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveCountry() async {
    setState(() => _isSaving = true);

    try {
      final provider = Provider.of<Providers>(context, listen: false);
      provider.updateCountry(_selectedCountry.name);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');
      print("country:${_selectedCountry.name}");
      print("residential_country:${_selectedCountry.name}");
      var response = await http.post(
        Uri.parse("$baseUrl/app/editprofile"),
        body: {
          "firstname": widget.details[0],
          "surname": widget.details[1],
          "country": _selectedCountry.name,
          "residential_country": _selectedCountry.name,
        },
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Country updated successfully')),
        );
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom == 0
                      ? 200.h
                      : 150.h,
                ),
                Text(
                  "Add your Country of residence",
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w600,
                    color: AppColors.grayColor,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                InkWell(
                  onTap: _openCountryPicker,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _selectedCountry.flagEmoji,
                          style: GoogleFonts.nunitoSans(fontSize: 20.sp),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          _selectedCountry.name,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom == 0
                      ? 330.h
                      : 80.h,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 60.h,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveCountry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
