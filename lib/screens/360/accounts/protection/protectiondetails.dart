import 'dart:async';
import 'dart:convert';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/portfolio/braidetails.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/customBottomSheet.dart';
import 'package:GapHub/widgets/piechart.dart';
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
import '../../wheel/360WheelScreen.dart';
import '../../widget/category_dropdown.dart';
import 'protectionItem/protectionitem.dart';
import 'provider/protection_provider.dart';
import 'widget/FrequencyPickerSheet.dart';
import 'widget/add_protection_popup.dart';
import 'widget/insuranceCard.dart';
import 'widget/noProtection.dart';

class Protectiondetails extends ConsumerStatefulWidget {
  const Protectiondetails({super.key});
  @override
  ConsumerState<Protectiondetails> createState() => _ProtectiondetailsState();
}

class _ProtectiondetailsState extends ConsumerState<Protectiondetails> {
  bool isDropdownActive = false;
  final ScrollController _scrollController = ScrollController();
  bool _appBarSolid = false;
  final bool _appBarSolid2 = false;

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

  Future<void> _loadData(String period) async {
    try {
      EasyLoading.show(status: 'Loading...');
      final controller = ref.read(
        lifeInsuranceFormProviderFamily(context.read<Providers>()).notifier,
      );
      await controller.fetchProtectionDataByPeriod(period);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString().replaceAll('Exception: ', ''));
    } finally {
      EasyLoading.dismiss();
    }
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
                  child: ThreesSixtyWheelScreen(initialCategory: "Protection"),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      setState(() => isDropdownActive = false);
    });
  }

  static const Map<String, String> _imagePathByType = {
    'Life Insurance': 'assets/wheel_segments/life_insurance.png',
    'Home Insurance': 'assets/wheel_segments/home_insurance.png',
    'Car Insurance': 'assets/wheel_segments/car_insurance.png',
    'Health Insurance': 'assets/wheel_segments/health_insurance.png',
    'Critical Illness Cover':
        'assets/wheel_segments/critical_illness_cover.png',
    'Income Protection': 'assets/wheel_segments/income_protection.png',
    'Gadget/Device Protection':
        'assets/wheel_segments/gadget_device_protection.png',
    'Others': 'assets/wheel_segments/others.png',
  };

  String _selectedFrequency = 'All';
  bool _showAllProtection = false;

  static const Map<String, String> _colorByCategory = {
    'Life Insurance': '0XFFFF5733',
    'Home Insurance': '0XFF148F77',
    'Car Insurance': '0XFF494949',
    'Health Insurance': '0XFF2471A3',
    'Critical Illness': '0XFFFFC300',
    'Income Protection': '0XFF00BCD4',
    'Gadget/Device Protection': '0XFFED3237',
    'Others': '0XFF581845',
  };

  static const Map<String, List<String>> _gradientByCategory = {
    'Life Insurance': ['0XFFF06708', '0XFFC61A24'],
    'Home Insurance': ['0XFF1D976C', '0XFF93F9B9'],
    'Car Insurance': ['0XFF355C7D', '0XFF6C5B7B'],
    'Critical Illness Cover': ['0XFFF7971E', '0XFFFFD200'],
    'Income Protection': ['0XFF36D1DC', '0XFF5B86E5'],
    'Health Insurance': ['0XFF373B44', '0XFF4286F4'],
    'Gadget/Device Protection': ['0XFF93291E', '0XFFED213A'],
    'Others': ['0XFFAA076B', '0XFF61045F'],
  };

  @override
  Widget build(BuildContext context) {
    // ✅ Safe data access - no didChangeDependencies, no null errors
    final providers = context.watch<Providers>();
    final protectionDatas = providers.protectionList ?? [];
    final protectionDataLites = providers.protectionListLite ?? {};
    final protectionDistribution = providers.protectionDistribution ?? {};
    final currency = providers.snapshotmodel.currency;

    double _displaySum = (protectionDataLites["sum"] ?? 0).toDouble();
    int wholeNumber = _displaySum.toInt();
    String decimalPart = _displaySum.toStringAsFixed(2).split('.').last;

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
                            'assets/wheel_segments/blurProtection.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                        gradient: LinearGradient(
                          colors: const [
                            // Color(0xFFF06708),  // #F06708 - Orange
                            // Color(0xFFC61A24),  // #C61A24 - Red
                            Color(0xFFF06708), // Orange overlay
                            // Colors.transparent, // Transparent at bottom
                            Colors.white,
                          ],
                          stops: [
                            0.0, // 0%
                            0.8, // 80%
                            // 1.0,    // 100%
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
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
                                    SizedBox(width: 4.w),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
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
                                              return FrequencyPickerSheet(
                                                selected: _selectedFrequency,
                                                onSelected: (value) {
                                                  setState(
                                                    () => _selectedFrequency =
                                                        value,
                                                  );
                                                  Navigator.pop(context);
                                                  _loadData(
                                                    value == 'All'
                                                        ? ''
                                                        : value.toLowerCase(),
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 5.w,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              20.r,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                _selectedFrequency == 'All'
                                                    ? 'All'
                                                    : _selectedFrequency ==
                                                          'Monthly'
                                                    ? 'PM'
                                                    : 'PA',
                                                style: GoogleFonts.nunitoSans(
                                                  fontSize: 13.sp,
                                                  color: const Color(
                                                    0xffe35D30,
                                                  ),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Transform.scale(
                                                scale: protectionDatas.isEmpty
                                                    ? 1.8
                                                    : 1.4, // Increases visual thickness
                                                child: Icon(
                                                  protectionDatas.isEmpty
                                                      ? Icons.arrow_drop_down
                                                      : Icons
                                                            .keyboard_arrow_down_rounded,
                                                  color: const Color(
                                                    0xffe35D30,
                                                  ),
                                                  size: 20.sp,
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
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 16.h,
                                  bottom: 20.h,
                                ),
                                child: CategoryDropdown(
                                  selectedCategory: "Protection",
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
                      width: double.infinity, // ✅ Add explicit width constraint
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
                          mainAxisSize:
                              MainAxisSize.min, // ✅ Take only needed space
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (protectionDatas.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 40.h),
                                child: Text(
                                  "Insurance policies & Premiums".toUpperCase(),
                                  style: TextStyle(
                                    color: const Color(0xff808080),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 12),

                            if (protectionDatas.isEmpty)
                              const NoProtection()
                            else
                              ConstrainedBox(
                                constraints: const BoxConstraints(minHeight: 0),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _showAllProtection
                                      ? protectionDatas.length
                                      : protectionDatas.length.clamp(0, 3),
                                  itemBuilder: (context, index) => Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 0.h,
                                      vertical: 6.h,
                                    ),
                                    child: InsuranceCard(
                                      currency:
                                          protectionDatas[index]['currency'] ??
                                          '',
                                      title:
                                          protectionDatas[index]['protection_type'] ??
                                          'Unknown',
                                      subTitle:
                                          protectionDatas[index]['protection_category'] ??
                                          '',
                                      imagePath:
                                          _imagePathByType[protectionDatas[index]['protection_category']] ??
                                          'assets/wheel_segments/others.png',
                                      value:
                                          protectionDatas[index]['value'] ?? 0,
                                      income:
                                          protectionDatas[index]['premium_pay'] ??
                                          0,
                                      payFrequency:
                                          (protectionDatas[index]['pay_frequency'] ??
                                                  'Monthly')
                                              .toString(),
                                      onTap: () {
                                        final category =
                                            protectionDatas[index]['protection_category']
                                                as String? ??
                                            'Others';
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Protectionitem(
                                              item: protectionDatas[index],
                                              imagePath:
                                                  _imagePathByType[category] ??
                                                  'assets/wheel_segments/others.png',
                                              gradientColors:
                                                  _gradientByCategory[category] ??
                                                  ['0XFFF06708', '0XFFC61A24'],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),

                            if (protectionDatas.length > 3)
                              InkWell(
                                onTap: () => setState(
                                  () =>
                                      _showAllProtection = !_showAllProtection,
                                ),
                                child: Container(
                                  margin: EdgeInsets.only(top: 4.h),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _showAllProtection
                                            ? ''
                                            : '+${protectionDatas.length - 3}',
                                        style: GoogleFonts.nunitoSans(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xff777777),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            _showAllProtection
                                                ? 'Show less'
                                                : 'Show more',
                                            style: GoogleFonts.nunitoSans(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xff272727),
                                            ),
                                          ),
                                          AnimatedRotation(
                                            turns: _showAllProtection ? 0.5 : 0,
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                            child: Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color: const Color(0xffB20049),
                                              size: 20.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            const SizedBox(height: 20),

                            if (protectionDatas.isNotEmpty) ...[
                              Text(
                                "Protection Distribution".toUpperCase(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 12.h),

                              Piechart(
                                labels:
                                    protectionDistribution["distribution"] !=
                                        null
                                    ? (protectionDistribution["distribution"]
                                              as List)
                                          .map(
                                            (item) =>
                                                item["category"].toString(),
                                          )
                                          .toList()
                                    : [],
                                percent:
                                    protectionDistribution["distribution"] !=
                                        null
                                    ? (protectionDistribution["distribution"]
                                              as List)
                                          .map(
                                            (item) =>
                                                (item["percentage"] as num)
                                                    .toDouble(),
                                          )
                                          .toList()
                                    : [],
                                values:
                                    protectionDistribution["distribution"] !=
                                        null
                                    ? (protectionDistribution["distribution"]
                                              as List)
                                          .map(
                                            (item) =>
                                                (item["total_premium"] as num)
                                                    .toDouble(),
                                          )
                                          .toList()
                                    : [],
                                colors:
                                    protectionDistribution["distribution"] !=
                                        null
                                    ? (protectionDistribution["distribution"]
                                              as List)
                                          .map(
                                            (item) =>
                                                _colorByCategory[item["category"]
                                                    .toString()] ??
                                                '0XFF581845',
                                          )
                                          .toList()
                                    : [],
                                gradients:
                                    protectionDistribution["distribution"] !=
                                        null
                                    ? (protectionDistribution["distribution"]
                                              as List)
                                          .map((item) {
                                            final category = item["category"]
                                                .toString();
                                            final stops =
                                                _gradientByCategory[category] ??
                                                ['0XFFAA076B', '0XFF61045F'];
                                            return [
                                              Color(int.parse(stops[0])),
                                              Color(int.parse(stops[1])),
                                            ];
                                          })
                                          .toList()
                                    : [],
                              ),
                              SizedBox(height: 30.h),
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
                                      return const AddProtectionPopup(
                                        title: "Pick your option",
                                      );
                                    },
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: AppColors.primaryColor,
                                      size: 22.sp,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      'Add Protection Account',
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
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

                          AnimatedOpacity(
                            opacity: titleOpacity,
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              "Protection",
                              style: GoogleFonts.nunitoSans(
                                fontSize: 16.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Row(
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
                                          return const AddProtectionPopup(
                                            title: "Pick your option",
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
                                            title: "Protection",
                                            content:
                                                "Here is an aggregation of all the insurance policies and premiums safeguarding you and what you own.",
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

// Keep AssetCard exactly as it was
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
