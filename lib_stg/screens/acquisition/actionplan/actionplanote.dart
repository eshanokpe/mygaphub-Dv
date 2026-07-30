import 'dart:async';
import 'dart:convert';
import 'package:GapHub/models/actionplanserver.dart';
import 'package:GapHub/models/remindermodel.dart';
import 'package:GapHub/screens/acquisition/actionplan/seeplan.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Actionplanote extends StatefulWidget {
  final String assetType;
  final Todayplanserver todayplan;
  const Actionplanote({
    super.key,
    required this.assetType,
    required this.todayplan,
  });

  @override
  _ActionplanoteState createState() => _ActionplanoteState();
}

class _ActionplanoteState extends State<Actionplanote> {
  final TextEditingController _note = TextEditingController();
  DialogBox dialogBox = DialogBox();
  bool update = false;

  getFeed() {
    switch (widget.assetType) {
      case 'Business Asset':
        _note.text = widget.todayplan.business["note"] ?? "";
        setState(() {
          update = true;
        });
        break;
      case 'Risk Asset':
        _note.text = widget.todayplan.risk["note"] ?? "";
        setState(() {
          update = true;
        });
        break;
      case 'Appreciating Asset':
        _note.text = widget.todayplan.appreciating["note"] ?? "";
        setState(() {
          update = true;
        });
        break;
      case 'Intellectual Asset':
        _note.text = widget.todayplan.intellectual["note"] ?? "";
        setState(() {
          update = true;
        });
        break;
      case 'Depreciating Asset':
        _note.text = widget.todayplan.depreciating["note"] ?? "";
        setState(() {
          update = true;
        });
        break;
      default:
    }
  }

  @override
  void initState() {
    super.initState();
    getFeed();
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
      appBar: AppBar(
        title: Text(
          widget.assetType,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: width * .035),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNav(2),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * .02,
            vertical: height * .02,
          ),
          child: Column(
            children: [
              SizedBox(height: height * .02),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Action Plan & Personal Strategy Note:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: width * .05,
                  ),
                ),
              ),
              SizedBox(height: height * .01),
              TextFormField(
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: width * .04,
                ),
                keyboardType: TextInputType.text,
                maxLines: 10,
                controller: _note,
                decoration: InputDecoration(
                  labelText: 'Please start typing here...',
                  alignLabelWithHint: true,
                  labelStyle: TextStyle(color: Colors.black.withOpacity(.5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(width * .03),
                  ),
                ),
              ),
              SizedBox(height: height * .03),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * .03),
                    ),
                  ),
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(FocusNode());

                    if (_note.text.isEmpty) {
                      dialogBox.information(
                        context,
                        'Status',
                        'Please fill up all the fields',
                      );
                      return;
                    }
                    if (_note.text.length < 10) {
                      dialogBox.information(
                        context,
                        'Status',
                        'The note should be at least 10 characters',
                      );
                      return;
                    }
                    switch (widget.assetType) {
                      case "Business Asset":
                        EasyLoading.show(status: 'Saving', dismissOnTap: false);
                        var url = Uri.parse("$baseUrl/app/actionplan");

                        Map<String, dynamic> body = {
                          "action": "vafgskgkzhskdfgzkgzkfgx",
                          "note": _note.text,
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
                        if (response.statusCode == 200) {
                          EasyLoading.dismiss();
                          Fluttertoast.showToast(
                            msg: 'Action plan saved',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                        } else {
                          EasyLoading.dismiss();
                          dialogBox.information(
                            context,
                            "Status",
                            'Failed to save',
                          );
                        }
                        break;
                      case "Risk Asset":
                        EasyLoading.show(status: 'Saving', dismissOnTap: false);
                        var url = Uri.parse("$baseUrl/app/actionplan");

                        Map<String, dynamic> body = {
                          "action": "apwgdhsvjxgsdgkgdxbgdcg",
                          "note": _note.text,
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

                        if (response.statusCode == 200) {
                          EasyLoading.dismiss();
                          Fluttertoast.showToast(
                            msg: 'Action plan saved',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                        } else {
                          EasyLoading.dismiss();
                          dialogBox.information(
                            context,
                            "Status",
                            'Failed to save',
                          );
                        }
                        break;
                      case "Appreciating Asset":
                        EasyLoading.show(status: 'Saving', dismissOnTap: false);
                        var url = Uri.parse("$baseUrl/app/actionplan");

                        Map<String, dynamic> body = {
                          "action": "ingtfsjvfejafdkshcvsxgcfsd",
                          "note": _note.text,
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
                        if (response.statusCode == 200) {
                          EasyLoading.dismiss();

                          Fluttertoast.showToast(
                            msg: 'Action plan saved',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                        } else {
                          EasyLoading.dismiss();
                          dialogBox.information(
                            context,
                            "Status",
                            'Failed to save',
                          );
                        }
                        break;
                      case "Intellectual Asset":
                        EasyLoading.show(status: 'Saving', dismissOnTap: false);

                        var url = Uri.parse("$baseUrl/app/actionplan");

                        Map<String, dynamic> body = {
                          "action": "dehnspeabwrtindgozid",
                          "note": _note.text,
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
                        if (response.statusCode == 200) {
                          EasyLoading.dismiss();
                          Fluttertoast.showToast(
                            msg: 'Action plan saved',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                        } else {
                          EasyLoading.dismiss();
                          dialogBox.information(
                            context,
                            "Status",
                            'Failed to save',
                          );
                        }
                        break;
                      case "Depreciating Asset":
                        EasyLoading.show(status: 'Saving', dismissOnTap: false);

                        var url = Uri.parse("$baseUrl/app/actionplan");

                        Map<String, dynamic> body = {
                          "action": "asfshjsgvnbxsgbbsnndepljn",
                          "note": _note.text,
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

                        if (response.statusCode == 200) {
                          EasyLoading.dismiss();
                          Fluttertoast.showToast(
                            msg: 'Action plan saved',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                        } else {
                          EasyLoading.dismiss();
                          dialogBox.information(
                            context,
                            "Status",
                            "Failed to save",
                          );
                        }
                        break;

                      default:
                        Fluttertoast.showToast(
                          msg: 'Error saving action plan',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                        );
                    }
                    // Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.zero,
                    height: height * .045,
                    width: width * .2,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        update ? 'Update' : 'Save',
                        style: TextStyle(
                          color: const Color(0xfff3f3f4),
                          fontWeight: FontWeight.w500,
                          fontSize: width * .05,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * .05),
              TextButton(
                onPressed: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  getactionp();
                },
                child: Text(
                  'See your notes',
                  style: TextStyle(
                    fontSize: width * .05,
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getactionp() async {
    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    try {
      EasyLoading.show(status: 'Loading', dismissOnTap: false);
      var urlActionPlan = Uri.parse("$baseUrl/app/actionplan");
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');
      final response = await http.get(
        urlActionPlan,
        headers: {"Authorization": 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        Actionplanserver actionplanserver = Actionplanserver.fromJson(
          jsonDecode(response.body),
        );

        var whatiwantB = actionplanserver.business;
        if (whatiwantB.isNotEmpty) {
          context.read<Providers>().popActionPlanB();
          for (var i = 0; i < whatiwantB.length; i++) {
            context.read<Providers>().addActionPlanB(
              Actionplanmodel(
                date: whatiwantB[i]["date"],
                note: whatiwantB[i]["note"],
              ),
            );
          }
        }

        var whatiwantR = actionplanserver.risk;
        if (whatiwantR.isNotEmpty) {
          context.read<Providers>().popActionPlanR();
          for (var i = 0; i < whatiwantR.length; i++) {
            context.read<Providers>().addActionPlanR(
              Actionplanmodel(
                date: whatiwantR[i]["date"],
                note: whatiwantR[i]["note"],
              ),
            );
          }
        }

        var whatiwantA = actionplanserver.appreciating;
        if (whatiwantA.isNotEmpty) {
          context.read<Providers>().popActionPlanA();
          for (var i = 0; i < whatiwantA.length; i++) {
            context.read<Providers>().addActionPlanA(
              Actionplanmodel(
                date: whatiwantA[i]["date"],
                note: whatiwantA[i]["note"],
              ),
            );
          }
        }

        var whatiwantI = actionplanserver.intellectual;
        if (whatiwantI.isNotEmpty) {
          context.read<Providers>().popActionPlanI();
          for (var i = 0; i < whatiwantI.length; i++) {
            context.read<Providers>().addActionPlanI(
              Actionplanmodel(
                date: whatiwantI[i]["date"],
                note: whatiwantI[i]["note"],
              ),
            );
          }
        }

        var whatiwantD = actionplanserver.depreciating;
        if (whatiwantD.isNotEmpty) {
          context.read<Providers>().popActionPlanD();
          for (var i = 0; i < whatiwantD.length; i++) {
            context.read<Providers>().addActionPlanD(
              Actionplanmodel(
                date: whatiwantD[i]["date"],
                note: whatiwantD[i]["note"],
              ),
            );
          }
        }
        switch (widget.assetType) {
          case "Business Asset":
            EasyLoading.dismiss();
            timer.cancel();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Seeplan(
                  assetType: widget.assetType,
                  actionPlanList: context.watch<Providers>().actionPlanListB,
                ),
              ),
            );
            break;
          case "Risk Asset":
            EasyLoading.dismiss();
            timer.cancel();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Seeplan(
                  assetType: widget.assetType,
                  actionPlanList: context.watch<Providers>().actionPlanListR,
                ),
              ),
            );
            break;
          case "Appreciating Asset":
            EasyLoading.dismiss();
            timer.cancel();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Seeplan(
                  assetType: widget.assetType,
                  actionPlanList: context.watch<Providers>().actionPlanListA,
                ),
              ),
            );
            break;
          case "Intellectual Asset":
            EasyLoading.dismiss();
            timer.cancel();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Seeplan(
                  assetType: widget.assetType,
                  actionPlanList: context.watch<Providers>().actionPlanListI,
                ),
              ),
            );
            break;
          case "Depreciating Asset":
            EasyLoading.dismiss();
            timer.cancel();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Seeplan(
                  assetType: widget.assetType,
                  actionPlanList: context.watch<Providers>().actionPlanListD,
                ),
              ),
            );
            break;

          default:
            timer.cancel();
            EasyLoading.dismiss();
        }
      } else {
        timer.cancel();
        EasyLoading.dismiss();
        dialogBox.information(context, 'Error', 'An error occured');
      }
    } catch (e) {
      timer.cancel();
      EasyLoading.dismiss();
      dialogBox.information(context, 'Error', 'An error occured');
    }
  }
}
