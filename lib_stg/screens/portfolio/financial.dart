import 'package:GapHub/screens/portfolio/charts/financumuchart.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import './charts/finanexpenchart.dart';

class Financial extends StatefulWidget {
  final Map data;
  final String type;
  final String id;

  const Financial({
    super.key,
    required this.data,
    required this.type,
    required this.id,
  });
  @override
  _FinancialState createState() => _FinancialState();
}

class _FinancialState extends State<Financial> {
  List<BarChartGroupData> showingBarExpen = [];
  List<BarChartGroupData> rawBarExpen = [];
  List<BarChartGroupData> showingBarCumu = [];
  List<BarChartGroupData> rawBarCumu = [];
  List names1 = ["Management", "Taxes", "Maintenance", "Others"];
  List names2 = ["Revenue", "Expenditure", "Net Income"];
  List colors = [
    0xff479CC6,
    0xffBBC3A4,
    0xffFF8F28,
    0xff414141,
    0xff77A2BB,
    0xffE28394,
  ];
   Color color1 = Color(0xff479CC6);
   Color color2 = Color(0xffBBC3A4);
   Color color3 = Color(0xffFF8F28);
   Color color4 = Color(0xff414141);

  List<TableRow> expenInfo = [];
  List<TableRow> cumuInfo = [];

  var d = DateFormat.yMMMM();
  var mgtTotal = 0;
  var taxTotal = 0;
  var mtnTotal = 0;
  var othersTotal = 0;
  int length = 0;
  var revTotal = 0;
  var expenTotal = 0;
  var netTotal = 0;
  List cumu = [];
  List mgnt = [];
  List taxes = [];
  List mtn = [];
  List others = [];
  List labels = [];
  int bigNumCumu = 0;
  int bigNumCum = 0;
  int lengthCumu = 0;
  int bigNumExpen = 0;
  int lengthExpen = 0;
  var currency;
  int m = 0;
  int c = 0;
  int t = 0;
  int o = 0;

  @override
  void initState() {
    super.initState();
    imgurl = widget.data['data']['asset']["photo_url"];
    List<dynamic> financialData = widget.data["data"]["asset_financial"];
    print('financialData:$financialData');
    length = financialData.length;
    print('financialDatalength:$length');

    var parts = widget.data['data']["asset"]["asset_currency"].toString().split(
      " ",
    );
    currency = parts[0];
    cumu = widget.data['data']["asset_financial_record"]["curriculum"];
    mgnt = widget.data['data']["asset_financial_record"]["management"];
    taxes = widget.data['data']["asset_financial_record"]["taxes"];
    mtn = widget.data['data']["asset_financial_record"]["maintenance"];
    others = widget.data['data']["asset_financial_record"]["others"];
    labels =
        widget.data['data']["asset_financial_record"]["expenditure_labels"];

    lengthCumu = cumu.length;
    lengthExpen = mgnt.length;
    if (cumu.isNotEmpty) {
      bigNumCum = cumu.reduce((curr, next) => curr > next ? curr : next);
    }
    print("mgnt:$mgnt");

    if (mgnt.isNotEmpty) {
      // Convert the list of strings to a list of integers
      List<int> mgntInt = mgnt.map((e) => int.tryParse(e) ?? 0).toList();
      m = mgntInt.reduce((curr, next) => curr > next ? curr : next);
    }

    if (taxes.isNotEmpty) {
      List<int> taxesInt = taxes.map((e) => int.tryParse(e) ?? 0).toList();
      t = taxesInt.reduce((curr, next) => curr > next ? curr : next);
    }
    if (mtn.isNotEmpty) {
      List<int> mtnInt = mtn.map((e) => int.tryParse(e) ?? 0).toList();
      c = mtnInt.reduce((curr, next) => curr > next ? curr : next);
    }

    if (others.isNotEmpty) {
      List<int> othersInt = others.map((e) => int.tryParse(e) ?? 0).toList();
      o = othersInt.reduce((curr, next) => curr > next ? curr : next);
    }

    var l = [m, t, c, o];
    var bigNumExpe = l.reduce((curr, next) => curr > next ? curr : next);

    if (bigNumCum >= 0 && bigNumCum <= 100) {
      bigNumCumu = 100;
    } else if (bigNumCum >= 101 && bigNumCum <= 1000) {
      bigNumCumu = 1000;
    } else if (bigNumCum >= 1001 && bigNumCum <= 10000) {
      bigNumCumu = 10000;
    } else if (bigNumCum >= 10001 && bigNumCum <= 100000) {
      bigNumCumu = 100000;
    } else if (bigNumCum >= 100001 && bigNumCum <= 1000000) {
      bigNumCumu = 1000000;
    } else if (bigNumCum >= 1000001 && bigNumCum <= 100000000) {
      bigNumCumu = 100000000;
    } else if (bigNumCum >= 100000001 && bigNumCum <= 1000000000) {
      bigNumCumu = 1000000000;
    } else {
      bigNumCumu = bigNumCum;
    }

    if (bigNumExpe >= 0 && bigNumExpe <= 100) {
      bigNumExpen = 100;
    } else if (bigNumExpe >= 101 && bigNumExpe <= 1000) {
      bigNumExpen = 1000;
    } else if (bigNumExpe >= 1001 && bigNumExpe <= 10000) {
      bigNumExpen = 10000;
    } else if (bigNumExpe >= 10001 && bigNumExpe <= 100000) {
      bigNumExpen = 100000;
    } else if (bigNumExpe >= 100001 && bigNumExpe <= 1000000) {
      bigNumExpen = 1000000;
    } else if (bigNumExpe >= 1000001 && bigNumExpe <= 100000000) {
      bigNumExpen = 100000000;
    } else if (bigNumExpe >= 100000001 && bigNumExpe <= 1000000000) {
      bigNumExpen = 1000000000;
    } else {
      bigNumExpen = bigNumExpe;
    }
    final barCum0 = makeCumu(1, 0, const Color(0xffffffff));
    List<BarChartGroupData> itemsExpen = [];
    List<BarChartGroupData> itemsCumu = [barCum0];

    for (var i = 0; i < lengthCumu; i++) {
      itemsCumu.add(
        makeCumu(
          i + 1,
          bigNumCumu == 0 ? 0 : (cumu[i] / bigNumCumu) * 5,
          Color(colors[i]),
        ),
      );
    }
    itemsCumu.add(makeCumu(lengthCumu + 1 + 1, 0, const Color(0xffffffff)));

    for (var i = 0; i < lengthExpen; i++) {
      itemsExpen.add(
        makeExpen(
          i + 1,
          bigNumCumu == 0 ? 0 : (int.tryParse(mgnt[i]) ?? 0) / bigNumExpen * 5,
          bigNumCumu == 0 ? 0 : (int.tryParse(taxes[i]) ?? 0) / bigNumExpen * 5,
          bigNumCumu == 0 ? 0 : (int.tryParse(mtn[i]) ?? 0) / bigNumExpen * 5,
          bigNumCumu == 0
              ? 0
              : (int.tryParse(others[i]) ?? 0) / bigNumExpen * 5,
        ),
      );
    }

    rawBarExpen = itemsExpen;

    showingBarExpen = rawBarExpen;

    rawBarCumu = itemsCumu;

    showingBarCumu = rawBarCumu;
  }

  var imgurl;

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    Future getImgx() async {
      return Image.network(
        imgurl,
        width: width * .5,
        height: width * .5,
        fit: BoxFit.cover,
      );
    }

    Future<String> getImg() async {
      return imgurl;
    }

    List listCumu = [];
    if (bigNumCumu != 0) {
      for (var i = 0; i < 6; i++) {
        listCumu.add((bigNumCumu / 5) * i);
      }
    } else {
      listCumu = [0, 0, 0, 0, 0, 0];
    }

    List listExpen = [];
    if (bigNumExpen != 0) {
      for (var i = 0; i < 6; i++) {
        listExpen.add((bigNumExpen / 5) * i);
      }
    } else {
      listExpen = [0, 0, 0, 0, 0, 0];
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffffffff),
        leading: IconButton(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            imgurl != imgPrefixAssets
                ? FutureBuilder<String>(
                    future: getImg(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          width: width * .1,
                          height: width * .1,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 1),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return SizedBox(
                          width: width * .1,
                          height: width * .1,
                          child: Icon(Icons.portrait, size: width * .08),
                        );
                      } else if (snapshot.hasData) {
                        return ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: imgurl,
                            imageBuilder: (context, imageProvider) {
                              return Container(
                                width: width * .1,
                                height: width * .1,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                            placeholder: (context, url) => SizedBox(
                              width: width * .1,
                              height: width * .1,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 0.5,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.portrait, size: width * .08),
                          ),
                        );
                      } else {
                        return SizedBox(
                          width: width * .1,
                          height: width * .1,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 1),
                          ),
                        );
                      }
                    },
                  )
                : ClipOval(
                    child: Image.asset(
                      'assets/images/add_photo.jpg',
                      width: width * .1,
                      height: width * .1,
                      fit: BoxFit.cover,
                    ),
                  ),
            SizedBox(
              width: width * .03,
            ), // Increased spacing for better visuals
            Expanded(
              child: Text(
                "${widget.data['data']["asset"]["name"]}",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: width * .045,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2, // Ensures text wraps on smaller screens
                overflow: TextOverflow.ellipsis, // Adds ellipsis for long text
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.edit, color: Color(0xff808080)),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(3),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * .04,
          vertical: height * .01,
        ),
        child: ListView(
          children: [
            Row(
              children: [
                Text(
                  "Expenditure Information".toUpperCase(),
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 15.sp),
                ),
              ],
            ),
            Finanexpenchart(
              data: widget.data,
              xAxis: labels,
              currency: currency,
              type: widget.type,
              id: widget.id,
              // yAxis: listExpen,
              length: 4,
              //showingBarGroups: showingBarExpen?.reversed?.toList(),
              showingBarGroups: showingBarExpen.toList(),
              // names: names1
            ),
            SizedBox(height: height * .02),
            Row(
              children: [
                Text(
                  "Cumulative Income".toUpperCase(),
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: width * .045),
                ),
              ],
            ),
            Financumuchart(
              data: widget.data,
              xAxis: labels,
              // yAxis: listCumu,
              currency: currency,
              type: widget.type,
              id: widget.id,
              // showingBarGroups: showingBarCumu,
              // names: names2,
              length: 3,
            ),
            SizedBox(height: height * .02),
            SizedBox(height: height * .03),
          ],
        ),
      ),
    );
  }

  BarChartGroupData makeExpen(
    int x,
    double y1,
    double y2,
    double y3,
    double y4,
  ) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          borderRadius: BorderRadius.zero,
          toY: y1,
          color: color1,
          width: 8,
        ),
        BarChartRodData(
          borderRadius: BorderRadius.zero,
          toY: y2,
          color: color2,
          width: 8,
        ),
        BarChartRodData(
          borderRadius: BorderRadius.zero,
          toY: y3,
          color: color3,
          width: 8,
        ),
        BarChartRodData(
          borderRadius: BorderRadius.zero,
          toY: y4,
          color: color4,
          width: 8,
        ),
      ],
    );
  }

  BarChartGroupData makeCumu(int x, double y1, Color barColor) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          borderRadius: BorderRadius.zero,
          toY: y1,
          color: barColor,
          width: 10,
        ),
      ],
    );
  }
}

class Tabledata2 extends StatelessWidget {
  const Tabledata2({
    super.key,
    required this.text,
    required this.thick,
    this.big = false,
    this.boxColor = Colors.white,
  });

  final String text;
  final bool thick;
  final Color boxColor;
  final bool big;

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Container(
      color: boxColor,
      padding: const EdgeInsets.all(5.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: big ? width * .027 : width * .035,
          fontWeight: thick ? FontWeight.w700 : FontWeight.w300,
        ),
      ),
    );
  }
}
