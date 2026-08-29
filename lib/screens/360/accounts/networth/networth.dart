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
import 'widget/add_networth_popup.dart';
import 'widget/netWorthDistributionCard.dart';
import 'widget/networthContent.dart';

class Networth extends ConsumerStatefulWidget {
  final Map item;
  final List? seveng;
  final List? bespokes;
  final num? invSum;
  final Map<String, dynamic>? braidTable;
  final List? mapList;
  final Map? mapListLite;

  const Networth({
    super.key,
    required this.item,
    this.seveng,
    this.bespokes,
    this.invSum,
    this.braidTable,
    this.mapList,
    this.mapListLite,
  });

  @override
  ConsumerState<Networth> createState() => _NetworthState();
}

class _NetworthState extends ConsumerState<Networth> {
  bool isDropdownActive = false;
  final ScrollController _scrollController = ScrollController();
  bool _appBarSolid = false;

  // Toggle state for what's included in the total net worth sum.
  bool _includePension = true;
  bool _includeHomeEquity = true;

  void _togglePension() {
    setState(() => _includePension = !_includePension);
  }

  void _toggleHomeEquity() {
    setState(() => _includeHomeEquity = !_includeHomeEquity);
  }

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

    // ✅ Fetch ALL financial data in parallel as soon as the screen renders
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
                const Expanded(
                  child: ThreesSixtyWheelScreen(initialCategory: "Networths"),
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

  /// Computes the total net worth figure based on the current toggle state.
  num _calculateDisplaySum({
    required num assetSum,
    required num liabilitySum,
    required num equitySum,
    required num pensionSum,
  }) {
    // Net Worth = Assets - Liabilities + (Optional Equity/Pension if not already in Assets)
    // Note: Adjust this logic based on whether 'assetSum' from API already includes equity/pension.
    // Assuming standard logic: Total Net Worth = (Assets + Equity + Pension) - Liabilities

    num totalAssets = assetSum;
    if (_includeHomeEquity) totalAssets += equitySum;
    if (_includePension) totalAssets += pensionSum;

    return totalAssets - liabilitySum;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 1. Watch ALL providers so the header total updates reactively
    final investmentState = ref.watch(investmentProvider);
    final equityState = ref.watch(equityProvider);
    final cashState = ref.watch(cashProvider);
    final pensionState = ref.watch(pensionProvider);

    // Keep legacy provider for currency and static assetsData if needed
    final providers = context.watch<Providers>();
    final currency = providers.snapshotmodel.currency;
    final assetsData = providers.assetsData;

    // ✅ 2. Extract sums safely (fallback to 0 while loading)
    // Note: If widget.item contains pre-calculated sums, you might prefer those.
    // However, using providers ensures real-time accuracy after edits.
    final double invSum = investmentState.loading
        ? 0
        : (investmentState.investmentSum ?? 0).toDouble();
    final double cashSum = cashState.loading
        ? 0
        : (cashState.cashDetail?["sum"] ?? 0).toDouble();

    // Combine Cash and Investment into "Current Assets" for this screen if needed,
    // or use the passed widget.item values if they represent the total snapshot.
    // For consistency with previous screens, let's use the provider values for dynamic parts:

    final double equitySum = equityState.loading
        ? 0
        : (equityState.equityDetail?["sum"] ?? 0).toDouble();
    final double pensionSum = pensionState.loading
        ? 0
        : (pensionState.pensionDetail?["sum"] ?? 0).toDouble();

    // Use legacy data for Asset/Liability totals if they come from a different endpoint (snapshot)
    final num assetSumFromSnapshot =
        double.tryParse(widget.item["net"]["asset"].toString()) ?? 0;
    final num liabilitySum =
        double.tryParse(widget.item["net"]["liability"].toString()) ?? 0;

    // Calculate Display Sum dynamically
    final num displaySum = _calculateDisplaySum(
      assetSum:
          assetSumFromSnapshot, // Or use (invSum + cashSum) if you want purely live calculation
      liabilitySum: liabilitySum,
      equitySum: equitySum,
      pensionSum: pensionSum,
    );

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
                  AnnotatedRegion<SystemUiOverlayStyle>(
                    value: const SystemUiOverlayStyle(
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness: Brightness.light,
                      statusBarBrightness: Brightness.dark,
                    ),
                    child: Container(
                      height: 300.h,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/wheel_segments/networthblur.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                        gradient: LinearGradient(
                          colors: [Color(0xFF134EB2), Color(0xff266C26)],
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
                                  selectedCategory: "Net Worth",
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
                            // ✅ 3. Pass live provider data to NetworthContent
                            NetworthContent(
                              mapList: widget.mapList,
                              mapListLite: widget.mapListLite,
                              seveng: widget.seveng ?? [],
                              bespokes: widget.bespokes ?? [],
                              invSum: invSum, // Live value
                              braidTable:
                                  investmentState.braidTable, // Live value
                              assetSum: assetSumFromSnapshot,
                              equitySum: equitySum, // Live value
                              liabilitySum: liabilitySum,
                              pensionSum: pensionSum, // Live value
                              includePension: _includePension,
                              includeHomeEquity: _includeHomeEquity,
                              onPensionTap: _togglePension,
                              onHomeEquityTap: _toggleHomeEquity,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              "Net worth Distribution".toUpperCase(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            if (widget.item.isNotEmpty)
                              NetWorthDistributionCard(
                                netDetail: widget.item['net_detail'],
                              ),
                            if (widget.item.isEmpty)
                              Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xffEEEEEE),
                                    width: 0.7,
                                  ),
                                ),
                                child: SizedBox(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 170.h,
                                          child: Center(
                                            child: Text(
                                              'Add your assets to view their distribution',
                                              style: GoogleFonts.nunitoSans(
                                                fontSize: 14.sp,
                                                color: const Color(0xff808080),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: const Color(0xffF7F7F7),
                                            border: Border.all(
                                              color: const Color(0xffEEEEEE),
                                              width: 0.7,
                                            ),
                                          ),
                                          child: const Column(
                                            children: [
                                              AssetRow(label: 'Investment'),
                                              AssetRow(label: 'Cash'),
                                              AssetRow(label: 'Pension'),
                                              AssetRow(label: 'Home Equity'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
                                      builder: (context) =>
                                          const FractionallySizedBox(
                                            heightFactor: 1.9,
                                            child: AddNetworkPopup(
                                              title: 'Select an account to add',
                                              subTitle: '...',
                                            ),
                                          ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: AppColors.primaryColor,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        'Add Account',
                                        style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
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
                    ),
                  ),
                ],
              ),
            ),
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
                              "Net Worth",
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
                                    builder: (context) =>
                                        const FractionallySizedBox(
                                          heightFactor: 1.9,
                                          child: AddNetworkPopup(
                                            title: 'Select an account to add',
                                            subTitle: '...',
                                          ),
                                        ),
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
                                        title: "Net Worth",
                                        content:
                                            "Here is the difference between what you own and what you owe financially.",
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
