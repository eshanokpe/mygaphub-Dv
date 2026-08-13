import 'dart:convert';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'addincomeAccount.dart';

class AssignIncomeChannels extends StatefulWidget {
  const AssignIncomeChannels({super.key});

  @override
  State<AssignIncomeChannels> createState() => _AssignIncomeChannelsState();
}

class _AssignIncomeChannelsState extends State<AssignIncomeChannels> {
  var totalassigned;
  Map data = {};
  @override
  void initState() {
    super.initState();

    data = context.read<Providers>().seedata;
  }

  @override
  Widget build(BuildContext context) {
    totalassigned = data['data']["total_assigned"];
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Container(
      height: height * .05,
      padding: EdgeInsets.only(right: width * .20),
      child: Padding(
        padding: EdgeInsets.only(left: width * .05, bottom: height * .01),
        child: InkWell(
          onTap: () {
            showDialog(
              useSafeArea: true,
              barrierDismissible: true,
              context: context,
              builder: (BuildContext context) {
                return MyDialogBox();
              },
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              totalassigned == 0
                  ? const Icon(
                      Icons.cancel_presentation_rounded,
                      color: Colors.red,
                    )
                  : const Icon(Icons.check_box_outlined, color: Colors.green),
              SizedBox(width: width * .02),
              Text(
                "Assign Income channels",
                style: TextStyle(
                  fontSize: width * .05,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyDialogBox extends StatefulWidget {
  const MyDialogBox({super.key});

  // List incomes;
  //MyDialogBox({this.incomes});
  @override
  _MyDialogBoxState createState() => _MyDialogBoxState();
}

class _MyDialogBoxState extends State<MyDialogBox> {
  var incomes;
  Map incomesData = {};
  Map data = {};
  var allocationamount;
  var totalassigned;
  @override
  void initState() {
    super.initState();
    incomesData = context.read<Providers>().incomesData;
    incomes = incomesData['incomes'];
    data = context.read<Providers>().seedata;
    //print("incomesData:${incomesData}");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currency = context.watch<Providers>().snapshotmodel.currency;
    allocationamount = data['data']["current_seed"]["budget_amount"];
    totalassigned = data['data']["total_assigned"];
    // print(totalassigned);

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
                          "Buget to Assign:",
                          style: TextStyle(
                            fontSize: width * .05,
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
                            fontSize: width * .05,
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
                    SizedBox(height: height * .02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "List of Income Accounts",
                          style: TextStyle(
                            fontSize: width * .05,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * .01),
                    incomes != null && incomes.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: incomes.length,
                            itemBuilder: (BuildContext context, int index) {
                              var income = incomes[index];
                              // print('incomeId:${income['id']}');
                              //print('income_name:${income['income_name']}');
                              var incomeName = income['income_name'];
                              var incomeType = income['income_type'];
                              var incomeId = income['id'];
                              var amount = income['amount'];
                              var assignedIncome = income['assigned_income'];
                              // Define a list of colors to loop through
                              List<Color> colors = [
                                const Color.fromARGB(255, 111, 48, 160),
                                const Color.fromARGB(255, 241, 144, 115),
                                const Color.fromARGB(255, 219, 247, 166),
                                const Color.fromARGB(255, 36, 112, 163),
                                const Color.fromARGB(255, 255, 196, 0),
                              ];

                              // Calculate the index of the color for the left side
                              int leftColorIndex = index % colors.length;

                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      EasyLoading.show(
                                        status: 'Loading',
                                        dismissOnTap: false,
                                      );
                                      try {
                                        // Fetch data and perform other operations here
                                        var urlportfolio = Uri.parse(
                                          "$baseUrl/app/portfolio/$incomeType/$incomeId",
                                        );
                                        var url2 = Uri.parse(
                                          "$baseUrl/app/seed",
                                        );
                                        var url = Uri.parse(
                                          "$baseUrl/app/360/non_portfolio/$incomeId",
                                        );
                                        final prefs =
                                            await SharedPreferences.getInstance();
                                        var token = prefs.getString('tokenDB');
                                        var response = await http.get(
                                          url,
                                          headers: {
                                            "Authorization": 'Bearer $token',
                                          },
                                        );
                                        var response2 = await http.get(
                                          url2,
                                          headers: {
                                            "Authorization": 'Bearer $token',
                                          },
                                        );
                                        if (incomeType.toString() ==
                                            'non_portfolio') {
                                          if (response.statusCode == 200) {
                                            var body = jsonDecode(
                                              response.body,
                                            );
                                            var body2 = jsonDecode(
                                              response2.body,
                                            );
                                            context
                                                .read<Providers>()
                                                .setSeeData(body2);
                                            context
                                                .read<Providers>()
                                                .setnonporfolioData(
                                                  body['data'],
                                                );
                                            //print('body2:${body2['data']}');
                                            //print('$incomeId:{incomeId}');

                                            // Show the dialog here
                                            showDialog(
                                              useSafeArea: true,
                                              barrierDismissible: true,
                                              context: context,
                                              builder:
                                                  (BuildContext dialogContext) {
                                                    return AddIncomeAccount(
                                                      incomeName: incomeName,
                                                      incomeId: incomeId,
                                                      amount: amount,
                                                    );
                                                  },
                                            );
                                            EasyLoading.dismiss();
                                          }
                                        } else {
                                          EasyLoading.dismiss();
                                          Fluttertoast.showToast(
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            msg: 'Porfolio ',
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                          );
                                        }
                                      } catch (e) {
                                        EasyLoading.dismiss();
                                        Fluttertoast.showToast(
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          msg: 'No Data Found ',
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                        );
                                        //print("Error: $e");
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          width: width * .04,
                                          height: height * .06,
                                          decoration: BoxDecoration(
                                            color: colors[leftColorIndex],
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  bottomLeft: Radius.circular(
                                                    10,
                                                  ),
                                                ),
                                          ),
                                        ),
                                        Container(
                                          width: width * .70,
                                          height: height * .06,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[500],
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topRight: Radius.circular(10),
                                                  bottomRight: Radius.circular(
                                                    10,
                                                  ),
                                                ),
                                          ),
                                          child: ListTile(
                                            dense: true,
                                            isThreeLine: false,
                                            leading: SizedBox(
                                              width: 200,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      '$incomeName - ${incomeType == "non_portfolio" ? "Non Portfolio" : "Porfolio"} $currency${amount.toStringAsFixed(2)}'
                                                          .replaceAllMapped(
                                                            RegExp(
                                                              r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                                            ),
                                                            (Match m) =>
                                                                '${m[1]},',
                                                          ),
                                                      // textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: width * .035,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  assignedIncome == null
                                                      ? Container()
                                                      : Center(
                                                          child: Container(
                                                            width: 20,
                                                            height: 30,
                                                            color: Colors.green,
                                                            child: const Center(
                                                              child: Text(
                                                                'A',
                                                                style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            ),
                                            trailing: const Icon(
                                              Icons.keyboard_arrow_right,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: height * .01),
                                ],
                              );
                            },
                          )
                        : const Center(child: Text('No data available')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: const [
        // Center(
        //   child: ElevatedButton(
        //     style: ButtonStyle(
        //       backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
        //     ),
        //     onPressed: () {},
        //     child: Text('Add Account'),
        //   ),
        // ),
      ],
    );
  }
}
