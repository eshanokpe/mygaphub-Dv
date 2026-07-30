import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ILabDifferenceCard extends StatefulWidget {
  const ILabDifferenceCard({super.key});

  @override
  State<ILabDifferenceCard> createState() => _ILabDifferenceCardState();
}

class _ILabDifferenceCardState extends State<ILabDifferenceCard> {
  int selectedIndex = -1;
  Map<String, dynamic> data = {};
  List<dynamic> b = []; // Declare b as a class variable
  bool invTick0 = true;
  bool equTick0 = true;
  bool savTick0 = true;
  bool creTick0 = true;
  bool mortTick0 = true;
  bool npTick0 = true;
  bool npTick1 = true;
  bool portTick0 = true;
  bool portTick1 = true;
  bool eduTick0 = true;
  bool perTick0 = true;
  bool discTick0 = true;
  bool expenTick1 = true;
  bool eduTick1 = true;
  bool perTick1 = true;
  bool discTick1 = true;
  bool expenTick0 = true;
  bool creTick11 = true;
  bool mortTick11 = true;
  bool invTick11 = true;
  bool equTick11 = true;
  bool savTick11 = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // Get the data from provider
        final providerData = context.read<Providers>().ilabdata;
        print("iLab raw data: $providerData");

        // Check if providerData has the expected structure
        if (providerData['status'] == true && providerData['data'] != null) {
          // Extract the actual data from the response
          data = Map<String, dynamic>.from(providerData['data'] as Map);
        } else {
          // If it's already the data structure without status wrapper
          data = Map<String, dynamic>.from(providerData);
        }
        // Process the ilab data after it's loaded
        if (data.isNotEmpty && data["ilab"] != null) {
          // Cast the map to the correct type
          Map<String, dynamic> a = Map<String, dynamic>.from(
            data["ilab"] as Map,
          );
          b = a.values.toList();
          debugPrint("b ${b.toString()}");

          if (b.length >= 17) {
            b.removeRange(0, 2);
            b.removeRange(11, 15);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> currentIlab = data["current_ilab"] is Map
        ? Map<String, dynamic>.from(data["current_ilab"] as Map)
        : {};
    final Map<String, dynamic> targetIlab = data["ilab"] is Map
        ? Map<String, dynamic>.from(data["ilab"] as Map)
        : {};

    // Helper function to safely convert to num
    num safeParseToNum(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value;
      if (value is String) {
        // Remove commas if present
        String cleanValue = value.replaceAll(',', '');
        return num.tryParse(cleanValue) ?? 0;
      }
      return 0;
    }

    var investment0 = invTick0 ? safeParseToNum(currentIlab["investment"]) : 0;

    var equity0 = equTick0 ? safeParseToNum(currentIlab["equity"]) : 0;

    var savings0 = savTick0 ? safeParseToNum(currentIlab["savings"]) : 0;

    var credit0 = creTick0 ? safeParseToNum(currentIlab["credit"]) : 0;

    var mortgage0 = mortTick0 ? safeParseToNum(currentIlab["mortgage"]) : 0;

    // Then use it like this:
    // Calculate liability total with clicked amounts subtracted
    num liabilityTotal0 = (credit0) + (mortgage0);

    var creTick1 = creTick0 ? currentIlab.safeParse("credit") : 0;
    var mortTick1 = mortTick0 ? currentIlab.safeParse("mortgage") : 0;
    var credit1 = creTick11 ? targetIlab.safeParse("credit") : 0;
    var mortgage1 = mortTick11 ? targetIlab.safeParse("mortgage") : 0;
    var liabilityTotal1 = credit1 + mortgage1;

    var nonP0 = npTick0 ? currentIlab.safeParse("non_portfolio") : 0;
    var nonP1 = npTick1 ? targetIlab.safeParse("non_portfolio") : 0;
    var port0 = portTick0 ? currentIlab.safeParse("portfolio") : 0;
    var port1 = portTick1 ? targetIlab.safeParse("asset_portfolio") : 0;

    // Calculate income total with clicked amounts subtracted
    var incomeTotal0 = (nonP0) + (port0);

    var periodic0 = perTick0 ? currentIlab.safeParse("periodic_saving") : 0;
    var education0 = eduTick0 ? currentIlab.safeParse("education") : 0;
    var expenditure0 = expenTick0 ? currentIlab.safeParse("expenditure") : 0;
    var discretionary0 = discTick0 ? currentIlab.safeParse("discretionary") : 0;
    var budget0 = periodic0 + education0 + expenditure0 + discretionary0;

    num assetTotal0 = investment0 + equity0 + savings0;

    var investment1 = invTick11 ? targetIlab.safeParse("investment") : 0;
    var equity1 = equTick11 ? targetIlab.safeParse("equity") : 0;
    var savings1 = savTick11 ? targetIlab.safeParse("savings") : 0;
    var assetTotal1 = investment1 + equity1 + savings1;

    var periodic1 = perTick1 ? targetIlab.safeParse("periodic_savings") : 0;
    var education1 = eduTick1 ? targetIlab.safeParse("education") : 0;
    var expenditure1 = expenTick1 ? targetIlab.safeParse("expenditure") : 0;
    var discretionary1 = discTick1 ? targetIlab.safeParse("discretionary") : 0;
    var budget1 = periodic1 + education1 + expenditure1 + discretionary1;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "iLAB",
                style: TextStyle(
                  color: const Color(0xff979797),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Difference",
                style: TextStyle(
                  color: const Color(0xff979797),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 38.w,
              height: 38.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  "assets/wheel_segments/income_icon.png",
                  width: 26.w,
                ),
              ),
            ),
            title: Text(
              "Income (NPi)",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            trailing: _buildFormattedAmount(
              _formatNumber((nonP0 - nonP1).toString()),
              isNegative: (nonP0 - nonP1) <= 0,
              color: (nonP0 - nonP1) <= 0
                  ? AppColors.primaryColor
                  : AppColors.greenColor,
            ),
          ),
          Divider(
            color: const Color(0xffefefef),
            thickness: 1.h,
            height: 1.h,
            indent: 50.w,
            endIndent: 0.w,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Transform.translate(
              offset: Offset(10, -10.h),
              child: SizedBox(
                width: 30.w,
                height: 30.h,
                child: Center(
                  child: Image.asset(
                    "assets/wheel_segments/dotted_line.png",
                    width: 20.w,
                  ),
                ),
              ),
            ),
            title: Padding(
              padding: EdgeInsets.only(left: 7.w),
              child: Text(
                "Income (APi)",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
            trailing: _buildFormattedAmount(
              _formatNumber((port0 - port1).toString()),
              isNegative: (port0 - port1) <= 0,
              color: (port0 - port1) <= 0
                  ? AppColors.primaryColor
                  : AppColors.greenColor,
            ),
          ),
          Divider(
            color: const Color(0xffefefef),
            thickness: 1.h,
            height: 1.h,
            indent: 50.w,
            endIndent: 0.w,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 38.w,
              height: 38.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  "assets/wheel_segments/liabilities_icon.png",
                  width: 26.w,
                ),
              ),
            ),
            title: Text(
              "Liabilities",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            trailing: _buildFormattedAmount(
              _formatNumber((liabilityTotal1 - liabilityTotal0).toString()),
              isNegative: (liabilityTotal1 - liabilityTotal0) <= 0,
              color: (liabilityTotal1 - liabilityTotal0) <= 0
                  ? AppColors.primaryColor
                  : AppColors.greenColor,
            ),
          ),
          Divider(
            color: const Color(0xffefefef),
            thickness: 1.h,
            height: 1.h,
            indent: 50.w,
            endIndent: 0.w,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 38.w,
              height: 38.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  "assets/wheel_segments/assets_icon.png",
                  width: 26.w,
                ),
              ),
            ),
            title: Text(
              "Asset",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            trailing: _buildFormattedAmount(
              _formatNumber((assetTotal0 - assetTotal1).toString()),
              isNegative: (assetTotal0 - assetTotal1) <= 0,
              color: (assetTotal0 - assetTotal1) <= 0
                  ? AppColors.primaryColor
                  : AppColors.greenColor,
            ),
          ),
          Divider(
            color: const Color(0xffefefef),
            thickness: 1.h,
            height: 1.h,
            indent: 50.w,
            endIndent: 0.w,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 38.w,
              height: 38.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  "assets/wheel_segments/expenditure_icon.png",
                  width: 26.w,
                ),
              ),
            ),
            title: Text(
              "Budget",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            trailing: _buildFormattedAmount(
              _formatNumber((budget1 - budget0).toString()),
              isNegative: (budget1 - budget0) <= 0,
              color: (budget1 - budget0) <= 0
                  ? AppColors.primaryColor
                  : AppColors.greenColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(String amount) {
    // Remove currency symbol if present for formatting
    String cleanAmount = amount.replaceAll(RegExp(r'[^0-9.-]'), '');
    String currency = context.watch<Providers>().snapshotmodel.currency;

    try {
      num value = num.parse(cleanAmount);

      // Format the number with commas and 2 decimal places
      String formattedNumber = value.toStringAsFixed(2);

      // Split into whole number and decimal parts
      List<String> parts = formattedNumber.split('.');
      String wholePart = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      String decimalPart = parts[1];

      // Return the formatted number with currency
      return '$currency$wholePart.$decimalPart';
    } catch (e) {
      return amount;
    }
  }

  Widget _buildFormattedAmount(
    String amount, {
    bool isNegative = false,
    required Color color,
  }) {
    // Extract currency and number parts
    String currency = context.watch<Providers>().snapshotmodel.currency;

    // Remove the negative sign and currency for parsing
    String cleanAmount = amount.replaceAll(RegExp(r'[^0-9.-]'), '');
    if (cleanAmount.startsWith('-')) {
      cleanAmount = cleanAmount.substring(1);
    }

    try {
      num value = num.parse(cleanAmount);
      String formattedNumber = value.toStringAsFixed(2);
      List<String> parts = formattedNumber.split('.');
      String wholePart = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      String decimalPart = parts[1];

      return RichText(
        text: TextSpan(
          children: [
            if (isNegative)
              TextSpan(
                text: '-',
                style: TextStyle(
                  fontFamily: 'NunitoSans',
                  fontSize: 14.sp,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            TextSpan(
              text: currency,
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontSize: 14.sp,
                color: isNegative ? color : color,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: wholePart,
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: 'NunitoSans',
                color: isNegative ? color : color,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: '.',
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: 'NunitoSans',
                color: isNegative ? color : color,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: decimalPart,
              style: TextStyle(
                fontSize: 11.sp, // Smaller font for subscript
                fontFamily: 'NunitoSans',
                color: isNegative ? color : color,
                fontWeight: FontWeight.w700,
                textBaseline: TextBaseline.alphabetic,
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return Text(
        amount,
        style: TextStyle(
          fontSize: 13.sp,
          color: isNegative ? AppColors.primaryColor : AppColors.primaryColor,
          fontWeight: FontWeight.w700,
        ),
      );
    }
  }
}

extension SafeNumParse on Map {
  num safeParse(String key, {num defaultValue = 0}) {
    var value = this[key];
    if (value == null) return defaultValue;
    if (value is num) return value;
    if (value is String) {
      String cleanValue = value.replaceAll(',', '');
      return num.tryParse(cleanValue) ?? defaultValue;
    }
    return defaultValue;
  }
}
