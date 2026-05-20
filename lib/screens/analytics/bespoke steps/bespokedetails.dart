import 'dart:async';
import 'dart:convert';
import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/models/sevengeemodel.dart';
import 'package:GapHub/screens/360/accounts/cash/cashitem.dart';
import 'package:GapHub/screens/360/accounts/liabilities/liabilitydetails.dart';
import 'package:GapHub/screens/360/accounts/liabilities/liabilityitem.dart';
import 'package:GapHub/screens/registration/costoflivingcalc.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/strings.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../360/threesixty.dart';

class Bespokedetails extends StatefulWidget {
  final List currentBS;
  final List currentBS2;

  const Bespokedetails(this.currentBS, this.currentBS2, {super.key});
  @override
  _BespokedetailsState createState() => _BespokedetailsState();
}

class _BespokedetailsState extends State<Bespokedetails> {
  final TextEditingController _current = TextEditingController();
  final TextEditingController _target = TextEditingController();
  final TextEditingController _baseline = TextEditingController();
  final TextEditingController _strategy = TextEditingController();
  TextEditingController savingsdetails = TextEditingController();
  Dio dio = Dio();
  DialogBox dialogBox = DialogBox();
  var current;
  var id;
  var current2;
  final TextEditingController _statusController = TextEditingController();
  @override
  void initState() {
    super.initState();
    current = widget.currentBS[0];
    // _statusController.text = infoOnVal();
    id = widget.currentBS[0]["id"].toString();
    current2 = widget.currentBS2[0];
    _current.text = widget.currentBS[0]["current"].toString();
    // _currentDebt.text = widget.currentBS[0]["current"].toString();
    _target.text = widget.currentBS[0]["target"].toString();
    _baseline.text = widget.currentBS[0]["baseline"].toString();
    savingsdetails.text = widget.currentBS[0]["kpi_details"].toString();
    _strategy.text = widget.currentBS[0]["extra"] ?? "";
    print('savingsdetails:${savingsdetails.text}');
  }

  bool _isClicked = false;
  bool _isClickedPersonal = false;
  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currency = '';
    if (widget.currentBS[0]["account_currency"] == null) {
      currency = splitit(context.watch<Providers>().currency);
    } else {
      currency = splitit(widget.currentBS[0]["account_currency"]);
    }
    //String creditCurrent =
    //  context.watch<Providers>().analyticsinfo.credit["current"].toString();

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    var value = context.watch<Providers>().sevengeemodel.steps[3].toString();
    var intVal = int.parse(value);
    String infoOnVal() {
      if (intVal >= 0 && intVal <= 25) {
        return saveup;
      } else if (intVal >= 26 && intVal <= 50) {
        return saveup;
      } else if (intVal >= 51 && intVal <= 75) {
        return saveup;
      } else if (intVal >= 76 && intVal <= 99) {
        return saveup;
      } else if (intVal >= 100) {
        return saveup;
      }
      return '';
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: const [
          // TextButton(
          //   child: Text(
          //     "Update",
          //     style: TextStyle(
          //         fontWeight: FontWeight.w700,
          //         fontSize: width * .035,
          //         color: const Color(0xff009933)),
          //   ),
          // ),
        ],
      ),
      bottomNavigationBar: const BottomNav(1),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: width * .05,
            horizontal: width * .03,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Color(
                        int.parse(
                          "0xff${current2["bg"].toString().substring(1)}",
                        ),
                      ),
                      width: 3,
                    ),
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
                            shaderCallback: (bounds) {
                              String bgColor =
                                  current2["bg"] ??
                                  "#000000"; // Default to black if null
                              if (bgColor.startsWith("#")) {
                                bgColor = bgColor.substring(1);
                              }
                              return LinearGradient(
                                colors: [
                                  Color(int.parse("0xff$bgColor")),
                                  Color(int.parse("0xff$bgColor")),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds);
                            },
                            child: Text(
                              '${current["kpi_name"] ?? ""}', // Avoid null issues
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: width * 0.05,
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
                              current["bespoke_type"] == "saveup"
                                  ? "Saving Up Target"
                                  : "Debt Elimination Target",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: width * .035,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * .03),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isClicked = !_isClicked; // Toggle state on tap
                  });
                },
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
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * .03,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Status',
                                    style: TextStyle(
                                      fontSize: width * .04,
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
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * .02,
                            ),
                            child: Column(
                              children: [_buildValue(current2["value"], width)],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * .01),
                      Card(
                        elevation: 0,
                        color: Colors.white,
                        margin: EdgeInsets.symmetric(horizontal: width * .02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: const BorderSide(
                            color: Color(0xffD8D8D8),
                            width: 0.5,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * .03,
                          ),
                          child: Container(
                            color: Colors.white,
                            margin: EdgeInsets.all(width * .02),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  current["bespoke_type"] == "saveup"
                                      ? "Savings target details"
                                      : "Debt Elimination details",
                                  style: TextStyle(
                                    fontWeight: _isClicked
                                        ? FontWeight.w500
                                        : FontWeight.w700,
                                    color: _isClicked
                                        ? Colors.grey
                                        : Colors.black,
                                    fontSize: width * .04,
                                  ),
                                ),
                                TextField(
                                  enabled: _isClicked,
                                  controller: savingsdetails,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Outline your strategy clearly...',
                                    contentPadding: const EdgeInsets.all(8),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: BorderSide(
                                        color: _isClicked
                                            ? Colors.black
                                            : Colors
                                                  .transparent, // Dynamic border color
                                        width: _isClicked ? 1.0 : 0.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: const BorderSide(
                                        color: Colors
                                            .black, // Always blue when focused
                                        width: 1.0,
                                      ),
                                    ),
                                    border:
                                        InputBorder.none, // Keep default none
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: width * .035,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * .01),
                      if (_isClicked)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * .03,
                          ),
                          child: Row(
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
                                      fontSize: width * .035,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: width * .40,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Remove focus from any text field
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(FocusNode());
                                    dialogBox.waiting(context, 'Saving');

                                    var url = "$baseUrl/app/bespoke/$id";
                                    Map<String, dynamic> data = {
                                      "strategy": _strategy.text.isNotEmpty
                                          ? _strategy.text
                                          : "",
                                      "details": savingsdetails.text.isNotEmpty
                                          ? savingsdetails.text
                                          : "",
                                      "current": _current.text.isNotEmpty
                                          ? int.parse(_current.text)
                                          : 0,
                                      "baseline": _baseline.text.isNotEmpty
                                          ? int.parse(_baseline.text)
                                          : 0,
                                      "target": _target.text.isNotEmpty
                                          ? int.parse(_target.text)
                                          : 0,
                                      "bespoke":
                                          current["bespoke_type"] == "saveup"
                                          ? "samnbvsjhnbvsnhbvsnvsjhsvnxjhxnvhbnvx"
                                          : "dejhiojdnoijdnsnvhbnvxjhxnvsjhsvnxshyg",
                                    };

                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    String? token = prefs.getString('tokenDB');

                                    if (token != null) {
                                      try {
                                        var response = await dio.post(
                                          url,
                                          options: Options(
                                            headers: {
                                              "Authorization": 'Bearer $token',
                                              "Accept": "application/json",
                                            },
                                          ),
                                          data: data,
                                        );

                                        if (response.statusCode == 200) {
                                          var sevenGUrl = Uri.parse(
                                            '$baseUrl/app/seveng',
                                          );
                                          final response2 = await http.get(
                                            sevenGUrl,
                                            headers: {
                                              "Authorization": 'Bearer $token',
                                            },
                                          );

                                          if (response2.statusCode == 200) {
                                            Sevengeemodel sevengeemodel =
                                                Sevengeemodel.fromJson(
                                                  jsonDecode(response2.body),
                                                );
                                            context
                                                .read<Providers>()
                                                .setSevenGee(sevengeemodel);
                                            Fluttertoast.showToast(
                                              msg: 'Saved Successfully',
                                            );
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          } else {
                                            dialogBox.information(
                                              context,
                                              'Status',
                                              "An error occurred",
                                            );
                                            Navigator.pop(context);
                                          }
                                        } else {
                                          dialogBox.information(
                                            context,
                                            'Status',
                                            "An error occurred",
                                          );
                                          Navigator.pop(context);
                                        }
                                      } catch (e) {
                                        print(e.toString());
                                        dialogBox.information(
                                          context,
                                          'Status',
                                          "An error occurred",
                                        );
                                        Navigator.pop(context);
                                      }
                                    } else {
                                      // Handle the case when token is null
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                  ),
                                  child: Text(
                                    "Update",
                                    style: TextStyle(
                                      fontSize: width * .035,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: height * .02),
                    ],
                  ),
                ),
              ),
              current["bespoke_type"] == "saveup"
                  ? Column(
                      children: [
                        SizedBox(height: height * .02),
                        Fiforms(
                          width: width,
                          enabled: false,
                          height: height,
                          name: 'Current',
                          subtitle: 'The amount you have saved up',
                          controller: _current,
                          symbol: currency,
                        ),
                        SizedBox(height: height * .02),
                        Fiforms(
                          width: width,
                          enabled: false,
                          height: height,
                          name: 'Target',
                          subtitle: 'Your savings target',
                          controller: _target,
                          symbol: currency,
                        ),
                        SizedBox(height: height * .02),
                      ],
                    )
                  : Column(
                      children: [
                        SizedBox(height: height * .02),
                        Fiforms(
                          width: width,
                          enabled: false,
                          height: height,
                          name: 'Current',
                          subtitle: 'The amount you have saved up',
                          controller: _baseline,
                          symbol: currency,
                        ),
                        SizedBox(height: height * .04),
                        Fiforms(
                          width: width,
                          enabled: false,
                          height: height,
                          name: 'Target',
                          subtitle: 'Your savings target',
                          controller: _current,
                          symbol: currency,
                        ),
                        SizedBox(height: height * .03),
                      ],
                    ),
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
                  SizedBox(height: height * .0),
                  Text(
                    'Document your plan',
                    style: TextStyle(
                      color: const Color(0xff888888),
                      fontWeight: FontWeight.w400,
                      fontSize: width * .04,
                    ),
                  ),
                  SizedBox(height: height * .02),
                  Card(
                    elevation: 0,
                    color: AppColors.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: const BorderSide(
                        color: Color(0xffD8D8D8),
                        width: 0.5,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isClickedPersonal =
                              !_isClickedPersonal; // Toggle state on tap
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextFormField(
                            enabled: _isClickedPersonal,
                            style: TextStyle(fontSize: width * .04),
                            controller: _strategy,
                            maxLines: 6,
                            decoration: InputDecoration(
                              hintText: 'Outline your strategy clearly...',
                              contentPadding: const EdgeInsets.all(8),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: _isClickedPersonal
                                      ? Colors.black
                                      : Colors
                                            .transparent, // Dynamic border color
                                  width: _isClickedPersonal ? 2.0 : 0.0,
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
                  if (_isClickedPersonal)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * .03),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: width * .40,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isClickedPersonal = false; // Hide buttons
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: width * .035,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: width * .40,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Remove focus from any text field
                                FocusScope.of(
                                  context,
                                ).requestFocus(FocusNode());
                                dialogBox.waiting(context, 'Saving');

                                var url = "$baseUrl/app/bespoke/$id";
                                Map<String, dynamic> data = {
                                  "strategy": _strategy.text.isNotEmpty
                                      ? _strategy.text
                                      : "",
                                  "details": savingsdetails.text.isNotEmpty
                                      ? savingsdetails.text
                                      : "",
                                  "current": _current.text.isNotEmpty
                                      ? int.parse(_current.text)
                                      : 0,
                                  "baseline": _baseline.text.isNotEmpty
                                      ? int.parse(_baseline.text)
                                      : 0,
                                  "target": _target.text.isNotEmpty
                                      ? int.parse(_target.text)
                                      : 0,
                                  "bespoke": current["bespoke_type"] == "saveup"
                                      ? "samnbvsjhnbvsnhbvsnvsjhsvnxjhxnvhbnvx"
                                      : "dejhiojdnoijdnsnvhbnvxjhxnvsjhsvnxshyg",
                                };

                                final prefs =
                                    await SharedPreferences.getInstance();
                                String? token = prefs.getString('tokenDB');

                                if (token != null) {
                                  try {
                                    var response = await dio.post(
                                      url,
                                      options: Options(
                                        headers: {
                                          "Authorization": 'Bearer $token',
                                          "Accept": "application/json",
                                        },
                                      ),
                                      data: data,
                                    );

                                    if (response.statusCode == 200) {
                                      var sevenGUrl = Uri.parse(
                                        '$baseUrl/app/seveng',
                                      );
                                      final response2 = await http.get(
                                        sevenGUrl,
                                        headers: {
                                          "Authorization": 'Bearer $token',
                                        },
                                      );

                                      if (response2.statusCode == 200) {
                                        Sevengeemodel sevengeemodel =
                                            Sevengeemodel.fromJson(
                                              jsonDecode(response2.body),
                                            );
                                        context.read<Providers>().setSevenGee(
                                          sevengeemodel,
                                        );
                                        Fluttertoast.showToast(
                                          msg: 'Saved Successfully',
                                        );
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      } else {
                                        dialogBox.information(
                                          context,
                                          'Status',
                                          "An error occurred",
                                        );
                                        Navigator.pop(context);
                                      }
                                    } else {
                                      dialogBox.information(
                                        context,
                                        'Status',
                                        "An error occurred",
                                      );
                                      Navigator.pop(context);
                                    }
                                  } catch (e) {
                                    print(e.toString());
                                    dialogBox.information(
                                      context,
                                      'Status',
                                      "An error occurred",
                                    );
                                    Navigator.pop(context);
                                  }
                                } else {
                                  // Handle the case when token is null
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                              ),
                              child: Text(
                                "Update",
                                style: TextStyle(
                                  fontSize: width * .035,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: height * .04),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    AppColors.primaryColor,
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(
                      horizontal: 12.w, // Reduced horizontal padding
                      vertical: 8.h, // Reduced vertical padding
                    ),
                  ),
                  minimumSize: WidgetStateProperty.all(
                    Size.zero,
                  ), // Removes minimum size constraints
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  current["bespoke_type"] == "saveup" ? cash() : liability();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        fontWeight: FontWeight.w400,
                        fontSize: width * .04,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  cash() async {
    dialogBox.waiting(context, "Loading");

    var url = "$baseUrl/app/360/cash";
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      List mapList = response.data["cash"];
      List bespokes = response.data["bespokes"];

      Navigator.pop(context);
      // Navigator.pop(context);

      int index =
          bespokes.indexWhere(
                (element) => element["id"].toString() == id.toString(),
              ) ==
              -1
          ? mapList.indexWhere(
              (element) => element["id"].toString() == id.toString(),
            )
          : bespokes.indexWhere(
              (element) => element["id"].toString() == id.toString(),
            );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Cashitem(
            item:
                bespokes.indexWhere(
                      (element) => element["id"].toString() == id.toString(),
                    ) ==
                    -1
                ? mapList[index]
                : bespokes[index],
            seven: false,
            bespokes: true,
          ),
        ),
      );
    }
  }

  liabilityy() async {
    dialogBox.waiting(context, "Loading");
    var url = "$baseUrl/app/360/liability";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      var mapList = response.data["liabilities"];

      var seveng = response.data["seveng"];
      var bespokes = response.data["bespokes"];

      num total = 0;
      List real = [];
      if (seveng.isNotEmpty) {
        var a = seveng.map((e) => e["current"]).toList();

        for (var item in a) {
          real.add(int.parse(item.toString()));
        }

        for (var item in a) {
          total = total + item;
        }
      }
      Navigator.pop(context);
      // Navigator.pop(context);

      int index =
          bespokes.indexWhere(
                (element) => element["id"].toString() == id.toString(),
              ) ==
              -1
          ? mapList.indexWhere(
              (element) => element["id"].toString() == id.toString(),
            )
          : bespokes.indexWhere(
              (element) => element["id"].toString() == id.toString(),
            );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Liabilityitem(
            item:
                bespokes.indexWhere(
                      (element) => element["id"].toString() == id.toString(),
                    ) ==
                    -1
                ? mapList[index]
                : bespokes[index],
            seven: false,
            bespokes: true,
          ),
        ),
      );
    }
  }

  liability() async {
    var timer = Timer(const Duration(seconds: 20), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, "Loading");
    var url2 = Uri.parse('$baseUrl/app/seveng/edit');
    var url = "$baseUrl/app/360/liability";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    var response2 = await http.get(
      url2,
      headers: {"Authorization": 'Bearer $token'},
    );

    if (response.statusCode == 200 && response2.statusCode == 200) {
      List mapList = response.data["liabilities"];
      // print("mapList:$mapList");
      var mapListLite = response.data["liabilities_detail"];
      List seveng = response.data["seveng"];
      var bespokes = response.data["bespokes"];
      var isAllocated = response.data["audit"]["is_allocated"];
      var creditCurrent = "0";
      var cc = jsonDecode(response2.body);
      Analyticsinfo analyticsinfo = Analyticsinfo.fromJson(cc["data"]);
      creditCurrent = analyticsinfo.credit!["current"].toString();
      num total = 0;
      List real = [];
      if (seveng.isNotEmpty) {
        List<num> a = seveng
            .map((e) => num.parse(e["current"].toString()))
            .toList();

        for (var item in a) {
          real.add(int.parse(item.toString()));
        }
        for (var item in a) {
          total = total + item;
        }
      }
      Navigator.pop(context);
      timer.cancel();

      if (isAllocated.toString() == "1") {
        timer.cancel();
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Liabilitydetails(
              liabilityData: mapList,
              liabilityDataLite: mapListLite,
              seveng: seveng,
              bespokes: bespokes,
            ),
          ),
        );
      } else if (int.parse(creditCurrent.toString()) == 0) {
        timer.cancel();
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Liabilitydetails(
              liabilityData: mapList,
              liabilityDataLite: mapListLite,
              seveng: seveng,
              bespokes: bespokes,
            ),
          ),
        );
      } else if (total != int.parse(creditCurrent.toString())) {
        timer.cancel();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Threesixty(
              unallocated: true,
              data: seveng,
              balance: seveng.isEmpty
                  ? int.parse(creditCurrent)
                  : (int.parse(creditCurrent) - total).toInt(),
            ),
          ),
        );
      } else {
        Navigator.pop(context);
        // print("mapList:$mapList");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Liabilitydetails(
              liabilityData: mapList,
              liabilityDataLite: mapListLite,
              seveng: seveng,
              bespokes: bespokes,
            ),
          ),
        );
      }
    }
    timer.cancel();
  }

  Widget _buildValue(String value, double width) {
    int? intValue = int.tryParse(value); // Convert value to int safely

    if (intValue == null) {
      return Text(
        'Invalid Value', // Handle cases where conversion fails
        style: TextStyle(fontSize: width * 0.04, fontWeight: FontWeight.w700),
      );
    }

    Color startColor;
    Color endColor;

    if (intValue >= 1 && intValue <= 25) {
      startColor = const Color(0xffFF0001);
      endColor = const Color(0xffCE0001);
    } else if (intValue >= 26 && intValue <= 50) {
      startColor = const Color(0xffF6AE39);
      endColor = const Color(0xffFF7A00);
    } else if (intValue >= 51 && intValue <= 75) {
      startColor = const Color(0xff005E32);
      endColor = const Color(0xff17B26A);
    } else {
      startColor = const Color(0xff005E77);
      endColor = const Color(0xff002E77);
    }

    return Row(
      children: [
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Text(
            '$intValue%',
            style: TextStyle(
              fontSize: width * 0.04,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
