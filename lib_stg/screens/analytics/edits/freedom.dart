import 'dart:async';
import 'dart:convert';
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
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/screens/registration/costoflivingcalc.dart';
import '../../360/accounts/retirement/presentation/retiredash.dart';
import '../navigation_manager.dart';

class Freedom extends StatefulWidget {
  final Analyticsinfo freedomInfo;
  final bool newUser;
  final bool fromSave;

  const Freedom({
    super.key,
    required this.freedomInfo,
    required this.newUser,
    this.fromSave = false,
  });
  @override
  _FreedomState createState() => _FreedomState();
}

class _FreedomState extends State<Freedom> {
  final _key = GlobalKey<FormState>();
  final TextEditingController _current = TextEditingController();
  final TextEditingController _target = TextEditingController();
  final TextEditingController _strategy = TextEditingController();
  DialogBox dialogBox = DialogBox();
  Dio dio = Dio();
  String? current;
  bool _isClicked = false;
  bool _isLoadingDialogVisible = false;
  @override
  void initState() {
    super.initState();
    // Format the initial values before setting them to the controllers
    current = context
        .read<Providers>()
        .snapshotmodel
        .financial["portfolio"]
        .toString();
    _current.text = formatDisplayNumber(current.toString());
    // Format the initial values before setting them to the controllers
    _target.text = widget.freedomInfo.freedom!['target'].toString();
    // _target.text =context.read<Providers>().snapshotmodel.financial["cost"].toString();
    if (widget.freedomInfo.freedom!['strategy'] != null) {
      _strategy.text = widget.freedomInfo.freedom!['strategy'].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    var currency = context.watch<Providers>().snapshotmodel.currency;

    var value = context.watch<Providers>().sevengeemodel.steps[1].toString();
    var intVal = int.parse(value);
    String infoOnVal() {
      if (intVal >= 0 && intVal <= 25) {
        return freedom1;
      } else if (intVal >= 26 && intVal <= 50) {
        return freedom2;
      } else if (intVal >= 51 && intVal <= 75) {
        return freedom3;
      } else if (intVal >= 76 && intVal <= 99) {
        return freedom4;
      } else if (intVal >= 100) {
        return freedom5;
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
                      // case true:
                      //   _current.text == current
                      //       ? fuck()
                      //       : dialogBox.options(
                      //           context,
                      //           "Status",
                      //           "The value you provided is different from the value provided earlier ($currency$current). Are you sure you want to proceed with this new value ($currency${_current.text})",
                      //           () {
                      //             fuck();
                      //           },
                      //         );
                      //   break;
                      case false:
                        widget.newUser ? retire() : fuck();
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
              // Text("newUser:${widget.newUser}"),
              // Text("contains:${widget.contains}"),
              _buildHeader(),
              Divider(
                color: const Color(0xffE6E6E6),
                indent: width * .03,
                endIndent: width * .03,
              ),
              SizedBox(height: height * .02),
              _buildStatus(value, infoOnVal()),
              Form(
                key: _key,
                child: Column(
                  children: [
                    Fiforms(
                      width: width,
                      height: height,
                      enabled: widget.newUser,
                      name: "Current",
                      subtitle: "Your monthly asset portfolio income",
                      controller: _current,
                      symbol: currency,
                    ),
                    SizedBox(height: height * .04),
                    Fiforms(
                      name: 'Target',
                      subtitle: 'Your monthly cost of living',
                      controller: _target,
                      enabled: widget.newUser,
                      height: height,
                      width: width,
                      symbol: currency,
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * .02),
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
                      fontSize: width * .035,
                    ),
                  ),
                  SizedBox(height: height * .02),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isClicked = !_isClicked; // Toggle state on tap
                      });
                    },
                    child: Card(
                      elevation: 0,
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
                              hintText: 'Outline your strategy clearly...',
                              contentPadding: const EdgeInsets.all(8),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: _isClicked
                                      ? Colors.black
                                      : Colors
                                            .transparent, // Dynamic border color
                                  width: _isClicked ? 2.5 : 0.0, 
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(
                                  color:
                                      Colors.black, // Always blue when focused
                                  width: 2.0,
                                ),
                              ),
                              border: InputBorder.none, // Keep default none
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
                      // mainAxisSize:MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: width * .40,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isClicked = false; // Hide buttons
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
                              FocusScope.of(context).requestFocus(FocusNode());
                              if (_current.text.isEmpty ||
                                  _target.text.isEmpty) {
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
                                  Navigator.pop(context);
                                  dialogBox.information(
                                    context,
                                    'Status',
                                    'Service timed out',
                                  );
                                  return;
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
                visible: widget.newUser,
                child: SizedBox(height: height * .05),
              ),
              SizedBox(height: height * .02),
              widget.newUser
                  ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(
                        vertical: 10.h,
                        horizontal: 8.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(width * .02),
                      ),
                    ),
                    onPressed: () {
                      switch (widget.newUser) {
                        case true:
                          retire();
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
                            fontWeight: FontWeight.w500,
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
    if (_current.text.isEmpty || _target.text.isEmpty) {
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

  retire() async {
    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    FocusScope.of(context).requestFocus(FocusNode());
    if (_current.text.isEmpty || _target.text.isEmpty) {
      dialogBox.information(context, 'Status', 'Please fill all fields');
      return;
    }
    _showLoadingDialog("Loading");

    var url = "$baseUrl/app/360/retirement/roi";
    var url2 = "$baseUrl/app/360/retirement";
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );

    var response2 = await dio.get(
      url2,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    context.read<Providers>().setretiredata(response.data['data']);
    context.read<Providers>().setpensions(response2.data['data']);

    if (response.statusCode == 200 && response2.statusCode == 200) {
      _dismissLoadingDialog();
      timer.cancel();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Retiredash(),
        ),
      );
    }
  }

  save7G() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_current.text.isEmpty || _target.text.isEmpty) {
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

    try {
      var url = Uri.parse("$baseUrl/app/seveng");
      var urlAnalytics = Uri.parse('$baseUrl/app/seveng/edit');
      Map<String, dynamic> body = {
        "seveng": "x32shzaqwsbxbjmazajxbvvsuw3vx",
        "current": _current.text.replaceAll(',', ''),
        "target": _target.text.replaceAll(',', ''),
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
              var dataDashboard = jsonDecode(responseDashboard.body);
              context.read<Providers>().setAssistance(
                Map<String, dynamic>.from(dataDashboard['assistance'] ?? {}),
              );
              var analyticsData = jsonDecode(response4.body);
              var analyticsinfo = Analyticsinfo.fromJson(analyticsData["data"]);
              context.read<Providers>().setAnalyticsInfo(analyticsinfo);

              timer.cancel();
              _dismissLoadingDialog();

              // ONLY auto-navigate if this page was opened from a save flow
              if (widget.fromSave && mounted) {
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
                    fromSave: true, // Pass through to next page
                  );
                } else {
                  // If no next page, navigate to dashboard or show completion
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
          _dismissLoadingDialog();
          dialogBox.information(context, 'Error', 'An error occurred');
        }
      } else {
        timer.cancel();
        if (mounted) {
          _dismissLoadingDialog();
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
    // Try parsing the value to an integer
    int? intValuePercentage = int.tryParse(value);

    // Handle invalid values
    if (intValuePercentage == null ||
        intValuePercentage < 0 ||
        intValuePercentage > 100) {
      return Text(
        'Invalid Value: $value', // More descriptive error message
        style: TextStyle(
          fontSize: width * 0.04,
          fontWeight: FontWeight.w700,
          color: Colors.red, // Use red to indicate an error
        ),
      );
    }

    // Define gradient colors based on the percentage value
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

    // Return the ShaderMask with gradient text
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
          color: Colors.white, // This color will be overridden by the gradient
        ),
      ),
    );
  }

  Widget _buildHeader() {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: Color(0xff8B322C), width: 3),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * .03),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align the text to the left
              children: [
                Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xff8B322C),
                          Color(0xffC54C42),
                        ], // Gradient colors
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        'Freedom',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20.sp,
                          color: Colors
                              .white, // Required to make the gradient visible
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'A measure of your progress on your path to financial freedom',
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
      ],
    );
  }

  Widget _buildStatus(String value, String infoOnVal) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    return Column(
      children: [
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
                            radius: 18
                                .h, // Half of the original height/width (53.h / 2)
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
                            textAlign: TextAlign
                                .center, // Optional: Align text to center
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: widget.newUser,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * .02),
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
                    infoOnVal,
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
      ],
    );
  }
}
