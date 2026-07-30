import 'dart:async';
import 'dart:io';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:GapHub/screens/portfolio/braiditem.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/custom_input_field.dart';
import 'package:GapHub/widgets/custom_input_field_multistep.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

import 'widget/display_image_widget.dart';

class BaidItemUpdateRecord extends StatefulWidget {
  final String imgurl;
  final Map data;
  final String name;
  final String? type;
  final String? id;

  const BaidItemUpdateRecord({
    super.key,
    required this.imgurl,
    required this.data,
    required this.name,
    this.type,
    this.id,
  });

  @override
  State<BaidItemUpdateRecord> createState() => _BaidItemUpdateRecordState();
}

class _BaidItemUpdateRecordState extends State<BaidItemUpdateRecord> {
  var document1;
  var document2;
  var document3;
  var document4;
  var document5;
  var document6;
  var document7;
  var document8;
  List documents = [];
  final _formKey = GlobalKey<FormState>();
  DialogBox dialogBox = DialogBox();
  TextEditingController docName = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController value = TextEditingController();
  TextEditingController revenue = TextEditingController();
  TextEditingController income = TextEditingController();
  TextEditingController mngtFees = TextEditingController();
  TextEditingController taxes = TextEditingController();
  TextEditingController mtnCost = TextEditingController();
  TextEditingController mtnDetails = TextEditingController();
  TextEditingController others = TextEditingController();
  TextEditingController otherNotes = TextEditingController();
  TextEditingController expenditure = TextEditingController();
  String? imgurl;
  Dio dio = Dio();
  final int _radioValue = 0;
  String asset = '-Select-';
  File? _image;
  var assetCurrency;
  var currency;

  @override
  void initState() {
    super.initState();
    imgurl = widget.data['data']["asset"]["photo_url"];
    var data = widget.data['data']["asset"];
    print("data:$data");
    assetCurrency = data["asset_currency"].toString().split(" ");
    currency = assetCurrency[0];

    name.text = data["name"];
    value.text = data["asset_value"].toString();
    revenue.text = data['record']['revenue'].toString();
    description.text = data["description"];
    document1 = data["document1"];
    // Ensure default values for empty text fields
    double taxesValue = double.tryParse(taxes.text.trim()) ?? 0;
    double mngtFeesValue = double.tryParse(mngtFees.text.trim()) ?? 0;
    double mtnCostValue = double.tryParse(mtnCost.text.trim()) ?? 0;
    double othersValue = double.tryParse(others.text.trim()) ?? 0;
    double revenueValue = double.tryParse(revenue.text.trim()) ?? 0;
    double expenditureValue =
        taxesValue + mngtFeesValue + mtnCostValue + othersValue;
    expenditure.text = expenditureValue.toStringAsFixed(2);
    double incomeValue = revenueValue - expenditureValue;

    // Update income field (rounding to the nearest integer)
    income.text = incomeValue.round().toString();

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
  }

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
  var d = DateFormat.yMMMM();
  List<dynamic> details = [];
  String updateDate = "";
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
    var body = jsonDecode(response.body)["asset_records"];
    mngtFees.text = "${body["management"] ?? ""}";
    taxes.text = "${body["taxes"] ?? ""}";
    mtnCost.text = "${body["maintenance"] ?? ""}";
    others.text = "${body["others"] ?? ""}";
    mtnDetails.text = body["maintenance_details"] ?? "";
    otherNotes.text = body["note"] ?? "";
  }

  DateTime selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    var data = widget.data['data']["asset"];
    updateDate = d.format(DateTime.now());
    details = [
      updateDate,
      value.text.isNotEmpty ? value.text : 0,
      revenue.text.isNotEmpty ? revenue.text : 0,
      taxes.text.isNotEmpty ? taxes.text : 0,
      mngtFees.text.isNotEmpty ? mngtFees.text : 0,
      mtnCost.text.isNotEmpty ? mtnCost.text : 0,
      mtnDetails.text.isNotEmpty ? mtnDetails.text : 0,
      otherNotes.text.isNotEmpty ? otherNotes.text : 0,
      currency,
      others.text.isNotEmpty ? others.text : 0,
      DateFormat('yyyy-MM').format(selectedDate),
    ];
    // print("details:$details");

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.08,
                height: MediaQuery.of(context).size.width * 0.08,
                child: DisplayImage(
                  imagePath: imgurl!,
                  icon: false,
                  onPressed: () {
                    null;
                  },
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              Flexible(
                child: Text(
                  '${widget.name[0].toUpperCase()}${widget.name.substring(1)}',
                  style: TextStyle(
                    color: AppColors.grayColor,
                    fontSize:
                        MediaQuery.of(context).size.width *
                        0.04, // Responsive font size
                  ),
                  overflow:
                      TextOverflow.ellipsis, // Handle long text gracefully
                ),
              ),
            ],
          ),
          iconTheme: IconThemeData(
            color: Colors.black,
            size: MediaQuery.of(context).size.width * 0.06,
          ),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .04),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _showBottomSheet(context, data);
                      }
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: const Color(0xff009933),
                        fontSize: width * .04,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * .04),
          child: ListView(
            children: [
              SizedBox(height: height * .03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Update Period'.toUpperCase(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: width * .04,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        updateDate,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: width * .04,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_drop_down, size: width * .1),
                        onPressed: () {
                          datePickerForNote(data);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: height * .04),
              CustomInputField(
                label: 'Value',
                inputFormatters: [amountValidator],
                labelText: true,
                obscureText: false,
                prefix: Text("$currency  "),
                keyboardType: TextInputType.number,
                controller: value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Field cannot be empty";
                  }
                  return null;
                },
              ),
              SizedBox(height: height * .02),
              CustomInputField(
                label: 'Revenue',
                inputFormatters: [amountValidator],
                labelText: true,
                obscureText: false,
                prefix: Text("$currency  "),
                keyboardType: TextInputType.number,
                controller: revenue,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Field cannot be empty";
                  }
                  return null;
                },
              ),
              SizedBox(height: height * .03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'EXPENDITURE'.toUpperCase(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: width * .04,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * .02),
              CustomInputField(
                label: 'Management Fees',
                inputFormatters: [amountValidator],
                labelText: true,
                obscureText: false,
                prefix: Text("$currency  "),
                keyboardType: TextInputType.number,
                controller: mngtFees,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Field cannot be empty";
                  }
                  return null;
                },
              ),
              SizedBox(height: height * .02),
              CustomInputField(
                label: 'Taxes',
                inputFormatters: [amountValidator],
                labelText: true,
                obscureText: false,
                prefix: Text("$currency  "),
                keyboardType: TextInputType.number,
                controller: taxes,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Field cannot be empty";
                  }
                  return null;
                },
              ),
              SizedBox(height: height * .02),
              CustomInputField(
                label: 'Maintenance Cost',
                inputFormatters: [amountValidator],
                labelText: true,
                obscureText: false,
                prefix: Text("$currency "),
                keyboardType: TextInputType.number,
                controller: mtnCost,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Field cannot be empty";
                  }
                  return null;
                },
              ),
              SizedBox(height: height * .02),
              CustomInputField(
                label: 'Maintenance Details',
                labelText: true,
                obscureText: false,
                keyboardType: TextInputType.text,
                controller: mtnDetails,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Field cannot be empty";
                  }
                  return null;
                },
              ),
              SizedBox(height: height * .02),
              CustomInputField(
                label: 'Other Costs',
                inputFormatters: [amountValidator],
                labelText: true,
                obscureText: false,
                prefix: Text("$currency  "),
                keyboardType: TextInputType.number,
                controller: others,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Field cannot be empty";
                  }
                  return null;
                },
              ),
              SizedBox(height: height * .02),
              CustomInputFieldMultiStep(
                label: 'Notes',
                image: '',
                maxLines: 6,
                currencies: '',
                suffixText: '',
                keyboardType: TextInputType.text,
                controller: otherNotes,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Please enter the amount';
                //   }
                //   return null;
                // },
              ),
              SizedBox(height: height * .02),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> noteData(Map<String, dynamic> data) async {
    // print("object:${data['id']}");
    var type = data["asset_class"];
    var id = data["id"];
    try {
      // Ensure token is retrieved from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');
      if (token == null || token.isEmpty) {
        throw Exception("Authentication token is missing");
      }

      // Construct the URL
      var url = Uri.parse("$baseUrl/app/portfolio/update/note/${data["id"]}");

      // Prepare the request body
      Map body = {
        "note": otherNotes.text,
        "period": DateFormat('y-M').format(selectedDate),
      };

      // Make the HTTP POST request
      var response = await http.post(
        url,
        body: body,
        headers: {"Authorization": 'Bearer $token'},
      );

      // Handle the response
      if (response.statusCode == 200) {
        var url = Uri.parse("$baseUrl/app/portfolio/$type/$id");
        var response2 = await http.get(
          url,
          headers: {"Authorization": 'Bearer $token'},
        );
        if (response2.statusCode == 200) {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
          // getItem(data["id"], data["asset_class"]);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Braiditem(
                data: jsonDecode(response2.body),
                archived: false,
                type: widget.type,
                id: widget.id,
              ),
            ),
          );
          Fluttertoast.showToast(msg: 'Data updated successfully');
          // Navigator.pop(context);
        }
        Fluttertoast.showToast(msg: "Note updated successfully");
      } else {
        var errorBody = jsonDecode(response.body);
        throw Exception(errorBody["message"] ?? "Failed to update the note");
      }
    } catch (e) {
      print("Error in noteData: ${e.toString()}");
      throw Exception("Error updating note: ${e.toString()}");
    }
  }

  bool hasInput(String text) {
    return text.trim().isNotEmpty;
  }

  Future<void> updateDetails(Map<dynamic, dynamic> data) async {
    var type = data["asset_class"];
    var id = data["id"].toString();
    print("type:$type");
    print("id:$id");

    // Dismiss keyboard
    FocusScope.of(context).requestFocus(FocusNode());

    // Start a timeout timer
    var timer = Timer(const Duration(seconds: 30), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });

    // Show loading dialog
    dialogBox.waiting(context, "Loading");

    var url = Uri.parse("$baseUrl/app/portfolio/update/records/$id");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    // Check if `otherNotes.text` has input
    // if (hasInput(otherNotes.text)) {
    //   try {
    //     await noteData(data);

    //     // Cancel the timer and close dialog
    //     timer.cancel();
    //     Navigator.pop(context);

    //     Fluttertoast.showToast(msg: 'Note updated successfully');
    //     return;
    //   } catch (e) {
    //     timer.cancel();
    //     Navigator.pop(context);
    //     dialogBox.information(context, "Error", e.toString());
    //   }
    // }

    // Check for other inputs
    if ([
      value.text,
      revenue.text,
      mngtFees.text,
      taxes.text,
      details[10]?.toString(),
      mtnCost.text,
      others.text,
      mtnDetails.text,
    ].any((field) => hasInput(field!))) {
      Map<String, String> body = {
        "amount": value.text ?? '',
        "revenue": revenue.text ?? '',
        "management": mngtFees.text ?? '',
        "taxes": taxes.text ?? '',
        "period": details[10]?.toString() ?? '',
        "maintenance": mtnCost.text ?? '',
        "others": others.text ?? '',
        "maintenance_details": mtnDetails.text ?? '',
        "note": otherNotes.text ?? '',
      };

      try {
        var response = await http.post(
          url,
          body: body,
          headers: {"Authorization": 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          var url = Uri.parse("$baseUrl/app/portfolio/$type/$id");
          var response2 = await http.get(
            url,
            headers: {"Authorization": 'Bearer $token'},
          );

          if (response2.statusCode == 200) {
            timer.cancel();
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);

            // Navigate to updated data
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Braiditem(
                  data: jsonDecode(response2.body),
                  archived: false,
                  type: type,
                  id: id,
                ),
              ),
            );
            Fluttertoast.showToast(msg: 'Data updated successfully');
          }
        } else {
          var body = jsonDecode(response.body);
          print("body:$body");
          timer.cancel();
          dialogBox.information(
            context,
            "Status",
            'Something went wrong, try again',
          );
        }
      } catch (e) {
        timer.cancel();
        dialogBox.information(
          context,
          "Status",
          'Something went wrong, try again',
        );
      }
    } else {
      // No input provided
      timer.cancel();
      Navigator.pop(context);
      dialogBox.information(context, "Status", 'No details provided to update');
    }
  }

  getItem(int id, String type) async {
    Timer timer = Timer(const Duration(seconds: 40), () {
      EasyLoading.dismiss();
      return;
    });

    var url = Uri.parse("$baseUrl/app/portfolio/$type/$id");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    var response = await http.get(
      url,
      headers: {"Authorization": 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      timer.cancel();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Braiditem(
            data: jsonDecode(response.body),
            archived: false,
            type: widget.type,
            id: widget.id,
          ),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: "Error");
    }
    timer.cancel();
    EasyLoading.dismiss();
  }

  launchDocu(String url) async {
    var url0 = url;
    await canLaunch(url0) ? launch(url0) : Fluttertoast.showToast(msg: 'Error');
  }

  void _showBottomSheet(BuildContext context, Map data) {
    showModalBottomSheet(
      context: context,
      // isDismissible: false,
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
              Text(
                'Discard Changes?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: width * .04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height * .02),
              Text(
                'If you leave now, you’ll lose your changes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.grayColor,
                  fontSize: width * .04,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: height * 0.03),
              CustomButton(
                text: 'Discard Changes',
                fontSize: width * .04,
                isLoading: false,
                borderRadius: 30,
                borderColor: const Color(0xffC8CECC),
                onPressed: () => Navigator.pop(context),
                color: Colors.white,
                textColor: Colors.black,
              ),
              SizedBox(height: height * 0.02),
              CustomButton(
                text: 'Continue Updating',
                fontSize: width * .04,
                isLoading: false,
                borderRadius: 30,
                borderColor: const Color(0xffC8CECC),
                onPressed: () {
                  updateDetails(data);
                },
                color: AppColors.primaryColor,
                textColor: Colors.white,
              ),
              SizedBox(height: height * 0.05),
            ],
          ),
        );
      },
    );
  }

  int timeoutDuration = 30;

  datePickerForNote(data) {
    showMonthPicker(
      context: context,
      firstDate: DateTime(2009),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    ).then((val) async {
      Timer timer = Timer(const Duration(milliseconds: 20000), () {
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
              Timer timer = Timer(const Duration(milliseconds: 20000), () {
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
}
