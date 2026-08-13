import 'dart:convert';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CurrencyPickerSheet extends StatefulWidget {
  final String? selectedSymbol;
  final Function(String fullDisplay, String symbolOnly, String displayCurrency)
  onCurrencySelected;

  const CurrencyPickerSheet({
    super.key,
    required this.selectedSymbol,
    required this.onCurrencySelected,
  });

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allCurrencies = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrencies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      final response = await http.get(
        Uri.parse("$baseUrl/app/exchange"),
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final popularCurrencies = body['data']['popular_currencies'] as List?;

        if (popularCurrencies != null && popularCurrencies.isNotEmpty) {
          final processed = popularCurrencies.map((currency) {
            return {
              'currency': currency['currency'],
              'symbol': currency['currency']?.toString().split(' ').first ?? '',
              'name': currency['country']?.toString() ?? 'Unknown Currency',
            };
          }).toList();

          if (mounted) {
            setState(() {
              _allCurrencies = processed;
              _filtered = List.from(_allCurrencies);
              _isLoading = false;
            });
          }
        } else {
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Failed to load currencies. Please try again.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Something went wrong. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _allCurrencies.where((c) {
        return c['name'].toString().toLowerCase().contains(query) ||
            c['currency'].toString().toLowerCase().contains(query) ||
            c['symbol'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.90,
      child: DraggableScrollableSheet(
        expand: true,
        initialChildSize: 1.0,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (_, scrollController) {
          return Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45.w,
                    height: 4.h,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: const TextStyle(color: Colors.black38),
                          // prefixIcon: const Icon(Icons.search, color: Colors.black45),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                              width: 35.w, // Total width (icon + padding)
                              height: 35.h,
                              child: Center(
                                child: Image.asset(
                                  'assets/settings/search.png',
                                  width: 15.w,
                                  height: 15.h,
                                  fit: BoxFit.contain,
                                  color: Colors.black45,
                                ),
                              ),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 30, // ⬅️ Reduce this
                            minHeight: 30,
                            maxWidth: 60, // ⬅️ Add this
                            maxHeight: 60,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFDDDDDD),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 0.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.close, color: Colors.black),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFE53935),
                          ),
                        )
                      : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _error!,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12.h),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLoading = true;
                                    _error = null;
                                  });
                                  _loadCurrencies();
                                },
                                child: const Text(
                                  'Retry',
                                  style: TextStyle(color: Color(0xFFE53935)),
                                ),
                              ),
                            ],
                          ),
                        )
                      : _filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No currencies found.',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black45,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: _filtered.length,
                          itemBuilder: (_, index) {
                            final currencyExchange = _filtered[index];
                            final currency = currencyExchange['currency'] ?? '';
                            final symbol = currencyExchange['symbol'] ?? '';
                            final name = currencyExchange['name'] ?? '';
                            final fullDisplay = "$symbol $name";
                            final displayCurrency = currency;
                            final isSelected = widget.selectedSymbol == symbol;

                            return Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  onTap: () {
                                    widget.onCurrencySelected(
                                      fullDisplay,
                                      symbol,
                                      displayCurrency,
                                    );
                                  },
                                  leading: Container(
                                    width: 30.w,
                                    height: 30.h,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF03222F),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        symbol,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: Color(0xFFE53935),
                                          size: 18,
                                        )
                                      : null,
                                ),
                                if (index != _filtered.length - 1)
                                  const Divider(
                                    height: 1,
                                    thickness: 0.5,
                                    color: AppColors.dividerColor,
                                  ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
