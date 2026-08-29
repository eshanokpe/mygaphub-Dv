import 'dart:async';
import 'dart:convert';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/screens/portfolio/portdashboard.dart';
import 'package:GapHub/screens/360/accounts/assets/presentation/add_homequity.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Assets extends StatefulWidget {
  const Assets({super.key});

  @override
  _AssetsState createState() => _AssetsState();
}

class _AssetsState extends State<Assets> {
  DialogBox dialogBox = DialogBox();
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
        centerTitle: true,
        title: Text(
          "Add Account: Assets",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: width * .040,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: width * .02,
              vertical: height * .01,
            ),
            child: Column(
              children: [
                Text(
                  "(Choose any of the type of asset you will like to add)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * .04,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: height * .1),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * .03),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const Portdashboard(investmentModal: true),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.zero,
                    height: height * .06,
                    width: width * .8,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Add an Investment',
                        style: TextStyle(
                          color: const Color(0xfff3f3f4),
                          fontWeight: FontWeight.w900,
                          fontSize: width * .05,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * .03),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * .03),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: () async {
                    dialogBox.waiting(context, "Loading");
                    var timer = Timer(const Duration(seconds: 40), () {
                      Navigator.pop(context);
                      dialogBox.information(
                        context,
                        'Status',
                        'Service timed out',
                      );
                      return;
                    });
                    var url = Uri.parse("$baseUrl/app/360/equity/info");
                    final prefs = await SharedPreferences.getInstance();
                    var token = prefs.getString('tokenDB');
                    var response = await http.get(
                      url,
                      headers: {"Authorization": 'Bearer $token'},
                    );

                    if (response.statusCode == 200) {
                      Map body = jsonDecode(response.body);
                      List mortgages = body["mortgages_available"];
                      List mortgagesList = mortgages
                          .map(
                            (e) =>
                                "${e["creditor_name"]} (${e["current_balance"]})"
                                    .replaceAllMapped(
                                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                      (Match m) => '${m[1]},',
                                    ),
                          )
                          .toList();
                      mortgagesList.insert(0, "-Select-");
                      context.read<Providers>().setMortgages(mortgages);
                      context.read<Providers>().setMortgagesList(mortgagesList);

                      List countries = body["countries"];
                      countries.insert(0, "-Select-");
                      context.read<Providers>().setCountries(countries);
                      timer.cancel();
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddHomeEquity(),
                        ),
                      );
                    } else {
                      timer.cancel();
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.zero,
                    height: height * .06,
                    width: width * .8,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Add Home Equity',
                        style: TextStyle(
                          color: const Color(0xfff3f3f4),
                          fontWeight: FontWeight.w900,
                          fontSize: width * .05,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
