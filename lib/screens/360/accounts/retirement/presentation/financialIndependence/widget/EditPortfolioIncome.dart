import 'dart:convert';

import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import ' EditPortfolioIncomeRoi.dart';

class EditPortfolioIncome extends StatefulWidget {
  const EditPortfolioIncome({super.key});

  @override
  _EditPortfolioIncomeState createState() => _EditPortfolioIncomeState();
}

class _EditPortfolioIncomeState extends State<EditPortfolioIncome> {
  late TextEditingController _investmentAmountController;
  late FocusNode _inputFocusNode;
  bool _isSaving = false;
  bool _isEditing = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late double _initialInvestmentAmount;

  @override
  void initState() {
    super.initState();
    _investmentAmountController = TextEditingController();
    _inputFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final providers = Provider.of<Providers>(context, listen: false);
    final retireData = providers.retiredata;
    _initialInvestmentAmount = _parseToDouble(retireData['improve_status']['investment']);
    _investmentAmountController.text = _initialInvestmentAmount.toStringAsFixed(2);
  }

  double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  /// Split amount into whole and decimal parts
  ({String whole, String decimal}) _splitAmount(String value) {
    final clean = value.replaceAll(',', '');
    final amount = double.tryParse(clean) ?? 0.0;
    final formatted = amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    final parts = formatted.split('.');
    return (whole: parts[0], decimal: '.${parts[1]}');
  }

  @override
  void dispose() {
    _investmentAmountController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveAndProceed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // ✅ Get the final entered value from first screen
      final enteredValue = _parseToDouble(_investmentAmountController.text.trim());

      // ✅ Pass it to the second screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditPortfolioIncomeRoi(
              investmentAmount: enteredValue, // Pass here
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final providers = context.watch<Providers>();
    final snapshotModel = providers.snapshotmodel;
    final currency = snapshotModel.currency.toString();

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
                  'How much can you set aside monthly for investments?',
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
                        opacity: _isEditing ? 1 : 0,
                        child: TextFormField(
                          controller: _investmentAmountController,
                          focusNode: _inputFocusNode,
                          textAlign: TextAlign.center,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.transparent),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter an amount';
                            }
                            final amount = double.tryParse(value.trim().replaceAll(',', ''));
                            if (amount == null || amount < 0) {
                              return 'Enter a valid positive number';
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
                                  text: currency,
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 26.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                TextSpan(
                                  text: _splitAmount(_investmentAmountController.text).whole,
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 26.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                TextSpan(
                                  text: _splitAmount(_investmentAmountController.text).decimal,
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[500],
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
                  onPressed: _isSaving ? null : _saveAndProceed,
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
                          'Next',
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