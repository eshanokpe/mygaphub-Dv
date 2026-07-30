import 'dart:math';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'wheel_painter.dart';

class WheelPainterWidget extends StatefulWidget {
  const WheelPainterWidget({super.key});

  @override
  State<WheelPainterWidget> createState() => _WheelPainterWidgetState();
}

class _WheelPainterWidgetState extends State<WheelPainterWidget> {
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
        if (data.isNotEmpty && data["current_ilab"] != null) {
          // Cast the map to the correct type
          Map<String, dynamic> a = Map<String, dynamic>.from(
            data["current_ilab"] as Map,
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

  void toggleLiabilitiesClicked(String liabilitiesType) {
    setState(() {
      // Get current values
      final Map<String, dynamic> currentIlab = data["current_ilab"] is Map
          ? Map<String, dynamic>.from(data["current_ilab"] as Map)
          : {};

      switch (liabilitiesType) {
        case 'credit':
          cashLiabilitiesClicked = !cashLiabilitiesClicked;
          if (cashLiabilitiesClicked) {
            creditLiability =
                num.tryParse(currentIlab["credit"]?.toString() ?? "0") ?? 0;
          } else {
            creditLiability = 0;
          }
          break;
        case 'mortgage':
          mortageLiabilitiesClicked = !mortageLiabilitiesClicked;
          if (mortageLiabilitiesClicked) {
            mortageLiability =
                num.tryParse(currentIlab["mortgage"]?.toString() ?? "0") ?? 0;
          } else {
            mortageLiability = 0;
          }
          break;
      }
    });
  }

  // Helper method to toggle asset transfer
  void toggleAssetTransfer(String assetType) {
    setState(() {
      // Get current values
      final Map<String, dynamic> currentIlab = data["current_ilab"] is Map
          ? Map<String, dynamic>.from(data["current_ilab"] as Map)
          : {};

      switch (assetType) {
        case 'investment':
          investmentAssetClicked = !investmentAssetClicked;
          if (investmentAssetClicked) {
            investmentAssets =
                num.tryParse(currentIlab["investment"]?.toString() ?? "0") ?? 0;
          } else {
            investmentAssets = 0;
          }
          break;
        case 'homeEquity':
          homeEquityAssetClicked = !homeEquityAssetClicked;
          if (homeEquityAssetClicked) {
            equityAssets =
                num.tryParse(currentIlab["equity"]?.toString() ?? "0") ?? 0;
          } else {
            equityAssets = 0;
          }
          break;
        case 'cash':
          cashAssetClicked = !cashAssetClicked;
          if (cashAssetClicked) {
            savingsAssets =
                num.tryParse(currentIlab["savings"]?.toString() ?? "0") ?? 0;
          } else {
            savingsAssets = 0;
          }
          break;
      }
    });
  }

  // Helper method to toggle income click
  void toggleIncomeClick(String incomeType) {
    setState(() {
      // Get current values
      final Map<String, dynamic> currentIlab = data["current_ilab"] is Map
          ? Map<String, dynamic>.from(data["current_ilab"] as Map)
          : {};

      switch (incomeType) {
        case 'non-portfolio':
          nonPortfolioIncomeClicked = !nonPortfolioIncomeClicked;
          if (nonPortfolioIncomeClicked) {
            clickedNonPortfolio =
                num.tryParse(currentIlab["non_portfolio"]?.toString() ?? "0") ??
                0;
          } else {
            clickedNonPortfolio = 0;
          }
          break;
        case 'portfolio':
          portfolioIncomeClicked = !portfolioIncomeClicked;
          if (portfolioIncomeClicked) {
            clickedPortfolio =
                num.tryParse(currentIlab["portfolio"]?.toString() ?? "0") ?? 0;
          } else {
            clickedPortfolio = 0;
          }
          break;
      }
    });
  }

  // Helper method to toggle budget click
  void toggleBudgetClick(String budgetType) {
    setState(() {
      // Get current values
      final Map<String, dynamic> currentIlab = data["current_ilab"] is Map
          ? Map<String, dynamic>.from(data["current_ilab"] as Map)
          : {};

      switch (budgetType) {
        case 'periodic':
          periodicClicked = !periodicClicked;
          if (periodicClicked) {
            clickedPeriodic =
                num.tryParse(
                  currentIlab["periodic_saving"]?.toString() ?? "0",
                ) ??
                0;
          } else {
            clickedPeriodic = 0;
          }
          break;
        case 'education':
          educationClicked = !educationClicked;
          if (educationClicked) {
            clickedEducation =
                num.tryParse(currentIlab["education"]?.toString() ?? "0") ?? 0;
          } else {
            clickedEducation = 0;
          }
          break;
        case 'expenditure':
          expenditureClicked = !expenditureClicked;
          if (expenditureClicked) {
            clickedExpenditure =
                num.tryParse(currentIlab["expenditure"]?.toString() ?? "0") ??
                0;
          } else {
            clickedExpenditure = 0;
          }
          break;
        case 'discretionary':
          discretionaryClicked = !discretionaryClicked;
          if (discretionaryClicked) {
            clickedDiscretionary =
                num.tryParse(currentIlab["discretionary"]?.toString() ?? "0") ??
                0;
          } else {
            clickedDiscretionary = 0;
          }
          break;
      }
    });
  }

  void onSegmentTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    String currency = context.watch<Providers>().snapshotmodel.currency;

    // Get current_ilab data with null safety
    final Map<String, dynamic> currentIlab = data["current_ilab"] is Map
        ? Map<String, dynamic>.from(data["current_ilab"] as Map)
        : {};

    var investment0 = invTick0
        ? (num.tryParse(currentIlab["investment"]?.toString() ?? "0") ?? 0)
        : 0;

    var equity0 = equTick0
        ? (num.tryParse(currentIlab["equity"]?.toString() ?? "0") ?? 0)
        : 0;

    var savings0 = savTick0
        ? (num.tryParse(currentIlab["savings"]?.toString() ?? "0") ?? 0)
        : 0;

    // Calculate asset total with clicked amounts subtracted
    num assetTotal0 =
        (investment0 - investmentAssets) +
        (equity0 - equityAssets) +
        (savings0 - savingsAssets);

    var credit0 = creTick0
        ? (num.tryParse(currentIlab["credit"]?.toString() ?? "0") ?? 0)
        : 0;
    var mortgage0 = mortTick0
        ? (num.tryParse(currentIlab["mortgage"]?.toString() ?? "0") ?? 0)
        : 0;

    // Calculate liability total with clicked amounts subtracted
    num liabilityTotal0 =
        (credit0 - creditLiability) + (mortgage0 - mortageLiability);

    var nonP0 = npTick0
        ? (num.tryParse(currentIlab["non_portfolio"]?.toString() ?? "0") ?? 0)
        : 0;
    var port0 = portTick0
        ? (num.tryParse(currentIlab["portfolio"]?.toString() ?? "0") ?? 0)
        : 0;

    // Calculate income total with clicked amounts subtracted
    var incomeTotal0 =
        (nonP0 - clickedNonPortfolio) + (port0 - clickedPortfolio);

    var periodic0 = perTick0
        ? (num.tryParse(currentIlab["periodic_saving"]?.toString() ?? "0") ?? 0)
        : 0;
    var education0 = eduTick0
        ? (num.tryParse(currentIlab["education"]?.toString() ?? "0") ?? 0)
        : 0;
    var expenditure0 = expenTick0
        ? (num.tryParse(currentIlab["expenditure"]?.toString() ?? "0") ?? 0)
        : 0;
    var discretionary0 = discTick0
        ? (num.tryParse(currentIlab["discretionary"]?.toString() ?? "0") ?? 0)
        : 0;

    // Calculate budget total with clicked amounts subtracted
    var budget0 =
        (periodic0 - clickedPeriodic) +
        (education0 - clickedEducation) +
        (expenditure0 - clickedExpenditure) +
        (discretionary0 - clickedDiscretionary);

    return GestureDetector(
      onTapUp: (details) {
        final box = context.findRenderObject() as RenderBox;
        final local = box.globalToLocal(details.globalPosition);
        final center = Offset(box.size.width / 2, box.size.height / 2);

        final dx = local.dx - center.dx;
        final dy = local.dy - center.dy;
        final distanceFromCenter = sqrt(dx * dx + dy * dy);

        if (distanceFromCenter > 80) {
          int index;

          if (dx > 0 && dy < 0) {
            index = 1;
          } else if (dx > 0 && dy > 0) {
            index = 2;
          } else if (dx < 0 && dy > 0) {
            index = 3;
          } else {
            index = 0;
          }

          // ✅ If tapping the already-selected segment, cancel/reset
          if (index == selectedIndex) {
            HapticFeedback.lightImpact();
            setState(() {
              selectedIndex = -1;
              investmentAssetClicked = false;
              homeEquityAssetClicked = false;
              cashAssetClicked = false;
              investmentAssets = 0;
              equityAssets = 0;
              savingsAssets = 0;
              // Also reset liabilities, income, and budget state
              cashLiabilitiesClicked = false;
              mortageLiabilitiesClicked = false;
              creditLiability = 0;
              mortageLiability = 0;
              nonPortfolioIncomeClicked = false;
              portfolioIncomeClicked = false;
              clickedNonPortfolio = 0;
              clickedPortfolio = 0;
              periodicClicked = false;
              educationClicked = false;
              expenditureClicked = false;
              discretionaryClicked = false;
              clickedPeriodic = 0;
              clickedEducation = 0;
              clickedExpenditure = 0;
              clickedDiscretionary = 0;
            });
          } else {
            onSegmentTap(index);
          }
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Get the actual size - this is KEY to cross-device consistency
          final wheelSize = constraints.maxWidth > 0
              ? constraints.maxWidth
              : 300.w;

          return SizedBox(
            width: wheelSize,
            height: wheelSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  painter: WheelPainter(selectedIndex: selectedIndex),
                  size: Size(wheelSize, wheelSize),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: AbsorbPointer(
                        child: _buildCenterContent(
                          currency,
                          assetTotal0,
                          liabilityTotal0,
                          budget0,
                          incomeTotal0,
                        ),
                      ),
                    ),
                  ),
                ),

                /// CANCEL ICON ON ACTIVE SEGMENT
                if (selectedIndex != -1)
                  Positioned(
                    left: _getIconPosition(selectedIndex, wheelSize).dx,
                    top: _getIconPosition(selectedIndex, wheelSize).dy,
                    child: AbsorbPointer(
                      absorbing: true,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            selectedIndex = -1;
                            investmentAssetClicked = false;
                            homeEquityAssetClicked = false;
                            cashAssetClicked = false;
                            investmentAssets = 0;
                            equityAssets = 0;
                            savingsAssets = 0;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          width: 25.w,
                          height: 25.h,
                          child: Image.asset(
                            'assets/wheel_segments/xiLab.png',
                            color: Colors.white,
                            // grade: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// CENTER CONTENT
  Widget _buildCenterContent(
    String currency,
    num assetTotal0,
    num liabilityTotal0,
    num budget0,
    num incomeTotal0,
  ) {
    if (selectedIndex == -1) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 75),
        child: Text(
          "Click on any colour to view your current position",
          textAlign: TextAlign.center,
          key: const ValueKey('default'),
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xffC5C5C5),
          ),
        ),
      );
    }

    switch (selectedIndex) {
      case 0:
        return _centerTileAssets(
          key: const ValueKey('assets'),
          title: "Asset",
          amount: "$currency${_formatNumber(assetTotal0.toString())}",
          color: const Color(0xff256825),
          currency: currency,
        );

      case 1:
        return _centerTileLiabilities(
          key: const ValueKey('liabilities'),
          title: "Liabilities",
          amount: "$currency${_formatNumber(liabilityTotal0.toString())}",
          color: const Color(0xff530182),
          currency: currency,
        );

      case 2:
        return _centerTileBudget(
          // Changed from _centerTile to _centerTileBudget
          key: const ValueKey('budget'),
          title: "Budget",
          amount: "$currency${_formatNumber(budget0.toString())}",
          color: const Color(0xffB71922),
          currency: currency,
        );

      case 3:
        return _centerTileIncome(
          key: const ValueKey('income'),
          title: "Income",
          amount: "$currency${_formatNumber(incomeTotal0.toString())}",
          color: const Color(0xffE08B1C),
          currency: currency,
        );

      default:
        return const SizedBox();
    }
  }

  Widget _centerTileBudget({
    required Key key,
    required String title,
    required String amount,
    required Color color,
    required String currency,
  }) {
    // Get current values
    final Map<String, dynamic> currentIlab = data["current_ilab"] is Map
        ? Map<String, dynamic>.from(data["current_ilab"] as Map)
        : {};

    num periodicValue =
        num.tryParse(currentIlab["periodic_saving"]?.toString() ?? "0") ?? 0;
    num educationValue =
        num.tryParse(currentIlab["education"]?.toString() ?? "0") ?? 0;
    num expenditureValue =
        num.tryParse(currentIlab["expenditure"]?.toString() ?? "0") ?? 0;
    num discretionaryValue =
        num.tryParse(currentIlab["discretionary"]?.toString() ?? "0") ?? 0;

    String numericPart = amount.replaceAll(RegExp(r'[^0-9.,-]'), '');
    String wholePart = numericPart;
    String decimalPart = '';

    if (numericPart.contains('.')) {
      List<String> parts = numericPart.split('.');
      wholePart = parts[0];
      decimalPart = '.${parts[1]}';
    }

    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        // SizedBox(height: 8.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 22.sp,
            color: const Color(0xff979797),
            fontWeight: FontWeight.w400,
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: currency,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: wholePart,
                style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: decimalPart,
                style: TextStyle(
                  fontSize: 20.sp, // Smaller font for subscript
                  fontWeight: FontWeight.w700,
                  color: AppColors.grayColor,
                  textBaseline: TextBaseline.alphabetic,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),

        /// Budget tags
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // First row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInteractiveTag(
                  label: "Savings Periodic",
                  iconPath: 'assets/wheel_segments/check-circle.svg',
                  backgroundColor: periodicClicked
                      ? const Color(0xffD2D2D2) // Gray color when clicked
                      : const Color(0xffB71922), // Red color for budget
                  value: periodicValue,
                  currency: currency,
                  isAssetClicked: periodicClicked,
                  onTap: () => toggleBudgetClick('periodic'),
                ),
                SizedBox(width: 8.w),
                _buildInteractiveTag(
                  label: "Education",
                  iconPath: 'assets/wheel_segments/check-circle.svg',
                  backgroundColor: educationClicked
                      ? const Color(0xffD2D2D2) // Gray color when clicked
                      : const Color(0xffB71922), // Red color for budget
                  value: educationValue,
                  currency: currency,
                  isAssetClicked: educationClicked,
                  onTap: () => toggleBudgetClick('education'),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Second row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInteractiveTag(
                  label: "Expenditure",
                  iconPath: 'assets/wheel_segments/check-circle.svg',
                  backgroundColor: expenditureClicked
                      ? const Color(0xffD2D2D2) // Gray color when clicked
                      : const Color(0xffB71922), // Red color for budget
                  value: expenditureValue,
                  currency: currency,
                  isAssetClicked: expenditureClicked,
                  onTap: () => toggleBudgetClick('expenditure'),
                ),
                SizedBox(width: 8.w),
                _buildInteractiveTag(
                  label: "Discretionary",
                  iconPath: 'assets/wheel_segments/check-circle.svg',
                  backgroundColor: discretionaryClicked
                      ? const Color(0xffD2D2D2) // Gray color when clicked
                      : const Color(0xffB71922), // Red color for budget
                  value: discretionaryValue,
                  currency: currency,
                  isAssetClicked: discretionaryClicked,
                  onTap: () => toggleBudgetClick('discretionary'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _centerTileIncome({
    required Key key,
    required String title,
    required String amount,
    required Color color,
    required String currency,
  }) {
    // Get current values
    final Map<String, dynamic> currentIlab = data["current_ilab"] is Map
        ? Map<String, dynamic>.from(data["current_ilab"] as Map)
        : {};

    num nonPortfolioValue =
        num.tryParse(currentIlab["non_portfolio"]?.toString() ?? "0") ?? 0;
    num portfolioValue =
        num.tryParse(currentIlab["portfolio"]?.toString() ?? "0") ?? 0;
    // Parse the amount to separate whole and decimal parts
    String numericPart = amount.replaceAll(RegExp(r'[^0-9.,-]'), '');
    String wholePart = numericPart;
    String decimalPart = '';

    if (numericPart.contains('.')) {
      List<String> parts = numericPart.split('.');
      wholePart = parts[0];
      decimalPart = '.${parts[1]}';
    }

    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 8.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 22.sp,
            color: const Color(0xff979797),
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 4.h),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: currency,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: wholePart,
                style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: decimalPart,
                style: TextStyle(
                  fontSize: 20.sp, // Smaller font for subscript
                  fontWeight: FontWeight.w800,
                  color: AppColors.grayColor,
                  textBaseline: TextBaseline.alphabetic,
                ),
              ),
            ],
          ),
        ),
        //  Text(
        //   _formatNumber(amount),
        //   style: TextStyle(
        //     fontSize: 28.sp,
        //     fontWeight: FontWeight.w800,
        //     color: Colors.black,
        //   ),
        // ),
        SizedBox(height: 12.h),

        /// Income tags
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInteractiveTag(
                  label: "Non-Portfolio",
                  iconPath: 'assets/wheel_segments/check-circle.svg',
                  backgroundColor: nonPortfolioIncomeClicked
                      ? const Color(0xffD2D2D2) // Brown color for liability
                      : const Color(0xffE08B1C), // Green for asset
                  value: nonPortfolioValue,
                  currency: currency,
                  isAssetClicked: nonPortfolioIncomeClicked,
                  onTap: () => toggleIncomeClick('non-portfolio'),
                ),
                SizedBox(width: 8.w),
                _buildInteractiveTag(
                  label: "Portfolio",
                  iconPath: 'assets/wheel_segments/check-circle.svg',
                  backgroundColor: portfolioIncomeClicked
                      ? const Color(0xffD2D2D2) // Brown color for liability
                      : const Color(0xffE08B1C), // Green for asset
                  value: portfolioValue,
                  currency: currency,
                  isAssetClicked: portfolioIncomeClicked,
                  onTap: () => toggleIncomeClick('portfolio'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _centerTileAssets({
    required Key key,
    required String title,
    required String amount,
    required Color color,
    required String currency,
  }) {
    // Get current values
    final Map<String, dynamic> currentIlab = data["current_ilab"] is Map
        ? Map<String, dynamic>.from(data["current_ilab"] as Map)
        : {};

    num investmentValue =
        num.tryParse(currentIlab["investment"]?.toString() ?? "0") ?? 0;
    num equityValue =
        num.tryParse(currentIlab["equity"]?.toString() ?? "0") ?? 0;
    num savingsValue =
        num.tryParse(currentIlab["savings"]?.toString() ?? "0") ?? 0;

    // Parse the amount to separate whole and decimal parts
    String numericPart = amount.replaceAll(RegExp(r'[^0-9.,-]'), '');
    String wholePart = numericPart;
    String decimalPart = '';

    if (numericPart.contains('.')) {
      List<String> parts = numericPart.split('.');
      wholePart = parts[0];
      decimalPart = '.${parts[1]}';
    }

    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 8.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 22.sp,
            color: const Color(0xff979797),
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 4.h),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: currency,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: wholePart,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: decimalPart,
                style: TextStyle(
                  fontSize: 20.sp, // Smaller font for subscript
                  fontWeight: FontWeight.w800,
                  color: AppColors.grayColor,
                  textBaseline: TextBaseline.alphabetic,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 12.h),

        /// Interactive tags
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInteractiveTag(
                  label: "Investments",
                  iconPath: 'assets/wheel_segments/check-circle.svg',
                  backgroundColor: investmentAssetClicked
                      ? const Color(0xffD2D2D2) // Brown color for liability
                      : const Color(0xff256825), // Green for asset
                  value: investmentValue,
                  currency: currency,
                  isAssetClicked: investmentAssetClicked,
                  onTap: () => toggleAssetTransfer('investment'),
                ),
                SizedBox(width: 8.w),
                _buildInteractiveTag(
                  label: "Home Equity",
                  iconPath: 'assets/wheel_segments/check-circle.svg',
                  backgroundColor: homeEquityAssetClicked
                      ? const Color(0xffD2D2D2)
                      : const Color(0xff256825),
                  value: equityValue,
                  currency: currency,
                  isAssetClicked: homeEquityAssetClicked,
                  onTap: () => toggleAssetTransfer('homeEquity'),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            _buildInteractiveTag(
              label: "Cash",
              iconPath: 'assets/wheel_segments/check-circle.svg',
              backgroundColor: cashAssetClicked
                  ? const Color(0xffD2D2D2)
                  : const Color(0xff256825),
              value: savingsValue,
              currency: currency,
              isAssetClicked: cashAssetClicked,
              onTap: () => toggleAssetTransfer('cash'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _centerTileLiabilities({
    required Key key,
    required String title,
    required String amount,
    required Color color,
    required String currency,
  }) {
    // Get current values
    final Map<String, dynamic> currentIlab = data["current_ilab"] is Map
        ? Map<String, dynamic>.from(data["current_ilab"] as Map)
        : {};

    num creditValue =
        num.tryParse(currentIlab["credit"]?.toString() ?? "0") ?? 0;
    num mortgageValue =
        num.tryParse(currentIlab["mortgage"]?.toString() ?? "0") ?? 0;

    String numericPart = amount.replaceAll(RegExp(r'[^0-9.,-]'), '');
    String wholePart = numericPart;
    String decimalPart = '';

    if (numericPart.contains('.')) {
      List<String> parts = numericPart.split('.');
      wholePart = parts[0];
      decimalPart = '.${parts[1]}';
    }

    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 8.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 22.sp,
            color: const Color(0xff979797),
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 4.h),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: currency,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: wholePart,
                style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: decimalPart,
                style: TextStyle(
                  fontSize: 20.sp, // Smaller font for subscript
                  fontWeight: FontWeight.w700,
                  color: AppColors.grayColor,
                  textBaseline: TextBaseline.alphabetic,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),

        /// Interactive tags
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInteractiveTag(
                  label: "Credit",
                  iconPath: 'assets/wheel_segments/check-circle.svg',
                  backgroundColor: cashLiabilitiesClicked
                      ? const Color(0xffD2D2D2) // Brown color for liability
                      : const Color(0xff530182), // Green for asset
                  value: creditValue,
                  currency: currency,
                  isAssetClicked: cashLiabilitiesClicked,
                  onTap: () => toggleLiabilitiesClicked('credit'),
                ),
                SizedBox(width: 8.w),
                _buildInteractiveTag(
                  label: "Mortgage",
                  iconPath: 'assets/wheel_segments/check-circle.svg',
                  backgroundColor: mortageLiabilitiesClicked
                      ? const Color(0xffD2D2D2)
                      : const Color(0xff530182),
                  value: mortgageValue,
                  currency: currency,
                  isAssetClicked: mortageLiabilitiesClicked,
                  onTap: () => toggleLiabilitiesClicked('mortgage'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Helper method to build interactive tags
  Widget _buildInteractiveTag({
    required String label,
    required String iconPath,
    required Color backgroundColor,
    required num value,
    required String currency,
    required bool isAssetClicked,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: backgroundColor,
        ),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: isAssetClicked ? 0.95 : 1.0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: 1.0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isAssetClicked)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.elasticOut,
                    child: SvgPicture.asset(
                      iconPath,
                      width: 16.w,
                      height: 16.h,
                      color: Colors.white,
                    ),
                  ),
                if (!isAssetClicked) SizedBox(width: 5.w),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: isAssetClicked
                        ? FontWeight.w700
                        : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(String amount) {
    // Remove currency symbol if present for formatting
    String cleanAmount = amount.replaceAll(RegExp(r'[^0-9.-]'), '');
    String currency =
        data["currency"] ??
        context.watch<Providers>().snapshotmodel.currency ??
        '£';

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

      // Return the formatted number
      return '$currency$wholePart.$decimalPart';
    } catch (e) {
      return amount;
    }
  }

  Offset _getIconPosition(int index, double wheelSize) {
    final center = wheelSize / 2;
    final arcRadius = wheelSize / 2 - 2;
    final iconSize = 24.w;

    // Calculate the exact angle for the arc based on the painter's logic
    // The painter uses: startAngle = -pi/2 + (i * pi/2) - 0.85
    // And sweep = 0.22
    // We need the middle of the arc
    final startAngle = -pi / 2 + (index * pi / 2) - 0.85;
    const sweep = 0.22;
    final middleAngle = startAngle + (sweep / 2);

    // Calculate position on arc
    final x = center + arcRadius * cos(middleAngle);
    final y = center + arcRadius * sin(middleAngle);

    // Add specific offsets for each quadrant to fine-tune positioning
    double offsetX = 0;
    double offsetY = 0;

    switch (index) {
      case 0: // Green - Top Left (Asset)
        offsetX = -1;
        offsetY = 1;
        break;
      case 1: // Purple - Top Right (Liabilities)
        offsetX = -2;
        offsetY = -2;
        break;
      case 2: // Red - Bottom Right (Budget)
        offsetX = 2;
        offsetY = -2;
        break;
      case 3: // Orange - Bottom Left (Income)
        offsetX = 0;
        offsetY = 0;
        break;
    }

    return Offset(x - (iconSize / 2) + offsetX, y - (iconSize / 2) + offsetY);
  }
}
