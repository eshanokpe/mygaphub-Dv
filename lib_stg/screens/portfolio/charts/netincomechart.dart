import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:GapHub/utils/colors.dart'; // Assuming AppColors is defined here
import 'package:GapHub/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import fluttertoast if you use it for errors
import 'package:intl/intl.dart'; // Import for number formatting

class NetIncomeChart extends StatefulWidget {
  // final List<BarChartGroupData> showingBarGroups; // Not used directly, can be removed if not needed by parent
  final List names; // Month names for dropdown and potentially bottom axis
  final String id;
  final String type;
  // final String currency;
  final String imgPrefixAssets;
  final String imgurl;
  final Map data; // Initial data for "Last 6 Months"

  const NetIncomeChart({
    super.key, // Add Key
    // required this.showingBarGroups,
    required this.names,
    required this.id,
    required this.type,
    required this.data,
    // required this.currency,
    required this.imgurl,
    required this.imgPrefixAssets,
  }); // Pass key to super

  @override
  State<NetIncomeChart> createState() => _NetIncomeChartState();
}

class _NetIncomeChartState extends State<NetIncomeChart> {
  List assetValues = [];
  List<double> _numericAssetValues = []; // State variable for numeric values
  static const String last6Months = "Last 6 Months";
  String selectedMonth = last6Months;
  // int touchedIndex = 0; // Not directly used elsewhere, managed by selectedBarIndex
  List labels = []; // Labels for the bottom axis (e.g., 'Jan 24')
  List<String> selectedBarLabel =
      []; // Full labels corresponding to bars (used for lookup) - Might be redundant if 'labels' holds the same info
  String barLabel = ''; // Display label for the selected bar (e.g., 'Jan')
  int selectedBarIndex = -1; // Initialize to -1 (no selection)
  double selectedBarValue = 0;
  bool selectedIndex = false;
  bool _isLoading = false;

  // Number formatter for currency values
  final currencyFormatter = NumberFormat("#,##0", "en_US");

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Helper to safely get data and handle potential nulls/types
  List _getSafeList(Map data, List<String> path) {
    dynamic current = data;
    for (String key in path) {
      if (current is Map && current.containsKey(key) && current[key] != null) {
        current = current[key];
      } else {
        // print("Warning: Path $path not found or null in data.");
        return []; // Return empty list if path is invalid or value is null
      }
    }
    // Ensure the final result is a list
    return current is List ? current : [];
  }

  // Helper to convert raw asset values to numeric list
  List<double> _calculateNumericValues(List sourceList) {
    return sourceList.map((e) {
      if (e is num) {
        return e.toDouble();
      } else if (e is String) {
        // Try parsing if it's a string representation of a number
        return double.tryParse(e.replaceAll(',', '')) ?? 0.0; // Handle commas
      }
      return 0.0; // Default to 0.0 if not numeric or parsable string
    }).toList();
  }

  void _initializeData() {
    // Use the helper function for safer access
    final detailPath = ['data', 'asset_financial_detail'];
    labels = _getSafeList(widget.data, [...detailPath, 'expenditure_labels']);
    assetValues = _getSafeList(widget.data, [...detailPath, 'net']);
    _numericAssetValues = _calculateNumericValues(
      assetValues,
    ); // Initialize numeric values
    // Assuming 'labels' contains the full identifier needed for selection lookup
    selectedBarLabel = List<String>.from(
      labels.map((l) => l.toString()),
    ); // Ensure strings

    // print("Initial Labels: $labels");
    // print("Initial Asset Values: $assetValues");
    // print("Initial Numeric Values: $_numericAssetValues");
  }

  // Function to calculate maxY for the chart axis
  double getChartMaxY(double maxValue) {
    if (maxValue <= 0) return 10; // Handle zero or negative max value
    if (maxValue <= 100) return 100;
    if (maxValue <= 1000) return 1000;
    if (maxValue <= 10000) return 10000;
    if (maxValue <= 100000) return 100000;
    if (maxValue <= 1000000) return 1000000;
    if (maxValue <= 10000000) return 10000000;
    if (maxValue <= 100000000) return 100000000;
    // For very large values, add some padding (e.g., 10%)
    return (maxValue * 1.1).ceilToDouble();
  }

  // Function to format axis labels (K, M)
  String formatAxisValue(double value) {
    if (value >= 1000000) {
      // Show .1 only if not a whole million
      return "${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}M";
    } else if (value >= 1000) {
      // Show .1 only if not a whole thousand
      return "${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K";
    } else {
      return value.toStringAsFixed(0); // No decimals for values < 1000
    }
  }

  Future<void> fetchChartData(String month) async {
    // Use mounted check before setState if async operation might complete after dispose
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      selectedIndex = false; // Reset selection visual state
      selectedBarIndex = -1;
      barLabel = "";
      selectedBarValue = 0;
    });

    try {
      List newLabels = [];
      List newAssetValues = [];

      if (month == last6Months) {
        // Reset to initial data using the helper
        final detailPath = ['data', 'asset_financial_detail'];
        newLabels = _getSafeList(widget.data, [
          ...detailPath,
          'expenditure_labels',
        ]);
        newAssetValues = _getSafeList(widget.data, [...detailPath, 'net']);
      } else {
        // Fetch data for specific month
        final url =
            "$baseUrl/app/portfolio/${widget.type}/${widget.id}?month=$month";
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('tokenDB');

        if (token == null || token.isEmpty) {
          print('Error fetching chart data: Auth token missing');
          if (mounted) Fluttertoast.showToast(msg: "Authentication error.");
          // Keep loading false, data will be empty
          newLabels = [];
          newAssetValues = [];
        } else {
          final response = await http.get(
            Uri.parse(url),
            headers: {"Authorization": 'Bearer $token'},
          );

          if (response.statusCode == 200) {
            final responseData = json.decode(response.body);
            // Adjust paths based on actual API response structure for specific months
            final recordPath = ['data', 'asset_financial_record'];
            final detailPath = [
              'data',
              'asset_financial_detail',
            ]; // Or maybe recordPath? Check API response

            // Prefer data from 'asset_financial_record' if available for monthly view
            newLabels = _getSafeList(responseData, [
              ...recordPath,
              'expenditure_labels',
            ]);
            newAssetValues = _getSafeList(responseData, [
              ...recordPath,
              'net',
            ]); // Assuming 'net' is in record for monthly

            // Fallback if record path is empty/missing
            if (newLabels.isEmpty || newAssetValues.isEmpty) {
              newLabels = _getSafeList(responseData, [
                ...detailPath,
                'expenditure_labels',
              ]);
              newAssetValues = _getSafeList(responseData, [
                ...detailPath,
                'net',
              ]);
            }
          } else {
            print(
              'Failed to load chart data for $month: Status Code ${response.statusCode}',
            );
            if (mounted) {
              Fluttertoast.showToast(msg: "Failed to load data for $month");
            }
            newLabels = [];
            newAssetValues = [];
          }
        }
      }

      // Update state after getting data (or empty lists on failure)
      if (mounted) {
        setState(() {
          labels = newLabels;
          assetValues = newAssetValues;
          _numericAssetValues = _calculateNumericValues(assetValues);
          selectedBarLabel = List<String>.from(labels.map((l) => l.toString()));
        });
      }
    } catch (error) {
      print('Error fetching chart data: $error');
      if (mounted) Fluttertoast.showToast(msg: "An error occurred.");
      // Reset to empty state on error
      if (mounted) {
        setState(() {
          labels = [];
          assetValues = [];
          _numericAssetValues = [];
          selectedBarLabel = [];
        });
      }
    } finally {
      // Ensure loading indicator stops
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions safely
    final mediaQuery = MediaQuery.of(context);
    final orientation = mediaQuery.orientation;
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    // Use screen width for sizing in portrait, height in landscape (more consistent)
    final width = orientation == Orientation.portrait
        ? screenWidth
        : screenHeight;
    final height = orientation == Orientation.portrait
        ? screenHeight
        : screenWidth;

    // Get currency from provider
    String currency =
        context.watch<Providers>().snapshotmodel.currency ??
        ''; // Handle null currency

    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * .01),
      child: AspectRatio(
        // Adjusted aspect ratio slightly to give more height for the info box
        aspectRatio: 1.1,
        child: Card(
          elevation: 0,
          color: AppColors.cardColor, // Use theme color if possible
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(color: Color(0xffD8D8D8), width: 0.5),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Stretch header/chart horizontally
            children: [
              _buildHeader(width, height),
              Expanded(
                child: Padding(
                  // Add padding inside the expanded area for the chart
                  padding: EdgeInsets.only(
                    left: width * 0.02,
                    right: width * 0.04,
                    bottom: height * 0.01,
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : (_numericAssetValues.isEmpty) // Check numeric values
                      ? Center(
                          child: Text("No data available for $selectedMonth"),
                        )
                      : _buildBarChart(width, height),
                ),
              ),
              // Conditionally build the info box
              AnimatedSwitcher(
                // Add animation for appearance/disappearance
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SizeTransition(
                    // Animate size change
                    sizeFactor: animation,
                    axisAlignment: -1.0, // Align to top
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ), // Fade in/out
                  );
                },
                child: (selectedIndex && !_isLoading)
                    ? _buildSelectedBarInfo(width, height, currency)
                    : const SizedBox.shrink(), // Use SizedBox.shrink when hidden
              ),
              // Add a small bottom padding inside the card
              SizedBox(height: height * .01),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedBarInfo(double width, double height, String currency) {
    return Container(
      key: const ValueKey('selectedInfo'), // Key for AnimatedSwitcher
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ), // Adjusted padding
      margin: EdgeInsets.symmetric(
        horizontal: width * .03,
        vertical: 0,
      ), // Removed vertical margin
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // Slightly smaller radius
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        // Use spaceBetween for alignment
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Wrap left side (image + label) in Flexible to allow it to shrink/grow
          Flexible(
            child: Row(
              mainAxisSize:
                  MainAxisSize.min, // Row takes minimum required space
              children: [
                ClipOval(
                  child: widget.imgurl.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: widget.imgurl,
                          width: width * .07, // Slightly smaller image
                          height: width * .07,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: width * .07,
                            height: width * .07,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: width * .07,
                            height: width * .07,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: width * .04,
                            ),
                          ),
                        )
                      : Image.asset(
                          widget.imgPrefixAssets.isNotEmpty
                              ? widget.imgPrefixAssets
                              : 'assets/images/add_photo.jpg',
                          width: width * .07,
                          height: width * .07,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: width * .07,
                                height: width * .07,
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: width * .04,
                                ),
                              ),
                        ),
                ),
                const SizedBox(width: 8), // Slightly less space
                // Flexible for the text label to prevent overflow
                Flexible(
                  child: Text(
                    barLabel,
                    style: TextStyle(
                      fontSize: width * .038,
                      fontWeight: FontWeight.bold,
                    ), // Slightly smaller font
                    overflow: TextOverflow.ellipsis, // Handle long labels
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          // Value on the right - Use currencyFormatter
          Text(
            "$currency${currencyFormatter.format(selectedBarValue)}", // Use formatter
            style: TextStyle(
              fontSize: width * .038,
              fontWeight: FontWeight.w600,
            ), // Slightly smaller font
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double width, double height) {
    return Padding(
      padding: EdgeInsets.only(
        left: width * .04,
        right: width * .04,
        top: height * .015,
        bottom: height * 0.005,
      ), // Adjusted padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Use Flexible to prevent Dropdown from causing overflow if names are long
          Flexible(
            child: DropdownButton<String>(
              value: selectedMonth,
              onChanged: _isLoading
                  ? null
                  : (String? newValue) {
                      if (newValue != null && newValue != selectedMonth) {
                        // Update selectedMonth state immediately for feedback
                        setState(() {
                          selectedMonth = newValue;
                        });
                        // Fetch data for the new selection
                        fetchChartData(newValue);
                      }
                    },
              underline: const SizedBox.shrink(),
              isExpanded: false, // Don't expand dropdown button itself
              // Style dropdown items
              items: [
                DropdownMenuItem<String>(
                  value: last6Months,
                  child: Text(
                    last6Months,
                    style: TextStyle(
                      fontSize: width * .038,
                      fontWeight: FontWeight.w500,
                    ), // Slightly smaller font
                  ),
                ),
                ...(widget.names).map<DropdownMenuItem<String>>((dynamic name) {
                  final nameStr = name.toString();
                  return DropdownMenuItem<String>(
                    value: nameStr,
                    child: Text(
                      nameStr,
                      style: TextStyle(
                        fontSize: width * .038,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow
                          .ellipsis, // Handle long month names in dropdown
                    ),
                  );
                }),
              ],
            ),
          ),
          // Year text
          Text(
            '${DateTime.now().year}',
            style: TextStyle(
              fontSize: width * .038,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(double width, double height) {
    // Calculate maxY based on the current numeric values
    double maxNumericValue = _numericAssetValues.isNotEmpty
        ? _numericAssetValues.reduce((a, b) => a > b ? a : b)
        : 0.0;
    double maxY = getChartMaxY(maxNumericValue); // Use helper function

    return BarChart(
      BarChartData(
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              // Safely get month name from labels
              String monthName = labels.length > groupIndex
                  ? labels[groupIndex].toString().split(" ")[0]
                  : '';
              String value = formatAxisValue(rod.toY); // Use axis formatting
              return BarTooltipItem(
                '$monthName\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ), // Slightly smaller
                children: <TextSpan>[
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: Colors.yellow[600],
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ), // Adjusted style
                  ),
                ],
              );
            },
          ),
          touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
            if (!event.isInterestedForInteractions ||
                response == null ||
                response.spot == null) {
              // If touch ends outside a bar, reset selection
              if (event is FlPanEndEvent) {
                if (selectedIndex && mounted) {
                  // Check mounted before setState
                  setState(() {
                    selectedIndex = false;
                    selectedBarIndex = -1;
                    barLabel = "";
                    selectedBarValue = 0;
                  });
                }
              }
              return;
            }

            final touchedIndex = response.spot!.touchedBarGroupIndex;

            // Prevent updates if loading
            if (_isLoading || !mounted) return; // Check mounted

            setState(() {
              if (selectedIndex && selectedBarIndex == touchedIndex) {
                // Deselect if touching the same bar again (optional, current tooltip handles hover)
                // selectedIndex = false;
                // selectedBarIndex = -1;
                // barLabel = "";
                // selectedBarValue = 0;
              } else {
                // Select the new bar
                selectedIndex = true;
                selectedBarIndex = touchedIndex;
                // Safely access labels (use selectedBarLabel which is guaranteed string list)
                barLabel = selectedBarLabel.length > touchedIndex
                    ? selectedBarLabel[touchedIndex].split(" ")[0]
                    : '';
                // Safely access _numericAssetValues
                selectedBarValue = _numericAssetValues.length > touchedIndex
                    ? _numericAssetValues[touchedIndex]
                    : 0.0;
              }
            });
          },
        ),
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: maxY > 0 ? maxY / 5 : 1,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
          drawVerticalLine: false,
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45, // Adjust space
              interval: maxY > 0 ? maxY / 5 : 1,
              getTitlesWidget: (value, meta) {
                if (value == 0 && maxY > 0) {
                  return const SizedBox.shrink(); // Hide 0 label if not max
                }
                // Align text to the right of the axis line
                return Container(
                  width: 40, // Ensure consistent width for alignment
                  margin: const EdgeInsets.only(right: 5),
                  child: Text(
                    formatAxisValue(value), // Use formatting
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontSize: width * .026,
                    ), // Adjust size
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 25, // Adjust space
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                // Safely get month name from labels list
                String monthName = labels.length > index
                    ? labels[index].toString().split(" ")[0]
                    : '';
                return Padding(
                  padding: const EdgeInsets.only(top: 5.0), // Add padding
                  child: Text(
                    monthName.length >= 3
                        ? monthName.substring(0, 3).toUpperCase()
                        : monthName,
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontSize: width * .026,
                    ), // Adjust size
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
            left: const BorderSide(color: Colors.transparent),
            right: const BorderSide(color: Colors.transparent),
            top: const BorderSide(color: Colors.transparent),
          ),
        ),
        barGroups: List.generate(
          _numericAssetValues.length, // Generate based on numeric data length
          (index) {
            final isSelected = selectedIndex && selectedBarIndex == index;
            // Define gradients for default and selected states
            const defaultGradient = LinearGradient(
              colors: [Color(0xff005E77), Color(0xff002E77)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            );
            const selectedGradient = LinearGradient(
              colors: [Color(0xff002E77), Color(0xff005E77)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            );

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: _numericAssetValues[index], // Use numeric value
                  gradient: isSelected ? selectedGradient : defaultGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  width: width * .04,
                  // Optional: Add border to selected bar
                  borderSide: isSelected
                      ? const BorderSide(color: Colors.black54, width: 0.5)
                      : null,
                ),
              ],
            );
          },
        ),
      ),
      // Optional: Add animation
      // swapAnimationDuration: const Duration(milliseconds: 250),
      // swapAnimationCurve: Curves.linear,
    );
  }
}

// Keep the Indicators class as it is, or update its formatting if needed
class Indicators extends StatelessWidget {
  const Indicators({
    super.key,
    required this.color,
    required this.month,
    required this.values,
    required this.currency,
  });

  final int color;
  final String month;
  final String currency;
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    // Use NumberFormat for consistency if available
    final currencyFormatter = NumberFormat("#,##0.00", "en_US");

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * .005,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: width * .03,
                width: width * .03,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(color),
                ),
              ),
              SizedBox(width: width * .01),
              Text(
                month, // Already a string
                style: TextStyle(fontSize: width * .04),
              ),
            ],
          ),
          SizedBox(width: width * .01),
          Expanded(
            child: Wrap(
              spacing: width * .02,
              runSpacing: 4.0,
              alignment: WrapAlignment.end,
              children: values.isNotEmpty
                  ? values.map((value) {
                      return Text(
                        '$currency${currencyFormatter.format(value)}', // Use formatter
                        style: TextStyle(
                          fontSize: width * .035,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }).toList()
                  : [
                      Text(
                        '${currency}0.00', // Show 0.00 if empty
                        style: TextStyle(
                          fontSize: width * .035, // Match font size
                          fontWeight: FontWeight.w700, // Match weight
                          color: Color(color), // Use provided color
                        ),
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}
