import 'dart:convert';
import 'package:GapHub/models/snapshotmodel.dart';
import 'package:GapHub/provider/AuthProvider.dart';
import 'package:GapHub/provider/currencyProvider.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'settings.dart'; 

class ChangeBaseCurrency extends StatefulWidget {
  const ChangeBaseCurrency({super.key});

  @override
  _CurrencyState createState() => _CurrencyState();
}

class _CurrencyState extends State<ChangeBaseCurrency> {
  final TextEditingController searchController = TextEditingController();
  DialogBox dialogBox = DialogBox();

  List<Map<String, dynamic>> _currencies = [];
  List<Map<String, dynamic>> _allCurrencies = [];

  bool _buttonEnabled = false;
  String? dataCurrency;
  String? currencySymbol;
  Map calculatorData = {};
  String? symbol;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Get dataCurrency immediately
    final providers = context.read<Providers>();
    dataCurrency = providers.snapshotmodel.currency;
    print('Initial dataCurrency: $dataCurrency');

    loadCurrencyData();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadCurrencyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      // Make API call to get popular currencies
      var urlPopularCurrencies = Uri.parse("$baseUrl/app/exchange");
      final responsePopularCurrencies = await http.get(
        urlPopularCurrencies,
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ); 

      if (responsePopularCurrencies.statusCode == 200) {
        final body = jsonDecode(responsePopularCurrencies.body);
        final popularCurrencies = body['data']['popular_currencies'] as List?;

        print("popular_currencies from API: ${popularCurrencies?.length}");

        if (popularCurrencies != null && popularCurrencies.isNotEmpty) {
          // Convert API response to match your expected structure
          final processedCurrencies = popularCurrencies.map((currency) {
            // Parse the currency string (e.g., "$ USD" -> symbol: "$", code: "USD")
            final currencyString = currency['currency']?.toString() ?? '';
            final parts = currencyString.split(' ');
            final symbol = parts.isNotEmpty ? parts[0] : '';
            final code = parts.length > 1 ? parts[1] : '';

            return {
              'symbol': symbol,
              'code': code,
              'name': currency['country']?.toString() ?? 'Unknown Currency',
              'flag': currency['flag']?.toString() ?? '',
              'isSelected': false,
            };
          }).toList();

          if (mounted) {
            setState(() {
              _allCurrencies = processedCurrencies.cast<Map<String, dynamic>>();
              _currencies = List.from(_allCurrencies);
            });

            // Wait for the next frame to ensure dataCurrency is updated
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _selectCurrencyFromData();
            });
          }
        } else {
          print("No popular currencies found in API response");
          if (mounted) {
            setState(() {
              _allCurrencies = [];
              _currencies = [];
            });
          }
        }
      } else {
        print(
          "API request failed with status: ${responsePopularCurrencies.statusCode}",
        );
        if (mounted) {
          setState(() {
            _allCurrencies = [];
            _currencies = [];
          });
        }
      }
    } catch (e) {
      print("Error loading currency data: $e");
      if (mounted) {
        setState(() {
          _allCurrencies = [];
          _currencies = [];
        });
      }
    }
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();

    setState(() {
      _currencies = _allCurrencies.where((currency) {
        final name = currency['name']?.toString().toLowerCase() ?? '';
        final symbol = currency['symbol']?.toString().toLowerCase() ?? '';
        final code = currency['code']?.toString().toLowerCase() ?? '';
        return name.contains(query) ||
            symbol.contains(query) ||
            code.contains(query);
      }).toList();
    });
  }

  void _selectCurrencyFromData() {
    print('dataCurrency: $dataCurrency');
    print('_currencies length: ${_currencies.length}');

    if (dataCurrency != null &&
        dataCurrency!.isNotEmpty &&
        _currencies.isNotEmpty) {
      bool found = false;

      for (int i = 0; i < _currencies.length; i++) {
        try {
          final currency = _currencies[i];
          final currencyCode = currency['code']?.toString() ?? '';
          final currencySymbol = currency['symbol']?.toString() ?? '';

          print(
            'Checking currency: symbol="$currencySymbol", code="$currencyCode"',
          );

          // Extract just the symbol from dataCurrency if it contains space
          String dataCurrencySymbol = dataCurrency!;
          if (dataCurrency!.contains(" ")) {
            var symbolParts = dataCurrency!.split(" ");
            if (symbolParts.isNotEmpty) {
              dataCurrencySymbol =
                  symbolParts[0]; // Get the symbol part (e.g., "$")
            }
          }

          // Compare with the symbol from API data
          if (dataCurrencySymbol == currencySymbol) {
            _toggleSelection(i);
            found = true;
            print(
              "✅ Selected currency: ${currency['name']} (symbol: $currencySymbol)",
            );
            break;
          }
        } catch (e) {
          print("Error checking currency at index $i: $e");
        }
      }

      if (!found) {
        print("❌ No matching currency found for dataCurrency: $dataCurrency");
        // Print all available currencies for debugging
        for (final currency in _currencies) {
          print(
            'Available: symbol="${currency['symbol']}" code="${currency['code']}" - ${currency['name']}',
          );
        }
      }
    } else {
      print("No dataCurrency available or currencies list is empty");
      if (dataCurrency == null || dataCurrency!.isEmpty) {
        print("dataCurrency is null or empty");
      }
      if (_currencies.isEmpty) {
        print("_currencies list is empty");
      }
    }
  }

  void _toggleSelection(int index) {
    if (!mounted) return;
    setState(() {
      for (int i = 0; i < _currencies.length; i++) {
        _currencies[i]['isSelected'] = (i == index);
      }
      _buttonEnabled = true;
    });
  }

  Future<void> savePreferences() async {
    if (!_buttonEnabled) return;

    // Find the selected currency to get both symbol and code
    final selectedCurrency = _currencies.firstWhere(
      (currency) => currency['isSelected'] == true,
    );

    final String symbol = selectedCurrency['symbol']?.toString() ?? '';
    final String code = selectedCurrency['code']?.toString() ?? '';

    // Create the formatted currency string (e.g., "$ USD")
    final String formattedCurrency = code;

    print("currencyCode: $formattedCurrency");
    print("currencySymbol: $symbol");
    setState(() => _isLoading = true);

    var urlPreferences = Uri.parse("$baseUrl/app/settings/preferences");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    // Use the formatted currency string
    final settingsData = {"preferred_currency": formattedCurrency};

    try {
      final responsePreferences = await http.put(
        urlPreferences,
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: json.encode(settingsData),
      ); 

      if (responsePreferences.statusCode == 200) {
        final body = jsonDecode(responsePreferences.body);
        final data = body['data'] ?? 'Preferences updated';
        var updateCurrency = data['preferred_currency'];

        print('Updated currency: $updateCurrency');

        // ✅ UPDATE ALL CURRENCY REFERENCES CONSISTENTLY
        final providers = context.read<Providers>();
        final currencyProvider = context.read<CurrencyProvider>();

        // 1. Update snapshotmodel currency (what your UI is watching)
        // providers.updateSnapshotCurrency(updateCurrency);

        // 2. Update base currency in Providers
        providers.setBaseCurrency(updateCurrency);

        // 3. Update CurrencyProvider
        currencyProvider.setBaseCurrency(updateCurrency);

        // 4. Refresh AuthProvider data to ensure consistency
        await context.read<AuthProvider>().signInDetails(context);

        // ✅ Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences updated successfully')),
        );

        // ✅ Navigate with updated base currency
        Navigator.pop(context);
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => Settings(baseCurrency: formattedCurrency),
        //   ),
        //   (route) => false, // This removes all previous routes
        // );
      } else if (responsePreferences.statusCode == 429) {
        final body = jsonDecode(responsePreferences.body);
        Fluttertoast.showToast(msg: body['message']);
      } else {
        final body = jsonDecode(responsePreferences.body);
        print('Error: ${body['message']}');
      }
    } catch (e) {
      print('Exception in savePreferences: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    dataCurrency = context.watch<Providers>().snapshotmodel.currency;
    print('dataCurrency:$dataCurrency');
    _buttonEnabled = _currencies.any(
      (currency) => currency['isSelected'] == true,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _buttonEnabled ? savePreferences : null,
            child: Text(
              'Save',
              style: GoogleFonts.nunitoSans(
                fontWeight: FontWeight.w800,
                fontSize: 16.sp,
                color: const Color(0xff0fb707),
              ),
            ),
          ),
          if (_isLoading)
            const Center(child: SpinKitCircle(color: Colors.black, size: 30.0)),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Base Currency',
                style: GoogleFonts.nunitoSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 22.sp,
                  color: AppColors.blackColor,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                'Select the base currency for your account',
                style: GoogleFonts.nunitoSans(
                  fontWeight: FontWeight.w400,
                  fontSize: 16.sp,
                  color: AppColors.grayColor,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
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
                            maxHeight: 40.sp,
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
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black, fontSize: 14.sp),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _currencies.length,
                itemBuilder: (context, index) {
                  final currency = _currencies[index];
                  final bool isSelected = currency['isSelected'] ?? false;

                  return Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () {
                          print('Tapped on: ${currency['name']}');
                          context.read<Providers>().setSymbol(
                            '${currency['symbol']} ${currency['code']}',
                          );
                          _toggleSelection(index);
                        },
                        trailing: isSelected
                            ? Icon(
                                Icons.check,
                                color: AppColors.primaryColor,
                                size: 16.sp,
                              )
                            : null,
                        leading: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFF03222F),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: Text(
                              currency['symbol']?.toString() ?? '',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunitoSans(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          currency['name']?.toString() ?? 'Unknown Currency',
                          style: GoogleFonts.nunitoSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                            color: AppColors.blackColor,
                          ),
                        ),
                        // subtitle: Text(
                        //   '${currency['symbol']} ${currency['code']}',
                        //   style: GoogleFonts.nunitoSans(
                        //     fontWeight: FontWeight.w400,
                        //     fontSize: 12.sp,
                        //     color: AppColors.grayColor,
                        //   ),
                        // ),
                      ),
                      if (index != _currencies.length - 1)
                        Divider(
                          height: 1.h,
                          thickness: 1.h,
                          color: Colors.grey[200],
                          indent: 16.w,
                          endIndent: 16.w,
                        ),
                    ],
                  );
                },
              ),
              SizedBox(height: 50.h),
            ],
          ),
        ),
      ),
    );
  }
}
