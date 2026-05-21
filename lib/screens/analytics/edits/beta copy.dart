import 'dart:async';
import 'dart:convert';
import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/screens/360/accounts/cash/cashitem.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/utils/strings.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/spaces.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/models/sevengeemodel.dart';
import 'package:GapHub/utils/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:GapHub/screens/registration/costoflivingcalc.dart';

class Beta extends StatefulWidget {
  final Analyticsinfo betaInfo;
  final bool newUser;
  final bool contains;

  Beta({this.betaInfo, this.newUser, this.contains});
  @override
  _BetaState createState() => _BetaState();
}

class _BetaState extends State<Beta> {
  var _key = GlobalKey<FormState>();
  TextEditingController _current = TextEditingController();
  TextEditingController _target = TextEditingController();
  TextEditingController _strategy = TextEditingController();
  DialogBox dialogBox = DialogBox();
  Dio dio = Dio();
  bool check = false;
  @override
  void initState() {
    super.initState();
    if (widget.betaInfo.beta['current'] != null) {
      _current.text = widget.betaInfo.beta['current'].toString();
    }
    if (widget.betaInfo.beta['target'] != null) {
      _target.text = widget.betaInfo.beta['target'].toString();
    }
    if (widget.betaInfo.beta['strategy'] != null) {
      _strategy.text = widget.betaInfo.beta['strategy'].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    var value = context.watch<Providers>().sevengeemodel.steps[5].toString();
    var intVal = int.parse(value);
    String infoOnVal() {
      if (intVal >= 0 && intVal <= 25) {
        return beta1;
      } else if (intVal >= 26 && intVal <= 50) {
        return beta2;
      } else if (intVal >= 51 && intVal <= 75) {
        return beta3;
      } else if (intVal >= 76 && intVal <= 99) {
        return beta4;
      } else if (intVal >= 100) {
        return beta5;
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
    var currency = context.watch<Providers>().snapshotmodel.currency;

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Beta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNav(1),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: width * .05, horizontal: width * .02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: width * .04),
                    children: [
                      TextSpan(
                          text: 'Beta ',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: width * .05)),
                      TextSpan(
                          text:
                              '(A measure of your house purchase funds saved up)')
                    ]),
              ),
              Form(
                child: Column(
                  children: [
                    SizedBox(
                      height: height * .03,
                    ),
                    Fiforms(
                        width: width,
                        height: height,
                        enabled: widget.newUser,
                        name: 'Current (House purchase savings today)',
                        controller: _current,
                        symbol: currency),
                    SizedBox(
                      height: height * .05,
                      child: Divider(
                        color: Theme.of(context).primaryColor,
                        height: 20,
                      ),
                    ),
                    Fiforms(
                        width: width,
                        height: height,
                        enabled: widget.newUser,
                        name: 'Target (House purchase deposit and other costs)',
                        controller: _target,
                        symbol: currency),
                    SizedBox(
                      height: height * .04,
                      child: Divider(
                        color: Theme.of(context).primaryColor,
                        height: 20,
                      ),
                    ),
                  ],
                ),
                key: _key,
              ),
              Visibility(
                visible: widget.newUser,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("I already bought my home",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: width * .045)),
                    Checkbox(
                        value: check,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (bool value) {
                          setState(() {
                            check = value;
                          });
                        })
                  ],
                ),
              ),
              SizedBox(
                height: height * .05,
              ),
              Visibility(
                visible: !widget.newUser,
                child: Column(
                  children: [
                    RichText(
                        text: TextSpan(
                            style: TextStyle(
                                fontSize: width * .06,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).accentColor),
                            children: [
                          TextSpan(text: 'STATUS: '),
                          TextSpan(
                              text: '$value%',
                              style: TextStyle(color: Color(realColors[5])))
                        ])),
                    SizedBox(
                      height: height * .05,
                    ),
                    Container(
                      padding: EdgeInsets.all(width * .03),
                      color: Color(0xffEFEFEF),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Comments / Suggestions:',
                              style: TextStyle(
                                  fontSize: width * .05,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor)),
                          Text(
                            '${infoOnVal()}',
                            style: TextStyle(
                              fontSize: width * .04,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * .04,
                    ),
                    RichText(
                      text: TextSpan(
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: width * .05,
                              fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(text: 'Personal Strategy '),
                            TextSpan(
                                text: '(document your plan below):',
                                style: TextStyle(fontSize: width * .03))
                          ]),
                    ),
                    SizedBox(
                      height: height * .02,
                    ),
                    Card(
                      elevation: 15,
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextFormField(
                              style: TextStyle(fontSize: width * .04),
                              maxLines: 10,
                              controller: _strategy,
                              decoration: InputDecoration(
                                  hintText: 'Document your plan',
                                  contentPadding: EdgeInsets.all(8)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      primary: Theme.of(context).primaryColor,
                                    ),
                                    onPressed: () {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                      if (_current.text.isEmpty ||
                                          _target.text.isEmpty) {
                                        dialogBox.information(context, 'Status',
                                            'Please fill all fields');
                                        return;
                                      }
                                      dialogBox.waiting(context, 'Saving');
                                      var timer = Timer(
                                          Duration(milliseconds: 30000), () {
                                        Navigator.pop(context);
                                        dialogBox.information(context, 'Status',
                                            'Service timed out');
                                        return;
                                      });

                                      try {
                                        save7G();
                                        timer.cancel();
                                      } catch (e) {
                                        Navigator.pop(context);
                                        timer.cancel();
                                        dialogBox.information(context, 'Status',
                                            'Error saving details');
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.zero,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text('Continue',
                                            style: TextStyle(
                                              color: Color(0xfff3f3f4),
                                              fontWeight: FontWeight.w400,
                                              fontSize: width * .04,
                                            )),
                                      ),
                                    )),
                                SizedBox(
                                  width: width * .01,
                                ),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                      ),
                                    ))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: !widget.newUser,
                child: SizedBox(
                  height: height * .05,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                ),
                onPressed: () {
                  switch (widget.newUser) {
                    case true:
                      FocusScope.of(context).requestFocus(FocusNode());
                      if ((_current.text.isEmpty ||
                              _current.text == "0" ||
                              _target.text == "0" ||
                              _target.text.isEmpty) &&
                          !check) {
                        dialogBox.information(
                            context, 'Status', 'Please fill all fields');
                        return;
                      }
                      dialogBox.waiting(context, 'Saving');
                      var timer = Timer(Duration(milliseconds: 30000), () {
                        Navigator.pop(context);
                        dialogBox.information(
                            context, 'Status', 'Service timed out');
                        return;
                      });
                      try {
                        save7G();
                        timer.cancel();
                      } catch (e) {
                        Navigator.pop(context);
                        dialogBox.information(
                            context, 'Status', 'Error saving details');
                        timer.cancel();
                      }
                      break;
                    case false:
                      widget.contains ? fuck() : cash();
                      break;
                    default:
                  }
                },
                child: Text(
                    widget.newUser || widget.contains ? "Save" : "View More",
                    style: TextStyle(
                      color: Color(0xfff3f3f4),
                      fontWeight: FontWeight.w400,
                      fontSize: width * .04,
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  fuck() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_current.text.isEmpty || _target.text.isEmpty) {
      dialogBox.information(context, 'Status', 'Please fill all fields');
      return;
    }
    dialogBox.waiting(context, 'Saving');
    var timer = Timer(Duration(milliseconds: 30000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    try {
      save7G();
      timer.cancel();
    } catch (e) {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Error saving details');
      timer.cancel();
    }
  }

  cash() async {
    if (_current.text.isEmpty || _target.text.isEmpty) {
      dialogBox.information(context, 'Status', 'Please fill all fields');
      return;
    }
    var timer = Timer(Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    FocusScope.of(context).requestFocus(FocusNode());

    dialogBox.waiting(context, "Loading");

    var url = "$baseUrl/app/360/cash";
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(url,
        options: Options(headers: {"Authorization": 'Bearer $token'}));
    if (response.statusCode == 200) {
      var seveng = response.data["seveng"];
      Navigator.pop(context);
      timer.cancel();
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                Cashitem(item: seveng[1], seven: true, bespokes: false),
          ));
    }
  }

  save7G() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if ((_current.text.isEmpty || _target.text.isEmpty) && !check) {
      dialogBox.information(context, 'Status', 'Please fill all fields');
      return;
    }
    var timer = Timer(Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });

    try {
      var _url = "$baseUrl/app/seveng";
      Map<String, dynamic> body = {};
      check
          ? body = {
              "purchase": "1",
              "seveng": "aqgndshsvdhsejdoksbxdvxsgd",
              "current": "0",
              "target": "0"
            }
          : body = {
              "seveng": "aqgndshsvdhsejdoksbxdvxsgd",
              "current": _current.text,
              "target": _target.text,
              "strategy": _strategy.text,
              "main": "1",
            };

      final prefs = await SharedPreferences.getInstance();

      var token = prefs.getString('tokenDB');

      var response = await http.post(_url,
          body: body,
          headers: {
            "Authorization": 'Bearer $token',
            "Content-Type": "application/x-www-form-urlencoded"
          },
          encoding: Encoding.getByName("utf-8"));
      // print(response.body);

      if (response.statusCode == 200) {
        String _url7G = '$baseUrl/app/seveng';

        final prefs = await SharedPreferences.getInstance();
        var finalToken = prefs.getString('tokenDB');

        final response2 = await http
            .get(_url7G, headers: {"Authorization": 'Bearer $finalToken'});
        Sevengeemodel sevengeemodel =
            Sevengeemodel.fromJson(jsonDecode(response2.body));
        if (response2.statusCode == 200) {
          context.read<Providers>().setSevenGee(sevengeemodel);
          timer.cancel();
          Navigator.pop(context);
          Navigator.pop(context);
          return null;
        } else {
          timer.cancel();
          Navigator.pop(context);
          dialogBox.information(context, 'Error', 'An error ocurred');
        }
      } else {
        timer.cancel();
        Navigator.pop(context);
        dialogBox.information(context, 'Error', 'An error ocurred');
      }
    } catch (e) {
      timer.cancel();
      Navigator.pop(context);
      dialogBox.information(context, 'Error', 'An error ocurred');
    }
  }
}