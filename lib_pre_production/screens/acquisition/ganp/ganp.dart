import 'dart:convert';
import 'package:GapHub/screens/acquisition/ganp/ganplist.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/models/ganpserver.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:dio/dio.dart';

class Ganp extends StatefulWidget {
  final List<dynamic> ganpCountries;

  const Ganp(this.ganpCountries, {super.key});
  @override
  _GanpState createState() => _GanpState();
}

class _GanpState extends State<Ganp> {
  DialogBox dialogBox = DialogBox();
  Dio dio = Dio();
  List<Widget> widgets = [];
  bool filterToggle = true;
  String keywordText = '';
  String roiFromText = '';
  String roiToText = '';

  TextEditingController keyword = TextEditingController();
  TextEditingController roiFrom = TextEditingController();
  TextEditingController roiTo = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    // slide 2 to 7. transparency on nav items

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Asset Acquisition',
              style: TextStyle(
                color: Colors.black,
                fontSize: width * .03,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'the only path that leads to financial independence',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: width * .023,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Image.asset(
              'assets/images/tracking.png',
              color: Colors.black,
            ),
          ),
        ],
        leading: IconButton(
          color: Colors.black,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 25,
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      bottomNavigationBar: const BottomNav(2),
      body: ListView(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: height * .02),
          Container(
            padding: EdgeInsets.symmetric(vertical: height * .02),
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(width * .02),
            ),
            child: Column(
              children: [
                Text(
                  'Green Asset National Program (GANP)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: width * .06,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: height * .01),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * .035),
                        child: TextField(
                          onEditingComplete: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            search();
                          },
                          keyboardType: TextInputType.name,
                          style: TextStyle(
                            fontSize: width * .035,
                            color: Colors.white,
                          ),
                          controller: keyword,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(width * .02),
                            ),
                            hintText: 'Available Cultivation',
                            filled: true,
                            fillColor: Colors.black,
                            contentPadding: EdgeInsets.all(width * .03),
                            hintStyle: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            filterToggle = !filterToggle;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(width * .01),
                          ),
                          height: width * .12,
                          width: width * .12,
                          child: filterToggle
                              ? Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: height * .03,
                                )
                              : Image.asset(
                                  'assets/images/subtract.png',
                                  height: width * .02,
                                ),
                        ),
                      ),
                    ),
                    SizedBox(width: width * .02),
                  ],
                ),
                SizedBox(height: height * .01),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: width * .035),
                  child: Visibility(
                    visible: !filterToggle,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            style: TextStyle(
                              fontSize: width * .035,
                              color: Colors.white,
                            ),
                            controller: roiFrom,
                            inputFormatters: [amountValidator],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.black,
                              hintStyle: const TextStyle(color: Colors.grey),
                              hintText: 'ROI From (%)',
                              contentPadding: EdgeInsets.all(width * .03),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  width * .02,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: width * .01),
                        Expanded(
                          child: TextField(
                            style: TextStyle(
                              fontSize: width * .035,
                              color: Colors.white,
                            ),
                            controller: roiTo,
                            keyboardType: TextInputType.number,
                            inputFormatters: [amountValidator],
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.black,
                              hintText: 'ROI To (%)',
                              contentPadding: EdgeInsets.all(width * .03),
                              hintStyle: const TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  width * .02,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: height * .02),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * .02),
                    ),
                  ),
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    search();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: height * .012),
                    child: Text(
                      'Search',
                      style: TextStyle(
                        fontSize: width * .035,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemCount: widget.ganpCountries.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(vertical: height * .01),
              child: Card(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(width * .02),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: height * .01,
                    horizontal: width * .02,
                  ),
                  width: width * .9,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          getGanpAssets(index);
                        },
                        child: SizedBox(
                          height: height * .27,
                          child: CachedNetworkImage(
                            imageUrl:
                                '$hubImageUrl/storage${widget.ganpCountries[index]['image'].toString().substring(6)}',
                            progressIndicatorBuilder:
                                (context, url, progress) => Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: .2,
                                    value: progress.progress,
                                  ),
                                ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.portrait),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: height * .01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Country',
                                style: TextStyle(
                                  fontSize: width * .045,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${widget.ganpCountries[index]['name']}',
                                style: TextStyle(
                                  fontSize: width * .035,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Minimum Capital: ${widget.ganpCountries[index]['shortname']}10,000',
                                style: TextStyle(
                                  fontSize: width * .035,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                'ROI: Up to 55%',
                                style: TextStyle(
                                  fontSize: width * .035,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                'Currency: ${widget.ganpCountries[index]['shortname']}',
                                style: TextStyle(
                                  fontSize: width * .035,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: height * .01),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(width * .02),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          getGanpAssets(index);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: height * .01),
                          child: Text(
                            'Visit',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: width * .05,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * .03),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: height * .03),
        ],
      ),
    );
  }

  searchd() async {
    keywordText = keyword.text;
    roiFromText = roiFrom.text;
    roiToText = roiTo.text;

    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    http.Response? url;
    // var _url = Uri.parse('$assetBaseUrl/search/ganp?token=xnbbnxbcbvjhnbkgvnmbbnfmohbvjcfgjmcbjmhnomcfjnomnpamqasxmbcvbvnfvbcfhfbvhjjjkfjknfvbiolckojinkjondodnglhdn');
    String baseUrl =
        "$assetBaseUrl/search/ganp?token=xnbbnxbcbvjhnbkgvnmbbnfmohbvjcfgjmcbjmhnomcfjnomnpamqasxmbcvbvnfvbcfhfbvhjjjkfjknfvbiolckojinkjondodnglhdn";

    String searchword = "";
    dialogBox.waiting(context, 'Searching');

    if (keywordText.isEmpty && roiFromText.isEmpty && roiToText.isEmpty) {
      timer.cancel();
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Please Enter your search Keyword");
    }

    if (keywordText.isNotEmpty) {
      // _url = _url.toString() + '&query=$keywordText' as Uri;
      url = await http.get(Uri.parse('$baseUrl/&query=$keywordText'));
      searchword = keywordText;
    }

    if (roiFromText.isNotEmpty) {
      //_url = _url.toString() + '&roi_from=$roiFromText' as Uri;
      url = await http.get(Uri.parse('$baseUrl/&roi_from=$roiFromText'));
      searchword = roiFromText;
    }

    if (roiToText.isNotEmpty) {
      //_url = _url.toString() + '&roi_to=$roiToText' as Uri;
      url = await http.get(Uri.parse('$baseUrl/&roi_to=$roiToText'));
      searchword = roiToText;
    }

    var response = url;

    if (response!.statusCode == 200) {
      var url3 = "$baseUrl/app/acquisition/favourite/ganp";
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');
      var response3 = await dio.get(
        url3,
        options: Options(headers: {"Authorization": 'Bearer $token'}),
      );
      context.read<Providers>().setFavoritesG(response3.data["cultivations"]);
      Ganpcountriesasset ganpcountriesasset = Ganpcountriesasset.fromJson(
        jsonDecode(response.body),
      );
      context.read<Providers>().setGanpCountryAssetServer(
        ganpcountriesasset.cultivations,
      );
      timer.cancel();
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Ganplist(
            countryAsset: ganpcountriesasset.cultivations,
            search: true,
            country: const {},
            searchword: searchword.trim(),
          ),
        ),
      );
    } else {
      timer.cancel();
      Navigator.pop(context);
      dialogBox.information(context, 'Error', 'An error ocurred');
    }
  }

  Future<void> search() async {
    keywordText = keyword.text;
    roiFromText = roiFrom.text;
    roiToText = roiTo.text;

    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });

    http.Response? url; // Make it nullable
    String baseUrl =
        "$assetBaseUrl/search/ganp?token=xnbbnxbcbvjhnbkgvnmbbnfmohbvjcfgjmcbjmhnomcfjnomnpamqasxmbcvbvnfvbcfhfbvhjjjkfjknfvbiolckojinkjondodnglhdn";

    String searchword = "";
    dialogBox.waiting(context, 'Searching');

    if (keywordText.isEmpty && roiFromText.isEmpty && roiToText.isEmpty) {
      timer.cancel();
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Please Enter your search Keyword");
      return; // Exit early
    }

    try {
      if (keywordText.isNotEmpty) {
        url = await http.get(Uri.parse('$baseUrl&query=$keywordText'));
        searchword = keywordText;
      } else if (roiFromText.isNotEmpty) {
        url = await http.get(Uri.parse('$baseUrl&roi_from=$roiFromText'));
        searchword = roiFromText;
      } else if (roiToText.isNotEmpty) {
        url = await http.get(Uri.parse('$baseUrl&roi_to=$roiToText'));
        searchword = roiToText;
      }

      // Ensure _url is not null before using it
      if (url == null) {
        timer.cancel();
        Navigator.pop(context);
        dialogBox.information(context, 'Error', 'Invalid search parameters');
        return;
      }

      if (url.statusCode == 200) {
        var url3 = "$baseUrl/app/acquisition/favourite/ganp";
        final prefs = await SharedPreferences.getInstance();
        var token = prefs.getString('tokenDB');

        var response3 = await dio.get(
          url3,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );

        context.read<Providers>().setFavoritesG(response3.data["cultivations"]);
        Ganpcountriesasset ganpcountriesasset = Ganpcountriesasset.fromJson(
          jsonDecode(url.body),
        );
        context.read<Providers>().setGanpCountryAssetServer(
          ganpcountriesasset.cultivations,
        );

        timer.cancel();
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Ganplist(
              countryAsset: ganpcountriesasset.cultivations,
              search: true,
              country: const {},
              searchword: searchword.trim(),
            ),
          ),
        );
      } else {
        throw Exception('Server error');
      }
    } catch (e) {
      timer.cancel();
      Navigator.pop(context);
      dialogBox.information(context, 'Error', 'An error occurred: $e');
    }
  }

  getGanpAssets(int index) async {
    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    try {
      print("ganp country id: ${widget.ganpCountries[index]["id"]}");
      dialogBox.waiting(context, 'Loading');
      var url = Uri.parse(
        "http://www.gapassethub.com/public/api/ganp/assets/${widget.ganpCountries[index]["id"]}?token=xnbbnxbcbvjhnbkgvnmbbnfmohbvjcfgjmcbjmhnomcfjnomnpamqasxmbcvbvnfvbcfhfbvhjjjkfjknfvbiolckojinkjondodnglhdn",
      );
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var url3 = "$baseUrl/app/acquisition/favourite/ganp";
        var response3 = await dio.get(
          url3,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );
        context.read<Providers>().setFavoritesG(response3.data["cultivations"]);
        Ganpcountriesasset ganpcountriesasset = Ganpcountriesasset.fromJson(
          jsonDecode(response.body),
        );

        context.read<Providers>().setGanpCountryAssetServer(
          ganpcountriesasset.cultivations,
        );
        timer.cancel();
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Ganplist(
              countryAsset: ganpcountriesasset.cultivations,
              search: false,
              country: jsonDecode(response.body)["country"],
              searchword: '',
            ),
          ),
        );
      } else {
        timer.cancel();
        Navigator.pop(context);
        dialogBox.information(context, 'Error', 'Ann error ocurred');
      }
    } catch (e) {
      timer.cancel();
      Navigator.pop(context);
      dialogBox.information(context, 'Error', 'An error ocurred');
    }
  }
}
