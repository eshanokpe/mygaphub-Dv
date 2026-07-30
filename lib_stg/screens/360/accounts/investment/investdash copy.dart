import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/360/widget/customSliverAppBar.dart';
import 'package:GapHub/screens/portfolio/widget/asset_class_widget.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Investdash extends StatefulWidget {
  final dynamic sums;
  final Map<String, dynamic>? braidTable;

  const Investdash({super.key, this.sums, required this.braidTable});

  @override
  // ignore: library_private_types_in_public_api
  _InvestdashState createState() => _InvestdashState();
}

class _InvestdashState extends State<Investdash> {
  bool _isDropdownActive = false;
  final ScrollController _scrollController = ScrollController();

  // Calculate total asset value for a category
  double _calculateTotalValue(List<dynamic> assets) {
    if (assets.isEmpty) return 0.0;
    return assets.fold(0.0, (sum, asset) {
      double assetValue = asset['asset_value'] is double
          ? asset['asset_value']
          : double.tryParse(asset['asset_value']?.toString() ?? '0') ?? 0.0;
      return sum + assetValue;
    });
  }

  // Calculate total monthly income for a category
  double _calculateTotalIncome(List<dynamic> assets) {
    if (assets.isEmpty) return 0.0;
    return assets.fold(0.0, (sum, asset) {
      double monthlyRoi = asset['monthly_roi'] is double
          ? asset['monthly_roi']
          : double.tryParse(asset['monthly_roi']?.toString() ?? '0') ?? 0.0;
      return sum + monthlyRoi;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Extract asset categories
    List<dynamic> businessAssets = widget.braidTable?['business'] ?? [];
    List<dynamic> riskAssets = widget.braidTable?['risk'] ?? [];
    List<dynamic> appreciatingAssets = widget.braidTable?['appreciating'] ?? [];

    // Calculate totals for each category
    double businessValue = _calculateTotalValue(businessAssets);
    double businessIncome = _calculateTotalIncome(businessAssets);

    double appreciatingValue = _calculateTotalValue(appreciatingAssets);
    double appreciatingIncome = _calculateTotalIncome(appreciatingAssets);

    double riskValue = _calculateTotalValue(riskAssets);
    double riskIncome = _calculateTotalIncome(riskAssets);

    String currency = context.read<Providers>().snapshotmodel.currency;

    return Scaffold(
      bottomNavigationBar: const BottomNav(4),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          /// SLIVER APP BAR - Using Reusable Component
          CustomSliverAppBar(
            scrollController: _scrollController,
            expandedHeight: 230.h,
            currency: currency,
            amount: widget.sums ?? 0,
            category: "Investment",
            bottomSheetTitle: "Investment",
            bottomSheetContent:
                "Lorem ipsum dolor sit amet consectetur. Augue nunc at ut adipiscing facilisi risus ut leo.",
            appBarTitle: 'Investment',
            gradient: const LinearGradient(
              colors: [Color(0xffb174e18), Color(0xffF9B423)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            blurImagePath: 'assets/wheel_segments/blurInvestment.png',
            onBackPressed: () {
              setState(() {
                _isDropdownActive = false;
              });
              Navigator.pop(context);
            },
            isDropdownActive: _isDropdownActive,
            onDropdownTap: (bool isActive) {
              setState(() {
                _isDropdownActive = isActive;
              });
            },
          ),

          /// BODY CONTENT
          SliverPadding(
            padding: EdgeInsets.only(top: 0.h),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Business Assets Card
                    // if (businessAssets.isNotEmpty)
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

                    // Appreciating Assets Card
                    // if (appreciatingAssets.isNotEmpty)
                    AssetCard(
                      title: "Appreciating Asset",
                      imagePath: 'assets/wheel_segments/house.png',
                      value: appreciatingValue,
                      income: appreciatingIncome,
                      assets: appreciatingAssets,
                      onTap: () async {
                        return getData("Appreciating", "appreciating", context);
                      },
                    ),
                    // if (appreciatingAssets.isNotEmpty)
                    SizedBox(height: 16.h),

                    // Risk Assets Card
                    // if (riskAssets.isNotEmpty)
                    AssetCard(
                      title: "Risk Asset ",
                      imagePath: 'assets/wheel_segments/risk.png',
                      value: riskValue,
                      income: riskIncome,
                      assets: riskAssets,
                      onTap: () async {
                        return getData("Risk", "risk", context);
                      },
                    ),
                    SizedBox(height: 16.h),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
            // Header Row
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
                // if (assets.isNotEmpty)
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
                // else
                //   const SizedBox(),
              ],
            ),

            const SizedBox(height: 16),

            // Inner Card
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
    String currency = context.read<Providers>().snapshotmodel.currency;
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
