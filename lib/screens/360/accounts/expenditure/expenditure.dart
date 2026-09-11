import 'dart:async';
import 'dart:convert';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/SEED/seedash/seedash.dart';
import 'package:GapHub/screens/portfolio/braidetails.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/customBottomSheet.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../assets/provider/equity_provider.dart';
import '../cash/provider/cash_provider.dart';
import '../investment/provider/investment_provider.dart';
import '../../wheel/360WheelScreen.dart';
import '../../widget/category_dropdown.dart';
import '../retirement/provider/pension_sum_provider.dart';
import 'widget/BuildExpenditureContent.dart';

class Expenditure extends ConsumerStatefulWidget {
  const Expenditure({super.key});

  @override
  ConsumerState<Expenditure> createState() => _ExpenditureState();
}

class _ExpenditureState extends ConsumerState<Expenditure> {
  bool isDropdownActive = false;
  final ScrollController _scrollController = ScrollController();
  bool _appBarSolid = false;

  // ✅ KEPT: Expenditure data variables
  Map? expenditureData;
  Map? expenditureDataLite;

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

    // ✅ KEPT: Fetch financial data in parallel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(investmentProvider.notifier).refreshInvestments();
      ref.read(equityProvider.notifier).refreshEquity();
      ref.read(cashProvider.notifier).refreshCash();
      ref.read(pensionProvider.notifier).refreshPensions();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                // ✅ KEPT: Expenditure category for wheel
                const Expanded(
                  child: ThreesSixtyWheelScreen(initialCategory: "Expenditure"),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      if (mounted) setState(() => isDropdownActive = false);
    });
  }

  // ✅ KEPT: Expenditure sum calculation logic
  num _calculateDisplaySum() {
    if (expenditureDataLite == null) return 0;
    try {
      List<dynamic> lists = expenditureDataLite!["values"];
      if (lists.isEmpty) return 0;
      return lists.reduce((value, current) => value + current);
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ KEPT: Expenditure data flow
    final providers = context.watch<Providers>();
    final currency = providers.snapshotmodel.currency;
    expenditureData = providers.expenditureList;
    expenditureDataLite = providers.expenditureListLite;

    // ✅ KEPT: Expenditure sum logic
    final num displaySum = _calculateDisplaySum();
    final int wholeNumber = displaySum.toInt();
    final String decimalPart = displaySum.toStringAsFixed(2).split('.').last;

    // ✅ FROM NETWORTH UI: Dynamic icon and title opacity
    final Color iconColor = _appBarSolid ? Colors.black : Colors.white;
    final double titleOpacity = _appBarSolid ? 1.0 : 0.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _appBarSolid ? Colors.white : Colors.transparent,
        statusBarIconBrightness: _appBarSolid
            ? Brightness.dark
            : Brightness.light,
      ),
      child: Scaffold(
        bottomNavigationBar: const BottomNav(4),
        body: Stack(
          children: [
            // ✅ FROM NETWORTH UI: Scrollable body with animated header
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ FROM NETWORTH UI: Hero header container
                  AnnotatedRegion<SystemUiOverlayStyle>(
                    value: const SystemUiOverlayStyle(
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness: Brightness.light,
                      statusBarBrightness: Brightness.dark,
                    ),
                    child: Container(
                      height: 300.h,
                      decoration: const BoxDecoration(
                        // ✅ KEPT: Expenditure blur image
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/wheel_segments/expenditureblur.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Column(
                            children: [
                              SizedBox(height: 110.h),
                              // ✅ FROM NETWORTH UI: Live amount display
                              Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: RichText(
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "${currency ?? '0'}$wholeNumber"
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
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 16.h,
                                  bottom: 20.h,
                                ),
                                child: CategoryDropdown(
                                  // ✅ KEPT: Expenditure label
                                  selectedCategory: "Expenditure",
                                  onTap: () {
                                    setState(() => isDropdownActive = true);
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
                  // ✅ FROM NETWORTH UI: Translated content card
                  Transform.translate(
                    offset: Offset(0, -60.h),
                    child: Container(
                      width: double.infinity,
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
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.h),

                            // ✅ KEPT: Expenditure distribution label
                            if (expenditureDataLite != null &&
                                expenditureDataLite!.isNotEmpty)
                              ExpenditureDistributionCard(
                                expenditureData: expenditureDataLite,
                                currency: currency,
                                onSetBudgetTap: seed,
                              ),
                            SizedBox(height: 30.h),

                            // ✅ KEPT: Simple Add Account button (no popup)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ✅ FROM NETWORTH UI: Floating animated AppBar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  statusBarColor: _appBarSolid
                      ? Colors.white
                      : Colors.transparent,
                  statusBarIconBrightness: _appBarSolid
                      ? Brightness.dark
                      : Brightness.light,
                  statusBarBrightness: _appBarSolid
                      ? Brightness.light
                      : Brightness.dark,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  color: _appBarSolid ? Colors.white : Colors.transparent,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 8.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // ✅ FROM NETWORTH UI: Dynamic color back button
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: iconColor,
                              size: 20.sp,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          // ✅ FROM NETWORTH UI: Fade-in title on scroll
                          AnimatedOpacity(
                            opacity: titleOpacity,
                            duration: const Duration(milliseconds: 250),
                            // ✅ KEPT: Expenditure title
                            child: Text(
                              "Expenditure",
                              style: GoogleFonts.nunitoSans(
                                fontSize: 16.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              // ✅ KEPT: Expenditure info bottom sheet content
                              InkWell(
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
                                        title: "Expenditure",
                                        content:
                                            "This is the amount you spend on your upkeep as an individual or a family.",
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
                            ],
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

  // ✅ KEPT: Expenditure getData method unchanged
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

  seed() async {
    var url = Uri.parse("$baseUrl/app/seed");
    var timer = Timer(const Duration(seconds: 50), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, 'Loading');
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await http.get(
      url,
      headers: {"Authorization": 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);

      context.read<Providers>().setSeeData(body);
      timer.cancel();
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Seedash()),
      );
    } else {
      timer.cancel();
      Navigator.pop(context);
    }
  }
}

// ✅ KEPT: AssetRow widget unchanged
class AssetRow extends StatelessWidget {
  final String label;
  const AssetRow({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.h,
            decoration: const BoxDecoration(
              color: Color(0xFFCECECE),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '0',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: '%',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grayColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
