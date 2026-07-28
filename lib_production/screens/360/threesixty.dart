import 'dart:async';
import 'package:GapHub/screens/others/dashboards/networkcard.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/screens/360/accounts/income/incomedash.dart';
import 'package:GapHub/screens/360/addaccount.dart';
import 'package:GapHub/screens/360/decider.dart';
import 'package:GapHub/screens/others/dashboards/dashboard.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/clock_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/screens/360/accounts/assetsAcc/assetdetails.dart';
import 'package:GapHub/screens/360/accounts/liabilities/liabilitydetails.dart';
import 'package:GapHub/screens/360/accounts/mortgage/mortgagedetails.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/screens/360/accounts/cash/cashdetails.dart';
import 'accounts/expenditure/expenditure.dart';
import 'accounts/income/income.dart';
import 'accounts/liabilities/liabilities.dart';
import 'accounts/liabilities/liabilityitem.dart';
import 'accounts/networth/networth.dart';
import 'accounts/networth/networthdetails.dart';
import 'accounts/philanthropy/philanthropy.dart';
import 'accounts/philanthropy/setgiving.dart';
import 'package:GapHub/models/analyticsinfo.dart';
import 'dart:convert';
import 'accounts/protection/protectiondetails.dart';
import 'accounts/retirement/retiredash.dart';
import 'components/addAccountBtn.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class Threesixty extends StatefulWidget {
  final bool unallocated;
  final int balance;
  final List data;
  const Threesixty({
    super.key,
    this.unallocated = false,
    this.balance = 0,
    this.data = const [],
  });
  @override
  _ThreesixtyState createState() => _ThreesixtyState();
}

class _ThreesixtyState extends State<Threesixty> {
  DialogBox dialogBox = DialogBox();
  Dio dio = Dio();
  var data;
  @override
  void initState() {
    super.initState();
  }

  cash() async {
    dialogBox.waiting(context, "Loading");
    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    var url = "$baseUrl/app/360/cash";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      var cashData = response.data["cash"];
      var seveng = response.data["seveng"];
      var cashDataLite = response.data["cash_detail"];
      var bespokes = response.data["bespokes"];
      context.read<Providers>().setcashData(cashData);
      context.read<Providers>().setcashDataLite(cashDataLite);
      context.read<Providers>().setcashseveng(seveng);
      context.read<Providers>().setcashbespokes(bespokes);
      timer.cancel();
      Navigator.pop(context);
      //Navigator.of(context).pushNamed('Cashdetails');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Cashdetails(cashData, cashDataLite, seveng, bespokes),
        ),
      );
    }
  }

  liability() async {
    var timer = Timer(const Duration(seconds: 20), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, "Loading");
    var url2 = Uri.parse('$baseUrl/app/seveng/edit');
    var url = "$baseUrl/app/360/liability";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    var response2 = await http.get(
      url2,
      headers: {"Authorization": 'Bearer $token'},
    );

    if (response.statusCode == 200 && response2.statusCode == 200) {
      List mapList = response.data["liabilities"];
      // print("mapList:$mapList");
      var mapListLite = response.data["liabilities_detail"];
      List seveng = response.data["seveng"];
      var bespokes = response.data["bespokes"];
      var isAllocated = response.data["audit"]["is_allocated"];
      var creditCurrent = "0";
      int creditCurrentInt = int.tryParse(creditCurrent) ?? 0;
      var cc = jsonDecode(response2.body);
      Analyticsinfo analyticsinfo = Analyticsinfo.fromJson(cc["data"]);
      creditCurrent = analyticsinfo.credit!["current"].toString();
      num total = 0;
      List real = [];
      if (seveng.isNotEmpty) {
        List<num> a = seveng
            .map((e) => num.parse(e["current"].toString()))
            .toList();

        for (var item in a) {
          real.add(int.parse(item.toString()));
        }
        for (var item in a) {
          total = total + item;
        }
      }
      Navigator.pop(context);
      timer.cancel();

      if (isAllocated.toString() == "1") {
        timer.cancel();
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Liabilitydetails(
              liabilityData: mapList,
              liabilityDataLite: mapListLite,
              seveng: seveng,
              bespokes: bespokes,
            ),
          ),
        );
      } else if (int.parse(creditCurrent.toString()) == 0) {
        timer.cancel();
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Liabilitydetails(
              liabilityData: mapList,
              liabilityDataLite: mapListLite,
              seveng: seveng,
              bespokes: bespokes,
            ),
          ),
        );
      } else if (total != int.parse(creditCurrent.toString())) {
        timer.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Threesixty(
              unallocated: true,
              data: seveng,
              balance: seveng.isEmpty
                  ? creditCurrentInt
                  : (creditCurrentInt - total).toInt(),
            ),
          ),
        );
      } else {
        Navigator.pop(context);
        // print("mapList:$mapList");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Liabilitydetails(
              liabilityData: mapList,
              liabilityDataLite: mapListLite,
              seveng: seveng,
              bespokes: bespokes,
            ),
          ),
        );
      }
    }
    timer.cancel();
  }

  mortgage() async {
    dialogBox.waiting(context, "Loading");
    var timer = Timer(const Duration(milliseconds: 30000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    var url = "$baseUrl/app/360/mortgage";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    var mapList = response.data["mortgages"];
    var seveng = response.data["seveng"];
    var mapListLite = response.data["mortgages_detail"];

    // context.read<Providers>().setcurrency(currency);
    if (response.statusCode == 200) {
      timer.cancel();
      // print(mapListLite);
      Navigator.pop(context);
      // Navigator.pop(context);
      // if (seveng[0]["credit_name"] == null &&
      //     seveng[0]["description"] == null) {
      //   timer.cancel();
      //   Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) => Mortgageitem(
      //                 item: seveng[0],
      //                 seven: true,
      //               )));
      // } else {
      timer.cancel();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Mortgagedetails(mapList, mapListLite, seveng),
        ),
      );
      // }
    }
  }

  assets() async {
    dialogBox.waiting(context, "Loading");
    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });

    var url = "$baseUrl/app/360/cash";
    var url2 = "$baseUrl/app/360/equity";
    var url3 = "$baseUrl/app/360/investment";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    var response2 = await dio.get(
      url2,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    var response3 = await dio.get(
      url3,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );

    if (response.statusCode == 200 && response2.statusCode == 200) {
      var equityList = response2.data["equity"];
      var equityListLite = response2.data["equity_detail"];
      var cashList = response.data["cash"];
      var cashListLite = response.data["cash_detail"];
      var seveng = response.data["seveng"];
      var bespokes = response.data["bespokes"];
      var invSum = response3.data["investment_sum"];
      print("invSum:$invSum");
      timer.cancel();
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Assetdetails(
            cashData: cashList,
            cashDataLite: cashListLite,
            seveng: seveng,
            equityData: equityList,
            equityDataLite: equityListLite,
            bespokes: bespokes,
            invSum: invSum,
          ),
        ),
      );
    }
  }

  protection() async {
    dialogBox.waiting(context, "Loading");
    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    var url = "$baseUrl/app/360/protection";
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    if (response.statusCode == 200) {
      timer.cancel();
      var mapList = response.data["protection"];
      var mapListLite = response.data["protection_detail"];
      context.read<Providers>().setProtectionList(mapList);
      context.read<Providers>().setProtectionListLite(mapListLite);
      // Navigator.pop(context);
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Protectiondetails()),
      );
    }
  }

  expenditure(currency) async {
    dialogBox.waiting(context, "Loading");
    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    var url = "$baseUrl/app/360/expenditure";
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    if (response.statusCode == 200) {
      timer.cancel();
      var mapList = response.data["expenditure"];
      var mapListLite = response.data["expenditure_detail"];
      context.read<Providers>().setExpenditureList(mapList);
      context.read<Providers>().setExpenditureListLite(mapListLite);
      Navigator.pop(context);
      // Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Expenditure()),
      );
    }
  }

  income() async {
    dialogBox.waiting(context, "Loading");

    try {
      var url = "$baseUrl/app/360/income";
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');
      var response = await dio.get(
        url,
        options: Options(headers: {"Authorization": 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        List assets = response.data["portfolio_asset"];
        List incomeData = response.data["incomes"];
        var incomeDataLite = response.data["income_detail"];

        var currentPortfolio = int.parse(
          response.data["income_info"]["current_portfolio"]
              // .round()
              .toString(),
        );

        List amounts = [];
        for (var i = 0; i < incomeData.length; i++) {
          amounts.add(incomeData[i]["amount"]);
        }
        num allocated = response.data["income_audit"] != null
            ? num.parse(
                response.data["income_audit"]["income_allocated"].toString(),
              )
            : 1;

        context.read<Providers>().setCurrentPortfolio(currentPortfolio);
        var portfolioDiff = response.data["income_info"]["portfolio_diff"];
        context.read<Providers>().setPortfolioDiff(portfolioDiff.toDouble());
        List<String> listofassets = ['-Select-'];
        for (var i = 0; i < assets.length; i++) {
          if (assets[i]["isArchive"] != 1) {
            listofassets.add(
              "${assets[i]["name"]} (${assets[i]["asset_currency"]}${assets[i]["monthly_roi"].toStringAsFixed(2)})"
                  .replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  ),
            );
          }
          context.read<Providers>().setAssets(listofassets);

          context.read<Providers>().setMapAsset(assets);
        }
        Navigator.pop(context);

        if (response.data["income_info"]["portfolio_diff"] > 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Income()),
          );
        } else {
          var incomes = response.data["incomes"] ?? [];
          var channels = response.data["income_channels"] ?? {};
          context.read<Providers>().addIncomeChart(
            response.data["income_chart"],
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Incomedash(
                incomeData,
                incomeDataLite,
                allocated,
                incomes: incomes,
                channels: channels,
              ),
            ),
          );
        }
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error: $e');
      Navigator.pop(context);
      dialogBox.information(
        context,
        'Error',
        'An error occurred. Please try again.',
      );
    }
  }

  retirement() async {
    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, "Loading");

    var url = "$baseUrl/app/360/retirement/roi";
    var url2 = "$baseUrl/app/360/retirement";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    var response2 = await dio.get(
      url2,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    context.read<Providers>().setretiredata(response.data);
    context.read<Providers>().setpensions(response2.data);
    if (response.statusCode == 200 && response2.statusCode == 200) {
      Navigator.pop(context);
      timer.cancel();
      //Navigator.of(context).pushNamed('Retiredash');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Retiredash(response.data, response2.data),
        ),
      );
    }
    timer.cancel();
  }

  philanthropy(currency) async {
    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, 'Loading');
    var url2 = "$baseUrl/app/360/philantrophy";

    final prefs = await SharedPreferences.getInstance();
    String? finalToken = prefs.getString('tokenDB');

    var response2 = await dio.get(
      url2,
      options: Options(headers: {"Authorization": 'Bearer $finalToken'}),
    );
    if (response2.statusCode == 200) {
      var grant = response2.data["data"]["grand"]["current"];
      print('grant:$grant');
      timer.cancel();
      Navigator.pop(context);
      var charity = response2.data["data"]["philantrophy"]["charity"];
      var familySupport =
          response2.data["data"]["philantrophy"]["family_support"];
      var personalCommitments =
          response2.data["data"]["philantrophy"]["personal_commitments"];
      var others = response2.data["data"]["philantrophy"]["others"];
      var setgiving = charity + familySupport + personalCommitments + others;
      print('setgiving:$setgiving');
      num allocated = num.parse(response2.data["grand"]["current"].toString());
      print('allocated:$allocated');

      if (grant != setgiving) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Setgiving(
              // double.parse(response2.data["grand"]["current"].toString()),
              response2.data,
            ),
          ),
        );

        context.read<Providers>().setphilanList(response2.data);
        context.read<Providers>().setcurrency(currency);
      } else {
        var grant = response2.data["data"]["grand"]["current"];
        var setgiving = response2.data["data"]["philantrophy_detail"]["values"];
        print('grant:$grant');
        print('setgiving:$setgiving');
        context.read<Providers>().setphilanList(response2.data);
        timer.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Philanthropy(response2.data, currency),
          ),
        );
      }
    } else {
      timer.cancel();
      Navigator.pop(context);
    }
  }

  networth(currency) async {
    bool contains = false;
    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, "Loading");
    var url = "$baseUrl/app/360/net";
    var url2 = "$baseUrl/app/360/equity";
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    var response2 = await dio.get(
      url2,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );

    Navigator.pop(context);
    // Navigator.pop(context);
    if (response.data["isNet"]["net_confirm"] == 0) {
      timer.cancel();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Networth(response.data)),
      );
    } else if (response.data["isNet"]["net_confirm"] == 1) {
      timer.cancel();

      print("contains:$contains");
      if (contains) {
        dropdown(context);
      } else {
        var values = response.data;
        print(values['net_detail']);
        var equity = response2.data['equity_detail']['sum'];
        //print('equity:$equity');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Networthdetails(
              item: response.data,
              equity: equity,
              currency: currency,
            ),
          ),
        );
      }
    }
  }

  void dropdown(BuildContext context) {
    showDialog(context: context, builder: (context) => const SelectSevenG());
  }

  @override
  Widget build(BuildContext context) {
    String currency = context.watch<Providers>().snapshotmodel.currency;
    data = context.watch<Providers>().recents;

    String currencyLib(int index) {
      String currency = widget.data[index]["currency"].toString();
      // String currency = s.substring(0, s.indexOf(" "));
      return currency;
    }

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

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
    bool contains = realColors.contains(0xff494949);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Personal Finance in 360°",
          style: TextStyle(fontSize: width * .035, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNav(4),
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          ListView(
            children: [
              SizedBox(height: height * .02),
              Text(
                "Welcome to your Personal Finance in 360°",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: width * .045,
                ),
              ),
              SizedBox(height: height * .02),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .03),
                child: Text(
                  "Recently Updated Tiles",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    fontSize: width * .05,
                  ),
                ),
              ),
              SizedBox(height: height * .03),
              data.isEmpty
                  ? Container(
                      child: Text(
                        "No Tile has been updated yet.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).primaryColor,
                          fontSize: width * .05,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: data.length,
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * .02),
                        child: Card(
                          elevation: 3,
                          color: const Color(0xff989898),
                          child: ListTile(
                            onTap: () {
                              String name = "${data[index]['account_name']}"
                                  .capitalize();
                              print("name:$name");
                              switch (name) {
                                case "Net":
                                  networth(currency);
                                  break;
                                case "Cash":
                                  cash();
                                  break;
                                case "Liabilities":
                                  liability();
                                  break;
                                case "Liability":
                                  liability();
                                  break;
                                case "Mortgage":
                                  mortgage();
                                  break;
                                case "Protection":
                                  protection();
                                  break;
                                case "Philantropy":
                                  philanthropy(currency);
                                  break;
                                case "Philanthropy":
                                  philanthropy(currency);
                                  break;
                                case "Expenditure":
                                  expenditure(currency);
                                  break;
                                case "Income":
                                  income();
                                  break;
                                case "Retirement":
                                  retirement();
                                  break;
                                default:
                              }
                            },
                            title: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "${data[index]['account_name']} - "
                                        .capitalize(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: width * .04,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "${data[index]['account_type']} - ",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: width * .04,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        "$currency${data[index]['sum'].toStringAsFixed(2)}"
                                            .replaceAllMapped(
                                              RegExp(
                                                r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                              ),
                                              (Match m) => '${m[1]},',
                                            ),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: width * .04,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: height * .05),
              const ClockWidget(0),
              SizedBox(height: height * .05),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .2),
                child: Addaccountbtn(width: width, index: "0"),
              ),
              SizedBox(height: height * .05),
            ],
          ),
          Visibility(
            visible: contains || widget.unallocated,
            child: Container(
              height: height,
              width: width,
              color: Colors.black.withOpacity(.8),
            ),
          ),
          Visibility(
            visible: contains,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * .02,
                vertical: height * .01,
              ),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Kindly validate all your 7G assumptions in order to view your 360°",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: width * .04,
                    ),
                  ),
                  SizedBox(height: height * .03),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Dashboard(index: 1),
                        ),
                      );
                    },
                    child: Text(
                      "Navigate to Analytics page now",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        fontSize: width * .04,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: widget.unallocated,
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * .02,
                  vertical: height * .02,
                ),
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Your Unallocated Credit Balance is: $currency${widget.balance}"
                          .replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          ),
                      style: TextStyle(
                        fontSize: width * .04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "(Allocate your balance to respective liability accounts)",
                      style: TextStyle(
                        fontSize: width * .03,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: height * .03),
                    SingleChildScrollView(
                      child: Container(
                        height: height * 0.4,
                        // height: height * widget.data.length / 11,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: widget.data.length,
                          itemBuilder: (context, index) => Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * .02,
                            ),
                            child: Card(
                              elevation: 3,
                              color: const Color(0xff989898),
                              child: ListTile(
                                onTap: () {
                                  var zeroBalance =
                                      widget.data[index]['current'] == 0
                                      ? true
                                      : false;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Liabilityitem(
                                        item: widget.data[index],
                                        zeroBalance: zeroBalance,
                                        seven: false,
                                        bespokes: false,
                                      ),
                                    ),
                                  );
                                },
                                title: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            "${widget.data[index]["creditor_name"]} - ",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            "${widget.data[index]['account_type']} - ",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "${currencyLib(index)}${widget.data[index]["current"]}"
                                            .replaceAllMapped(
                                              RegExp(
                                                r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                              ),
                                              (Match m) => '${m[1]},',
                                            ),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    widget.balance == 0
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  width * .01,
                                ),
                              ),
                            ),
                            onPressed: () async {
                              dialogBox.waiting(context, "Saving");

                              var timer = Timer(
                                const Duration(milliseconds: 20000),
                                () {
                                  Navigator.pop(context);
                                  dialogBox.information(
                                    context,
                                    'Status',
                                    'Service timed out',
                                  );
                                  return;
                                },
                              );
                              final prefs =
                                  await SharedPreferences.getInstance();
                              var token = prefs.getString('tokenDB');
                              var url =
                                  "$baseUrl/app/360/liability?crd=ajkmzxjkcnkfsnznnjksxnjnkcnjc&alo=azsjkhbdjcbjszbhjbxjhcbjbhhbjghdx";
                              var response = await dio.get(
                                url,
                                options: Options(
                                  headers: {"Authorization": 'Bearer $token'},
                                ),
                              );

                              if (response.statusCode == 200) {
                                Navigator.pop(context);
                                Navigator.pop(context);

                                timer.cancel();
                                liability();
                              } else {
                                Navigator.pop(context);
                                timer.cancel();
                              }
                            },
                            child: Text(
                              "Submit",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: width * .045,
                              ),
                            ),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  width * .01,
                                ),
                              ),
                            ),
                            onPressed: () {
                              context.read<Providers>().setLiabilitiesbalance(
                                widget.balance,
                              );
                              context
                                  .read<Providers>()
                                  .setLiabilitiesunallocated(true);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Liabilities(
                                    unallocated: true,
                                    balance: widget.balance,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              "Add a Credit Account",
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
            ),
          ),
        ],
      ),
    );
  }
}
