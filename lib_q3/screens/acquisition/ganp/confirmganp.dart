import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Confirmganp extends StatefulWidget {
  final Map<String, dynamic> productDetails;
  final int unit;
  final List<int> values;

  const Confirmganp(this.productDetails, this.values, this.unit, {super.key});
  @override
  _ConfirmganpState createState() => _ConfirmganpState();
}

class _ConfirmganpState extends State<Confirmganp> {
  bool checkVal = false;
  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    var returns =
        int.parse(widget.productDetails['months'].round().toString()) /
        int.parse(widget.productDetails['max_pay'].round().toString());
    String currency = widget.productDetails['currency'].toString().substring(
      0,
      1,
    );
    var firstPayment =
        (widget.values[1] /
                int.parse(widget.productDetails['max_pay'].round().toString()))
            .round();

    var amount = widget.productDetails['amount'].toString();
    var totalAmount = int.parse(amount) * widget.unit;

    var percent = firstPayment / widget.values[1] * 100;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 25,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: Colors.black,
        ),
        title: Text(
          '${widget.productDetails['name']} Subscription',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * .02,
            vertical: height * .01,
          ),
          child: Column(
            children: [
              SizedBox(height: height * .02),
              SizedBox(
                height: height * .27,
                child: InkWell(
                  onTap: () {},
                  child: CachedNetworkImage(
                    imageUrl:
                        'http://www.gapassethub.com/ganp/public/storage${widget.productDetails['image1'].toString().substring(6)}',
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
              Text(
                '${widget.productDetails['name']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: width * .065,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: height * .01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.productDetails['rate']}% Return',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: width * .035,
                      color: Colors.black,
                    ),
                  ),
                  Image.asset('assets/images/dot.png', width: width * .04),
                  Text(
                    '${widget.productDetails['months']} Months',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: width * .035,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              // Container(
              //   height: height * .27,
              //   child: InkWell(
              //     onTap: () {},
              //     child: CachedNetworkImage(
              //       imageUrl:
              //           'http://prismcheck.com/releasea/ganp/public/storage${widget.productDetails['image1'].toString().substring(6)}',
              //       progressIndicatorBuilder: (context, url, progress) =>
              //           Center(
              //         child: CircularProgressIndicator(
              //           strokeWidth: .2,
              //           value: progress.progress,
              //         ),
              //       ),
              //       errorWidget: (context, url, error) => Icon(Icons.portrait),
              //       fit: BoxFit.cover,
              //     ),
              //   ),
              // ),
              Text(
                'Your Subscription\'s Amount',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: width * .065,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: height * .005),
              Text(
                '$currency$totalAmount'.replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},',
                ),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: width * .065,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: height * .005),
              // Text('(Actual Fixed Price: )',
              //     style: TextStyle(
              //         fontWeight: FontWeight.bold,
              //         fontSize: width * .055,
              //         color: Colors.black)),
              SizedBox(height: height * .02),
              Card(
                color: Colors.grey[200],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Representative Example (Variable): In the ${returns.round()}th month you will receive $currency$firstPayment (${percent.round()}% of your income).'
                            .replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            ),
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: width * .04,
                          color: Colors.black,
                        ),
                      ),
                      int.parse(
                                widget.productDetails['max_pay']
                                    .round()
                                    .toString(),
                              ) >
                              1
                          ? Text(
                              'And by the ${widget.productDetails['months']}th month, you will receive the balance of $currency${widget.values[1] - firstPayment}.'
                                  .replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]},',
                                  ),
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: width * .04,
                                color: Colors.black,
                              ),
                            )
                          : Container(),
                      Text(
                        'As well as your capital of $currency${widget.values[0]}. Total amount returned will be $currency${widget.values[3]}.'
                            .replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            ),
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: width * .04,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * .01),
              const Divider(),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Disclaimer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: width * .055,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: height * .01),
              Text(
                'MyGAPhub does not guarantee or control neither your capital nor your returns. You will enter into an independent contract with the local vendor which will be responsible for managing your asset.',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .035,
                  color: Colors.black,
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    activeColor: Theme.of(context).primaryColor,
                    checkColor: Colors.white,
                    value: checkVal,
                    onChanged: (bool? value) {
                      setState(() {
                        checkVal = value ?? false;
                      });
                    },
                  ),
                  Text(
                    'I agree with all the terms and conditions',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: width * .04,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const Divider(thickness: 2),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).primaryColor,
                  ),
                ),
                // color: Theme.of(context).primaryColor,
                onPressed: () {
                  print("subscribe id: ${widget.productDetails['id']}");
                  Subscribe(widget.productDetails['id']);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 3,
                  ),
                  child: Text(
                    'Subscribe with Vendor',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: width * .04,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * .04),
            ],
          ),
        ),
      ),
    );
  }

  Subscribe(assetId) async {
    if (!checkVal) {
      Fluttertoast.showToast(msg: "Accept Terms and Conditions");
      return;
    }
    print("unit: ${widget.unit}");
    EasyLoading.show(status: 'Loading', dismissOnTap: false);
    var url = Uri.parse("$baseUrl/app/acquisition/investment/ganp/$assetId");
    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      EasyLoading.dismiss();
      return;
    });

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var reapresponse = await http.post(
      url,
      body: {'units': '${widget.unit}'},
      headers: {"Authorization": 'Bearer $token'},
    );
    if (reapresponse.statusCode == 200) {
      timer.cancel();
      EasyLoading.dismiss();
      Fluttertoast.showToast(
        msg: "Subscription successfully submitted",
        toastLength: Toast.LENGTH_LONG,
      );
    }
    // connectTo(
    //     context, "post", "/app/acquisition/investment/ganp/${assetId}", {
    //       "units": "${widget.unit}"
    //     },
    //     shoot: () {
    //   Navigator.pop(context);
    //   Fluttertoast.showToast(msg: "Subscription successfully submitted", toastLength: Toast.LENGTH_LONG);
    // });
  }
}
