import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import 'package:GapHub/models/ganpserver.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/acquisition/ganp/ganp.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/widgets/avatarImage.dart';
import 'package:GapHub/widgets/bottomnav.dart';

import 'opportunities/appreciatingAssetUI.dart';
import 'opportunities/businessAssetUI.dart';
import 'opportunities/riskAssetUI.dart';

class Opportunities extends StatefulWidget {
  final int value;

  const Opportunities({super.key, required this.value});

  @override
  _OpportunitiesState createState() => _OpportunitiesState();
}

class _OpportunitiesState extends State<Opportunities> {
  final Map<int, String> assetTypes = {
    0: 'Business Asset',
    1: 'Appreciating Asset',
    2: 'Risk Asset',
  };

  final DialogBox dialogBox = DialogBox();
  final Dio dio = Dio();
  late String selectedAsset;

  @override
  void initState() {
    super.initState();
    // Initialize selectedAsset based on the passed value
    selectedAsset = assetTypes[widget.value] ?? 'Appreciating Asset';
    print("selectedAsset:$selectedAsset");
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isPortrait = orientation == Orientation.portrait;
    final double height = isPortrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final double width = isPortrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
          actions: const [AvatarImage()],
        ),
        // backgroundColor: const Color(0XFFF6F6F6),
        bottomNavigationBar: const BottomNav(2),
        body: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(width * .02),
            ),
            width: double.infinity,
            height: height,
            padding: EdgeInsets.symmetric(horizontal: width * .04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * .01),
                Text(
                  'Acquisition Opportunities',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    fontSize: 20.sp,
                  ),
                ),
                Container(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      focusColor: Theme.of(context).primaryColor,
                      value: selectedAsset,
                      items: assetTypes.values
                          .map(
                            (asset) => DropdownMenuItem<String>(
                              value: asset,
                              child: Text(
                                asset,
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w300,
                                  fontSize: 16.sp,
                                  color: const Color(0xff808080),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      dropdownColor: Colors.white,
                      icon: const Icon(
                        Icons.arrow_drop_down_sharp,
                        color: Colors.black,
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedAsset = value);
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                // Dynamic content based on selected asset type
                if (selectedAsset == 'Business Asset')
                  const BusinessAssetUI()
                else if (selectedAsset == 'Appreciating Asset')
                  const AppreciatingAssetUI()
                else if (selectedAsset == 'Risk Asset')
                  const RiskAssetUI(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Rest of your methods remain the same...
  Future<void> getGanp() async {
    final timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
    });

    try {
      dialogBox.waiting(context, 'Loading');

      final url = Uri.parse(
        "$assetBaseUrl/ganp/countries?token=xnbbnxbcbvjhnbkgvnmbbnfmohbvjcfgjmcbjmhnomcfjnomnpamqasxmbcvbvnfvbcfhfbvhjjjkfjknfvbiolckojinkjondodnglhdn",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        const url3 = "$baseUrl/app/acquisition/favourite/ganp";
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('tokenDB');

        final response3 = await dio.get(
          url3,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );

        context.read<Providers>().setFavoritesG(response3.data["cultivations"]);

        final Ganpcountries ganpcountries = Ganpcountries.fromJson(
          jsonDecode(response.body),
        );

        context.read<Providers>().setGanpCountryServer(ganpcountries.countries);

        timer.cancel();
        Navigator.pop(context);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Ganp(ganpcountries.countries),
          ),
        );
      } else {
        timer.cancel();
        Navigator.pop(context);
        dialogBox.information(
          context,
          'Error',
          'An error occurred ${response.statusCode}',
        );
      }
    } catch (e) {
      timer.cancel();
      Navigator.pop(context);
      dialogBox.information(context, 'Error', 'An error occurred');
    }
  }
}
