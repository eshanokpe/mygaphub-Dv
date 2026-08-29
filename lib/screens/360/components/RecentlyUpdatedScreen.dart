import 'dart:async';
import 'dart:convert';

import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/360/accounts/income/income.dart';
import 'package:GapHub/screens/360/accounts/philanthropy/setgiving.dart';
import 'package:GapHub/screens/360/threesixty.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../accounts/cash/cashdetails.dart';
import '../accounts/expenditure/expenditure.dart';
import '../accounts/income/incomedash.dart';
import '../accounts/liabilities/liabilitydetails.dart';
import '../accounts/mortgage/mortgagedetails.dart';
import '../accounts/networth/networth.dart';
import '../accounts/networth/networthdetails.dart';
import '../accounts/philanthropy/philanthropy.dart';
import '../accounts/protection/protectiondetails.dart';
import '../accounts/retirement/presentation/retiredash.dart';
import 'addAccountBtn.dart';

class RecentlyUpdatedScreen extends StatefulWidget {
  final List data;
  const RecentlyUpdatedScreen({super.key, this.data = const []});

  @override
  State<RecentlyUpdatedScreen> createState() => _RecentlyUpdatedScreenState();
}

class _RecentlyUpdatedScreenState extends State<RecentlyUpdatedScreen> {
  Dio dio = Dio();
  @override
  Widget build(BuildContext context) {
    String currency = context.watch<Providers>().snapshotmodel.currency;
    var data = context.watch<Providers>().recents;

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.all(14.w),
      child: Column(
        children: [
          SizedBox(height: height * .02),
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
                  itemBuilder: (context, index) {
                    String accountName = "${data[index]['account_name']}"
                        .capitalize();
                    String accountType = "${data[index]['account_type']}"
                        .capitalize();

                    // FIXED: Format the amount to always have 2 decimal places
                    dynamic sumValue = data[index]['sum'];
                    String formattedSum = _formatAmount(sumValue);
                    String accountAmount = "$currency$formattedSum";

                    String imagePath = _getImagePathForAccount(accountName);

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * .02),
                      child: AccountTile(
                        imagePath: imagePath,
                        title: accountName,
                        subtitle: accountType,
                        amount: accountAmount,
                        onTap: () {
                          print("name:$accountName");
                          switch (accountName) {
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
                      ),
                    );
                  },
                ),
          SizedBox(height: height * .05),
          const Addaccountbtn(index: "0"),
        ],
      ),
    );
  }

  // Helper method to format amount to always have 2 decimal places
  String _formatAmount(dynamic value) {
    if (value == null) return "0.00";

    if (value is int) {
      return "$value.00";
    } else if (value is double) {
      // Handle double precision
      return value.toStringAsFixed(2);
    } else if (value is String) {
      // If it's already a string, try to parse it
      try {
        double parsedValue = double.parse(value);
        return parsedValue.toStringAsFixed(2);
      } catch (e) {
        return value; // Return as-is if parsing fails
      }
    }
    return "0.00";
  }

  String _getImagePathForAccount(String accountName) {
    switch (accountName) {
      case "Cash":
        return 'assets/wheel_segments/cash_icon.png';
      case "Net":
        return 'assets/wheel_segments/networth_icon.png';
      case "Liabilities":
      case "Liability":
        return 'assets/wheel_segments/liabilities_icon.png';
      case "Mortgage":
        return 'assets/wheel_segments/mortgage_icon.png';
      case "Protection":
        return 'assets/wheel_segments/protection_icon.png';
      case "Philantropy":
      case "Philanthropy":
        return 'assets/wheel_segments/philanthropy_icon.png';
      case "Expenditure":
        return 'assets/wheel_segments/expenditure_icon.png';
      case "Income":
        return 'assets/wheel_segments/income_icon.png';
      case "Retirement":
        return 'assets/wheel_segments/retirement_icon.png';
      default:
        return 'assets/wheel_segments/default_icon.png'; // Fallback icon
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
    var url = "$baseUrl/app/360/net-worth";
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
    if (response.data['data']["isNet"]["net_confirm"] == 0) {
      timer.cancel();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Networth(item: response.data)),
      );
    } else if (response.data["isNet"]["net_confirm"] == 1) {
      timer.cancel();

      print("contains:$contains");
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

  Future<void> cash() async {
    // Show loading dialog immediately
    dialogBox.waiting(context, "Loading");

    // Set up timeout timer
    final timer = Timer(const Duration(seconds: 20), () {
      _handleTimeout();
    });

    try {
      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Prepare headers
      final headers = {'Authorization': 'Bearer $token'};

      // Make API call
      const url =
          "$baseUrl/app/360/cash?archive=0&header=&access=&account=&kpi=";
      final response = await dio.get(url, options: Options(headers: headers));

      // Check if request was successful
      if (response.statusCode == 200) {
        // Check the response structure - it has a status and data wrapper
        final responseData = response.data;

        if (responseData is Map && responseData['status'] == true) {
          // Extract the actual data from the 'data' field
          final cashResponseData = responseData['data'] as Map? ?? {};

          // Extract data from response with null safety
          final cashData = cashResponseData["cash"] as List? ?? [];
          final sevengData = cashResponseData["seveng"] as List? ?? [];
          final cashDetailData = cashResponseData["cash_detail"] as Map? ?? {};
          final bespokesData = cashResponseData["bespokes"] as List? ?? [];

          // Update providers with data
          context.read<Providers>().setcashData(cashData);
          context.read<Providers>().setcashDataLite(cashDetailData);
          context.read<Providers>().setcashseveng(sevengData);
          context.read<Providers>().setcashbespokes(bespokesData);

          // Cancel timer since request completed successfully
          timer.cancel();

          // Close loading dialog
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          // Navigate to cash details screen with all available data
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Cashdetails(
                cashData,
                cashDetailData,
                sevengData,
                bespokesData,
              ),
            ),
          );
        } else {
          throw Exception(
            'API returned error: ${responseData['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception(
          'Failed to load cash data (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      // Cancel timer on error
      timer.cancel();

      // Handle error
      await _handleError(e);
    }
  }

  void _handleTimeout() {
    // Close loading dialog if still showing
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // Show timeout message
    dialogBox.information(
      context,
      'Status',
      'Service timed out. Please try again.',
    );
  }

  Future<void> _handleError(dynamic error) async {
    // Close loading dialog if still showing
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    String errorMessage = _getErrorMessage(error);

    dialogBox.information(context, 'Error', errorMessage);
  }

  String _getErrorMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred';

    if (error is Exception) {
      final errorString = error.toString();

      // Handle specific error types
      if (errorString.contains('token')) {
        return 'Authentication failed. Please log in again.';
      } else if (errorString.contains('timeout')) {
        return 'Connection timeout. Please check your internet connection.';
      } else if (errorString.contains('SocketException')) {
        return 'Network error. Please check your internet connection.';
      } else if (errorString.contains('format')) {
        return 'Invalid data format received from server.';
      }

      // Clean up generic exception message
      return errorString
          .replaceAll('Exception:', '')
          .replaceAll('FormatException:', '')
          .replaceAll('DioException:', '')
          .trim();
    }

    return 'An error occurred: $error';
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
      creditCurrent = analyticsinfo.credit["current"].toString();
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

  // ==================== MORTGAGE ====================
  Future<void> mortgage() async {
    dialogBox.waiting(context, "Loading");
    final timer = Timer(const Duration(seconds: 30), () => _handleTimeout());
    final prefs = await SharedPreferences.getInstance();
    try {
      var token = prefs.getString('tokenDB');
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final headers = {'Authorization': 'Bearer $token'};
      const url = "$baseUrl/app/360/mortgage";
      final response = await dio.get(url, options: Options(headers: headers));

      if (response.statusCode == 200) {
        timer.cancel();

        final mortgageList = response.data["mortgages"];
        final sevengList = response.data["seveng"];
        final mortgageDetailList = response.data["mortgages_detail"];

        // Validate required data (adjust based on what's actually required)
        if (mortgageList == null) {
          throw Exception('Invalid response format: missing mortgage data');
        }

        // Update providers if needed (uncomment if you have provider methods)
        // context.read<Providers>().setMortgageList(mortgageList);
        // if (mortgageDetailList != null) {
        //   context.read<Providers>().setMortgageDetailList(mortgageDetailList);
        // }
        // if (sevengList != null) {
        //   context.read<Providers>().setMortgageSeveng(sevengList);
        // }

        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Mortgagedetails(
              mortgageList,
              mortgageDetailList ?? [],
              sevengList ?? [],
            ),
          ),
        );
      } else {
        throw Exception(
          'Failed to load mortgage data (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      timer.cancel();
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      await _handleError(e);
    }
  }

  Future<void> protection() async {
    // Show loading dialog immediately
    dialogBox.waiting(context, "Loading");

    // Set up timeout timer
    final timer = Timer(const Duration(seconds: 20), () {
      _handleTimeout();
    });

    try {
      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Prepare headers
      final headers = {'Authorization': 'Bearer $token'};

      // Make API call
      const url =
          "$baseUrl/app/360/protection?archive=0&header=&access=&account=";
      final response = await dio.get(url, options: Options(headers: headers));

      // Check if request was successful
      if (response.statusCode == 200) {
        // Check if API returned success status
        final responseData = response.data;

        if (responseData['status'] == true) {
          print("response.data: $responseData");

          // Cancel timer since request completed successfully
          timer.cancel();

          // Extract data from the "data" field in the response
          final protectionData = responseData["data"];

          // Get the lists from the data object
          final protectionList = protectionData["protection"] ?? [];
          final protectionDetailList =
              protectionData["protection_detail"] ?? [];

          // Validate data
          if (protectionList.isEmpty) {
            print('No protection data found');
            // You might want to show a message to user
          }

          // Update providers with data
          if (context.mounted) {
            context.read<Providers>().setProtectionList(protectionList);
            context.read<Providers>().setProtectionListLite(
              protectionDetailList,
            );
          }
          // Close loading dialog
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          // Navigate to protection details screen
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Protectiondetails(),
              ),
            );
          }
        } else {
          throw Exception(
            responseData['message'] ?? 'Failed to load protection data',
          );
        }
      } else {
        throw Exception(
          'Failed to load protection data (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      // Cancel timer on error
      timer.cancel();

      // Handle error
      _handleError(e);
    }
  }

  // ==================== PHILANTHROPY ====================
  Future<void> philanthropy(String currency) async {
    dialogBox.waiting(context, "Loading");
    final timer = Timer(const Duration(seconds: 20), () => _handleTimeout());
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');

    try {
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final headers = {'Authorization': 'Bearer $token'};
      const url =
          "$baseUrl/app/360/philantrophy?archive=0&header=&access=&account=&period=&income=&crd=&alo=";
      final response = await dio.get(url, options: Options(headers: headers));

      if (response.statusCode == 200) {
        timer.cancel();

        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Extract data from response
        final responseData = response.data["data"];
        if (responseData == null) {
          throw Exception('Invalid response format: missing data');
        }

        final grant = responseData["grand"]?["current"];
        final charity = responseData["philantrophy"]?["charity"] ?? 0;
        final familySupport =
            responseData["philantrophy"]?["family_support"] ?? 0;
        final personalCommitments =
            responseData["philantrophy"]?["personal_commitments"] ?? 0;
        final others = responseData["philantrophy"]?["others"] ?? 0;

        final setgiving =
            charity + familySupport + personalCommitments + others;
        final allocated = num.tryParse(grant?.toString() ?? "0") ?? 0;

        debugPrint('grant: $grant');
        debugPrint('setgiving: $setgiving');
        debugPrint('allocated: $allocated');

        // Update provider with data
        context.read<Providers>().setphilanList(response.data);
        context.read<Providers>().setcurrency(currency);

        // Navigate based on condition
        if (grant != setgiving) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Setgiving(response.data)),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Philanthropy(response.data, currency),
            ),
          );
        }
      } else {
        throw Exception(
          'Failed to load philanthropy data (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      timer.cancel();
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      await _handleError(e);
    }
  }

  // ==================== EXPENDITURE ====================
  Future<void> expenditure(String currency) async {
    dialogBox.waiting(context, "Loading");
    final timer = Timer(const Duration(seconds: 20), () => _handleTimeout());
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');
    try {
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final headers = {'Authorization': 'Bearer $token'};
      const url = "$baseUrl/app/360/expenditure";
      final response = await dio.get(url, options: Options(headers: headers));

      if (response.statusCode == 200) {
        final responseData = response.data;
        timer.cancel();
        final expenditureData = responseData["data"];
        final expenditureList = expenditureData["expenditure"];
        final expenditureDetailList = expenditureData["expenditure_detail"];

        // Validate required data
        if (expenditureList == null) {
          throw Exception('Invalid response format: missing expenditure data');
        }

        // Update providers with data
        context.read<Providers>().setExpenditureList(expenditureList);

        if (expenditureDetailList != null) {
          context.read<Providers>().setExpenditureListLite(
            expenditureDetailList,
          );
        }

        context.read<Providers>().setcurrency(currency);

        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Expenditure()),
        );
      } else {
        throw Exception(
          'Failed to load expenditure data (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      timer.cancel();
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      await _handleError(e);
    }
  }

  // ==================== INCOME ====================
  Future<void> income() async {
    dialogBox.waiting(context, "Loading");
    final timer = Timer(const Duration(seconds: 20), () => _handleTimeout());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final headers = {'Authorization': 'Bearer $token'};
      const url =
          "$baseUrl/app/360/income?archive=0&header=&access=&account=&period=&income=&crd=&alo=";
      final response = await dio.get(url, options: Options(headers: headers));

      if (response.statusCode == 200) {
        timer.cancel();

        // Extract data from response with null safety
        final assets = response.data["data"]["portfolio_asset"] as List? ?? [];
        final incomeData = response.data["data"]["incomes"] as List? ?? [];
        final incomeDataLite = response.data["data"]["income_detail"];
        final incomeInfo = response.data["data"]["income_info"] ?? {};
        final incomeAudit = response.data["data"]["income_audit"];
        final incomeChart = response.data["data"]["income_chart"];

        // Parse current portfolio
        int currentPortfolio = 0;
        try {
          currentPortfolio = int.parse(
            incomeInfo["current_portfolio"]?.toString() ?? "0",
          );
        } catch (e) {
          debugPrint('Error parsing current_portfolio: $e');
        }

        // Parse portfolio difference
        double portfolioDiff = 0.0;
        try {
          portfolioDiff =
              (incomeInfo["portfolio_diff"] as num?)?.toDouble() ?? 0.0;
        } catch (e) {
          debugPrint('Error parsing portfolio_diff: $e');
        }

        // Calculate amounts list
        List<num> amounts = [];
        for (var i = 0; i < incomeData.length; i++) {
          try {
            amounts.add(
              num.tryParse(incomeData[i]["amount"]?.toString() ?? "0") ?? 0,
            );
          } catch (e) {
            debugPrint('Error parsing amount at index $i: $e');
          }
        }

        // Parse allocated amount
        num allocated = 1;
        if (incomeAudit != null) {
          allocated =
              num.tryParse(
                incomeAudit["income_allocated"]?.toString() ?? "1",
              ) ??
              1;
        }

        // Process assets list
        List<String> listOfAssets = ['-Select-'];
        for (var i = 0; i < assets.length; i++) {
          final asset = assets[i];
          if (asset["isArchive"] != 1) {
            final name = asset["name"] ?? '';
            final currency = asset["asset_currency"] ?? '';
            final monthlyRoi =
                (asset["monthly_roi"] as num?)?.toDouble() ?? 0.0;

            listOfAssets.add(
              "$name ($currency${monthlyRoi.toStringAsFixed(2)})"
                  .replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  ),
            );
          }
        }

        // Update providers
        context.read<Providers>().setCurrentPortfolio(currentPortfolio);
        context.read<Providers>().setPortfolioDiff(portfolioDiff);
        context.read<Providers>().setAssets(listOfAssets);
        context.read<Providers>().setMapAsset(assets);

        if (incomeChart != null) {
          context.read<Providers>().addIncomeChart(incomeChart);
        }

        // Close loading dialog
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Navigate based on portfolio difference
        if (portfolioDiff > 0) {
          // Make sure Income is properly imported and is a valid widget
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Income(), // Add const if possible
            ),
          );
        } else {
          final incomes = response.data["incomes"] ?? [];
          final channels = response.data["income_channels"] ?? {};

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
        throw Exception(
          'Failed to load income data (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      timer.cancel();
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      await _handleError(e);
    }
  }

  Future<void> retirement() async {
    // Show loading dialog immediately
    dialogBox.waiting(context, "Loading");

    // Set up timeout timer
    final timer = Timer(const Duration(seconds: 20), () {
      _handleTimeout();
    });

    try {
      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Prepare headers
      final headers = {'Authorization': 'Bearer $token'};

      // Make parallel API calls for better performance
      final results = await Future.wait([
        dio.get(
          '$baseUrl/app/360/retirement/roi',
          options: Options(headers: headers),
        ),
        dio.get(
          '$baseUrl/app/360/retirement?archive=0&header=&access=&account=',
          options: Options(headers: headers),
        ),
      ]);

      final roiResponse = results[0];
      final retirementResponse = results[1];

      // Check if both requests were successful
      if (roiResponse.statusCode == 200 &&
          retirementResponse.statusCode == 200) {
        // Update providers with data
        context.read<Providers>().setretiredata(roiResponse.data['data']);
        context.read<Providers>().setpensions(retirementResponse.data['data']);
        // Cancel timer since request completed successfully
        timer.cancel();

        // Close loading dialog
        Navigator.pop(context);

        // Navigate to retirement dashboard
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Retiredash()),
        );
      } else {
        throw Exception('Failed to load retirement data');
      }
    } catch (e) {
      // Cancel timer on error
      timer.cancel();

      // Close loading dialog
      Navigator.pop(context);

      // Show error message
      _handleError(e);
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class AccountTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String amount;
  final VoidCallback? onTap;

  const AccountTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Parse the amount to extract currency, whole number, and decimal parts
    // FIXED: Add error handling for amount parsing
    String currencySymbol = context.watch<Providers>().snapshotmodel.currency;
    String wholeNumber = "0";
    String decimalPart = "00";

    try {
      if (amount.isNotEmpty) {
        currencySymbol = amount.substring(0, 1);

        if (amount.contains('.')) {
          wholeNumber = amount.substring(1, amount.indexOf('.'));
          decimalPart = amount.substring(amount.indexOf('.') + 1);

          // Ensure decimal part has exactly 2 digits
          if (decimalPart.length == 1) {
            decimalPart = "${decimalPart}0";
          } else if (decimalPart.length > 2) {
            decimalPart = decimalPart.substring(0, 2);
          }
        } else {
          // Handle case with no decimal point
          wholeNumber = amount.substring(1);
          decimalPart = "00";
        }
      }
    } catch (e) {
      // Fallback values if parsing fails
      print("Error parsing amount: $e");
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 14.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFEAEAEA), // #EAEAEA
                width: 0.7,
              ),
              color: const Color(0xFFF3F3F3), // background: #F3F3F3
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.02), // 2% opacity black
                  blurRadius: 2,
                  offset: Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 45.h,
                  width: 45.w,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFEAEAEA),
                      width: 0.7,
                    ),
                  ),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: 32.w,
                    height: 32.h,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w300,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ],
                  ),
                ),
                // Custom amount display with specific styling
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    // Currency symbol (£)
                    Text(
                      currencySymbol,
                      style: TextStyle(
                        color: const Color(0xFF000000),
                        fontSize: 18.sp,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w700,
                        height: 20 / 18, // line-height 20px / font-size 18px
                      ),
                    ),
                    // Whole number (777)
                    Text(
                      wholeNumber.replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
                      style: TextStyle(
                        color: const Color(0xFF000000),
                        fontSize: 18.sp,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w700,
                        height: 20 / 18,
                      ),
                    ),
                    // Decimal point (.)
                    Text(
                      '.',
                      style: TextStyle(
                        color: const Color(0xFF777777),
                        fontSize: 18.sp,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w700,
                        height: 20 / 18,
                      ),
                    ),
                    // Decimal part (53)
                    Text(
                      decimalPart,
                      style: TextStyle(
                        color: const Color(0xFF777777),
                        fontSize: 14.sp,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w700,
                        height: 20 / 14, // line-height 20px / font-size 14px
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
