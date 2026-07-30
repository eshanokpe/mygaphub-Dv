import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'analytic_header.dart';

class Kpistab extends StatefulWidget {
  final List<Widget> tabPages;
  final double width;
  final double height;
  final bool contains;
  final bool fromSave;
  const Kpistab({
    super.key,
    required this.tabPages,
    required this.width,
    required this.height,
    required this.contains,
    this.fromSave = false,
  });
  @override
  _KpistabState createState() => _KpistabState();
}

class _KpistabState extends State<Kpistab> with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: widget.fromSave
          ? AnalyticHeader(newUserAnalytics: widget.contains)
          : null,
      bottomNavigationBar: widget.fromSave ? const BottomNav(1) : null,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: widget.height * .02),
            Visibility(
              visible: widget.contains,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: height * .02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Analytics',
                          style: TextStyle(
                            fontSize: widget.width * .05,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: widget.height * .01),
                    Row(
                      children: [
                        Text(
                          'These are your ',
                          style: TextStyle(
                            fontSize: widget.width * .04,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          'Key Performance Indicators',
                          style: TextStyle(
                            fontSize: widget.width * .04,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: widget.height * .02),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: !widget.contains,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: height * .02),
                child: Column(
                  children: [
                    Text(
                      'Your multiple-choice answers have provided an assumption. ',
                      style: TextStyle(
                        fontSize: widget.width * .035,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: widget.height * .01),
                    Text(
                      'Click (or tap) any of the following bars to validate these assumptions',
                      style: TextStyle(
                        fontSize: widget.width * .035,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: !widget.contains,
              child: SizedBox(height: widget.height * .02),
            ),
            // Text('${widget.contains}'),
            SizedBox(
              width: widget.width,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                padding: EdgeInsets.zero,
                tabAlignment: TabAlignment.start,
                tabs: [
                  Tab(
                    child: Text(
                      '7G KPI',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Bespoke KPI',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: const Color(0xff4F5B6D),
                indicator: UnderlineTabIndicator(
                  borderSide: const BorderSide(
                    width: 3.0,
                    color: Color(0xff4F5B6D),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  insets: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
                ),
                indicatorWeight: 3.0,
                indicatorPadding: EdgeInsets.only(bottom: 2.h),
                labelColor: const Color(0xff272727),
                unselectedLabelColor: const Color(0xff6B7280),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.normal,
                ),
                physics: const BouncingScrollPhysics(),
                dividerColor: Colors.transparent,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: widget.tabPages,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
