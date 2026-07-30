import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/utils/constants.dart';
import 'dashboard.dart';

class Sort extends StatefulWidget {
  const Sort({super.key});

  @override
  _SortState createState() => _SortState();
}

class _SortState extends State<Sort> {
  bool switch0 = false;
  bool switch1 = false;
  bool switch2 = false;
  bool switch3 = false;
  bool switch4 = false;
  bool switch5 = false;
  bool switch6 = false;
  bool switch7 = false;
  bool switch8 = false;
  bool switch9 = false;

  List<bool> booleans = [];
  List<String> string = [
    "Home Equity",
    "Net Worth",
    "Average SEED",
    "Grand",
    "Freedom",
    "Education",
    "Debt",
    "Credit",
    "Beta",
    "Alpha",
  ];
  Map dashData = {};
  DialogBox dialogBox = DialogBox();
  @override
  void initState() {
    super.initState();
    dashData = context.read<Providers>().dashdata["dashboard"];
    switch0 = dashData["equity"];
    switch1 = dashData["net_worth"];
    switch2 = dashData["average_seed"];
    switch3 = dashData["grand"];
    switch4 = dashData["freedom"];
    switch5 = dashData["education"];
    switch6 = dashData["debt"];
    switch7 = dashData["credit"];
    switch8 = dashData["beta"];
    switch9 = dashData["alpha"];

    booleans.add(switch0);
    booleans.add(switch1);
    booleans.add(switch2);
    booleans.add(switch3);
    booleans.add(switch4);
    booleans.add(switch5);
    booleans.add(switch6);
    booleans.add(switch7);
    booleans.add(switch8);
    booleans.add(switch9);
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
        surfaceTintColor: Colors.white,
        title: Text(
          'Update your View',
          style: TextStyle(fontSize: width * .05, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: width * .02,
              vertical: height * .01,
            ),
            child: Column(
              children: [
                Text(
                  "Select the tiles you will like to display on your dashboard",
                  style: TextStyle(
                    fontSize: width * .035,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: height * .01),
                Text(
                  "(you can only have a maximum of 3 tiles at a time)",
                  style: TextStyle(
                    fontSize: width * .03,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: height * .03),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: string.length,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * .02),
                    child: Card(
                      elevation: 3,
                      color: Colors.grey[300],
                      child: ListTile(
                        onTap: () {},
                        title: Text(string[index]),
                        trailing: Switch(
                          activeThumbColor: Theme.of(context).primaryColor,
                          value: booleans[index],
                          onChanged: (value) {
                            print('value:$value');
                            print('index:$index');

                            setState(() {
                              booleans[index] = !booleans[index];
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * .03),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * .01),
                    ),
                  ),
                  onPressed: () async {
                    var trues = [];
                    trues = booleans.where((element) => element).toList();
                    if (trues.length != 3) {
                      Fluttertoast.showToast(
                        msg:
                            "You can only select a maximum and a minimum of 3 tiles at a time",
                        toastLength: Toast.LENGTH_LONG,
                      );
                    } else {
                      var timer = Timer(const Duration(seconds: 40), () {
                        Navigator.pop(context);
                        dialogBox.information(
                          context,
                          'Status',
                          'Service timed out',
                        );
                        return;
                      });
                      dialogBox.waiting(context, "Saving");
                      var url = Uri.parse("$baseUrl/app/dashboard/tiles");
                      final prefs = await SharedPreferences.getInstance();
                      var token = prefs.getString('tokenDB');
                      Map body = {};

                      for (var i = 0; i < booleans.length; i++) {
                        if (booleans[i]) {
                          switch (i) {
                            case 0:
                              body["equity"] = "1";
                              break;
                            case 1:
                              body["net_worth"] = "1";
                              break;
                            case 2:
                              body["average_seed"] = "1";
                              break;
                            case 3:
                              body["grand"] = "1";
                              break;
                            case 4:
                              body["freedom"] = "1";
                              break;
                            case 5:
                              body["education"] = "1";
                              break;
                            case 6:
                              body["debt"] = "1";
                              break;
                            case 7:
                              body["credit"] = "1";
                              break;
                            case 8:
                              body["beta"] = "1";
                              break;
                            case 9:
                              body["alpha"] = "1";
                              break;
                            default:
                          }
                        }
                      }
                      var response = await http.post(
                        url,
                        body: body,
                        headers: {"Authorization": 'Bearer $token'},
                      );

                      if (response.statusCode == 200 &&
                          jsonDecode(response.body)["status"]) {
                        var urld = Uri.parse("$baseUrl/app/dashboard");
                        var responseD = await http.get(
                          urld,
                          headers: {"Authorization": 'Bearer $token'},
                        );
                        if (responseD.statusCode == 200) {
                          context.read<Providers>().setDashData(
                            jsonDecode(responseD.body),
                          );
                        }
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context);

                        timer.cancel();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Dashboard(index: 0),
                          ),
                        );
                      } else {
                        dialogBox.information(
                          context,
                          "Status",
                          "Anerror occured",
                        );
                        Navigator.pop(context);

                        timer.cancel();
                      }
                    }
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: width * .045,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
