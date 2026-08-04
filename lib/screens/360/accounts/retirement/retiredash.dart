import 'package:GapHub/screens/360/accounts/retirement/retirement.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/ficard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/acquisition/ganp/ganp.dart';
import 'package:GapHub/screens/acquisition/reap/reap.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'viewdetails.dart';
import 'dart:convert';
import 'retarchives.dart';
import 'dart:async';
import 'package:GapHub/models/ganpserver.dart';
import 'package:dio/dio.dart';
import 'package:GapHub/widgets/piechart.dart';
import 'retirementdetails.dart';

class Retiredash extends StatefulWidget {
  final Map data;
  final Map pensions;
  const Retiredash(this.data, this.pensions, {super.key});

  @override
  _RetiredashState createState() => _RetiredashState(data);
}

class _RetiredashState extends State<Retiredash> {
  List<String> colors = [
    '0Xff581845',
    '0XFFFF5733',
    "0XFFFFC300",
    "0XFFDAF7A6",
    "0XFF2471A3",
    "0XFF148F77",
    "0XFF7D6608",
    "0XFF17202A",
    "0XFFFFC300",
    '0xffED3237',
    '0xff494949',
    '0xff000000',
  ];
  double montInv = 0;
  bool loading = false;
  Map data;
  double roce = 0;
  Dio dio = Dio();
  DialogBox dialogBox = DialogBox();
  _RetiredashState(this.data);

  // Define a function to convert a string to the corresponding enum value
  stringToAverage(String value) {
    print("value:$value");
    switch (value) {
      case 'seed':
        return 'seed';
      case 'expenditure':
        return 'expenditure';
      // Handle other cases as needed
      default:
        return 'seed'; // Default value
    }
  }

  String _selectedAverage = 'seed';
  @override
  void initState() {
    super.initState();
    _selectedAverage = widget.data["improve_status"]["seed_type"];

    stringToAverage(widget.data["improve_status"]["seed_type"]);
    montInv = double.parse(data["improve_status"]["investment"].toString());
    roce = double.parse(data["improve_status"]["roce"].toString());
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

    String currency = context
        .watch<Providers>()
        .snapshotmodel
        .currency
        .toString();
    String current = context
        .watch<Providers>()
        .snapshotmodel
        .snapshot["currentper"]
        .toString();
    current = current.replaceAll(',', '');
    String time = context
        .watch<Providers>()
        .snapshotmodel
        .snapshot["timeper"]
        .toString();
    time = time.replaceAll(',', '');
    double currentPer = double.parse(current);
    double timePer = double.parse(time);
    var pensions = widget.pensions["retirement"];
    // print(pensions[0]);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: RichText(
          text: TextSpan(
            children: const [
              TextSpan(text: 'Financial Independence (Not '),
              TextSpan(
                text: 'Retirement',
                style: TextStyle(
                  // decoration: TextDecoration.lineThrough,
                  color: Colors.red,
                ),
              ),
              TextSpan(text: ')'),
            ],
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: width * .04,
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(4),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              SizedBox(height: height * .01),
              currentPer > 1
                  ? Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: width * .02,
                        vertical: height * .01,
                      ),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        border: Border.all(color: const Color(0xffED3237)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Congratulations! You are Financially Independent!!',
                        style: TextStyle(
                          fontSize: width * .035,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Container(),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * .03,
                    vertical: height * .02,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width * .01),
                      border: Border.all(
                        // color: Theme.of(context).primaryColor,
                      ),
                    ),
                    child: Text(
                      "Financial independence is a smarter way to retire and still be buzzing with LIFE!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        // color: Theme.of(context).primaryColor,
                        fontSize: width * .04,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * .03),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .03),
                child: FiCard(width: width, height: height, yes: true),
              ),
              SizedBox(height: height * .03),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * .03,
                  vertical: height * .01,
                ),
                child: Card(
                  color: Colors.white,
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * .03,
                      vertical: height * .01,
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Opportunities for You",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: width * .04,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        // SizedBox(
                        //   height: height * .03,
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  getGanp();
                                },
                                child: Image.asset("assets/images/ganp.png"),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Reap(),
                                  ),
                                ),
                                child: Image.asset("assets/images/reap.png"),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Income: $currency 1,800",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: width * .04,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "Capital Required: $currency 1,000",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: width * .04,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * .05),
              currentPer >= 100 && timePer >= 100
                  ? Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(width * .04),
                          child: Container(
                            padding: EdgeInsets.all(width * .02),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(width * .01),
                              color: Theme.of(context).primaryColor,
                            ),
                            child: Text(
                              "CONGRATULATIONS! You are Financially Independent!!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: width * .04,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          "Now, concentrate on expanding your wealth for posterity! Acquire more assets for your portfolio.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: width * .04,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: height * .05),
                      ],
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * .03,
                            vertical: height * .01,
                          ),
                          child: Card(
                            elevation: 5,
                            color: AppColors.cardColor,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: width * .03,
                                vertical: height * .01,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          "Time to Financial Independence:",
                                          style: TextStyle(
                                            fontSize: width * .04,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: width * .03),
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      width * .01,
                                                    ),
                                              ),
                                              child: Text(
                                                "${double.parse(data["roi_detail"]["time_finiancial"].toString()).round()}",
                                                style: TextStyle(
                                                  fontSize: width * .04,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              " Years",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: width * .04,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Align(
                                  //   alignment: Alignment.centerRight,
                                  //   child: TextButton(
                                  //       onPressed: () async {
                                  //         Navigator.push(
                                  //             context,
                                  //             MaterialPageRoute(
                                  //               builder: (context) =>
                                  //                   Viewdetails(data),
                                  //             ));
                                  //       },
                                  //       child: Text("View Details",
                                  //           style: TextStyle(
                                  //               decoration:
                                  //                   TextDecoration.underline,
                                  //               fontSize: width * .035,
                                  //               fontWeight: FontWeight.w500))),
                                  // ),
                                  SizedBox(
                                    height: height * .05,
                                    child: const Divider(thickness: 2),
                                  ),
                                  Center(
                                    child: Text(
                                      "Thinking of investing more with higher ROI%",
                                      style: TextStyle(
                                        fontSize: width * .04,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      "Use the +/- buttons below",
                                      style: TextStyle(
                                        fontSize: width * .035,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: height * .05),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Monthly Asset Portfolio Income (API) needed",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: width * .04,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: height * .01),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Card(
                                      elevation: 5,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "$currency${double.parse(data["improve_status"]["monthly_asset"].toString()).toStringAsFixed(2)}"
                                              .replaceAllMapped(
                                                RegExp(
                                                  r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                                ),
                                                (Match m) => '${m[1]},',
                                              ),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                            fontSize: width * .04,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: <Widget>[
                                      ListTile(
                                        title: Text(
                                          "Average SEED Total",
                                          style: TextStyle(
                                            fontSize: width * .04,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        trailing: Radio(
                                          value: 'seed',
                                          groupValue: _selectedAverage,
                                          onChanged: (String? value) {
                                            setState(() {
                                              _selectedAverage = value ?? '';
                                              String selectedAverageString =
                                                  _selectedAverage.toString();
                                              print(
                                                "Selected Average: $selectedAverageString",
                                              );
                                            });
                                          },
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                          "Average Monthly Expenditure",
                                          style: TextStyle(
                                            fontSize: width * .04,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        trailing: Radio(
                                          value: 'expenditure',
                                          groupValue: _selectedAverage,
                                          onChanged: (String? value) {
                                            setState(() {
                                              _selectedAverage = value ?? '';
                                              String selectedAverageString =
                                                  _selectedAverage.toString();
                                              print(
                                                "Selected Average: $selectedAverageString",
                                              );
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: height * .05,
                                    child: const Divider(thickness: 1.5),
                                  ),
                                  Text(
                                    "How much can you set aside monthly for investments",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: width * .035,
                                    ),
                                  ),
                                  SizedBox(height: height * .01),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        iconSize: width * .1,
                                        icon: Image.asset(
                                          "assets/images/minus.png",
                                          color: montInv == 0
                                              ? Colors.grey
                                              : Colors.blue,
                                        ),
                                        onPressed: montInv == 0
                                            ? null
                                            : () {
                                                setState(() {
                                                  montInv = montInv - 10;
                                                });
                                              },
                                      ),
                                      SizedBox(width: width * .05),
                                      Text(
                                        "$currency $montInv".replaceAllMapped(
                                          RegExp(
                                            r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                          ),
                                          (Match m) => '${m[1]},',
                                        ),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blue,
                                          fontSize: width * .06,
                                        ),
                                      ),
                                      SizedBox(width: width * .05),
                                      IconButton(
                                        iconSize: width * .1,
                                        icon: Image.asset(
                                          "assets/images/add.png",
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            montInv = montInv + 10;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: height * .05,
                                    child: const Divider(thickness: 1.5),
                                  ),
                                  Text(
                                    "What is your expected Return on Capital Employed (ROCE)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: width * .035,
                                    ),
                                  ),
                                  SizedBox(height: height * .01),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        iconSize: width * .1,
                                        icon: Image.asset(
                                          "assets/images/minus.png",
                                          color: roce == 0
                                              ? Colors.grey
                                              : Colors.blue,
                                        ),
                                        onPressed: roce == 0
                                            ? null
                                            : () {
                                                setState(() {
                                                  roce = roce - 1;
                                                });
                                              },
                                      ),
                                      SizedBox(width: width * .06),
                                      Text(
                                        "$roce%",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blue,
                                          fontSize: width * .065,
                                        ),
                                      ),
                                      SizedBox(width: width * .06),
                                      IconButton(
                                        iconSize: width * .1,
                                        icon: Image.asset(
                                          "assets/images/add.png",
                                          color: roce == 100
                                              ? Colors.grey
                                              : Colors.blue,
                                        ),
                                        onPressed: roce == 100
                                            ? null
                                            : () {
                                                setState(() {
                                                  roce = roce + 1;
                                                });
                                              },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height * .03),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * .09,
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            width * .02,
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          loading = !loading;
                                        });
                                        var url = Uri.parse(
                                          "$baseUrl/app/360/improve/roi",
                                        );
                                        // var url = "$baseUrl/app/360/improve/roi";
                                        var url2 =
                                            "$baseUrl/app/360/retirement/roi";

                                        final prefs =
                                            await SharedPreferences.getInstance();
                                        var token = prefs.getString('tokenDB');
                                        String selectedAverageString =
                                            _selectedAverage.toString();
                                        var response = await http.post(
                                          url,
                                          body: {
                                            "roce": roce.toString(),
                                            "investment": montInv.toString(),
                                            "seed_type": selectedAverageString,
                                          },
                                          headers: {
                                            "Authorization": 'Bearer $token',
                                          },
                                        );
                                        if (response.statusCode == 200) {
                                          var response2 = await dio.get(
                                            url2,
                                            options: Options(
                                              headers: {
                                                "Authorization":
                                                    'Bearer $token',
                                              },
                                            ),
                                          );
                                          if (response2.statusCode == 200) {
                                            data = response2.data;
                                            setState(() {
                                              loading = !loading;
                                            });
                                            Fluttertoast.showToast(
                                              msg: "Updated Successfully",
                                            );
                                          }
                                        } else {}
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              loading
                                                  ? 'Updating'
                                                  : 'Update Result',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: width * .05,
                                              ),
                                            ),
                                            SizedBox(
                                              width: !loading ? 0 : width * .05,
                                            ),
                                            loading
                                                ? SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: CircularProgressIndicator(
                                                      backgroundColor: Colors
                                                          .white
                                                          .withOpacity(.6),
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(
                                                            Colors.white
                                                                .withOpacity(
                                                                  .6,
                                                                ),
                                                          ),
                                                      strokeWidth: 1.2,
                                                    ),
                                                  )
                                                : const SizedBox(height: 0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * .05,
                                    child: const Divider(thickness: 2.5),
                                  ),
                                  pensions.isEmpty
                                      ? Container(
                                          child: Column(
                                            children: [
                                              Text(
                                                "No Pension Account created yet",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: width * .05,
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          Retirement(
                                                            treesisty: true,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  "Add Pension Account",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                    fontSize: width * .04,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "Your Pension Pot (Accrued Income = $currency${widget.pensions["retirement_detail"]["sum"]})"
                                                        .replaceAllMapped(
                                                          RegExp(
                                                            r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                                          ),
                                                          (Match m) =>
                                                              '${m[1]},',
                                                        ),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      decoration: TextDecoration
                                                          .underline,
                                                      // color: Colors.blue,
                                                      fontSize: width * .04,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.list,
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                  ),
                                                  onPressed: () async {
                                                    dialogBox.waiting(
                                                      context,
                                                      "Opening",
                                                    );
                                                    var url =
                                                        "$baseUrl/app/360/retirement?archive=all";
                                                    final prefs =
                                                        await SharedPreferences.getInstance();
                                                    var token = prefs.getString(
                                                      'tokenDB',
                                                    );
                                                    var response = await dio.get(
                                                      url,
                                                      options: Options(
                                                        headers: {
                                                          "Authorization":
                                                              'Bearer $token',
                                                        },
                                                      ),
                                                    );

                                                    if (response.statusCode ==
                                                        200) {
                                                      Navigator.pop(context);
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Retarchives(
                                                                response.data,
                                                              ),
                                                        ),
                                                      );
                                                    } else {
                                                      Navigator.pop(context);
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: height * .03),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics: const ScrollPhysics(),
                                              itemCount: pensions.length,
                                              itemBuilder: (context, index) => Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: width * .02,
                                                ),
                                                child: Card(
                                                  color: const Color(
                                                    0xff989898,
                                                  ),
                                                  elevation: 3,
                                                  child: InkWell(
                                                    onTap: () {
                                                      // print("pensions: ${pensions[index]}");
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Retirementdetails(
                                                                data:
                                                                    pensions[index],
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 1,
                                                          child: Container(
                                                            height:
                                                                height * .07,
                                                            color: Color(
                                                              int.parse(
                                                                colors[index],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 40,
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      width *
                                                                      .03,
                                                                ),
                                                            height:
                                                                height * .07,
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    child: RichText(
                                                                      text: TextSpan(
                                                                        children: [
                                                                          TextSpan(
                                                                            text:
                                                                                "${pensions[index]['name'].toUpperCase()} - ",
                                                                            style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize:
                                                                                  width *
                                                                                  .04,
                                                                              fontWeight: FontWeight.w400,
                                                                            ),
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                "${pensions[index]['pension_type']} - ",
                                                                            style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize:
                                                                                  width *
                                                                                  .04,
                                                                              fontWeight: FontWeight.w900,
                                                                            ),
                                                                          ),
                                                                          TextSpan(
                                                                            text: "$currency${pensions[index]['current']}".replaceAllMapped(
                                                                              RegExp(
                                                                                r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                                                              ),
                                                                              (
                                                                                Match
                                                                                m,
                                                                              ) => '${m[1]},',
                                                                            ),
                                                                            style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize:
                                                                                  width *
                                                                                  .04,
                                                                              fontWeight: FontWeight.w400,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Image.asset(
                                                                    'assets/images/chevron_right.png',
                                                                    height:
                                                                        width *
                                                                        .035,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  SizedBox(height: height * .05),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical: height * .01,
                                        horizontal: width * .03,
                                      ),
                                      backgroundColor: Theme.of(
                                        context,
                                      ).primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          width * .02,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              Retirement(treesisty: true),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Add Pension Account",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: width * .05,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * .05,
                                    child: const Divider(thickness: 2),
                                  ),
                                  widget.pensions["retirement"].isNotEmpty
                                      ? Column(
                                          children: [
                                            Center(
                                              child: Text(
                                                "Pension Distribution",
                                                style: TextStyle(
                                                  // decoration: TextDecoration.underline,
                                                  fontSize: width * .06,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                            Piechart(
                                              labels: widget
                                                  .pensions["retirement_detail"]["labels"],
                                              values:
                                                  (widget.pensions["retirement_detail"]["values"]
                                                          as List)
                                                      .map(
                                                        (value) =>
                                                            double.tryParse(
                                                              value.toString(),
                                                            ) ??
                                                            0.0,
                                                      )
                                                      .toList(),
                                              percent:
                                                  (widget.pensions["retirement_detail"]["percentages"]
                                                          as List)
                                                      .map(
                                                        (percent) =>
                                                            double.tryParse(
                                                              percent
                                                                  .toString(),
                                                            ) ??
                                                            0.0,
                                                      )
                                                      .toList(),
                                              colors: colors,
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  Visibility(
                                    visible: widget
                                        .pensions["retirement"]
                                        .isNotEmpty,
                                    child: SizedBox(
                                      height: height * .05,
                                      child: const Divider(thickness: 2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  getGanp() async {
    var timer = Timer(const Duration(milliseconds: 40000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });

    try {
      dialogBox.waiting(context, 'Loading');
      var url = Uri.parse(
        "$assetBaseUrl/ganp/countries?token=xnbbnxbcbvjhnbkgvnmbbnfmohbvjcfgjmcbjmhnomcfjnomnpamqasxmbcvbvnfvbcfhfbvhjjjkfjknfvbiolckojinkjondodnglhdn",
      );
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var url3 = "$baseUrl/app/acquisition/favourite/ganp";
        final prefs = await SharedPreferences.getInstance();
        var token = prefs.getString('tokenDB');
        var response3 = await dio.get(
          url3,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );
        context.read<Providers>().setFavoritesG(response3.data["cultivations"]);
        Ganpcountries ganpcountries = Ganpcountries.fromJson(
          jsonDecode(response.body),
        );

        context.read<Providers>().setGanpCountryServer(ganpcountries.countries);
        timer.cancel();
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Ganp(ganpcountries.countries),
          ),
        );
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
