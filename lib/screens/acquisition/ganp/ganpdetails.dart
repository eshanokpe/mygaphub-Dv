import 'package:GapHub/screens/acquisition/ganp/confirmganp.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:share/share.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Ganpdetails extends StatefulWidget {
  final Map<String, dynamic> productDetails;

  const Ganpdetails(this.productDetails, {super.key});
  @override
  _GanpdetailsState createState() => _GanpdetailsState();
}

class _GanpdetailsState extends State<Ganpdetails> {
  static const subUnits = <String>[
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30',
    '31',
    '32',
    '33',
    '34',
    '35',
    '36',
    '37',
    '38',
    '39',
    '40',
    '41',
    '42',
    '43',
    '44',
    '45',
    '46',
    '47',
    '48',
    '49',
    '50',
  ];
  Dio dio = Dio();
  String sub = '1';
  final List<DropdownMenuItem<String>> subscrip = subUnits
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
      )
      .toList();
  double? sliderVal;
  bool favColors = false;

  @override
  void initState() {
    super.initState();
    sliderVal =
        double.parse(widget.productDetails['total_units'].toString()) -
        double.parse(widget.productDetails['invested_units'].toString());
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

    var list = context.watch<Providers>().favoritesG;
    var id = widget.productDetails["id"];
    favColors = list.any((element) => element["id"] == id);
    var itemName = widget.productDetails["name"].toString();

    int amount =
        int.parse(widget.productDetails['amount'].round().toString()) *
        int.parse(sub);
    int totalProfit =
        (int.parse(widget.productDetails['rate'].round().toString()) /
                100 *
                amount)
            .round();
    int monthlyProfit =
        (totalProfit /
                int.parse(widget.productDetails['months'].round().toString()))
            .round();
    int returns = amount + totalProfit;

    List<int> values = [amount, totalProfit, monthlyProfit, returns];

    return Scaffold(
      bottomNavigationBar: const BottomNav(2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 25,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.productDetails['name']}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: favColors
                ? Image.asset(
                    'assets/images/favourite-red.png',
                    color: Theme.of(context).primaryColor,
                  )
                : Image.asset('assets/images/favourite.png'),
            onPressed: () async {
              var url3 = "$baseUrl/app/acquisition/favourite/ganp";
              Fluttertoast.showToast(
                msg: !favColors ? "Adding Asset" : "Removing Asset",
              );
              var url = !favColors
                  ? '$baseUrl/app/acquisition/favourite/$id?acquisition=gaoajkjxjnjzsbdhankdxmp_ashdhshbsed&signature=ahgfhagbhgsbhgsbyuhjwgs65wytgv7wystdg6tygfvdtydgvgyhdnxngb'
                  : "$baseUrl/app/acquisition/favourite/$id?acquisition=gaoajkjxjnjzsbdaahgs_rmzojickjnsjz&signature=ahgfhagbhgsbhgsbyuhjwgs65wytgv7wystdg6tygfvdtydgvgyhdnxngb";
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
              context.read<Providers>().setFavoritesG(
                response3.data["cultivations"],
              );

              Fluttertoast.showToast(
                msg: favColors ? "Removed Successfully" : "Added Successfully",
              );

              setState(() {
                favColors = !favColors;
              });
            },
          ),
          IconButton(
            icon: Image.asset(
              'assets/images/share.png',
              color: Colors.black,
              // height: height * .03,
            ),
            onPressed: () {
              // Share.share(
              //     '$shareBase/acquisition/asset/ganp/${id}_${itemName.split(" ").first}');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: height * .02),
              // Text(
              //     'Returns: ${widget.productDetails['currency'].toString().substring(0, 1)}$returns'
              //         .replaceAllMapped(
              //             new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              //             (Match m) => '${m[1]},'),
              //     style: TextStyle(
              //       fontWeight: FontWeight.bold,
              //       fontSize: width * .06,
              //     )),
              SizedBox(height: height * .02),
              Container(
                margin: EdgeInsets.symmetric(horizontal: width * .04),
                padding: EdgeInsets.symmetric(
                  vertical: height * .01,
                  horizontal: width * .04,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.grey, blurRadius: 5),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(height: height * .01),
                    SizedBox(
                      height: height * .27,
                      child: InkWell(
                        onTap: () {},
                        child: CachedNetworkImage(
                          imageUrl:
                              '$hubImageUrl/storage${widget.productDetails['image2'].toString().substring(6)}',
                          progressIndicatorBuilder: (context, url, progress) =>
                              Center(
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
                    SizedBox(height: height * .02),
                    Text(
                      '${widget.productDetails['name']} Illustration and Intelligence Report',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: width * .06,
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Select you subscription unit'),
                    ),
                    SizedBox(height: height * .005),
                    Container(
                      padding: EdgeInsets.only(
                        left: width * .015,
                        right: width * .015,
                      ),
                      width: width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(width * .01),
                        color: Colors.grey[100],
                        border: Border.all(),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          focusColor: Theme.of(context).primaryColor,
                          value: sub,
                          items: subscrip,
                          onChanged: (subval) {
                            print("unit: $subval");
                            setState(() {
                              sub = subval!;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: height * .04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subscription Units',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: width * .04,
                          ),
                        ),
                        Text(
                          'Amount',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: width * .04,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * .005),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          sub,
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: width * .035,
                          ),
                        ),
                        Text(
                          '${widget.productDetails['currency'].toString().substring(0, 1)}$amount'
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              ),
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: width * .035,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * .02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Term',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: width * .04,
                          ),
                        ),
                        Text(
                          'Returns',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: width * .04,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * .005),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.productDetails['months']} months',
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: width * .035,
                          ),
                        ),
                        Text(
                          '${widget.productDetails['currency'].toString().substring(0, 1)}$returns'
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              ),
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: width * .035,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * .02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Profit',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: width * .04,
                          ),
                        ),
                        Text(
                          'Rate',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: width * .04,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * .005),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.productDetails['currency'].toString().substring(0, 1)}$totalProfit'
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              ),
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: width * .035,
                          ),
                        ),
                        Text(
                          '${widget.productDetails['rate']}%',
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: width * .035,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * .02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Frequency',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: width * .04,
                          ),
                        ),
                        Wrap(
                          direction: Axis.vertical,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: [
                            Text(
                              'Equivalent Monthly',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: width * .04,
                              ),
                            ),
                            Text(
                              'Income',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: width * .04,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: height * .005),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.productDetails['max_pay']}',
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: width * .035,
                          ),
                        ),
                        Text(
                          '${widget.productDetails['currency'].toString().substring(0, 1)}$monthlyProfit'
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              ),
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: width * .035,
                          ),
                        ),
                      ],
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Confirmganp(
                              widget.productDetails,
                              values,
                              int.parse(sub),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: height * .01,
                          horizontal: width * .01,
                        ),
                        child: Text(
                          'Subscribe',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * .04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * .03),
              Text(
                'Units Remaining: ${sliderVal!.round()}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: width * .05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height * .03),
              Slider(
                value: sliderVal!,
                min: 0,
                max: widget.productDetails['total_units'].toDouble(),
                activeColor: Theme.of(context).primaryColor,
                onChanged: (_) {},
              ),
              SizedBox(height: height * .03),
              ExpandablePanel(
                header: Card(
                  color: Theme.of(context).colorScheme.secondary,
                  elevation: 5,
                  child: ListTile(
                    trailing: Image.asset(
                      'assets/images/chevron_down.png',
                      height: width * .04,
                    ),
                    title: Text(
                      'Summary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * .04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                collapsed: const SizedBox.shrink(),
                expanded: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * .02,
                    vertical: height * .01,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(width * .01),
                      bottomRight: Radius.circular(width * .01),
                    ),
                  ),
                  child: Text(
                    '${widget.productDetails['summary']}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: width * .035,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              ExpandablePanel(
                header: Card(
                  color: Theme.of(context).colorScheme.secondary,
                  elevation: 5,
                  child: ListTile(
                    trailing: Image.asset(
                      'assets/images/chevron_down.png',
                      height: width * .04,
                    ),
                    title: Text(
                      'View Intelligence Report',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * .04,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                collapsed: const SizedBox.shrink(),
                expanded: Container(
                  height: height * .05,
                  padding: EdgeInsets.only(left: width * .03),
                  child: Text('Available Upon Request'),
                ),
              ),
              // ExpandablePanel(
              //   header: Card(
              //     color: Theme.of(context).accentColor,
              //     elevation: 5,
              //     child: ListTile(
              //       trailing: Image.asset(
              //         'assets/images/chevron_down.png',
              //         height: width * .04,
              //       ),
              //       title: Text(
              //         'Sight & Sound',
              //         style: TextStyle(
              //             color: Colors.white,
              //             fontSize: width * .04,
              //             fontWeight: FontWeight.bold),
              //       ),
              //     ),
              //   ),
              //   // ignore: deprecated_member_use
              //   hasIcon: false,
              //   expanded: Container(
              //     child: Text(
              //       '',
              //       style:
              //           TextStyle(color: Colors.black, fontSize: width * .035),
              //       textAlign: TextAlign.justify,
              //     ),
              //     padding: EdgeInsets.symmetric(
              //         horizontal: width * .02, vertical: height * .01),
              //     decoration: BoxDecoration(
              //         color: Colors.grey[200],
              //         borderRadius: BorderRadius.only(
              //             bottomLeft: Radius.circular(width * .01),
              //             bottomRight: Radius.circular(width * .01))),
              //   ),
              // ),
              SizedBox(height: height * .03),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Confirmganp(
                        widget.productDetails,
                        values,
                        int.parse(sub),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: height * .01,
                    horizontal: width * .01,
                  ),
                  child: Text(
                    'Subscribe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * .04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * .03),
            ],
          ),
        ),
      ),
    );
  }
}
