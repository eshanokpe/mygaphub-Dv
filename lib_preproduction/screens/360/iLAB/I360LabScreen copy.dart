import 'dart:math';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/customBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'widget/iLab_difference_card.dart';
import 'threesixty_category_bottomSheet.dart';
import 'widget/wheel_painter_target_position.dart';
import 'widget/wheel_painter_widget.dart';

class I360LabScreen extends StatefulWidget {
  const I360LabScreen({super.key});

  @override
  State<I360LabScreen> createState() => _I360LabScreenState();
}

class _I360LabScreenState extends State<I360LabScreen> {
  int selectedIndex = -1;
  Map<String, dynamic> data = {};
  List<dynamic> b = []; // Declare b as a class variable
  bool invTick0 = true;
  bool equTick0 = true;
  bool savTick0 = true;
  bool creTick0 = true;
  bool mortTick0 = true;
  bool npTick0 = true;
  bool portTick0 = true;
  bool eduTick0 = true;
  bool perTick0 = true;
  bool discTick0 = true;
  bool expenTick1 = true;
  bool expenTick0 = true;

  // New state variables for asset-to-liability transfer
  bool investmentAssetClicked = false;
  bool homeEquityAssetClicked = false;
  bool cashAssetClicked = false;

  bool cashLiabilitiesClicked = false;
  bool mortageLiabilitiesClicked = false;

  bool nonPortfolioIncomeClicked = false;
  bool portfolioIncomeClicked = false;

  bool periodicClicked = false;
  bool educationClicked = false;
  bool expenditureClicked = false;
  bool discretionaryClicked = false;

  // Track transferred amounts
  num investmentAssets = 0;
  num equityAssets = 0;
  num savingsAssets = 0;

  num creditLiability = 0;
  num mortageLiability = 0;

  num clickedNonPortfolio = 0;
  num clickedPortfolio = 0;

  num clickedPeriodic = 0;
  num clickedEducation = 0;
  num clickedExpenditure = 0;
  num clickedDiscretionary = 0;
  Map<dynamic, dynamic> providerData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // Get the data from provider
        providerData = context.read<Providers>().ilabdata;
        // print("iLab raw data: $providerData");

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

  void onSegmentTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: ListView(
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back_ios_new, size: 18.w),
                  ),
                  InkWell(
                    onTap: () {
                      _showCategorySheet();
                    },
                    child: Image.asset(
                      'assets/wheel_segments/pencil-alt.png',
                      width: 24.w,
                      height: 24.h,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              /// TITLE
              Center(
                child: Text(
                  "360 iLAB",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              SizedBox(height: 4.h),

              Center(
                child: Text(
                  "Play with your iLAB Clock",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xff393737),
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              /// WHEEL
              const WheelPainterWidget(),

              SizedBox(height: 20.h),

              /// CURRENT POSITION BUTTON
              Center(
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
                        return const CustomBottomSheet(
                          title: 'Current Position',
                          content:
                              'Lorem ipsum dolor sit amet consectetur. Nunc pellentesque odio nibh porttitor sit id non. Commodo a rhoncus scelerisque tincidunt in mattis placerat. A non feugiat habitasse viverra mauris. In vulputate a eleifend interdum. Mollis facilisi lorem.',
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(56.r),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(
                            0xFF4A5668,
                          ), // Original: #333E4F → Lightened by 20%
                          Color(
                            0xFF7D8898,
                          ), // Original: #677283 → Lightened by 20%
                        ],
                        stops: [0.2033, 1.9251], // 20.33% and 192.51%
                        transform: GradientRotation(
                          182 * pi / 180,
                        ), // 182 degrees
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x120F1828),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/wheel_segments/information-circle.svg',
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "${DateTime.now().year} Current Position",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40.h),
              const ILabDifferenceCard(),

              SizedBox(height: 20.h),

              /// WHEEL for Target position
              const WheelPainterTargetPosition(),
              SizedBox(height: 40.h),

              /// CURRENT POSITION BUTTON
              Center(
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
                        return const CustomBottomSheet(
                          title: 'Target Position',
                          content:
                              'Lorem ipsum dolor sit amet consectetur. Nunc pellentesque odio nibh porttitor sit id non. Commodo a rhoncus scelerisque tincidunt in mattis placerat. A non feugiat habitasse viverra mauris. In vulputate a eleifend interdum. Mollis facilisi lorem.',
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(56.r),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF333E4F),
                          Color(0xFF677283),
                          // Color(0xFF293240),
                          // Color(0xFF525C6A),
                        ],
                        stops: [0.2033, 1.9251], // 20.33% and 192.51%
                        transform: GradientRotation(
                          182 * pi / 180,
                        ), // 182 degrees
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x120F1828), // rgba(16, 24, 40, 0.07)
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/wheel_segments/information-circle.svg',
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "${DateTime.now().year} Target Position",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: Material(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20.r),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.r),
                    onTap: () {
                      _showCategorySheet();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/wheel_segments/pencil-alt.png',
                            color: Colors.white,
                            width: 24.w,
                            height: 24.h,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Edit Target',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 70.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategorySheet() {
    ThreesixtyCategoryBottomSheet(context, providerData).show();
  }
}
