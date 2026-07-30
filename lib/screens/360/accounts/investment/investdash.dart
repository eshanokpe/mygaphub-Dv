import 'dart:async';
import 'dart:convert';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/portfolio/braidetails.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/customBottomSheet.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/svg.dart';
import '../../wheel/360WheelScreen.dart';
import '../../widget/category_dropdown.dart';

class Investdash extends StatefulWidget {
  final dynamic sums;
  final Map<String, dynamic>? braidTable;

  const Investdash({super.key, this.sums, required this.braidTable});

  @override
  _InvestdashState createState() => _InvestdashState();
}

class _InvestdashState extends State<Investdash> {
  bool isDropdownActive = false;
  final ScrollController _scrollController = ScrollController();
  bool _appBarSolid = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final statusBarHeight = MediaQuery.of(context).padding.top;
      final triggerOffset = 200.h - statusBarHeight - 56.h;
      final shouldBeSolid = _scrollController.offset >= triggerOffset;
      if (shouldBeSolid != _appBarSolid) {
        setState(() => _appBarSolid = shouldBeSolid);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double _calculateTotalValue(List<dynamic> assets) {
    if (assets.isEmpty) return 0.0;
    return assets.fold(0.0, (sum, asset) {
      double assetValue = asset['asset_value'] is double
          ? asset['asset_value']
          : double.tryParse(asset['asset_value']?.toString() ?? '0') ?? 0.0;
      return sum + assetValue;
    });
  }

  double _calculateTotalIncome(List<dynamic> assets) {
    if (assets.isEmpty) return 0.0;
    return assets.fold(0.0, (sum, asset) {
      double monthlyRoi = asset['monthly_roi'] is double
          ? asset['monthly_roi']
          : double.tryParse(asset['monthly_roi']?.toString() ?? '0') ?? 0.0;
      return sum + monthlyRoi;
    });
  }

  Future<void> _showWheelBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(56.0),
          topRight: Radius.circular(56.0),
        ),
      ),
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(56.0),
            topRight: Radius.circular(56.0),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(height: 16.sp),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 160),
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xffCDCDCD),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 7.sp),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close, color: Colors.black, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Close',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 14.sp,
                            color: AppColors.blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ThreesSixtyWheelScreen(initialCategory: "Investment"),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      setState(() {
        isDropdownActive = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> businessAssets = widget.braidTable?['business'] ?? [];
    List<dynamic> riskAssets = widget.braidTable?['risk'] ?? [];
    List<dynamic> appreciatingAssets = widget.braidTable?['appreciating'] ?? [];

    double businessValue = _calculateTotalValue(businessAssets);
    double businessIncome = _calculateTotalIncome(businessAssets);

    double appreciatingValue = _calculateTotalValue(appreciatingAssets);
    double appreciatingIncome = _calculateTotalIncome(appreciatingAssets);

    double riskValue = _calculateTotalValue(riskAssets);
    double riskIncome = _calculateTotalIncome(riskAssets);

    String currency = context.watch<Providers>().snapshotmodel.currency;
    var amount = widget.sums ?? 0;
    String wholeNumber = amount.toStringAsFixed(0);
    String decimalPart = amount.toStringAsFixed(2).split('.').last;

    final Color iconColor = _appBarSolid ? Colors.black : Colors.white;
    final double titleOpacity = _appBarSolid ? 1.0 : 0.0;


    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _appBarSolid ? Colors.white : Colors.transparent,
        statusBarIconBrightness: _appBarSolid ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        bottomNavigationBar: const BottomNav(4),
        body: Stack(
          children: [
            // ── SCROLLABLE CONTENT ──────────────────────────────────────
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GRADIENT BACKGROUND — light status bar icons
                  AnnotatedRegion<SystemUiOverlayStyle>(
                    value: const SystemUiOverlayStyle(
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness: Brightness.light,
                      statusBarBrightness: Brightness.dark, // iOS
                    ),
                    child: Container(
                      height: 300.h,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xffB20049), Color(0xff032E53)],
                          begin: Alignment.topLeft,
                          end: Alignment(1.7, 2.1),
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: Image.asset(
                                  'assets/wheel_segments/blurInvestment.png',
                                ).image,
                                fit: BoxFit.cover,
                                alignment: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              SizedBox(height: 60.h),
                              Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: Center(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "$currency$wholeNumber"
                                              .replaceAllMapped(
                                                RegExp(
                                                  r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                                ),
                                                (Match m) => '${m[1]},',
                                              ),
                                          style: GoogleFonts.nunitoSans(
                                            fontSize: 36.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ".$decimalPart",
                                          style: GoogleFonts.nunitoSans(
                                            fontSize: 24.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ), 
                              Padding(
                                padding: EdgeInsets.only(top: 16.h, bottom: 20.h),
                                child: CategoryDropdown(
                                  selectedCategory: "Investment",
                                  onTap: () {
                                    setState(() {
                                      isDropdownActive = true;
                                    });
                                    _showWheelBottomSheet(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
      
                  // White content section
                 
                 Transform.translate(
                    offset: Offset(0, -60.h),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AssetCard(
                              title: "Business Asset",
                              imagePath: 'assets/wheel_segments/Money.png',
                              value: businessValue,
                              income: businessIncome,
                              assets: businessAssets,
                              onTap: () async {
                                return getData("Business", "business", context);
                              },
                            ),
                            SizedBox(height: 16.h),
                            AssetCard(
                              title: "Appreciating Asset",
                              imagePath: 'assets/wheel_segments/house.png',
                              value: appreciatingValue,
                              income: appreciatingIncome,
                              assets: appreciatingAssets,
                              onTap: () async {
                                return getData(
                                  "Appreciating",
                                  "appreciating",
                                  context,
                                );
                              },
                            ),
                            SizedBox(height: 16.h),
                            AssetCard(
                              title: "Risk Asset",
                              imagePath: 'assets/wheel_segments/risk.png',
                              value: riskValue,
                              income: riskIncome,
                              assets: riskAssets,
                              onTap: () async {
                                return getData("Risk", "risk", context);
                              },
                            ),
                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
      
            // ── ANIMATED APP BAR ────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  statusBarColor:
                      _appBarSolid ? Colors.white : Colors.transparent,
                  statusBarIconBrightness:
                      _appBarSolid ? Brightness.dark : Brightness.light,
                  statusBarBrightness:
                      _appBarSolid ? Brightness.light : Brightness.dark, // iOS
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  color: _appBarSolid ? Colors.white : Colors.transparent,
                  child: SafeArea(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back button
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: IconButton(
                              key: ValueKey(_appBarSolid),
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: iconColor,
                                size: 20.sp,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
      
                          // Center title — fades in when scrolled
                          AnimatedOpacity(
                            opacity: titleOpacity,
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              "Investment",
                              style: GoogleFonts.nunitoSans(
                                fontSize: 16.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
      
                          // Info button pinned right
                          Align(
                            alignment: Alignment.centerRight,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: InkWell(
                                key: ValueKey(_appBarSolid),
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(56.0),
                                        topRight: Radius.circular(56.0),
                                      ),
                                    ),
                                    builder: (BuildContext context) {
                                      return const CustomBottomSheet(
                                        title: "Investment",
                                        content:
                                            "Here is an aggregation of all the assets contributing to your long-term financial growth.",
                                      );
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(8.w),
                                  child: SvgPicture.asset(
                                    'assets/wheel_segments/info_thin.svg',
                                    colorFilter: ColorFilter.mode(
                                      iconColor,
                                      BlendMode.srcIn,
                                    ),
                                    width: 24.w,
                                    height: 24.h,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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


// ── AssetCard & _buildRow ─────────────────────────────────────────────────────

class AssetCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final num value;
  final num income;
  final List<dynamic> assets;
  final VoidCallback? onTap;

  const AssetCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.value,
    required this.income,
    required this.assets,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xffF7F7F7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xffEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    imagePath,
                    width: 24.w,
                    height: 24.h,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.broken_image, size: 20.sp);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "View",
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.primaryColor,
                      size: 20.sp,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildRow(
                    'assets/wheel_segments/value.png',
                    "Value",
                    value,
                    context,
                  ),
                  const Divider(indent: 30, color: Color(0xffECECEC)),
                  _buildRow(
                    'assets/wheel_segments/hand-money.png',
                    "Income",
                    income,
                    context,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    String imagePath,
    String label,
    num amount,
    BuildContext context,
  ) {
    String currency = context.watch<Providers>().snapshotmodel.currency;
    String amountStr = amount.toStringAsFixed(2);
    List<String> parts = amountStr.split('.');
    String wholePart = parts[0];
    String decimalPart = parts[1];
    return Row(
      children: [
        Image.asset(imagePath, width: 22.w, height: 22.h),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
        ),
        const Spacer(),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text:
                    "$currency${wholePart.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                style: GoogleFonts.nunitoSans(
                  fontSize: 16.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: ".$decimalPart",
                style: GoogleFonts.nunitoSans(
                  fontSize: 14.sp,
                  color: const Color(0xff777777),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
