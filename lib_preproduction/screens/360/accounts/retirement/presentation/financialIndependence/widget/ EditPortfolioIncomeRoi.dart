import 'dart:convert';

import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditPortfolioIncomeRoi extends StatefulWidget {
  final double investmentAmount;
  const EditPortfolioIncomeRoi({
    super.key,
    required this.investmentAmount,
  });

  @override
  _EditPortfolioIncomeRoiState createState() => _EditPortfolioIncomeRoiState();
}

class _EditPortfolioIncomeRoiState extends State<EditPortfolioIncomeRoi> {
  late TextEditingController _roceController;
  late FocusNode _inputFocusNode;
  bool _isSaving = false;
  bool _isEditing = false; // ✅ Defined here
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late int _initialRoce;

  @override
  void initState() {
    super.initState();
    _roceController = TextEditingController();
    _inputFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final providers = Provider.of<Providers>(context, listen: false);
    final retireData = providers.retiredata;
    final rawRoce = _parseToDouble(retireData['improve_status']['roce']);
    _initialRoce = rawRoce < 1 ? 1 : rawRoce.round();
    _roceController.text = _initialRoce.toString();
  }

  double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  ({String whole, String decimal}) _splitAmount(String value) {
    final clean = value.replaceAll(',', '');
    final amount = double.tryParse(clean) ?? 0.0;
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    final parts = formatted.split('.');
    return (whole: parts[0], decimal: '');
  }

  @override
  void dispose() {
    _roceController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveAndSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return;
    setState(() => _isSaving = true);

    try {
      final enteredRoce = _parseToDouble(_roceController.text.trim());
      final int finalRoce = enteredRoce < 1 ? 1 : enteredRoce.round();
      final enteredInvestment = widget.investmentAmount;
      String selectedAverage = 'seed';

      final provider = Provider.of<Providers>(context, listen: false);
      provider.retiredata['improve_status']['investment'] = enteredInvestment;
      provider.retiredata['improve_status']['roce'] = finalRoce;
      provider.retiredata["improve_status"]["seed_type"] = selectedAverage;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');
      if (token == null) throw Exception("Authentication token not found");

      print("investment: $enteredInvestment");
      print("roce: $finalRoce");

      final url = Uri.parse("$baseUrl/app/360/improve/roi");
      final urlROI = Uri.parse("$baseUrl/app/360/retirement/roi");
      final urlRetirement = Uri.parse("$baseUrl/app/360/retirement?archive=0&header=&access=&account=");

      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          "investment": enteredInvestment,
          "roce": finalRoce,
          "seed_type": selectedAverage
        }),
      );

      if (!mounted) return;

      print("response: ${response.body}");
      print("statusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseROI = await http.get(urlROI, headers: headers);
        final responseRetirement = await http.get(urlRetirement, headers: headers);

        if (!mounted) return;

        if (responseRetirement.statusCode == 200) {
          final retirementJson = jsonDecode(responseRetirement.body);
          final retirementData = retirementJson['data'] as Map? ?? {};
          provider.setpensions(retirementData);
        }

        if (responseROI.statusCode == 200) {
          final roiJson = jsonDecode(responseROI.body);
          final roiData = roiJson['data'] as Map? ?? {};
          provider.setretiredata(roiData);
        }

        Fluttertoast.showToast(
          backgroundColor: const Color(0xff00B050),
          textColor: Colors.white,
          msg: 'Details saved successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      } else if (response.statusCode == 429) {
        final body = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['message'] ?? "Too many requests")),
          );
        }
      } else {
        final body = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['message'] ?? "Failed to save")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom == 0 ? 120.h : 60.h),

                Text(
                  'What is your expected Return on Capital Employed (ROCE)?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.counterColor,
                  ),
                ),
                SizedBox(height: 30.h),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: _isEditing ? 1 : 0, // ✅ Uses _isEditing correctly
                        child: TextFormField(
                          controller: _roceController,
                          focusNode: _inputFocusNode,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.transparent),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a valid percentage';
                            }
                            final number = int.tryParse(value.trim().replaceAll(',', ''));
                            if (number == null || number < 1) {
                              return 'Enter a whole number of 1 or more';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                          ),
                          onChanged: (_) => setState(() {}),
                          onTap: () => setState(() => _isEditing = true),
                          onFieldSubmitted: (_) {
                            setState(() => _isEditing = false);
                            FocusScope.of(context).unfocus();
                          },
                          onEditingComplete: () {
                            setState(() => _isEditing = false);
                            FocusScope.of(context).unfocus();
                          },
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          setState(() => _isEditing = true);
                          FocusScope.of(context).requestFocus(_inputFocusNode);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: _splitAmount(_roceController.text).whole,
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 26.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' %',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).viewInsets.bottom == 0 ? 350.h : 80.h),

                ElevatedButton(
                  onPressed: _isSaving ? null : _saveAndSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    minimumSize: Size.fromHeight(60.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    elevation: 2,
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Save',
                          style: GoogleFonts.nunitoSans(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
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