import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/screens/analytics/edits/credit.dart';
import 'package:GapHub/screens/analytics/edits/freedom.dart';
import 'package:GapHub/screens/analytics/edits/grand.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../edits/alpha.dart';
import '../edits/beta.dart';
import '../edits/debt.dart';
import '../edits/education.dart';

class ProgressListUI extends StatefulWidget {
  final List<int> realColors;
  final bool newUser;

  const ProgressListUI({
    super.key,
    required this.realColors,
    required this.newUser,
  });

  @override
  State<ProgressListUI> createState() => _ProgressListUIState();
}

class _ProgressListUIState extends State<ProgressListUI> {
  Analyticsinfo? analyticsinfo;
  bool isLoading = false;
  Timer? _requestTimer;

  @override
  void dispose() {
    _requestTimer?.cancel();
    super.dispose();
  }

  bool _shouldUseSectionGradient(Map<String, dynamic>? sectionData) {
    if (sectionData == null) return false;
    final mainValue = sectionData['main']?.toString() ?? '';
    return mainValue == '1';
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    final geere = context.watch<Providers>().sevengeemodel.steps;
    final labels = [
      "Grand",
      "Freedom",
      "Education",
      "Debt",
      "Credit",
      "Beta",
      "Alpha",
    ];
    final subLabels = [
      "A measure of your benevolence",
      "A measure of your progress on your path to financial freedom",
      "A measure of how much you have saved up for your kids university education",
      "A measure of what you owe on your primary place of residence",
      "Loans, credit cards, HPIs, all unsecured debt",
      "A measure of your house purchase savings",
      "A measure of your asset growth fund (AGF)",
    ];
    final discripLabels = [
      "Embrace the spirit of giving! You can easily track your charitable contributions as a percentage of your personal or family expenses.",
      "The Path to Freedom refers to the ratio of your average monthly income generated from your asset portfolio to your average monthly expenses, expressed as a percentage.",
      "This approach not only helps your children steer clear of student loan debt but also actively monitors your savings for their university education.",
      "This will allow you to track the progress of your mortgage repayment for your primary residence effectively.",
      "This approach will allow you to track your progress as you methodically eliminate all your unsecured debts, empowering you to secure a debt-free future.",
      "If you haven't purchased your own residential property yet, consider this as an opportunity to save money for your dream home.",
      "This is the measure of your asset growth Fund, specifically allocated to cover your essential living expenses in the event of losing your primary source of income.",
    ];
    final colors = [
      Colors.red,
      Colors.redAccent,
      Colors.orange,
      Colors.orange,
      Colors.green,
      Colors.green,
      Colors.blue,
    ];
    // Get analyticsinfo from provider if available
    final analyticsInfoFromProvider = context.watch<Providers>().analyticsinfo;

    // Map each label to its corresponding section data
    final Map<String, Map<String, dynamic>?> sectionDataMap = {
      "Grand": analyticsInfoFromProvider.grand,
      "Freedom": analyticsInfoFromProvider.freedom,
      "Education": analyticsInfoFromProvider.education,
      "Debt": analyticsInfoFromProvider.dept,
      "Credit": analyticsInfoFromProvider.credit,
      "Beta": analyticsInfoFromProvider.beta,
      "Alpha": analyticsInfoFromProvider.alpha,
    };

    return ListView.builder(
      shrinkWrap: true,
      itemCount: geere.length,
      itemBuilder: (context, index) {
        final label = labels[index];
        final sectionData = sectionDataMap[label];
        final isValidated = _shouldUseSectionGradient(sectionData);
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Row(
            children: [
              // Label
              GestureDetector(
                onTap: () {
                  _showPickerEdit(
                    context,
                    labels[index],
                    subLabels[index],
                    discripLabels[index],
                  );
                },
                child: SizedBox(
                  width: width * .18,
                  child: Text(
                    labels[index],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ),

              // Progress Bar
              Expanded(
                child: GestureDetector(
                  onTap: () => _handleProgressBarTap(
                    context,
                    label,
                    widget.realColors[index],
                  ),
                  child: _buildProgressBar(
                    geere[index],
                    colors[index],
                    width,
                    isValidated,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(
    int progress,
    Color color,
    double width,
    bool isValidated,
  ) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Container(
          height: 23.h,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        progress < 0
            ? LayoutBuilder(
                builder: (context, constraints) {
                  double minWidth = 35;
                  double percentageWidth =
                      constraints.maxWidth * (progress / 100);
                  Color endColor;
                  Color startColor;

                  if (progress >= 1 && progress <= 25) {
                    startColor = const Color(0xffFF0001);
                    endColor = const Color(0xffCE0001);
                  } else if (progress >= 26 && progress <= 50) {
                    startColor = const Color(0xffF6AE39);
                    endColor = const Color(0xffFF7A00);
                  } else if (progress >= 51 && progress <= 75) {
                    startColor = const Color(0xff005E32);
                    endColor = const Color(0xff17B26A);
                  } else if (progress >= 76 && progress <= 100) {
                    startColor = const Color(0xff005E77);
                    endColor = const Color(0xff002E77);
                  } else {
                    startColor = Colors.grey;
                    endColor = Colors.grey.withOpacity(0.9);
                  }
                  return Row(
                    children: [
                      Container(
                        width: max(percentageWidth, minWidth),
                        height: 23.h,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(20),
                          ),
                          gradient: LinearGradient(
                            colors: isValidated
                                ? [startColor, endColor]
                                : [
                                    const Color(0xff444444),
                                    const Color(0xff444444).withOpacity(0.9),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        alignment: Alignment.center,
                      ),
                      SizedBox(width: width * .02),
                      Text(
                        "$progress%",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  );
                },
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  double minWidth = 35;
                  double percentageWidth =
                      constraints.maxWidth * (progress / 100);
                  Color endColor;
                  Color startColor;

                  if (progress >= 1 && progress <= 25) {
                    startColor = const Color(0xffFF0001);
                    endColor = const Color(0xffCE0001);
                  } else if (progress >= 26 && progress <= 50) {
                    startColor = const Color(0xffF6AE39);
                    endColor = const Color(0xffFF7A00);
                  } else if (progress >= 51 && progress <= 75) {
                    startColor = const Color(0xff005E32);
                    endColor = const Color(0xff17B26A);
                  } else if (progress >= 76 && progress <= 100) {
                    startColor = const Color(0xff005E77);
                    endColor = const Color(0xff002E77);
                  } else {
                    startColor = Colors.grey;
                    endColor = Colors.grey.withOpacity(0.9);
                  }
                  return Container(
                    width: max(percentageWidth, minWidth),
                    height: 23.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isValidated
                            ? [startColor, endColor]
                            : [
                                const Color(0xff444444),
                                const Color(0xff444444).withOpacity(0.9),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "$progress%",
                            style: TextStyle(
                              color: progress <= 1
                                  ? Colors.black
                                  : Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        Positioned(
          right: 0,
          child: Icon(
            Icons.chevron_right,
            color: progress == 100 ? Colors.white : Colors.grey,
          ),
        ),
      ],
    );
  }

  Future<void> _handleProgressBarTap(
    BuildContext context,
    String label,
    int color,
  ) async {
    void dismissLoadingDialog() {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    // Cancel any previous timer
    _requestTimer?.cancel();

    _requestTimer = Timer(const Duration(seconds: 20), () {
      if (mounted) {
        dismissLoadingDialog();
        dialogBox.information(context, 'Status', 'Service timed out');
      }
    });

    if (mounted) {
      dialogBox.waiting(context, 'Loading');
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/app/seveng/edit'),
        headers: {"Authorization": 'Bearer $token'},
      );

      if (!mounted) {
        _requestTimer?.cancel();
        return;
      }

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final analyticsData = body["data"];
        var analyticsinfo = Analyticsinfo.fromJson(analyticsData);
        context.read<Providers>().setAnalyticsInfo(analyticsinfo);

        if (analyticsData != null && analyticsData is Map<String, dynamic>) {
          setState(() {
            analyticsinfo = Analyticsinfo.fromJson(analyticsData);
            context.read<Providers>().setAnalyticsInfo(analyticsinfo);
            isLoading = false;
          });

          context.read<Providers>().setAnalyticsInfo(analyticsinfo!);

          _requestTimer?.cancel();

          if (mounted) {
            dismissLoadingDialog();

            // Determine if it's a new user based on the specific section's main value
            final screens = {
              'Grand': () {
                final mainValue =
                    analyticsinfo.grand?['main']?.toString() ?? '';
                final newUser = mainValue == '1';
                print("mainValueGrand:$mainValue");
                print("newUserGrand:$newUser");
                return Grand(
                  grandInfo: analyticsinfo,
                  contains: newUser,
                  newUser: newUser,
                );
              },
              'Freedom': () {
                final mainValue =
                    analyticsinfo.freedom?['main']?.toString() ?? '';
                final newUser = mainValue == '1';
                print("mainValueFreedom:$mainValue");
                print("newUserFreedom:$newUser");
                return Freedom(freedomInfo: analyticsinfo, newUser: newUser);
              },
              'Education': () {
                final mainValue =
                    analyticsinfo.education?['main']?.toString() ?? '';
                final newUser = mainValue == '1';
                print("mainValueEducation:$mainValue");
                print("newUserEducation:$newUser");
                return Education(
                  educationInfo: analyticsinfo,
                  newUser: newUser,
                  contains: newUser,
                );
              },
              'Debt': () {
                final mainValue = analyticsinfo.dept?['main']?.toString() ?? '';
                final newUser = mainValue == '1';
                print("newUserDebt:$newUser");
                return Debt(
                  debtInfo: analyticsinfo,
                  newUser: newUser,
                  contains: newUser,
                );
              },
              'Credit': () {
                final mainValue =
                    analyticsinfo.credit?['main']?.toString() ?? '';
                final newUser = mainValue == '1';
                print("newUserCredit:$newUser");
                return Credit(
                  creditInfo: analyticsinfo,
                  newUser: newUser,
                  contains: newUser,
                );
              },
              'Beta': () {
                final mainValue = analyticsinfo.beta?['main']?.toString() ?? '';
                final newUser = mainValue == '1';
                print("newUserBeta:$newUser");
                return Beta(
                  betaInfo: analyticsinfo,
                  newUser: newUser,
                  contains: newUser,
                );
              },
              'Alpha': () {
                final mainValue =
                    analyticsinfo.alpha?['main']?.toString() ?? '';
                final newUser = mainValue == '1';
                print("newUserAlpha:$newUser");
                return Alpha(
                  alphaInfo: analyticsinfo,
                  newUser: newUser,
                  contains: newUser,
                );
              },
            };

            if (screens.containsKey(label)) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => screens[label]!()),
              );
            }
          }
        } else {
          if (mounted) {
            dismissLoadingDialog();
            dialogBox.information(context, 'Error', 'Invalid data format');
          }
        }
      } else {
        if (mounted) {
          dismissLoadingDialog();
          dialogBox.information(
            context,
            'Error',
            'Failed to load data: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        dismissLoadingDialog();
        dialogBox.information(
          context,
          'Connection Issue',
          'Your internet connection appears to be unstable. Please check your network and try again.',
        );
      }
      _requestTimer?.cancel();
    }
  }

  void _showPickerEdit(
    BuildContext context,
    String title,
    String subtitle,
    String content,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Modal(title: title, subtitle: subtitle, content: content);
      },
    );
  }
}

class Modal extends StatelessWidget {
  final String title;
  final String subtitle;
  final String content;

  const Modal({
    required this.title,
    required this.subtitle,
    required this.content,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: width * .04),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * .02),
            Center(
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Divider(
                  color: const Color(0xffcdcdcd),
                  height: 14.h,
                  thickness: 5,
                  indent: width * .38,
                  endIndent: width * .38,
                ),
              ),
            ),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20.sp),
            ),
            Text(
              subtitle,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
            ),
            SizedBox(height: height * .01),
            Text(
              content,
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14.sp),
            ),
            SizedBox(height: height * .02),
            CustomButton(
              text: 'Close',
              fontSize: 16.sp,
              isLoading: false,
              borderRadius: 30,
              borderColor: const Color(0xffC8CECC),
              onPressed: () => Navigator.pop(context),
              color: Colors.white,
              textColor: Colors.black,
            ),
            SizedBox(height: height * .05),
          ],
        ),
      ),
    );
  }
}
