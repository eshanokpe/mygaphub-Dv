import 'dart:async';
import 'dart:convert';
import 'package:GapHub/screens/360/accounts/assets/provider/equity_provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/customBottomSheet.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';

import '../../../widget/category_dropdown.dart';
import '../widget/add_protection_popup.dart';
import '../widget/assetsListCard.dart';
import '../widget/piechartHomeEquity.dart';
import 'homeEquityItem.dart';
import 'noHomeEquity.dart';

class Equitydetails extends ConsumerStatefulWidget {
  const Equitydetails({super.key});

  @override
  ConsumerState<Equitydetails> createState() => _EquitydetailsState();
}

class _EquitydetailsState extends ConsumerState<Equitydetails> {
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(equityProvider.notifier);
      // Only fetch if we don't have data yet to avoid unnecessary reloads
      if (notifier.state.equityData == null) {
        notifier.refreshEquity();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  static const String _equityGradientStart = '0xFF173C17';
  static const String _equityGradientEnd = '0xFF266C26';
  static const double _minOpacity = 0.35;
  static const double _opacityStep = 0.15;

  List<Color> _equityGradientForIndex(int index) {
    final opacity = (1.0 - (index * _opacityStep)).clamp(_minOpacity, 1.0);
    final start = Color(int.parse(_equityGradientStart)).withOpacity(opacity);
    final end = Color(int.parse(_equityGradientEnd)).withOpacity(opacity);
    return [start, end];
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Watch the provider. This will rebuild the UI automatically
    // when refreshEquity() finishes and updates the state.
    final equityState = ref.watch(equityProvider);
    final equityData = equityState.equityData ?? [];
    final equityDataLite = equityState.equityDetail ?? {};
    final currency = context.watch<Providers>().snapshotmodel.currency;

    // Calculate display values safely
    double displaySum = (equityDataLite["sum"] ?? 0).toDouble();
    int wholeNumber = displaySum.toInt();
    String decimalPart = displaySum.toStringAsFixed(2).split('.').last;

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
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  AnnotatedRegion<SystemUiOverlayStyle>(
                    value: const SystemUiOverlayStyle(
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness: Brightness.light,
                    ),
                    child: Container(
                      height: 320.h,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/wheel_segments/home_equity_listblur.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                        gradient: LinearGradient(
                          colors: [Color(0xfff266c26), Color(0xffF6981E)],
                          stops: [0.0, 5.8],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Column(
                            children: [
                              SizedBox(height: 110.h),
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
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 16.h,
                                  bottom: 20.h,
                                ),
                                child: CategoryDropdown(
                                  selectedCategory: "Home Equity",
                                  dropdown: false,
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content Section
                  Transform.translate(
                    offset: Offset(0, -69.h),
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
                            // ✅ LOADING STATE: Show spinner if loading and no data
                            if (equityState.loading && equityData.isEmpty)
                              SizedBox(
                                height: 200.h,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              )
                            // ✅ EMPTY STATE
                            else if (equityState.isEmpty)
                              const NoHomeEquity()
                            // ✅ DATA STATE
                            else ...[
                              Padding(
                                padding: EdgeInsets.only(top: 40.h),
                                child: Text(
                                  "List of home Equity & Their Equity"
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: const Color(0xff808080),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              ConstrainedBox(
                                constraints: const BoxConstraints(minHeight: 0),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: equityData.length,
                                  itemBuilder: (context, index) {
                                    final item = equityData[index];
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 0.h,
                                        vertical: 6.h,
                                      ),
                                      child: AssetsListCard(
                                        currency: currency,
                                        title:
                                            item['address']?['address_line_1'] ??
                                            'Unknown',
                                        subTitle: item['country'] ?? '',
                                        imagePath:
                                            'assets/wheel_segments/home_equity_icon.png',
                                        value: item['value'] ?? 0,
                                        income: item['market_value'] ?? 0,
                                        ismortgage:
                                            (item['ismortgage'] ?? 'false')
                                                .toString(),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => HomeEquityItem(
                                                item: Map<String, dynamic>.from(
                                                  item,
                                                ),
                                                imagePath:
                                                    'assets/wheel_segments/home_equity_icon.png',
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Text(
                                "Equity Distribution".toUpperCase(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              PiechartHomeEquity(
                                labels: equityDataLite["labels"] != null
                                    ? (equityDataLite["labels"] as List)
                                          .map((item) => item.toString())
                                          .toList()
                                    : [],
                                percent: equityDataLite["percentages"] != null
                                    ? (equityDataLite["percentages"] as List)
                                          .map(
                                            (item) => (item as num).toDouble(),
                                          )
                                          .toList()
                                    : [],
                                values: equityDataLite["values"] != null
                                    ? (equityDataLite["values"] as List)
                                          .map(
                                            (item) => (item as num).toDouble(),
                                          )
                                          .toList()
                                    : [],
                                gradients: equityDataLite["labels"] != null
                                    ? List<List<Color>>.generate(
                                        (equityDataLite["labels"] as List)
                                            .length,
                                        (i) => _equityGradientForIndex(i),
                                      )
                                    : [],
                              ),
                              SizedBox(height: 30.h),
                              Center(
                                child: SizedBox(
                                  width: 180.w,
                                  height: 50.h,
                                  child: InkWell(
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
                                          return const AddAssetsPopup(
                                            title: "Add Account",
                                            subTitle:
                                                "Choose the type of asset you will like to add",
                                          );
                                        },
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add,
                                          color: AppColors.primaryColor,
                                          size: 22.sp,
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          'Add Home Equity',
                                          style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 24.h),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // AppBar Overlay
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
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: iconColor,
                              size: 20.sp,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          AnimatedOpacity(
                            opacity: titleOpacity,
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              "Home Equity",
                              style: GoogleFonts.nunitoSans(
                                fontSize: 16.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Row(
                            children: [
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
                                      return const AddAssetsPopup(
                                        title: "Add Account",
                                        subTitle:
                                            "Choose the type of asset you will like to add",
                                      );
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(8.w),
                                  child: SvgPicture.asset(
                                    'assets/wheel_segments/add_thin.svg',
                                    colorFilter: ColorFilter.mode(
                                      iconColor,
                                      BlendMode.srcIn,
                                    ),
                                    width: 16.w,
                                    height: 16.h,
                                  ),
                                ),
                              ),
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
                                        title: "Home Equity",
                                        content:
                                            "Here is an aggregation of the values you have in your homes owned by you",
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
}
