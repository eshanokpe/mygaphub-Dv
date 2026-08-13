import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ExchangeRates extends StatefulWidget {
  Map<String, dynamic> newCurrencyRates;
  ExchangeRates({super.key, required this.newCurrencyRates});

  @override
  _ExchangeRatesState createState() => _ExchangeRatesState();
}

class _ExchangeRatesState extends State<ExchangeRates> {
  late Map<String, dynamic> newCurrencyRates; // Store the new rates here
  List<Map<String, dynamic>> currencyListData = [];
  List<Map<String, dynamic>> filteredCurrencies = [];

  final TextEditingController searchController = TextEditingController();
  final TextEditingController val = TextEditingController();
  bool loading = false;
  bool isLoadingRates = true; // Add loading state for rates
  Dio dio = Dio();
  String? lastUpdate;
  String? baseCurrentcy;

  static const currencyList = <String>[
    "AED",
    "AUD",
    "BRL",
    "CAD",
    "CHF",
    "CNY",
    "EUR",
    "GBP",
    "GHS",
    "IDR",
    "INR",
    "JPY",
    "MXN",
    "NGN",
    "RUB",
    "SAR",
    "USD",
    "ZAR",
  ];

  static const currencyNames = <String>[
    'UAE Dirham',
    'Australian Dollar',
    'Brazilian Real',
    'Canadian Dollar',
    'Swiss Franc',
    'Renminbi',
    'Euro',
    'Pound Sterling',
    'Ghana Cedis',
    'Indonesian Rupiah',
    'Indian Rupee',
    'Japan Yen',
    'Mexican Peso',
    'Nigerian Naira',
    'Russian Ruble',
    'Saudi Riyal',
    'US Dollar',
    'South African Rand',
  ];

  @override
  void initState() {
    super.initState();
    newCurrencyRates = widget.newCurrencyRates;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => fetchNewCurrencyRates(),
    );
    searchController.addListener(_filterCurrencies);
    fetchNewCurrencyRates();
  }

  // Fetch the new currency rates from your API
  Future<void> fetchNewCurrencyRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      var urld = "$baseUrl/app/exchange";
      var responseD = await dio.get(
        urld,
        options: Options(
          headers: {
            "Authorization": 'Bearer $token',
            "Content-Type": 'application/json',
          },
        ),
      );

      if (responseD.statusCode == 200 || responseD.statusCode == 201) {
        Map result = responseD.data;
        print("base_currentcy:${result['data']["base_currency"]}");
        if (result['data'] != null &&
            result['data']['system_currencies'] != null) {
          setState(() {
            newCurrencyRates = Map<String, dynamic>.from(
              result['data']['system_currencies'],
            );
            lastUpdate = result['data']['last_update'];
            baseCurrentcy = result['data']['base_currency'];
            isLoadingRates = false;
          });
          setupData();
        }
      }
    } catch (e) {
      print('Error fetching currency rates: $e');
      setState(() {
        isLoadingRates = false;
      });
      // Fall back to provider data if API fails
      setupDataFromProvider();
    }
  }

  void setupData() {
    // Use the new currency rates instead of provider data
    final dataList = <Map<String, dynamic>>[];

    for (int i = 0; i < currencyList.length; i++) {
      String key = currencyList[i];
      if (newCurrencyRates.containsKey(key)) {
        final name = currencyNames[i];
        final rate = newCurrencyRates[key];
        final flagAsset = getFlagAssetFromCode(key);

        dataList.add({
          'abbre': key,
          'name': name,
          'rate': rate,
          'flag': flagAsset,
          'trend': 'down', // You can adjust based on actual data logic
          'dropdown': () => dropdown(key, rate.toString(), flagAsset, name),
        });
      }
    }

    setState(() {
      currencyListData = dataList;
      filteredCurrencies = List.from(currencyListData);
    });
  }

  void setupDataFromProvider() {
    // Fallback method if API fails
    Map currencies = jsonDecode(
      context.read<Providers>().manualCurrency["currencies"],
    );
    currencies.removeWhere((key, value) => !currencyList.contains(key));

    final dataList = <Map<String, dynamic>>[];

    for (int i = 0; i < currencyList.length; i++) {
      String key = currencyList[i];
      if (currencies.containsKey(key)) {
        final name = currencyNames[i];
        final rate = currencies[key];
        final flagAsset = getFlagAssetFromCode(key);

        dataList.add({
          'abbre': key,
          'name': name,
          'rate': rate,
          'flag': flagAsset,
          'trend': 'down',
          'dropdown': () => dropdown(key, rate.toString(), flagAsset, name),
        });
      }
    }

    setState(() {
      currencyListData = dataList;
      filteredCurrencies = List.from(currencyListData);
    });
  }

  void _filterCurrencies() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredCurrencies = currencyListData
          .where((item) => item['name'].toLowerCase().contains(query))
          .toList();
    });
  }

  String getFlagAssetFromCode(String code) {
    final map = {
      'AED': 'united-arab-emirates',
      'AUD': 'australia',
      'BRL': 'brazil',
      'CAD': 'canada',
      'CHF': 'switzerland',
      'CNY': 'china',
      'EUR': 'european-union',
      'GBP': 'united-kingdom',
      'GHS': 'ghana-flag',
      'IDR': 'indonesia',
      'INR': 'india-flag',
      'JPY': 'japan',
      'MXN': 'mexico',
      'NGN': 'nigerian-flag',
      'RUB': 'russia',
      'SAR': 'saudi-arabia',
      'USD': 'united-states-of-america',
      'ZAR': 'south-africa',
    };
    return map[code] ?? 'default-flag';
  }

  void dropdown(String abbre, String rate, String asset, String name) {
    final userCurrency = context.read<Providers>().currency;
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    val.text = rate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.zero,
        titlePadding: EdgeInsets.symmetric(vertical: width * .05),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(width * .05),
        ),
        backgroundColor: Colors.white,
        title: Image.asset("assets/images/$asset.png", height: height * .06),
        content: StatefulBuilder(
          builder: (context, StateSetter setState) {
            return SizedBox(
              width: width * .8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "How much $name to 1 $userCurrency",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: width * .04,
                    ),
                  ),
                  SizedBox(height: height * .01),
                  TextField(
                    controller: val,
                    enabled: !loading,
                    keyboardType: TextInputType.number,
                    inputFormatters: [amountValidator],
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(width * .03),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: height * .02),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(width * .01),
                      ),
                    ),
                    onPressed: () => save(abbre),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * .02,
                        vertical: width * .01,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Submit",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * .045,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (loading)
                            Padding(
                              padding: EdgeInsets.only(left: width * .05),
                              child: SizedBox(
                                height: 25,
                                width: 25,
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.white.withOpacity(.6),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withOpacity(.6),
                                  ),
                                  strokeWidth: 2.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> save(String abbre) async {
    FocusScope.of(context).unfocus();
    if (loading) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');

    final url = Uri.parse("$baseUrl/app/tools/preference/exchange");

    setState(() => loading = true);

    final response = await http.post(
      url,
      body: {"currency": abbre, "rate": val.text},
      headers: {"Authorization": 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      const dashUrl = "$baseUrl/app/dashboard";
      final responseD = await dio.get(
        dashUrl,
        options: Options(headers: {"Authorization": 'Bearer $token'}),
      );

      if (responseD.statusCode == 200) {
        context.read<Providers>().setDashData(responseD.data);
        context.read<Providers>().setCurrency(
          responseD.data["gap_currencies"]["user_currency"],
        );
        context.read<Providers>().setManualCurrency(
          responseD.data["gap_currencies"]["manual_currencies"],
        );
        context.read<Providers>().setSystemCurrency(
          responseD.data["gap_currencies"]["system_currencies"],
        );

        Fluttertoast.showToast(msg: 'Update Successful');
        Navigator.pop(context);
        Navigator.pop(context);
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (_) => ExchangeRates()),
        // );
      } else {
        Fluttertoast.showToast(msg: 'Update unsuccessful');
        Navigator.pop(context);
      }
    } else {
      Fluttertoast.showToast(msg: 'Update unsuccessful');
      Navigator.pop(context);
    }

    setState(() => loading = false);
  }

  Widget _trendIcon(String trend) {
    return Image.asset(
      trend == 'high'
          ? 'assets/settings/trending-up.png'
          : 'assets/settings/trending-down.png',
      width: 12.sp,
      height: 12.sp,
    );
  }

  @override
  Widget build(BuildContext context) {
    final symbolCurrency = context.read<Providers>().snapshotmodel.currency;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.blackColor,
              size: 20.sp,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        // bottomNavigationBar: const BottomNav(4),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exchange Rates',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatLastUpdate(lastUpdate),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          isDense: true, // Makes the field more compact
                          contentPadding: EdgeInsets.symmetric(vertical: 8.sp),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                              color: Color(0xffdddddd),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 0.5,
                            ),
                          ),
                          prefixIcon: IconButton(
                            icon: Image.asset(
                              'assets/settings/search.png',
                              width: 20.sp,
                              height: 20.sp,
                              fit: BoxFit.contain,
                            ),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(
                              maxWidth: 40.sp,
                              maxHeight: 30.sp,
                            ),
                          ),
                          hintText: 'Search',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    InkWell(
                      onTap: () {
                        searchController.clear();
                        FocusScope.of(context).unfocus();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),
                Expanded(
                  child: isLoadingRates
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: filteredCurrencies.length,
                          itemBuilder: (context, index) {
                            final currency = filteredCurrencies[index];
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 5.h,
                                horizontal: 10.w,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/images/${currency['flag']}.png',
                                            width: 30,
                                          ),
                                          SizedBox(width: 10.w),
                                          Text(
                                            currency['name'],
                                            style: GoogleFonts.nunitoSans(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          border: Border.all(
                                            color: AppColors.borderColor,
                                            width: 1,
                                          ),
                                        ),
                                        child: _trendIcon(currency['trend']),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5.h),
                                  Text(
                                    '${symbolCurrency}1.00 = ${double.parse(currency['rate'].toString()).toStringAsPrecision(4)}',
                                    style: GoogleFonts.nunitoSans(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatLastUpdate(String? lastUpdate) {
    if (lastUpdate == null || lastUpdate.isEmpty) return '';
    try {
      final date = DateTime.parse(lastUpdate);
      return 'Last updated: ${DateFormat('d MMMM yyyy').format(date)}';
    } catch (_) {
      return 'Last updated: $lastUpdate';
    }
  }
}
