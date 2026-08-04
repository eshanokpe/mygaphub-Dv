import 'dart:async';
import 'dart:convert';
import 'package:GapHub/screens/360/accounts/philanthropy/setgiving.dart';
import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/models/sevengeemodel.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/strings.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/screens/registration/costoflivingcalc.dart';
import '../navigation_manager.dart';

// ---------------------------------------------------------------------------
// Color constants
// ---------------------------------------------------------------------------

const _kColorSaveGreen = Color(0xff009933);
const _kColorSlate = Color(0xff4F5B6D);
const _kColorSlateLight = Color(0xff6C7685);
const _kColorDivider = Color(0xffE6E6E6);
const _kColorCardBorder = Color(0xffD8D8D8);
const _kColorCard = Color(0xfff4f4f4);
const _kColorSubtext = Color(0xff888888);
const _kColorCancelLabel = Color(0xff344054);
const _kColorCancelBorder = Color(0xffD0D5DD);
const _kColorIconTint = Color(0xfff3f3f4);
const _kColorRed = Color(0xffFF0001);
const _kColorRedDark = Color(0xffCE0001);
const _kColorAmber = Color(0xffF6AE39);
const _kColorOrange = Color(0xffFF7A00);
const _kColorGreenDark = Color(0xff005E32);
const _kColorGreenLight = Color(0xff17B26A);
const _kColorBlueDark = Color(0xff005E77);
const _kColorNavy = Color(0xff002E77);

class Grand extends StatefulWidget {
  final Analyticsinfo grandInfo;
  final bool newUser;
  final bool contains;
  final bool fromSave;

  const Grand({
    super.key,
    required this.grandInfo,
    required this.newUser,
    required this.contains,
    this.fromSave = false,
  });

  @override
  _GrandState createState() => _GrandState();
}

class _GrandState extends State<Grand> {
  final _formKey = GlobalKey<FormState>();
  Dio _dio = Dio();
  final TextEditingController _current = TextEditingController();
  final TextEditingController _target = TextEditingController();
  final TextEditingController _strategy = TextEditingController();
  DialogBox _dialogBox = DialogBox();
  bool _isClicked = false;
  bool _isLoadingDialogVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.grandInfo.grand!['current'] != null) {
      _current.text = formatDisplayNumber(
        widget.grandInfo.grand!['current'].toString(),
      );
    }
    if (widget.grandInfo.grand!['target'] != null) {
      _target.text = formatDisplayNumber(
        widget.grandInfo.grand!['target'].toString(),
      );
    }
    if (widget.grandInfo.grand!['strategy'] != null) {
      _strategy.text = widget.grandInfo.grand!['strategy'].toString();
    }
  }

  @override
  void dispose() {
    _current.dispose();
    _target.dispose();
    _strategy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var value = context.watch<Providers>().sevengeemodel.steps[0].toString();
    String currency = context.watch<Providers>().snapshotmodel.currency;

    var intVal = int.parse(value);
    String infoOnVal() {
      if (intVal >= 0 && intVal <= 25) {
        return grand1;
      } else if (intVal >= 26 && intVal <= 50) {
        return grand2;
      } else if (intVal >= 51 && intVal <= 75) {
        return grand3;
      } else if (intVal >= 76 && intVal <= 99) {
        return grand4;
      } else if (intVal >= 100) {
        return grand5;
      }
      return '';
    }

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
        surfaceTintColor: Colors.white,
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          widget.newUser || widget.contains
              ? Container()
              : TextButton(
                  onPressed: () {
                    switch (widget.newUser) {
                      case true:
                        FocusScope.of(context).requestFocus(FocusNode());
                        if (_current.text.isEmpty || _target.text.isEmpty) {
                          _dialogBox.information(
                            context,
                            'Status',
                            'Please fill all fields',
                          );
                          return;
                        }
                        _dialogBox.waiting(context, 'Saving');
                        var timer = Timer(
                          const Duration(milliseconds: 30000),
                          () {
                            Navigator.pop(context);
                            _dialogBox.information(
                              context,
                              'Status',
                              'Service timed out',
                            );
                            return;
                          },
                        );
                        try {
                          _save7G();
                          timer.cancel();
                        } catch (e) {
                          Navigator.pop(context);
                          _dialogBox.information(
                            context,
                            'Status',
                            'Error saving details',
                          );
                          timer.cancel();
                        }
                        break;
                      case false:
                        widget.contains
                            ? _openPhilanthropy(currency)
                            : _handleSave();
                        break;
                      default:
                    }
                  },
                  child: Text(
                    "Save",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: width * .035,
                      color: _kColorSaveGreen,
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
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: _kColorSlate, width: 3),
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
                              colors: [_kColorSlate, _kColorSlateLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              'Grand',
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
                          Text(
                            'A measure of your benevolence',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16.sp,
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
                color: _kColorDivider,
                indent: width * .03,
                endIndent: width * .03,
              ),
              SizedBox(height: height * .02),
              Visibility(
                visible: widget.newUser,
                child: Card(
                  elevation: 0,
                  color: _kColorCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: const BorderSide(
                      color: _kColorCardBorder,
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
                key: _formKey,
                child: Column(
                  children: [
                    Fiforms(
                      symbol: currency,
                      width: width,
                      height: height,
                      enabled: widget.newUser,
                      subtitle:
                          'Average monthly amount you give to others and charity',
                      name: 'Current',
                      controller: _current,
                    ),
                    SizedBox(height: height * .02),
                    Fiforms(
                      name: 'Target',
                      subtitle: 'Intended amount to give to others and charity',
                      controller: _target,
                      height: height,
                      width: width,
                      enabled: widget.newUser,
                      symbol: currency,
                    ),
                  ],
                ),
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
                      color: _kColorSubtext,
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
                      elevation: 0,
                      color: AppColors.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: const BorderSide(
                          color: _kColorCardBorder,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextFormField(
                            enabled: _isClicked,
                            style: TextStyle(fontSize: width * .04),
                            maxLines: 7,
                            controller: _strategy,
                            decoration: InputDecoration(
                              hintText: 'Outline your strategy clearly...',
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
                                  width: 2.5,
                                ),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!widget.newUser)
                    const SizedBox.shrink()
                  else if (_isClicked)
                    Padding(
                      padding: EdgeInsets.only(top: height * .015),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isClicked = false;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                side: const BorderSide(
                                  color: _kColorCancelBorder,
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: _kColorCancelLabel,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: width * .03),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                FocusScope.of(
                                  context,
                                ).requestFocus(FocusNode());
                                if (_current.text.isEmpty ||
                                    _target.text.isEmpty) {
                                  _dialogBox.information(
                                    context,
                                    'Status',
                                    'Please fill all fields',
                                  );
                                  return;
                                }
                                _dialogBox.waiting(context, 'Saving');
                                var timer = Timer(
                                  const Duration(milliseconds: 30000),
                                  () {
                                    Navigator.pop(context);
                                    _dialogBox.information(
                                      context,
                                      'Status',
                                      'Service timed out',
                                    );
                                    return;
                                  },
                                );
                                try {
                                  _save7G();
                                  timer.cancel();
                                } catch (e) {
                                  Navigator.pop(context);
                                  timer.cancel();
                                  _dialogBox.information(
                                    context,
                                    'Status',
                                    'Error saving details',
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Update",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              Visibility(
                visible: widget.newUser,
                child: SizedBox(height: height * .05),
              ),
              SizedBox(height: height * .02),
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
                            _openPhilanthropy(currency);
                            break;
                          case false:
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
                            color: _kColorIconTint,
                          ),
                          SizedBox(width: width * .02),
                          Text(
                            "View More",
                            style: TextStyle(
                              color: _kColorIconTint,
                              fontWeight: FontWeight.w400,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoadingDialog(String message) {
    if (_isLoadingDialogVisible || !mounted) return;
    _isLoadingDialogVisible = true;
    _dialogBox.waiting(context, message).then((_) {
      _isLoadingDialogVisible = false;
    });
  }

  void _dismissLoadingDialog() {
    if (!_isLoadingDialogVisible || !mounted) return;
    _isLoadingDialogVisible = false;
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _handleSave() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_current.text.isEmpty || _target.text.isEmpty) {
      _dialogBox.information(context, 'Status', 'Please fill all fields');
      return;
    }
    _showLoadingDialog('Saving');
    try {
      await _save7G();
    } catch (e) {
      if (mounted) {
        _dismissLoadingDialog();
        _dialogBox.information(
          context,
          'Unable to Save',
          'We could not save your information right now. Please try again.',
        );
      }
    }
  }

  Future<void> _openPhilanthropy(String currency) async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_current.text.isEmpty || _target.text.isEmpty) {
      _dialogBox.information(context, 'Status', 'Please fill all fields');
      return;
    }
    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      _dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    _showLoadingDialog('Loading');
    var url2 = "$baseUrl/app/360/philantrophy";

    final prefs = await SharedPreferences.getInstance();
    String? finalToken = prefs.getString('tokenDB');

    var response2 = await _dio.get(
      url2,
      options: Options(headers: {"Authorization": 'Bearer $finalToken'}),
    );
    if (response2.statusCode == 200) {
      timer.cancel();
      _dismissLoadingDialog();

      if (response2.data["data"]["grand"]["current"] !=
          response2.data["data"]["philantrophy_detail"]["sum"]) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Setgiving(response2.data)),
        );
      } else {
        context.read<Providers>().setphilanList(response2.data);
        Navigator.of(context).pushNamed('Philanthropy');
      }
    } else {
      timer.cancel();
      _dismissLoadingDialog();
    }
  }

  Future<void> _save7G() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_current.text.isEmpty || _target.text.isEmpty) {
      _dialogBox.information(context, 'Status', 'Please fill all fields');
      return;
    }

    var timer = Timer(const Duration(milliseconds: 45000), () {
      if (mounted) {
        _dismissLoadingDialog();
        _dialogBox.information(
          context,
          'Taking Longer Than Expected',
          'Saving your information is taking longer than expected. Please check your connection and try again.',
        );
      }
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');
      final headers = {"Authorization": 'Bearer $token'};

      final url = Uri.parse("$baseUrl/app/seveng");
      final urlAnalytics = Uri.parse('$baseUrl/app/seveng/edit');
      final urlDashboard = Uri.parse('$baseUrl/app/dashboard');

      Map<String, dynamic> body = {
        "seveng": "ggs5dbwexsxgxbxjzgjabajzxhsgzah",
        "current": _current.text.replaceAll(',', ''),
        "target": _target.text.replaceAll(',', ''),
        "strategy": _strategy.text,
        "main": "1",
      };

      // 1. POST first — must complete before fetching fresh data
      final response = await http.post(
        url,
        body: body,
        headers: {
          ...headers,
          "Content-Type": "application/x-www-form-urlencoded",
        },
        encoding: Encoding.getByName("utf-8"),
      );

      if (response.statusCode != 200 || !mounted) {
        throw Exception('Save failed with status ${response.statusCode}');
      }

      // 2. Fire all GET requests in parallel
      final results = await Future.wait([
        http.get(url, headers: headers), // seveng    → index 0
        http.get(urlAnalytics, headers: headers), // analytics → index 1
        http.get(urlDashboard, headers: headers), // dashboard → index 2
      ]);

      final response2 = results[0];
      final responseAnalytics = results[1];
      final responseDashboard = results[2];

      if (response2.statusCode != 200 ||
          responseAnalytics.statusCode != 200 ||
          responseDashboard.statusCode != 200) {
        throw Exception('One or more fetch requests failed');
      }

      if (!mounted) return;

      // Update providers
      final sevengeemodel = Sevengeemodel.fromJson(jsonDecode(response2.body));
      context.read<Providers>().setSevenGee(sevengeemodel);

      final dataDashboard = jsonDecode(responseDashboard.body);
      context.read<Providers>().setAssistance(
        Map<String, dynamic>.from(dataDashboard['assistance'] ?? {}),
      );

      final analyticsData = jsonDecode(responseAnalytics.body);
      final analyticsinfo = Analyticsinfo.fromJson(analyticsData["data"]);
      context.read<Providers>().setAnalyticsInfo(analyticsinfo);

      timer.cancel();
      _dismissLoadingDialog();

      if (widget.fromSave && mounted) {
        final String assistanceData =
            dataDashboard['assistance']?["personal"]?["setup"] ?? "";
        final String nextPageType = _getNextPageType(assistanceData);

        if (nextPageType.isNotEmpty) {
          NavigationManager.navigateToPage(
            context: context,
            pageType: nextPageType,
            analyticsinfo: analyticsinfo,
            replace: true,
            fromSave: true,
          );
        } else {
          _dialogBox
              .information(
                context,
                'Success',
                'Information saved successfully!',
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
      } else if (mounted) {
        // Pop whatever dialog is on top (the loading one), then show success
        await Future.delayed(const Duration(milliseconds: 100));
        Navigator.pushNamedAndRemoveUntil(
          context,
          'Dashboard',
          (route) => false,
          arguments: {'targetTab': 1}, // 1 = analytics tab
        );
      }
    } catch (e) {
      timer.cancel();
      if (mounted) {
        _dismissLoadingDialog();
        _dialogBox.information(
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
      startColor = _kColorRed;
      endColor = _kColorRedDark;
    } else if (intValuePercentage <= 50) {
      startColor = _kColorAmber;
      endColor = _kColorOrange;
    } else if (intValuePercentage <= 75) {
      startColor = _kColorGreenDark;
      endColor = _kColorGreenLight;
    } else {
      startColor = _kColorBlueDark;
      endColor = _kColorNavy;
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
