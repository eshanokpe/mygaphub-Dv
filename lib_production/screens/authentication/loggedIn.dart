import 'dart:async';
import 'dart:convert';
import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/models/loginusermodel.dart';
import 'package:GapHub/models/sevengeemodel.dart';
import 'package:GapHub/models/snapshotmodel.dart';
import 'package:GapHub/screens/others/dashboards/dashboard.dart';
import 'package:GapHub/screens/registration/calculation/precalc.dart';
import 'package:GapHub/screens/registration/financial_health/prequestions.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class LoggedIn extends StatefulWidget {
  final fromAppLink;

  const LoggedIn({super.key, this.fromAppLink = false});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoggedIn> {
  TextEditingController emailCon = TextEditingController();
  TextEditingController passCon = TextEditingController();
  bool visible = true;
  DialogBox dialogBox = DialogBox();
  bool onfield = true;
  int keyint = 0;
  bool isChanging = true;
  Dio dio = Dio();
  late FocusNode pnode, enode;
  late final String fromAppLink;
  // _LoginState({this.fromAppLink});

  @override
  void initState() {
    super.initState();
    enode = FocusNode();
    pnode = FocusNode();
    fromAppLink = widget.fromAppLink;
    signIn();
    // final newVersion = NewVersion(
    //   context: context,
    // );
    // newVersion.showAlertIfNecessary();
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        isChanging = false;
      });
    });
  }

  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    pop() {
      SystemNavigator.pop();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Prequestions()),
      );
    }

    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          return dialogBox.options(
            context,
            'Close',
            'Are you sure you want to exit? ',
            pop,
          );
        },
        child: SingleChildScrollView(
          child: Container(
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[],
            ),
          ),
        ),
      ),
    );
  }

  signIn() async {
    // var _urLogin = Uri.parse("$baseUrl/mygap/login");
    var urlDetails = Uri.parse("$baseUrl/user");
    var url7G = Uri.parse('$baseUrl/app/seveng');
    var urlEditDetails = Uri.parse("$baseUrl/app/profile");
    var urlr = Uri.parse("$baseUrl/app/360/tiles");
    var url = Uri.parse("$baseUrl/app/portfolio");
    var urlEdit = Uri.parse('$baseUrl/app/seveng/edit');
    var urld = "$baseUrl/app/dashboard";
    var urlSnapshot = Uri.parse('$baseUrl/app/snapshot');
    final urlSupport = Uri.parse("$baseUrl/app/support");

    final prefs = await SharedPreferences.getInstance();
    final finalToken = prefs.getString("tokenDB");
    print("finalToken:$finalToken");

    //request 2
    final response2 = await http.get(
      urlDetails,
      headers: {"Authorization": 'Bearer $finalToken'},
    );
    if (response2.statusCode == 200 || response2.statusCode == 201) {
      // context.read<AcquisitionProvider>();

      Map<String, dynamic> resposne = jsonDecode(response2.body);
      Map<String, dynamic> user = resposne;
      print(" User id ${user["id"]}");
      print(" User firstname ${user["firstname"]}");
      print(" User surname ${user["surname"]}");
      print(" User email ${user["email"]}");
      Loginusermodel loginusermodel = Loginusermodel.fromJson(
        jsonDecode(response2.body),
      );
      context.read<Providers>().setLoginDetails(loginusermodel);
      context.read<Providers>().seToken(finalToken!);
      int value = 0;
      await prefs.setString('tokenDB', finalToken);
      await prefs.setInt("value", value);
      await prefs.setString("id", "${user["id"]}");
      await prefs.setString("firstname", "${user["firstname"]}");
      await prefs.setString("surname", "${user["surname"]}");
      await prefs.setString("email", "${user["email"]}");
      await prefs.setString('tokenDB', finalToken);
      context.read<Providers>().setDetailsList(loginusermodel.firstname!, 0);
      context.read<Providers>().setDetailsList(loginusermodel.surname!, 1);
      context.read<Providers>().setDetailsList(loginusermodel.email!, 2);

      //response3
      final responseDetails = await http.get(
        urlEditDetails,
        headers: {
          "Authorization": 'Bearer $finalToken',
          "Accept": "application/json",
        },
      );

      if (responseDetails.statusCode == 200 ||
          responseDetails.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(
          responseDetails.body,
        );
        Editdetails editdetails = Editdetails.fromJson(responseBody);

        context.read<Providers>().setDetailsList(
          editdetails.user["firstname"].toString(),
          0,
        );
        context.read<Providers>().setDetailsList(
          editdetails.user["surname"].toString(),
          1,
        );
        context.read<Providers>().setDetailsList(
          editdetails.user["email"].toString(),
          2,
        );
        context.read<Providers>().setDetailsList(
          editdetails.user["profile"]["phone"].toString(),
          3,
        );
        context.read<Providers>().setDetailsList(
          editdetails.user["profile"]["date_of_birth"].toString(),
          4,
        );
        context.read<Providers>().setDetailsList(
          editdetails.user["profile"]["ancesry"].toString(),
          5,
        );
        context.read<Providers>().setDetailsList(
          editdetails.user["profile"]["country"].toString(),
          6,
        );
        String imgurl = editdetails.user["profile"]["image"];
        if (imgurl.length >= 6) {
          imgurl = imgurl.replaceRange(0, 6, 'assets/storage');
          imgurl = '$imgPrefix/$imgurl';
        }

        context.read<Providers>().setDetailsList(imgurl, 7);
        context.read<Providers>().setDetailsList(
          editdetails.user["profile"]["dob_count"].toString(),
          8,
        );
        context.read<Providers>().setDetailsList(
          editdetails.user["created_at"].toString(),
          9,
        );
        context.read<Providers>().setDetailsList(
          editdetails.user["profile"]["dob_count"].toString(),
          8,
        );
        final supportResponse = await http.get(
          urlSupport,
          headers: {"Authorization": 'Bearer $finalToken'},
        );

        //response3
        final response3 = await http.get(
          urlSnapshot,
          headers: {"Authorization": 'Bearer $finalToken'},
        );
        if (response3.statusCode == 200 || response3.statusCode == 201) {
          Snapshotmodel snapshotmodel = Snapshotmodel.fromJson(
            jsonDecode(response3.body),
          );
          final bodySupport = jsonDecode(supportResponse.body);
          final dataSupport = bodySupport['data']['gap_supports']['data'];
          print("dataSupport:$dataSupport");
          context.read<Providers>().setSupport(dataSupport);
          context.read<Providers>().setSnapshot(snapshotmodel);
          context.read<Providers>().setCurrentPortfolio(
            snapshotmodel.financial["portfolio"],
          );

          //response4
          final response4 = await http.get(
            url7G,
            headers: {"Authorization": 'Bearer $finalToken'},
          );
          if (response4.statusCode == 200 || response4.statusCode == 201) {
            Sevengeemodel sevengeemodel = Sevengeemodel.fromJson(
              jsonDecode(response4.body),
            );
            context.read<Providers>().setSevenGee(sevengeemodel);
            //response5
            var response5 = await http.get(
              url,
              headers: {"Authorization": 'Bearer $finalToken'},
            );
            if (response5.statusCode == 200 || response5.statusCode == 201) {
              context.read<Providers>().setPortfolio(
                jsonDecode(response5.body),
              );
              var port = jsonDecode(response5.body);
              print("port: $port");
              //response6
              var response6 = await http.get(
                urlr,
                headers: {"Authorization": 'Bearer $finalToken'},
              );
              if (response6.statusCode == 200 || response6.statusCode == 201) {
                context.read<Providers>().setRecent(
                  jsonDecode(response6.body)["tiles"],
                );

                //response7
                var responseEdit = await http.get(
                  urlEdit,
                  headers: {"Authorization": 'Bearer $finalToken'},
                );
                if (responseEdit.statusCode == 200 ||
                    responseEdit.statusCode == 201) {
                  var data = jsonDecode(responseEdit.body);
                  //print("data:${data['data']}");
                  Analyticsinfo analyticsinfo = Analyticsinfo.fromJson(
                    data['data'],
                  );
                  context.read<Providers>().setAnalyticsInfo(analyticsinfo);

                  num tot = 0;
                  for (var a in sevengeemodel.steps) {
                    tot = tot + a;
                  }
                  bool col = sevengeemodel.backgrounds.every(
                    (element) => element == '#494949',
                  );
                  //response8

                  if ((tot != 0 || !col) &&
                      snapshotmodel.currency != "" &&
                      snapshotmodel.financial["cost"] != "0") {
                    var responseD = await dio.get(
                      urld,
                      options: Options(
                        headers: {
                          "Authorization": 'Bearer $finalToken',
                          "Content-Type": 'appllication/json',
                        },
                      ),
                    );
                    // print("responsD: " + responseD.statusMessage.toString());
                    if (responseD.statusCode == 200 ||
                        responseD.statusCode == 201) {
                      context.read<Providers>().setDashData(responseD.data);
                      context.read<Providers>().setCurrency(
                        responseD.data["gap_currencies"]["user_currency"],
                      );
                      context.read<Providers>().setManualCurrency(
                        responseD.data["gap_currencies"]["manual_currencies"],
                      );
                      context.read<Providers>().setSystemCurrency(
                        responseD.data["gap_currencies"]["system_currencies"],
                      );
                      context.read<Providers>().setAssistance(
                        responseD.data["assistance"],
                      );
                      Navigator.pop(context);
                      //check if seveng assumption questions are filled
                      if ([
                            null,
                            "",
                            "0",
                            0,
                          ].contains(sevengeemodel.questions.step1) ||
                          [
                            null,
                            "",
                            "0",
                            0,
                          ].contains(sevengeemodel.questions.step2) ||
                          [
                            null,
                            "",
                            "0",
                            0,
                          ].contains(sevengeemodel.questions.step3) ||
                          [
                            null,
                            "",
                            "0",
                            0,
                          ].contains(sevengeemodel.questions.step4) ||
                          [
                            null,
                            "",
                            "0",
                            0,
                          ].contains(sevengeemodel.questions.step5) ||
                          [
                            null,
                            "",
                            "0",
                            0,
                          ].contains(sevengeemodel.questions.step6) ||
                          [
                            null,
                            "",
                            "0",
                            0,
                          ].contains(sevengeemodel.questions.step7)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Prequestions(),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Dashboard(index: 0),
                        ),
                      );
                    } else {
                      whatError(responseD.statusCode, context);
                    }
                  } else if (tot == 0 &&
                      snapshotmodel.currency == "" &&
                      snapshotmodel.financial["cost"] == "0") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Precalc()),
                    );
                  } else if (tot == 0 &&
                      snapshotmodel.currency != "" &&
                      snapshotmodel.financial["cost"] != "0") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Prequestions(),
                      ),
                    );
                  } else if (tot > 0 &&
                      snapshotmodel.currency == "" &&
                      snapshotmodel.financial["cost"] == "0") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Precalc()),
                    );
                  } else {
                    print("tot: $tot");
                    print("snapshotmodel: ${snapshotmodel.financial["cost"]}");
                    print("currency: ${snapshotmodel.currency}");
                    Navigator.pop(context);
                    dialogBox.information(context, 'Status', 'Error!!');
                  }
                } else {
                  whatError(responseEdit.statusCode, context);
                }
              } else {
                whatError(response6.statusCode, context);
              }
            } else {
              whatError(response5.statusCode, context);
            }
          } else {
            whatError(response4.statusCode, context);
          }
        } else {
          whatError(response3.statusCode, context);
        }
      } else {
        whatError(responseDetails.statusCode, context);
      }
    } else {
      whatError(response2.statusCode, context);
    }
  }
}

class Token {
  String token;
  Token(this.token);

  factory Token.fromJSON(dynamic json) {
    return Token(json['data']['access_token'] as String);
  }

  @override
  String toString() {
    return ' { $token } ';
  }
}
