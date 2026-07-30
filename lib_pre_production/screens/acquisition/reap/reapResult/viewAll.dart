import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'ImageView.dart';
import 'MapView.dart';
import 'videoView.dart';
import 'virtualTourView.dart';

class ViewAll extends StatefulWidget {
  final int initialTabIndex;
  final LatLng? currentLocation;
  final PropertyDetailModel propertyDetail; // Changed to non-nullable

  const ViewAll({
    super.key,
    this.initialTabIndex = 0,
    this.currentLocation,
    required this.propertyDetail, // Marked as required
  });

  @override
  State<ViewAll> createState() => _ViewAllState();
}

class _ViewAllState extends State<ViewAll> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final height = isPortrait ? mediaQuery.size.height : mediaQuery.size.width;
    final width = isPortrait ? mediaQuery.size.width : mediaQuery.size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: _buildCloseButton(width),
        centerTitle: true,
        elevation: 0,
        bottom: _buildTabBar(width),
      ),
      body: _buildTabBarView(),
    );
  }

  Widget _buildCloseButton(double width) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.close, size: 20, color: AppColors.blackColor),
          SizedBox(width: width * 0.01),
          Text(
            'Close',
            style: TextStyle(
              fontSize: 13.sp,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w500,
              color: AppColors.blackColor,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildTabBar(double width) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: TabBar(
        controller: _tabController,
        indicator: const BoxDecoration(color: Colors.white),
        indicatorPadding: EdgeInsets.symmetric(horizontal: width * 0.02),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        labelPadding: EdgeInsets.symmetric(horizontal: width * 0.01),
        tabs: List.generate(4, (index) {
          final isSelected = _tabController.index == index;
          return Tab(
            child: Container(
              constraints: const BoxConstraints(minWidth: 100),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xffe5e5e5), width: 1),
                color: isSelected ? Colors.black : Colors.transparent,
              ),
              child: Center(
                child: Text(
                  ['Image', 'Video', 'Map', 'Virtual Tour'][index],
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    overflow: TextOverflow.ellipsis,
                    fontSize: 12.sp,
                    color: isSelected ? Colors.white : const Color(0xff272727),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        ImageView(propertyDetail: widget.propertyDetail),
        VideoView(propertyDetail: widget.propertyDetail),
        MapView(),
        VirtualTourView(propertyDetail: widget.propertyDetail),
      ],
    );
  }
}
