import 'dart:async';
import 'dart:convert';
import 'package:GapHub/models/reapserver.dart';
import 'package:GapHub/screens/acquisition/reap/reapdetails.dart';
import 'package:GapHub/screens/others/dashboards/dashboard.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:dio/dio.dart';

// class FeaturedPage extends StatelessWidget{
//   @override
//   Widget build(BuildContext contxt){
//       return Scaffold(

//       )
//   }

// }

class FeaturedList extends StatefulWidget {
  final String url;
  final List reapList;
  final int lastPage;
  final int firstPage;
  final String searchword;
  final bool search;
  const FeaturedList({
    super.key,
    required this.url,
    required this.reapList,
    required this.lastPage,
    required this.firstPage,
    required this.searchword,
    required this.search,
  });
  @override
  _FeaturedListState createState() => _FeaturedListState(reapList);
}

class _FeaturedListState extends State<FeaturedList> {
  List reapList = [];
  Reapserver reapserver = Reapserver();
  int currentPage = 1;
  DialogBox dialogBox = DialogBox();
  TextEditingController search = TextEditingController();
  List<Widget> navWidgets = [];
  Dio dio = Dio();
  final ScrollController _scrollController = ScrollController();
  _FeaturedListState(this.reapList);
  static const menuItems1 = <String>[
    "Low to High Price",
    "High to Low Price",
    "Newest Listings",
    "Oldest Listings",
  ];

  final List<PopupMenuItem<String>> sortItems = menuItems1
      .map((e) => PopupMenuItem<String>(value: e, child: Text(e)))
      .toList();

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    for (var i = 1; i <= widget.lastPage; i++) {
      navWidgets.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(border: Border.all()),
            child: Text('$i', style: TextStyle(fontSize: width * .03)),
          ),
        ),
      );
    }

    // List reapList = context.watch<Providers>().reapServerList;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Dashboard(index: 0)),
          ),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        elevation: 25,
        backgroundColor: Colors.white,
        title: Text(
          widget.search
              ? "${widget.searchword} Listings"
              : "Listings", //'${reapList[0]['category']['name']} Listings',
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
                        SizedBox(height: height * .03, child: const Divider()),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.search
                                ? "All ${widget.searchword} Listings"
                                : "All ${widget.reapList[0]["category"]["name"]} Listings:",
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
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(width * .01),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                              toastLength: Toast.LENGTH_LONG,
                              msg: widget.search
                                  ? "Alert for ${widget.searchword} listings created successfully"
                                  : "Alert for ${widget.reapList[0]["category"]["name"]} listings created successfully",
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
      ),
      bottomNavigationBar: const BottomNav(2),
      body: reapList.isEmpty
          ? Container(
              child: Center(
                child: Text(
                  "No Item",
                  style: TextStyle(
                    fontSize: width * .06,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * .02,
                vertical: height * .02,
              ),
              child: ListView(
                controller: _scrollController,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * .22,
                      vertical: height * .02,
                    ),
                    child: TextField(
                      onEditingComplete: searchFun,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(fontSize: width * .035),
                      controller: search,
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
                          borderRadius: BorderRadius.circular(width * .1),
                        ),
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: reapList.length,
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * .02,
                        vertical: height * .04,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: height * .02),
                        color: Colors.grey[200],
                        child: Column(
                          children: [
                            SizedBox(
                              height: height * .27,
                              width: width * .9,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Reapdetails(reapList[index]),
                                    ),
                                  );
                                },
                                child: CachedNetworkImage(
                                  imageUrl:
                                      'http://gappropertyhub.com/storage/asset_images/${reapList[index]["asset_image"]["image2"]}',
                                  progressIndicatorBuilder:
                                      (context, url, progress) => Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: .2,
                                          value: progress.progress,
                                        ),
                                      ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.portrait),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(height: height * .01),
                            Text(
                              '${reapList[index]['name']}',
                              style: TextStyle(
                                fontSize: width * .06,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: height * .01),
                            Text(
                              '${reapList[index]['location']['street']}, ${reapList[index]['location']['city']}, ${reapList[index]['location']['state']}, ${reapList[index]['location']['country']}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: width * .04,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            SizedBox(height: height * .01),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        Reapdetails(reapList[index]),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                ),
                                height: height * .045,
                                width: width * 1,
                                child: Center(
                                  child: Text(
                                    '${reapList[index]['currency']}${reapList[index]['investment']['sale_price']}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: width * .045,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: height * .02),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: width * .02,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Bed"),
                                      Text(
                                        '${reapList[index]["special_feature"]["spec_feature2"]}',
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: height * .02,
                                    child: Divider(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Bath"),
                                      Text(
                                        '${reapList[index]["special_feature"]["spec_feature3"]}',
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: height * .02,
                                    child: Divider(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Rental Income"),
                                      Text(
                                        '${reapList[index]["currency"]}${reapList[index]["investment"]["total_deduction"]}',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: height * .02),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        Reapdetails(reapList[index]),
                                  ),
                                );
                              },
                              child: const Text(
                                'View details',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * .01),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: width * .02),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Visibility(
                          visible: currentPage != widget.firstPage,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  width * .01,
                                ),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                currentPage -= 1;
                                getReap();
                              });
                            },
                            child: Text(
                              'PREV',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: width * .05,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Visibility(
                          visible: currentPage == widget.firstPage,
                          child: SizedBox(width: width * .22),
                        ),
                        Visibility(
                          visible: reapList.isNotEmpty,
                          child: Text(
                            '$currentPage of ${widget.lastPage}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: width * .05,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Visibility(
                          visible: currentPage == widget.lastPage,
                          child: SizedBox(width: width * .22),
                        ),
                        Visibility(
                          visible: currentPage != widget.lastPage,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  width * .01,
                                ),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                currentPage += 1;
                                getReap();
                              });
                            },
                            child: Text(
                              'NEXT',
                              style: TextStyle(
                                fontSize: width * .04,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Text(widget.reapList[0].toString())
                ],
              ),
            ),
    );
  }

  sort(String sort) async {
    dialogBox.waiting(context, "Sorting");
    var url = "${widget.url}&ct_sort=$sort&page=1";
    var response = await dio.get(url);
    List list = response.data["result"]["data"];

    setState(() {
      reapList = list;
      Navigator.pop(context);
    });
  }

  searchFun() async {
    FocusScope.of(context).requestFocus(FocusNode());
    Fluttertoast.showToast(msg: "Searching");
    var url = Uri.parse(
      'http://gappropertyhub.com/api/search?token=qswsdopspncagajkxnnznbxghsjksjujiubszajkbagznbzvszhjvxhvsvzghzgxgvxhgdjhvhchxbhxbxvvxvhhxvhvhhmdjxdbjxvhjhxdbvjxdxjbvlbjz&page=1&ct_keyword=${search.text.trim()}',
    );
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var url3 = "$baseUrl/app/acquisition/favourite";
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');
      var response3 = await dio.get(
        url3,
        options: Options(headers: {"Authorization": 'Bearer $token'}),
      );
      context.read<Providers>().setFavorites(response3.data["assets"]);
      Reapserver reapserver = Reapserver.fromJson(jsonDecode(response.body));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FeaturedList(
            url: widget.url,
            search: true,
            searchword: search.text.trim(),
            reapList: reapserver.result!['data'],
            firstPage: widget.firstPage,
            lastPage: reapserver.result!['last_page'],
          ),
        ),
      );
    }
  }

  getReap() async {
    var timer = Timer(const Duration(seconds: 40), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    try {
      dialogBox.waiting(context, 'Loading');

      var urltouse = Uri.parse('${widget.url}&page=$currentPage');
      var response = await http.get(urltouse);
      if (response.statusCode == 200) {
        reapserver = Reapserver.fromJson(jsonDecode(response.body));

        setState(() {
          reapList = reapserver.result!['data'];
        });
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastLinearToSlowEaseIn,
        );
        timer.cancel();
        Navigator.pop(context);
      } else {
        timer.cancel();
        Navigator.pop(context);
        dialogBox.information(context, 'Error', 'An error ocurred');
      }
    } catch (e) {
      timer.cancel();
      Navigator.pop(context);
      dialogBox.information(context, 'Error', "No more items");
    }
  }
}
