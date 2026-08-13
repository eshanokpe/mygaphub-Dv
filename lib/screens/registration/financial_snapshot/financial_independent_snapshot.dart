import 'package:GapHub/provider/acquisiProvider.dart';
import 'package:GapHub/screens/registration/financial_health/prequestions.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/customBottomSheet.dart';
import 'package:GapHub/widgets/custom_appbar_logo.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/widgets/ficard.dart';
import 'package:GapHub/widgets/ficard2.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'financial_independent_timelline.dart';

class FinancialIndependentSnapshot extends StatefulWidget {
  final bool login;
  // final Calculatormodel parameters;
  const FinancialIndependentSnapshot(this.login, {super.key});

  @override
  State<FinancialIndependentSnapshot> createState() =>
      _FinancialIndependentSnapshotState();
}

class _FinancialIndependentSnapshotState
    extends State<FinancialIndependentSnapshot> {
  double total = 0;
  double currentPer = 0;
  double timePer = 0;
  double time = 0;
  double current = 0;

  void _fetchBudgetData() {
    Provider.of<AcquisiProvider>(context, listen: false).getBudget();
  }

  @override
  void initState() {
    super.initState();
    _fetchBudgetData();
    print('current122:$current');
    // Parse parameters safely
  }

  @override
  Widget build(BuildContext context) {
    final calculatorModel = Provider.of<AcquisiProvider>(context);
    print("1savings:${calculatorModel.savings}");
    print("1education:${calculatorModel.education}");
    print("1mortgage:${calculatorModel.mortgage}");
    print("1mobility:${calculatorModel.mobility}");
    print("1expenses:${calculatorModel.expenses}");
    print("1utility:${calculatorModel.utility}");
    print("1debtRepay:${calculatorModel.debtRepay}");
    print("1charity:${calculatorModel.charity}");
    print("1extraSave:${calculatorModel.rainyDays}");
    print("1otherIncome:${calculatorModel.otherWages}");
    var a = double.tryParse(calculatorModel.savings) ?? 0;
    var b = double.tryParse(calculatorModel.education) ?? 0;
    var c = double.tryParse(calculatorModel.mortgage) ?? 0;
    var d = double.tryParse(calculatorModel.mobility) ?? 0;
    var e = double.tryParse(calculatorModel.expenses) ?? 0;
    var f = double.tryParse(calculatorModel.utility) ?? 0;
    var g = double.tryParse(calculatorModel.debtRepay) ?? 0;
    var h = double.tryParse(calculatorModel.charity) ?? 0;
    var rainy = double.tryParse(calculatorModel.rainyDays) ?? 0;
    var other = double.tryParse(calculatorModel.otherWages) ?? 0;

    // Calculate total
    total = a + b + c + d + e + f + g + h;

    // Prevent division by zero and handle Infinity/NaN
    if (total != 0) {
      time = (rainy / total) * 30;
      current = (other / total) * 100;
    } else {
      time = 0;
      current = 0;
    } 

    // Calculate percentages safely
    timePer = total != 0 ? time / 360 : 0;
    currentPer = total != 0 ? current / 100 : 0;

    // Ensure no NaN or Infinity results
    if (timePer.isNaN || timePer.isInfinite) {
      timePer = 0;
    }
    if (currentPer.isNaN || currentPer.isInfinite) {
      currentPer = 0;
    }

    DialogBox dialogBox = DialogBox();

    pop() {
      SystemNavigator.pop();
    }

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    void popTwice() {
      var popCount = 0;
      Navigator.of(context).popUntil((route) {
        if (route.isFirst || popCount >= 2) {
          return true;
        }

        popCount++;
        return false;
      });
    }

    return WillPopScope(
      onWillPop: () async {
        popTwice();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBarLogo(
          title: '',
          onBackPressed: popTwice,
          actionIconPath: 'assets/logo.png',
          onActionPressed: () {},
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.login
                  ? FiCard(width: width, height: height, yes: false)
                  : FiCard2(
                      width: width,
                      height: height,
                      // calculatormodel: calculatorModel ?? 0.0,
                    ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.06),

              current >= 100 || time >= 360
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/icons/infor.png', width: 30),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: CustomButton(
                              borderRadius: 30,
                              text: 'Continue',
                              fontSize: 16,
                              icon: Icons.arrow_forward_ios,
                              iconColor: AppColors.primaryColor,
                              borderColor: Colors.white,
                              onPressed: () async {
                                {
                                  dialogBox.waiting(context, 'Loading');
                                  try {
                                    Map<String, dynamic> body = {
                                      "currency":
                                          calculatorModel.selectedCurrency,
                                      "periodic_savings":
                                          calculatorModel.savings,
                                      "education": calculatorModel.education,
                                      "mortgage": calculatorModel.mortgage,
                                      "mobility": calculatorModel.mobility,
                                      "expenses": calculatorModel.expenses,
                                      "utility": calculatorModel.utility,
                                      "dept_repay": calculatorModel.debtRepay,
                                      "charity": calculatorModel.charity,
                                      "other_income":
                                          calculatorModel.otherWages,
                                      "extra_save": calculatorModel.rainyDays,
                                      "roce": '0',
                                      "investment": '0',
                                    };

                                    var url = Uri.parse(
                                      "$baseUrl/app/calculator",
                                    );
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    var token = prefs.getString('tokenDB');
                                    final response = await http.post(
                                      url,
                                      body: body,
                                      headers: {
                                        "Authorization": 'Bearer $token',
                                        "Accept": "application/json",
                                        "Content-Type":
                                            "application/x-www-form-urlencoded",
                                      },
                                      encoding: Encoding.getByName("utf-8"),
                                    );

                                    if (response.statusCode == 200) {
                                      Navigator.pop(context);
                                      navigateWithSlideTransition(
                                        context: context,
                                        destinationScreen: const Prequestions(),
                                        transitionDuration: const Duration(
                                          milliseconds: 200,
                                        ), // Optional: Adjust transition duration
                                      );
                                    } else {
                                      Navigator.pop(context);
                                      dialogBox.information(
                                        context,
                                        'Status',
                                        'Network or Server Error',
                                      );
                                    }
                                  } catch (e) {
                                    Navigator.pop(context);
                                    dialogBox.information(
                                      context,
                                      'Status',
                                      e.toString(),
                                    );
                                  }
                                }
                              },
                              color: const Color.fromARGB(255, 229, 229, 229),
                              textColor: AppColors.blackColor,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
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
                                  title: 'Improve your Status',
                                  content:
                                      'For you to achieve financial independence, you may need to improve your result by acquiring some assets that will generate income other than your monthly salary which will cover your monthly financial commitments',
                                );
                              },
                            );
                          },
                          child: Image.asset(
                            'assets/icons/infor.png',
                            width: 30,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: CustomButton(
                              text: 'Improve Status',
                              borderRadius: 30,
                              fontSize: 16,
                              icon: Icons.arrow_forward_ios,
                              iconColor: AppColors.primaryColor,
                              borderColor: Colors.white,
                              onPressed: () {
                                context.read<Providers>().setTotMonthly(total);
 
                                navigateWithSlideTransition(
                                  context: context,
                                  destinationScreen:
                                      FinancialIndependentTimeline(),
                                  transitionDuration: const Duration(
                                    milliseconds: 200,
                                  ), // Optional: Adjust transition duration
                                );
                              },
                              color: const Color.fromARGB(255, 229, 229, 229),
                              textColor: AppColors.blackColor,
                            ),
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),
            ],
          ),
        ),
      ),
    );
  }
}
