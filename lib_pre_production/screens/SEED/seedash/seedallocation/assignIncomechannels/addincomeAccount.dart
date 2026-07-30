import 'dart:async';
import 'dart:convert';
import 'package:GapHub/screens/SEED/seedash/setbudget.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyTextEditingController extends TextEditingController {
  operator []=(int index, String value) {
    text = text.replaceRange(index, index + 1, value);
  }
}

class AddIncomeAccount extends StatefulWidget {
  final String incomeName;
  final incomeId;
  var amount;
  AddIncomeAccount({
    super.key,
    required this.incomeName,
    this.amount,
    this.incomeId,
  });
  @override
  _AddIncomeAccountState createState() => _AddIncomeAccountState();
}

class _AddIncomeAccountState extends State<AddIncomeAccount> {
  var incomes;
  Map incomesData = {};
  var allocationamount;
  var totalassigned;
  Map data = {};
  String selectedLabelAsset = "";
  List<String> chartData = [];
  Map nonporfolioData = {};
  Map incomeData = {};
  Map<String, int> valuesMap = {};
  Map<String, int> valuesTithe = {};
  Map<String, int> valuesTaxes = {};
  Map<String, int> valuesNet = {};
  List<double> values = [];
  List<double> titheValues = [];
  List<double> taxValues = [];
  List<double> netValues = [];
  TextEditingController totalassignValue = TextEditingController();
  bool isEditable = false;
  @override
  void initState() {
    super.initState();
    print('incomeName:${widget.incomeName}');
    print('incomeId:${widget.incomeId}');
    print('amount:${widget.amount}');
    incomes = context.read<Providers>().incomesData;
    data = context.read<Providers>().seedata;
    incomesData = context.read<Providers>().incomesData;
    incomes = incomesData['incomes'];
    nonporfolioData = context.read<Providers>().nonporfolioData;
    incomeData = nonporfolioData["income"];
    chartData = nonporfolioData["chart"]['label_asset'].cast<String>();
    //print("incomes:$chartData");
    //chartData.sort((a, b) => b.compareTo(a));
    //print("chartData:$chartData");
    if (chartData.isNotEmpty) {
      selectedLabelAsset = chartData[0];
    }

    // Example: Iterating through the list and casting each element to int
    // Populate valuesMap dynamically based on chartData
    for (int i = 0; i < chartData.length; i++) {
      valuesMap[chartData[i]] = nonporfolioData["chart"]["values"][i];
      //valuesNet[chartData[i]] = nonporfolioData["chart"]["values"][i];
      //valuesNetincome[chartData[i]] = nonporfolioData["chart"]["values"][i];
      valuesTithe[chartData[i]] = nonporfolioData["chart"]["tithe_values"][i];
      valuesTaxes[chartData[i]] = nonporfolioData["chart"]["taxes_values"][i];
      valuesNet[chartData[i]] = nonporfolioData["chart"]["net_values"][i];

      // You can add mappings for tithe values, taxes values, and net values in a similar manner
    }
  }

  @override
  Widget build(BuildContext context) {
    String currency = context.watch<Providers>().snapshotmodel.currency;
    allocationamount = data['data']["current_seed"]["budget_amount"];
    totalassigned = data['data']["total_assigned"];
    totalassignValue.text = totalassigned.toString();

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    return AlertDialog(
      contentPadding: EdgeInsets.zero, // Remove top padding

      content: SizedBox(
        width: width * 100,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Positioned(
                top: 5,
                right: 5,
                child: Padding(
                  padding: const EdgeInsets.only(left: 0.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: width * .03,
                  right: width * .02,
                  bottom: height * .01,
                  top: height * .03,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Budget to Assign:",
                          style: TextStyle(
                            fontSize: width * .045,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: width * .02),
                        Text(
                          "$currency$allocationamount.00".replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          ),
                          style: TextStyle(
                            fontSize: width * .045,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * .01),
                    Row(
                      children: [
                        Text(
                          "Balance to Assign:",
                          style: TextStyle(
                            fontSize: width * .05,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: width * .02),
                        Text(
                          "$currency${allocationamount - totalassigned}.00"
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              ),
                          style: TextStyle(
                            fontSize: width * .05,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * .01),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              "${widget.incomeName} Average Income: $currency${widget.amount.toStringAsFixed(2)}"
                                  .replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]},',
                                  ),
                              style: TextStyle(
                                fontSize: width * .045,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(width: width * .02),
                        ],
                      ),
                    ),
                    SizedBox(height: height * .02),
                    Container(
                      child: Text(
                        "Income Period",
                        style: TextStyle(
                          fontSize: width * .045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: height * .01),
                    Container(
                      width: width * .80,
                      padding: EdgeInsets.only(
                        left: width * .03,
                        right: width * .03,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white,
                        border: Border.all(
                          color: const Color.fromARGB(255, 196, 196, 196),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: const Text(''),
                          value: selectedLabelAsset,
                          items: chartData
                              .map(
                                (data) => DropdownMenuItem<String>(
                                  value: data.toString(),
                                  child: Text(data),
                                ),
                              )
                              .toList(),
                          onChanged: (value) async {
                            setState(() {
                              selectedLabelAsset = value!;
                            });
                            //print('itemsssdate:$historicdate');
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: height * .01),
                    Container(
                      child: Text(
                        "Net Income",
                        style: TextStyle(
                          fontSize: width * .045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: height * .01),
                    Container(
                      width: width,
                      height: height * .06,
                      padding: EdgeInsets.only(
                        left: width * .04,
                        right: width * .03,
                        top: height * .015,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.grey[300],
                        border: Border.all(
                          color: const Color.fromARGB(255, 196, 196, 196),
                        ),
                      ),
                      child: Text(
                        '$currency${valuesNet[selectedLabelAsset] ?? ""}'
                            .replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            ),
                        style: TextStyle(
                          fontSize: width * .05,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(height: height * .02),
                    Container(
                      child: Text(
                        "Assigned Amount",
                        style: TextStyle(
                          fontSize: width * .045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: height * .01),
                    InkWell(
                      onTap: () {
                        setState(() {
                          isEditable = !isEditable;
                        });
                      },
                      child: TextFormField(
                        enabled: isEditable,
                        readOnly: !isEditable,
                        keyboardType: TextInputType.number,
                        controller: totalassignValue,
                        // onChanged: (newValue) {
                        //   // Update the value in the controller as the user edits it.
                        //   setState(() {
                        //     // Parse the new value as a double and update the controller.
                        //     totalassignValue.text = newValue;
                        //   });
                        // },
                        style: const TextStyle(fontWeight: FontWeight.w400),
                        decoration: InputDecoration(
                          prefixText: currency,
                          prefixStyle: const TextStyle(color: Colors.black),
                          suffixIcon: const Icon(
                            Icons.edit,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Colors.white,
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
              ),
            ],
          ),
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
            ),
            onPressed: () {
              subAssignedIncome(widget.incomeId, totalassignValue);
            },
            child: const Text('Submit'),
          ),
        ),
      ],
    );
  }

  void subAssignedIncome(
    int incomeId,
    TextEditingController totalassignValue,
  ) async {
    //print(incomeId.toString());
    //print(totalassignValue.text);
    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, 'Loading');
    var url = Uri.parse("$baseUrl/app/seed/assign/income");
    var url2 = Uri.parse("$baseUrl/app/seed");
    var url3 = Uri.parse("$baseUrl/app/360/income");

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    // var response2 =
    //await http.get(url2, headers: {"Authorization": 'Bearer $token'});
    // // var response3 =
    //     await http.get(url3, headers: {"Authorization": 'Bearer $token'});

    var response = await http.post(
      url,
      body: {
        'seed_income': incomeId.toString(),
        'seed_budget': totalassignValue.text,
      },
      headers: {
        "Authorization": 'Bearer $token',
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      encoding: Encoding.getByName("utf-8"),
    );
    // if (response.statusCode == 200) {}
    if (response.statusCode == 200) {
      timer.cancel();
      Navigator.pop(context);
      var response2 = await http.get(
        url2,
        headers: {"Authorization": 'Bearer $token'},
      );

      var body2 = jsonDecode(response2.body);
      context.read<Providers>().setSeeData(body2);
      // var body3 = jsonDecode(response3.body);
      // var incomes = body3;
      //context.read<Providers>().incomesAccount(incomes);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Setbudget(true)),
      );
      Fluttertoast.showToast(
        backgroundColor: Colors.green,
        textColor: Colors.white,
        msg: 'Successfull ',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } else {
      timer.cancel();
      Navigator.pop(context);
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'No Data Found ',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
