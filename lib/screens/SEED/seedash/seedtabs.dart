import 'dart:async';
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:GapHub/widgets/spaces.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'seeds.dart';
import 'package:GapHub/screens/SEED/charts/seedonut.dart';
import 'package:intl/intl.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/utils/extensions.dart';
import 'average_seed/average_seed.dart';
import 'future_seed/futureseed.dart';
import 'historic_seed/historicseed.dart';
import 'seeds_adverage.dart';
import 'seeds_target.dart';
import 'setbudget.dart';

class Seedtabs extends StatefulWidget {
  String datez;
  Seedtabs({super.key, required this.datez});
  @override
  _SeedtabsState createState() => _SeedtabsState();
}

class _SeedtabsState extends State<Seedtabs> with TickerProviderStateMixin {
  TabController? _tabController;

  Map data = {};
  var d = DateFormat.yMMMM();
  var datez;
  double savings = 0;
  Map dashData = {};
  Map seedData = {};
  @override
  void initState() {
    datez = widget.datez;
    dashData = context.read<Providers>().dashdata;
    seedData = context.read<Providers>().seedata;
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    data = context.read<Providers>().seedata;
    String currency = context.watch<Providers>().snapshotmodel.currency;
    data['data']["average_detail"]["table"]["savings"];
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    List current = data['data']["current_detail"]["seed_web"];
    List average = data['data']["average_detail"]["seed_web"];
    List target = data['data']["target_detail"]["seed_web"];
    Widget text = Text(
      "0%",
      style: TextStyle(fontSize: width * .05, fontWeight: FontWeight.w500),
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: height * .4,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(.05),
            border: Border.all(width: 1, color: Colors.grey[200]!),
          ),
          width: double.infinity,
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Image.asset(
                      'assets/images/left_chevron.png',
                      width: width * .08,
                      color: Colors.transparent,
                    ),
                    onPressed: null,
                  ),
                  average.every((e) => e == 0)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [text],
                        )
                      : Topdonut(
                          values: data['data']["average_detail"]["seed_web"],
                          currency: currency,
                          total: data['data']["average_detail"]["total"]
                              .toStringAsFixed(2),
                          percent: data['data']["average_detail"]["seed_web"],
                        ),
                  IconButton(
                    icon: Image.asset(
                      'assets/images/right_chevron.png',
                      width: width * .08,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      _tabController!.animateTo(
                        (_tabController!.index + 1) % 2,
                      );
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Image.asset(
                      'assets/images/left_chevron.png',
                      width: width * .08,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      _tabController!.animateTo(
                        (_tabController!.index + 1) % 2,
                      );
                    },
                  ),
                  current.every((e) => e == 0)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: height * .02),
                            Text(
                              "$datez",
                              style: TextStyle(
                                fontSize: width * .05,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: height * .07),
                            text,
                            SizedBox(height: height * .02),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                              onPressed: () async {
                                var url = Uri.parse("$baseUrl/app/seed");
                                var url2 = Uri.parse("$baseUrl/app/360/income");

                                var timer = Timer(
                                  const Duration(seconds: 40),
                                  () {
                                    EasyLoading.dismiss();
                                    Navigator.pop(context);
                                    dialogBox.information(
                                      context,
                                      'Status',
                                      'Service timed out',
                                    );
                                    return;
                                  },
                                );
                                dialogBox.waiting(context, 'Loading');
                                final prefs =
                                    await SharedPreferences.getInstance();
                                var token = prefs.getString('tokenDB');
                                var response = await http.get(
                                  url,
                                  headers: {"Authorization": 'Bearer $token'},
                                );
                                var response2 = await http.get(
                                  url2,
                                  headers: {"Authorization": 'Bearer $token'},
                                );
                                if (response.statusCode == 200) {
                                  var body = jsonDecode(response.body);
                                  var body2 = jsonDecode(response2.body);
                                  var incomes = body2['incomes'];
                                  print("incomes$body2");
                                  context.read<Providers>().setSeeData(body);
                                  context.read<Providers>().incomesAccount(
                                    incomes,
                                  );
                                  timer.cancel();
                                  Navigator.pop(context);
                                  EasyLoading.dismiss();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Setbudget(true),
                                    ),
                                  );
                                } else {
                                  timer.cancel();
                                  Navigator.pop(context);
                                }
                              },
                              child: Text(
                                current.every((e) => e == 0)
                                    ? "Create a Budget"
                                    : "Update Budget",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Topdonut(
                          values: data["data"]["current_detail"]["seed_web"],
                          currency: currency,
                          total: data["data"]["current_detail"]["total"]
                              .toStringAsFixed(2),
                          percent: data["data"]["current_detail"]["seed_web"],
                        ),
                  IconButton(
                    icon: Image.asset(
                      'assets/images/right_chevron.png',
                      width: width * .08,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      _tabController!.animateTo(
                        (_tabController!.index + 1) % 3,
                      );
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Image.asset(
                      'assets/images/left_chevron.png',
                      width: width * .08,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      _tabController!.animateTo(
                        (_tabController!.index + 1) % 2,
                      );
                    },
                  ),
                  target.every((e) => e == 0)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // IconButton(
                            //   icon: Image.asset(
                            //       'assets/images/left_chevron.png',
                            //       width: width * .08,
                            //       color: Colors.black),
                            //   onPressed: () {
                            //     _tabController!
                            //         .animateTo((_tabController!.index + 1) % 2);
                            //   },
                            // ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                previewModel(context);
                              },
                              child: const Text(
                                "Next Month",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Topdonut(
                          values: data['data']["target_detail"]["seed_web"],
                          currency: currency,
                          total: data['data']["target_detail"]["total"]
                              .toStringAsFixed(2),
                          percent: data['data']["target_detail"]["seed_web"],
                        ),
                  IconButton(
                    icon: Image.asset(
                      'assets/images/right_chevron.png',
                      width: width * .08,
                      color: Colors.transparent,
                    ),
                    onPressed: null,
                  ),
                ],
              ),
            ],
          ),
        ),
        Stack(
          fit: StackFit.passthrough,
          alignment: Alignment.center,
          children: [
            Container(
              height: height * .075,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[50]!,
                    width: width * .008,
                  ),
                ),
              ),
            ),
            TabBar(
              tabs: const [
                Tab(child: Text('Average')),
                Tab(child: Text('Current')),
                Tab(child: Text('Future')),
              ],
              indicatorColor: Theme.of(context).primaryColor,
              labelColor: Colors.black,
              indicatorWeight: 3,
              unselectedLabelColor: Colors.grey[500],
              labelStyle: TextStyle(
                fontSize: width * .04,
                fontWeight: FontWeight.w700,
              ),
              controller: _tabController,
            ),
          ],
        ),
        SizedBox(
          height: height * .5,
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              Column(
                children: [
                  SeedsAverage([
                    data['data']["average_detail"]["table"]["savings"],
                    data['data']["average_detail"]["table"]["education"],
                    data['data']["average_detail"]["table"]["expenditure"],
                    data['data']["average_detail"]["table"]["discretionary"],
                  ]),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    onPressed: () async {
                      var timer = Timer(const Duration(seconds: 40), () {
                        // Navigator.pop(context);
                        EasyLoading.dismiss();
                        dialogBox.information(
                          context,
                          'Status',
                          'Service timed out',
                        );
                        return;
                      });
                      EasyLoading.show(status: 'Loading', dismissOnTap: false);
                      var urlSA = Uri.parse("$baseUrl/app/seed/");
                      final prefs = await SharedPreferences.getInstance();
                      var token = prefs.getString('tokenDB');
                      var response = await http.get(
                        urlSA,
                        headers: {
                          "Authorization": 'Bearer $token',
                          "Accept": "application/json",
                          "Content-Type": "application/x-www-form-urlencoded",
                        },
                      );
                      if (response.statusCode == 200) {
                        Map<String, dynamic> body = jsonDecode(response.body);
                        var period = body["data"]['periods'];

                        if (period.length == 0) {
                          timer.cancel();
                          EasyLoading.dismiss();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AverageSeed(data: body),
                            ),
                          );
                        } else if (period.length == null) {
                          timer.cancel();
                          EasyLoading.dismiss();
                          Fluttertoast.showToast(
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            msg: 'No Data Found ',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                        } else {
                          timer.cancel();
                          EasyLoading.dismiss();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoricSeed(data: body),
                            ),
                          );
                        }
                      } else {
                        timer.cancel();
                        EasyLoading.dismiss();
                        Fluttertoast.showToast(
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          msg: 'No Data Found ',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                        );
                      }
                    },
                    child: Text(
                      'Historic SEED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * .035,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                child: Column(
                  children: [
                    Seeds([
                      data['data']["current_detail"]["table"]["savings"], //amount
                      data['data']["current_detail"]["table"]["education"],
                      data['data']["current_detail"]["table"]["expenditure"],
                      data['data']["current_detail"]["table"]["discretionary"],
                    ]),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      onPressed: () async {
                        var timer = Timer(const Duration(seconds: 40), () {
                          EasyLoading.dismiss();
                          Navigator.pop(context);
                          dialogBox.information(
                            context,
                            'Status',
                            'Service timed out',
                          );
                          return;
                        });
                        dialogBox.waiting(context, 'Loading');
                        var url = Uri.parse("$baseUrl/app/360/income");
                        final prefs = await SharedPreferences.getInstance();
                        var token = prefs.getString('tokenDB');

                        var response = await http.get(
                          url,
                          headers: {"Authorization": 'Bearer $token'},
                        );
                        if (response.statusCode == 200) {
                          var body = jsonDecode(response.body);
                          var incomes = body;
                          print("incomes:$body");
                          context.read<Providers>().incomesAccount(incomes);
                          timer.cancel();
                          Navigator.pop(context);
                          EasyLoading.dismiss();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Setbudget(true),
                            ),
                          );
                        } else {
                          timer.cancel();
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        current.every((e) => e == 0)
                            ? "Create a Budget"
                            : "Update Budget",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * .035,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  SeedsTarget([
                    data['data']["target_detail"]["table"]["savings"],
                    data['data']["target_detail"]["table"]["education"],
                    data['data']["target_detail"]["table"]["expenditure"],
                    data['data']["target_detail"]["table"]["discretionary"],
                  ]),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    onPressed: () async {
                      var url = Uri.parse("$baseUrl/app/seed");
                      var timer = Timer(const Duration(seconds: 40), () {
                        Navigator.pop(context);
                        dialogBox.information(
                          context,
                          'Status',
                          'Service timed out',
                        );
                        return;
                      });
                      dialogBox.waiting(context, 'Loading');
                      final prefs = await SharedPreferences.getInstance();
                      var token = prefs.getString('tokenDB');
                      var response = await http.get(
                        url,
                        headers: {"Authorization": 'Bearer $token'},
                      );
                      if (response.statusCode == 200) {
                        var body = jsonDecode(response.body);

                        context.read<Providers>().setSeeData(body);
                        timer.cancel();
                        EasyLoading.dismiss();
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Setbudget(true),
                          ),
                        );
                      } else {
                        timer.cancel();
                        Navigator.pop(context);
                      }
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          previewModel(context);
                        },
                        child: Text(
                          target.every((e) => e == 0)
                              ? "Next Month"
                              : "Update Next Month",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void previewModel(BuildContext context) {
    showDialog(context: context, builder: (context) => const Select());
  }
}

class Select extends StatefulWidget {
  const Select({super.key});

  @override
  State<Select> createState() => _SelectState();
}

class _SelectState extends State<Select> {
  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.only(top: 0, bottom: height * .05),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.cancel_outlined),
                highlightColor: Colors.pink,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          Text(
            'Would you like to duplicate current month`s budget for next month?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: width * .04),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            EasyLoading.show(status: 'Loading', dismissOnTap: false);
            var url = Uri.parse("$baseUrl/app/seed/target?clone= ygfebhjgsbh");
            var url2 = Uri.parse("$baseUrl/app/seed/");
            final prefs = await SharedPreferences.getInstance();
            var token = prefs.getString('tokenDB');
            var timer = Timer(const Duration(seconds: 40), () {
              Navigator.pop(context);
              EasyLoading.dismiss();
              dialogBox.information(context, 'Status', 'Service timed out');
              return;
            });
            var response = await http.get(
              url,
              headers: {"Authorization": 'Bearer $token'},
            );
            if (response.statusCode == 200) {
              EasyLoading.dismiss();
              Map body = jsonDecode(response.body);
              print("datayes:$body");
              context.read<Providers>().setSeedTarget(body);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Futureseed(true)),
              );
              timer.cancel();
            } else {
              EasyLoading.dismiss();
              print({response.statusCode.toString()});
              timer.cancel();
            }
          },
          child: Text(
            'No',
            style: TextStyle(color: Colors.white, fontSize: width * .04),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () async {
            EasyLoading.show(status: 'Loading', dismissOnTap: false);
            var url = Uri.parse("$baseUrl/app/seed/target?clone=rjkhbhfhdhbd");
            var url2 = Uri.parse("$baseUrl/app/seed/");
            final prefs = await SharedPreferences.getInstance();
            var token = prefs.getString('tokenDB');
            var timer = Timer(const Duration(seconds: 40), () {
              Navigator.pop(context);
              EasyLoading.dismiss();
              dialogBox.information(context, 'Status', 'Service timed out');
              return;
            });
            var response = await http.get(
              url,
              headers: {"Authorization": 'Bearer $token'},
            );
            if (response.statusCode == 200) {
              EasyLoading.dismiss();
              Map body = jsonDecode(response.body);
              print("datayes:$body");
              context.read<Providers>().setSeedTarget(body);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Futureseed(true)),
              );
              timer.cancel();
            } else {
              print({response.statusCode.toString()});
              timer.cancel();
              EasyLoading.dismiss();
            }
          },
          child: Text(
            'Yes',
            style: TextStyle(color: Colors.white, fontSize: width * .04),
          ),
        ),
      ],
    );
  }
}

class Topdonut extends StatelessWidget {
  const Topdonut({
    super.key,
    required this.percent,
    required this.currency,
    required this.total,
    required this.values,
  });

  final List percent;
  final String currency;
  final total;
  final List values;

  @override
  Widget build(BuildContext context) {
    String currency = context.watch<Providers>().snapshotmodel.currency;
    Orientation orientation = MediaQuery.of(context).orientation;

    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Hspace(context.height(.02)),
        Text(
          "$currency$total".replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          ),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: width * .045, fontWeight: FontWeight.w700),
        ),
        Hspace(context.height(.01)),
        Seedonut(
          colors: const [
            '0xff00B050',
            '0xffE6C069',
            '0xffD13B56',
            '0xff77A2BB',
          ],
          labels: const [
            "Savings",
            "Education",
            "Expenditure",
            "Discretionary",
          ],
          percent: percent,
          values: values,
        ),
      ],
    );
  }
}

class SeedRow extends StatelessWidget {
  final int color;
  final String name;
  final String value;
  final VoidCallback? onTap;

  const SeedRow({
    super.key,
    required this.color,
    required this.name,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: height * .01),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: width * .05,
                  width: width * .05,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(color),
                        blurRadius: 0,
                        offset: Offset(width * .006, width * .005),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(width * .005),
                    border: Border.all(color: Color(color)),
                  ),
                ),
                SizedBox(width: width * .04),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: width * .045,
                    color: Color(color),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              value.replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              ),
              style: TextStyle(
                fontSize: width * .045,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
