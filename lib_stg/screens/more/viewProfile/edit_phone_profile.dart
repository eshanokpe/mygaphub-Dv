import 'dart:io';
import 'dart:convert';

import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_picker/country_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phone_number/phone_number.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
 
import 'verify_number.dart';

class EditPhoneScreen extends StatefulWidget {
  final String initialPhone;
  final bool isPhone;

  const EditPhoneScreen({
    super.key,
    required this.initialPhone,
    required this.isPhone,
  });

  @override
  _EditPhoneScreenState createState() => _EditPhoneScreenState();
}

class _EditPhoneScreenState extends State<EditPhoneScreen> {
  late TextEditingController _numberController;
  late FocusNode _focusNode;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Country _selectedCountry = Country.parse('GB'); // Default to UK
  bool _isSaving = false;
  bool _isPhoneValid = false;
  final PhoneNumberUtil _phoneUtil = PhoneNumberUtil();
  late List<Country> _allCountries;
  bool _hasShownEmptyFieldPopup = false;
  List<Map<String, dynamic>> _popularCurrencies = [];
  bool _isLoadingCountries = false;

  // Cache for popular currencies
  static List<Map<String, dynamic>>? _cachedPopularCurrencies;
  static DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(
    hours: 24,
  ); // Cache for 24 hours

  // Default fallback currencies (used when no cache and no internet)
  final List<Map<String, dynamic>> _defaultCurrencies = const [
    {"currency": "\$ USD", "flag": "united-states", "country": "US Dollar"},
    {"currency": "€ EUR", "flag": "european-union", "country": "Euro"},
    {
      "currency": "£ GBP",
      "flag": "united-kingdom",
      "country": "Pound Sterling",
    },
    {"currency": "₦ NGN", "flag": "nigeria", "country": "Nigerian Naira"},
    {
      "currency": "A\$ AUD",
      "flag": "australia",
      "country": "Australian Dollar",
    },
    {"currency": "¥ JPY", "flag": "japan", "country": "Japan Yen"},
    {"currency": "¢ GHS", "flag": "ghana", "country": "Ghana Cedis"},
    {"currency": "CF CHF", "flag": "swizerland", "country": "Swiss Franc"},
    {"currency": "C\$ CAD", "flag": "canada", "country": "Canadian Dollar"},
    {"currency": "元 CNY", "flag": "china", "country": "Renminbi"},
    {"currency": "\$ MXN", "flag": "mexico", "country": "Mexican Peso"},
    {"currency": "₹ INR", "flag": "india", "country": "Indian Rupee"},
    {"currency": "₽ RUB", "flag": "russia", "country": "Russian ruble"},
    {
      "currency": "R ZAR",
      "flag": "south-africa",
      "country": "South African Rand",
    },
    {"currency": "R\$ BRL", "flag": "brazil", "country": "Brazilian real"},
    {
      "currency": "د.إ AED",
      "flag": "united-arab-emirates",
      "country": "UAE Dirham",
    },
    {"currency": "﷼ SAR", "flag": "saudi-arabia", "country": "Saudi Riyal"},
    {"currency": "Rp IDR", "flag": "indonesia", "country": "Indonesian rupiah"},
  ];

  // Add country phone number length mapping
  final Map<String, int> _countryPhoneLengths = {
    'US': 10, // United States
    'GB': 10, // United Kingdom
    'NG': 10, // Nigeria
    'AU': 9, // Australia
    'JP': 10, // Japan
    'GH': 9, // Ghana
    'CH': 9, // Switzerland
    'CA': 10, // Canada
    'CN': 11, // China
    'MX': 10, // Mexico
    'IN': 10, // India
    'RU': 10, // Russia
    'ZA': 9, // South Africa
    'BR': 11, // Brazil
    'AE': 9, // UAE
    'SA': 9, // Saudi Arabia
    'ID': 10, // Indonesia
    'DE': 10, // Germany (for Euro)
  };

  @override
  void initState() {
    super.initState();

    _allCountries = CountryService().getAll();
    String nationalNumber = '';
    if (widget.initialPhone.trim().isNotEmpty &&
        widget.initialPhone.trim().toLowerCase() != 'null') {
      String fullNumber = widget.initialPhone;

      // Try to extract country code and find the national number
      for (var country in _allCountries) {
        String countryCode = '+${country.phoneCode}';
        if (fullNumber.startsWith(countryCode)) {
          nationalNumber = fullNumber.substring(countryCode.length);
          _selectedCountry = country; // Set the correct country
          break;
        }
      }
      // If no country code match found, use the full number
      if (nationalNumber.isEmpty) {
        nationalNumber = fullNumber;
      }
    }

    _numberController = TextEditingController(text: nationalNumber);
    _focusNode = FocusNode();
    _allCountries = CountryService().getAll();

    // Load popular currencies with caching
    _loadPopularCurrencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialEmptyField();
    });
  }

  // Add the missing method here
  void _checkInitialEmptyField() {
    if (!_hasShownEmptyFieldPopup && _numberController.text.isEmpty) {
      _hasShownEmptyFieldPopup = true;
      validationResponse(
        context,
        'Empty Field',
        'Please enter the phone number.',
      );
    }
  }

  Future<void> _loadPopularCurrencies() async {
    // First, load from cache if available
    if (_cachedPopularCurrencies != null) {
      setState(() {
        _popularCurrencies = _cachedPopularCurrencies!;
      });
    } else {
      // If no cache, show defaults immediately
      setState(() {
        _popularCurrencies = _defaultCurrencies;
      });
    }

    // Then fetch fresh data in background if cache is expired
    if (_shouldRefreshCache()) {
      _fetchPopularCurrencies();
    }
  }

  bool _shouldRefreshCache() {
    if (_cachedPopularCurrencies == null) return true;
    if (_lastFetchTime == null) return true;
    return DateTime.now().difference(_lastFetchTime!) > _cacheDuration;
  }

  Future<void> _fetchPopularCurrencies() async {
    // Don't show loading indicator for background refresh
    // Only show if we have no data at all
    if (_popularCurrencies.isEmpty) {
      setState(() {
        _isLoadingCountries = true;
      });
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      final response = await http
          .get(
            Uri.parse('$baseUrl/app/exchange'),
            headers: {
              "Authorization": 'Bearer $token',
              "Accept": "application/json",
            },
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => http.Response('Timeout', 408),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final currencies = List<Map<String, dynamic>>.from(
            data['data']['popular_currencies'] ?? [],
          );

          // Update cache
          _cachedPopularCurrencies = currencies;
          _lastFetchTime = DateTime.now();

          // Save to SharedPreferences for persistence across app restarts
          await prefs.setString('popular_currencies', jsonEncode(currencies));

          if (mounted) {
            setState(() {
              _popularCurrencies = currencies;
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching popular currencies: $e");

      // Try to load from SharedPreferences if cache is empty
      if (_cachedPopularCurrencies == null) {
        final prefs = await SharedPreferences.getInstance();
        final saved = prefs.getString('popular_currencies');
        if (saved != null) {
          try {
            final List<dynamic> decoded = jsonDecode(saved);
            final savedCurrencies = List<Map<String, dynamic>>.from(decoded);
            _cachedPopularCurrencies = savedCurrencies;
            if (mounted) {
              setState(() {
                _popularCurrencies = savedCurrencies;
              });
            }
          } catch (e) {
            // If saved data is corrupted, keep defaults
          }
        }
      }
    } finally {
      if (mounted && _popularCurrencies.isEmpty) {
        setState(() {
          _isLoadingCountries = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && _numberController.text.isEmpty) {
      validationResponse(
        context,
        'Empty Field',
        'Please enter a phone number to continue',
      );
    }
  }

  Future<void> _saveNumber() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = Provider.of<Providers>(context, listen: false);

    // Get dial code from selected country
    final dialCode = '+${_selectedCountry.phoneCode}';

    if (_numberController.text.isNotEmpty) {
      _validatePhoneNumber(_numberController.text);
    }

    setState(() {
      _isSaving = true;
    });

    // ✅ Call the OTP sending function
    String otpResult = await sendOtp(_numberController.text);
    print("otpResult:$otpResult");
    print("dialCode:$dialCode");

    setState(() {
      _isSaving = false;
    });

    if (otpResult == 'ALREADY_VERIFIED') {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('tokenDB');

        final provider = Provider.of<Providers>(context, listen: false);

        // Format the phone number with dial code
        final formattedPhoneNumber =
            '$dialCode${_numberController.text.replaceAll(' ', '')}';

        provider.updatePhoneNumber(formattedPhoneNumber);

        var url = Uri.parse("$baseUrl/app/editprofile");
        var response = await http.post(
          url,
          body: {
            "phone": formattedPhoneNumber, // Use the formatted phone number
          },
          headers: {
            "Authorization": 'Bearer $token',
            "Accept": "application/json",
          },
        );

        if (response.statusCode == 200) {
          // Return the formatted phone number to the previous screen
          Navigator.pop(context, formattedPhoneNumber);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phone number updated successfully')),
          );
        } else if (response.statusCode == 429) {
          final body = jsonDecode(response.body);
          print('Error 429: ${body['message']}');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${body['message']}')));
        } else {
          final body = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${body['message'] ?? 'Failed to update phone number'}',
              ),
            ),
          );
        }
      } catch (e) {
        print("Error updating profile: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while updating phone number'),
          ),
        );
      }
    } else if (otpResult == 'SUCCESS') {
      // Phone needs verification, go to verification screen
      navigateWithSlideTransition(
        context: context,
        destinationScreen: VerifyNumberProfile(
          firstName: provider.details[0],
          lastName: provider.details[1],
          email: provider.details[2],
          phoneNumber: _numberController.text,
          dialCode: dialCode,
        ),
        transitionDuration: const Duration(milliseconds: 200),
      );
    }
    // If otpResult is 'ERROR', do nothing (error is already handled)
  }

  Future<String> sendOtp(String phoneNumber) async {
    try {
      final dialCode = '+${_selectedCountry.phoneCode}';
      var number = _numberController.text.replaceAll(' ', '');
      print('phoneNumber:$dialCode$number');

      final response = await http.post(
        Uri.parse('$baseUrl/whatsapp/send-otp'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': 'pT79hjfC91lG7gViU3tSHixtxlZZfvUBfDFeOFKP',
        },
        body: jsonEncode({'phone_number': '$dialCode$number'}),
      );

      print('OTP:${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("OTP sent response: $data");

        // Check if phone number is already verified
        if (data['status'] == true && data['data'] != null) {
          final state = data['data']['state'];
          if (state == 'ALREADY_VERIFIED') {
            return 'ALREADY_VERIFIED'; // Special return value for already verified
          }
        }

        return 'SUCCESS'; // Regular success
      } else if (response.statusCode == 429) {
        final body = jsonDecode(response.body);
        print('Error 429: ${body['message']}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${body['message']}')));
        return 'ERROR';
      } else {
        final data = jsonDecode(response.body);
        print("OTP sent response: $data");
        print("Failed to send OTP: ${response.statusCode}");
        return 'ERROR';
      }
    } catch (e) {
      print("Error sending OTP: $e");
      validationResponse(context, 'Error', e.toString());
      return 'ERROR';
    }
  }

  void _openCountryPicker() {
    if (Platform.isIOS) {
      _showMaterialCountryPicker(); // Use Material for iOS as well
    } else {
      _showMaterialCountryPicker();
    }
  }

  void _showMaterialCountryPicker() {
    List<Map<String, dynamic>> filteredCurrencies = List.from(
      _popularCurrencies,
    );

    TextEditingController searchController = TextEditingController();
    bool hasText = false;

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void filterCountries(String query) {
              setModalState(() {
                filteredCurrencies = _popularCurrencies
                    .where(
                      (currency) => currency['country'].toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                    )
                    .toList();
              });
            }

            searchController.addListener(() {
              setModalState(() {
                hasText = searchController.text.isNotEmpty;
              });
            });

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.80,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle bar
                      Container(
                        width: 45,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xffcdcdcd),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Search Field
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              onChanged: filterCountries,
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
                                hintText: 'Search ',
                                hintStyle: GoogleFonts.nunitoSans(
                                  fontSize: 14.sp,
                                  color: AppColors.grayColor,
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
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.h,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          hasText
                              ? GestureDetector(
                                  onTap: () {
                                    searchController.clear();
                                    filterCountries('');
                                  },
                                  child: Text(
                                    "Cancel",
                                    style: GoogleFonts.nunitoSans(
                                      color: Colors.black,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Image.asset(
                                    'assets/settings/xcancel.png',
                                    width: 30.sp,
                                    height: 30.sp,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                          SizedBox(width: 10.w),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // Currency List (no loading indicator since we show data immediately)
                      Expanded(
                        child: filteredCurrencies.isEmpty
                            ? Center(
                                child: Text(
                                  'No countries available',
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 14.sp,
                                    color: AppColors.grayColor,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredCurrencies.length,
                                itemBuilder: (context, index) {
                                  final currency = filteredCurrencies[index];
                                  final countryCode =
                                      _getCountryCodeFromCurrency(currency);
                                  final phoneCode = _getPhoneCodeFromCurrency(
                                    currency,
                                  );

                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 0,
                                    ),
                                    leading: Text(
                                      _getFlagEmoji(currency['flag']),
                                      style: TextStyle(fontSize: 20.sp),
                                    ),
                                    title: Text(
                                      _formatFlagName(currency['flag']),
                                      style: GoogleFonts.nunitoSans(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    trailing: Text(
                                      '+$phoneCode',
                                      style: GoogleFonts.nunitoSans(
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    onTap: () {
                                      if (countryCode != null &&
                                          phoneCode != null) {
                                        final country = Country.tryParse(
                                          countryCode,
                                        );
                                        if (country != null) {
                                          setState(
                                            () => _selectedCountry = country,
                                          );
                                          Navigator.pop(context);
                                          _checkPhoneValidity(
                                            _numberController.text,
                                          );
                                        }
                                      }
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getFlagEmoji(String flagName) {
    // Map flag names to emojis
    final flagMap = {
      'united-states': '🇺🇸',
      'european-union': '🇪🇺',
      'united-kingdom': '🇬🇧',
      'nigeria': '🇳🇬',
      'australia': '🇦🇺',
      'japan': '🇯🇵',
      'ghana': '🇬🇭',
      'swizerland': '🇨🇭',
      'canada': '🇨🇦',
      'china': '🇨🇳',
      'mexico': '🇲🇽',
      'india': '🇮🇳',
      'russia': '🇷🇺',
      'south-africa': '🇿🇦',
      'brazil': '🇧🇷',
      'united-arab-emirates': '🇦🇪',
      'saudi-arabia': '🇸🇦',
      'indonesia': '🇮🇩',
    };
    return flagMap[flagName] ?? '🏳️';
  }

  String? _getCountryCodeFromCurrency(Map<String, dynamic> currency) {
    // Map currency countries to country codes
    final countryMap = {
      'US Dollar': 'US',
      'Euro': 'DE', // Using Germany for Euro
      'Pound Sterling': 'GB',
      'Nigerian Naira': 'NG',
      'Australian  Dollar': 'AU',
      'Japan Yen': 'JP',
      'Ghana Cedis': 'GH',
      'Swiss Franc': 'CH',
      'Canadian Dollar': 'CA',
      'Renminbi': 'CN',
      'Mexican Peso': 'MX',
      'Indian Rupee': 'IN',
      'Russian ruble': 'RU',
      'South African Rand': 'ZA',
      'Brazilian real': 'BR',
      'UAE Dirham': 'AE',
      'Saudi Riyal': 'SA',
      'Indonesian rupiah': 'ID',
    };
    return countryMap[currency['country']];
  }

  String? _getPhoneCodeFromCurrency(Map<String, dynamic> currency) {
    // Map currency countries to phone codes
    final phoneCodeMap = {
      'US Dollar': '1',
      'Euro': '49', // Germany
      'Pound Sterling': '44',
      'Nigerian Naira': '234',
      'Australian  Dollar': '61',
      'Japan Yen': '81',
      'Ghana Cedis': '233',
      'Swiss Franc': '41',
      'Canadian Dollar': '1',
      'Renminbi': '86',
      'Mexican Peso': '52',
      'Indian Rupee': '91',
      'Russian ruble': '7',
      'South African Rand': '27',
      'Brazilian real': '55',
      'UAE Dirham': '971',
      'Saudi Riyal': '966',
      'Indonesian rupiah': '62',
    };
    return phoneCodeMap[currency['country']];
  }

  int? _getPhoneLengthFromCountryCode(String? countryCode) {
    if (countryCode == null) return null;
    return _countryPhoneLengths[countryCode];
  }

  bool _isValidPhoneLength(String phoneNumber) {
    final countryCode = _selectedCountry.countryCode;

    final expectedLength = _countryPhoneLengths[countryCode];
    if (expectedLength == null) return true;

    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length == expectedLength;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom == 0
                        ? 220.h
                        : 100.h,
                  ),
                  Center(
                    child: Text(
                      "Edit your WhatsApp Number",
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14.sp,
                        color: AppColors.grayColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Country Picker Button
                      InkWell(
                        onTap: _openCountryPicker,
                        child: Container(
                          height: 55.h,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: const Color(0xfff3f3f3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _selectedCountry.flagEmoji,
                                style: TextStyle(fontSize: 20.sp),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '+${_selectedCountry.phoneCode}',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.blackColor,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              Icon(
                                Icons.keyboard_arrow_down_outlined,
                                color: Colors.grey,
                                size: 20.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: TextFormField(
                          focusNode: _focusNode,
                          keyboardType: TextInputType.phone,
                          controller: _numberController,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(15),
                          ],
                          style: GoogleFonts.nunitoSans(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          validator: _validatePhoneNumber,
                          decoration: InputDecoration(
                            hintText: '123 123456',
                            hintStyle: GoogleFonts.nunitoSans(
                              fontSize: 22.sp,
                              color: AppColors.grayColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xfff3f3f3),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.h,
                              horizontal: 8.w,
                            ),
                          ),
                          onChanged: (value) {
                            _checkPhoneValidity(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom == 0
                        ? 300.h
                        : 170.h,
                  ),

                  ElevatedButton(
                    onPressed: _isPhoneValid ? _saveNumber : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      minimumSize: Size.fromHeight(60.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Next',
                            style: GoogleFonts.nunitoSans(
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getPhoneLengthHint() {
    final countryCode = _selectedCountry.countryCode;

    final expectedLength = _countryPhoneLengths[countryCode];
    if (expectedLength == null) return 'Enter phone number';

    return 'Enter $expectedLength-digit phone number for ${_selectedCountry.name}';
  }

  Future<void> _checkPhoneValidity(String value) async {
    final region = _selectedCountry.countryCode;
    final dialCode = '+${_selectedCountry.phoneCode}';

    if (dialCode == null) return;

    final numberDigitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    // Check length first before making API calls
    final expectedLength = _getPhoneLengthFromCountryCode(region);
    final currentLength = numberDigitsOnly.length;

    // Show validation response for invalid length
    if (expectedLength != null &&
        numberDigitsOnly.isNotEmpty &&
        currentLength != expectedLength) {
      if (currentLength > expectedLength) {
        validationResponse(
          context,
          'Error',
          'The phone number you provided is invalid. Please enter a correct one.',
        );
      }
      setState(() {
        _isPhoneValid = false;
      });
      return;
    }

    try {
      final fullNumber = '$dialCode$numberDigitsOnly';
      final parsed = await _phoneUtil.parse(fullNumber, regionCode: region);
      final isValid = await _phoneUtil.validate(fullNumber, regionCode: region);
      final isLengthValid = parsed.nationalNumber == numberDigitsOnly;

      final valid = isValid && isLengthValid;

      setState(() {
        _isPhoneValid = valid;
      });

      print('valid:$valid');
      print('_isPhoneValid:$_isPhoneValid');
    } catch (e) {
      setState(() {
        _isPhoneValid = false;
      });
    }
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      setState(() => _isPhoneValid = false);
      validationResponse(
        context,
        'Empty Field',
        'Please enter a phone number to continue.',
      );
      return 'Phone number is required';
    }

    // Validate phone number length
    if (!_isValidPhoneLength(value)) {
      final expectedLength = _getPhoneLengthFromCountryCode(
        _selectedCountry.countryCode,
      );
      return 'Phone number for ${_selectedCountry.name} should be $expectedLength digits';
    }

    return null;
  }

  void validationResponse(
    BuildContext context,
    String? title,
    String? message,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.only(top: 50.h),
          padding: EdgeInsets.symmetric(horizontal: 24.h, vertical: 20.w),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                title ?? '',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 15.h),
              Text(
                message ?? '',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 14.sp,
                  color: AppColors.grayColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  FocusScope.of(context).unfocus();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: Text(
                  "Go back",
                  style: GoogleFonts.nunitoSans(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        );
      },
    );
  }

  String _formatFlagName(String flagName) {
    return flagName
        .split('-')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
