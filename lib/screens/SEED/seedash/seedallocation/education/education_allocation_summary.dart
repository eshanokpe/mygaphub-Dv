import 'package:GapHub/models/savingAllocationserver.dart';
import 'package:GapHub/utils/extensions.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proste_bezier_curve/proste_bezier_curve.dart';
import 'package:provider/provider.dart';
import 'education_allocation.dart';
import 'vew_detaila_education_allocation.dart';

class EducationAllocationSummary extends StatefulWidget {
  final List<SavingAllserver> data;

  const EducationAllocationSummary({super.key, required this.data});

  @override
  State<EducationAllocationSummary> createState() =>
      _EducationAllocationSummaryState();
}

class _EducationAllocationSummaryState
    extends State<EducationAllocationSummary> {
  // Constants for better maintainability
  static const Color _primaryColor = Color(0xffE6C069);
  static const Color _backgroundColor = Colors.white;
  static const double _cardBorderRadius = 20;
  static const double _listItemHeightRatio = 0.12;
  static const double _topSpacingRatio = 0.03;
  static const double _cardWidthRatio = 0.88;
  static const double _cardHeightRatio = 0.20;

  // Cached values to avoid recalculation
  late double _screenWidth;
  late double _screenHeight;
  late Orientation _orientation;
  late String _currency;

  @override
  Widget build(BuildContext context) {
    // Cache dimensions and providers
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    _orientation = MediaQuery.of(context).orientation;
    _currency = context.watch<Providers>().snapshotmodel.currency;

    final height = _getResponsiveHeight();
    final width = _getResponsiveWidth();

    return Scaffold(
      backgroundColor: Colors.blue.withOpacity(.05),
      appBar: _buildAppBar(),
      body: _buildBody(height, width),
    );
  }

  // Helper methods for responsive dimensions
  double _getResponsiveHeight() {
    return _orientation == Orientation.portrait ? _screenHeight : _screenWidth;
  }

  double _getResponsiveWidth() {
    return _orientation == Orientation.portrait ? _screenWidth : _screenHeight;
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'SEED',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: context.width(.045),
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.black),
      ),
    );
  }

  Widget _buildBody(double height, double width) {
    return Container(
      color: Colors.blue.withOpacity(.05),
      height: height,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: height * _topSpacingRatio),
            _buildHeaderCard(width, height),
            SizedBox(height: height * 0.01),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(double width, double height) {
    return Stack(
      children: [
        _buildCardBackground(width, height),
        _buildCardTitle(width, height),
        _buildCardCurve(height, width),
        _buildAllocationList(width, height),
      ],
    );
  }

  Widget _buildCardBackground(double width, double height) {
    return Center(
      child: Container(
        width: width * _cardWidthRatio,
        height: height * _cardHeightRatio,
        decoration: BoxDecoration(
          color: _primaryColor,
          borderRadius: BorderRadius.circular(_cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 6,
              blurRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTitle(double width, double height) {
    return Positioned(
      top: height * 0.04,
      left: width * 0.04,
      right: width * 0.04,
      child: Center(
        child: SizedBox(
          width: width * _cardWidthRatio,
          height: height * 0.10,
          child: Padding(
            padding: EdgeInsets.only(top: height * 0.00, right: width * 0.10),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: [
                  _buildTitleRow('Education Allocation'),
                  _buildTitleRow('Summary'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: _screenWidth * 0.060,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardCurve(double height, double width) {
    return Padding(
      padding: EdgeInsets.only(top: width * 0.27),
      child: Align(
        alignment: Alignment.topCenter,
        child: ClipPath(
          clipper: ProsteBezierCurve(
            position: ClipPosition.top,
            list: [
              BezierCurveSection(
                start: Offset(_screenWidth, 0),
                top: Offset(_screenWidth / 2, 30),
                end: const Offset(0, 0),
              ),
            ],
          ),
          child: Container(color: Colors.white, height: height),
        ),
      ),
    );
  }

  Widget _buildAllocationList(double width, double height) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: height * 0.28),
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.05,
              vertical: height * 0.0,
            ),
            child: _buildListView(width, height),
          ),
        ),
        _buildAddMoreButton(width, height),
      ],
    );
  }

  Widget _buildListView(double width, double height) {
    if (widget.data.isEmpty) {
      return _buildEmptyState(width, height);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemCount: widget.data.length,
      itemBuilder: (context, index) {
        return _buildAllocationItem(widget.data[index], index, width, height);
      },
    );
  }

  Widget _buildEmptyState(double width, double height) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: height * 0.1),
        child: Text(
          'No allocations found',
          style: TextStyle(color: Colors.grey, fontSize: width * 0.04),
        ),
      ),
    );
  }

  Widget _buildAllocationItem(
    SavingAllserver item,
    int index,
    double width,
    double height,
  ) {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: Container(
        height: height * _listItemHeightRatio,
        padding: EdgeInsets.symmetric(horizontal: width * 0.02, vertical: 0.h),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color.fromARGB(255, 196, 196, 196)),
          ),
        ),
        child: ListTile(
          horizontalTitleGap: -10.0,
          contentPadding: EdgeInsets.only(
            top: 0.h,
            right: width * 0.0,
            left: width * 0.0,
          ),
          onTap: () => _navigateToDetail(index),
          isThreeLine: true,
          leading: _buildLeadingIcon(width),
          title: _buildTitle(item, width),
          trailing: _buildAmount(item, width),
          subtitle: _buildSubtitle(item, width),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(double width) {
    return Container(
      height: width * 0.04,
      width: width * 0.04,
      margin: EdgeInsets.only(top: 5, right: width * 0.08),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: _primaryColor,
            blurRadius: 0,
            offset: Offset(width * 0.006, width * 0.005),
          ),
        ],
        borderRadius: BorderRadius.circular(width * 0.005),
        border: Border.all(color: _primaryColor),
      ),
    );
  }

  Widget _buildTitle(SavingAllserver item, double width) {
    return Container(
      child: Text(
        item.label ?? '',
        style: TextStyle(
          color: _primaryColor,
          fontSize: width * 0.050,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAmount(SavingAllserver item, double width) {
    return Text(
      _formatCurrency(item.amount),
      style: TextStyle(
        color: Colors.black,
        fontSize: width * 0.040,
        fontWeight: FontWeight.w300,
      ),
    );
  }

  Widget _buildSubtitle(SavingAllserver item, double width) {
    final balance = item.summary.totalLeft ?? 0;
    return Text(
      "$_currency ${balance.toStringAsFixed(2)} Balance",
      style: TextStyle(
        color: Colors.black,
        fontSize: width * 0.040,
        fontWeight: FontWeight.w300,
      ),
    );
  }

  Widget _buildAddMoreButton(double width, double height) {
    return Padding(
      padding: EdgeInsets.only(
        top: 10.h,
        right: width * 0.05,
        left: width * 0.05,
      ),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color.fromARGB(255, 196, 196, 196)),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _navigateToAddAllocation,
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: OverflowBar(
                overflowAlignment: OverflowBarAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Add more",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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
    );
  }

  // Navigation methods
  void _navigateToDetail(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ViewDetailEduAllocation(item: widget.data, index: index),
      ),
    );
  }

  void _navigateToAddAllocation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EducationAllocation()),
    );
  }

  // Utility methods
  String _formatCurrency(num? amount) {
    final value = amount ?? 0;
    final formatted = value.toStringAsFixed(2);
    return '$_currency$formatted'.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

// Extracted custom clippers for better reusability
class CustomSelfClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final section1 = BezierCurveSection(
      start: const Offset(0, 30),
      top: const Offset(10, 45),
      end: const Offset(0, 60),
    );

    final section2 = BezierCurveSection(
      start: Offset(size.width, size.height - 90),
      top: Offset(size.width - 10, size.height - 105),
      end: Offset(size.width, size.height - 120),
    );

    final dot1 = ProsteBezierCurve.calcCurveDots(section1);
    final dot2 = ProsteBezierCurve.calcCurveDots(section2);

    final path = Path()
      ..lineTo(0, 0)
      ..lineTo(0, 30)
      ..quadraticBezierTo(dot1.x1, dot1.y1, dot1.x2, dot1.y2)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, size.height - 90)
      ..quadraticBezierTo(dot2.x1, dot2.y1, dot2.x2, dot2.y2)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class CustomSelfClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final section1 = BezierCurveSection(
      start: Offset(0, size.height),
      top: Offset(30, size.height - 50),
      end: Offset(80, size.height - 70),
    );

    final section2 = BezierCurveSection(
      start: Offset(size.width - 100, size.height - 70),
      top: Offset(size.width - 30, size.height - 95),
      end: Offset(size.width, size.height - 160),
    );

    final dot1 = ProsteBezierCurve.calcCurveDots(section1);
    final dot2 = ProsteBezierCurve.calcCurveDots(section2);

    final path = Path()
      ..lineTo(0, 0)
      ..lineTo(0, size.height)
      ..quadraticBezierTo(dot1.x1, dot1.y1, dot1.x2, dot1.y2)
      ..lineTo(size.width - 100, size.height - 70)
      ..quadraticBezierTo(dot2.x1, dot2.y1, dot2.x2, dot2.y2)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
