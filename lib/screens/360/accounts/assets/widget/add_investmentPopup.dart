import 'dart:async';
import 'dart:convert';

import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/portfolio/braidetails.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/connectTo.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../portfolio/assetclasses.dart';
import '../../cash/cash.dart';
import '../../cash/cashdetails.dart';
import '../../investment/investdash.dart';
import '../../retirement/presentation/retiredash.dart';
import '../../retirement/presentation/widget/category_of_pensionScreen.dart';
import '../presentation/equitydetails.dart';
import '../presentation/add_homequity.dart';

class AddInvestmentPopup extends StatelessWidget {
  final String title;
  final num sums;
  final Map<String, dynamic>? braidTable;

  const AddInvestmentPopup({
    super.key,
    required this.title,
    required this.sums,
    required this.braidTable,
  });

  @override
  Widget build(BuildContext context) {
    double calculateTotalValue(List<dynamic> assets) {
      if (assets.isEmpty) return 0.0;
      return assets.fold(0.0, (sum, asset) {
        double assetValue = asset['asset_value'] is double
            ? asset['asset_value']
            : double.tryParse(asset['asset_value']?.toString() ?? '0') ?? 0.0;
        return sum + assetValue;
      });
    }

    double calculateTotalIncome(List<dynamic> assets) {
      if (assets.isEmpty) return 0.0;
      return assets.fold(0.0, (sum, asset) {
        double monthlyRoi = asset['monthly_roi'] is double
            ? asset['monthly_roi']
            : double.tryParse(asset['monthly_roi']?.toString() ?? '0') ?? 0.0;
        return sum + monthlyRoi;
      });
    }

    String currency = context.watch<Providers>().snapshotmodel.currency;
    List<dynamic> businessAssets = braidTable?['business'] ?? [];
    List<dynamic> riskAssets = braidTable?['risk'] ?? [];
    List<dynamic> appreciatingAssets = braidTable?['appreciating'] ?? [];

    double businessValue = calculateTotalValue(businessAssets);
    double businessIncome = calculateTotalIncome(businessAssets);

    double appreciatingValue = calculateTotalValue(appreciatingAssets);
    double appreciatingIncome = calculateTotalIncome(appreciatingAssets);

    double riskValue = calculateTotalValue(riskAssets);
    double riskIncome = calculateTotalIncome(riskAssets);

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(56.0),
          topRight: Radius.circular(56.0),
        ),
        color: Colors.white, // Background color for the bottom sheet
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Center(
                  child: Container(
                    height: 5.h,
                    width: 45.w,
                    decoration: BoxDecoration(
                      color: const Color(0xffcdcdcd),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Center(
                child: Text(
                  title,
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              Center(
                child: AssetAmountText(currencySymbol: currency, amount: sums),
              ),
              SizedBox(height: 20.h),

              Center(
                child: Text(
                  "Here is an aggregation of all the assets contributing to your long-term financial growth.",
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    fontStyle: FontStyle.italic,
                    color: AppColors.grayColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20.h),
              _buildContentRow(
                assetPath: 'assets/images/portfolio_income.png',
                title: 'Business',
                value: businessValue,
                currency: currency,
                onTap: () {
                  Navigator.pop(context);
                  // return getData("Business", "business", context);
                },
              ),
              SizedBox(height: 5.h),

              Divider(
                color: AppColors.dividerColor,
                thickness: 0.5.h,
                height: 2.h,
                indent: 50.w,
                endIndent: 30.w,
              ),
              SizedBox(height: 5.h),

              _buildContentRow(
                assetPath: 'assets/wheel_segments/appreciating.png',
                title: 'Appreciating',
                value: appreciatingValue,
                currency: currency,
                onTap: () {
                  // return getData("Appreciating", "appreciating", context);
                },
              ),
              Divider(
                color: AppColors.dividerColor,
                thickness: 0.5.h,
                height: 2.h,
                indent: 50.w,
                endIndent: 30.w,
              ),
              _buildContentRow(
                assetPath: 'assets/wheel_segments/risk2.png',
                title: 'Risk',
                value: riskValue,
                currency: currency,
                onTap: () {
                  Navigator.pop(context);
                  // return getData("Risk", "risk", context);
                },
              ),
              SizedBox(height: 30.h),
              CustomButton(
                text: 'Close',
                fontSize: 16.sp,
                borderRadius: 30,
                icon: null,
                iconColor: AppColors.primaryColor,
                borderColor: const Color(0xffC8CECC),
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.white,
                textColor: AppColors.blackColor,
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentRow({
    required String assetPath,
    required String title,
    required num value,
    required VoidCallback? onTap,
    required String currency,
  }) {
    return InkWell(
      splashColor: Colors.blue.withOpacity(0.2), // ripple color
      highlightColor: Colors.blue.withOpacity(0.1), // hold-down color
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(8.w),
                child: Image.asset(assetPath, fit: BoxFit.contain, width: 20.w),
              ),
              SizedBox(width: 16.w),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.nunitoSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        AssetAmountText2(
                          currencySymbol: currency,
                          amount: value,
                        ),
                      ],
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20.w,
                      color: const Color(0xFFBFBFBF),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getAssetClasses(context, Function doing) {
    connectTo(context, "get", "/app/portfolio/information", {}, shoot: doing);
  }

  Future<void> getData(String cap, String small, BuildContext context) async {
    final timeoutTimer = Timer(const Duration(seconds: 40), () {
      EasyLoading.dismiss();
      Fluttertoast.showToast(msg: "Request timed out. Please try again.");
    });

    EasyLoading.show(status: 'Loading', dismissOnTap: false);

    try {
      var url = Uri.parse("$baseUrl/app/portfolio/$small");
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      var response = await http.get(
        url,
        headers: {"Authorization": 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                Braidetails(cap, jsonDecode(response.body), false),
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: "Error: ${response.statusCode}. Something went wrong.",
        );
      }
    } catch (error) {
      Fluttertoast.showToast(msg: "An error occurred: ${error.toString()}");
    } finally {
      timeoutTimer.cancel();
      EasyLoading.dismiss();
    }
  }
}

class AssetAmountText extends StatelessWidget {
  final String currencySymbol;
  final dynamic amount;

  const AssetAmountText({
    super.key,
    required this.currencySymbol,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final num numValue = double.tryParse(amount.toString()) ?? 0;
    final formatted = numValue.toStringAsFixed(2);
    final parts = formatted.split('.');
    final whole = '$currencySymbol${_formatNumber(parts[0])}';
    final decimal = '.${parts[1]}';

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: whole,
            style: GoogleFonts.nunitoSans(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          TextSpan(
            text: decimal,
            style: GoogleFonts.nunitoSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF9A9A9A),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(String? valueStr) {
    if (valueStr == null || valueStr.isEmpty) return '0';
    final num numValue = num.tryParse(valueStr) ?? 0;
    return NumberFormat('#,###').format(numValue);
  }
}

class AssetAmountText2 extends StatelessWidget {
  final String currencySymbol;
  final dynamic amount;

  const AssetAmountText2({
    super.key,
    required this.currencySymbol,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final num numValue = double.tryParse(amount.toString()) ?? 0;
    final formatted = numValue.toStringAsFixed(2);
    final parts = formatted.split('.');
    final whole = '$currencySymbol${_formatNumber(parts[0])}';
    final decimal = '.${parts[1]}';

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: whole,
            style: GoogleFonts.nunitoSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          TextSpan(
            text: decimal,
            style: GoogleFonts.nunitoSans(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF9A9A9A),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(String? valueStr) {
    if (valueStr == null || valueStr.isEmpty) return '0';
    final num numValue = num.tryParse(valueStr) ?? 0;
    return NumberFormat('#,###').format(numValue);
  }
}
