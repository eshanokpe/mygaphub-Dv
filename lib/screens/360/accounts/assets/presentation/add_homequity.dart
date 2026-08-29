import 'dart:async';
import 'dart:convert';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart' as legacy;

import 'package:GapHub/provider/providers.dart';
import '../../../widget/percentageInput.dart';
import '../../../widget/textInput.dart';
import '../../SuccessModal.dart';
import '../../protection/addProtection/widget/coverStartField.dart';
import '../../retirement/presentation/widget/currencyInput.dart';
import '../../retirement/presentation/widget/currencyInputAge.dart';
import '../provider/home_equity_form_provider.dart';
import '../widget/TargetDate.dart';
import '../widget/bottomSheetPickerField.dart';
import '../../../widget/formLabel.dart';
import '../widget/successModalAssets.dart';
import 'equitydetails.dart';

class AddHomeEquity extends ConsumerStatefulWidget {
  const AddHomeEquity({super.key});

  @override
  ConsumerState<AddHomeEquity> createState() => _AddHomeEquityState();
}

class _AddHomeEquityState extends ConsumerState<AddHomeEquity> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _currentValueController = TextEditingController();
  final FocusNode _zipFocusNode = FocusNode();

  bool _debtLoaded = false;

  late List<Country> _allCountries;

  @override
  void initState() {
    super.initState();
    // _allCountries = CountryService().getAll();
    final allowedCodes = {'GB', 'US', 'CA', 'ZA'};
    _allCountries = CountryService()
        .getAll()
        .where((c) => allowedCodes.contains(c.countryCode))
        .toList();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _currentValueController.dispose();
    _zipFocusNode.dispose();
    super.dispose();
  }

  /// Finds the Country entry matching the currently selected country name
  /// so we can show its flag next to the field. Returns null if nothing
  /// has been picked yet (or the stored value doesn't match a known name).
  Country? _findCountryByName(String name) {
    try {
      return _allCountries.firstWhere((c) => c.name == name);
    } catch (_) {
      return null;
    }
  }

  void _openCountryPicker(HomeEquityFormNotifier notifier) {
    List<Country> filteredCountries = List.from(_allCountries);
    final TextEditingController searchController = TextEditingController();
    bool hasText = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void filterCountries(String query) {
              setModalState(() {
                filteredCountries = _allCountries
                    .where(
                      (country) => country.name.toLowerCase().contains(
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
                        width: 45.w,
                        height: 5.h,
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
                                hintText: 'Search',
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
                                    width: 20.sp,
                                    height: 20.sp,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                          SizedBox(width: 10.w),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // Country List
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredCountries.length,
                          itemBuilder: (context, index) {
                            final country = filteredCountries[index];
                            return ListTile(
                              leading: Text(
                                country.flagEmoji,
                                style: TextStyle(fontSize: 20.sp),
                              ),
                              title: Text(
                                country.name,
                                style: GoogleFonts.nunitoSans(fontSize: 16.sp),
                              ),
                              onTap: () {
                                notifier.setCountry(country.name);
                                Navigator.pop(context);
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

  /// Shared parser for the `address_components` array returned by both the
  /// Place Details and Geocoding APIs (they use the same shape).
  /// Shared parser for the `address_components` array returned by both the
  /// Place Details and Geocoding APIs.
  ({String townCity, String postcode}) _parseAddressComponents(
    List components,
  ) {
    String findByType(List<String> types) {
      // We look for the FIRST match in the priority list
      for (final type in types) {
        final match = components.firstWhere(
          (c) => (c['types'] as List).contains(type),
          orElse: () => null,
        );
        if (match != null) {
          return match['long_name'] as String? ?? '';
        }
      }
      return '';
    }

    // ✅ EXPANDED: Added administrative_area_level_2, sublocality, and neighborhood
    // This catches cities in US, ZA, and other regions that don't use 'postal_town'
    final townCity = findByType([
      'postal_town',
      'locality',
      'administrative_area_level_2',
      'sublocality',
      'neighborhood',
    ]);

    // ✅ EXPANDED: Look for postal_code, then prefix/suffix fallbacks
    var postcode = findByType(['postal_code']);

    if (postcode.isEmpty) {
      final prefix = findByType(['postal_code_prefix']);
      final suffix = findByType(['postal_code_suffix']);
      // Only join if at least one exists
      if (prefix.isNotEmpty || suffix.isNotEmpty) {
        postcode = [prefix, suffix].where((s) => s.isNotEmpty).join(' ');
      }
    }

    return (townCity: townCity, postcode: postcode);
  }

  Future<({String townCity, String postcode})> _fetchAddressComponents(
    String placeId,
  ) async {
    if (placeId.isEmpty) return (townCity: '', postcode: '');
    try {
      final uri =
          Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
            'place_id': placeId,
            'fields': 'address_component,geometry',
            'key': googlePlacesApiKey,
          });
      final response = await http.get(uri);

      if (response.statusCode != 200) return (townCity: '', postcode: '');

      final decoded = jsonDecode(response.body) as Map;

      if (decoded['status'] != 'OK') {
        debugPrint('Place Details Error: ${decoded['error_message']}');
        return (townCity: '', postcode: '');
      }

      final result = decoded['result'] as Map? ?? {};
      final components = (result['address_components'] as List?) ?? [];
      final geometry = result['geometry'] as Map? ?? {};
      final location = geometry['location'] as Map? ?? {};

      final lat = location['lat']?.toDouble();
      final lng = location['lng']?.toDouble();

      var parsedResult = _parseAddressComponents(components);

      debugPrint(
        'Initial Parse -> Town: "${parsedResult.townCity}", Postcode: "${parsedResult.postcode}"',
      );

      // ✅ FIX: If postcode is missing, try reverse geocoding with coordinates
      if (parsedResult.postcode.isEmpty && lat != null && lng != null) {
        debugPrint('Postcode missing — attempting reverse geocoding');
        final reverseResult = await _reverseGeocode(lat, lng);

        if (reverseResult.postcode.isNotEmpty) {
          parsedResult = (
            townCity: parsedResult.townCity.isEmpty
                ? reverseResult.townCity
                : parsedResult.townCity,
            postcode: reverseResult.postcode,
          );
          debugPrint(
            'Reverse geocoded -> Town: "${parsedResult.townCity}", Postcode: "${parsedResult.postcode}"',
          );
        }
      }

      return parsedResult;
    } catch (e) {
      debugPrint('Place Details fetch error: $e');
      return (townCity: '', postcode: '');
    }
  }

  /// ✅ NEW METHOD: Reverse geocode using lat/lng to find nearest postcode
  Future<({String townCity, String postcode})> _reverseGeocode(
    double lat,
    double lng,
  ) async {
    try {
      final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
        'latlng': '$lat,$lng',
        'key': googlePlacesApiKey,
      });
      final response = await http.get(uri);

      if (response.statusCode != 200) return (townCity: '', postcode: '');

      final decoded = jsonDecode(response.body) as Map;

      if (decoded['status'] != 'OK') {
        return (townCity: '', postcode: '');
      }

      final results = (decoded['results'] as List?) ?? [];
      if (results.isEmpty) return (townCity: '', postcode: '');

      // Take the most specific result (first one)
      final components = (results.first['address_components'] as List?) ?? [];
      return _parseAddressComponents(components);
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
      return (townCity: '', postcode: '');
    }
  }

  /// Fallback for when Place Details has no postal_code at all — this
  /// happens for route-level picks (e.g. a bare street name with no house
  /// number), since a street can span multiple postcodes and Place Details
  /// won't guess. The Geocoding API is more willing to interpolate one.
  Future<({String townCity, String postcode})> _fetchFromGeocoding(
    String placeId,
  ) async {
    try {
      final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
        'place_id': placeId,
        'key': googlePlacesApiKey,
      });
      final response = await http.get(uri);

      debugPrint('Geocoding fallback status: ${response.statusCode}');
      debugPrint('Geocoding fallback body: ${response.body}');

      if (response.statusCode != 200) return (townCity: '', postcode: '');

      final decoded = jsonDecode(response.body) as Map;

      debugPrint('Geocoding fallback "status" field: ${decoded['status']}');
      if (decoded['status'] != 'OK') {
        if (decoded['error_message'] != null) {
          debugPrint(
            'Geocoding fallback error_message: ${decoded['error_message']}',
          );
        }
        return (townCity: '', postcode: '');
      }

      // Geocode results is a *list* of results (route + broader areas etc.)
      // — take the first, which is the most specific match for the place_id.
      final results = (decoded['results'] as List?) ?? [];
      if (results.isEmpty) return (townCity: '', postcode: '');

      final components = (results.first['address_components'] as List?) ?? [];
      return _parseAddressComponents(components);
    } catch (e) {
      debugPrint('Geocoding fallback fetch error: $e');
      return (townCity: '', postcode: '');
    }
  }

  Future<void> _openAddressSearch(HomeEquityFormNotifier notifier) async {
    List<Map<String, String>> predictions = [];
    bool isLoading = false;
    Timer? debounce;
    final TextEditingController searchController = TextEditingController();

    Future<void> fetchPredictions(
      String query,
      StateSetter setModalState,
    ) async {
      if (query.trim().isEmpty) {
        setModalState(() => predictions = []);
        return;
      }
      setModalState(() => isLoading = true);
      try {
        final uri = Uri.https(
          'maps.googleapis.com',
          '/maps/api/place/autocomplete/json',
          {
            'input': query,
            // ✅ FIX 1: Use 'geocode' to prioritize precise locations over broad areas
            'types': 'geocode',
            'components': 'country:gb|country:us|country:ca|country:za',
            'key': googlePlacesApiKey,
          },
        );
        final response = await http.get(uri);

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body) as Map;
          if (decoded['status'] == 'OK') {
            final results = (decoded['predictions'] as List?) ?? [];

            // ✅ FIX 2: Filter results to ensure they look like specific addresses
            // We exclude results that are purely 'route' or 'establishment' without a street number
            predictions = results
                .where((p) {
                  // Ensure it has a comma (City/Country separation)
                  // and preferably doesn't look like a pure transit station
                  final desc = p['description'] as String;
                  return desc.contains(',') &&
                      !desc.toLowerCase().contains('station');
                })
                .map<Map<String, String>>(
                  (p) => {
                    'description': p['description'] as String,
                    'place_id': p['place_id'] as String,
                  },
                )
                .toList();
          } else {
            predictions = [];
          }
        }
      } catch (_) {
        predictions = [];
      } finally {
        setModalState(() => isLoading = false);
      }
    }

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext modalContext) {
        // ✅ Use a specific name for modal context
        return StatefulBuilder(
          builder: (BuildContext innerContext, StateSetter setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: SizedBox(
                  height: MediaQuery.of(innerContext).size.height * 0.80,
                  child: Column(
                    children: [
                      Container(
                        width: 45.w,
                        height: 5.h,
                        decoration: BoxDecoration(
                          color: const Color(0xffcdcdcd),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              autofocus: true,
                              onChanged: (value) {
                                debounce?.cancel();
                                debounce = Timer(
                                  const Duration(milliseconds: 400),
                                  () {
                                    fetchPredictions(value, setModalState);
                                  },
                                );
                              },
                              decoration: InputDecoration(
                                hintText: 'Start typing a street address...',
                                hintStyle: GoogleFonts.nunitoSans(
                                  fontSize: 14.sp,
                                  color: AppColors.grayColor,
                                ),
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
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 10.h,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 15.w),
                          GestureDetector(
                            onTap: () {
                              searchController.clear();
                              setModalState(() {
                                predictions = [];
                                isLoading = false;
                              });
                              if (Navigator.canPop(innerContext)) {
                                Navigator.pop(innerContext);
                              }
                            },
                            child: Image.asset(
                              'assets/settings/xcancel.png',
                              width: 20.sp,
                              height: 20.sp,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Expanded(
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : predictions.isEmpty
                            ? Padding(
                                padding: EdgeInsets.only(top: 24.h),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/wheel_segments/search_address.png',
                                      width: 100.w,
                                    ),
                                    SizedBox(height: 12.h),
                                    Text(
                                      'Search for your home address',
                                      style: GoogleFonts.nunitoSans(
                                        color: AppColors.grayColor,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: predictions.length,
                                itemBuilder: (context, index) {
                                  final item = predictions[index];
                                  return ListTile(
                                    title: Text(
                                      item['description'] ?? '',
                                      style: GoogleFonts.nunitoSans(
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                    onTap: () async {
                                      final placeId = item['place_id'] ?? '';
                                      final description =
                                          item['description'] ?? '';

                                      setModalState(() => isLoading = true);

                                      final result =
                                          await _fetchAddressComponents(
                                            placeId,
                                          );

                                      // ✅ FIX: Check if we can still pop before doing so
                                      if (!mounted) return;

                                      notifier.setHomeAddress(description);
                                      notifier.setTownCity(result.townCity);
                                      notifier.setZipcode(result.postcode);

                                      // ✅ FIX: Use innerContext and check canPop
                                      if (Navigator.canPop(innerContext)) {
                                        Navigator.pop(innerContext);
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

    debounce?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final currency = legacy.Provider.of<Providers>(
      context,
    ).snapshotmodel.currency;

    final formState = ref.watch(homeEquityFormProvider);
    final notifier = ref.read(homeEquityFormProvider.notifier);

    if (!_debtLoaded) {
      _debtLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.loadDebt(currency);
      });
    }

    final Orientation orientation = MediaQuery.of(context).orientation;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: const Icon(Icons.chevron_left, size: 28, color: Colors.black),
        ),
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNav(4),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: width * .06),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Home Equity',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        'assets/wheel_segments/home_equity_icon.png',
                        width: 24.w,
                        height: 24.h,
                      ),
                    ],
                  ),
                  Text(
                    "Complete the form to add this asset",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: height * .03),

                  const FormLabel('Is there mortgage on this property?'),
                  BottomSheetPickerField(
                    value: formState.mortgageProperty,
                    hint: '-Select',
                    items: HomeEquityFormNotifier.mortgagePropertyOptions,
                    onChanged: (value) =>
                        notifier.setMortgageProperty(value ?? '-Select-'),
                    title: 'Is there mortgage on this property',
                  ),
                  SizedBox(height: 20.h),
                  if (formState.mortgageProperty == 'Yes') ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 13.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Mortgage',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Image.asset(
                                'assets/wheel_segments/mortgage_infor.png',
                                width: 24.w,
                                height: 24.h,
                              ),
                            ],
                          ),
                          const FormLabel(
                            'Include your mortgage account since this asset has a mortgage.',
                          ),
                          SizedBox(height: 5.h),
                          const FormLabel('Who is the creditor?'),
                          TextInput(
                            hint: 'E.g. Barclays, Halifax',
                            value: formState.creditor,
                            onChanged: notifier.setCreditor,
                            expandable: true,
                            border: 16,
                          ),
                          SizedBox(height: 10.h),

                          const FormLabel('Description of Mortgage'),
                          BottomSheetPickerField(
                            darkColor: true,
                            value: formState.mortgageDescription,
                            hint: '-Select',
                            items: HomeEquityFormNotifier
                                .mortgageDescriptionOptions,
                            onChanged: (value) => notifier
                                .setMortgageDescription(value ?? '-Select-'),
                            title: 'Description of Mortgage',
                          ),
                          SizedBox(height: 10.h),

                          const FormLabel(
                            'What asset is this mortgage secured against?',
                          ),
                          BottomSheetPickerField(
                            darkColor: true,
                            value: formState.mortgageSecured,
                            hint: '-Select',
                            items:
                                HomeEquityFormNotifier.mortgageSecuredOptions,
                            onChanged: (value) => notifier.setMortgageSecured(
                              value ?? '-Select-',
                            ),
                            title:
                                'What asset is this mortgage secured against?',
                          ),
                          SizedBox(height: 10.h),

                          const FormLabel(
                            'What was the mortgage opening balance?',
                          ),
                          CurrencyInput(
                            border: 16,
                            value: formState.mortgageOpeningBalance,
                            onChanged: notifier.setMortgageOpeningBalance,
                          ),
                          SizedBox(height: 10.h),

                          const FormLabel(
                            'What is the current mortgage balance?',
                          ),
                          CurrencyInput(
                            border: 16,
                            value: formState.mortgageCurrentBalance,
                            onChanged: notifier.setMortgageCurrentBalance,
                          ),
                          SizedBox(height: 10.h),

                          const FormLabel(
                            'What is the monthly payment amount?',
                          ),
                          CurrencyInput(
                            border: 16,
                            value: formState.monthlyPayment,
                            onChanged: notifier.setMonthlyPayment,
                          ),
                          SizedBox(height: 10.h),

                          const FormLabel(
                            'What is the interest rate on this mortgage?',
                          ),
                          PercentageInput(
                            value: formState.mortgageInterestRate,
                            onChanged: notifier.setMortgageInterestRate,
                          ),
                          SizedBox(height: 10.h),

                          const FormLabel('Pay Off Strategy'),
                          TextInput(
                            hint: 'e.g £200/month overpayment',
                            value: formState.payOffStrategy,
                            onChanged: notifier.setPayOffStrategy,
                            expandable: true,
                            border: 16,
                          ),
                          SizedBox(height: 10.h),

                          const FormLabel('Payoff Target Date'),
                          TargetDate(
                            darkColor: true,
                            selectedDate: formState.targetDate,
                            isExpanded: formState.isTargetDateExpanded,
                            onToggle: notifier.toggleTargetDateExpanded,
                            onDateSelected: notifier.setCoverStart,
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 15.h),
                  const FormLabel('What country is this property located in?'),
                  InkWell(
                    borderRadius: BorderRadius.circular(14.r),
                    onTap: () => _openCountryPicker(notifier),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Row(
                        children: [
                          if (_findCountryByName(formState.country) !=
                              null) ...[
                            Text(
                              _findCountryByName(formState.country)!.flagEmoji,
                              style: GoogleFonts.nunitoSans(fontSize: 18.sp),
                            ),
                            SizedBox(width: 8.w),
                          ],
                          Expanded(
                            child: Text(
                              formState.country,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color:
                                    _findCountryByName(formState.country) ==
                                        null
                                    ? AppColors.grayColor
                                    : Colors.black,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.grayColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  const FormLabel('Home Address'),
                  InkWell(
                    borderRadius: BorderRadius.circular(14.r),
                    onTap: () => _openAddressSearch(notifier),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFffffff),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: const Color(0xFFD0D0D0),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/settings/search.png',
                            fit: BoxFit.contain,
                            width: 20.w,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              formState.homeAddress.isEmpty
                                  ? 'Enter a street address, postcode, e.t.c'
                                  : formState.homeAddress,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: formState.homeAddress.isEmpty
                                    ? AppColors.grayColor
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 15.h),
                  const FormLabel('Current market value of your home?'),
                  CurrencyInput(
                    value: formState.currentValue,
                    onChanged: notifier.setCurrentValue,
                  ),

                  SizedBox(height: 15.h),
                  const FormLabel('Date Acquired'),

                  TargetDate(
                    darkColor: true,
                    selectedDate: formState.dateAcquired,
                    isExpanded: formState.isTargetDateExpanded,
                    onToggle: notifier.toggleTargetDateExpanded,
                    onDateSelected: notifier.setDateAcquired,
                  ),
                  SizedBox(height: 40.h),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: formState.isSubmitting
                          ? null
                          : () async {
                              // Dismiss keyboard before any navigation/modal.
                              FocusScope.of(context).unfocus();

                              final result = await notifier.submit();
                              debugPrint(
                                'HomeEquity submit -> success: ${result.success}, '
                                'error: ${result.errorMessage}',
                              );

                              if (!context.mounted) return;

                              if (result.success) {
                                SuccessModalAssets.show(
                                  context: context,
                                  message: 'Equity added successfully!',
                                  onClose: () {},
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      result.errorMessage ??
                                          'Failed to save. Please try again.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: formState.isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Add Home Equity',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
