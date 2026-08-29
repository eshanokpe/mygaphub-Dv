import 'dart:async';
import 'package:GapHub/screens/360/accounts/income/incomedash.dart';
import 'package:GapHub/screens/360/accounts/assets/presentation/assetdetails.dart';
import 'package:GapHub/screens/360/accounts/liabilities/liabilitydetails.dart';
import 'package:GapHub/screens/360/accounts/mortgage/mortgagedetails.dart';
import 'package:GapHub/screens/360/accounts/investment/investdash.dart';
import 'package:GapHub/screens/360/accounts/philanthropy/philanthropy.dart';
import 'package:GapHub/screens/360/accounts/philanthropy/setgiving.dart';
import 'package:GapHub/screens/360/decider.dart';
import 'package:GapHub/screens/360/iLAB/ilab.dart';
import 'package:GapHub/screens/360/threesixty.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:GapHub/models/analyticsinfo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/screens/360/accounts/cash/cashdetails.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/360/accounts/retirement/presentation/retiredash.dart';
import '../screens/360/accounts/networth/networthdetails.dart';
import '../screens/360/accounts/networth/networth.dart';
import '../screens/acquisition/actionplan/presentation/action_plan_strategy.dart';

class ClockWidget extends StatelessWidget {
  final int index;
  const ClockWidget(this.index, {super.key});
  @override
  Widget build(BuildContext context) {
    String currency = context.watch<Providers>().snapshotmodel.currency;

    DialogBox dialogBox = DialogBox();
    Dio dio = Dio();

    cash() async {
      var timer = Timer(const Duration(seconds: 40), () {
        Navigator.pop(context);
        dialogBox.information(context, 'Status', 'Service timed out');
        return;
      });
      dialogBox.waiting(context, "Loading");
      var url = "$baseUrl/app/360/cash";

      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');
      var response = await dio.get(
        url,
        options: Options(headers: {"Authorization": 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        var mapList = response.data["cash"];
        var mapListLite = response.data["cash_detail"];
        var seveng = response.data["seveng"];
        var bespokes = response.data["bespokes"];
        context.read<Providers>().setcashData(mapList);
        context.read<Providers>().setcashDataLite(mapListLite);
        context.read<Providers>().setcashseveng(seveng);
        context.read<Providers>().setcashbespokes(bespokes);

        Navigator.pop(context);
        Navigator.pop(context);

        timer.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                Cashdetails(mapList, mapListLite, seveng, bespokes),
          ),
        );
      }
      timer.cancel();
    }

    income() async {
      dialogBox.waiting(context, "Loading");

      var timer = Timer(const Duration(seconds: 40), () {
        Navigator.pop(context);
        dialogBox.information(context, 'Status', 'Service timed out');
        return;
      });
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

        int currentPortfolio = int.parse(
          response.data["income_info"]["current_portfolio"].round().toString(),
        );
        context.read<Providers>().setCurrentPortfolio(currentPortfolio);

        List amounts = [];
        for (var i = 0; i < incomeData.length; i++) {
          amounts.add(incomeData[i]["amount"]);
        }

        int allocated = 1; // Default value
        if (response.data["income_audit"] != null) {
          try {
            allocated = int.parse(
              response.data["income_audit"]["income_allocated"].toString(),
            );
          } catch (e) {
            print("Error parsing income_allocated: $e");
          }
        }

        num portfolioDiff = response.data["income_info"]["portfolio_diff"];
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
        timer.cancel();
        if (response.data["income_info"]["portfolio_diff"] > 0) {
          // Navigator.of(context).pushNamed('Income');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Decider("Income")),
          );
        } else {
          var incomes = response.data["incomes"] ?? [];
          var channels = response.data["income_channels"] ?? {};
          context.read<Providers>().addIncomeChart(
            response.data["income_chart"],
          );
          //context.read<Providers>().setFavoritesG(reapganp);
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
        timer.cancel();
      }
    }

    liability() async {
      var timer = Timer(const Duration(milliseconds: 20000), () {
        Navigator.pop(context);
        dialogBox.information(context, 'Status', 'Service timed out');
        return;
      });
      dialogBox.waiting(context, "Loading");
      var url2 = Uri.parse('$baseUrl/app/seveng/edit');
      var url = "$baseUrl/app/360/liability";

      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');
      try {
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
          var mapListLite = response.data["liabilities_detail"];
          List seveng = response.data["seveng"];
          var bespokes = response.data["bespokes"];
          var isAllocated = response.data["audit"]["is_allocated"];
          var creditCurrent = "0";
          var cc = jsonDecode(response2.body);
          Analyticsinfo analyticsinfo = Analyticsinfo.fromJson(cc["data"]);
          creditCurrent = analyticsinfo.credit["current"].toString();
          num total = 0;
          List real = [];
          if (seveng.isNotEmpty) {
            var a = seveng.map((e) => e["current"]).toList();
            // var a = seveng.map((e) => e["current"].round()).toList();

            for (var item in a) {
              real.add(int.parse(item.toString()));
            }

            for (var item in a) {
              total += num.parse(item);
              print('test2');
            }
          }
          print("dataLia:$cc");

          Navigator.pop(context);
          timer.cancel();
          if (isAllocated.toString() == "1") {
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Threesixty(
                  unallocated: true,
                  data: seveng,
                  balance: seveng.isEmpty
                      ? int.parse(creditCurrent)
                      : (int.parse(creditCurrent) - total).toInt(),
                ),
              ),
            );
          } else {
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
          }
        }
        timer.cancel();
      } catch (e) {
        print("e:$e");
        timer.cancel();
        Navigator.pop(context);
        dialogBox.information(
          context,
          'Status',
          'Something went wrong try again',
        );
      }
    }

    mortgage() async {
      var timer = Timer(const Duration(seconds: 40), () {
        Navigator.pop(context);
        dialogBox.information(context, 'Status', 'Service timed out');
        return;
      });
      dialogBox.waiting(context, "Loading");

      var url = "$baseUrl/app/360/mortgage";

      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');
      var response = await dio.get(
        url,
        options: Options(headers: {"Authorization": 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        var mapList = response.data["mortgages"];
        var mapListLite = response.data["mortgages_detail"];
        var seveng = response.data["seveng"];

        Navigator.pop(context);

        timer.cancel();
        // if (seveng[0]["creditor_name"] != null &&
        //     seveng[0]["description"] != null) {
        //   Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //           builder: (context) => Mortgageitem(
        //                 item: seveng[0],
        //                 seven: true,
        //               )));
        // } else {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Mortgagedetails(mapList, mapListLite, seveng),
          ),
        );
        // }
      }
      timer.cancel();
    }

    assets() async {
      var timer = Timer(const Duration(seconds: 40), () {
        Navigator.pop(context);
        dialogBox.information(context, 'Status', 'Service timed out');
        return;
      });
      dialogBox.waiting(context, "Loading");

      var url = "$baseUrl/app/360/cash";
      var url2 = "$baseUrl/app/360/equity";
      var url3 = "$baseUrl/app/360/investment";
      var url4 = "$baseUrl/app/360/retirement";

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
      var response4 = await dio.get(
        url4,
        options: Options(headers: {"Authorization": 'Bearer $token'}),
      );

      if (response.statusCode == 200 &&
          response2.statusCode == 200 &&
          response3.statusCode == 200) {
        var equityList = response2.data["equity"];
        var equityListLite = response2.data["equity_detail"];
        var cashList = response.data["cash"];
        var cashListLite = response.data["cash_detail"];
        var seveng = response.data["seveng"];
        var bespokes = response.data["bespokes"];
        var invSum = response3.data['data']["investment_sum"];
        var braidTable = response3.data['data']['braid_table'];
        var pensions = response4.data['retirement_detail'];
        context.read<Providers>()
          ..setequityList(equityList)
          ..setequityDetail(equityListLite)
          ..setcashDataLite(cashListLite)
          ..setcashData(cashList)
          ..setpensions(pensions);
        Navigator.pop(context);
        Navigator.pop(context);
        timer.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                Assetdetails(seveng: seveng, bespokes: bespokes),
          ),
        );
      }
      timer.cancel();
    }

    protection() async {
      var timer = Timer(const Duration(seconds: 40), () {
        Navigator.pop(context);
        dialogBox.information(context, 'Status', 'Service timed out');
        return;
      });
      dialogBox.waiting(context, "Loading");
      var url = "$baseUrl/app/360/protection";
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');
      var response = await dio.get(
        url,
        options: Options(headers: {"Authorization": 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        var mapList = response.data["protection"];
        var mapListLite = response.data["protection_detail"];
        context.read<Providers>().setProtectionList(mapList);
        context.read<Providers>().setProtectionListLite(mapListLite);
        Navigator.pop(context);
        timer.cancel();
        Navigator.of(context).pushNamed('Protectiondetails');
      }
      timer.cancel();
    }

    philanthropy(currency) async {
      var timer = Timer(const Duration(seconds: 40), () {
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
        context.read<Providers>().setphilanList(response2.data);
        var grant = response2.data["data"]["grand"]["current"];

        //var setgiving = response2.data["data"]["philantrophy_detail"]["values"];

        timer.cancel();
        Navigator.pop(context);
        var charity = response2.data["data"]["philantrophy"]["charity"];
        var familySupport =
            response2.data["data"]["philantrophy"]["family_support"];
        var personalCommitments =
            response2.data["data"]["philantrophy"]["personal_commitments"];
        var others = response2.data["data"]["philantrophy"]["others"];
        var setgiving =
            int.tryParse(charity)! +
            int.tryParse(familySupport)! +
            int.tryParse(personalCommitments)! +
            int.tryParse(others)!;

        print('setgiving:$setgiving');

        if (int.tryParse(grant) == setgiving) {
          print('grant:$grant');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Philanthropy(response2.data, currency),
            ),
          );
          timer.cancel();
          context.read<Providers>().setphilanList(response2.data);
        } else if (grant != setgiving) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Setgiving(response2.data)),
          );
          context.read<Providers>().setphilanList(response2.data);
          context.read<Providers>().setcurrency(currency);
          var grant = response2.data["data"]["grand"]["current"];
          print('grant222:$grant');
        }
      } else {
        timer.cancel();
        Navigator.pop(context);
      }
    }

    retirement() async {
      var timer = Timer(const Duration(seconds: 40), () {
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
      context.read<Providers>().setretiredata(response.data['data']);
      context.read<Providers>().setpensions(response2.data['data']);
      if (response.statusCode == 200 && response2.statusCode == 200) {
        Navigator.pop(context);

        timer.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Retiredash()),
        );
      } else {
        Navigator.pop(context);
      }
      timer.cancel();
    }

    expenditure() async {
      var timer = Timer(const Duration(seconds: 40), () {
        Navigator.pop(context);
        dialogBox.information(context, 'Status', 'Service timed out');
        return;
      });
      dialogBox.waiting(context, "Loading");
      var url = "$baseUrl/app/360/expenditure";
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');
      var response = await dio.get(
        url,
        options: Options(headers: {"Authorization": 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        var mapList = response.data["data"]["expenditure"];
        var mapListLite = response.data["data"]["expenditure_detail"];
        context.read<Providers>().setExpenditureList(mapList);
        context.read<Providers>().setExpenditureListLite(mapListLite);
        print('mapListLite:$mapListLite');
        Navigator.pop(context);
        timer.cancel();
        Navigator.of(context).pushNamed('Expenditure');
      }
      timer.cancel();
    }

    Orientation orientation = MediaQuery.of(context).orientation;

    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Center(
        child: Stack(
          children: [
            Container(
              height: width,
              width: width,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
            ),
            Positioned(
              top: width * .4,
              left: width * .4,
              child: InkWell(
                child: Image.asset(
                  'assets/images/wheel.png',
                  height: width * .2,
                ),
                onTap: () async {
                  // --- Start of new robust handling ---
                  bool isLoadingDialogPopped = false;
                  Timer? timer;

                  void safePopLoadingDialog() {
                    if (context.mounted &&
                        Navigator.canPop(context) &&
                        !isLoadingDialogPopped) {
                      // Check if a dialog is present
                      Navigator.pop(context); // Pop the "Loading" dialog
                      isLoadingDialogPopped = true;
                    }
                  }

                  void showInfoDialog(String title, String message) {
                    if (context.mounted) {
                      // Ensure widget is still in the tree
                      dialogBox.information(context, title, message);
                    }
                  }

                  timer = Timer(const Duration(seconds: 40), () {
                    if (context.mounted && !isLoadingDialogPopped) {
                      safePopLoadingDialog();
                      showInfoDialog('Status', 'Service timed out');
                    }
                  });
                  // --- End of new robust handling ---

                  dialogBox.waiting(context, "Loading");

                  try {
                    var url = "$baseUrl/app/360/ilab";
                    final prefs = await SharedPreferences.getInstance();
                    var token = prefs.getString('tokenDB');

                    if (token == null) {
                      safePopLoadingDialog();
                      timer.cancel();
                      showInfoDialog(
                        'Authentication Error',
                        'Session expired. Please log in again.',
                      );
                      return;
                    }

                    var response = await dio.get(
                      url,
                      options: Options(
                        headers: {"Authorization": 'Bearer $token'},
                      ),
                    );

                    safePopLoadingDialog(); // Pop loading dialog as soon as API call is done
                    timer.cancel();

                    if (response.statusCode == 200) {
                      if (context.mounted) {
                        context.read<Providers>().setIlabdata(response.data);
                        print(
                          'iLab data fetched successfully',
                        ); // More informative print
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Ilab()),
                        );
                      }
                    } else {
                      showInfoDialog(
                        'Error',
                        'Failed to load iLab data: ${response.statusCode} - ${response.statusMessage}',
                      );
                    }
                  } on DioException catch (e) {
                    safePopLoadingDialog();
                    timer.cancel();
                    showInfoDialog(
                      'Network Error',
                      'An error occurred: ${e.message}',
                    );
                  } catch (e) {
                    safePopLoadingDialog();
                    timer.cancel();
                    showInfoDialog(
                      'Error',
                      'An unexpected error occurred: ${e.toString()}',
                    );
                  }
                },
              ),
            ),
            Positioned(
              top: width * .005,
              right: width * .49,
              child: Container(
                height: width * .05,
                width: width * .01,
                color: Colors.black,
              ),
            ),
            Positioned(
              top: width * .03,
              right: width * .42,
              child: InkWell(
                onTap: () async {
                  var timer = Timer(const Duration(seconds: 40), () {
                    Navigator.pop(context);
                    dialogBox.information(
                      context,
                      'Status',
                      'Service timed out',
                    );
                    return;
                  });
                  dialogBox.waiting(context, "Loading");
                  var url = "$baseUrl/app/360/net";
                  var url2 = "$baseUrl/app/360/equity";
                  final prefs = await SharedPreferences.getInstance();
                  var token = prefs.getString('tokenDB');
                  var response = await dio.get(
                    url,
                    options: Options(
                      headers: {"Authorization": 'Bearer $token'},
                    ),
                  );
                  var response2 = await dio.get(
                    url2,
                    options: Options(
                      headers: {"Authorization": 'Bearer $token'},
                    ),
                  );
                  String netConfirm = response.data["isNet"]["net_confirm"];
                  print("isNet:$netConfirm");
                  Navigator.pop(context);
                  Navigator.pop(context);
                  if (netConfirm == '0') {
                    Navigator.pop(context);
                    timer.cancel();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Networth(item: response.data),
                      ),
                    );
                  } else if (netConfirm == '1') {
                    var equity = response2.data['equity_detail']['sum'];
                    print('equity:$equity');
                    var values = response.data;
                    print('net_detail${values['net_detail']['values']}');
                    timer.cancel();

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
                },
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: index == 1
                        ? [
                            BoxShadow(
                              color: Colors.grey[700]!,
                              spreadRadius: 7,
                              blurRadius: 7,
                              offset: const Offset(
                                0,
                                3,
                              ), // changes position of shadow
                            ),
                          ]
                        : null,
                    borderRadius: BorderRadius.circular(width * .02),
                    color: Colors.purple,
                  ),
                  height: width * .15,
                  width: width * .13,
                  child: Center(
                    child: Text(
                      "Net Worth",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * .025,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: width * .1,
              right: width * .21,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(30 / 360),
                child: Container(
                  height: width * .05,
                  width: width * .01,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: width * .1228,
              right: width * .22,
              child: InkWell(
                onTap: liability,
                child: Container(
                  height: width * .15,
                  width: width * .13,
                  decoration: BoxDecoration(
                    boxShadow: index == 2
                        ? [
                            BoxShadow(
                              color: Colors.grey[700]!,
                              spreadRadius: 7,
                              blurRadius: 7,
                              offset: const Offset(
                                0,
                                3,
                              ), // changes position of shadow
                            ),
                          ]
                        : null,
                    borderRadius: BorderRadius.circular(width * .02),
                    color: Colors.purple,
                  ),
                  child: Center(
                    child: Text(
                      "Liabilities",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * .025,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: width * .2856,
              right: width * .06,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(60 / 360),
                child: Container(
                  height: width * .05,
                  width: width * .01,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: width * .2856,
              right: width * .08,
              child: InkWell(
                onTap: expenditure,
                child: Container(
                  height: width * .15,
                  width: width * .13,
                  decoration: BoxDecoration(
                    boxShadow: index == 3
                        ? [
                            BoxShadow(
                              color: Colors.grey[700]!,
                              spreadRadius: 7,
                              blurRadius: 7,
                              offset: const Offset(
                                0,
                                3,
                              ), // changes position of shadow
                            ),
                          ]
                        : null,
                    borderRadius: BorderRadius.circular(width * .02),
                    color: Colors.purple,
                  ),
                  child: Center(
                    child: Text(
                      "Expenditure",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * .020,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: width * .5,
              right: width * .005,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(90 / 360),
                child: Container(
                  height: width * .05,
                  width: width * .01,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: width * .45,
              right: width * .025,
              child: InkWell(
                onTap: protection,
                child: Container(
                  height: width * .15,
                  width: width * .13,
                  decoration: BoxDecoration(
                    boxShadow: index == 4
                        ? [
                            BoxShadow(
                              color: Colors.grey[700]!,
                              spreadRadius: 7,
                              blurRadius: 7,
                              offset: const Offset(
                                0,
                                3,
                              ), // changes position of shadow
                            ),
                          ]
                        : null,
                    borderRadius: BorderRadius.circular(width * .02),
                    color: Colors.purple,
                  ),
                  child: Center(
                    child: Text(
                      "Protection",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * .020,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              // bottom: width * .32,
              // right: width * .03,
              bottom: width * .22,
              right: width * .095,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(120 / 360),
                child: Container(
                  height: width * .05,
                  width: width * .01,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              // top: width * .5712,
              bottom: width * .22,
              right: width * .1,
              child: InkWell(
                onTap: () {
                  retirement();
                },
                child: Container(
                  height: width * .15,
                  width: width * .13,
                  decoration: BoxDecoration(
                    boxShadow: index == 5
                        ? [
                            BoxShadow(
                              color: Colors.grey[700]!,
                              spreadRadius: 7,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                    borderRadius: BorderRadius.circular(width * .02),
                    color: Colors.purple,
                  ),
                  child: Center(
                    child: Text(
                      "Retirement",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * .020,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: width * .07,
              right: width * .245,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(150 / 360),
                child: Container(
                  height: width * .05,
                  width: width * .01,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              // top: width * .714,
              bottom: width * .07,
              right: width * .26,
              child: InkWell(
                onTap: () async {
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

                  /// var url = "$baseUrl/app/seveng/edit";
                  var url = Uri.parse('$baseUrl/app/360/investment');

                  final prefs = await SharedPreferences.getInstance();
                  var token = prefs.getString('tokenDB');

                  var response = await http.get(
                    url,
                    headers: {"Authorization": 'Bearer $token'},
                  );
                  if (response.statusCode == 200) {
                    timer.cancel();
                    Navigator.pop(context);
                    var investment = jsonDecode(response.body);
                    print("investment:$investment");
                    context.read<Providers>().setinvSum(
                      investment['investment_sum'],
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Investdash(
                          sums: investment['investment_sum'],
                          braidTable: investment['data']['braid_table'],
                        ),
                      ),
                    );
                  } else {
                    timer.cancel();
                    Navigator.pop(context);
                    switch (response.statusCode) {
                      case 400:
                        Fluttertoast.showToast(
                          msg: "Error: bad request",
                          backgroundColor: Theme.of(context).primaryColor,
                        );
                        break;
                      case 401:
                        Fluttertoast.showToast(
                          msg: "Error: Unauthorised, please login again",
                          backgroundColor: Theme.of(context).primaryColor,
                        );
                        break;
                      case 422:
                        Fluttertoast.showToast(
                          msg: "Error: 422, please try again later",
                          backgroundColor: Theme.of(context).primaryColor,
                        );
                        break;
                      case 500:
                        Fluttertoast.showToast(
                          msg: "Error: Server Error",
                          backgroundColor: Theme.of(context).primaryColor,
                        );
                        break;
                      default:
                    }
                  }
                },
                child: Container(
                  height: width * .15,
                  width: width * .13,
                  decoration: BoxDecoration(
                    boxShadow: index == 6
                        ? [
                            BoxShadow(
                              color: Colors.grey[700]!,
                              spreadRadius: 7,
                              blurRadius: 7,
                              offset: const Offset(
                                0,
                                3,
                              ), // changes position of shadow
                            ),
                          ]
                        : null,
                    borderRadius: BorderRadius.circular(width * .02),
                    color: Colors.purple,
                  ),
                  child: Center(
                    child: Text(
                      "Investment",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * .022,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              // bottom: width * .32,
              // right: width * .03,
              bottom: width * .005,
              left: width * .48,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(180 / 360),
                child: Container(
                  height: width * .05,
                  width: width * .01,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              // top: width * .8568,
              bottom: width * .04,
              left: width * .42,
              child: InkWell(
                onTap: cash,
                child: Container(
                  height: width * .15,
                  width: width * .13,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * .02),
                    color: Colors.purple,
                    boxShadow: index == 7
                        ? [
                            BoxShadow(
                              color: Colors.grey[700]!,
                              spreadRadius: 7,
                              blurRadius: 7,
                              offset: const Offset(
                                0,
                                3,
                              ), // changes position of shadow
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      "Cash",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * .025,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: width * .07,
              left: width * .245,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(210 / 360),
                child: Container(
                  height: width * .05,
                  width: width * .01,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              // top: width * .714,
              bottom: width * .1,
              left: width * .22,
              child: InkWell(
                onTap: mortgage,
                child: Container(
                  height: width * .15,
                  width: width * .13,
                  decoration: BoxDecoration(
                    boxShadow: index == 8
                        ? [
                            BoxShadow(
                              color: Colors.grey[700]!,
                              spreadRadius: 7,
                              blurRadius: 7,
                              offset: const Offset(
                                0,
                                3,
                              ), // changes position of shadow
                            ),
                          ]
                        : null,
                    borderRadius: BorderRadius.circular(width * .02),
                    color: Colors.purple,
                  ),
                  child: Center(
                    child: Text(
                      "Mortgage",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * .025,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: width * .22,
              left: width * .095,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(240 / 360),
                child: Container(
                  height: width * .05,
                  width: width * .01,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              // top: width * .5712,
              bottom: width * .25,
              left: width * .08,
              child: InkWell(
                onTap: () {
                  philanthropy(currency);
                },
                child: Container(
                  height: width * .15,
                  width: width * .13,
                  decoration: BoxDecoration(
                    boxShadow: index == 9
                        ? [
                            BoxShadow(
                              color: Colors.grey[700]!,
                              spreadRadius: 7,
                              blurRadius: 7,
                              offset: const Offset(
                                0,
                                3,
                              ), // changes position of shadow
                            ),
                          ]
                        : null,
                    borderRadius: BorderRadius.circular(width * .02),
                    color: Colors.purple,
                  ),
                  child: Center(
                    child: Text(
                      "Philanthropy",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * .020,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: width * .5,
              left: width * .005,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(90 / 360),
                child: Container(
                  height: width * .05,
                  width: width * .01,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: width * .44,
              left: width * .022,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ActionPlanStrategy(),
                    ),
                  );
                },
                child: Container(
                  height: width * .15,
                  width: width * .13,
                  decoration: BoxDecoration(
                    boxShadow: index == 10
                        ? [
                            BoxShadow(
                              color: Colors.grey[700]!,
                              spreadRadius: 7,
                              blurRadius: 7,
                              offset: const Offset(
                                0,
                                3,
                              ), // changes position of shadow
                            ),
                          ]
                        : null,
                    borderRadius: BorderRadius.circular(width * .02),
                    color: Colors.purple,
                  ),
                  child: Center(
                    child: Text(
                      "Action Plan",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * .022,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: width * .2856,
              left: width * .06,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(300 / 360),
                child: Container(
                  height: width * .05,
                  width: width * .01,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: width * .2656,
              left: width * .07,
              child: InkWell(
                onTap: income,
                child: Container(
                  height: width * .15,
                  width: width * .13,
                  decoration: BoxDecoration(
                    boxShadow: index == 11
                        ? [
                            BoxShadow(
                              color: Colors.grey[700]!,
                              spreadRadius: 7,
                              blurRadius: 7,
                              offset: const Offset(
                                0,
                                3,
                              ), // changes position of shadow
                            ),
                          ]
                        : null,
                    borderRadius: BorderRadius.circular(width * .02),
                    color: Colors.purple,
                  ),
                  child: Center(
                    child: Text(
                      "Income",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * .025,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: width * .1,
              left: width * .21,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(330 / 360),
                child: Container(
                  height: width * .05,
                  width: width * .01,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: width * .111,
              left: width * .22,
              child: InkWell(
                onTap: assets,
                child: Container(
                  height: width * .15,
                  width: width * .13,
                  decoration: BoxDecoration(
                    boxShadow: index == 12
                        ? [
                            BoxShadow(
                              color: Colors.grey[700]!,
                              spreadRadius: 7,
                              blurRadius: 7,
                              offset: const Offset(
                                0,
                                3,
                              ), // changes position of shadow
                            ),
                          ]
                        : null,
                    borderRadius: BorderRadius.circular(width * .02),
                    color: Colors.purple,
                  ),
                  child: Center(
                    child: Text(
                      "Asset",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * .025,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
