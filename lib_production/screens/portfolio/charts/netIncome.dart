import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NetIncomeChart extends StatefulWidget {
  final List<BarChartGroupData> showingBarGroups;
  final List names;
  final String id;
  final String type;
  final String currency;
  final String imgPrefixAssets;
  final String imgurl;
  final Map data;

  const NetIncomeChart({
    super.key,
    required this.showingBarGroups,
    required this.names,
    required this.id,
    required this.type,
    required this.data,
    required this.currency,
    required this.imgurl,
    required this.imgPrefixAssets,
  });

  @override
  State<NetIncomeChart> createState() => _NetIncomeChartState();
}

class _NetIncomeChartState extends State<NetIncomeChart> {
  List assetValues = [];
  // Use a constant for the default selection
  static const String last6Months = "Last 6 Months";
  String selectedMonth = last6Months; // Initialize with the constant
  int touchedIndex = 0;
  List labels = [];
  // List labelAsset = []; // This variable doesn't seem to be used, consider removing
  // List chartData = []; // This variable doesn't seem to be used directly for building the chart, consider removing if not needed elsewhere
  List<double> values = [];
  // List<String> month = []; // This variable doesn't seem to be used, consider removing
  List<String> selectedBarLabel = [];
  String barLabel = '';
  int selectedBarIndex = 0;
  double selectedBarValue = 0;
  bool selectedIndex = false;
  bool _isLoading = false; // Add a loading state

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Helper to safely get data and handle potential nulls
  List _getSafeList(Map data, List<String> path) {
    dynamic current = data;
    for (String key in path) {
      if (current is Map && current.containsKey(key) && current[key] != null) {
        current = current[key];
      } else {
        return []; // Return empty list if path is invalid or value is null
      }
    }
    return current is List ? current : [];
  }

  void _initializeData() {
    // Use the helper function for safer access
    final detailPath = ['data', 'asset_financial_detail'];
    labels = _getSafeList(widget.data, [...detailPath, 'expenditure_labels']);
    assetValues = _getSafeList(widget.data, [...detailPath, 'net']);
    // Ensure selectedBarLabel is initialized safely
    selectedBarLabel = List<String>.from(labels);

    // Optional: Print initial data for debugging
    // print("Initial Labels: $labels");
    // print("Initial Asset Values: $assetValues");
    // print("Initial Selected Bar Label: $selectedBarLabel");
  }

  double getBigNumValue(double maxValue) {
    // Consider simplifying this logic or using a loop/map if ranges follow a pattern
    if (maxValue <= 0) return 10; // Handle zero or negative max value
    if (maxValue <= 100) return 100;
    if (maxValue <= 1000) return 1000;
    if (maxValue <= 10000) return 10000;
    if (maxValue <= 100000) return 100000;
    if (maxValue <= 1000000) return 1000000;
    if (maxValue <= 10000000) return 10000000;
    if (maxValue <= 100000000) return 100000000;
    return maxValue * 1.1; // Add some padding for values > 100M
  }

  Future<void> fetchChartData(String month) async {
    setState(() {
      _isLoading = true; // Start loading indicator
      selectedIndex = false; // Reset selection when data changes
      selectedBarIndex = -1;
      barLabel = "";
      selectedBarValue = 0;
    });

    try {
      if (month == last6Months) {
        // Reset to initial data using the helper
        final detailPath = ['data', 'asset_financial_detail'];
        setState(() {
          labels = _getSafeList(widget.data, [
            ...detailPath,
            'expenditure_labels',
          ]);
          assetValues = _getSafeList(widget.data, [...detailPath, 'net']);
          selectedBarLabel = List<String>.from(
            labels,
          ); // Reset based on new labels
        });
        return; // Exit after resetting state
      }

      // Fetch data for specific month
      final url =
          "$baseUrl/app/portfolio/${widget.type}/${widget.id}?month=$month";
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      // Add token check
      if (token == null || token.isEmpty) {
        print('Error fetching chart data: Auth token missing');
        // Optionally show a toast message to the user
        // Fluttertoast.showToast(msg: "Authentication error. Please log in again.");
        setState(() => _isLoading = false); // Stop loading
        return;
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Use helper for safer access to potentially different structure
        // Adjust paths if the structure for specific months is different
        final recordPath = [
          'data',
          'asset_financial_record',
        ]; // Example path, adjust if needed
        final detailPath = [
          'data',
          'asset_financial_detail',
        ]; // Example path, adjust if needed

        setState(() {
          // Update state with fetched data
          labels = _getSafeList(responseData, [
            ...recordPath,
            'expenditure_labels',
          ]);
          assetValues = _getSafeList(responseData, [...detailPath, 'net']);
          selectedBarLabel = List<String>.from(
            labels,
          ); // Update based on new labels
        });
      } else {
        print('Failed to load chart data: Status Code ${response.statusCode}');
        // Optionally show a toast message
        // Fluttertoast.showToast(msg: "Failed to load chart data for $month");
        // Consider resetting to a default/empty state or showing an error message in the chart area
        setState(() {
          labels = [];
          assetValues = [];
          selectedBarLabel = [];
        });
      }
    } catch (error) {
      print('Error fetching chart data: $error');
      // Optionally show a toast message
      // Fluttertoast.showToast(msg: "An error occurred while fetching data.");
      setState(() {
        // Reset to empty state on error
        labels = [];
        assetValues = [];
        selectedBarLabel = [];
      });
    } finally {
      setState(() {
        _isLoading = false; // Stop loading indicator regardless of outcome
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    String currency = context.watch<Providers>().snapshotmodel.currency;

    // No need for FutureBuilder here if imgurl is passed directly
    // Future<String> getImg() async {
    //   return widget.imgurl;
    // }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * .01),
      child: AspectRatio(
        aspectRatio:
            1.0, // Consider making this slightly wider if needed (e.g., 1.2)
        child: Card(
          elevation: 0,
          color: AppColors.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(color: Color(0xffD8D8D8), width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.start, // Default
            // mainAxisSize: MainAxisSize.max, // Default for Column
            children: [
              _buildHeader(width, height),
              Expanded(
                // Show loading indicator or chart
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (labels.isEmpty ||
                          assetValues.isEmpty) // Check if data is empty
                    ? Center(
                        child: Text("No data available for $selectedMonth"),
                      )
                    : _buildBarChart(width, height),
              ),
              SizedBox(height: height * .01),
              // Show selected bar info only if an item is selected and not loading
              if (selectedIndex && !_isLoading)
                _buildSelectedBarInfo(
                  width,
                  height,
                  currency,
                ), // Extracted to a method
              SizedBox(height: height * .01),
            ],
          ),
        ),
      ),
    );
  }

  // Extracted method for building the selected bar info container
  Widget _buildSelectedBarInfo(double width, double height, String currency) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(
        horizontal: width * .03,
        vertical: height * .01,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          // Optional: Add subtle shadow
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            // Left side: Image and Label
            children: [
              // Use ClipOval for circular image clipping
              ClipOval(
                child:
                    widget.imgurl.startsWith(
                      'http',
                    ) // Basic check for network URL
                    ? CachedNetworkImage(
                        imageUrl: widget.imgurl,
                        width: width * .08,
                        height: width * .08,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          // Simple placeholder
                          width: width * .08,
                          height: width * .08,
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          // Simple error placeholder
                          width: width * .08,
                          height: width * .08,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: width * .05,
                          ),
                        ),
                      )
                    : Image.asset(
                        // Assuming local asset otherwise
                        widget.imgPrefixAssets.isNotEmpty
                            ? widget.imgPrefixAssets
                            : 'assets/images/add_photo.jpg', // Use prefix or default
                        width: width * .08,
                        height: width * .08,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          // Handle asset error
                          width: width * .08,
                          height: width * .08,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: width * .05,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Flexible(
                // Allow text to wrap if needed
                child: Text(
                  barLabel, // Already extracted month name
                  style: TextStyle(
                    fontSize: width * .04,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis, // Prevent overflow
                ),
              ),
            ],
          ),
          // Right side: Formatted Value
          Text(
            // Use NumberFormat for better currency formatting if available (add intl package)
            // Otherwise, keep the regex method
            "$currency${selectedBarValue.toStringAsFixed(0)}".replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            ),
            style: TextStyle(
              fontSize: width * .04,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double width, double height) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * .04,
        vertical: height * .01,
      ), // Reduced vertical padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dropdown wrapped for better layout control if needed
          Flexible(
            child: DropdownButton<String>(
              value: selectedMonth,
              // Prevent changing selection while loading
              onChanged: _isLoading
                  ? null
                  : (String? newValue) {
                      if (newValue != null && newValue != selectedMonth) {
                        // Update state and fetch data
                        // No need for setState here, fetchChartData handles it
                        fetchChartData(newValue);
                        // Update selectedMonth immediately for visual feedback
                        setState(() {
                          selectedMonth = newValue;
                        });
                      }
                    },
              underline:
                  const SizedBox.shrink(), // Removes the default underline
              isExpanded: false, // Let the dropdown size itself
              // Style the dropdown items
              items: [
                DropdownMenuItem<String>(
                  value: last6Months, // Use constant
                  child: Text(
                    last6Months, // Use constant
                    style: TextStyle(
                      fontSize: width * .04,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Ensure widget.names is a List<String> or cast safely
                ...(widget.names).map<DropdownMenuItem<String>>((dynamic name) {
                  // Ensure name is a string
                  final nameStr = name.toString();
                  return DropdownMenuItem<String>(
                    value: nameStr,
                    child: Text(
                      nameStr,
                      style: TextStyle(
                        fontSize: width * .04,
                        fontWeight: FontWeight.w500,
                        color: Colors.black, // Ensure text color is visible
                      ),
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
              fontSize: width * .04,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(double width, double height) {
    // Handle cases where assetValues might be empty or contain non-numeric data
    final numericValues = assetValues
        .map(
          (e) => e is num ? e.toDouble() : 0.0,
        ) // Convert to double, default to 0.0 if not numeric
        .toList();

    // Calculate maxY only if numericValues is not empty
    double maxYValue = numericValues.isNotEmpty
        ? numericValues.reduce((a, b) => a > b ? a : b)
        : 0.0; // Default maxY if list is empty

    // Ensure maxY is at least a small positive number for the chart to render
    double maxY = getBigNumValue(maxYValue);
    if (maxY <= 0) maxY = 10; // Ensure chart has some height

    return Padding(
      // Add padding around the chart
      padding: EdgeInsets.only(
        right: width * 0.04,
        left: width * 0.01,
        bottom: height * 0.01,
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barTouchData: BarTouchData(
            // Enable touch interactions
            enabled: true, // Set to true to allow touches
            // Use touchTooltipData for default tooltips or touchCallback for custom behavior
            touchTooltipData: BarTouchTooltipData(
              // tooltipBgColor: Colors.blueGrey,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                // Customize tooltip text here if needed
                String monthName = labels.length > groupIndex
                    ? labels[groupIndex].toString().split(" ")[0]
                    : '';
                String value = formatValue(
                  rod.toY,
                ); // Use your formatValue function
                return BarTooltipItem(
                  '$monthName\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: value,
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
            touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
              // This callback is still useful for custom actions on touch, like updating the selectedBarInfo
              if (!event.isInterestedForInteractions ||
                  response == null ||
                  response.spot == null) {
                // If not interacting or no spot, potentially reset selection if needed
                // setState(() {
                //   if (selectedIndex) selectedIndex = false; // Reset if touched outside bars
                // });
                return;
              }
              final touchedIndex = response.spot!.touchedBarGroupIndex;

              // Prevent updates if loading
              if (_isLoading) return;

              setState(() {
                if (selectedIndex && selectedBarIndex == touchedIndex) {
                  // Deselect if touching the same bar again
                  selectedIndex = false;
                  selectedBarIndex = -1;
                  barLabel = "";
                  selectedBarValue = 0;
                } else {
                  // Select the new bar
                  selectedIndex = true;
                  selectedBarIndex = touchedIndex;
                  // Safely access labels
                  barLabel = labels.length > touchedIndex
                      ? labels[touchedIndex].toString().split(" ")[0]
                      : '';
                  // Safely access assetValues
                  selectedBarValue = numericValues.length > touchedIndex
                      ? numericValues[touchedIndex]
                      : 0.0;
                }
              });
            },
          ),
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            // Customize grid lines
            show: true,
            drawHorizontalLine: true, // Show horizontal lines
            horizontalInterval: maxY > 0
                ? maxY / 5
                : 1, // Match left axis intervals
            getDrawingHorizontalLine: (value) {
              // Style horizontal lines
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
            drawVerticalLine: false, // Hide vertical lines
          ),
          titlesData: FlTitlesData(
            // Left Axis Titles (Values)
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50, // Adjust space for labels
                interval: maxY > 0 ? maxY / 5 : 1,
                getTitlesWidget: (value, meta) {
                  // Don't show title for 0 unless maxY is also 0
                  if (value == 0 && maxY > 0) return Container();
                  return Padding(
                    padding: const EdgeInsets.only(
                      right: 8.0,
                    ), // Add padding to avoid overlap
                    child: Text(
                      formatValue(value), // Use formatting function
                      style: TextStyle(
                        color: Colors.black54, // Softer color
                        fontWeight: FontWeight.w500, // Slightly bolder
                        fontSize: width * .028, // Adjust size
                      ),
                      textAlign: TextAlign.right, // Align text to the right
                    ),
                  );
                },
              ),
            ),
            // Right, Top Axis Titles (Hidden)
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            // Bottom Axis Titles (Months)
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30, // Space for bottom labels
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  // Safely get month name from labels list
                  String monthName = labels.length > index
                      ? labels[index].toString().split(" ")[0]
                      : '';
                  return Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                    ), // Add padding above text
                    child: Text(
                      // Show first 3 chars, uppercase
                      monthName.length >= 3
                          ? monthName.substring(0, 3).toUpperCase()
                          : monthName,
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontSize: width * .028,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Border styling
          borderData: FlBorderData(
            show: true,
            border: Border(
              // Only show bottom border
              bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
              left: const BorderSide(color: Colors.transparent),
              right: const BorderSide(color: Colors.transparent),
              top: const BorderSide(color: Colors.transparent),
            ),
          ),
          // Bar Groups Data
          barGroups: List.generate(
            labels.length, // Generate based on the number of labels
            (index) {
              // Determine color based on selection state
              final isSelected = selectedIndex && selectedBarIndex == index;
              final barColor = isSelected
                  ? const Color(0xff005E77)
                  : const Color(0xff005E77); // Highlight selected bar
              final gradient = LinearGradient(
                // Define gradient
                colors: isSelected
                    // ? [Colors.orangeAccent, Colors.deepOrange]
                    ? [const Color(0xff005E77), const Color(0xff002E77)]
                    : [
                        const Color(0xff005E77),
                        const Color(0xff002E77),
                      ], // Default gradient
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              );

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    // Safely access numericValues
                    toY: numericValues.length > index
                        ? numericValues[index]
                        : 0.0,
                    gradient: gradient, // Apply gradient
                    // color: barColor, // Use gradient instead of single color
                    borderRadius: const BorderRadius.only(
                      // Rounded top corners
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                    width: width * .04, // Bar width
                    // Optional: Add back borders if desired
                    // borderSide: isSelected ? BorderSide(color: Colors.black, width: 1) : null,
                  ),
                ],
                // Optional: Show values on top of bars
                // showingTooltipIndicators: isSelected ? [0] : [],
              );
            },
          ),
        ),
        // Optional: Add animation
        // swapAnimationDuration: Duration(milliseconds: 250),
        // swapAnimationCurve: Curves.linear,
      ),
    );
  }

  // Keep your existing formatValue function
  String formatValue(double value) {
    if (value >= 1000000) {
      return "${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}M"; // Show .1 only if needed
    } else if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K"; // Show .1 only if needed
    } else {
      return value.toStringAsFixed(0); // No decimals for values < 1000
    }
  }
}

// Keep the Indicators class as it was, it doesn't seem directly related to the issue
class Indicators extends StatelessWidget {
  // ... (rest of the Indicators class code remains the same) ...
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
              Text(month, style: TextStyle(fontSize: width * .04)),
            ],
          ),
          SizedBox(width: width * .01),
          Expanded(
            child: Wrap(
              spacing: width * .02, // Adjust the spacing between items
              runSpacing: 4.0, // Adjust the spacing between lines
              alignment: WrapAlignment.end,
              children: values.isNotEmpty
                  ? values.map((value) {
                      // Format value with commas and precision
                      final formattedValue = value
                          .toStringAsFixed(2)
                          .replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          );
                      return Text(
                        '$currency$formattedValue',
                        style: TextStyle(
                          fontSize: width * .035,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }).toList()
                  : [
                      // Show 0.00 if values list is empty
                      Text(
                        '${currency}0.00',
                        style: TextStyle(
                          fontSize: width * .04,
                          color: Color(color), // Use provided color
                          fontWeight: FontWeight.w700, // Match style
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
