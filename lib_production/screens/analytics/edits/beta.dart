import 'dart:async';
import 'dart:convert';
import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/screens/360/accounts/cash/cashitem.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/utils/strings.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/models/sevengeemodel.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:GapHub/screens/registration/costoflivingcalc.dart';

import '../navigation_manager.dart';
import 'alpha.dart';

class Beta extends StatefulWidget {
  final Analyticsinfo betaInfo;
  final bool newUser;
  final bool contains;
  final bool fromSave;

  const Beta({
    super.key,
    required this.betaInfo,
    required this.newUser,
    required this.contains,
    this.fromSave = false,
  });

  @override
  _BetaState createState() => _BetaState();
}

class _BetaState extends State<Beta> {
  final _key = GlobalKey<FormState>();
  final TextEditingController _current = TextEditingController();
  final TextEditingController _target = TextEditingController();
  final TextEditingController _strategy = TextEditingController();
  final DialogBox dialogBox = DialogBox();
  final Dio dio = Dio();

  bool _isClicked = false;
  bool check = false;
  bool _isLoadingDialogVisible = false;

  @override
  void initState() {
    super.initState();
    final beta = widget.betaInfo.beta;
    if (beta?['current'] != null) _current.text = beta!['current'].toString();
    if (beta?['target'] != null) _target.text = beta!['target'].toString();
    if (beta?['strategy'] != null) _strategy.text = beta!['strategy'].toString();
  }

  @override
  void dispose() {
    _current.dispose();
    _target.dispose();
    _strategy.dispose();
    super.dispose();
  }

  // ─── Loading dialog helpers ───────────────────────────────────────────────

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

  // ─── Validation helper ────────────────────────────────────────────────────

  bool _fieldsValid() =>
      check || (_current.text.isNotEmpty && _target.text.isNotEmpty);

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> fuck() async {
    FocusScope.of(context).unfocus();
    if (!_fieldsValid()) {
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

  Future<void> cash() async {
    if (!_fieldsValid()) {
      dialogBox.information(context, 'Status', 'Please fill all fields');
      return;
    }
    FocusScope.of(context).unfocus();
    _showLoadingDialog('Loading');

    final timer = Timer(const Duration(milliseconds: 20000), () {
      _dismissLoadingDialog();
      dialogBox.information(context, 'Status', 'Service timed out');
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');
      final response = await dio.get(
        '$baseUrl/app/360/cash',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      timer.cancel();
      if (response.statusCode == 200) {
        final seveng = response.data['seveng'];
        _dismissLoadingDialog();
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  Cashitem(item: seveng[1], seven: true, bespokes: false),
            ),
          );
        }
      }
    } catch (e) {
      timer.cancel();
      _dismissLoadingDialog();
      if (mounted) {
        dialogBox.information(
          context,
          'Connection Issue',
          'Please check your network and try again.',
        );
      }
    }
  }

  Future<void> save7G() async {
    FocusScope.of(context).unfocus();
    if (!_fieldsValid()) {
      dialogBox.information(context, 'Status', 'Please fill all fields');
      return;
    }

    final timer = Timer(const Duration(milliseconds: 45000), () {
      if (mounted) {
        _dismissLoadingDialog();
        dialogBox.information(
          context,
          'Taking Longer Than Expected',
          'Saving your information is taking longer than expected. '
              'Please check your connection and try again.',
        );
      }
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      final Map<String, dynamic> body = check
          ? {
              'purchase': '1',
              'seveng': 'aqgndshsvdhsejdoksbxdvxsgd',
              'current': '0',
              'target': '0',
            }
          : {
              'seveng': 'aqgndshsvdhsejdoksbxdvxsgd',
              'current': _current.text.replaceAll(',', ''),
              'target': _target.text.replaceAll(',', ''),
              'strategy': _strategy.text,
              'main': '1',
            };

      // ── Fire save + analytics fetch in parallel ──────────────────────────
      final results = await Future.wait([
        http.post(
          Uri.parse('$baseUrl/app/seveng'),
          body: body,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          encoding: Encoding.getByName('utf-8'),
        ),
        http.get(
          Uri.parse('$baseUrl/app/seveng/edit'),
          headers: {'Authorization': 'Bearer $token'},
        ),
        http.get(
          Uri.parse('$baseUrl/app/seveng'),
          headers: {'Authorization': 'Bearer $token'},
        ),
        http.get(
          Uri.parse('$baseUrl/app/dashboard'),
          headers: {'Authorization': 'Bearer $token'},
        ),
      ]);

      final saveResponse      = results[0];
      final analyticsResponse = results[1];
      final sevengResponse    = results[2];
      final dashboardResponse = results[3];

      if (!mounted) {
        timer.cancel();
        return;
      }

      if (saveResponse.statusCode != 200) {
        timer.cancel();
        _dismissLoadingDialog();
        dialogBox.information(context, 'Error', 'An error occurred');
        return;
      }

      // ── Update providers ─────────────────────────────────────────────────
      if (sevengResponse.statusCode == 200) {
        context.read<Providers>().setSevenGee(
              Sevengeemodel.fromJson(jsonDecode(sevengResponse.body)),
            );
      }

      Analyticsinfo? analyticsinfo;
      if (analyticsResponse.statusCode == 200) {
        analyticsinfo = Analyticsinfo.fromJson(
          jsonDecode(analyticsResponse.body)['data'],
        );
        context.read<Providers>().setAnalyticsInfo(analyticsinfo);
      }

      Map<String, dynamic> dataDashboard = {};
      if (dashboardResponse.statusCode == 200) {
        dataDashboard = Map<String, dynamic>.from(
          jsonDecode(dashboardResponse.body),
        );
        context.read<Providers>().setAssistance(
          Map<String, dynamic>.from(dataDashboard['assistance'] ?? {}),
        );
      }

      timer.cancel();
      _dismissLoadingDialog();

      if (!mounted) return;

      // ── Navigate ──────────────────────────────────────────────────────────
      if (widget.fromSave && dataDashboard.isNotEmpty) {
        final assistanceData =
            dataDashboard['assistance']?['personal']?['setup'] ?? '';
        final nextPageType = _getNextPageType(assistanceData);

        if (nextPageType.isNotEmpty && analyticsinfo != null) {
          NavigationManager.navigateToPage(
            context: context,
            pageType: nextPageType,
            analyticsinfo: analyticsinfo,
            replace: true,
            fromSave: true,
          );
        } else {
          dialogBox
              .information(context, 'Success', 'Information saved successfully!!')
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
        dialogBox.information(
          context,
          'Unable to Save',
          'We could not save your information. '
              'Please check your connection and try again.',
        );
      }
    }
  }

  String _getNextPageType(String assistance) {
    if (assistance.isEmpty) return '';
    final text = assistance.toLowerCase();
    if (text.contains('credit')) return 'credit';
    if (text.contains('grand')) return 'grand';
    if (text.contains('freedom')) return 'freedom';
    if (text.contains('education')) return 'education';
    if (text.contains('debt')) return 'debt';
    if (text.contains('beta')) return 'beta';
    if (text.contains('alpha')) return 'alpha';
    return '';
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    var value = context.watch<Providers>().sevengeemodel.steps[5].toString();
    var intVal = int.parse(value);

    String infoOnVal() {
      if (intVal >= 0 && intVal <= 25) return beta1;
      if (intVal >= 26 && intVal <= 50) return beta2;
      if (intVal >= 51 && intVal <= 75) return beta3;
      if (intVal >= 76 && intVal <= 99) return beta4;
      if (intVal >= 100) return beta5;
      return '';
    }

    final colors = context.watch<Providers>().sevengeemodel.backgrounds;
    final realColors = colors
        .map((a) => int.parse('0xff${a.toString().substring(1)}'))
        .toList();

    final currency = context.watch<Providers>().snapshotmodel.currency;

    final orientation = MediaQuery.of(context).orientation;
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
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!widget.newUser)
            TextButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                if (check) {
                  fuck();
                  return;
                }
                widget.contains ? cash() : fuck();
              },
              child: Text(
                'Save',
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
              // ── Header ────────────────────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Color(0xffA67F40), width: 3),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * .03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xff5A3E0E), Color(0xffA67F40)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          'Beta',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        'A measure of your house purchase savings',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Divider(
                color: const Color(0xffE6E6E6),
                indent: width * .03,
                endIndent: width * .03,
              ),
              SizedBox(height: 12.h),

              // ── Status card (new user only) ────────────────────────────────
              Visibility(
                visible: widget.newUser,
                child: Card(
                  elevation: 0,
                  color: const Color(0xfff4f4f4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: const BorderSide(color: Color(0xffD8D8D8), width: 0.5),
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
                                    horizontal: width * .02),
                                child: Text(
                                  'Hi ${context.watch<Providers>().details[0]}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Nunito',
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: width * .02),
                            child: Column(
                              children: [
                                Text(
                                  'Status',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                _buildValue(value, width),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: width * .02),
                        child: Text(
                          infoOnVal(),
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: height * .02),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // ── Input fields ──────────────────────────────────────────────
              Form(
                key: _key,
                child: Column(
                  children: [
                    Fiforms(
                      width: width,
                      height: height,
                      enabled: widget.newUser,
                      name: 'Current',
                      subtitle: 'House purchase savings today',
                      controller: _current,
                      symbol: currency,
                    ),
                    SizedBox(height: height * .02),
                    Fiforms(
                      width: width,
                      height: height,
                      enabled: widget.newUser,
                      name: 'Target',
                      subtitle: 'House purchase deposit and other costs',
                      controller: _target,
                      symbol: currency,
                    ),
                  ],
                ),
              ),

              // ── Checkbox ──────────────────────────────────────────────────
              Visibility(
                visible: !widget.newUser,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'I already bought my home',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: width * .04,
                      ),
                    ),
                    Checkbox(
                      value: check,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (value) => setState(() => check = value!),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * .02),

              // ── Personal Strategy ─────────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    onTap: () => setState(() => _isClicked = !_isClicked),
                    child: Card(
                      elevation: 0,
                      color: AppColors.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: const BorderSide(color: Color(0xffD8D8D8)),
                      ),
                      child: TextFormField(
                        enabled: _isClicked,
                        style: TextStyle(fontSize: width * .04),
                        controller: _strategy,
                        maxLines: 7,
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
                              width: 2.0,
                            ),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  if (!widget.newUser)
                    const SizedBox.shrink()
                  else if (_isClicked)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: width * .40,
                          child: ElevatedButton(
                            onPressed: () =>
                                setState(() => _isClicked = false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                            child: Text(
                              'Cancel',
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
                              FocusScope.of(context).unfocus();
                              if (!_fieldsValid()) {
                                dialogBox.information(
                                  context,
                                  'Status',
                                  'Please fill all fields',
                                );
                                return;
                              }
                              dialogBox.waiting(context, 'Saving');
                              final timer = Timer(
                                const Duration(milliseconds: 30000),
                                () {
                                  Navigator.pop(context);
                                  dialogBox.information(
                                    context,
                                    'Status',
                                    'Service timed out',
                                  );
                                },
                              );
                              try {
                                save7G();
                                timer.cancel();
                              } catch (e) {
                                Navigator.pop(context);
                                timer.cancel();
                                dialogBox.information(
                                  context,
                                  'Status',
                                  'Error saving details',
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                            ),
                            child: Text(
                              'Update',
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
              SizedBox(height: height * .02),
              Visibility(
                visible: !widget.newUser,
                child: SizedBox(height: height * .03),
              ),

              // ── View More button ──────────────────────────────────────────
              if (widget.newUser)
                ElevatedButton(
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
                  onPressed: cash,
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
                        'View More',
                        style: TextStyle(
                          color: const Color(0xfff3f3f4),
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Percentage value widget ──────────────────────────────────────────────

  Widget _buildValue(String value, double width) {
    final intValuePercentage = int.tryParse(value);
    if (intValuePercentage == null ||
        intValuePercentage < 0 ||
        intValuePercentage > 100) {
      return Text(
        'Invalid Value: $value',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w900,
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
      shaderCallback: (bounds) => LinearGradient(
        colors: [startColor, endColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
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