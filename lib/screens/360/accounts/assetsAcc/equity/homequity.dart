import 'dart:convert';
import 'package:GapHub/models/addressmodel.dart';
import 'package:GapHub/screens/360/decider.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/dialog.dart';
import 'package:flutter/material.dart';
import 'package:GapHub/screens/360/accounts/assetsAcc/equity/equitydetails.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:GapHub/provider/providers.dart';

class Homequity extends StatefulWidget {
  const Homequity({super.key});

  @override
  _HomequityState createState() => _HomequityState();
}

class _HomequityState extends State<Homequity> {
  var key = GlobalKey<FormState>();
  Timer? timer;
  TextEditingController address = TextEditingController();
  TextEditingController zipcode = TextEditingController();
  TextEditingController currentValue = TextEditingController();
  DialogBox dialogBox = DialogBox();
  ScrollController scrollController = ScrollController(initialScrollOffset: 10);

  Dio dio = Dio();
  var mortgages = [];
  var mortgagesList = [];
  bool loading = false;
  var countries = [];
  FocusNode zipnode = FocusNode();
  List add = ["-Select-"];
  List<Addressmodel> addresses = [];
  BuildContext? dialogContext;
  static const subUnits1 = <String>['Yes', 'No'];

  String option = 'Yes';
  String buss = '-Select-';

  final List<DropdownMenuItem<String>> optionList = subUnits1
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
      )
      .toList();
  String mortgage = '-Select-';
  String country = '-Select-';

  checkVerify() {
    if (!zipnode.hasFocus) {
      verifyCode();
    }
  }

  @override
  void initState() {
    super.initState();
    // debt(currency);
    mortgages = context.read<Providers>().mortgages;

    countries = context.read<Providers>().countries;

    zipnode.addListener(checkVerify);
  }

  debt(String currency) async {
    var url = Uri.parse("$baseUrl/app/360/equity/info");
    // var url = Uri.parse("$baseUrl/app/360/mortgage");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await http.get(
      url,
      headers: {"Authorization": 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      Map body = jsonDecode(response.body);
      List mortgages = body["mortgages_available"];
      print("mortgages:$mortgages");
      List mortgagesList = mortgages
          // .where((e) =>
          //     e["creditor_name"] !=
          //     'null')
          .map((e) {
            String creditorName = e["creditor_name"];
            num currentBalance = e["current_balance"];

            // Construct formatted string
            String formattedString =
                "$creditorName (${currency}${currentBalance.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')})";

            return formattedString;
          })
          .toList();

      mortgagesList.insert(0, "-Select-");
      context.read<Providers>().setMortgages(mortgages);
      context.read<Providers>().setMortgagesList(mortgagesList);

      // List countries = body["countries"];
      // countries.insert(0, "-Select-");
      // context.read<Providers>().setCountries(countries);
    }
  }

  @override
  Widget build(BuildContext context) {
    String currency = context.watch<Providers>().snapshotmodel.currency;

    mortgagesList = context.read<Providers>().mortgagesList;
    print("mortgagesList:$mortgagesList");
    debt(currency);
    Orientation orientation = MediaQuery.of(context).orientation;

    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          "Add Account: Home Equity",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: width * .035,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNav(4),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: height * .02),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .04),
                child: Form(
                  key: key,
                  child: Column(
                    children: [
                      Text(
                        "(Complete the form below to add your home details)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: width * .035,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: width * .045,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Is there mortgage on this property?',
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  fontSize: width * .04,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
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
                          child: DropdownButton(
                            focusColor: Theme.of(context).primaryColor,
                            value: option,
                            items: optionList,
                            onChanged: (subval) {
                              setState(() {
                                option = subval as String;
                              });
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Visibility(
                        visible: option == "Yes",
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: width * .045,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text:
                                          'What is the current mortgage balance:',
                                    ),
                                    TextSpan(
                                      text: " *",
                                      style: TextStyle(
                                        fontSize: width * .04,
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
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
                                borderRadius: BorderRadius.circular(
                                  width * .01,
                                ),
                                color: Colors.white,
                                border: Border.all(),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  focusColor: Theme.of(context).primaryColor,
                                  value: mortgage,
                                  items: mortgagesList.map((value) {
                                    return DropdownMenuItem<String>(
                                      value: "$value",
                                      child: Text(
                                        "$value",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (subval) {
                                    setState(() {
                                      mortgage = subval as String;
                                    });
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(FocusNode());
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: height * .005),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Mortgage balance not found from the list?",
                                    style: TextStyle(
                                      fontSize: width * .028,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  InkWell(
                                    child: Text(
                                      " Add mortgage account now",
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontSize: width * .028,
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    onTap: () {
                                      // Navigator.of(context).pushNamed('Mortgage');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              Decider("Mortgage"),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: height * .03),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: width * .045,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Country Property is located:',
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  fontSize: width * .04,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
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
                          child: DropdownButton(
                            focusColor: Theme.of(context).primaryColor,
                            value: country,
                            items: countries.map((value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 13,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (subval) {
                              setState(() {
                                country = subval as String;
                                zipcode.clear();
                                address.clear();
                              });
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                          ),
                        ),
                      ),
                      Visibility(
                        visible:
                            country == "Canada" ||
                            country == "United States" ||
                            country == "United Kingdom",
                        child: Column(
                          children: [
                            SizedBox(height: height * .03),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: width * .045,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Post Code/Zip Code:'),
                                    TextSpan(
                                      text: " *",
                                      style: TextStyle(
                                        fontSize: width * .045,
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: height * .005),
                            TextFormField(
                              controller: zipcode,
                              focusNode: zipnode,
                              keyboardType: TextInputType.name,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w400,
                              ),
                              textInputAction: TextInputAction.search,
                              // onChanged: (value) {
                              //   keyss = false;
                              //   if (value.length == 5 &&
                              //       country == "United States") {
                              //     Timer(Duration(seconds: 2), () {
                              //       verifyCode();
                              //     });
                              //   } else if (value.replaceAll(" ", "").length >=
                              //           5 &&
                              //       (country == "Canada" ||
                              //           country == "United Kingdom")) {
                              //     timer = Timer(Duration(seconds: 3), () {
                              //       keyss = true;
                              //       verifyCode();
                              //     });
                              //   }
                              // },
                              // onFieldSubmitted: (_) => verifyCode(),vvvvvvvvvvvvvvvvvvvv
                              // onEditingComplete: () => verifyCode(),
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                hintStyle: TextStyle(fontSize: width * .03),
                                contentPadding: EdgeInsets.all(width * .03),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: height * .005),
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                child: Text(
                                  "Hit enter on keyboard to verify code",
                                  style: TextStyle(
                                    fontSize: width * .028,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                onTap: () {
                                  verifyCode();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: width * .045,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              const TextSpan(text: 'Home Address:'),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  fontSize: width * .04,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      TextFormField(
                        controller: address,
                        maxLines: 3,
                        keyboardType: TextInputType.name,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                          fontSize: width * .04,
                        ),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintStyle: TextStyle(fontSize: width * .03),
                          contentPadding: EdgeInsets.all(width * .03),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: width * .045,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Current market value of your home:',
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  fontSize: width * .045,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      TextFormField(
                        controller: currentValue,
                        inputFormatters: [amountValidator],
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          prefix: Text(
                            currency,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w400,
                              fontSize: width * .04,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: TextStyle(fontSize: width * .03),
                          contentPadding: EdgeInsets.only(
                            left: width * .013,
                            right: width * .03,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: height * .05),
                      country == "Canada" ||
                              country == "United States" ||
                              country == "United Kingdom"
                          ?
                            //     Expanded(
                            // flex: 1,
                            // child:
                            Column(
                              children: <Widget>[
                                const Text(
                                  "Use this link to confirm your property value:",
                                ),
                                InkWell(
                                  onTap: () => {
                                    if (country == "Canada")
                                      launch(
                                        "https://wowa.ca/home-value-estimator",
                                      )
                                    else if (country == "United States")
                                      launch(
                                        "https://www.remax.com/home-value-estimates",
                                      )
                                    else if (country == "United Kingdom")
                                      launch(
                                        "https://www.zoopla.co.uk/house-prices/",
                                      ),
                                  },
                                  child: const Text(
                                    " Property Value Lookup",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            )
                          // )
                          : Container(),
                      SizedBox(height: height * .05),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(width * .01),
                          ),
                        ),
                        onPressed: saveEquity,
                        child: Text(
                          "Submit",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: width * .045,
                          ),
                        ),
                      ),
                      SizedBox(height: height * .01),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: width * .035,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              TextSpan(
                                text: "* ",
                                style: TextStyle(
                                  fontSize: width * .035,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const TextSpan(text: 'Fields are mandatory'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * .05),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool check() {
    bool match = false;
    var uniReg = RegExp(
      r"^[a-z0-9][a-z0-9\- ]{0,10}[a-z0-9]$",
      caseSensitive: false,
    );

    match = uniReg.hasMatch(zipcode.text.trim());
    return match;
  }

  verifyCode() async {
    addresses.clear();
    if (!check()) {
      Fluttertoast.showToast(
        msg: "Invalid Postcode/Zipcode. Please enter a correct code",
      );
      return;
    }
    setState(() {
      loading = true;
    });
    FocusScope.of(context).requestFocus(FocusNode());
    Fluttertoast.showToast(msg: "Searching...");
    var url = Uri.parse(
      "https://api.addressy.com/Capture/Interactive/Find/v1.10/json2.ws?Key=$keyAPI&Text=${zipcode.text}&Countries=$country",
    );

    var headers = {"Content-Type": "application/json"};

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      try {
        String data = response.body.toString();
        final regex = RegExp("\\{[^\\}]*\\}");
        final match = regex.allMatches(data).toList();
        var l = match.map((e) => e.group(0)).toList();
        for (var i = 0; i < match.length; i++) {
          var a = l[i];
          a = a!.replaceAll("Id:", '"Id":');
          a = a.replaceAll("Type:", '"Type":');
          a = a.replaceAll("Text:", '"Text":');
          a = a.replaceAll("Description:", '"Description":');
          a = a.replaceAll("Highlight:", '"Highlight":');

          Addressmodel addressmodel = Addressmodel.fromJSON(jsonDecode(a));
          if (addressmodel.type == "Postcode") {
            addresses.add(addressmodel);
          }
        }
        add = addresses.map((e) => e.text).toList();
        setState(() {
          loading = false;
        });
        dropdown(false);
      } catch (e) {
        Fluttertoast.showToast(msg: "Unable to find address");
      }
    } else {}
  }

  saveEquity() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (option == "Yes" && mortgage == "-Select-") {
      dialogBox.information(
        context,
        'Status',
        "Please select a mortgage balance",
      );
      return;
    }
    if (option == "-Select-" ||
        country == '-Select-' ||
        ((country == "Canada" ||
                country == "United States" ||
                country == "United Kingdom") &&
            zipcode.text.isEmpty) ||
        address.text.isEmpty ||
        currentValue.text.isEmpty) {
      dialogBox.information(
        context,
        'Status',
        "Please select an option for all mandatory fields",
      );
      return;
    }
    dialogBox.waiting(context, "Saving");

    var timer = Timer(const Duration(seconds: 40), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    var url = Uri.parse("$baseUrl/app/360/equity");
    var url2 = "$baseUrl/app/360/equity";
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    Map body = {
      "zip_code": zipcode.text ?? "",
      "ismortgage": option == "Yes" ? '1' : '0',
      "market_value": currentValue.text ?? "",
      "country": country,
      "location": address.text,
    };
    if (option == "Yes") {
      int index1 = mortgagesList.indexWhere((element) => element == mortgage);
      index1--;
      body["mortgage"] = mortgages[index1]["id"].toString();
      if (mortgages[index1]["main"] == 1) {
        body["dept"] = "-1";
      } else {
        body["dept"] = "0";
      }
    } else {
      body["mortgage"] = "0";
    }
    var response = await http.post(
      url,
      body: body,
      headers: {"Authorization": 'Bearer $token'},
    );

    if (response.statusCode == 400) {
      timer.cancel();
      Navigator.pop(context);
      dialogBox.information(context, 'Status', response.body);
      return null;
    }
    if (response.statusCode == 200) {
      var response = await dio.get(
        url2,
        options: Options(headers: {"Authorization": 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        var mapList = response.data["equity"];
        var mapListLite = response.data["equity_detail"];
        timer.cancel();

        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Equitydetails(mapList, mapListLite),
          ),
        );
      } else {
        Navigator.pop(context);
        dialogBox.information(context, "Status", "An error occured");
        timer.cancel();
      }
    } else {
      Navigator.pop(context);
      dialogBox.information(context, "Status", "An error occured");
      timer.cancel();
    }
  }

  void dropdown(bool tru) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        elevation: 5,
        title: Text(
          "Select an address",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: width * .06),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: height * .5,
              width: width * .9,
              child: Scrollbar(
                thumbVisibility: true,
                controller: scrollController,
                child: ListView.builder(
                  shrinkWrap: true,
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () async {
                      var url = Uri.parse(
                        "https://api.addressy.com/Capture/Interactive/Retrieve/v1/csv.ws?Key=$keyAPI&Id=${addresses[index].id}&Field1Format={{City}}&Field2Format=&Field3Format=&Field4Format=&Field5Format=&Field6Format=&Field7Format=&Field8Format=&Field9Format=&Field10Format=&Field11Format=&Field12Format=&Field13Format=&Field14Format=&Field15Format=&Field16Format=&Field17Format=&Field18Format=&Field19Format=&Field20Format=",
                      );
                      var url2 = Uri.parse(
                        "https://api.addressy.com/Capture/Interactive/Find/v1.10/json2.ws?Key=$keyAPI&Text=${zipcode.text.trim()}&Countries=$country&Container=${addresses[index].id}",
                      );
                      var headers = {"Content-Type": "application/json"};

                      if (addresses[index].type == "Address") {
                        var response = await http.get(url, headers: headers);

                        var body = response.body;
                        var list = body.split(",");
                        var l = list.sublist(56, list.length - 1);
                        var add = l.reduce(
                          (curr, next) =>
                              curr.length > next.length ? curr : next,
                        );
                        address.text = add.replaceAll("\n", " ");
                        Navigator.of(context, rootNavigator: true).pop();
                      } else {
                        var response = await http.get(url2, headers: headers);

                        if (response.statusCode == 200) {
                          addresses.clear();
                          String data = response.body.toString();

                          final regex = RegExp("\\{[^\\}]*\\}");
                          final match = regex.allMatches(data).toList();
                          var l = match.map((e) => e.group(0)).toList();

                          void processAddresses(
                            List<String> match,
                            List<String?> l,
                            List<Addressmodel> addresses,
                          ) {
                            for (var i = 0; i < match.length; i++) {
                              var a = l[i];

                              // Skip if `a` is null
                              if (a == null) {
                                print("Skipping null value at index $i");
                                continue;
                              }

                              // Apply replacements
                              a = a.replaceAll("Id:", '"Id":');
                              a = a.replaceAll("Type:", '"Type":');
                              a = a.replaceAll("Text:", '"Text":');
                              a = a.replaceAll(
                                "Description:",
                                '"Description":',
                              );
                              a = a.replaceAll("Highlight:", '"Highlight":');

                              // Decode JSON and create Addressmodel
                              try {
                                final addressJson = jsonDecode(a);
                                final addressmodel = Addressmodel.fromJSON(
                                  addressJson,
                                );
                                addresses.add(addressmodel);
                              } catch (e) {
                                print("Error decoding JSON at index $i: $e");
                              }
                            }
                          }

                          add = addresses.map((e) => e.text).toList();
                          Navigator.of(context, rootNavigator: true).pop();
                          dropdown(true);
                        }
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.all(width * .01),
                      child: Card(
                        elevation: 5,
                        child: Padding(
                          padding: EdgeInsets.all(width * .04),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  addresses[index].text,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: width * .05,
                                  ),
                                ),
                              ),
                              tru
                                  ? Container()
                                  : const Icon(Icons.arrow_forward_ios_rounded),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: height * .01),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Input address manually if you cannot find your address on the list",
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .03,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
