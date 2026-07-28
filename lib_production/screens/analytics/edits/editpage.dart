import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/analytics/analytics.dart';
import 'package:GapHub/screens/analytics/edits/alpha.dart';
import 'package:GapHub/screens/analytics/edits/credit.dart';
import 'package:GapHub/screens/analytics/kpistab.dart';
import 'package:GapHub/screens/analytics/tab/bespoke_KPI.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../widgets/avatarImage.dart';
import 'beta.dart';
import 'debt.dart';
import 'education.dart';
import 'freedom.dart';
import 'grand.dart';

class Editpage extends StatefulWidget {
  final Analyticsinfo analyticsinfo;
  final bool newUserAnalytics;
  final List<int> realColors;
  final bool fromSave;
  const Editpage(
    this.realColors,
    this.analyticsinfo,
    this.newUserAnalytics, {
    super.key,
    this.fromSave = false,
  });
  @override
  _EditpageState createState() => _EditpageState();
}

class _EditpageState extends State<Editpage> {
  static List<String> gees = [
    'Grand',
    'Freedom',
    'Education',
    'Debt',
    'Credit',
    'Beta',
    'Alpha',
  ];
  @override
  Widget build(BuildContext context) {
    var geere = context.watch<Providers>().sevengeemodel.steps;
    List<String> sevenGees = [];
    for (var a in geere) {
      sevenGees.add(a.toString());
    }
    return Scaffold(
      bottomNavigationBar: const BottomNav(1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: true,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
        ),
        actions: const [AvatarImage()],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '7G KPI',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Select any KPI to view or modify it',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),
            Card(
              elevation: 0,
              color: AppColors.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: const BorderSide(color: Color(0xffD8D8D8), width: 0.5),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemCount: gees.length,
                itemBuilder: (context, index) => Column(
                  children: [
                    ListTile(
                      onTap: () {
                        switch (gees[index]) {
                          case 'Alpha':
                            final mainValue =
                                widget.analyticsinfo.alpha?['main']
                                    ?.toString() ??
                                '';
                            final newUser = mainValue == '1';
                            print("newUserAlpha:$newUser");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Alpha(
                                  newUser: newUser,
                                  contains: newUser,
                                  alphaInfo: widget.analyticsinfo,
                                ),
                              ),
                            );

                            break;
                          case 'Beta':
                            final mainValue =
                                widget.analyticsinfo.beta?['main']
                                    ?.toString() ??
                                '';
                            final newUser = mainValue == '1';
                            print("newUserBeta:$newUser");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Beta(
                                  newUser: newUser,
                                  contains: newUser,
                                  betaInfo: widget.analyticsinfo,
                                ),
                              ),
                            );

                            break;
                          case 'Credit':
                            final mainValue =
                                widget.analyticsinfo.credit?['main']
                                    ?.toString() ??
                                '';
                            final newUser = mainValue == '1';
                            print("newUserCredit:$newUser");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Credit(
                                  newUser: newUser,
                                  contains: newUser,
                                  creditInfo: widget.analyticsinfo,
                                ),
                              ),
                            );

                            break;
                          case 'Debt':
                            final mainValue =
                                widget.analyticsinfo.dept?['main']
                                    ?.toString() ??
                                '';
                            final newUser = mainValue == '1';
                            print("newUserDebt:$newUser");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Debt(
                                  newUser: newUser,
                                  contains: newUser,
                                  debtInfo: widget.analyticsinfo,
                                ),
                              ),
                            );

                            break;
                          case 'Education':
                            final mainValue =
                                widget.analyticsinfo.education?['main']
                                    ?.toString() ??
                                '';
                            final newUser = mainValue == '1';
                            print("mainValueEducation:$mainValue");
                            print("newUserEducation:$newUser");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Education(
                                  newUser: newUser,
                                  contains: newUser,
                                  educationInfo: widget.analyticsinfo,
                                ),
                              ),
                            );

                            break;
                          case 'Freedom':
                            final mainValue =
                                widget.analyticsinfo.freedom?['main']
                                    ?.toString() ??
                                '';
                            final newUser = mainValue == '1';
                            print("mainValueFreedom:$mainValue");
                            print("newUserFreedom:$newUser");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Freedom(
                                  newUser: newUser,
                                  freedomInfo: widget.analyticsinfo,
                                ),
                              ),
                            );

                            break;
                          case 'Grand':
                            final mainValue =
                                widget.analyticsinfo.grand?['main']
                                    ?.toString() ??
                                '';
                            final newUser = mainValue == '1';
                            print("mainValueGrand:$mainValue");
                            print("newUserGrand:$newUser");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Grand(
                                  newUser: newUser,
                                  contains: newUser,
                                  grandInfo: widget.analyticsinfo,
                                ),
                              ),
                            );

                            break;
                          default:
                        }
                      },
                      trailing: Image.asset(
                        'assets/images/chevron_right.png',
                        height: 8.h,
                        width: 6.w,
                      ),
                      title: Text(
                        gees[index],
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    // Add a divider if it's not the last item
                    if (index < gees.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Color(0xffe6e6e6),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32.h),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                ),
                onPressed: () {
                  if (widget.fromSave) {
                    final height = MediaQuery.of(context).size.height;
                    final width = MediaQuery.of(context).size.width;

                    double alpha = double.parse(sevenGees[6]);
                    double beta = double.parse(sevenGees[5]);
                    double credit = double.parse(sevenGees[4]);
                    double debt = double.parse(sevenGees[3]);
                    double education = double.parse(sevenGees[2]);
                    double freedom = double.parse(sevenGees[1]);
                    double grand = double.parse(sevenGees[0]);

                    final average =
                        (alpha +
                            beta +
                            credit +
                            debt +
                            education +
                            freedom +
                            grand) /
                        7;

                    // Create the tab pages
                    final tabPages = <Widget>[
                      Analytics(
                        key: const PageStorageKey('analyticsPage'),
                        height: height,
                        newUserAnalytics: widget.newUserAnalytics,
                        average: average,
                        realColors: widget.realColors,
                        seriesData:
                            const [], // You may need to pass your series data here
                        width: width,
                      ),
                      BespokeKPI(key: const PageStorageKey('bespokePage')),
                    ];

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Kpistab(
                          tabPages: tabPages,
                          height: height,
                          width: width,
                          contains: widget.newUserAnalytics,
                          fromSave: widget.fromSave,
                        ),
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  padding: EdgeInsets.zero,
                  height: 44.h,
                  width: 100.w,
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/view_chart.png',
                          height: 16.h,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'View Chart',
                          style: TextStyle(
                            color: const Color(0xfff3f3f4),
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}
