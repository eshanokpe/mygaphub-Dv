import 'dart:math';
import 'dart:typed_data';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;

import 'I360LabScreen.dart';

class ThreesSixtyWheelScreen extends StatefulWidget {
  const ThreesSixtyWheelScreen({super.key});

  @override
  State<ThreesSixtyWheelScreen> createState() => _ThreesSixtyWheelScreenState();
}

class _ThreesSixtyWheelScreenState extends State<ThreesSixtyWheelScreen> {
  double rotation = 0;
  int selectedIndex = 0;
  bool _isDragging = false;
  List<ui.Image> _segmentImages = [];
  List<ui.Image> _centerIcons = [];
  bool _imagesLoaded = false;

  late final List<WheelItem> _wheelItems;
  late final List<WheelItemSideCard> _sideCardItems;
  late final List<String> _segmentImagePaths;
  late final List<String> _centerIconPaths;

  @override
  void initState() {
    super.initState();
    _initializeWheelData();
    _loadAllImages();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialRotation();
    });
  }

  void _setInitialRotation() {
    final sectionAngle = (2 * pi) / _wheelItems.length;
    double pointerAngle = -pi / 2;
    double targetRotation =
        (pointerAngle - (0 * sectionAngle + sectionAngle / 2)) % (2 * pi);
    if (targetRotation > pi) targetRotation -= 2 * pi;

    setState(() {
      rotation = targetRotation;
    });
  }

  void _initializeWheelData() {
    _wheelItems = [
      WheelItem(
        title: "Net Worth",
        activeCardPath: 'assets/wheel_segments/Networth.png',
        segmentPath: 'assets/wheel_segments/segment_networth.png',
        centerIconPath: 'assets/wheel_segments/networth_icon.png',
      ),
      WheelItem(
        title: "Assets",
        activeCardPath: 'assets/wheel_segments/Assets.png',
        segmentPath: 'assets/wheel_segments/segment_assets.png',
        centerIconPath: 'assets/wheel_segments/assets_icon.png',
      ),
      WheelItem(
        title: "Income",
        activeCardPath: 'assets/wheel_segments/Income.png',
        segmentPath: 'assets/wheel_segments/segment_income.png',
        centerIconPath: 'assets/wheel_segments/income_icon.png',
      ),
      WheelItem(
        title: "Strategy",
        activeCardPath: 'assets/wheel_segments/Strategy.png',
        segmentPath: 'assets/wheel_segments/segment_strategy.png',
        centerIconPath: 'assets/wheel_segments/strategy_icon.png',
      ),
      WheelItem(
        title: "Philanthropy",
        activeCardPath: 'assets/wheel_segments/Philanthropy.png',
        segmentPath: 'assets/wheel_segments/segment_philanthropy.png',
        centerIconPath: 'assets/wheel_segments/philanthropy_icon.png',
      ),
      WheelItem(
        title: "Mortgage",
        activeCardPath: 'assets/wheel_segments/Mortgage.png',
        segmentPath: 'assets/wheel_segments/segment_mortgage.png',
        centerIconPath: 'assets/wheel_segments/mortgage_icon.png',
      ),
      WheelItem(
        title: "Cash",
        activeCardPath: 'assets/wheel_segments/Cash.png',
        segmentPath: 'assets/wheel_segments/segment_cash.png',
        centerIconPath: 'assets/wheel_segments/cash_icon.png',
      ),
      WheelItem(
        title: "Investment",
        activeCardPath: 'assets/wheel_segments/Investment.png',
        segmentPath: 'assets/wheel_segments/segment_investment.png',
        centerIconPath: 'assets/wheel_segments/investment_icon.png',
      ),
      WheelItem(
        title: "Retirement",
        activeCardPath: 'assets/wheel_segments/Retirement.png',
        segmentPath: 'assets/wheel_segments/segment_retirement.png',
        centerIconPath: 'assets/wheel_segments/retirement_icon.png',
      ),
      WheelItem(
        title: "Protection",
        activeCardPath: 'assets/wheel_segments/Protection.png',
        segmentPath: 'assets/wheel_segments/segment_protection.png',
        centerIconPath: 'assets/wheel_segments/protection_icon.png',
      ),
      WheelItem(
        title: "Expenditure",
        activeCardPath: 'assets/wheel_segments/Expenditure.png',
        segmentPath: 'assets/wheel_segments/segment_expenditure.png',
        centerIconPath: 'assets/wheel_segments/expenditure_icon.png',
      ),
      WheelItem(
        title: "Liabilities",
        activeCardPath: 'assets/wheel_segments/Liabilities.png',
        segmentPath: 'assets/wheel_segments/segment_liabilities.png',
        centerIconPath: 'assets/wheel_segments/liabilities_icon.png',
      ),
    ];

    _sideCardItems = [
      WheelItemSideCard(
        title: _wheelItems[0].title,
        imagePath: 'assets/wheel_segments/NetworthSideCard.png',
      ),
      WheelItemSideCard(
        title: _wheelItems[1].title,
        imagePath: 'assets/wheel_segments/AssetsSideCard.png',
      ),
      WheelItemSideCard(
        title: _wheelItems[2].title,
        imagePath: 'assets/wheel_segments/IncomeInactive.png',
      ),
      WheelItemSideCard(
        title: _wheelItems[3].title,
        imagePath: 'assets/wheel_segments/StrategyInactive.png',
      ),
      WheelItemSideCard(
        title: _wheelItems[4].title,
        imagePath: 'assets/wheel_segments/PhilanthropyInactive.png',
      ),
      WheelItemSideCard(
        title: _wheelItems[5].title,
        imagePath: 'assets/wheel_segments/MortgageInactive.png',
      ),
      WheelItemSideCard(
        title: _wheelItems[6].title,
        imagePath: 'assets/wheel_segments/CashInactive.png',
      ),
      WheelItemSideCard(
        title: _wheelItems[7].title,
        imagePath: 'assets/wheel_segments/InvestmentInactive.png',
      ),
      WheelItemSideCard(
        title: _wheelItems[8].title,
        imagePath: 'assets/wheel_segments/RetirementInactive.png',
      ),
      WheelItemSideCard(
        title: _wheelItems[9].title,
        imagePath: 'assets/wheel_segments/ProtectionInactive.png',
      ),
      WheelItemSideCard(
        title: _wheelItems[10].title,
        imagePath: 'assets/wheel_segments/ExpenditureInactive.png',
      ),
      WheelItemSideCard(
        title: _wheelItems[11].title,
        imagePath: 'assets/wheel_segments/LiabilitiesInactive.png',
      ),
    ];

    _segmentImagePaths = _wheelItems.map((item) => item.segmentPath).toList();
    _centerIconPaths = _wheelItems.map((item) => item.centerIconPath).toList();
  }

  Future<void> _loadAllImages() async {
    List<ui.Image> segmentImages = [];
    List<ui.Image> iconImages = [];

    for (int i = 0; i < _segmentImagePaths.length; i++) {
      try {
        final String path = _segmentImagePaths[i];
        final ByteData data = await rootBundle.load(path);
        final Uint8List bytes = data.buffer.asUint8List();
        final ui.Codec codec = await ui.instantiateImageCodec(bytes);
        final ui.FrameInfo frame = await codec.getNextFrame();
        segmentImages.add(frame.image);
      } catch (e) {
        print(
          'Error loading segment image at index $i: ${_wheelItems[i].title} - $e',
        );
      }
    }

    for (int i = 0; i < _centerIconPaths.length; i++) {
      try {
        final String path = _centerIconPaths[i];
        final ByteData data = await rootBundle.load(path);
        final Uint8List bytes = data.buffer.asUint8List();
        final ui.Codec codec = await ui.instantiateImageCodec(bytes);
        final ui.FrameInfo frame = await codec.getNextFrame();
        iconImages.add(frame.image);
      } catch (e) {
        print(
          'Error loading icon image at index $i: ${_wheelItems[i].title} - $e',
        );
      }
    }

    if (mounted) {
      setState(() {
        _segmentImages = segmentImages;
        _centerIcons = iconImages;
        _imagesLoaded = true;
      });
    }
  }

  void _updateSelectedIndex() {
    final sectionAngle = (2 * pi) / _wheelItems.length;
    double normalizedRotation = rotation % (2 * pi);
    if (normalizedRotation < 0) normalizedRotation += 2 * pi;

    double pointerAngle = -pi / 2;
    double angleDiff = (pointerAngle - normalizedRotation) % (2 * pi);
    int newIndex = (angleDiff / sectionAngle).floor() % _wheelItems.length;

    if (newIndex != selectedIndex) {
      setState(() {
        selectedIndex = newIndex;
      });
    }
  }

  void _snapToNearest() {
    if (_isDragging) return;

    final sectionAngle = (2 * pi) / _wheelItems.length;
    double pointerAngle = -pi / 2;
    double normalizedRotation = rotation % (2 * pi);
    if (normalizedRotation < 0) normalizedRotation += 2 * pi;

    double angleDiff = (pointerAngle - normalizedRotation) % (2 * pi);
    int targetIndex = (angleDiff / sectionAngle).round() % _wheelItems.length;

    double targetRotation =
        (pointerAngle - (targetIndex * sectionAngle + sectionAngle / 2)) %
        (2 * pi);
    if (targetRotation > pi) targetRotation -= 2 * pi;

    setState(() {
      rotation = targetRotation;
      selectedIndex = targetIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Always return the UI immediately, no loading indicator
    return Container(
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Container(
                    padding: EdgeInsets.all(8.w), // Added .w
                    child: Text(
                      "Scroll across to view more",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xff393737),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),

                /// Animate Right and Left
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: Image.asset(
                          'assets/wheel_segments/animate_right.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: Image.asset(
                          'assets/wheel_segments/animate_left.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),

                /// CAROUSEL SLIDER CARD
                SizedBox(
                  height: constraints.maxHeight * 0.5,
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: _buildActiveCard(_wheelItems[selectedIndex]),
                        ),
                      ),

                      Positioned(
                        left: -screenWidth * 0.2,
                        top: 30.h, // Added .h
                        child: _buildSideCard(
                          _sideCardItems[(selectedIndex -
                                  1 +
                                  _sideCardItems.length) %
                              _sideCardItems.length],
                          true,
                        ),
                      ),

                      Positioned(
                        right: -screenWidth * 0.2,
                        top: 30.h, // Added .h
                        child: _buildSideCard(
                          _sideCardItems[(selectedIndex + 1) %
                              _sideCardItems.length],
                          false,
                        ),
                      ),
                    ],
                  ),
                ),

                /// STATIC WHEEL
                SizedBox(
                  height: constraints.maxHeight * 0.42,
                  child: Container(
                    color: Colors.white,
                    child: ClipRect(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(color: Colors.white),
                          ),

                          Positioned(
                            bottom: -160.h, // Changed to .h
                            left: 0,
                            right: 0,
                            child: GestureDetector(
                              onPanStart: (_) {
                                setState(() {
                                  _isDragging = true;
                                });
                              },
                              onPanUpdate: (details) {
                                setState(() {
                                  rotation += details.delta.dx * 0.01;
                                  _updateSelectedIndex();
                                });
                              },
                              onPanEnd: (_) {
                                setState(() {
                                  _isDragging = false;
                                });
                                _snapToNearest();
                              },
                              child: Container(
                                height: 360.h,
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: CustomPaint(
                                  size: Size(400.w, 400.w),
                                  painter: RotatingWheelPainter(
                                    _wheelItems,
                                    rotation,
                                    selectedIndex,
                                    _segmentImages,
                                    _centerIcons,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            bottom: -40.h, // Changed to .h
                            left: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const I360LabScreen(),
                                  ),
                                );
                              },
                              child: Center(
                                child: Container(
                                  width: 150.w,
                                  height: 160.h,
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    'assets/images/ILAB.png',
                                    width:
                                        150.w, // Added width for responsiveness
                                    height: 160
                                        .h, // Added height for responsiveness
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            top: 25.h, // Changed to .h
                            left: 0,
                            right: 0,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Image.asset(
                                    'assets/images/pointer.png',
                                    width: 50.w,
                                    height: 50.h,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 12.h,
                                  ), // Changed to .h
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: SizedBox(
                                      width: 8.w,
                                      height: 8.h,
                                      child: Image.asset(
                                        'assets/images/pointer_inside.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // TOP ARROWS - MOVED TO END SO THEY'RE ON TOP
                          Positioned(
                            top: 70.h, // Changed to .h
                            left: 0,
                            right: 0,
                            height: 30.h,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Stack(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Left Arrow with Click Handler
                                      SizedBox(
                                        width: 18.w,
                                        height: 18.h,
                                        child: GestureDetector(
                                          onTap: () {
                                            print("Left arrow tapped");
                                            setState(() {
                                              final sectionAngle =
                                                  (2 * pi) / _wheelItems.length;
                                              // Calculate new selected index directly
                                              int newIndex =
                                                  (selectedIndex -
                                                      1 +
                                                      _wheelItems.length) %
                                                  _wheelItems.length;
                                              selectedIndex = newIndex;

                                              // Calculate the rotation needed for this index
                                              const double pointerAngle =
                                                  -pi / 2;
                                              double targetRotation =
                                                  (pointerAngle -
                                                      (newIndex * sectionAngle +
                                                          sectionAngle / 2)) %
                                                  (2 * pi);
                                              if (targetRotation > pi)
                                                targetRotation -= 2 * pi;
                                              rotation = targetRotation;
                                            });
                                          },
                                          child: Image.asset(
                                            'assets/wheel_segments/animate_left_wheel.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),

                                      // Right Arrow with Click Handler
                                      SizedBox(
                                        width: 18.w,
                                        height: 18.h,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              // Calculate rotation to move to next item (counter-clockwise rotation)
                                              final sectionAngle =
                                                  (2 * pi) / _wheelItems.length;
                                              rotation -=
                                                  sectionAngle; // Subtract sectionAngle to rotate counter-clockwise
                                              _updateSelectedIndex();
                                              _snapToNearest();
                                            });
                                          },
                                          child: Image.asset(
                                            'assets/wheel_segments/animate_right_wheel.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ],
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
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveCard(WheelItem item) {
    return Container(
      width: 400.w, // Added .w
      height: 300.h, // Added .h
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r), // Added .r
        image: DecorationImage(
          image: AssetImage(item.activeCardPath),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildSideCard(WheelItemSideCard item, bool isLeft) {
    return Container(
      width: 180.w, // Added .w
      height: 210.h, // Added .h
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r), // Added .r
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.r), // Added .r
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.cover,
                width: 180.w, // Added width for responsiveness
                height: 210.h, // Added height for responsiveness
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WheelItem {
  final String title;
  final String activeCardPath;
  final String segmentPath;
  final String centerIconPath;

  WheelItem({
    required this.title,
    required this.activeCardPath,
    required this.segmentPath,
    required this.centerIconPath,
  });
}

class WheelItemSideCard {
  final String title;
  final String imagePath;

  WheelItemSideCard({required this.title, required this.imagePath});
}

/// ROTATING WHEEL PAINTER
class RotatingWheelPainter extends CustomPainter {
  final List<WheelItem> items;
  final double rotation;
  final int selectedIndex;
  final List<ui.Image> segmentImages;
  final List<ui.Image> centerIcons;

  RotatingWheelPainter(
    this.items,
    this.rotation,
    this.selectedIndex,
    this.segmentImages,
    this.centerIcons,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // Fill the entire canvas with white first
    canvas.drawColor(Colors.white, BlendMode.srcOver);

    final radius = size.width / 2.0;
    final center = Offset(radius, radius);
    final sweep = 2 * pi / items.length;

    // Draw the outer ring segments
    for (int i = 0; i < items.length; i++) {
      final startAngle = sweep * i + rotation;
      final rect = Rect.fromCircle(center: center, radius: radius);

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(rect, startAngle, sweep, false)
        ..close();

      // Draw segment with image if available, otherwise show placeholder
      if (i < segmentImages.length && segmentImages.isNotEmpty) {
        canvas.save();
        canvas.clipPath(path);

        final image = segmentImages[i];
        final double scale = (2 * radius) / min(image.width, image.height);
        final double scaledWidth = image.width * scale;
        final double scaledHeight = image.height * scale;

        final double left = center.dx - scaledWidth / 2;
        final double top = center.dy - scaledHeight / 2;

        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(startAngle + sweep / 2);
        canvas.translate(-center.dx, -center.dy);

        canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          Rect.fromLTWH(left, top, scaledWidth, scaledHeight),
          Paint(),
        );

        canvas.restore();
        canvas.restore();
      } else {
        // Placeholder while images load
        final placeholderPaint = Paint()
          ..color = Colors.grey.shade200
          ..style = PaintingStyle.fill;

        canvas.drawPath(path, placeholderPaint);

        // Add subtle border
        final borderPaint = Paint()
          ..color = Colors.grey.shade300
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

        canvas.drawPath(path, borderPaint);
      }
    }

    // Draw white center circle
    final whiteCenterPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final double whiteCenterRadius = radius * 0.48;
    canvas.drawCircle(center, whiteCenterRadius, whiteCenterPaint);

    // Add border around white center
    final centerBorderPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, whiteCenterRadius, centerBorderPaint);

    // Draw center icons if available
    for (int i = 0; i < items.length; i++) {
      if (i < centerIcons.length && centerIcons.isNotEmpty) {
        canvas.save();

        final startAngle = sweep * i + rotation;
        final iconRadius = radius * 0.75;
        const positionInSegment = 0.50;
        final iconAngle = startAngle + (sweep * positionInSegment);

        final iconX = center.dx + iconRadius * cos(iconAngle);
        final iconY = center.dy + iconRadius * sin(iconAngle);
        final iconOffset = Offset(iconX, iconY);

        final icon = centerIcons[i];

        final double iconSize = radius * 0.18;
        final double iconScale = iconSize / max(icon.width, icon.height);
        final double iconWidth = icon.width * iconScale;
        final double iconHeight = icon.height * iconScale;
        final double circleSize = max(iconWidth, iconHeight) * 1.4;

        // Draw circle background
        final circlePaint = Paint()
          ..color = const Color(0x57FFFFFF)
          ..style = PaintingStyle.fill;

        final circleBorderPaint = Paint()
          ..color = const Color(0x24E4E4E4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7;

        canvas.drawCircle(iconOffset, circleSize / 2, circlePaint);
        canvas.drawCircle(iconOffset, circleSize / 2, circleBorderPaint);

        // Draw icon
        canvas.drawImageRect(
          icon,
          Rect.fromLTWH(0, 0, icon.width.toDouble(), icon.height.toDouble()),
          Rect.fromLTWH(
            iconX - iconWidth / 2,
            iconY - iconHeight / 2,
            iconWidth,
            iconHeight,
          ),
          Paint(),
        );

        canvas.restore();
      }
    }

    // Draw outer circle border
    final outerBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(center, radius, outerBorderPaint);

    // Outer circle with inner shadow
    final outerInnerShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.24)
      ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 4.229)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;

    canvas.drawCircle(center, radius, outerInnerShadowPaint);
  }

  @override
  bool shouldRepaint(covariant RotatingWheelPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.segmentImages != segmentImages ||
        oldDelegate.centerIcons != centerIcons;
  }
}
