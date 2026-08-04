import 'dart:async';
import 'dart:convert';
import 'package:GapHub/screens/acquisition/reap/carouselfull.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Reapdetails extends StatefulWidget {
  final Map<String, dynamic> reapItem;
  // final bool favorited;

  Reapdetails(this.reapItem);
  @override
  _ReapdetailsState createState() => _ReapdetailsState();
}

class _ReapdetailsState extends State<Reapdetails> {
  List options = [
    "Property Description",
    "Investment Numbers",
    "Facts & Features",
    "Neigborhood Highlights",
    "Intelligent Report",
    "Investment Interest Areas",
  ];
  Dio dio = Dio();
  bool favColors = false;
  TextEditingController phoneNumsController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  ExpandableController barController = ExpandableController();

  @override
  void initState() {
    super.initState();
    // print(widget.favorited);
  }

  @override
  Widget build(BuildContext context) {
    // getFav() async {
    //   var timer = Timer(Duration(milliseconds: 5000), () {
    //     setState(() {
    //       getFav();
    //     });
    //   });
    //   var url3 = "$baseUrl/app/acquisition/favourite";
    //   final prefs = await SharedPreferences.getInstance();
    //   var token = prefs.getString('tokenDB');
    //   var response3 = await dio.get(url3,
    //       options: Options(
    //         headers: {"Authorization": 'Bearer $token'},
    //       ));
    //   context.read<Providers>().setFavorites(response3.data["assets"]);
    // }

    // getFav();

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    var list = context.watch<Providers>().favorites;
    var id = widget.reapItem["id"];
    favColors = list.any((element) => element["id"] == id);
    var streetName = widget.reapItem["name"].toString();

    Widget images(String url) {
      String imgurl = 'http://gappropertyhub.com/storage/asset_images/$url';
      if (imgurl.isNotEmpty) {
        return CachedNetworkImage(
          imageUrl: imgurl,
          fit: BoxFit.contain,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
        );
      }
      return const SizedBox();
    }

    List<String> urlChecked = [
      widget.reapItem["asset_image"]["image1"],
      widget.reapItem["asset_image"]["image2"],
      widget.reapItem["asset_image"]["image3"],
      widget.reapItem["asset_image"]["image4"],
      widget.reapItem["asset_image"]["image5"],
      widget.reapItem["asset_image"]["image6"],
      widget.reapItem["asset_image"]["image7"],
      widget.reapItem["asset_image"]["image8"],
      widget.reapItem["asset_image"]["image9"],
      widget.reapItem["asset_image"]["image10"],
      widget.reapItem["asset_image"]["image11"],
      widget.reapItem["asset_image"]["image12"],
      widget.reapItem["asset_image"]["image13"],
      widget.reapItem["asset_image"]["image14"],
      widget.reapItem["asset_image"]["image15"],
      widget.reapItem["asset_image"]["image16"],
    ];

    urlChecked.removeWhere((element) => element.isEmpty);

    List<String> reapDetails = [
      "Property Description",
      "Investment Numbers",
      "Special Features",
      "Facts & Features",
      "Neigbourhood Highlights",
      "Intelligent Report",
      "Sight & Sound",
      "Investment Interest Area",
    ];

    List<Widget> imageList = [
      for (var i = 0; i < urlChecked.length; i++) images(urlChecked[i]),
    ];

    // List<Widget> imageList = imageLis.removeWhere((element) => false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.reapItem['location']['street']}',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: width * .035,
          ),
        ),
        actions: [
          IconButton(
            icon: favColors
                ? Image.asset(
                    'assets/images/favourite-red.png',
                    color: Theme.of(context).primaryColor,
                  )
                : Image.asset('assets/images/favourite.png'),
            onPressed: () async {
              var url3 = "$baseUrl/app/acquisition/favourite";
              Fluttertoast.showToast(
                msg: !favColors ? "Adding Asset" : "Removing Asset",
              );
              var url = !favColors
                  ? '$baseUrl/app/acquisition/favourite/$id?acquisition=retyanshamdhankdxmp_ashdhgagdhb&signature=ahgfhagbhgsbhgsbyuhjwgs65wytgv7wystdg6tygfvdtydgvgyhdnxngb'
                  : "$baseUrl/app/acquisition/favourite/$id?acquisition=retyanshamdaahgs_rmzojishjbdx&signature=ahgfhagbhgsbhgsbyuhjwgs65wytgv7wystdg6tygfvdtydgvgyhdnxngb";
              final prefs = await SharedPreferences.getInstance();
              var token = prefs.getString('tokenDB');
              var response = await dio.get(
                url,
                options: Options(headers: {"Authorization": 'Bearer $token'}),
              );

              var response3 = await dio.get(
                url3,
                options: Options(headers: {"Authorization": 'Bearer $token'}),
              );
              context.read<Providers>().setFavorites(response3.data["assets"]);

              Fluttertoast.showToast(
                msg: favColors ? "Removed Successfully" : "Added Successfully",
              );

              setState(() {
                favColors = !favColors;
              });
            },
          ),
          IconButton(
            icon: Image.asset('assets/images/share.png', color: Colors.black),
            onPressed: () {
              // Share.share(
              //     '$shareBase/acquisition/asset/reap/${id}_${streetName.split(" ").first}');
            },
          ),
        ],
        elevation: 25,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      bottomNavigationBar: BottomNav(2),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * .02,
            vertical: height * .02,
          ),
          child: Column(
            children: [
              Text(
                'Rental Income: ${widget.reapItem["currency"]}${widget.reapItem["investment"]["net_revenue"]}',
                style: TextStyle(
                  fontSize: width * .05,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Carouselfull(imageList),
                  ),
                ),
                child: CarouselSlider(
                  items: imageList,
                  options: CarouselOptions(
                    height: height * .3,
                    aspectRatio: 16 / 9,
                    initialPage: 0,
                    enlargeCenterPage: true,
                    viewportFraction: 0.8,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 3),
                    autoPlayAnimationDuration: Duration(milliseconds: 1500),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    scrollDirection: Axis.horizontal,
                  ),
                ),
              ),
              Text(
                '${widget.reapItem['location']['street']}, ${widget.reapItem['location']['city']}, ${widget.reapItem['location']['state']}, ${widget.reapItem['location']['country']}.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: width * .04,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: height * .05),
              Container(
                padding: EdgeInsets.only(left: width * .02),
                height: height * .05,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  border: Border.all(width: 0, color: Colors.grey[300]!),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Property Details'.toUpperCase(),
                    style: TextStyle(
                      fontSize: width * .05,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              ExpandablePanel(
                header: Card(
                  color: Colors.black,
                  elevation: 5,
                  child: ListTile(
                    trailing: Image.asset(
                      'assets/images/chevron_down.png',
                      height: width * .04,
                    ),
                    title: Text(
                      '${reapDetails[0]}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * .04,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                // ignore: deprecated_member_use
                collapsed: Container(),
                expanded: Card(
                  child: Padding(
                    padding: EdgeInsets.all(width * .02),
                    child: Text(
                      '${widget.reapItem["description"]}',
                      style: TextStyle(
                        fontSize: width * .035,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              ExpandablePanel(
                header: Card(
                  color: Colors.black,
                  elevation: 5,
                  child: ListTile(
                    trailing: Image.asset(
                      'assets/images/chevron_down.png',
                      height: width * .04,
                    ),
                    title: Text(
                      reapDetails[1],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * .04,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                collapsed: Container(),
                expanded: Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: Center(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: width * .035,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    children: [
                                      TextSpan(text: 'Sale Price: '),
                                      TextSpan(
                                        text:
                                            '${widget.reapItem["currency"]}${widget.reapItem["investment"]["sale_price"]}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(
                                  color: Colors.black,
                                  width: width * .001,
                                ),
                              ),
                              height: height * .05,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: Center(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: width * .035,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    children: [
                                      TextSpan(text: 'Rental Value: '),
                                      TextSpan(
                                        text:
                                            '${widget.reapItem["currency"]}${widget.reapItem["investment"]["rental_price"]}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(
                                  color: Colors.black,
                                  width: width * .001,
                                ),
                              ),
                              height: height * .05,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: Center(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: width * .035,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    children: [
                                      TextSpan(text: 'Management Fee: '),
                                      TextSpan(
                                        text:
                                            '${widget.reapItem["currency"]}${widget.reapItem["investment"]["management_fee"]}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                  width: width * .001,
                                ),
                              ),
                              height: height * .05,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: Center(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: width * .035,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    children: [
                                      TextSpan(text: 'Property Tax: '),
                                      TextSpan(
                                        text:
                                            '${widget.reapItem["currency"]}${widget.reapItem["investment"]["tax"]}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                  width: width * .001,
                                ),
                              ),
                              height: height * .05,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: Center(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: width * .035,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    children: [
                                      TextSpan(text: 'Gross ROI: '),
                                      TextSpan(
                                        text:
                                            '${widget.reapItem["investment"]["gross"]}%',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(
                                  color: Colors.black,
                                  width: width * .001,
                                ),
                              ),
                              height: height * .05,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: Center(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: width * .035,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    children: [
                                      TextSpan(text: 'Misc & Assoc Fee: '),
                                      TextSpan(
                                        text:
                                            '${widget.reapItem["currency"]}${widget.reapItem["investment"]["associate_fee"]}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(
                                  color: Colors.black,
                                  width: width * .001,
                                ),
                              ),
                              height: height * .05,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: Center(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: width * .035,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    children: [
                                      TextSpan(text: 'Net Revenue : '),
                                      TextSpan(
                                        text:
                                            '${widget.reapItem["currency"]}${widget.reapItem["investment"]["net_revenue"]}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                  width: width * .001,
                                ),
                              ),
                              height: height * .05,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: Center(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: width * .035,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    children: [
                                      TextSpan(text: 'Rental Income: '),
                                      TextSpan(
                                        text:
                                            '${widget.reapItem["currency"]}${widget.reapItem["investment"]["monthly_income"]}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                  width: width * .001,
                                ),
                              ),
                              height: height * .05,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: Center(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: width * .035,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    children: [
                                      TextSpan(text: 'Total Deduction: '),
                                      TextSpan(
                                        text:
                                            '${widget.reapItem["currency"]}${widget.reapItem["investment"]["total_deduction"]}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(
                                  color: Colors.black,
                                  width: width * .001,
                                ),
                              ),
                              height: height * .05,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(
                                  color: Colors.black,
                                  width: width * .001,
                                ),
                              ),
                              height: height * .05,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * .005),

              ExpandablePanel(
                header: Card(
                  color: Colors.black,
                  elevation: 5,
                  child: ListTile(
                    trailing: Image.asset(
                      'assets/images/chevron_down.png',
                      height: width * .04,
                    ),
                    title: Text(
                      '${reapDetails[2]}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * .04,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                collapsed: Container(),
                expanded: Card(
                  child: Container(
                    width: width,
                    padding: EdgeInsets.all(width * .03),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.reapItem["special_feature"]["spec_feature1"] ==
                                null
                            ? Container()
                            : Padding(
                                padding: EdgeInsets.only(bottom: height * .01),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: width * .035,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    children: [
                                      TextSpan(text: 'Property Type: '),
                                      TextSpan(
                                        text:
                                            '${widget.reapItem["special_feature"]["spec_feature1"]}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        Padding(
                          padding: EdgeInsets.only(bottom: height * .01),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: width * .035,
                                fontWeight: FontWeight.w400,
                              ),
                              children: [
                                TextSpan(text: 'Bed: '),
                                TextSpan(
                                  text:
                                      '${widget.reapItem["special_feature"]["spec_feature2"]}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: width * .035,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              TextSpan(text: 'Bath: '),
                              TextSpan(
                                text:
                                    '${widget.reapItem["special_feature"]["spec_feature3"]}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        widget.reapItem["special_feature"]["spec_feature4"] ==
                                null
                            ? Container()
                            : Padding(
                                padding: EdgeInsets.only(top: height * .01),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: width * .035,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            '${widget.reapItem["special_feature"]["spec_feature4"]}',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        widget.reapItem["special_feature"]["spec_feature5"] ==
                                null
                            ? Container()
                            : Padding(
                                padding: EdgeInsets.only(top: height * .01),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: width * .035,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            '${widget.reapItem["special_feature"]["spec_feature5"]}',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        widget.reapItem["special_feature"]["spec_feature6"] ==
                                null
                            ? Container()
                            : Padding(
                                padding: EdgeInsets.only(top: height * .01),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: width * .035,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            '${widget.reapItem["special_feature"]["spec_feature6"]}',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        widget.reapItem["special_feature"]["spec_feature7"] ==
                                null
                            ? Container()
                            : Padding(
                                padding: EdgeInsets.only(top: height * .01),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: width * .035,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            '${widget.reapItem["special_feature"]["spec_feature7"]}',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              ExpandablePanel(
                header: Card(
                  color: Colors.black,
                  elevation: 5,
                  child: ListTile(
                    trailing: Image.asset(
                      'assets/images/chevron_down.png',
                      height: width * .04,
                    ),
                    title: Text(
                      '${reapDetails[3]}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * .04,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                collapsed: Container(),
                expanded: Card(
                  child: Container(
                    width: width,
                    padding: EdgeInsets.all(width * .03),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: width * .035,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    '${widget.reapItem["feature"]["feature1"]}',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height * .01),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: width * .035,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    '${widget.reapItem["feature"]["feature2"]}',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height * .01),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: width * .035,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    '${widget.reapItem["feature"]["feature3"]}',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height * .01),
                        widget.reapItem["feature"]["feature4"] == null
                            ? Container()
                            : RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: width * .035,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          '${widget.reapItem["feature"]["feature4"]}',
                                    ),
                                  ],
                                ),
                              ),
                        widget.reapItem["feature"]["feature4"] == null
                            ? Container()
                            : SizedBox(height: height * .01),
                        widget.reapItem["feature"]["feature4"] == null
                            ? Container()
                            : Text(
                                '${widget.reapItem["feature"]["feature5"]},',
                                style: TextStyle(
                                  fontSize: width * .035,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              ExpandablePanel(
                collapsed: Container(),
                expanded: Card(
                  child: Padding(
                    padding: EdgeInsets.all(width * .03),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.reapItem["neighborhood"]}',
                          textScaleFactor: 1,
                          style: TextStyle(
                            fontSize: width * .035,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              ExpandablePanel(
                header: Card(
                  color: Colors.black,
                  elevation: 5,
                  child: ListTile(
                    trailing: Image.asset(
                      'assets/images/chevron_down.png',
                      height: width * .04,
                    ),
                    title: Text(
                      reapDetails[5],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * .04,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                collapsed: Container(),
                expanded: Container(
                  child: Text('Available Upon Request'),
                  height: height * .05,
                  padding: EdgeInsets.only(left: width * .03),
                ),
              ),
              SizedBox(height: height * .005),
              ExpandablePanel(
                header: Card(
                  color: Colors.black,
                  elevation: 5,
                  child: ListTile(
                    trailing: Image.asset(
                      'assets/images/chevron_down.png',
                      height: width * .04,
                    ),
                    title: Text(
                      reapDetails[6],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * .04,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                collapsed: Container(),
                expanded: Container(
                  child: Text('Available Upon Request'),
                  height: height * .05,
                  padding: EdgeInsets.only(left: width * .03),
                ),
              ),
              SizedBox(height: height * .005),
              ExpandablePanel(
                controller: barController,
                header: Card(
                  color: Color.fromRGBO(0, 0, 0, 1),
                  elevation: 5,
                  child: ListTile(
                    trailing: Image.asset(
                      'assets/images/chevron_down.png',
                      height: width * .04,
                    ),
                    title: Text(
                      reapDetails[7],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * .04,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                collapsed: Container(),
                expanded: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * .03,
                      vertical: height * .03,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: height * .01),
                        if (["", null].contains(
                          Provider.of<Providers>(
                            context,
                            listen: false,
                          ).details[3],
                        ))
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Phone Number',
                              style: TextStyle(
                                fontSize: width * .045,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        SizedBox(height: height * .005),
                        if (["", null].contains(
                          Provider.of<Providers>(
                            context,
                            listen: false,
                          ).details[3],
                        ))
                          TextFormField(
                            controller: phoneNumsController,
                            textCapitalization: TextCapitalization.sentences,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              prefixText: "",
                              prefixStyle: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w400,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.only(
                                left: width * .013,
                                right: width * .03,
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        if (["", null].contains(
                          Provider.of<Providers>(
                            context,
                            listen: false,
                          ).details[3],
                        ))
                          SizedBox(height: height * .03),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Subject',
                            style: TextStyle(
                              fontSize: width * .045,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: height * .005),
                        TextFormField(
                          controller: subjectController,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            prefixText: "",
                            prefixStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w400,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.only(
                              left: width * .013,
                              right: width * .03,
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: height * .03),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Message',
                            style: TextStyle(
                              fontSize: width * .045,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: height * .005),
                        TextFormField(
                          controller: messageController,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 7,
                          decoration: InputDecoration(
                            prefixText: "",
                            prefixStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w400,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.only(
                              left: width * .013,
                              right: width * .03,
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: height * .005),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              Save(id);
                            },
                            child: Text(
                              'Save',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * .04),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width * .02),
                  ),
                ),
                onPressed: () {
                  var dialogBox = DialogBox();

                  dialogBox.options(
                    context,
                    "Confirm Reserve Asset",
                    "Are you sure you want to reserve this asset?",
                    () {
                      Reserve(id);
                    },
                  );
                },
                child: Container(
                  height: height * .05,
                  child: Center(
                    child: Text(
                      'Reserve this Asset',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * .05,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
                onPressed: () {},
                child: Container(
                  height: height * .05,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Add to Portfolio Desired Assets',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * .05,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset(
                            'assets/images/desired.png',
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Text(widget.reapItem.toString())
            ],
          ),
        ),
      ),
    );
  }

  Reserve(assetId) async {
    EasyLoading.show(status: 'Loading', dismissOnTap: false);
    var url = Uri.parse("$baseUrl/app/acquisition/investment/reap/${assetId}");
    var timer = Timer(Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      EasyLoading.dismiss();
      return;
    });

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var reapresponse = await http.post(
      url,
      headers: {"Authorization": 'Bearer $token'},
    );
    if (reapresponse.statusCode == 200) {
      timer.cancel();
      EasyLoading.dismiss();
      Fluttertoast.showToast(msg: "Asset reserved");
    }
    // connectTo(
    //     context, "post", "/app/acquisition/investment/reap/${assetId}", {},
    //     shoot: () {
    //   Fluttertoast.showToast(msg: "Asset reserved");
    // });
  }

  Save(assetId) async {
    print("asset id: ${assetId}");
    // if (
    //     ["", null].contains(subjectController.text.trim()) ||
    //     ["", null].contains(messageController.text.trim())) {
    //   var dialogBox = DialogBox();
    //   dialogBox.information(
    //       context, 'Provide All Details', 'All fields must be filled');
    //   return;
    // }
    // var data = {
    //   "message": messageController.text.trim(),
    //   "subject": subjectController.text.trim(),
    // };
    // connectTo(
    //     context,
    //     "post",
    //     "/app/acquisition/interest/reap/${assetId}",
    //     data,
    //     shoot: () {

    //       Fluttertoast.showToast(msg: "Interest has been recorded");
    // });

    var details = Provider.of<Providers>(context, listen: false).details;
    if (["", null].contains(details[3])) {
      if (["", null].contains(phoneNumsController.text.trim()) ||
          ["", null].contains(subjectController.text.trim()) ||
          ["", null].contains(messageController.text.trim())) {
        var dialogBox = DialogBox();
        dialogBox.information(
          context,
          'Provide All Details',
          'All fields must be filled',
        );
        return;
      }
      var data = {
        "message": messageController.text.trim(),
        "phone": phoneNumsController.text.trim(),
        "subject": subjectController.text.trim(),
      };
      var url = Uri.parse(
        "$baseUrl/app/acquisition/investment/reap/${assetId}",
      );

      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');
      var response = await http.post(
        url,
        body: data,
        headers: {"Authorization": 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        Fluttertoast.showToast(msg: "Interest has been recorded");
        barController.toggle();
        messageController.clear();
        phoneNumsController.clear();
        subjectController.clear();
      } else {
        Fluttertoast.showToast(msg: "Error occured");
      }
    } else {
      if (!["", null].contains(subjectController.text.trim()) &&
          !["", null].contains(messageController.text.trim())) {
        var data = {
          "message": messageController.text.trim(),
          "subject": subjectController.text.trim(),
        };
        var url = Uri.parse(
          "$baseUrl/app/acquisition/interest/reap/${assetId}",
        );

        final prefs = await SharedPreferences.getInstance();
        var token = prefs.getString('tokenDB');
        var response = await http.post(
          url,
          body: data,
          headers: {"Authorization": 'Bearer $token'},
        );
        if (response.statusCode == 200) {
          var body = jsonDecode(response.body);
          Fluttertoast.showToast(msg: "Interest has been recorded");
          barController.toggle();
          messageController.clear();
          phoneNumsController.clear();
          subjectController.clear();
        } else {
          Fluttertoast.showToast(msg: "Error occured");
        }
      } else {
        var dialogBox = DialogBox();
        dialogBox.information(
          context,
          'Provide All Details',
          'All fields must be filled',
        );
      }
    }
  }
}
