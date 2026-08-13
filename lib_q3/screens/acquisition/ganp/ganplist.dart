import 'dart:convert';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/models/ganpserver.dart';
import 'package:GapHub/screens/acquisition/ganp/ganpdetails.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class Ganplist extends StatefulWidget {
  final Map<String, dynamic> countryAsset;
  final bool search;
  final String searchword;
  final Map country;

  const Ganplist({
    super.key,
    required this.countryAsset,
    required this.country,
    required this.search,
    required this.searchword,
  });
  @override
  _GanplistState createState() => _GanplistState();
}

class _GanplistState extends State<Ganplist> {
  TextEditingController search = TextEditingController();
  Dio dio = Dio();
  static const menuItems = <String>[
    "Low to High Price",
    "High to Low Price",
    "Newest Listings",
    "Oldest Listings",
  ];

  String? selectedItem;

  final List<PopupMenuItem<String>> popUpItems = menuItems
      .map((e) => PopupMenuItem<String>(value: e, child: Text(e)))
      .toList();
  @override
  Widget build(BuildContext context) {
    List ganpList = widget.countryAsset["data"];
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: ganpList.isEmpty
          ? AppBar(
              backgroundColor: Colors.white,
              title: Text(
                widget.search
                    ? "All ${widget.searchword} Listings"
                    : 'GANP ${widget.country["name"]} listings',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              actions: [
                PopupMenuButton(
                  icon: Image.asset(
                    'assets/images/alert.png',
                    height: height * .025,
                    color: Colors.black,
                  ),
                  // color: Color(0xffC6DFB7),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: height * .01),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Notify me about",
                                  style: TextStyle(
                                    // color: Color(0xfff3f3f4),
                                    fontWeight: FontWeight.w300,
                                    fontSize: width * .04,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: height * .03,
                                child: const Divider(),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.search
                                      ? "All ${widget.searchword} Listings"
                                      : "GANP ${widget.country["name"]} listings",
                                  style: TextStyle(
                                    // color: Color(0xfff3f3f4),
                                    fontWeight: FontWeight.w800,
                                    fontSize: width * .045,
                                  ),
                                ),
                              ),
                              SizedBox(height: height * .02),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      width * .01,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Fluttertoast.showToast(
                                    toastLength: Toast.LENGTH_LONG,
                                    msg: widget.search
                                        ? "Alert for ${widget.searchword} listings created successfully"
                                        : "Alert for GANP ${widget.country["name"]} listings created successfully",
                                  );
                                },
                                child: Text(
                                  "Create Alert",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: width * .035,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  onSelected: (value) {},
                ),
              ],
              elevation: 25,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.black),
              ),
              centerTitle: true,
            )
          : AppBar(
              backgroundColor: Colors.white,
              title: Text(
                widget.search
                    ? "All ${widget.searchword} Listings"
                    : 'GANP ${widget.country["name"]} listings',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              actions: [
                PopupMenuButton(
                  icon: Image.asset(
                    'assets/images/sort.png',
                    height: height * .025,
                    color: Colors.black,
                  ),
                  itemBuilder: (context) => popUpItems,
                  onSelected: (value) {
                    switch (value) {
                      case "Low to High Price":
                        setState(() {
                          ganpList.sort(
                            (a, b) =>
                                int.parse(
                                  a["amount"].round().toString().replaceAll(
                                    ",",
                                    "",
                                  ),
                                ).compareTo(
                                  int.parse(
                                    b["amount"].round().toString().replaceAll(
                                      ",",
                                      "",
                                    ),
                                  ),
                                ),
                          );
                        });

                        break;
                      case "High to Low Price":
                        setState(() {
                          ganpList.sort(
                            (a, b) =>
                                int.parse(
                                  b["amount"].round().toString().replaceAll(
                                    ",",
                                    "",
                                  ),
                                ).compareTo(
                                  int.parse(
                                    a["amount"].round().toString().replaceAll(
                                      ",",
                                      "",
                                    ),
                                  ),
                                ),
                          );
                        });
                        break;
                      case "Newest Listings":
                        setState(() {
                          ganpList.sort(
                            (a, b) => b["created_at"].toString().compareTo(
                              a["created_at"].toString(),
                            ),
                          );
                        });

                        break;
                      case "Oldest Listings":
                        setState(() {
                          ganpList.sort(
                            (a, b) => a["created_at"].toString().compareTo(
                              b["created_at"].toString(),
                            ),
                          );
                        });
                        break;
                      default:
                    }
                  },
                ),
                PopupMenuButton(
                  icon: Image.asset(
                    'assets/images/alert.png',
                    height: height * .025,
                    color: Colors.black,
                  ),
                  // color: Color(0xffC6DFB7),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: height * .01),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Notify me about",
                                  style: TextStyle(
                                    // color: Color(0xfff3f3f4),
                                    fontWeight: FontWeight.w300,
                                    fontSize: width * .04,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: height * .03,
                                child: const Divider(),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.search
                                      ? "All ${widget.searchword} Listings"
                                      : "GANP ${widget.country["name"]} listings",
                                  style: TextStyle(
                                    // color: Color(0xfff3f3f4),
                                    fontWeight: FontWeight.w800,
                                    fontSize: width * .045,
                                  ),
                                ),
                              ),
                              SizedBox(height: height * .02),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      width * .01,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Fluttertoast.showToast(
                                    toastLength: Toast.LENGTH_LONG,
                                    msg: widget.search
                                        ? "Alert for ${widget.searchword} listings created successfully"
                                        : "Alert for GANP ${widget.country["name"]} listings created successfully",
                                  );
                                },
                                child: Text(
                                  "Create Alert",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: width * .035,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  onSelected: (value) {},
                ),
              ],
              elevation: 25,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.black),
              ),
              centerTitle: true,
            ),
      bottomNavigationBar: const BottomNav(2),
      body: ganpList.isEmpty
          ? Center(
              child: Text(
                'No GANP Asset yet',
                style: TextStyle(
                  fontSize: width * .06,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ListView(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * .04,
                    vertical: height * .02,
                  ),
                  child: TextField(
                    textInputAction: TextInputAction.search,
                    style: TextStyle(fontSize: width * .035),
                    controller: search,
                    onEditingComplete: searchFun,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: searchFun,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: width * .02,
                        vertical: height * .01,
                      ),
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(width * .02),
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                  physics: const ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.countryAsset['data'].length,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.all(width * .02),
                    child: Card(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * .02,
                          vertical: height * .02,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(width * .02),
                        ),
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Ganpdetails(
                                        widget.countryAsset['data'][index],
                                      ),
                                    ),
                                  );
                                },
                                child: CachedNetworkImage(
                                  imageUrl:
                                      '$hubImageUrl/storage${widget.countryAsset['data'][index]['image1'].toString().substring(6)}',
                                  progressIndicatorBuilder:
                                      (context, url, progress) => Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: .2,
                                          value: progress.progress,
                                        ),
                                      ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.warning_amber_rounded),
                                  fit: BoxFit.none,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${widget.countryAsset['data'][index]['name']}',
                                          style: TextStyle(
                                            fontSize: width * .045,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '${widget.countryAsset['data'][index]['agency']['name']}',
                                          style: TextStyle(
                                            fontSize: width * .035,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '${widget.countryAsset['data'][index]['rate']}% Return',
                                              style: TextStyle(
                                                fontSize: width * .035,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Image.asset(
                                              'assets/images/dot.png',
                                              width: width * .02,
                                            ),
                                            Text(
                                              '${widget.countryAsset['data'][index]['months']} months',
                                              style: TextStyle(
                                                fontSize: width * .035,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: width * .01),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: width * .01,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                          borderRadius: BorderRadius.circular(
                                            width * .01,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${widget.countryAsset['data'][index]['currency'].toString().substring(0, 1)}${widget.countryAsset['data'][index]['amount']} Per Unit',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: width * .04,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: height * .01),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    width * .01,
                                  ),
                                ),
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Ganpdetails(
                                      widget.countryAsset['data'][index],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  'Details',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: width * .05,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Text(ganpList.toString())
              ],
            ),
    );
  }

  searchFun() async {
    FocusScope.of(context).requestFocus(FocusNode());
    Fluttertoast.showToast(msg: "Searching");
    var url = Uri.parse(
      "$assetBaseUrl/search/ganp?token=xnbbnxbcbvjhnbkgvnmbbnfmohbvjcfgjmcbjmhnomcfjnomnpamqasxmbcvbvnfvbcfhfbvhjjjkfjknfvbiolckojinkjondodnglhdn&query=${search.text.trim()}",
    );

    var response = await http.get(url);

    if (response.statusCode == 200) {
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Ganplist(
            countryAsset: ganpcountriesasset.cultivations,
            search: true,
            searchword: search.text.trim(),
            country: const {},
          ),
        ),
      );
    }
  }
}
