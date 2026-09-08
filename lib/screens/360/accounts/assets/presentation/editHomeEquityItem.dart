import 'dart:async';
import 'dart:convert';

import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/customBottomSheet.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart' as legacy;
import '../../../widget/percentageInput.dart';
import '../../../widget/textInput.dart';
import '../../protection/addProtection/widget/coverStartField.dart';
import '../../retirement/presentation/widget/currencyInput.dart';
import '../provider/equity_provider.dart';
import '../provider/home_equity_form_provider.dart';
import '../widget/bottomSheetPickerField.dart';
import '../../../widget/formLabel.dart';
import '../widget/delete_popup.dart';
import '../widget/successModalAssets.dart';
import '../widget/targetDate.dart';
import '../widget/targetDateFuture.dart';

class EditHomeEquityItem extends ConsumerStatefulWidget {
  final Map<String, dynamic> item;

  const EditHomeEquityItem({super.key, required this.item});

  @override
  ConsumerState<EditHomeEquityItem> createState() => _EditHomeEquityItemState();
}

class _EditHomeEquityItemState extends ConsumerState<EditHomeEquityItem> {
  bool _debtLoaded = false;
  late List<Country> _allCountries;

  bool _showManualAddress = false;

  @override
  @override
  void initState() {
    super.initState();
    final allowedCodes = {'GB', 'US', 'CA', 'ZA'};
    _allCountries = CountryService()
        .getAll()
        .where((c) => allowedCodes.contains(c.countryCode))
        .toList();

    // Pre-fill the form with existing data, then load debt — both deferred
    // until after the first frame so we never mutate provider state mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(homeEquityFormProvider.notifier).initializeFromMap(widget.item);

      final currency = legacy.Provider.of<Providers>(
        context,
        listen: false,
      ).snapshotmodel.currency;
      ref.read(homeEquityFormProvider.notifier).loadDebt(currency);
    });
  }

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

  Future<void> _openAddressSearch(
    HomeEquityFormNotifier notifier,
    String selectedCountry,
  ) async {
    List<Map<String, String>> predictions = [];
    bool isLoading = false;
    Timer? debounce;
    final TextEditingController searchController = TextEditingController();
    final countryCode = _findCountryByName(
      selectedCountry,
    )?.countryCode.toLowerCase();
    final countryFilter = countryCode == null || countryCode.isEmpty
        ? 'country:gb|country:us|country:ca|country:za'
        : 'country:$countryCode';

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
            'components': countryFilter,
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
                                    SizedBox(height: 20.h),
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
                                      notifier.setAddress(description);
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

  @override
  Widget build(BuildContext context) {
    final currency = legacy.Provider.of<Providers>(
      context,
    ).snapshotmodel.currency;
    final formState = ref.watch(homeEquityFormProvider);
    final notifier = ref.read(homeEquityFormProvider.notifier);

    if (!_debtLoaded) {
      _debtLoaded = true;
      notifier.loadDebt(currency);
    }

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
        title: Text(
          'Edit Home Equity',
          style: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(4),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
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
                const FormLabel('Edit etails of your home equity'),

                SizedBox(height: 20.h),

                // --- Reuse the exact same form fields from AddHomeEquity here ---
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
                            SizedBox(
                              width: 30.w,
                              height: 30.h,
                              child: InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(56.0),
                                        topRight: Radius.circular(56.0),
                                      ),
                                    ),
                                    builder: (BuildContext context) {
                                      return const CustomBottomSheet(
                                        title: "Mortgage",
                                        content:
                                            "Here is an aggregation of all your debt that are secure against properties",
                                      );
                                    },
                                  );
                                },
                                child: Image.asset(
                                  'assets/wheel_segments/mortgage_infor.png',
                                  width: 24.w,
                                  height: 24.h,
                                ),
                              ),
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
                          items:
                              HomeEquityFormNotifier.mortgageDescriptionOptions,
                          onChanged: (value) => notifier.setMortgageDescription(
                            value ?? '-Select-',
                          ),
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
                          items: HomeEquityFormNotifier.mortgageSecuredOptions,
                          onChanged: (value) =>
                              notifier.setMortgageSecured(value ?? '-Select-'),
                          title: 'What asset is this mortgage secured against?',
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

                        const FormLabel('What is the monthly payment amount?'),
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
                        TargetDateFuture(
                          darkColor: true,
                          allowFuture: true,
                          selectedDate: formState.targetDate,
                          isExpanded: formState.isTargetDateExpanded,
                          onToggle: notifier.toggleTargetDateExpanded,
                          onDateSelected: notifier.setCoverStart,
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 0.h),
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
                        if (_findCountryByName(formState.country) != null) ...[
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
                                  _findCountryByName(formState.country) == null
                                  ? AppColors.grayColor
                                  : Colors.black,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black87,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const FormLabel('Home Address'),
                    InkWell(
                      onTap: () =>
                          _openAddressSearch(notifier, formState.country),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Text(
                              'Search ',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            Image.asset(
                              'assets/settings/search.png',
                              color: AppColors.primaryColor,
                              width: 12.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                formState.homeAddress.isNotEmpty
                    ? Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: !_showManualAddress
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(formState.homeAddress),
                                  Text(formState.townCity),
                                  Text(formState.zipcode),
                                  SizedBox(height: 20.h),
                                  SizedBox(
                                    width: 60.w,
                                    height: 20.h,
                                    child: InkWell(
                                      onTap: () {
                                        setState(
                                          () => _showManualAddress = true,
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            'Edit ',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Icon(
                                            weight: 20,
                                            Icons.arrow_forward_ios,
                                            color: AppColors.primaryColor,
                                            size: 10.sp,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const FormLabel('Address line 1'),
                                  TextInput(
                                    hint: 'Street and house number',
                                    value: formState.address,
                                    onChanged: notifier.setAddress,
                                    expandable: true,
                                    border: 16.sp,
                                  ),
                                  SizedBox(height: 10.h),
                                  const FormLabel('Address line 2'),
                                  TextInput(
                                    hint: 'Flat, buidling, or unit',
                                    value: formState.address2,
                                    onChanged: notifier.setAddress2,
                                    expandable: true,
                                    border: 16.sp,
                                  ),
                                  SizedBox(height: 10.h),
                                  const FormLabel('Town/City?'),
                                  TextInput(
                                    hint: 'Enter town or city',
                                    value: formState.townCity,
                                    onChanged: notifier.setTownCity,
                                    expandable: true,
                                    border: 16.sp,
                                  ),
                                  SizedBox(height: 10.h),
                                  const FormLabel('Postcode?'),
                                  TextInput(
                                    hint: 'e.g L1 8JQ',
                                    value: formState.zipcode,
                                    onChanged: notifier.setZipcode,
                                    expandable: true,
                                    border: 16,
                                  ),
                                ],
                              ),
                      )
                    : InkWell(
                        borderRadius: BorderRadius.circular(14.r),
                        onTap: () =>
                            _openAddressSearch(notifier, formState.country),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xfffffffff),
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

                SizedBox(height: 20.h),
                const FormLabel('Current market value of your home?'),
                CurrencyInput(
                  value: formState.currentValue,
                  onChanged: notifier.setCurrentValue,
                ),

                SizedBox(height: 20.h),
                const FormLabel('Date Acquired'),
                CoverStartField(
                  downArrow: true,
                  selectedDate:
                      formState.dateAcquired, // ✅ FIXED: Uses dateAcquired now
                  isExpanded: formState.isDateAcquiredExpanded, // ✅ FIXED
                  onToggle: notifier.toggleDateAcquiredExpanded, // ✅ FIXED
                  onDateSelected: notifier.setDateAcquired, // ✅ FIXED
                ),

                SizedBox(height: 40.h),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54.h,
                        child: OutlinedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(56.0),
                                  topRight: Radius.circular(56.0),
                                ),
                              ),
                              builder: (sheetContext) => DeletePopup(
                                title: "Delete this assets?",
                                onConfirm: () async {
                                  final result = await notifier.delete(
                                    widget.item['id'].toString(),
                                  );
                                  if (!mounted) return;

                                  if (result.success) {
                                    Navigator.of(sheetContext).pop();
                                    Navigator.of(context).maybePop();
                                    Navigator.of(context).maybePop();
                                    Navigator.of(context).maybePop();
                                    await ref
                                        .read(equityProvider.notifier)
                                        .refreshEquity();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          result.errorMessage ??
                                              'Failed to delete. Please try again.',
                                        ),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryColor,
                            side: const BorderSide(
                              color: AppColors.grayColor2,
                              width: 1.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                          ),
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: SizedBox(
                        height: 54.h,
                        child: ElevatedButton(
                          onPressed: formState.isSubmitting
                              ? null
                              : () async {
                                  FocusScope.of(context).unfocus();

                                  final result = await notifier.update(
                                    widget.item['id'].toString(),
                                  );

                                  if (!context.mounted) return;

                                  if (result.success) {
                                    SuccessModalAssets.show(
                                      context: context,
                                      message: 'Equity updated successfully!',
                                      onClose: () {},
                                      control: 'editor',
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          result.errorMessage ??
                                              'Failed to update. Please try again.',
                                        ),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            elevation: 0,
                          ),
                          child: formState.isSubmitting
                              ? SizedBox(
                                  width: 24.w,
                                  height: 24.h,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Save',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
