import 'dart:async';
import 'dart:convert';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/360/accounts/assets/presentation/equitydetails.dart';
import 'package:GapHub/screens/homepage/widget/row_view_details.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:GapHub/widgets/plus_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/utils/extensions.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/widgets/piechart.dart';
import '../../360/accounts/assets/presentation/add_homequity.dart';

class Homequitydash extends StatefulWidget {
  final double height;
  final double width;
  final Map residential;
  final String currency;

  const Homequitydash({
    super.key,
    required this.height,
    required this.currency,
    required this.width,
    required this.residential,
  });
  @override
  _HomequitydashState createState() => _HomequitydashState();
}

class _HomequitydashState extends State<Homequitydash> {
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
    return Container(
      child: widget.residential["chart"] != null
          ? Column(
              children: [
                RowViewDetails(
                  mainText: 'Primary Residence home equity',
                  detailText: 'View',
                  onTap: () {
                    // Handle onTap action here
                    toHomeEquity();
                  },
                  arrowTap: true,
                ),

                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 241, 241, 241),
                      width: 1.5,
                    ),
                  ),
                  color: const Color.fromARGB(255, 253, 253, 253),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.width(.04),
                    ),
                    width: widget.width * 05,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.width * .02),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Builder(
                          builder: (context) {
                            final chartValues =
                                widget.residential["chart"]?["values"];
                            final valuesList =
                                (chartValues is List ? chartValues : [0, 0])
                                    .reversed
                                    .toList();
                            return Piechart(
                              values: valuesList,
                              labels: const ["Equity", "Debt"],
                              colors: const ['0XFF581845', '0XFFFFA056'],
                              doiwant: true,
                              percent: valuesList,
                            );
                          },
                        ),

                        SizedBox(height: widget.height * .02),
                        Text(
                          '${widget.currency}${widget.residential["equity"] ?? 0}'
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              ),
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: widget.height * .01),
                        Text(
                          'You own ${widget.residential["ownership"] ?? 0}% of your home',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: widget.height * .02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Value: ',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                color: AppColors.grayColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${widget.currency}${widget.residential["market_value"] ?? 0}'
                                  .replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]},',
                                  ),
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                color: AppColors.blackColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: widget.height * .01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mortgage: ',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                color: AppColors.grayColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              [
                                    "",
                                    null,
                                    false,
                                    0,
                                  ].contains(widget.residential["mortgage"])
                                  ? "0"
                                  : '${widget.currency}${widget.residential["mortgage"]["current_balance"]}'
                                        .replaceAllMapped(
                                          RegExp(
                                            r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                          ),
                                          (Match m) => '${m[1]},',
                                        ),
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                color: AppColors.blackColor,
                                fontSize: widget.width * .04,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: widget.height * .01),
              ],
            )
          : Column(
              children: [
                RowViewDetails(
                  mainText: 'Primary Residence home equity',
                  detailText: 'View',
                  onTap: () {
                    // Handle onTap action here
                    toHomeEquity();
                  },
                  arrowTap: true,
                ),
                SizedBox(height: widget.height * .02),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 241, 241, 241),
                      width: 1.5,
                    ),
                  ),
                  color: const Color.fromARGB(255, 253, 253, 253),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.width * .04,
                      vertical: widget.height * .02,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: widget.height * 0.03),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'You are yet to set your Home Equity',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xff666666),
                                fontSize: 14.sp,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: widget.height * 0.03),
                        PlusButton(
                          color: Colors.white,
                          iconsColor: AppColors.primaryColor,
                          textColor: AppColors.blackColor,
                          icons: Icons.add,
                          text: 'Set up',
                          onPressed: debt,
                        ),
                        SizedBox(height: widget.height * 0.03),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: widget.height * .02),
              ],
            ),
    );
  }

  toHomeEquity() async {
    var timer = Timer(const Duration(seconds: 40), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, "Loading");

    var url = "$baseUrl/app/360/cash";
    var url2 = "$baseUrl/app/360/equity";
    var url3 = "$baseUrl/app/360/investment";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    Dio dio = Dio();
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

    if (response.statusCode == 200 &&
        response2.statusCode == 200 &&
        response3.statusCode == 200) {
      var equityList = response2.data["equity"];
      var equityListLite = response2.data["equity_detail"];
      var cashList = response.data["cash"];
      var cashListLite = response.data["cash_detail"];
      var seveng = response.data["seveng"];
      var bespokes = response.data["bespokes"];
      var invSum = response3.data["investment_sum"];
      context.read<Providers>()
        ..setequityList(equityList)
        ..setequityDetail(equityListLite);
      Navigator.pop(context);
      //Navigator.pop(context);
      timer.cancel();
      navigateWithSlideTransition(
        context: context,
        destinationScreen: const Equitydetails(),
        transitionDuration: const Duration(milliseconds: 200),
      );
    }
    timer.cancel();
  }

  Future<void> debt() async {
    const timeoutDuration = Duration(seconds: 40);
    const loadingMessage = 'Loading';
    const timeoutMessage =
        'Service timed out. Please check your internet connection.';
    const statusMessage = 'Status';

    Timer? timer;

    try {
      // Show loading dialog
      dialogBox.waiting(context, loadingMessage);

      // Set timeout timer
      timer = Timer(timeoutDuration, () {
        _handleTimeout();
      });

      // Get authentication token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Make API request
      final url = Uri.parse('$baseUrl/app/360/equity/info');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);

        // Process mortgages data
        final List mortgages = body['mortgages_available'] ?? [];
        final List<String> mortgagesList = _formatMortgagesList(mortgages);

        // Process countries data
        final List countries = body['countries'] ?? [];
        final List<String> countriesList = _formatCountriesList(countries);

        // Update providers
        context.read<Providers>().setMortgages(mortgages);
        context.read<Providers>().setMortgagesList(mortgagesList);
        context.read<Providers>().setCountries(countriesList);

        // Cancel timer and close dialog
        timer.cancel();
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Navigate to Homequity screen
        navigateWithSlideTransition(
          context: context,
          destinationScreen: const AddHomeEquity(),
          transitionDuration: const Duration(milliseconds: 200),
        );
      } else {
        throw Exception(
          'Failed to fetch Equity Info data.:${response.statusCode}',
        );
      }
    } catch (e) {
      // Handle any errors
      timer?.cancel();
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error message
      dialogBox.information(
        context,
        statusMessage,
        e.toString().contains('Exception')
            ? e.toString().replaceFirst('Exception: ', '')
            : 'An error occurred. Please try again.',
      );

      print('Error in debt(): $e');
    }
  }

  /// Handles timeout scenario
  void _handleTimeout() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    dialogBox.information(
      context,
      'Status',
      'Service timed out. Please check your internet connection.',
    );
  }

  /// Formats mortgages list with proper currency formatting
  List<String> _formatMortgagesList(List mortgages) {
    try {
      final formattedList = mortgages
          .where((e) => e['creditor_name'] != null)
          .map((e) {
            final creditorName = e['creditor_name'] as String;
            final currentBalance = e['current_balance'] ?? 0;

            // Format currency with commas
            final formattedBalance = _formatCurrency(currentBalance);

            return '$creditorName (${widget.currency}$formattedBalance)';
          })
          .toList();

      // Add default option at the beginning
      formattedList.insert(0, '-Select-');
      return formattedList;
    } catch (e) {
      print('Error formatting mortgages: $e');
      return ['-Select-'];
    }
  }

  /// Formats countries list
  List<String> _formatCountriesList(List countries) {
    try {
      final formattedList = countries.map((c) => c.toString()).toList();
      formattedList.insert(0, '-Select-');
      return formattedList;
    } catch (e) {
      print('Error formatting countries: $e');
      return ['-Select-'];
    }
  }

  /// Formats currency with commas for thousands
  String _formatCurrency(dynamic amount) {
    try {
      final number = amount is int
          ? amount
          : (amount is double ? amount.round() : 0);

      return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    } catch (e) {
      return '0';
    }
  }
}
