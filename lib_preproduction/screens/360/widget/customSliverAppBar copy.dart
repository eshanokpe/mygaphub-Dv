import 'package:GapHub/screens/360/wheel/360WheelScreen.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/customBottomSheet.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import 'category_dropdown.dart';

class CustomSliverAppBar extends StatefulWidget {
  final double expandedHeight;
  final String currency;
  final String appBarTitle;
  final dynamic amount;
  final String category;
  final String bottomSheetTitle;
  final String bottomSheetContent;
  final VoidCallback? onBackPressed;
  final bool isDropdownActive;
  final ValueChanged<bool>? onDropdownTap;
  final LinearGradient? gradient;
  final String? blurImagePath;
  final ScrollController? scrollController;

  const CustomSliverAppBar({
    super.key,
    this.expandedHeight = 250,
    required this.currency,
    required this.appBarTitle,
    required this.amount,
    required this.category,
    required this.bottomSheetTitle,
    required this.bottomSheetContent,
    this.onBackPressed,
    this.isDropdownActive = false,
    this.onDropdownTap,
    this.gradient,
    this.blurImagePath,
    this.scrollController,
  });

  @override
  State<CustomSliverAppBar> createState() => _CustomSliverAppBarState();
}

class _CustomSliverAppBarState extends State<CustomSliverAppBar> {
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController?.hasClients ?? false) {
      final scrollOffset = widget.scrollController!.offset;
      // Change to > 0 instead of > 50 to trigger immediately on scroll
      final shouldBeScrolled = scrollOffset > 0;

      if (shouldBeScrolled != _isScrolled) {
        setState(() {
          _isScrolled = shouldBeScrolled;
        });
      }
    }
  }

  Future<void> _showWheelBottomSheet(BuildContext context) async {
    print("Opening wheel bottom sheet with category: ${widget.category}");

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
                // Drag handle
                InkWell(
                  // behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.pop(context);
                  },
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
                // Close button
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: InkWell(
                    // behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.pop(context);
                    },
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
                  child: ThreesSixtyWheelScreen(
                    initialCategory: widget.category,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      // Reset state when bottom sheet is closed
      if (widget.onDropdownTap != null) {
        widget.onDropdownTap!(false);
      }
    });

    print("Bottom sheet closed");
  }

  @override
  Widget build(BuildContext context) {
    String wholeNumber = widget.amount.toStringAsFixed(0);
    String decimalPart = widget.amount.toStringAsFixed(2).split('.').last;

    return SliverAppBar(
      expandedHeight: widget.expandedHeight.h,
      surfaceTintColor: Colors.white,
      pinned: true,
      floating: false,
      snap: false,
      backgroundColor: Colors.white, // Always white when collapsed
      elevation: _isScrolled ? 4 : 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: _isScrolled || widget.isDropdownActive
              ? Colors.black
              : Colors.white,
        ),
        onPressed: widget.onBackPressed,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
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
                  return CustomBottomSheet(
                    title: widget.bottomSheetTitle,
                    content: widget.bottomSheetContent,
                  );
                },
              );
            },
            child: SvgPicture.asset(
              'assets/wheel_segments/info_thin.svg',
              color: _isScrolled || widget.isDropdownActive
                  ? Colors.black
                  : Colors.white,
              width: 24.w,
              height: 24.h,
            ),
          ),
        ),
      ],
      centerTitle: true,
      title: _isScrolled || widget.isDropdownActive
          ? Text(
              widget.appBarTitle,
              style: GoogleFonts.nunitoSans(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: EdgeInsets.zero,
        background: Stack(
          clipBehavior: Clip.none,
          children: [
            // White background that appears immediately on scroll or when dropdown is active
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: (_isScrolled || widget.isDropdownActive)
                  ? Colors.white
                  : Colors.transparent,
            ),

            // Original gradient background (only shows when not scrolled and dropdown not active)
            if (!widget.isDropdownActive && !_isScrolled)
              Container(decoration: BoxDecoration(gradient: widget.gradient!))
            else if (widget.isDropdownActive)
              Container(color: Colors.white),

            // Blur overlay image (only shows when not scrolled and dropdown not active)
            if (!widget.isDropdownActive &&
                !_isScrolled &&
                (widget.blurImagePath != null))
              Positioned.fill(
                child: Image.asset(widget.blurImagePath!, fit: BoxFit.cover),
              ),

            // Content (always visible)
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 106.h),

                /// Amount
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${widget.currency}$wholeNumber"
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              ),
                          style: GoogleFonts.nunitoSans(
                            fontSize: 36.sp,
                            color: widget.isDropdownActive
                                ? Colors.black
                                : (_isScrolled ? Colors.black : Colors.white),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(
                          text: ".$decimalPart",
                          style: GoogleFonts.nunitoSans(
                            fontSize: 24.sp,
                            color: widget.isDropdownActive
                                ? Colors.black
                                : (_isScrolled ? Colors.black : Colors.white),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                /// Dropdown
                CategoryDropdown(
                  selectedCategory: widget.category,
                  onTap: () {
                    if (widget.onDropdownTap != null) {
                      widget.onDropdownTap!(true);
                    }
                    _showWheelBottomSheet(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
