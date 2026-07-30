import 'dart:async';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class Protectionitem extends StatefulWidget {
  final Map item;
  final bool archived;

  const Protectionitem({super.key, required this.item, this.archived = false});
  @override
  _ProtectionitemState createState() => _ProtectionitemState();
}

class _ProtectionitemState extends State<Protectionitem> {
  DialogBox dialogBox = DialogBox();
  Dio dio = Dio();
  bool enable = false;
  TextEditingController details = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController assured = TextEditingController();
  TextEditingController premium = TextEditingController();
  TextEditingController start = TextEditingController();
  TextEditingController end = TextEditingController();
  TextEditingController document = TextEditingController();

  static const subUnits2 = <String>[
    'Whole of Life',
    'Term Assurance',
    'Endowment Policy',
    'Annuity Plan',
    'Comprehensive Cover',
    'Third Party Cover',
    'Others',
  ];
  String? type;
  final List<DropdownMenuItem<String>> typeList = subUnits2
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ),
      )
      .toList();
  static const subUnits3 = <String>['Annually', 'Monthly'];
  String? frequency;

  final List<DropdownMenuItem<String>> frequencyList = subUnits3
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ),
      )
      .toList();
  static const subUnits4 = <String>[
    '-Select-',
    'Direct Debit',
    'Debit/Credit Card',
    'Standing Order',
  ];
  String? paymentType;
  var startDB = "";
  var endDB = "";
  DateTime? startd;
  DateTime? endd;

  final List<DropdownMenuItem<String>> paymentTypeList = subUnits4
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
      )
      .toList();
  var link;
  @override
  void initState() {
    super.initState();
    var item = widget.item;
    link = item["document"];

    if (link != null && link.toString().length > 10) {
      link = link.toString().replaceRange(0, 6, 'assets/storage');
      link = '$imgPrefix/$link';
    }
    type = item["protection_type"] ?? "";
    details.text = item["details"] ?? "";
    contact.text = item["provider_contact"] ?? "";
    assured.text = item["sum_assured"] ?? "";
    premium.text = item["premium_pay"].toString() ?? "";
    frequency = item["pay_frequency"] ?? "";
    start.text = item["cover_start"] ?? "";
    startDB = item["cover_start"] ?? "";
    end.text = item["cover_end"] ?? "";
    endDB = item["cover_end"] ?? "";
    paymentType = item["payment_type"];
    document.text = link ?? "";
  }

  launchDocu(String url) async {
    var url0 = url;
    await canLaunch(url0) ? launch(url0) : Fluttertoast.showToast(msg: 'Error');
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

    final currency = context.watch<Providers>().snapshotmodel.currency;
    var item = widget.item;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          '${item["protection_type"]}',
          style: TextStyle(fontSize: width * .05, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          Visibility(
            visible: !widget.archived,
            child: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  enable = !enable;
                });
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(4),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * .04,
            vertical: height * .02,
          ),
          child: Column(
            children: [
              Text(
                "${item["protection_category"]}: Protection",
                textAlign: TextAlign.center,
                style: TextStyle(
                  // color: Theme.of(context).primaryColor,
                  fontSize: width * .05,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '(view and edit your details)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  // color: Theme.of(context).primaryColor,
                  fontSize: width * .035,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: height * .03),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Type of Insurance:',
                  style: TextStyle(
                    fontSize: width * .045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              Container(
                padding: EdgeInsets.only(
                  left: width * .015,
                  right: width * .015,
                ),
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width * .01),
                  color: Colors.white,
                  border: Border.all(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    focusColor: Theme.of(context).primaryColor,
                    value: type,
                    items: typeList,
                    onChanged: (subval) {
                      setState(() {
                        type = subval;
                      });
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                  ),
                ),
              ),
              SizedBox(height: height * .03),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Details of Cover:',
                  style: TextStyle(
                    fontSize: width * .045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              TextFormField(
                enabled: enable,
                controller: details,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: TextStyle(fontSize: width * .03),
                  contentPadding: EdgeInsets.all(width * .03),
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: height * .03),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Provider\'s Contact:',
                  style: TextStyle(
                    fontSize: width * .045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              TextFormField(
                enabled: enable,
                controller: contact,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintStyle: TextStyle(fontSize: width * .03),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(width * .03),
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: height * .03),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sum Assured:',
                  style: TextStyle(
                    fontSize: width * .045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              TextFormField(
                enabled: enable,
                controller: assured,
                inputFormatters: [amountValidator],
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  prefix: Text(currency),
                  filled: true,
                  fillColor: Colors.white,
                  prefixStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                  hintStyle: TextStyle(fontSize: width * .03),
                  contentPadding: EdgeInsets.all(width * .03),
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: height * .03),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Policy Premium & Payment Frequency:',
                  style: TextStyle(
                    fontSize: width * .045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      enabled: enable,
                      controller: premium,
                      inputFormatters: [amountValidator],
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        prefix: Text(currency),
                        filled: true,
                        fillColor: Colors.white,
                        prefixStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        hintStyle: TextStyle(fontSize: width * .03),
                        contentPadding: EdgeInsets.all(width * .03),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: width * .05),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(
                        left: width * .015,
                        right: width * .015,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(width * .01),
                        color: Colors.white,
                        border: Border.all(),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          focusColor: Theme.of(context).primaryColor,
                          value: frequency,
                          items: frequencyList,
                          onChanged: (subval) {
                            setState(() {
                              frequency = subval;
                            });
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * .03),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Cover Start/End Dates:',
                  style: TextStyle(
                    fontSize: width * .045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        var datez =
                            DateTime.parse(start.text) ?? DateTime.now();
                        showDatePicker(
                          context: context,
                          initialDate: datez,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        ).then((value) {
                          setState(() {
                            if (value != null) {
                              startDB = DateFormat('yyyy-MM-dd').format(value);
                              start.text = startDB;
                              startd = value;
                            }
                          });
                          FocusScope.of(context).requestFocus(FocusNode());
                        });
                      },
                      child: TextFormField(
                        enabled: false,
                        controller: start,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: Icon(
                            Icons.date_range,
                            color: Theme.of(context).primaryColor,
                          ),
                          hintStyle: TextStyle(fontSize: width * .03),
                          contentPadding: EdgeInsets.all(width * .03),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: width * .05),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        var datez = DateTime.parse(end.text) ?? DateTime.now();
                        showDatePicker(
                          context: context,
                          initialDate: datez,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        ).then((value) {
                          setState(() {
                            if (value != null) {
                              endDB = DateFormat('yyyy-MM-dd').format(value);
                              end.text = endDB;
                              endd = value;
                            }
                          });
                          FocusScope.of(context).requestFocus(FocusNode());
                        });
                      },
                      child: TextFormField(
                        enabled: enable,
                        controller: end,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: Icon(
                            Icons.date_range,
                            color: Theme.of(context).primaryColor,
                          ),
                          hintStyle: TextStyle(fontSize: width * .03),
                          contentPadding: EdgeInsets.all(width * .03),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * .03),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Payment Type:',
                  style: TextStyle(
                    fontSize: width * .045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              Container(
                padding: EdgeInsets.only(
                  left: width * .015,
                  right: width * .015,
                ),
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width * .01),
                  color: Colors.white,
                  border: Border.all(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    focusColor: Theme.of(context).primaryColor,
                    value: paymentType,
                    items: paymentTypeList,
                    onChanged: (subval) {
                      setState(() {
                        paymentType = subval;
                      });
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                  ),
                ),
              ),
              SizedBox(height: height * .03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Document Vault:',
                    style: TextStyle(
                      fontSize: width * .045,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      launchDocu(link);
                    },
                    child: Text(
                      "View Document",
                      style: TextStyle(
                        fontSize: width * .045,
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * .03),
              Visibility(
                visible: enable,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * .01),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    update();
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(
                      // decoration: TextDecoration.underline,
                      color: Colors.white,
                      fontSize: width * .04,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: !enable,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    backgroundColor: Colors.grey[400],
                  ),
                  onPressed: widget.archived
                      ? () {
                          dialogBox.options(
                            context,
                            "Confirm Add Account",
                            "Are you sure you want to add this account? (You will be able to view the account in Mortgage)",
                            () {
                              addorremove();
                            },
                          );
                        }
                      : () {
                          dialogBox.options(
                            context,
                            "Confirm Remove Account",
                            "Are you sure you want to remove this account? (You will be able view the account under Archive section)",
                            () {
                              addorremove();
                            },
                          );
                          // dropdown();
                        },
                  child: Text(
                    widget.archived ? "Restore Account" : "Remove Account",
                    style: TextStyle(
                      // decoration: TextDecoration.underline,
                      color: Colors.black,
                      fontSize: width * .035,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  addorremove() async {
    dialogBox.waiting(context, "Loading");
    var timer = Timer(const Duration(seconds: 50), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    var urlr = "$baseUrl/app/360/tiles";

    var url = widget.archived
        ? "$baseUrl/app/360/protection?header=pwsijedijierujsxhjndgmbhhgcghdchnsbdgjvjxbsx&access=atyhgujhashgbsxdhgvshgsghfgnbvjbsjkbvjbvjhdx&account=${widget.item["id"]}"
        : "$baseUrl/app/360/protection?header=pwsijedijierujsxhjndgmbhhgcghdchnsbdgjvjxbsx&access=uyaghgbshgbhsjxbhsjxbvbhxdbvdhgbvghdvcghvgdhcvhsnbhsb&account=${widget.item["id"]}";
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      try {
        var response = await dio.get(
          urlr,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );
        context.read<Providers>().setRecent(response.data["tiles"]);

        Navigator.pop(context);
        protection();
        Fluttertoast.showToast(
          msg: widget.archived
              ? "Account unarchived successfully"
              : "Account archived successfully",
        );
      } catch (e) {
        Navigator.pop(context);
      }
      timer.cancel();
    } else {
      timer.cancel();
    }
    //
  }

  update() async {
    FocusScope.of(context).requestFocus(FocusNode());

    var timer = Timer(const Duration(seconds: 50), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, "Saving");
    var id = widget.item["id"];
    var url = Uri.parse("$baseUrl/app/360/protection/$id");
    var urlr = "$baseUrl/app/360/tiles";

    Map data = {
      "protection_type": type,
      "provider_contact": contact.text,
      "details": details.text,
      "sum_assured": assured.text,
      "premium_pay": premium.text,
      "pay_frequently": frequency,
      "pay_typed": paymentType,
      "cover_start": startDB,
      "cover_end": endDB,
    }; 

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    var response = await http.post(
      url,
      body: data,
      headers: {"Authorization": 'Bearer $token'},
    );
    if (response.statusCode == 400) {
      Fluttertoast.showToast(msg: response.body);

      timer.cancel();
      return;
    }

    if (response.statusCode == 200) {
      // Navigator.pop(context);

      try {
        var response = await dio.get(
          urlr,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );
        context.read<Providers>().setRecent(response.data["tiles"]);
        protection();
      } catch (e) {
        Navigator.pop(context);
      }
      timer.cancel();
    } else {
      timer.cancel();
    }
    Navigator.pop(context);
  }

  protection() async {
    dialogBox.waiting(context, "Loading");
    var url = "$baseUrl/app/360/protection";
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    // print(response.data);
    if (response.statusCode == 200) {
      var mapList = response.data["protection"];
      var mapListLite = response.data["protection_detail"];
      context.read<Providers>().setProtectionList(mapList);
      context.read<Providers>().setProtectionListLite(mapListLite);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      if (widget.archived) {
        Navigator.pop(context);
      }
      Navigator.of(context).pushNamed('Protectiondetails');
    } else {
      Navigator.pop(context);
    }
  }
}
