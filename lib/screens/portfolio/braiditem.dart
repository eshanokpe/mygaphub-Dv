import 'dart:async';
import 'dart:io';
import 'package:GapHub/models/snapshotmodel.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:GapHub/widgets/plus_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'charts/itemshealthchart.dart';
import 'charts/assetvaluechart.dart';
import 'package:flutter/services.dart';
import 'charts/netincomechart.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'braidetails.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'summary.dart';
import 'financial.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:provider/provider.dart';

import 'braidItem/edit_braiditem.dart';
import 'braidItem/update_record.dart';
import 'widget/archived_bottom_sheet.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class Braiditem extends StatefulWidget {
  final String? id;
  final String? type;
  final Map data;
  final bool archived;

  const Braiditem({
    super.key,
    this.id,
    required this.data,
    this.type,
    this.archived = false,
  });
  @override
  _BraiditemState createState() => _BraiditemState();
}

class _BraiditemState extends State<Braiditem> {
  String? createdAt;
  TextEditingController name = TextEditingController();
  TextEditingController docName = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController revenue = TextEditingController();
  TextEditingController expenditure = TextEditingController();
  TextEditingController mngtFees = TextEditingController();
  TextEditingController taxes = TextEditingController();
  TextEditingController mtnCost = TextEditingController();
  TextEditingController mtnDetails = TextEditingController();
  TextEditingController others = TextEditingController();
  TextEditingController otherNotes = TextEditingController();
  TextEditingController income = TextEditingController();
  TextEditingController value = TextEditingController();
  TextEditingController description = TextEditingController();
  DialogBox dialogBox = DialogBox();
  final Color leftBarColorHealth = const Color(0xff479CC6);
  final Color centerBarColorHealth = const Color(0xffBBC3A4);
  final Color rightBarColorHealth = const Color(0xffFF8F28);

  bool enable = false;
  bool editing = true;
  bool update = false;
  final double width0 = 8;
  final double width1 = 30;
  final double width2 = 30;

  final picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  bool _saveNote = false;
  File? _image;
  Dio dio = Dio();
  File? imagePlaceHolder;
  FilePickerResult? result;
  File? _file;
  var document1;
  var document2;
  var document3;
  var document4;
  var document5;
  var document6;
  var document7;
  var document8;
  List documents = [];
  String updateDate = "";
  DateTime selectedDate = DateTime.now();
  // List<dynamic> incom = [];
  List<dynamic> valu = [];
  List<dynamic> net = [];
  List<dynamic> expe = [];
  List<dynamic> rev = [];
  double bigNumIncome = 0;
  double bigNumIncom = 0;
  int lengthIncome = 0;
  double bigNumValue = 0;
  double bigNumValu = 0;

  int lengthValue = 0;
  double bigNumHealth = 0;
  double bigNumHealt = 0;

  int lengthHealth = 0;
  var namea = "";
  List labels = [];
  double r = 0;
  double e = 0;
  double n = 0;
  int _radioValue = 0;

  String asset = '-Select-';

  launchDocu(String url) async {
    var url0 = url;
    await canLaunch(url0) ? launch(url0) : Fluttertoast.showToast(msg: 'Error');
  }

  var imgurl;
  List<BarChartGroupData> showingBarGroupsHealth = [];
  List<BarChartGroupData> rawBarGroupsHealth = [];

  List<BarChartGroupData> showingBarGroupsIncome = [];
  List<BarChartGroupData> rawBarGroupsIncome = [];

  List<BarChartGroupData> showingBarGroupsValue = [];
  List<BarChartGroupData> rawBarGroupsValue = [];

  var d = DateFormat.yMMMM();

  bool notes = false;
  @override
  void initState() {
    super.initState();
    print('widget:${widget.id}');
    print("data:${widget.data}");

    print(
      "assetType:${widget.data["data"]['asset_financial_detail']['asset_values:']}",
    );
    valu = widget.data['data']["asset_financial_detail"]["asset_values"];
    rev = widget.data['data']["asset_financial_detail"]["revenue"];
    expe = widget.data['data']["asset_financial_detail"]["expenditure"];
    net = widget.data['data']["asset_financial_detail"]["net"];
    lengthIncome = net.length;
    lengthHealth = rev.length;
    if (rev.isNotEmpty) {
      if (rev.length == 1) {
        r = double.parse(rev[0].toString());
      } else {
        r = rev.reduce(
          (curr, next) => curr > next
              ? double.parse(curr.toString())
              : double.parse(next.toString()),
        );
      }
    }
    if (expe.isNotEmpty) {
      if (expe.length == 1) {
        e = double.parse(expe[0].toString());
      } else {
        e = expe.reduce(
          (curr, next) => curr > next
              ? double.parse(curr.toString())
              : double.parse(next.toString()),
        );
      }
    }
    if (net.isNotEmpty) {
      if (net.length == 1) {
        n = double.parse(net[0].toString());
      } else {
        n = net.reduce(
          (curr, next) => curr > next
              ? double.parse(curr.toString())
              : double.parse(next.toString()),
        );
      }
    }
    var l = [r, e, n];
    bigNumHealt = l.reduce((curr, next) => curr > next ? curr : next);
    lengthValue = valu.length;
    if (net.isNotEmpty) {
      if (net.length == 1) {
        bigNumIncom = double.parse(net[0].toString());
      } else {
        bigNumIncom = net.reduce(
          (curr, next) => curr > next
              ? double.parse(curr.toString())
              : double.parse(next.toString()),
        );
      }
    }
    if (valu.isNotEmpty) {
      if (valu.length == 1) {
        bigNumValu = double.parse(valu[0].toString());
      } else {
        bigNumValu = valu.reduce(
          (curr, next) => curr > next
              ? double.parse(curr.toString())
              : double.parse(next.toString()),
        );
      }
    }

    if (bigNumHealt >= 0 && bigNumHealt <= 100) {
      bigNumHealth = 100;
    } else if (bigNumHealt >= 101 && bigNumHealt <= 1000) {
      bigNumHealth = 1000;
    } else if (bigNumHealt >= 1001 && bigNumHealt <= 10000) {
      bigNumHealth = 10000;
    } else if (bigNumHealt >= 10001 && bigNumHealt <= 100000) {
      bigNumHealth = 100000;
    } else if (bigNumHealt >= 100001 && bigNumHealt <= 1000000) {
      bigNumHealth = 1000000;
    } else if (bigNumHealt >= 1000001 && bigNumHealt <= 10000000) {
      bigNumHealth = 10000000;
    } else if (bigNumHealt >= 10000001 && bigNumHealt <= 100000000) {
      bigNumHealth = 100000000;
    } else {
      bigNumHealth = bigNumHealt;
    }

    if (bigNumIncom >= 0 && bigNumIncom <= 100) {
      bigNumIncome = 100;
    } else if (bigNumIncom >= 101 && bigNumIncom <= 1000) {
      bigNumIncome = 1000;
    } else if (bigNumIncom >= 1001 && bigNumIncom <= 10000) {
      bigNumIncome = 10000;
    } else if (bigNumIncom >= 10001 && bigNumIncom <= 100000) {
      bigNumIncome = 100000;
    } else if (bigNumIncom >= 100001 && bigNumIncom <= 1000000) {
      bigNumIncome = 1000000;
    } else if (bigNumIncom >= 1000001 && bigNumIncom <= 10000000) {
      bigNumIncome = 10000000;
    } else if (bigNumIncom >= 10000001 && bigNumIncom <= 100000000) {
      bigNumIncome = 100000000;
    } else {
      bigNumIncome = bigNumIncom;
    }

    if (bigNumValu >= 0 && bigNumValu <= 100) {
      bigNumValue = 100;
    } else if (bigNumValu >= 101 && bigNumValu <= 1000) {
      bigNumValue = 1000;
    } else if (bigNumValu >= 1001 && bigNumValu <= 10000) {
      bigNumValue = 10000;
    } else if (bigNumValu >= 10001 && bigNumValu <= 100000) {
      bigNumValue = 100000;
    } else if (bigNumValu >= 100001 && bigNumValu <= 1000000) {
      bigNumValue = 1000000;
    } else if (bigNumValu >= 1000001 && bigNumValu <= 10000000) {
      bigNumValue = 10000000;
    } else if (bigNumValu >= 10000001 && bigNumValu <= 100000000) {
      bigNumValue = 100000000;
    } else {
      bigNumValue = bigNumValu;
    }
    labels =
        widget.data['data']["asset_financial_detail"]["expenditure_labels"];

    var data = widget.data['data']["asset"];
    print("dataRevenue11:${data['average_revenue']}");
    print("location:${data['location']}");
    name.text = data["name"];
    asset = data["portfolio_type"] ?? '-Select-';
    // _radioValue = data["automated"] ?? 0;
    _radioValue = int.tryParse(data["automated"] ?? '0') ?? 0;

    address.text = data["location"] ?? "";
    createdAt = data["created_at"];

    value.text = data["asset_value"].toString();
    income.text = data["monthly_roi"].toString();
    description.text = data["description"];
    document1 = data["document1"];
    expenditure.text =
        (data['average_value'] != null && data['average_value'] is num)
        ? data['average_value'].toString()
        : '0.0';
    revenue.text =
        (data['average_revenue'] != null && data['average_revenue'] is num)
        ? data['average_revenue'].toString()
        : '0.0';

    if (document1 != null) {
      documents.add(document1);
    }
    document2 = data["document2"];
    if (document2 != null) {
      documents.add(document2);
    }
    document3 = data["document3"];
    if (document3 != null) {
      documents.add(document3);
    }
    document4 = data["document4"];
    if (document4 != null) {
      documents.add(document4);
    }
    document5 = data["document5"];
    if (document5 != null) {
      documents.add(document5);
    }
    document6 = data["document6"];
    if (document6 != null) {
      documents.add(document6);
    }
    document7 = data["document7"];
    if (document7 != null) {
      documents.add(document7);
    }
    document8 = data["document8"];
    if (document8 != null) {
      documents.add(document8);
    }

    imgurl = data["photo_url"];
    print("imgurlBraid:$imgurl");
    // if (imgurl != null) {
    //   print("profile picture: $imgurl");
    //   imgurl = imgurl.replaceRange(0, 6, 'assets/storage');
    //   imgurl = '$imgPrefix/$imgurl';
    // }
    updateDate = d.format(DateTime.now());

    List<BarChartGroupData> itemsIncome = [];
    for (var i = 0; i < lengthIncome; i++) {
      itemsIncome.add(
        makeGroupDataIncome(
          i + 1,
          (bigNumIncome == 0 ? 0 : (net[i].round() / bigNumIncome) * 5) < 0
              ? 0
              : (bigNumIncome == 0 ? 0 : (net[i].round() / bigNumIncome) * 5),
        ),
      );
    }

    List<BarChartGroupData> itemsValue = [];
    for (var i = 0; i < lengthValue; i++) {
      itemsValue.add(
        makeGroupDataValue(
          i + 1,
          (bigNumValue == 0 ? 0 : (valu[i].round() / bigNumValue) * 5) < 0
              ? 0
              : (bigNumValue == 0 ? 0 : (valu[i].round() / bigNumValue) * 5),
        ),
      );
    }

    List<BarChartGroupData> itemsHealth = [];
    for (var i = 0; i < lengthHealth; i++) {
      itemsHealth.add(
        makeGroupDataHealth(
          i + 1,
          (bigNumHealth == 0 ? 0 : (rev[i].round() / bigNumHealth) * 5) < 0
              ? 0
              : (bigNumHealth == 0 ? 0 : (rev[i].round() / bigNumHealth) * 5),
          (bigNumHealth == 0 ? 0 : (expe[i].round() / bigNumHealth) * 5) < 0
              ? 0
              : (bigNumHealth == 0 ? 0 : (expe[i].round() / bigNumHealth) * 5),
          (bigNumHealth == 0 ? 0 : (net[i].round() / bigNumHealth) * 5) < 0
              ? 0
              : (bigNumHealth == 0 ? 0 : (net[i].round() / bigNumHealth) * 5),
        ),
      );
    }

    rawBarGroupsHealth = itemsHealth;
    rawBarGroupsIncome = itemsIncome;
    rawBarGroupsValue = itemsValue;

    showingBarGroupsHealth = rawBarGroupsHealth;
    showingBarGroupsIncome = rawBarGroupsIncome;
    showingBarGroupsValue = rawBarGroupsValue;
    // print("assetvalue:$itemsValue");
    getvalue();
  }

  // Convert the month name to its numerical representation
  Map<String, int> monthMap = {
    'January': 1,
    'February': 2,
    'March': 3,
    'April': 4,
    'May': 5,
    'June': 6,
    'July': 7,
    'August': 8,
    'September': 9,
    'October': 10,
    'November': 11,
    'December': 12,
  };
  Future getvalue() async {
    List<String> parts = updateDate.split(' ');
    int year = int.parse(parts[1]);
    int month = monthMap[parts[0]]!;
    // Create a DateTime object with the converted values
    DateTime convertedDate = DateTime(year, month, 1);
    String formattedDate =
        "${convertedDate.year}-${convertedDate.month.toString().padLeft(2, '0')}-01 00:00:00.000";

    print("monthhhh:$formattedDate");
    var data = widget.data['data']["asset"];
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var urlq = Uri.parse(
      "$baseUrl/app/portfolio/${data["asset_class"]}/${data["id"]}?header=ajnjxbnuhjsbxnhujbxncujhbxdcbhjnasuhjbn&access=addnewperiodadd_ajhbxsjbhnsjhbjbnsxjk&period=$formattedDate",
    );
    var response = await http.get(
      urlq,
      headers: {"Authorization": 'Bearer $token'},
    );
    print("response:${jsonDecode(response.body)}");
    // var body = jsonDecode(response.body)["asset_records"];
    var body = jsonDecode(response.body)['asset_records'] ?? [];

    mngtFees.text = "${body["management"] ?? ""}";
    taxes.text = "${body["taxes"] ?? ""}";
    mtnCost.text = "${body["maintenance"] ?? ""}";
    others.text = "${body["others"] ?? ""}";
    mtnDetails.text = body["maintenance_details"] ?? "";
    otherNotes.text = body["note"] ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<String>> assetList = asseTypes
        .map(
          (String value) => DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: MediaQuery.of(context).size.width * .04,
                color: Colors.black,
              ),
            ),
          ),
        )
        .toList();
    var data = widget.data['data']["asset"];

    var parts = data["asset_currency"].toString().split(" ");
    print("parts:${parts[0]}");
    var currency = parts[0];
    List listIncome = [];
    if (bigNumIncome != 0) {
      for (var i = 0; i < 6; i++) {
        listIncome.add((bigNumIncome / 5) * i);
      }
    } else {
      listIncome = [0, 0, 0, 0, 0, 0];
    }

    List listValue = [];
    if (bigNumValue != 0) {
      for (var i = 0; i < 6; i++) {
        listValue.add((bigNumValue / 5) * i);
      }
    } else {
      listValue = [0, 0, 0, 0, 0, 0];
    }

    List listHealth = [];
    if (bigNumHealth != 0) {
      for (var i = 0; i < 6; i++) {
        listHealth.add((bigNumHealth / 5) * i);
      }
    } else {
      listHealth = [0, 0, 0, 0, 0, 0];
    }
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

    Widget topMenu() => IconButton(
      icon: Icon(Icons.more_horiz, size: width * .07),
      onPressed: () async {
        _showBottomSheet(context, widget.type!, widget.id!);
      },
    );
    Widget topMenuArchived() => IconButton(
      icon: Icon(Icons.more_horiz, size: width * .07),
      onPressed: () async {
        ArchivedBottomSheet.show(
          context,
          widget.data,
          widget.archived,
          widget.type!,
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [widget.archived ? topMenuArchived() : topMenu()],
      ),
      bottomNavigationBar: const BottomNav(3),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .03),
        child: ListView(
          controller: _scrollController,
          children: [
            SizedBox(height: height * .01),
            Card(
              elevation: 0,
              color: AppColors.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: const BorderSide(color: Color(0xffD8D8D8), width: 0.5),
              ),
              child: Padding(
                padding: EdgeInsets.all(width * .04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        imgurl != imgPrefixAssets
                            ? FutureBuilder<String>(
                                future: getImg(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasError) {
                                    return const Center(
                                      child: Icon(Icons.portrait),
                                    );
                                  } else if (snapshot.hasData) {
                                    return ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: imgurl,
                                        imageBuilder: (context, imageProvider) {
                                          return Container(
                                            width: width * .2,
                                            height: width * .2,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                        },
                                        placeholder: (context, url) =>
                                            const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 0.5,
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.portrait),
                                      ),
                                    );
                                  } else {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                },
                              )
                            : Image.asset(
                                'assets/images/add_photo.jpg',
                                width: width * .10,
                                height: width * .10,
                                fit: BoxFit.cover,
                              ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/calander.png', // Add your Tesla logo image in assets
                              width: width * .04,
                            ),
                            SizedBox(width: width * .01),
                            Text(
                              // 'Sun, 27 April',
                              formatDate(createdAt!),
                              style: TextStyle(
                                fontSize: width * .04,
                                color: AppColors.grayColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: height * .01),
                    Text(
                      name.text,
                      style: TextStyle(
                        fontSize: width * .05,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: height * .02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Value', style: TextStyle(fontSize: width * .04)),
                        Text(
                          '$currency${double.parse(value.text).toStringAsFixed(2)}'
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              ),
                          style: TextStyle(
                            fontSize: width * .04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * .01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Income', style: TextStyle(fontSize: width * .04)),
                        Text(
                          '$currency${double.parse(income.text).toStringAsFixed(2)}'
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              ),
                          style: TextStyle(
                            fontSize: width * .04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * .01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Revenue',
                          style: TextStyle(fontSize: width * .04),
                        ),
                        Text(
                          '$currency${double.parse(revenue.text).toStringAsFixed(2)}'
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              ),
                          style: TextStyle(
                            fontSize: width * .04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * .01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Expenditure',
                          style: TextStyle(fontSize: width * .04),
                        ),
                        Text(
                          '$currency${double.parse(expenditure.text).toStringAsFixed(2)}'
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              ),
                          style: TextStyle(
                            fontSize: width * .04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * .03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/location_red.png',
                              width: width * .04,
                              height: width * .04,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: width * .01),
                            Text(
                              'Location',
                              style: TextStyle(
                                color: const Color(0xffE84141),
                                fontWeight: FontWeight.w500,
                                fontSize: width * .04,
                              ),
                            ),
                          ],
                        ),
                        address.text != ''
                            ? Text(
                                address.text,
                                style: TextStyle(
                                  fontSize: width * .04,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(
                                'No address',
                                style: TextStyle(
                                  fontSize: width * .04,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                      ],
                    ),
                    SizedBox(height: height * .02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * .0005,
                            ),
                            child: PlusButton(
                              isButtonEnabled: widget.archived,
                              color: Colors.white,
                              iconsColor: AppColors.primaryColor,
                              textColor: AppColors.blackColor,
                              icons: Icons.edit,
                              text: 'Edit Details',
                              onPressed: () {
                                navigateWithSlideTransition(
                                  context: context,
                                  destinationScreen: BaidItemEdit(
                                    imgurl: imgurl,
                                    data: widget.data,
                                    type: widget.type,
                                    id: widget.id,
                                  ),
                                  transitionDuration: const Duration(
                                    milliseconds: 200,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.02,
                        ), // Adds spacing
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: PlusButton(
                              isButtonEnabled: widget.archived,
                              color: Colors.white,
                              iconsColor: const Color(0xff009933),
                              textColor: AppColors.blackColor,
                              icons: Icons.refresh,
                              text: 'Update Record',
                              onPressed: () {
                                navigateWithSlideTransition(
                                  context: context,
                                  destinationScreen: BaidItemUpdateRecord(
                                    imgurl: imgurl,
                                    data: widget.data,
                                    name: name.text,
                                  ),
                                  transitionDuration: const Duration(
                                    milliseconds: 200,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: height * .02),
            Row(
              children: [
                Text(
                  'Asset Financial Health Chart'.toUpperCase(),
                  style: TextStyle(
                    color: const Color(0xff77839a),
                    fontSize: width * .04,
                  ),
                ),
              ],
            ),
            SizedBox(height: height * .01),
            ItemsHealthChart(
              data: widget.data,
              currency: currency,
              type: widget.type! ?? "",
              id: widget.id ?? "",
              names: labels,
            ),
            SizedBox(height: height * .03),
            Row(
              children: [
                Text(
                  'Asset Value Chart'.toUpperCase(),
                  style: TextStyle(
                    color: const Color(0xff77839a),
                    fontSize: width * .04,
                  ),
                ),
              ],
            ),
            SizedBox(height: height * .01),
            AssetValueChart(
              data: widget.data,
              id: widget.id,
              type: widget.type,
              names: labels,
            ),
            Visibility(
              visible: !widget.archived,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .02),
                child: Column(
                  children: [
                    Visibility(
                      visible: notes,
                      child: Transform.rotate(
                        angle: 5 / 360,
                        child: SizedBox(
                          width: width * .96,
                          height: height * .23,
                          // decoration: BoxDecoration(
                          //   color: Color(0xFFF3C69D),
                          // ),
                          child: Card(
                            color: const Color(0xFFF3C69D),
                            elevation: 7,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 0,
                                  ),
                                  child: Text(
                                    updateDate,
                                    style: const TextStyle(fontSize: 22),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  height: height * .11,
                                  width: double.maxFinite,
                                  child: TextFormField(
                                    expands: true,
                                    keyboardType: TextInputType.text,
                                    // initialValue: otherNotes.text.isEmpty? "" : otherNotes.text,
                                    controller: otherNotes,
                                    onTap: () {},
                                    maxLines: null,
                                    style: TextStyle(
                                      fontSize: width * .04,
                                      fontWeight: FontWeight.w300,
                                    ),
                                    enabled: _saveNote,
                                    decoration: InputDecoration(
                                      filled: true,
                                      contentPadding: EdgeInsets.all(
                                        width * .02,
                                      ),
                                      disabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          width * .02,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          width * .02,
                                        ),
                                      ),
                                      fillColor: const Color(0xFFF3C69D),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          width * .01,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: TextButton(
                                    onPressed: () => {
                                      if (_saveNote)
                                        saveNoteFun()
                                      else
                                        setState(() => _saveNote = true),
                                    },
                                    child: Text(
                                      _saveNote ? "Save" : "Edit",
                                      style: TextStyle(
                                        color: _saveNote
                                            ? Theme.of(context).primaryColor
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Container(
                            //   width: width,
                            //   color: Colors.grey
                            // )
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: notes,
                      // child: SizedBox(
                      // width: width * .8,
                      // height: height *.2,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: InkWell(
                            onTap: () => {datePickerForNote(data)},
                            child: SizedBox(
                              width: width * .5,
                              height: height * .1,
                              child: Card(
                                color: Colors.blue,
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Text(
                                        updateDate,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          height: 2,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    Positioned(
                                      // alignment: Alignment.topRight,
                                      top: -10,
                                      right: -10,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.calendar_today_outlined,
                                          size: width * .05,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          datePickerForNote(data);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: editing,
              child: Column(
                children: [
                  SizedBox(height: height * .03),
                  Row(
                    children: [
                      Text(
                        'NET INCOME CHART'.toUpperCase(),
                        style: TextStyle(
                          color: const Color(0xff77839a),
                          fontSize: width * .04,
                        ),
                      ),
                    ],
                  ),
                  NetIncomeChart(
                    // showingBarGroups: showingBarGroupsIncome,
                    // currency: currency,
                    imgurl: imgurl,
                    imgPrefixAssets: imgPrefixAssets,
                    names: labels,
                    type: widget.type!,
                    id: widget.id!,
                    data: widget.data,
                  ),
                  SizedBox(height: height * .02),
                  Row(
                    children: [
                      Text(
                        'Description'.toUpperCase(),
                        style: TextStyle(
                          color: const Color(0xff808080),
                          fontSize: width * .04,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * .01),
                  Card(
                    color: AppColors.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(
                        color: Color(0xffFAFAFA),
                        width: 0.5,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: width * .03),
                      child: Container(
                        margin: EdgeInsets.only(bottom: width * .03),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                description.text,
                                overflow: TextOverflow.clip,
                                style: TextStyle(fontSize: width * .04),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * .02),
                  Center(
                    child: Row(
                      children: [
                        Text(
                          'Uploaded Documents'.toUpperCase(),
                          style: TextStyle(
                            color: const Color(0xff808080),
                            fontSize: width * .04,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * .01),
                  Card(
                    color: AppColors.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: const BorderSide(
                        color: Color(0xffFAFAFA),
                        width: 0.5,
                      ),
                    ),
                    child: ExpandableTheme(
                      data: const ExpandableThemeData(
                        iconColor: Colors.blue,
                        useInkWell: true,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(
                          width * .02,
                        ), // Added padding for better layout
                        child: Column(
                          children: <Widget>[
                            ExpansionTile(
                              leading: Image.asset(
                                'assets/images/pdf_icon.png',
                                width: width * .10,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '${documents.length} Documents uploaded',
                                    style: TextStyle(
                                      fontSize: width * .04,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              children: <Widget>[
                                ListView.builder(
                                  itemCount: documents.length,
                                  physics: const ScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) => Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: height * .005,
                                      horizontal: width * .05,
                                    ),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/pdf1.png',
                                          width: width * .10,
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            launchDocu(
                                              "${documents[index]["document"]}",
                                            );
                                          },
                                          child: Text(
                                            "${documents[index]["name"]}",
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: width * .04,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  updateDetails(data) async {
    if (!editing) {
      FocusScope.of(context).requestFocus(FocusNode());
      if (result != null && docName.text.isEmpty) {
        dialogBox.information(
          context,
          "Status",
          "Please provide a document name",
        );
        return;
      }
      var timer = Timer(const Duration(seconds: 30), () {
        Navigator.pop(context);
        dialogBox.information(context, 'Status', 'Service timed out');
        return;
      });

      // dialogBox.waiting(context, "Saving");
      EasyLoading.show(status: 'Saving', dismissOnTap: false);
      var url = "$baseUrl/app/portfolio/update/details/${data["id"]}";
      var url0 = '$baseUrl/app/portfolio/update/photo/${data["id"]}';
      print("aldflakjsdlfjaflajsdfj${data["id"]}");
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');
      FormData? formData;
      if (_file != null) {
        String filename = _file!.path.split('/').last;
        formData = FormData.fromMap({
          "asset_document": await MultipartFile.fromFile(
            _file!.path,
            filename: filename,
          ),
          "asset_document_name": docName.text,
          "asset_name": name.text,
          "description": description.text,
          "location": address.text,
          "asset_value": value.text,
          //"income": income.text,
          // "portfolio_type": asset,
          "portfolio_type": 1,
          "automated_rate": "$_radioValue",
        });
      }

      print(
        {
          "asset_document_name": docName.text,
          "asset_name": name.text,
          "description": description.text,
          "location": address.text,
          "asset_value": value.text,
          "income": income.text,
          "portfolio_type": asset,
          "automated_rate": "$_radioValue",
        }.toString(),
      );

      Map body = {
        "asset_name": name.text,
        "asset_value": value.text,
        // "portfolio_type": asset,
        // 'portfolio_type_id': asset,
        "portfolio_type": 1,
        "automated_rate": "$_radioValue",
        "location": address.text,
        // "income": income.text,
        "description": description.text,
      };
      if (_image != null) {
        try {
          String filename = _image!.path.split('/').last;
          FormData formData = FormData.fromMap({
            "photo": await MultipartFile.fromFile(
              _image!.path,
              filename: filename,
              contentType: MediaType('image', 'jpg'),
            ),
          });

          var response2 = await dio.post(
            url0,
            data: formData,
            options: Options(
              headers: {
                "Accept": "application/json",
                "Authorization": 'Bearer ${token!}',
              },
            ),
          );
          if (response2.statusCode == 200) {
            print('res:${response2.statusCode}');

            Fluttertoast.showToast(msg: 'Images upload successful');
          } else {
            print('res:${response2.statusCode}');
            // dialogBox.information(context, "Status", 'e.toString()');
          }
        } catch (e) {
          dialogBox.information(context, "Status", e.toString());
        }
      }

      try {
        var response2 = await dio.post(
          url,
          data: _file != null ? formData : body,
          options: Options(
            headers: {
              "Accept": "application/json",
              "Authorization": 'Bearer ${token!}',
            },
          ),
        );

        if (response2.statusCode == 200) {
          var body = response2.data;
          timer.cancel();
          getItem(data["id"], data["asset_class"]);
          // Fluttertoast.showToast(msg: "Updated successfully");

          EasyLoading.dismiss();
          // dialogBox.information(context, "Status", 'Updated successfully');
          // Navigator.pop(context);
        } else {
          timer.cancel();

          Fluttertoast.showToast(msg: "Something went wrong, try again");
          EasyLoading.dismiss();
          // dialogBox.information(context, "Status", 'Something went wrong, try again');
          // Navigator.pop(context);
        }
        print("here1: ${response2.statusCode}");
      } catch (e) {
        timer.cancel();
        EasyLoading.dismiss();
        dialogBox.information(
          context,
          "Status",
          'Something went wrong, try again',
        );
        // Navigator.pop(context);
        //dialogBox.information(context, "Statuss", e.toString());
      }
    }
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastLinearToSlowEaseIn,
    );
    setState(() {
      enable = true;
      editing = false;
    });
  }

  datePickerForNote(data) {
    showMonthPicker(
      context: context,
      firstDate: DateTime(2009),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    ).then((val) async {
      Timer timer = Timer(const Duration(seconds: 40), () {
        EasyLoading.dismiss();
        return;
      });
      EasyLoading.show(status: 'Loading', dismissOnTap: false);

      var doug = DateFormat('yyyy-MM').format(val!);
      // print(DateFormat('yyyy-MM').format(val));
      var url = Uri.parse(
        "$baseUrl/app/portfolio/${data["asset_class"]}/${data["id"]}?header=ajnjxbnuhjsbxnhujbxncujhbxdcbhjnasuhjbn&access=addperiod_ajhbxsjnbjsxbnoaklmsikn&period=$doug",
      );
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');
      var response = await http.get(
        url,
        headers: {"Authorization": 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body)["asset_records"];
        if (body == null) {
          dialogBox.options(
            context,
            "New Update record",
            "The Period ${d.format(val)} records does not exist. Are you sure you want to add this period?",
            () async {
              Timer timer = Timer(const Duration(seconds: 40), () {
                EasyLoading.dismiss();
                return;
              });
              EasyLoading.show(status: 'Loading', dismissOnTap: false);
              var urlq = Uri.parse(
                "$baseUrl/app/portfolio/${data["asset_class"]}/${data["id"]}?header=ajnjxbnuhjsbxnhujbxncujhbxdcbhjnasuhjbn&access=addnewperiodadd_ajhbxsjbhnsjhbjbnsxjk&period=$doug",
              );
              var response = await http.get(
                urlq,
                headers: {"Authorization": 'Bearer $token'},
              );
              var body = jsonDecode(response.body);
              value.text = "${body["amount"] ?? ""}";
              revenue.text = "${body["revenue"] ?? ""}";
              mngtFees.text = "${body["management"] ?? ""}";
              taxes.text = "${body["taxes"] ?? ""}";
              mtnCost.text = "${body["maintenance"] ?? ""}";
              others.text = "${body["others"] ?? ""}";
              mtnDetails.text = body["maintenance_details"] ?? "";
              otherNotes.text = body["note"] ?? "";
              var dd = d.format(val);
              setState(() {
                updateDate = dd;
              });
              selectedDate = val;
              timer.cancel();
              EasyLoading.dismiss();
            },
          );
        } else {
          value.text = "${body["amount"] ?? ""}";
          revenue.text = "${body["revenue"] ?? ""}";
          mngtFees.text = "${body["management"] ?? ""}";
          taxes.text = "${body["taxes"] ?? ""}";
          mtnCost.text = "${body["maintenance"] ?? ""}";
          others.text = "${body["others"] ?? ""}";
          mtnDetails.text = body["maintenance_details"] ?? "";
          otherNotes.text = body["note"] ?? "";
          var dd = d.format(val);
          setState(() {
            updateDate = dd;
          });
          selectedDate = val;
        }
        timer.cancel();
        EasyLoading.dismiss();
      }
    });
  }

  getItem(int id, String type) async {
    Timer timer = Timer(const Duration(seconds: 40), () {
      EasyLoading.dismiss();
      return;
    });
    // EasyLoading.show(
    //   status: 'Loading',
    //   dismissOnTap: false,
    // );
    var url = Uri.parse("$baseUrl/app/portfolio/$type/$id");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    var response = await http.get(
      url,
      headers: {"Authorization": 'Bearer $token'},
    );
    // print(response.statusCode);
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Updated successfully");
      // Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Braiditem(data: jsonDecode(response.body)),
        ),
      );
      EasyLoading.dismiss();
    } else {
      Fluttertoast.showToast(msg: "Error");
    }
    timer.cancel();
    EasyLoading.dismiss();
  }

  saveNoteFun() async {
    // dialogBox.waiting(context, "Updating");
    EasyLoading.show(status: 'Loading', dismissOnTap: false);
    var url = Uri.parse(
      "$baseUrl/app/portfolio/update/note/${widget.data['data']["asset"]["id"]}",
    );
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    Map body = {
      "note": otherNotes.text,
      "period": DateFormat('y-M').format(selectedDate),
    };

    var response = await http.post(
      url,
      body: body,
      headers: {"Authorization": 'Bearer $token'},
    );
    if (response.statusCode == 200 && jsonDecode(response.body)["status"]) {
      var url = Uri.parse(
        "$baseUrl/app/portfolio/${widget.data['data']["asset"]["asset_class"]}/${widget.data['data']["asset"]["id"]}",
      );
      var response2 = await http.get(
        url,
        headers: {"Authorization": 'Bearer $token'},
      );

      // print("body: ${response2.body}");
      // print("response: ${response2.statusCode}");
      if (response2.statusCode == 200) {
        // Navigator.pop(context);
        // Navigator.pop(context);
        // Navigator.pop(context);

        setState(() {
          _saveNote = false;
          notes = false;
        });

        EasyLoading.dismiss();
        Fluttertoast.showToast(msg: "Updated Note Successfully");
      } else {
        // Navigator.pop(context);
        EasyLoading.dismiss();
        switch (response.statusCode) {
          case 400:
            Fluttertoast.showToast(
              msg: "Error: bad request",
              backgroundColor: Theme.of(context).primaryColor,
            );
            break;
          case 401:
            Fluttertoast.showToast(
              msg: "Error: Unauthorised, please login again",
              backgroundColor: Theme.of(context).primaryColor,
            );
            break;
          case 422:
            Fluttertoast.showToast(
              msg: "Error: 422, please try again later",
              backgroundColor: Theme.of(context).primaryColor,
            );
            break;
          case 500:
            Fluttertoast.showToast(
              msg: "Error: Server Error",
              backgroundColor: Theme.of(context).primaryColor,
            );
            break;
          default:
        }
      }
    } else {
      // Navigator.pop(context);
      EasyLoading.dismiss();
      switch (response.statusCode) {
        case 400:
          Fluttertoast.showToast(
            msg: "Error: bad request",
            backgroundColor: Theme.of(context).primaryColor,
          );
          break;
        case 401:
          Fluttertoast.showToast(
            msg: "Error: Unauthorised, please login again",
            backgroundColor: Theme.of(context).primaryColor,
          );
          break;
        case 422:
          Fluttertoast.showToast(
            msg: "Error: 422, please try again later",
            backgroundColor: Theme.of(context).primaryColor,
          );
          break;
        case 500:
          Fluttertoast.showToast(
            msg: "Error: Server Error",
            backgroundColor: Theme.of(context).primaryColor,
          );
          break;
        default:
      }
    }
  }

  getData(String cap, String small, bool removal) async {
    var url = Uri.parse("$baseUrl/app/portfolio/$small");
    var urlInc = "$baseUrl/app/360/income";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    var response = await http.get(
      url,
      headers: {"Authorization": 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      if (removal) {
        var responseInc = await dio.get(
          urlInc,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );

        List assets = responseInc.data["portfolio_asset"];
        List<String> listofassets = ['-Select-'];
        for (var i = 0; i < assets.length; i++) {
          if (assets[i]["isArchive"] != 1) {
            listofassets.add(
              "${assets[i]["name"]} (${assets[i]["asset_currency"]}${assets[i]["monthly_roi"].toStringAsFixed(2)})"
                  .replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  ),
            );
          }
        }
        context.read<Providers>().setAssets(listofassets);
        context.read<Providers>().setMapAsset(assets);
        var urlSnapshot = Uri.parse('$baseUrl/app/snapshot');

        final response3 = await http.get(
          urlSnapshot,
          headers: {"Authorization": 'Bearer $token'},
        );
        Snapshotmodel snapshotmodel = Snapshotmodel.fromJson(
          jsonDecode(response3.body),
        );
        context.read<Providers>().setSnapshot(snapshotmodel);
        context.read<Providers>().setCurrentPortfolio(
          snapshotmodel.financial["portfolio"],
        );

        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        if (widget.archived) {
          Navigator.pop(context);
        }
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Braidetails(cap, jsonDecode(response.body), false),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: "Error");
    }
  }

  BarChartGroupData makeGroupDataHealth(
    int x,
    double y1,
    double y2,
    double y3,
  ) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          borderRadius: BorderRadius.zero,
          toY: y1,
          color: leftBarColorHealth,
          width: width0,
        ),
        BarChartRodData(
          borderRadius: BorderRadius.zero,
          toY: y2,
          color: centerBarColorHealth,
          width: width0,
        ),
        BarChartRodData(
          borderRadius: BorderRadius.zero,
          toY: y3,
          color: rightBarColorHealth,
          width: width0,
        ),
      ],
    );
  }

  BarChartGroupData makeGroupDataValue(int x, double y1) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          borderRadius: BorderRadius.zero,
          toY: y1,
          color: const Color(0xff897C62),
          width: width1,
        ),
      ],
    );
  }

  BarChartGroupData makeGroupDataIncome(int x, double y1) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          borderRadius: BorderRadius.zero,
          toY: y1,
          color: const Color(0xFF002E77),
          // colors: [
          //   const Color(0xFF005E77),
          //   const Color(0xFF002E77),
          // ],
          width: width2,
        ),
      ],
    );
  }

  void _showPicker(
    context,
    height,
    width,
    VoidCallback getImgCam,
    VoidCallback getImgGal,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    getImgGal();
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: Text('Camera'),
                  onTap: () {
                    getImgCam();
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(height: height * .01),
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  addorremove() async {
    var timer = Timer(const Duration(seconds: 40), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, "Loading");

    var url = widget.archived
        ? "$baseUrl/app/portfolio/${widget.data['data']["asset"]["asset_class"]}/${widget.data['data']["asset"]["id"]}?header=pasjknmxjknjzkxnjxnjzhxnxcfdxajknknniojakn&access=atyhgujhashgbsxdhgvshgsghfgnbvjbsjkbvjbvjhdx&account=${widget.data['data']["asset"]["id"]}"
        : "$baseUrl/app/portfolio/${widget.data['data']["asset"]["asset_class"]}/${widget.data['data']["asset"]["id"]}?header=pasjknmxjknjzkxnjxnjzhxnxcfdxajknknniojakn&access=uyaghgbshgbhsjxbhsjxbvbhxdbvdhgbvghdvcghvgdhcvhsnbhsb&account=${widget.data['data']["asset"]["id"]}";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );

    if (response.statusCode == 200 && response.data["success"]) {
      try {
        getData(
          "${widget.data['data']["asset"]["asset_class"]}".capitalize(),
          "${widget.data['data']["asset"]["asset_class"]}",
          true,
        );
        Fluttertoast.showToast(
          msg: widget.archived
              ? "Asset unarchived successfully"
              : "Asset archived successfully",
        );
      } catch (e) {
        Navigator.pop(context);
      }
      timer.cancel();
    } else {
      timer.cancel();
      Navigator.pop(context);
    }
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
    return DateFormat("EEE, dd MMM").format(date);
  }

  void _showBottomSheet(BuildContext context, String type, String id) {
    showModalBottomSheet(
      context: context,
      // isDismissible: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        Orientation orientation = MediaQuery.of(context).orientation;
        final height = orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height
            : MediaQuery.of(context).size.width;
        final width = orientation == Orientation.portrait
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.height;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Divider(
                    color: const Color(0xffcdcdcd),
                    height: height * .02,
                    thickness: 5,
                    indent: width * .38,
                    endIndent: width * .38,
                  ),
                ),
              ),
              SizedBox(height: height * .02),
              ListTile(
                onTap: () {
                  print("dataMore:${widget.data}");

                  Navigator.of(context).pop();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Financial(data: widget.data, type: type, id: id),
                    ),
                  );
                },
                leading: Image.asset(
                  "assets/images/financial_details.png",
                  width: width * .08,
                ),
                title: Text(
                  'More Financial Details',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  _showBottomSheetRemoveAsset(context);
                },
                leading: Image.asset(
                  "assets/images/remove_asset.png",
                  width: width * .08,
                ),
                title: Text(
                  'Remove Asset',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: height * 0.03),
              CustomButton(
                text: 'Close',
                fontSize: 14.sp,
                isLoading: false,
                borderRadius: 30,
                borderColor: const Color(0xffC8CECC),
                onPressed: () => Navigator.pop(context),
                color: Colors.white,
                textColor: Colors.black,
              ),
              SizedBox(height: height * 0.05),
            ],
          ),
        );
      },
    );
  }

  void _showBottomSheetRemoveAsset(BuildContext context) {
    showModalBottomSheet(
      context: context,
      // isDismissible: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        Orientation orientation = MediaQuery.of(context).orientation;
        final height = orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height
            : MediaQuery.of(context).size.width;
        final width = orientation == Orientation.portrait
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.height;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Divider(
                      color: const Color(0xffcdcdcd),
                      height: height * .02,
                      thickness: 5,
                      indent: width * .38,
                      endIndent: width * .38,
                    ),
                  ),
                ),
                SizedBox(height: height * .02),
                Text(
                  'Remove this asset?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(height: height * .01),
                Text(
                  'This asset will be moved to the Archive section, where you can view and recover it whenever needed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    color: AppColors.grayColor,
                  ),
                ),
                SizedBox(height: height * .02),
                CustomButton(
                  text: 'Go Back',
                  fontSize: 14.sp,
                  isLoading: false,
                  borderRadius: 30,
                  borderColor: const Color(0xffC8CECC),
                  onPressed: () => Navigator.pop(context),
                  color: AppColors.primaryColor,
                  textColor: Colors.white,
                ),
                SizedBox(height: height * 0.03),
                CustomButton(
                  text: 'Remove Asset',
                  fontSize: width * .04,
                  isLoading: false,
                  borderRadius: 30,
                  borderColor: const Color(0xffC8CECC),
                  onPressed: () {
                    addorremove();
                  },
                  color: Colors.white,
                  textColor: Colors.black,
                ),
                SizedBox(height: height * 0.05),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TextRowDigit extends StatelessWidget {
  const TextRowDigit({
    super.key,
    required this.controller,
    required this.enable,
    required this.text,
    required this.currency,
  });

  final TextEditingController controller;
  final bool enable;
  final String text;
  final String currency;

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            text,
            style: TextStyle(
              fontSize: width * .045,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: controller,
            style: TextStyle(
              fontSize: width * .04,
              fontWeight: FontWeight.w300,
            ),
            enabled: enable,
            onTap: () {
              if (controller.text == "0") {
                controller.clear();
              }
            },
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              prefix: Text(currency),
              filled: true,
              contentPadding: EdgeInsets.all(width * .02),
              disabledBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(width * .02),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(width * .02),
              ),
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(width * .01),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TextRow extends StatelessWidget {
  const TextRow({
    super.key,
    required this.controller,
    required this.enable,
    required this.maxLines,
    required this.text,
  });

  final TextEditingController controller;
  final bool enable;
  final int maxLines;
  final String text;

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            text,
            style: TextStyle(
              fontSize: width * .045,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: TextFormField(
            keyboardType: TextInputType.name,
            controller: controller,
            onTap: () {
              if (controller.text == "0") {
                controller.clear();
              }
            },
            maxLines: maxLines,
            style: TextStyle(
              fontSize: width * .04,
              fontWeight: FontWeight.w300,
            ),
            enabled: enable,
            decoration: InputDecoration(
              filled: true,
              contentPadding: EdgeInsets.all(width * .02),
              disabledBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(width * .02),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(width * .02),
              ),
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(width * .01),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
