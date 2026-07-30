import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/SEED/seedash/seedash.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/customBottomSheet.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/svg.dart';

import '../../wheel/360WheelScreen.dart';
import '../../widget/category_dropdown.dart';

class Philanthropy extends StatefulWidget {
  final dynamic data;
  final String currency;

  const Philanthropy(this.data, this.currency, {super.key});

  @override
  _PhilanthropyState createState() => _PhilanthropyState();
}

class _PhilanthropyState extends State<Philanthropy> {
  Map data = {};
  var setgiving;
  int? _selectedBarIndex;
  bool _isDropdownActive = false;

  // ── Scroll-triggered app bar ──────────────────────────────────────────────
  final ScrollController _scrollController = ScrollController();
  bool _appBarSolid = false;

  /// The scroll offset at which the app bar becomes fully white.
  double get _appBarTriggerOffset => 120.h;

  @override
  void initState() {
    super.initState();
    setState(() => data = context.read<Providers>().philanthropydata);
    setState(() => setgiving = data["data"]["philantrophy_detail"]["values"]);

    // Set initial status bar to light (white icons for dark bg)
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    )); 

    _scrollController.addListener(() {
      final shouldBeSolid = _scrollController.offset >= _appBarTriggerOffset;
      if (shouldBeSolid != _appBarSolid) {
        setState(() => _appBarSolid = shouldBeSolid);

        // ← Switch status bar icons dark/light to match app bar
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: shouldBeSolid ? Colors.white : Colors.transparent,
          statusBarIconBrightness:
              shouldBeSolid ? Brightness.dark : Brightness.light,
        ));
      }
    });
  }

  @override
  void dispose() {
    // Restore to default when leaving screen
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _scrollController.dispose();
    super.dispose();
  }
  // ─────────────────────────────────────────────────────────────────────────

  List<Color> barColors = [
    const Color(0xff214E9C),
    const Color(0xffC61A24),
    const Color(0xffF6981E),
    const Color(0xff266C26),
  ];

  List<Color> barColorsDark = [
    const Color(0xff0D2D60),
    const Color(0xff6A1116),
    const Color(0xff825212),
    const Color(0xff173C17),
  ];

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
                const Expanded(
                  child: ThreesSixtyWheelScreen(
                    initialCategory: "Philanthropy",
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      setState(() {
        _isDropdownActive = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double maxBarHeight = 150.h;
    num maxValue = setgiving.reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) maxValue = 1;

    String currency = context.read<Providers>().snapshotmodel.currency;
    var dataLite = data['data']["philantrophy_detail"];
    List<dynamic> lists = dataLite["values"];
    var sum = lists.reduce((value, current) => value + current);

    String wholeNumber = sum.toStringAsFixed(0);
    String decimalPart = sum.toStringAsFixed(2).split('.').last;

    // App bar colours that animate with scroll
    final Color appBarBg = _appBarSolid ? Colors.white : Colors.transparent;
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
            // ── SCROLLABLE CONTENT ────────────────────────────────────────
            SingleChildScrollView(
              controller: _scrollController, // <-- attach controller
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GRADIENT BACKGROUND
                  Container(
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
                                'assets/wheel_segments/blur.png',
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
                                        text: "${widget.currency}$wholeNumber"
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
                                selectedCategory: "Philanthropy",
                                onTap: () {
                                  setState(() {
                                    _isDropdownActive = true;
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
      
                  // White content section
                  Transform.translate(
                    offset: Offset(0, -50.h),
                    child: Center(
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
                              Text(
                                "PHILANTHROPY PROFILE",
                                style: GoogleFonts.nunitoSans(
                                  color: const Color(0xff808080),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 12.h),
      
                              /// PROFILE CARD
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 20.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xffEEEEEE),
                                    width: 0.7,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: dataLite["labels"].length,
                                      itemBuilder: (context, index) {
                                        bool isLast =
                                            index ==
                                            dataLite["labels"].length - 1;
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ProfileRow(
                                              dataLite["labels"][index],
                                              dataLite["values"][index],
                                            ),
                                            if (!isLast)
                                              const Divider(
                                                color: Color(0xffE3E3E3),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                    SizedBox(height: 24.h),
                                    SetBudgetButton(
                                      onTap: () => _handleSetBudgetTap(context),
                                    ),
                                    SizedBox(height: 10.h),
                                  ],
                                ),
                              ),
      
                              SizedBox(height: 32.h),
      
                              /// PHILANTHROPY DISTRIBUTION
                              Text(
                                "PHILANTHROPY DISTRIBUTION",
                                style: GoogleFonts.nunitoSans(
                                  color: AppColors.grayColor,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 12.h),
      
                              /// CHART CARD
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xffEEEEEE),
                                    width: 0.7,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    /// BARS
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14.w,
                                        vertical: 20.h,
                                      ),
                                      child: SizedBox(
                                        height:
                                            setgiving.every(
                                              (value) => value == 0,
                                            )
                                            ? 100.h
                                            : 170.h,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 150.h,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  if (setgiving.every(
                                                    (value) => value == 0,
                                                  ))
                                                    Center(
                                                      child: Text(
                                                        "Set your budget to display chart data",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.nunitoSans(
                                                              fontSize: 14.sp,
                                                              color:
                                                                  const Color(
                                                                    0xff808080,
                                                                  ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                      ),
                                                    )
                                                  else
                                                    SizedBox(
                                                      width: 300.w,
                                                      height: 150.h,
                                                      child: Stack(
                                                        clipBehavior: Clip.none,
                                                        children: [
                                                          if (setgiving.length >
                                                              3)
                                                            Positioned(
                                                              bottom: 0,
                                                              left: 200.w,
                                                              child: GestureDetector(
                                                                onTap: () {
                                                                  setState(() {
                                                                    _selectedBarIndex =
                                                                        _selectedBarIndex ==
                                                                            3
                                                                        ? null
                                                                        : 3;
                                                                  });
                                                                },
                                                                child: _buildBar(
                                                                  index: 3,
                                                                  color:
                                                                      barColors[3],
                                                                  color2:
                                                                      barColorsDark[3],
                                                                  height:
                                                                      setgiving[3] ==
                                                                          0
                                                                      ? 10.h
                                                                      : (setgiving[3] /
                                                                                maxValue) *
                                                                            maxBarHeight,
                                                                  isZero:
                                                                      setgiving[3] ==
                                                                      0,
                                                                  isSelected:
                                                                      _selectedBarIndex ==
                                                                      3,
                                                                  isOtherSelected:
                                                                      _selectedBarIndex !=
                                                                          null &&
                                                                      _selectedBarIndex !=
                                                                          3,
                                                                ),
                                                              ),
                                                            ),
                                                          if (setgiving.length >
                                                              2)
                                                            Positioned(
                                                              bottom: 0,
                                                              left: 150.w,
                                                              child: GestureDetector(
                                                                onTap: () {
                                                                  setState(() {
                                                                    _selectedBarIndex =
                                                                        _selectedBarIndex ==
                                                                            2
                                                                        ? null
                                                                        : 2;
                                                                  });
                                                                },
                                                                child: _buildBar(
                                                                  index: 2,
                                                                  color:
                                                                      barColors[2],
                                                                  color2:
                                                                      barColorsDark[2],
                                                                  height:
                                                                      setgiving[2] ==
                                                                          0
                                                                      ? 10.h
                                                                      : (setgiving[2] /
                                                                                maxValue) *
                                                                            maxBarHeight,
                                                                  isZero:
                                                                      setgiving[2] ==
                                                                      0,
                                                                  isSelected:
                                                                      _selectedBarIndex ==
                                                                      2,
                                                                  isOtherSelected:
                                                                      _selectedBarIndex !=
                                                                          null &&
                                                                      _selectedBarIndex !=
                                                                          2,
                                                                ),
                                                              ),
                                                            ),
                                                          if (setgiving.length >
                                                              1)
                                                            Positioned(
                                                              bottom: 0,
                                                              left: 80.w,
                                                              child: GestureDetector(
                                                                onTap: () {
                                                                  setState(() {
                                                                    _selectedBarIndex =
                                                                        _selectedBarIndex ==
                                                                            1
                                                                        ? null
                                                                        : 1;
                                                                  });
                                                                },
                                                                child: _buildBar(
                                                                  index: 1,
                                                                  color:
                                                                      barColors[1],
                                                                  color2:
                                                                      barColorsDark[1],
                                                                  height:
                                                                      setgiving[1] ==
                                                                          0
                                                                      ? 10.h
                                                                      : (setgiving[1] /
                                                                                maxValue) *
                                                                            maxBarHeight,
                                                                  isZero:
                                                                      setgiving[1] ==
                                                                      0,
                                                                  isSelected:
                                                                      _selectedBarIndex ==
                                                                      1,
                                                                  isOtherSelected:
                                                                      _selectedBarIndex !=
                                                                          null &&
                                                                      _selectedBarIndex !=
                                                                          1,
                                                                ),
                                                              ),
                                                            ),
                                                          if (setgiving.length >
                                                              0)
                                                            Positioned(
                                                              bottom: 0,
                                                              left: 0,
                                                              child: GestureDetector(
                                                                onTap: () {
                                                                  setState(() {
                                                                    _selectedBarIndex =
                                                                        _selectedBarIndex ==
                                                                            0
                                                                        ? null
                                                                        : 0;
                                                                  });
                                                                },
                                                                child: _buildBar(
                                                                  index: 0,
                                                                  color:
                                                                      barColors[0],
                                                                  color2:
                                                                      barColorsDark[0],
                                                                  height:
                                                                      setgiving[0] ==
                                                                          0
                                                                      ? 10.h
                                                                      : (setgiving[0] /
                                                                                maxValue) *
                                                                            maxBarHeight,
                                                                  isZero:
                                                                      setgiving[0] ==
                                                                      0,
                                                                  isSelected:
                                                                      _selectedBarIndex ==
                                                                      0,
                                                                  isOtherSelected:
                                                                      _selectedBarIndex !=
                                                                          null &&
                                                                      _selectedBarIndex !=
                                                                          0,
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
      
                                    /// LEGEND
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xffF7F7F7),
                                        border: Border.all(
                                          color: const Color(0xffEEEEEE),
                                          width: 0.7,
                                        ),
                                      ),
                                      child: Column(
                                        children: List.generate(
                                          dataLite["labels"].length,
                                          (index) {
                                            final formattedAmount =
                                                dataLite["values"][index];
                                            return Column(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 14.w,
                                                    vertical: 9.h,
                                                  ),
                                                  child: GestureDetector(
                                                    onTap: formattedAmount == 0
                                                        ? null
                                                        : () {
                                                            setState(() {
                                                              _selectedBarIndex =
                                                                  _selectedBarIndex ==
                                                                      index
                                                                  ? null
                                                                  : index;
                                                            });
                                                          },
                                                    child: _legendRow(
                                                      barColors[index],
                                                      barColorsDark[index],
                                                      dataLite["labels"][index],
                                                      formattedAmount,
                                                      isSelected:
                                                          _selectedBarIndex ==
                                                          index,
                                                      isOtherSelected:
                                                          _selectedBarIndex !=
                                                              null &&
                                                          _selectedBarIndex !=
                                                              index,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      
            // ── ANIMATED APP BAR ──────────────────────────────────────────
            SafeArea(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                color: appBarBg,
                // Add a subtle bottom shadow when solid
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
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
                          "Philanthropy",
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
      
                      // Info button
                      AnimatedSwitcher(
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
                                  title: "Philanthropy",
                                  content:
                                      "This is the average of what you give to various causes on a monthly basis",
                                );
                              },
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all(8.w),
                            child: SvgPicture.asset(
                              'assets/wheel_segments/info_thin.svg',
                              // Apply color filter for black tint when solid
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── All existing methods unchanged ────────────────────────────────────────

  Widget _buildBar({
    required int index,
    required Color color,
    required Color color2,
    required double height,
    bool isZero = false,
    bool isSelected = false,
    bool isOtherSelected = false,
  }) {
    bool isActive =
        isSelected || (!isOtherSelected && _selectedBarIndex == null);

    double targetScale = 1.0;

    if (isSelected) {
      targetScale = 1.05;
    } else if (isOtherSelected) {
      targetScale = 0.95;
    }

    BoxDecoration getDecoration() {
      const borderRadius = BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      );

      if (index == 0) {
        if (isActive) {
          return const BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              colors: [Color(0xff134EB2), Color(0xff0D2D60)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x140F1828),
                offset: Offset(9, -6),
                blurRadius: 12,
                spreadRadius: -5,
              ),
            ],
          );
        } else {
          return const BoxDecoration(
            borderRadius: borderRadius,
            color: Color(0xffcfd8e6),
            boxShadow: [
              BoxShadow(
                color: Color(0x140F1828),
                offset: Offset(9, -6),
                blurRadius: 12,
                spreadRadius: -5,
              ),
            ],
          );
        }
      } else if (index == 1) {
        if (isActive) {
          return const BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              colors: [Color(0xffC61A24), Color(0xff6A1116)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x140F1828),
                offset: Offset(9, -6),
                blurRadius: 12,
                spreadRadius: -5,
              ),
            ],
          );
        } else {
          return const BoxDecoration(
            borderRadius: borderRadius,
            color: Color(0xffddb9bb),
            boxShadow: [
              BoxShadow(
                color: Color(0x140F1828),
                offset: Offset(9, -6),
                blurRadius: 12,
                spreadRadius: -5,
              ),
            ],
          );
        }
      } else if (index == 2) {
        if (isActive) {
          return const BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              colors: [Color(0xffF6981E), Color(0xff825212)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x0D0F1828),
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          );
        } else {
          return const BoxDecoration(
            borderRadius: borderRadius,
            color: Color(0xffe8d4b9),
            boxShadow: [
              BoxShadow(
                color: Color(0x0D0F1828),
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          );
        }
      } else {
        if (isActive) {
          return const BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              colors: [Color(0xff266C26), Color(0xff173C17)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x140F1828),
                offset: Offset(9, -6),
                blurRadius: 12,
                spreadRadius: -5,
              ),
            ],
          );
        } else {
          return const BoxDecoration(
            borderRadius: borderRadius,
            color: Color(0xffbbc9bb),
            boxShadow: [
              BoxShadow(
                color: Color(0x140F1828),
                offset: Offset(9, -6),
                blurRadius: 12,
                spreadRadius: -5,
              ),
            ],
          );
        }
      }
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: targetScale),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Container(
          width: 104.w * scale,
          height: height.h * scale,
          decoration: getDecoration(),
        );
      },
    );
  }

  Widget _legendRow(
    Color color,
    Color color2,
    String title,
    num amount, {
    bool isSelected = false,
    bool isOtherSelected = false,
  }) {
    String currency = context.read<Providers>().snapshotmodel.currency;
    String amountStr = amount.toStringAsFixed(2);
    List<String> parts = amountStr.split('.');
    String wholePart = parts[0];
    String decimalPart = parts[1];

    double opacity = 1.0;
    if (isOtherSelected) {
      opacity = 0.3;
    }
    if (isSelected) {
      opacity = 1.0;
    }

    return Opacity(
      opacity: opacity,
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: amount == 0 ? const Color(0xffCECECE) : null,
              gradient: amount == 0
                  ? null
                  : LinearGradient(
                      colors: [color, color2],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunitoSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text:
                      "$currency${wholePart.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: ".$decimalPart",
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11.sp,
                    color: const Color(0xff777777),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSetBudgetTap(BuildContext context) async {
    DialogBox dialogBox = DialogBox();
    dialogBox.waiting(context, 'Loading SEED data...');

    Timer timer = Timer(const Duration(seconds: 40), () {
      Navigator.pop(context);
      dialogBox.information(
        context,
        'Timeout Error',
        'Request timed out. Please check your connection and try again.',
      );
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('tokenDB');

      if (token == null) {
        timer.cancel();
        Navigator.pop(context);
        dialogBox.information(
          context,
          'Authentication Error',
          'Please log in again to continue.',
        );
        return;
      }

      var url = Uri.parse("$baseUrl/app/seed");
      var response = await http.get(
        url,
        headers: {"Authorization": 'Bearer $token'},
      );

      timer.cancel();

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        context.read<Providers>().setSeeData(body);
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Seedash()),
        );
      } else {
        Navigator.pop(context);

        String errorMessage = 'Failed to load SEED data';
        if (response.statusCode == 401) {
          errorMessage = 'Session expired. Please log in again.';
        } else if (response.statusCode == 404) {
          errorMessage = 'SEED data not found.';
        } else if (response.statusCode >= 500) {
          errorMessage = 'Server error. Please try again later.';
        }

        dialogBox.information(
          context,
          'Error ${response.statusCode}',
          errorMessage,
        );
      }
    } catch (e) {
      timer.cancel();
      Navigator.pop(context);

      dialogBox.information(
        context,
        'Connection Error',
        'Unable to connect to server. Please check your internet connection.',
      );

      debugPrint('Error fetching SEED data: $e');
    }
  }
}

/// PROFILE ROW
class ProfileRow extends StatelessWidget {
  final String title;
  final num amount;

  const ProfileRow(this.title, this.amount, {super.key});

  @override
  Widget build(BuildContext context) {
    String currency = context.read<Providers>().snapshotmodel.currency;
    String amountStr = amount.toStringAsFixed(2);
    List<String> parts = amountStr.split('.');
    String wholePart = parts[0];
    String decimalPart = parts[1];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xff777777)),
          ),
          SizedBox(height: 5.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text:
                      "$currency${wholePart.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                  style: GoogleFonts.nunitoSans(
                    fontSize: 20.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: ".$decimalPart",
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16.sp,
                    color: const Color(0xff777777),
                    fontWeight: FontWeight.w700,
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

/// SET BUDGET BUTTON
class SetBudgetButton extends StatelessWidget {
  final VoidCallback? onTap;

  const SetBudgetButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.red),
            SizedBox(width: 8),
            Text("Set Budget in SEED", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
