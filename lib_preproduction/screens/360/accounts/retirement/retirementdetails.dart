import 'dart:async';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'presentation/retiredash.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Retirementdetails extends StatefulWidget {
  final Map data;
  final bool archived;
  const Retirementdetails({
    super.key,
    required this.data,
    this.archived = false,
  });
  @override
  _RetirementdetailsState createState() => _RetirementdetailsState();
}

class _RetirementdetailsState extends State<Retirementdetails> {
  bool enable = false;
  TextEditingController provider = TextEditingController();
  TextEditingController monthly = TextEditingController();
  TextEditingController retire = TextEditingController();
  TextEditingController yearsToRetire = TextEditingController();
  TextEditingController percent = TextEditingController();
  TextEditingController balanceC = TextEditingController();
  TextEditingController balanceR = TextEditingController();
  TextEditingController amnC = TextEditingController();
  TextEditingController amnR = TextEditingController();
  int a = 0;
  int x = 0;
  double y = 0;
  DateTime? datez;
  Dio dio = Dio();

  DialogBox dialogBox = DialogBox();

  @override
  void initState() {
    super.initState();
    print("no:${widget.data["id"]}");
    // var ageToRetire = widget.data["retirement_age"];
    var ageToRetire = int.tryParse(widget.data["retirement_age"] ?? '') ?? 0;

    retire.text =
        "$ageToRetire".replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        ) ??
        "";
    provider.text =
        widget.data["provider"].toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        ) ??
        "";
    monthly.text =
        widget.data["monthly_contribution"].toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        ) ??
        "";
    balanceC.text = widget.data["current"].toString() ?? "";
    amnC.text = widget.data["assured_income"].toString();

    percent.text = widget.data["percentage_cos"].toString() ?? "0";

    yearsToRetire.text = widget.data["year_retirement"].toString() ?? "0";

    balanceR.text =
        widget.data["retire_balance"].toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        ) ??
        "";

    amnR.text =
        widget.data["retire_income"].toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        ) ??
        "";

    if (widget.data["dob"] != null) {
      datez = DateTime.parse(widget.data["dob"]);
      var retireYear = DateTime(
        datez!.year + ageToRetire.toInt(),
        datez!.month,
        datez!.month,
      );

      // var b = DateTime();
      a = retireYear.year - DateTime.now().year;
      yearsToRetire.text = "$a Years";
    } else {
      datez = DateTime.now();
    }
    // x = (widget.data["monthly_contribution"] * 12 * a) + widget.data["current"];
    // balanceR.text = "$x".replaceAllMapped(
    //     new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    // var divide = widget.data["current"] / widget.data["assured_income"];
    // y = x / divide;
    // amnR.text = "${y.round()}".replaceAllMapped(
    //     new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.data;
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    String currency = context.watch<Providers>().snapshotmodel.currency;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${data["name"]}- ${data["pension_type"]}',
          style: TextStyle(fontSize: width * .045, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNav(4),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * .04,
            vertical: height * .02,
          ),
          child: Column(
            children: [
              Text(
                '(view & edit)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  // color: Theme.of(context).primaryColor,
                  fontSize: width * .035,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: height * .03),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      'PENSION POT',
                      style: TextStyle(
                        // color: Theme.of(context).primaryColor,
                        fontSize: width * .045,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: width * .03),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Current Year',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: width * .04,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Retirement Year',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: width * .04,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * .03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Balance:',
                      style: TextStyle(
                        // color: Theme.of(context).primaryColor,
                        fontSize: width * .04,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      enabled: false,
                      controller: balanceC,
                      keyboardType: TextInputType.number,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        prefixText: "$currency ",
                        filled: true,
                        fillColor: !enable ? Colors.white : Colors.grey[300],
                        prefixStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        hintStyle: TextStyle(fontSize: width * .03),
                        contentPadding: EdgeInsets.only(
                          left: width * .013,
                          right: width * .03,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: width * .02),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      enabled: false,
                      controller: balanceR,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(fontSize: width * .03),
                        prefixText: "$currency ",
                        filled: true,
                        fillColor: !enable ? Colors.white : Colors.grey[300],
                        prefixStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        contentPadding: EdgeInsets.only(
                          left: width * .013,
                          right: width * .03,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * .03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Accrued Monthly Income:',
                      style: TextStyle(
                        // color: Theme.of(context).primaryColor,
                        fontSize: width * .04,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      enabled: false,
                      controller: amnC,
                      keyboardType: TextInputType.number,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        prefixText: "$currency ",
                        filled: true,
                        fillColor: !enable ? Colors.white : Colors.grey[300],
                        prefixStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        hintStyle: TextStyle(fontSize: width * .03),
                        contentPadding: EdgeInsets.only(
                          left: width * .013,
                          right: width * .03,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: width * .02),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      enabled: false,
                      controller: amnR,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        prefixText: "$currency ",
                        filled: true,
                        fillColor: !enable ? Colors.white : Colors.grey[300],
                        prefixStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        hintStyle: TextStyle(fontSize: width * .03),
                        contentPadding: EdgeInsets.only(
                          left: width * .013,
                          right: width * .03,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * .05),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Other Details",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: width * .05,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: width * .02),
                  Visibility(
                    visible: !widget.archived,
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          enable = !enable;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * .05),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Name of the pension provider:',
                  style: TextStyle(
                    fontSize: width * .045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              TextFormField(
                controller: provider,
                enabled: enable,
                keyboardType: TextInputType.name,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintStyle: TextStyle(fontSize: width * .03),
                  contentPadding: EdgeInsets.all(width * .03),
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: height * .03),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Monthly Contributions:',
                  style: TextStyle(
                    fontSize: width * .045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              TextFormField(
                controller: monthly,
                enabled: enable,
                inputFormatters: [amountValidator],
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  prefixText: currency,
                  prefixStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                  hintStyle: TextStyle(fontSize: width * .03),
                  contentPadding: EdgeInsets.all(width * .03),
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: height * .03),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Retirement Age:',
                  style: TextStyle(
                    fontSize: width * .045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              TextFormField(
                enabled: enable,
                controller: retire,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  suffixText: "Years",
                  hintStyle: TextStyle(fontSize: width * .03),
                  contentPadding: EdgeInsets.all(width * .03),
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: height * .03),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Years to Retirement:',
                  style: TextStyle(
                    fontSize: width * .045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              TextFormField(
                enabled: false,
                controller: yearsToRetire,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: !enable ? Colors.white : Colors.grey[300],
                  suffixText: "Years",
                  hintStyle: TextStyle(fontSize: width * .03),
                  contentPadding: EdgeInsets.all(width * .03),
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: height * .03),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Percentage of Current Budget:',
                  style: TextStyle(
                    fontSize: width * .045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              TextFormField(
                enabled: false,
                controller: percent,
                inputFormatters: [amountValidator],
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: !enable ? Colors.white : Colors.grey[300],
                  suffixText: "%",
                  hintStyle: TextStyle(fontSize: width * .03),
                  contentPadding: EdgeInsets.all(width * .03),
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: height * .03),
              Visibility(
                visible: !enable,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    backgroundColor: Colors.grey[400],
                  ),
                  onPressed: widget.archived
                      ? () {
                          dialogBox.options(
                            context,
                            "Confirm Add Account",
                            "Are you sure you want to add this account? (You will be able to view the account in Mortgage)",
                            () {
                              addorremove();
                            },
                          );
                        }
                      : () {
                          dialogBox.options(
                            context,
                            "Confirm Remove Account",
                            "Are you sure you want to remove this account? (You will be able view the account under Archive section)",
                            () {
                              addorremove();
                            },
                          );
                          // dropdown();
                        },
                  child: Text(
                    widget.archived ? "Restore Account" : "Remove Account",
                    style: TextStyle(
                      // decoration: TextDecoration.underline,
                      color: Colors.black,
                      fontSize: width * .035,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: enable,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * .01),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: () async {
                    dialogBox.waiting(context, "Saving");
                    print("no:${widget.data["id"]}");
                    var url = Uri.parse(
                      "$baseUrl/app/360/retirement/${widget.data["id"]}",
                    );
                    var url2 = "$baseUrl/app/360/retirement/roi";
                    var url3 = "$baseUrl/app/360/retirement";
                    final prefs = await SharedPreferences.getInstance();
                    var token = prefs.getString('tokenDB');
                    Map<String, dynamic> data = { 
                      "current": balanceC.text,
                      "assured_income": amnC.text,
                      "monthly": monthly.text,
                      "retirement": retire.text,
                      "provider": provider.text,
                    }; 
                    var response = await http.post(
                      url,
                      body: data,
                      headers: {"Authorization": 'Bearer $token'},
                    );

                    if (response.statusCode == 200 ||
                        response.statusCode == 201) {
                      var response2 = await dio.get(
                        url2,
                        options: Options(
                          headers: {"Authorization": 'Bearer $token'},
                        ),
                      );
                      var response3 = await dio.get(
                        url3,
                        options: Options(
                          headers: {"Authorization": 'Bearer $token'},
                        ),
                      );
                      if (response2.statusCode == 200 &&
                          response3.statusCode == 200) {
                            // ✅ Extract nested data objects
                        final roiData = response2.data['data'] as Map? ?? {};
                        final retirementData = response3.data['data'] as Map? ?? {};

                        if (context.mounted) {
                          context.read<Providers>()
                            ..setretiredata(roiData)
                            ..setpensions(retirementData);
                        } 
                        Navigator.of(context).pop();
                        // Navigator.of(context).pop();
                        Fluttertoast.showToast(
                          msg: 'Your Pension Account is Successful',
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const Retiredash(),
                          ),
                        );
                      } else {
                        Navigator.of(context).pop();
                        Fluttertoast.showToast(msg: 'somethings went wrong');
                      }
                    } else {
                      Navigator.of(context).pop();
                      Fluttertoast.showToast(
                        msg: 'Please enter your Monthly Contributions',
                      );
                    }
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(
                      // decoration: TextDecoration.underline,
                      color: Colors.white,
                      fontSize: width * .04,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  addorremove() async {
    dialogBox.waiting(context, "Loading");
    var timer = Timer(const Duration(milliseconds: 40000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    var urlr = "$baseUrl/app/360/tiles";

    var url = widget.archived
        ? "$baseUrl/app/360/retirement?header=pwiuduihdnjhnsbdgjvjxbsngmbhhgkhdccghdx&access=atyhgujhashgbsxdhgvshgsghfgnbvjbsjkbvjbvjhdx&account=${widget.data["id"]}"
        : "$baseUrl/app/360/retirement?header=pwiuduihdnjhnsbdgjvjxbsngmbhhgkhdccghdx&access=uyaghgbshgbhsjxbhsjxbvbhxdbvdhgbvghdvcghvgdhcvhsnbhsb&account=${widget.data["id"]}";
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      try {
        var response = await dio.get(
          urlr,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );
        context.read<Providers>().setRecent(response.data["tiles"]);
        retirement();
        Fluttertoast.showToast(
          msg: widget.archived
              ? "Account unarchived successfully"
              : "Account archived successfully",
        );
      } catch (e) {
        Navigator.pop(context);
      }
      timer.cancel();
    } else {
      timer.cancel();
    }
    //
  }

  retirement() async {
    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, "Loading");

    var url = "$baseUrl/app/360/retirement/roi";
    var url2 = "$baseUrl/app/360/retirement";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    var response2 = await dio.get(
      url2,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    if (response.statusCode == 200 && response2.statusCode == 200) {
      final roiData = response.data['data'] as Map? ?? {};
      final retirementData = response2.data['data'] as Map? ?? {};

      context.read<Providers>()
          ..setretiredata(roiData)
          ..setpensions(retirementData);
      
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      
      if (widget.archived) {
        Navigator.pop(context);
      }
      timer.cancel();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Retiredash(),
        ),
      );
    }
    timer.cancel();
  }
}
