import 'dart:async';
import 'dart:convert';
import 'package:GapHub/screens/360/accounts/mortgage/mortgageitem.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:dio/dio.dart';
import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/models/sevengeemodel.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/strings.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/screens/registration/costoflivingcalc.dart';
import 'package:GapHub/screens/analytics/navigation_manager.dart';

class Debt extends StatefulWidget {
  final Analyticsinfo debtInfo;
  final bool newUser;
  final bool contains;
  final bool fromSave;

  const Debt({
    super.key,
    required this.debtInfo,
    required this.newUser,
    required this.contains,
    this.fromSave = false,
  });

  @override
  _DebtState createState() => _DebtState();
}

class _DebtState extends State<Debt> {
  final _key = GlobalKey<FormState>();
  final TextEditingController _baseline = TextEditingController();
  final TextEditingController _current = TextEditingController();
  final TextEditingController _strategy = TextEditingController();
  DialogBox dialogBox = DialogBox();
  Dio dio = Dio();
  bool _isClicked = false;
  bool _isLoadingDialogVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.debtInfo.dept!['current'] != null) {
      _current.text = formatDisplayNumber(
        widget.debtInfo.dept!['current'].toString(),
      );
    }
    if (widget.debtInfo.dept!['baseline'] != null) {
      _baseline.text = formatDisplayNumber(
        widget.debtInfo.dept!['baseline'].toString(),
      );
    }
    if (widget.debtInfo.dept!['strategy'] != null) {
      _strategy.text = widget.debtInfo.dept!['strategy'].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    var value = context.watch<Providers>().sevengeemodel.steps[3].toString();
    var intVal = int.parse(value);
    String infoOnVal() {
      if (intVal >= 0 && intVal <= 25) {
        return debt1;
      } else if (intVal >= 26 && intVal <= 50) {
        return debt2;
      } else if (intVal >= 51 && intVal <= 75) {
        return debt3;
      } else if (intVal >= 76 && intVal <= 99) {
        return debt4;
      } else if (intVal >= 100) {
        return debt5;
      }
      return '';
    }

    var currency = context.watch<Providers>().snapshotmodel.currency;

    var colors = context.watch<Providers>().sevengeemodel.backgrounds;
    List<String> sevenGeesColor = [];
    List<String> sevenGeesColors = [];
    List<int> realColors = [];
    for (var a in colors) {
      sevenGeesColor.add(a.toString().substring(1));
    }

    for (var a in sevenGeesColor) {
      sevenGeesColors.add('0xff$a');
    }
    for (var a in sevenGeesColors) {
      realColors.add(int.parse(a));
    }

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        surfaceTintColor: Colors.white,
        actions: [
          widget.newUser
              ? Container()
              : TextButton(
                  onPressed: () {
                    switch (widget.newUser) {
                      case true:
                        FocusScope.of(context).requestFocus(FocusNode());
                        if (double.parse(_baseline.text.replaceAll(',', '')) <
                            double.parse(_current.text.replaceAll(',', ''))) {
                          Fluttertoast.showToast(
                            msg: 'Current cannot be greater than Baseline',
                          );
                          return;
                        }
                        if (_current.text.isEmpty || _baseline.text.isEmpty) {
                          dialogBox.information(
                            context,
                            'Status',
                            'Please fill all fields',
                          );
                          return;
                        }
                        dialogBox.waiting(context, 'Saving');
                        var timer = Timer(
                          const Duration(milliseconds: 30000),
                          () {
                            if (mounted) {
                              Navigator.pop(context);
                              dialogBox.information(
                                context,
                                'Status',
                                'Service timed out',
                              );
                            }
                            return;
                          },
                        );
                        try {
                          save7G();
                          timer.cancel();
                        } catch (e) {
                          if (mounted) {
                            Navigator.pop(context);
                            dialogBox.information(
                              context,
                              'Status',
                              'Error saving details',
                            );
                          }
                          timer.cancel();
                        }
                        break;
                      case false:
                        widget.newUser ? mortgage() : fuck();
                        break;
                      default:
                    }
                  },
                  child: Text(
                    "Save",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: width * .035,
                      color: const Color(0xff009933),
                    ),
                  ),
                ),
        ],
      ),
      bottomNavigationBar: const BottomNav(1),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: width * .05,
            horizontal: width * .02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text('${widget.newUser}'),
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Color(0xff7B44A1), width: 3),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * .03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xff4A2A68), Color(0xff7B44A1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              'Debt',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 20.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'A measure of what you owe on your primary place of residence',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * .02),
              Divider(
                color: const Color(0xffE6E6E6),
                indent: width * .03,
                endIndent: width * .03,
              ),
              Visibility(
                visible: widget.newUser,
                child: Card(
                  elevation: 0,
                  color: const Color(0xfff4f4f4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: const BorderSide(
                      color: Color(0xffD8D8D8),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: height * .01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  radius: 18.h,
                                  backgroundColor: Colors.white,
                                  backgroundImage: const AssetImage(
                                    'assets/images/personal_avatar.png',
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * .02,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    text:
                                        'Hi ${context.watch<Providers>().details[0]}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Nunito',
                                      color: Colors.black,
                                    ),
                                    children: const <TextSpan>[],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          Visibility(
                            visible: widget.newUser,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: width * .02,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Status',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: width * .04,
                                    ),
                                  ),
                                  _buildValue(value, width),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * .02),
                        child: Text(
                          infoOnVal(),
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: width * .035,
                          ),
                        ),
                      ),
                      SizedBox(height: height * .02),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * .01),
              Form(
                key: _key,
                child: Column(
                  children: [
                    Fiforms(
                      width: width,
                      enabled: widget.newUser,
                      height: height,
                      name: 'Baseline',
                      subtitle: 'The amount you borrowed to buy your house',
                      controller: _baseline,
                      symbol: currency,
                    ),
                    SizedBox(height: height * .02),
                    Fiforms(
                      width: width,
                      enabled: widget.newUser,
                      height: height,
                      name: "Current",
                      subtitle: 'Your mortgage balance today',
                      controller: _current,
                      symbol: currency,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height * .03),
                        Text(
                          'Personal Strategy',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: width * .04,
                          ),
                        ),
                        SizedBox(height: height * .005),
                        Text(
                          'Document your plan',
                          style: TextStyle(
                            color: const Color(0xff888888),
                            fontWeight: FontWeight.w400,
                            fontSize: width * .04,
                          ),
                        ),
                        SizedBox(height: height * .02),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isClicked = !_isClicked;
                            });
                          },
                          child: Card(
                            color: AppColors.cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              side: const BorderSide(
                                color: Color(0xffD8D8D8),
                                width: 0.5,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextFormField(
                                  enabled: _isClicked,
                                  style: TextStyle(fontSize: width * .04),
                                  controller: _strategy,
                                  maxLines: 7, 
                                  decoration: InputDecoration(
                                    hintText:
                                        'Outline your strategy clearly...',
                                    contentPadding: const EdgeInsets.all(8),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: BorderSide(
                                        color: _isClicked
                                            ? Colors.black
                                            : Colors.transparent,
                                        width: _isClicked ? 2.5 : 0.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: const BorderSide(
                                        color: Colors.black,
                                        width: 2.0,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Show nothing if newUser is true
                        if (!widget.newUser)
                          const SizedBox.shrink()
                        // Show buttons when clicked and not new user
                        else if (_isClicked)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: width * .40,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isClicked = false;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                  ),
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      fontSize: width * .04,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: width * .40,
                                child: ElevatedButton(
                                  onPressed: () {
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(FocusNode());
                                    if (double.parse(
                                          _baseline.text.replaceAll(',', ''),
                                        ) <
                                        double.parse(
                                          _current.text.replaceAll(',', ''),
                                        )) {
                                      Fluttertoast.showToast(
                                        msg:
                                            'Current cannot be greater than Baseline',
                                      );
                                      return;
                                    }
                                    if (_current.text.isEmpty ||
                                        _baseline.text.isEmpty) {
                                      dialogBox.information(
                                        context,
                                        'Status',
                                        'Please fill all fields',
                                      );
                                      return;
                                    }
                                    dialogBox.waiting(context, 'Saving');
                                    var timer = Timer(
                                      const Duration(milliseconds: 30000),
                                      () {
                                        if (mounted) {
                                          Navigator.pop(context);
                                          dialogBox.information(
                                            context,
                                            'Status',
                                            'Service timed out',
                                          );
                                        }
                                        return;
                                      },
                                    );
                                    try {
                                      save7G();
                                      timer.cancel();
                                    } catch (e) {
                                      if (mounted) {
                                        Navigator.pop(context);
                                        dialogBox.information(
                                          context,
                                          'Status',
                                          'Error saving details',
                                        );
                                      }
                                      timer.cancel();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                  ),
                                  child: Text(
                                    "Update",
                                    style: TextStyle(
                                      fontSize: width * .04,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    Visibility(
                      visible: !widget.newUser,
                      child: SizedBox(height: height * .05),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: widget.newUser,
                child: SizedBox(height: height * .05),
              ),
              widget.newUser
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 8.w,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(width * .02),
                        ),
                      ),
                      onPressed: () {
                        switch (widget.newUser) {
                          case true:
                           mortgage();
                            break;
                          default:
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.remove_red_eye,
                            size: width * .04,
                            color: const Color(0xfff3f3f4),
                          ),
                          SizedBox(width: width * .02),
                          Text(
                            "View More",
                            style: TextStyle(
                              color: const Color(0xfff3f3f4),
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ):Container(),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoadingDialog(String message) {
    if (_isLoadingDialogVisible || !mounted) return;
    _isLoadingDialogVisible = true;
    dialogBox.waiting(context, message).then((_) {
      _isLoadingDialogVisible = false;
    });
  }

  void _dismissLoadingDialog() {
    if (!_isLoadingDialogVisible || !mounted) return;
    _isLoadingDialogVisible = false;
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> fuck() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (double.parse(_baseline.text.replaceAll(',', '')) <
        double.parse(_current.text.replaceAll(',', ''))) {
      Fluttertoast.showToast(msg: 'Current cannot be greater than Baseline');
      return;
    }
    if (_current.text.isEmpty || _baseline.text.isEmpty) {
      dialogBox.information(context, 'Status', 'Please fill all fields');
      return;
    }
    _showLoadingDialog('Saving');
    try {
      await save7G();
    } catch (e) {
      if (mounted) {
        _dismissLoadingDialog();
        dialogBox.information(
          context,
          'Unable to Save',
          'We could not save your information right now. Please try again.',
        );
      }
    }
  }

  mortgage() async {
    if (_current.text.isEmpty || _baseline.text.isEmpty) {
      dialogBox.information(context, 'Status', 'Please fill all fields');
      return;
    }
    var timer = Timer(const Duration(milliseconds: 45000), () {
      if (mounted) {
        _dismissLoadingDialog();
        dialogBox.information(
          context,
          'Taking Longer Than Expected',
          'Saving your information is taking longer than expected. Please check your connection and try again.',
        );
      }
      return;
    });
    FocusScope.of(context).requestFocus(FocusNode());

    _showLoadingDialog("Loading");

    var url = "$baseUrl/app/360/mortgage";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );

    if (response.statusCode == 200 && mounted) {
      var seveng = response.data["seveng"];
      _dismissLoadingDialog();
      timer.cancel();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Mortgageitem(item: seveng[0], seven: true),
        ),
      );
    } else if (mounted) {
      timer.cancel();
      _dismissLoadingDialog();
    }
  }

  save7G() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_current.text.isEmpty || _baseline.text.isEmpty) {
      dialogBox.information(context, 'Status', 'Please fill all fields');
      return;
    }

    var timer = Timer(const Duration(milliseconds: 20000), () {
      if (mounted) {
        _dismissLoadingDialog();
        dialogBox.information(context, 'Status', 'Service timed out');
      }
      return;
    });

    try {
      var url = Uri.parse("$baseUrl/app/seveng");
      var urlAnalytics = Uri.parse('$baseUrl/app/seveng/edit');
      Map<String, dynamic> body = {
        "seveng": "danhbxbxnjxvn7wxdsvabxzuiwgd",
        "current": _current.text.replaceAll(',', ''),
        "baseline": _baseline.text.replaceAll(',', ''),
        "strategy": _strategy.text,
        "main": "1",
      };

      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      var response = await http.post(
        url,
        body: body,
        headers: {
          "Authorization": 'Bearer $token',
          "Content-Type": "application/x-www-form-urlencoded",
        },
        encoding: Encoding.getByName("utf-8"),
      );

      final response4 = await http.get(
        urlAnalytics,
        headers: {"Authorization": 'Bearer $token'},
      );

      if (response.statusCode == 200 && mounted) {
        var url7G = Uri.parse('$baseUrl/app/seveng');

        final prefs = await SharedPreferences.getInstance();
        var finalToken = prefs.getString('tokenDB');

        final response2 = await http.get(
          url7G,
          headers: {"Authorization": 'Bearer $finalToken'},
        );

        if (response2.statusCode == 200) {
          Sevengeemodel sevengeemodel = Sevengeemodel.fromJson(
            jsonDecode(response2.body),
          );
          context.read<Providers>().setSevenGee(sevengeemodel);

          if (response4.statusCode == 200) {
            var urlDashboard = Uri.parse('$baseUrl/app/dashboard');
            var responseDashboard = await http.get(
              urlDashboard,
              headers: {"Authorization": 'Bearer $finalToken'},
            );

            if (responseDashboard.statusCode == 200 && mounted) {
              var dataDashboard = Map<String, dynamic>.from(
                jsonDecode(responseDashboard.body),
              );
              var analyticsData = jsonDecode(response4.body);
              var analyticsinfo = Analyticsinfo.fromJson(analyticsData["data"]);
              context.read<Providers>().setAnalyticsInfo(analyticsinfo);
              context.read<Providers>().setAssistance(
                Map<String, dynamic>.from(dataDashboard['assistance'] ?? {}),
              );

              timer.cancel();
              _dismissLoadingDialog();
              // ONLY auto-navigate if this page was opened from a save flow
              if (widget.fromSave && mounted) {
                if (dataDashboard.isNotEmpty) {
                  String assistanceData =
                      dataDashboard['assistance']?["personal"]?["setup"] ?? "";
                  print("assistanceData: $assistanceData");

                  String nextPageType = _getNextPageType(assistanceData);
                  print("Next page type to navigate: $nextPageType");

                  if (nextPageType.isNotEmpty) {
                    NavigationManager.navigateToPage(
                      context: context,
                      pageType: nextPageType,
                      analyticsinfo: analyticsinfo,
                      replace: true,
                      fromSave: true,
                    );
                  } else {
                    dialogBox
                        .information(
                          context,
                          'Success',
                          'Information saved successfully!!',
                        )
                        .then((_) {
                          if (mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              'Dashboard',
                              (route) => false,
                            );
                          }
                        });
                  }
                } else {
                  // Pop whatever dialog is on top (the loading one), then show success
                  dialogBox
                      .information(
                        context,
                        'Success',
                        'Information saved successfully!!',
                      )
                      .then((_) {
                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            'Dashboard',
                            (route) => false,
                          );
                        }
                      });
                }
              } else if (mounted && !widget.fromSave) {
                // Pop whatever dialog is on top (the loading one), then show success
                await Future.delayed(const Duration(milliseconds: 100));
                 Navigator.pushNamedAndRemoveUntil(
                  context,
                  'Dashboard',
                  (route) => false,
                  arguments: {'targetTab': 1}, // 1 = analytics tab
                );
              }
              return;
            }
          }
        }

        timer.cancel();
        if (mounted) {
          Navigator.pop(context);
          dialogBox.information(context, 'Error', 'An error occurred');
        }
      } else {
        timer.cancel();
        if (mounted) {
          Navigator.pop(context);
          dialogBox.information(context, 'Error', 'An error occurred');
        }
      }
    } catch (e) {
      timer.cancel();
      if (mounted) {
        _dismissLoadingDialog();
        dialogBox.information(
          context,
          'Unable to Save',
          'We could not save your information. Please check your connection and try again.',
        );
      }
    }
  }

  String _getNextPageType(String assistance) {
    if (assistance.isEmpty) return '';

    String setupText = assistance.toLowerCase();

    // Extract page type from setup text
    if (setupText.contains('credit')) return 'credit';
    if (setupText.contains('grand')) return 'grand';
    if (setupText.contains('freedom')) return 'freedom';
    if (setupText.contains('education')) return 'education';
    if (setupText.contains('debt')) return 'debt';
    if (setupText.contains('beta')) return 'beta';
    if (setupText.contains('alpha')) return 'alpha';

    return '';
  }

  Widget _buildValue(String value, double width) {
    int? intValuePercentage = int.tryParse(value);

    if (intValuePercentage == null ||
        intValuePercentage < 0 ||
        intValuePercentage > 100) {
      return Text(
        'Invalid Value: $value',
        style: TextStyle(
          fontSize: width * 0.04,
          fontWeight: FontWeight.w700,
          color: Colors.red,
        ),
      );
    }

    Color startColor;
    Color endColor;

    if (intValuePercentage <= 25) {
      startColor = const Color(0xffFF0001);
      endColor = const Color(0xffCE0001);
    } else if (intValuePercentage <= 50) {
      startColor = const Color(0xffF6AE39);
      endColor = const Color(0xffFF7A00);
    } else if (intValuePercentage <= 75) {
      startColor = const Color(0xff005E32);
      endColor = const Color(0xff17B26A);
    } else {
      startColor = const Color(0xff005E77);
      endColor = const Color(0xff002E77);
    }

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: Text(
        '$intValuePercentage%',
        style: TextStyle(
          fontSize: width * 0.04,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
