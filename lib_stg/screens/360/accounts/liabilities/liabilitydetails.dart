import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/screens/360/threesixty.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/clock_widget.dart';
import 'package:GapHub/widgets/piechart.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import '../../components/addAccountBtn.dart';
import 'liabilityitem.dart';
import 'liarchives.dart';

class Liabilitydetails extends StatefulWidget {
  final List liabilityData;
  final Map liabilityDataLite;
  final List seveng;
  final List bespokes;

  const Liabilitydetails({
    super.key,
    required this.liabilityData,
    required this.liabilityDataLite,
    required this.seveng,
    required this.bespokes,
  });

  @override
  _LiabilitydetailsState createState() => _LiabilitydetailsState();
}

class _LiabilitydetailsState extends State<Liabilitydetails> {
  final Dio dio = Dio();
  final DialogBox dialogBox = DialogBox();
  List<String> colors = [
    "0XFF581845",
    "0XFFFF5733",
    "0XFFFFC300",
    "0XFFDAF7A6",
    "0XFF2471A3",
    "0XFF148F77",
    "0XFF7D6608",
    "0XFF17202A",
    "0XFFFFC300",
    '0xffED3237',
    '0xff494949',
    '0xff000000',
  ];
  List liabilityData = [];

  @override
  void initState() {
    super.initState();
    // Initialize liabilityData with a copy of widget.liabilityData
    liabilityData = List.from(widget.liabilityData);
    // Modify the local copy
    liabilityData.removeWhere(
      (element) => element["credit_id"].toString() == "1",
    );
  }

  Widget _popUpMenu() {
    return PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(value: 1, child: Text('View Archived Accounts')),
      ],
      icon: const Icon(Icons.list),
      onSelected: (value) async {
        dialogBox.waiting(context, "Opening");
        var url = "$baseUrl/app/360/liability?archive=all";
        final prefs = await SharedPreferences.getInstance();
        var token = prefs.getString('tokenDB');
        try {
          var response = await dio.get(
            url,
            options: Options(headers: {"Authorization": 'Bearer $token'}),
          );
          if (response.statusCode == 200) {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Liarchives(response.data),
              ),
            );
          } else {
            Navigator.pop(context);
            Fluttertoast.showToast(
              backgroundColor: Colors.red,
              textColor: Colors.white,
              msg: 'Failed to load archived accounts.',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          }
        } catch (e) {
          Navigator.pop(context);
          Fluttertoast.showToast(
            backgroundColor: Colors.red,
            textColor: Colors.white,
            msg: 'An error occurred. Please try again.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      },
    );
  }

  String currency(int index, List list) {
    if (list.isNotEmpty) {
      String currency = list[index]["currency"].toString();
      return splitit(currency);
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    print("liabilityData2:${widget.liabilityData}");

    final orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    var liabilityDataLite = widget.liabilityDataLite;
    var seveng = widget.seveng.where((ob) => ob["isArchive"] == 0).toList();
    var bespokes = widget.bespokes.where((ob) => ob["isArchive"] == 0).toList();
    String currency1 = context.watch<Providers>().snapshotmodel.currency;
    print("liabilityData:$liabilityData");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Liabilities',
          style: TextStyle(fontSize: width * .035, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNav(4),
      body: ListView(
        children: [
          SizedBox(height: height * .01),
          Center(
            child: Text(
              "Liabilities: $currency1${liabilityDataLite["sum"].toStringAsFixed(2)}"
                  .replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  ),
              style: TextStyle(
                fontSize: width * .06,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: height * .01),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * .02,
                vertical: height * .02,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width * .01),
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                child: Text(
                  "Here is an aggregation of all the money you owe others.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: width * .04,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: height * .03),
          Center(
            child: Text(
              "List of Liabilities Accounts",
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontSize: width * .06,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(height: height * .01),
          Visibility(
            visible: widget.liabilityData.isEmpty,
            child: SizedBox(
              height: height * .08,
              child: Card(
                elevation: 5,
                color: Theme.of(context).colorScheme.secondary,
                child: Center(
                  child: Text(
                    "No Liability Account added yet",
                    style: TextStyle(
                      fontSize: width * .055,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildLiabilityList(seveng, "seveng", width, height),
          _buildLiabilityList(bespokes, "bespokes", width, height),
          _buildLiabilityList(
            widget.liabilityData,
            "liabilityData",
            width,
            height,
          ),
          _buildPieChartSection(liabilityDataLite, width, height),
          // Text('liabilityData:${widget.liabilityData.toString()}'),
          SizedBox(height: height * .05),
          const ClockWidget(2),
          SizedBox(height: height * .05),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * .2),
            child: const Addaccountbtn(index: "Liabilities"),
          ),
          SizedBox(height: height * .05),
        ],
      ),
    );
  }

  Widget _buildPieChartSection(
    Map liabilityDataLite,
    double width,
    double height,
  ) {
    if (widget.liabilityData.isEmpty &&
            widget.seveng.isEmpty &&
            widget.bespokes.isEmpty ||
        (widget.liabilityDataLite["values"].length == 1 &&
            widget.liabilityDataLite["values"][0] == 0)) {
      return Container();
    }

    return Column(
      children: [
        SizedBox(height: height * .05, child: const Divider(thickness: 2)),
        Center(
          child: Text(
            "Liabilities Distribution",
            style: TextStyle(
              fontSize: width * .06,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Piechart(
          labels: liabilityDataLite["labels"],
          values: (liabilityDataLite["values"] as List)
              .map((value) => double.tryParse(value.toString()) ?? 0.0)
              .toList(),
          percent: (liabilityDataLite["percentages"] as List)
              .map((percent) => double.tryParse(percent.toString()) ?? 0.0)
              .toList(),
          colors: colors,
        ),
      ],
    );
  }

  Widget _buildLiabilityList(
    List list,
    String type,
    double width,
    double height,
  ) {
    if (list.isEmpty) return Container();

    return ListView.builder(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .02),
        child: LiabilityListItem(
          item: list[index],
          // color: Color(int.parse(colors[index])),
          color: Color(int.parse(colors[index % colors.length])),

          isBespoke: type == "bespokes",
          onTap: () {
            var zeroBalance = list[index]['current'] == 0;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Liabilityitem(
                  item: list[index],
                  zeroBalance: zeroBalance,
                  seven: type == "seveng",
                  bespokes: type == "bespokes",
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LiabilityListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final Color color;
  final bool isBespoke;
  final Function onTap;

  const LiabilityListItem({
    super.key,
    required this.item,
    required this.color,
    this.isBespoke = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Card(
      color: const Color(0xff989898),
      elevation: 3,
      child: InkWell(
        onTap: () => onTap(),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(height: height * .07, color: color),
            ),
            Expanded(
              flex: 40,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: width * .03),
                height: height * .07,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    "${item[isBespoke ? "kpi_name" : "creditor_name"]} - ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: width * .04,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text:
                                    "${item[isBespoke ? 'dept_types' : 'account_type']} - ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: width * .04,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              TextSpan(
                                text:
                                    "${splitit(item[isBespoke ? "account_currency" : "currency"])}${item["current"]}"
                                        .replaceAllMapped(
                                          RegExp(
                                            r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                          ),
                                          (Match m) => '${m[1]},',
                                        ),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: width * .04,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/images/chevron_right.png',
                        height: width * .05,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
