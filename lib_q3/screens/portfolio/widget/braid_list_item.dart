import 'dart:async';
import 'dart:convert';
import 'package:GapHub/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/screens/portfolio/braiditem.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BraidListItem extends StatelessWidget {
  final List<dynamic> existing;
  final String type;

  BraidListItem({required this.existing, required this.type});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Wrap ListView.builder in an Expanded to allow it to take available space
        Expanded(
          child: ListView.builder(
            itemCount: existing.length,
            itemBuilder: (context, i) {
              var parts = existing[i]["asset_currency"].toString().split(" ");
              var currency = parts[0];
              var assetValue = existing[i]["asset_value"];
              var monthlyROI = existing[i]["monthly_roi"];
              var createdAt = existing[i]["created_at"];
              var photo = existing[i]["photo_url"];

              return InkWell(
                onTap: () {
                  getDataItem(existing[i]["id"].toString(), context);
                },
                child: _buildCard(
                  context: context,
                  name: existing[i]["name"],
                  photo: photo,
                  assetValue: "$currency$assetValue",
                  monthlyROI: "$currency$monthlyROI",
                  createdAt: "$createdAt",
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Helper function to format numbers with commas
  String formatNumber(num value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  // Card widget builder
  Widget _buildCard({
    BuildContext? context,
    String? name,
    String? photo,
    String? assetValue,
    String? monthlyROI,
    String? createdAt,
  }) {
    Orientation orientation = MediaQuery.of(context!).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * .02,
              vertical: MediaQuery.of(context).size.height * .015,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                photo == imgPrefixAssets
                    ? CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xffE84141), Color(0xffFA7070)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            name![0], // First letter of the name
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors
                                  .white, // Text color must be white for the gradient to show
                            ),
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(photo!),
                        backgroundColor: Colors.grey[200],
                      ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${name![0].toUpperCase()}${name.substring(1)}',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * .04,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/timer_icon.png',
                            width: MediaQuery.of(context).size.width * .04,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formatDate(createdAt!),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.grayColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _indicatorText(
                      context: context,
                      amount: assetValue!,
                      color: Colors.green.shade200,
                      image: 'assets/images/green_arrow.png',
                    ),
                    // SizedBox(height: 8),
                    _indicatorText(
                      context: context,
                      amount: monthlyROI!,
                      color: Colors.blue.shade200,
                      image: 'assets/images/blue_arrow.png',
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
          const Divider(color: AppColors.grayColor2, height: 2, thickness: 1.0),
        ],
      ),
    );
  }

  // Indicator Text Widget
  Widget _indicatorText({
    BuildContext? context,
    String? amount,
    Color? color,
    String? image,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                formatAmount(amount!),
                style: TextStyle(
                  fontSize: MediaQuery.of(context!).size.width * .04,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Image.asset(image!, width: MediaQuery.of(context).size.width * .12),
      ],
    );
  }

  String formatAmount(String amount) {
    double? parsedAmount = double.tryParse(
      amount.replaceAll(RegExp(r'[^\d.]'), '').trim(),
    );

    if (parsedAmount == null) return 'Invalid amount';

    // Round to two decimal places
    String roundedAmount = parsedAmount.toStringAsFixed(2);

    // Apply comma formatting
    return roundedAmount.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String formatDate(String createdAt) {
    DateTime date = DateTime.parse(createdAt);
    DateTime now = DateTime.now();

    // Check if the date is today
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return "Today";
    }

    // Format as "07 Jul" if not today
    return DateFormat("dd MMM").format(date);
  }

  getDataItem(String id, BuildContext context) async {
    print("type:$type");
    print("id:$id");
    var _type = type.toLowerCase();
    Timer timer = Timer(const Duration(milliseconds: 20000), () {
      EasyLoading.dismiss();
      return;
    });
    EasyLoading.show(status: 'Loading', dismissOnTap: false);
    var url = Uri.parse("$baseUrl/app/portfolio/$_type/$id");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    var response = await http.get(
      url,
      headers: {"Authorization": 'Bearer $token'},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);
      // print("data:$data");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Braiditem(data: jsonDecode(response.body), type: _type, id: id),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: "Error");
    }
    timer.cancel();
    EasyLoading.dismiss();
  }
}
