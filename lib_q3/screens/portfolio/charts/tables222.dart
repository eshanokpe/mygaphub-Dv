import 'dart:async';
import 'dart:convert';
import 'package:GapHub/provider/providers.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../braidetails.dart';

class Tables2 extends StatefulWidget {
  const Tables2({super.key});

  @override
  _Tables2State createState() => _Tables2State();
}

class _Tables2State extends State<Tables2> {
  Map data1 = {};
  Map data2 = {};
  Map data = {};
  String c = '';
  @override
  void initState() {
    super.initState();
    c = splitit(context.read<Providers>().currency);
    data = context.read<Providers>().portfolio;
    data1 = data["existing_report"];
    data2 = data["desired_report"];
  }

  @override
  Widget build(BuildContext context) {
    double totExistVal = 0;
    double totExistInc = 0;
    double totDesiredVal = 0;
    double totDesiredInc = 0;

    for (var i = 0; i < data1["values"].length; i++) {
      totExistVal += data1["values"][i];
    }
    for (var i = 0; i < data1["incomes"].length; i++) {
      totExistInc += data1["incomes"][i];
    }
    for (var i = 0; i < data2["values"].length; i++) {
      totDesiredVal += data2["values"][i];
    }
    for (var i = 0; i < data2["incomes"].length; i++) {
      totDesiredInc += data2["incomes"][i];
    }
    getData(String cap, String small) async {
      Timer timer = Timer(const Duration(seconds: 40), () {
        EasyLoading.dismiss();
        return;
      });
      EasyLoading.show(status: 'Loading', dismissOnTap: false);
      var url = Uri.parse("$baseUrl/app/portfolio/$small");
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      var response = await http.get(
        url,
        headers: {"Authorization": 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                Braidetails(cap, jsonDecode(response.body), false),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: "Error");
      }
      timer.cancel();
      EasyLoading.dismiss();
    }

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Column(
      children: [
        Table(
          border: TableBorder.all(color: Colors.black, width: .3),
          children: [
            const TableRow(
              children: [
                Tabledata2(text: '', thick: false),
                Tabledata2(text: 'Value', thick: true),
                Tabledata2(text: 'Income', thick: true),
              ],
            ),
            TableRow(
              children: [
                InkWell(
                  onTap: () {
                    getData("Business", "business");
                  },
                  child: const Tabledata2(text: 'Business', thick: false),
                ),
                Tabledata2(
                  text: '$c${data1["values"][0].toStringAsFixed(2)}'
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
                  thick: false,
                  boxColor: 0xff6D9EEB,
                ),
                Tabledata2(
                  text: '$c${data1["incomes"][0].toStringAsFixed(2)}'
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
                  thick: false,
                  boxColor: 0xff6D9EEB,
                ),
              ],
            ),
            TableRow(
              children: [
                InkWell(
                  onTap: () {
                    getData("Risk", "risk");
                  },
                  child: const Tabledata2(text: 'Risk', thick: false),
                ),
                Tabledata2(
                  text: '$c${data1["values"][1].toStringAsFixed(2)}'
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
                  thick: false,
                  boxColor: 0xff6D9EEB,
                ),
                Tabledata2(
                  text: '$c${data1["incomes"][1].toStringAsFixed(2)}'
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
                  thick: false,
                  boxColor: 0xff6D9EEB,
                ),
              ],
            ),
            TableRow(
              children: [
                InkWell(
                  onTap: () {
                    getData("Appreciating", "appreciating");
                  },
                  child: const Tabledata2(text: 'Appreciating', thick: false),
                ),
                Tabledata2(
                  text: '$c${data1["values"][2].toStringAsFixed(2)}'
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
                  thick: false,
                  boxColor: 0xff6D9EEB,
                ),
                Tabledata2(
                  text: '$c${data1["incomes"][2].toStringAsFixed(2)}'
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
                  thick: false,
                  boxColor: 0xff6D9EEB,
                ),
              ],
            ),
            TableRow(
              children: [
                InkWell(
                  onTap: () {
                    getData("Intellectual", "intellectual");
                  },
                  child: const Tabledata2(text: 'Intellectual', thick: false),
                ),
                Tabledata2(
                  text: '$c${data1["values"][3].toStringAsFixed(2)}'
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
                  thick: false,
                  boxColor: 0xff6D9EEB,
                ),
                Tabledata2(
                  text: '$c${data1["incomes"][3].toStringAsFixed(2)}'
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
                  thick: false,
                  boxColor: 0xff6D9EEB,
                ),
              ],
            ),
            TableRow(
              children: [
                InkWell(
                  onTap: () {
                    getData("Depreciating", "depreciating");
                  },
                  child: const Tabledata2(text: 'Depreciating', thick: false),
                ),
                Tabledata2(
                  text: '$c${data1["values"][4].toStringAsFixed(2)}'
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
                  thick: false,
                  boxColor: 0xff6D9EEB,
                ),
                Tabledata2(
                  text: '$c${data1["incomes"][4].toStringAsFixed(2)}'
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
                  thick: false,
                  boxColor: 0xff6D9EEB,
                ),
              ],
            ),
            TableRow(
              children: [
                const Tabledata2(text: 'TOTAL', thick: true),
                Tabledata2(
                  text: '$c${totExistVal.toStringAsFixed(2)}'.replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  ),
                  thick: true,
                ),
                Tabledata2(
                  text: '$c${totExistInc.toStringAsFixed(2)}'.replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  ),
                  thick: true,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: height * .03),
        // Container(
        //   width: double.infinity,
        //   padding: const EdgeInsets.all(5.0),
        //   decoration:
        //       BoxDecoration(border: Border.all(color: Colors.black, width: .3)),
        //   child: Text("Desired Asset",
        //       textAlign: TextAlign.center,
        //       style: TextStyle(
        //           fontSize: width * .04, fontWeight: FontWeight.w700)),
        // ),
        // Table(
        //   border: TableBorder.all(color: Colors.black, width: .3),
        //   children: [
        //     TableRow(children: [
        //       Tabledata2(text: '', thick: false),
        //       Tabledata2(text: 'Value', thick: true),
        //       Tabledata2(text: 'Income', thick: true),
        //     ]),
        //     TableRow(children: [
        //       InkWell(
        //           onTap: () {
        //             getData("Business", "business");
        //           },
        //           child: Tabledata2(text: 'Business', thick: false)),
        //       Tabledata2(
        //         text: '$c${data2["values"][0].toStringAsFixed(2)}'
        //             .replaceAllMapped(
        //                 new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                 (Match m) => '${m[1]},'),
        //         thick: false,
        //         boxColor: 0xffB6D7A8,
        //       ),
        //       Tabledata2(
        //         text: '$c${data2["incomes"][0].toStringAsFixed(2)}'
        //             .replaceAllMapped(
        //                 new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                 (Match m) => '${m[1]},'),
        //         thick: false,
        //         boxColor: 0xffB6D7A8,
        //       ),
        //     ]),
        //     TableRow(children: [
        //       InkWell(
        //           onTap: () {
        //             getData("Risk", "risk");
        //           },
        //           child: Tabledata2(text: 'Risk', thick: false)),
        //       Tabledata2(
        //         text: '$c${data2["values"][1].toStringAsFixed(2)}'
        //             .replaceAllMapped(
        //                 new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                 (Match m) => '${m[1]},'),
        //         thick: false,
        //         boxColor: 0xffB6D7A8,
        //       ),
        //       Tabledata2(
        //         text: '$c${data2["incomes"][1].toStringAsFixed(2)}'
        //             .replaceAllMapped(
        //                 new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                 (Match m) => '${m[1]},'),
        //         thick: false,
        //         boxColor: 0xffB6D7A8,
        //       ),
        //     ]),
        //     TableRow(children: [
        //       InkWell(
        //           onTap: () {
        //             getData("Appreciating", "appreciating");
        //           },
        //           child: Tabledata2(text: 'Appreciating', thick: false)),
        //       Tabledata2(
        //         text: '$c${data2["values"][2].toStringAsFixed(2)}'
        //             .replaceAllMapped(
        //                 new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                 (Match m) => '${m[1]},'),
        //         thick: false,
        //         boxColor: 0xffB6D7A8,
        //       ),
        //       Tabledata2(
        //         text: '$c${data2["incomes"][2].toStringAsFixed(2)}'
        //             .replaceAllMapped(
        //                 new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                 (Match m) => '${m[1]},'),
        //         thick: false,
        //         boxColor: 0xffB6D7A8,
        //       ),
        //     ]),
        //     TableRow(children: [
        //       InkWell(
        //           onTap: () {
        //             getData("Intellectual", "intellectual");
        //           },
        //           child: Tabledata2(text: 'Intellectual', thick: false)),
        //       Tabledata2(
        //         text: '$c${data2["values"][3].toStringAsFixed(2)}'
        //             .replaceAllMapped(
        //                 new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                 (Match m) => '${m[1]},'),
        //         thick: false,
        //         boxColor: 0xffB6D7A8,
        //       ),
        //       Tabledata2(
        //         text: '$c${data2["incomes"][3].toStringAsFixed(2)}'
        //             .replaceAllMapped(
        //                 new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                 (Match m) => '${m[1]},'),
        //         thick: false,
        //         boxColor: 0xffB6D7A8,
        //       ),
        //     ]),
        //     TableRow(children: [
        //       InkWell(
        //           onTap: () {
        //             getData("Depreciating", "depreciating");
        //           },
        //           child: Tabledata2(text: 'Depreciating', thick: false)),
        //       Tabledata2(
        //         text: '$c${data2["values"][4].toStringAsFixed(2)}'
        //             .replaceAllMapped(
        //                 new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                 (Match m) => '${m[1]},'),
        //         thick: false,
        //         boxColor: 0xffB6D7A8,
        //       ),
        //       Tabledata2(
        //         text: '$c${data2["incomes"][4].toStringAsFixed(2)}'
        //             .replaceAllMapped(
        //                 new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                 (Match m) => '${m[1]},'),
        //         thick: false,
        //         boxColor: 0xffB6D7A8,
        //       ),
        //     ]),
        //     TableRow(children: [
        //       Tabledata2(
        //         text: 'TOTAL',
        //         thick: true,
        //       ),
        //       Tabledata2(
        //           text: '$c${totDesiredVal.toStringAsFixed(2)}'
        //               .replaceAllMapped(
        //                   new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                   (Match m) => '${m[1]},'),
        //           thick: true),
        //       Tabledata2(
        //           text: '$c${totDesiredInc.toStringAsFixed(2)}'
        //               .replaceAllMapped(
        //                   new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                   (Match m) => '${m[1]},'),
        //           thick: true),
        //     ]),
        //   ],
        // ),
        SizedBox(height: height * .03),
        // Container(
        //   width: double.infinity,
        //   padding: const EdgeInsets.all(5.0),
        //   decoration:
        //       BoxDecoration(border: Border.all(color: Colors.black, width: .3)),
        //   child: Text("Anticipated Total (Desired + Total)",
        //       textAlign: TextAlign.center,
        //       style: TextStyle(
        //           fontSize: width * .04, fontWeight: FontWeight.w700)),
        // ),
        // Table(
        //   border: TableBorder.all(color: Colors.black, width: .3),
        //   children: [
        //     TableRow(children: [
        //       Tabledata2(text: '', thick: false),
        //       Tabledata2(text: 'Value', thick: true),
        //       Tabledata2(text: 'Income', thick: true),
        //     ]),
        //     TableRow(children: [
        //       InkWell(
        //           onTap: () {
        //             getData("Business", "business");
        //           },
        //           child: Tabledata2(text: 'Business', thick: false)),
        //       Tabledata2(
        //         text:
        //             '$c${(data1["values"][0] + data2["values"][0]).toStringAsFixed(2)}'
        //                 .replaceAllMapped(
        //                     new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                     (Match m) => '${m[1]},'),
        //         thick: false,
        //         boxColor: 0xffF4CCCC,
        //       ),
        //       Tabledata2(
        //           text:
        //               '$c${(data1["incomes"][0] + data2["incomes"][0]).toStringAsFixed(2)}'
        //                   .replaceAllMapped(
        //                       new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                       (Match m) => '${m[1]},'),
        //           thick: false,
        //           boxColor: 0xffF4CCCC),
        //     ]),
        //     TableRow(children: [
        //       InkWell(
        //           onTap: () {
        //             getData("Risk", "risk");
        //           },
        //           child: Tabledata2(text: 'Risk', thick: false)),
        //       Tabledata2(
        //           text:
        //               '$c${(data1["values"][1] + data2["values"][1]).toStringAsFixed(2)}'
        //                   .replaceAllMapped(
        //                       new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                       (Match m) => '${m[1]},'),
        //           thick: false,
        //           boxColor: 0xffF4CCCC),
        //       Tabledata2(
        //           text:
        //               '$c${(data1["incomes"][1] + data2["incomes"][1]).toStringAsFixed(2)}'
        //                   .replaceAllMapped(
        //                       new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                       (Match m) => '${m[1]},'),
        //           thick: false,
        //           boxColor: 0xffF4CCCC),
        //     ]),
        //     TableRow(children: [
        //       InkWell(
        //           onTap: () {
        //             getData("Appreciating", "appreciating");
        //           },
        //           child: Tabledata2(text: 'Appreciating', thick: false)),
        //       Tabledata2(
        //           text:
        //               '$c${(data1["values"][2] + data2["values"][2]).toStringAsFixed(2)}'
        //                   .replaceAllMapped(
        //                       new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                       (Match m) => '${m[1]},'),
        //           thick: false,
        //           boxColor: 0xffF4CCCC),
        //       Tabledata2(
        //           text:
        //               '$c${(data1["incomes"][2] + data2["incomes"][2]).toStringAsFixed(2)}'
        //                   .replaceAllMapped(
        //                       new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                       (Match m) => '${m[1]},'),
        //           thick: false,
        //           boxColor: 0xffF4CCCC),
        //     ]),
        //     TableRow(children: [
        //       InkWell(
        //           onTap: () {
        //             getData("Intellectual", "Intellectual".toLowerCase());
        //           },
        //           child: Tabledata2(text: 'Intellectual', thick: false)),
        //       Tabledata2(
        //           text:
        //               '$c${(data1["values"][3] + data2["values"][3]).toStringAsFixed(2)}'
        //                   .replaceAllMapped(
        //                       new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                       (Match m) => '${m[1]},'),
        //           thick: false,
        //           boxColor: 0xffF4CCCC),
        //       Tabledata2(
        //           text:
        //               '$c${(data1["incomes"][3] + data2["incomes"][3]).toStringAsFixed(2)}'
        //                   .replaceAllMapped(
        //                       new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                       (Match m) => '${m[1]},'),
        //           thick: false,
        //           boxColor: 0xffF4CCCC),
        //     ]),
        //     TableRow(children: [
        //       InkWell(
        //           onTap: () {
        //             getData("Depreciating", "Depreciating".toLowerCase());
        //           },
        //           child: Tabledata2(text: 'Depreciating', thick: false)),
        //       Tabledata2(
        //           text:
        //               '$c${(data1["values"][4] + data2["values"][4]).toStringAsFixed(2)}'
        //                   .replaceAllMapped(
        //                       new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                       (Match m) => '${m[1]},'),
        //           thick: false,
        //           boxColor: 0xffF4CCCC),
        //       Tabledata2(
        //           text:
        //               '$c${(data1["incomes"][4] + data2["incomes"][4]).toStringAsFixed(2)}'
        //                   .replaceAllMapped(
        //                       new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                       (Match m) => '${m[1]},'),
        //           thick: false,
        //           boxColor: 0xffF4CCCC),
        //     ]),
        //     TableRow(children: [
        //       Tabledata2(
        //         text: 'TOTAL',
        //         thick: true,
        //       ),
        //       Tabledata2(
        //           text: '$c${(totDesiredVal + totExistVal).toStringAsFixed(2)}'
        //               .replaceAllMapped(
        //                   new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                   (Match m) => '${m[1]},'),
        //           thick: true),
        //       Tabledata2(
        //           text: '$c${(totExistInc + totDesiredInc).toStringAsFixed(2)}'
        //               .replaceAllMapped(
        //                   new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        //                   (Match m) => '${m[1]},'),
        //           thick: true),
        //     ]),
        //   ],
        // ),
      ],
    );
  }
}

class Tabledata2 extends StatelessWidget {
  const Tabledata2({
    super.key,
    required this.text,
    required this.thick,
    this.boxColor = 0xffffffff,
  });

  final String text;
  final bool thick;
  final int boxColor;

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Container(
      color: Color(boxColor),
      padding: const EdgeInsets.all(5.0),
      child: Text(
        text,
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: width * .04,
          fontWeight: thick ? FontWeight.w700 : FontWeight.w300,
        ),
      ),
    );
  }
}
