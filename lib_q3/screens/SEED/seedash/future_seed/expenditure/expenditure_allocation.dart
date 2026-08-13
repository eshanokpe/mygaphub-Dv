import 'dart:convert';
import 'package:GapHub/models/savingAllocationexpenditure.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/extensions.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'expenditure_allocation_summary.dart';
import 'widget/E2TextFeild.dart';
import 'widget/ETextFeild.dart';

class FSExpenditureAllocation extends StatefulWidget {
  const FSExpenditureAllocation({Key? key}) : super(key: key);

  @override
  State<FSExpenditureAllocation> createState() =>
      _FSExpenditureAllocationState();
}

class _FSExpenditureAllocationState extends State<FSExpenditureAllocation> {
  TextEditingController expenditureAmount = TextEditingController();
  TextEditingController savingNote = TextEditingController();
  TextEditingController newlabel = TextEditingController();
  TextEditingController newaccommodationlabel = TextEditingController();
  TextEditingController newtransportationlabel = TextEditingController();
  TextEditingController newhomefamilylabel = TextEditingController();
  TextEditingController newutilitieslabel = TextEditingController();
  TextEditingController newdebtrepaymentlabel = TextEditingController();
  TextEditingController savdateinput = TextEditingController();

  var _key = GlobalKey<FormState>();
  Map data = {};
  // int allocationamount;
  var d = DateFormat.yMMMM();
  var datez = "";
  var currentmonth = "";
  Map dat = {};
  int? budget_amount;
  var state;
  bool _checked = true;
  final _controller = ValueNotifier<bool>(false);
  List<SavingAllexpenditure> _dataExpen = [];
  @override
  void initState() {
    super.initState();
    data = context.read<Providers>().seedata;
    DateTime date = DateTime.parse(data['data']["current_seed"]["period"]);
    datez = d.format(date);
    //DateTime month = DateTime.parse(dat['period']);
    //currentmonth = d.format(month);
    //budget_amount = data['data']["current_seed"]["budget_amount"];
    //print(budget_amount);
    _controller.addListener(() {
      setState(() {
        if (_controller.value) {
          print('1');
          _checked = true;
        } else {
          print('0');
          _checked = false;
        }
        if (_checked == true) {
          showrecurring = true;
        } else {
          showrecurring = false;
        }
      });
    });
  }

  String expenditurevalue = "-Select-";
  String? label;

  //accommodation
  String accommodationvalue = '-Select-';
  String other = "Others";
  bool _showAccommodation = false;
  bool _showAccommodationdescription = false;
  String? accommodationError;

  //transportation
  bool _showTransportation = false;
  String transportationvalue = '-Select-';
  bool _showTransportationdescription = false;
  String? transportationError;

  //home_family
  bool _showhomefamily = false;
  String homefamilyvalue = '-Select-';
  bool _showhomefamilydescription = false;
  String? homefamilyError;

  //utilities
  bool _showutilities = false;
  String utilitiesvalue = '-Select-';
  bool _showutilitiesdescription = false;
  String? utilitiesError;

  //debtrepayment
  bool _showdebtrepayment = false;
  String debtrepaymentvalue = '-Select-';
  bool _showdebtrepaymentdescription = false;
  String? debtrepaymentError;

  //recurring
  bool showrecurring = false;

  String? dropdownError;

  bool isValid = false;
  String? newlabell;

  String option = '-Select-';

  static const expenditure = <String>[
    '-Select-',
    'Accommodation',
    'Transportation',
    'Home and Family',
    'Utilities',
    'Debt Repayment',
  ];
  static const accommodation = <String>[
    '-Select-',
    'Mortgage',
    'Rent',
    'Mortgage Reduction',
    'Other',
  ];
  static const transportation = <String>[
    '-Select-',
    'Fuel',
    'Insurance',
    'Road Tax',
    'Warranty Premium',
    'MOT',
    'Trains & Taxis',
    'Misc',
    'Others',
  ];
  static const homefamily = <String>[
    '-Select-',
    'Groceries',
    'Children Allowance',
    'Parents Allowance',
    'Personal Allowance',
    'Clothings',
    'Eating Out',
    'Entertainment',
    'Life Insurance',
    'Home & Emergency Insurance',
    'Childcare',
    'Extra-Curricula',
    'Others',
  ];

  static const utilities = <String>[
    '-Select-',
    'Council / Property Tax',
    'Gas',
    'Electric',
    'Water & Sewage',
    'TV & Cable Subscriptions',
    'Internet / Broadband',
    'Mobile Phone',
    'Others',
  ];

  static const debtrepayment = <String>[
    '-Select-',
    'Loan',
    'Credit Card',
    'Other',
  ];

  final List<DropdownMenuItem<String>> utilitiesList = utilities
      .map(
        (String value) => DropdownMenuItem<String>(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          value: value,
        ),
      )
      .toList();

  final List<DropdownMenuItem<String>> debtrepaymentList = debtrepayment
      .map(
        (String value) => DropdownMenuItem<String>(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          value: value,
        ),
      )
      .toList();

  final List<DropdownMenuItem<String>> expenditureList = expenditure
      .map(
        (String value) => DropdownMenuItem<String>(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          value: value,
        ),
      )
      .toList();
  final List<DropdownMenuItem<String>> accommodationList = accommodation
      .map(
        (String value) => DropdownMenuItem<String>(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          value: value,
        ),
      )
      .toList();
  final List<DropdownMenuItem<String>> transportationList = transportation
      .map(
        (String value) => DropdownMenuItem<String>(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          value: value,
        ),
      )
      .toList();

  final List<DropdownMenuItem<String>> homefamilyList = homefamily
      .map(
        (String value) => DropdownMenuItem<String>(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          value: value,
        ),
      )
      .toList();
  @override
  Widget build(BuildContext context) {
    var allocationamount = data['data']["current_seed"]["budget_amount"];
    String currency = context.watch<Providers>().snapshotmodel.currency;
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blue.withOpacity(.05),
      appBar: AppBar(
        backgroundColor: Colors.blue.withOpacity(.05),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Expenditure Allocation',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: context.width(.050),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _key,
          child: Column(
            children: [
              SizedBox(height: height * .02),
              Padding(
                padding: EdgeInsets.only(left: width * .08),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Expenditure Category",
                      style: TextStyle(
                        fontSize: width * .05,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * .01),
              Container(
                padding: EdgeInsets.only(left: width * .02, right: width * .02),
                width: width,
                margin: EdgeInsets.only(left: width * .08, right: width * .08),
                //width: width * .9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                  border: Border.all(color: Color.fromARGB(255, 196, 196, 196)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    focusColor: Theme.of(context).primaryColor,
                    value: expenditurevalue,
                    items: expenditureList,
                    onChanged: (value) {
                      setState(() {
                        expenditurevalue = value!;
                        if (expenditurevalue == expenditure[0]) {
                          dropdownError = null;
                          isValid = false;
                        }
                        if (expenditurevalue != expenditure[0]) {
                          dropdownError = '';
                          isValid = true;
                        }
                        if (expenditurevalue == expenditure[1] ||
                            expenditurevalue == expenditure[2] ||
                            expenditurevalue == expenditure[3] ||
                            expenditurevalue == expenditure[4] ||
                            expenditurevalue == expenditure[5]) {
                          _showAccommodationdescription = false;
                          _showTransportationdescription = false;
                          _showhomefamilydescription = false;
                          _showutilitiesdescription = false;
                        }

                        print(value);
                        if (value == expenditure[1]) {
                          _showAccommodation = true;
                        } else {
                          _showAccommodation = false;
                        }
                        if (expenditurevalue == expenditure[2]) {
                          _showTransportation = true;
                        } else {
                          _showTransportation = false;
                        }
                        if (expenditurevalue == expenditure[3]) {
                          _showhomefamily = true;
                        } else {
                          _showhomefamily = false;
                        }
                        if (expenditurevalue == expenditure[4]) {
                          _showutilities = true;
                        } else {
                          _showutilities = false;
                        }
                        if (expenditurevalue == expenditure[5]) {
                          _showdebtrepayment = true;
                        } else {
                          _showdebtrepayment = false;
                        }
                      });

                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                  ),
                ),
              ),
              dropdownError == null
                  ? SizedBox.shrink()
                  : Padding(
                      padding: EdgeInsets.only(left: width * .08),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            dropdownError ?? "",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),

              //Accommodation
              Visibility(
                visible: _showAccommodation,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: width * .08,
                        top: height * .005,
                        right: width * .08,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Description Label",
                            style: TextStyle(
                              fontSize: width * .05,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: width * .02,
                        right: width * .02,
                      ),
                      width: width,
                      margin: EdgeInsets.only(
                        left: width * .08,
                        top: height * .01,
                        right: width * .08,
                      ),
                      //width: width * .9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white,
                        border: Border.all(
                          color: Color.fromARGB(255, 196, 196, 196),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          focusColor: Theme.of(context).primaryColor,
                          value: accommodationvalue,
                          items: accommodationList,
                          onChanged: (value) {
                            setState(() {
                              accommodationvalue = value!;

                              print(value);
                              if (accommodationvalue != '-Select-') {
                                accommodationError = " ";
                                isValid = true;
                              }
                              if (accommodationvalue == accommodation[4]) {
                                _showAccommodationdescription = true;
                              } else {
                                _showAccommodationdescription = false;
                              }
                              if (expenditurevalue == expenditure[2]) {
                                _showAccommodationdescription = false;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    accommodationError == null
                        ? SizedBox.shrink()
                        : Padding(
                            padding: EdgeInsets.only(left: width * .08),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  accommodationError ?? "",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
              SizedBox(height: height * .01),
              Visibility(
                replacement: SizedBox.shrink(),
                maintainSize: false,
                visible: _showAccommodationdescription,
                child: ETextForm(
                  hintText: 'Create a new Accommodation label',
                  controller: newaccommodationlabel,
                  symbol: ' ',
                  // ignore: missing_return
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Please enter label';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                ),
              ),

              //Transportation
              Visibility(
                visible: _showTransportation,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: width * .08,
                        top: height * .005,
                        right: width * .08,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Description Label",
                            style: TextStyle(
                              fontSize: width * .05,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: width * .02,
                        right: width * .02,
                      ),
                      width: width,
                      margin: EdgeInsets.only(
                        left: width * .08,
                        top: height * .01,
                        right: width * .08,
                      ),
                      //width: width * .9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white,
                        border: Border.all(
                          color: Color.fromARGB(255, 196, 196, 196),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          focusColor: Theme.of(context).primaryColor,
                          value: transportationvalue,
                          items: transportationList,
                          onChanged: (value) {
                            setState(() {
                              transportationvalue = value!;

                              print(value);
                              if (transportationvalue == transportation[8]) {
                                _showTransportationdescription = true;
                              } else {
                                _showTransportationdescription = false;
                              }
                              if (expenditurevalue == expenditure[2]) {
                                _showAccommodationdescription = false;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    transportationError == null
                        ? SizedBox.shrink()
                        : Padding(
                            padding: EdgeInsets.only(left: width * .08),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  transportationError ?? "",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
              Visibility(
                replacement: SizedBox.shrink(),
                maintainSize: false,
                visible: _showTransportationdescription,
                child: ETextForm(
                  hintText: 'Create a new Transportation label',
                  controller: newtransportationlabel,
                  symbol: ' ',
                  // ignore: missing_return
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Please enter label';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                ),
              ),

              //HomeFamily
              Visibility(
                visible: _showhomefamily,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: width * .08,
                        top: height * .005,
                        right: width * .08,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Description Label",
                            style: TextStyle(
                              fontSize: width * .05,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: width * .02,
                        right: width * .02,
                      ),
                      width: width,
                      margin: EdgeInsets.only(
                        left: width * .08,
                        top: height * .01,
                        right: width * .08,
                      ),
                      //width: width * .9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white,
                        border: Border.all(
                          color: Color.fromARGB(255, 196, 196, 196),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          focusColor: Theme.of(context).primaryColor,
                          value: homefamilyvalue,
                          items: homefamilyList,
                          onChanged: (value) {
                            setState(() {
                              homefamilyvalue = value!;

                              print(value);
                              if (homefamilyvalue == homefamily[12]) {
                                _showhomefamilydescription = true;
                              } else {
                                _showhomefamilydescription = false;
                              }

                              if (expenditurevalue == expenditure[2]) {
                                _showAccommodationdescription = false;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    homefamilyError == null
                        ? SizedBox.shrink()
                        : Padding(
                            padding: EdgeInsets.only(left: width * .08),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  homefamilyError ?? "",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
              Visibility(
                replacement: SizedBox.shrink(),
                maintainSize: false,
                visible: _showhomefamilydescription,
                child: ETextForm(
                  hintText: 'Create a new label',
                  controller: newhomefamilylabel,
                  symbol: ' ',
                  // ignore: missing_return
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Please enter label';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                ),
              ),

              //utilities
              Visibility(
                visible: _showutilities,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: width * .08,
                        top: height * .005,
                        right: width * .08,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Description Label",
                            style: TextStyle(
                              fontSize: width * .05,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: width * .02,
                        right: width * .02,
                      ),
                      width: width,
                      margin: EdgeInsets.only(
                        left: width * .08,
                        top: height * .01,
                        right: width * .08,
                      ),
                      //width: width * .9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white,
                        border: Border.all(
                          color: Color.fromARGB(255, 196, 196, 196),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          focusColor: Theme.of(context).primaryColor,
                          value: utilitiesvalue,
                          items: utilitiesList,
                          onChanged: (value) {
                            setState(() {
                              utilitiesvalue = value!;

                              print(value);
                              if (utilitiesvalue == utilities[8]) {
                                _showutilitiesdescription = true;
                              } else {
                                _showutilitiesdescription = false;
                              }

                              if (expenditurevalue == expenditure[2]) {
                                _showAccommodationdescription = false;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    utilitiesError == null
                        ? SizedBox.shrink()
                        : Padding(
                            padding: EdgeInsets.only(left: width * .08),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  utilitiesError ?? "",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
              Visibility(
                replacement: SizedBox.shrink(),
                maintainSize: false,
                visible: _showutilitiesdescription,
                child: ETextForm(
                  hintText: 'Create a new label',
                  controller: newutilitieslabel,
                  symbol: ' ',
                  // ignore: missing_return
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Please enter label';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                ),
              ),

              //utilities
              Visibility(
                visible: _showdebtrepayment,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: width * .08,
                        top: height * .005,
                        right: width * .08,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Description Label",
                            style: TextStyle(
                              fontSize: width * .05,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: width * .02,
                        right: width * .02,
                      ),
                      width: width,
                      margin: EdgeInsets.only(
                        left: width * .08,
                        top: height * .01,
                        right: width * .08,
                      ),
                      //width: width * .9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white,
                        border: Border.all(
                          color: Color.fromARGB(255, 196, 196, 196),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          focusColor: Theme.of(context).primaryColor,
                          value: debtrepaymentvalue,
                          items: debtrepaymentList,
                          onChanged: (value) {
                            setState(() {
                              debtrepaymentvalue = value!;

                              print(value);
                              if (debtrepaymentvalue == debtrepayment[3]) {
                                _showdebtrepaymentdescription = true;
                              } else {
                                _showdebtrepaymentdescription = false;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    debtrepaymentError == null
                        ? SizedBox.shrink()
                        : Padding(
                            padding: EdgeInsets.only(left: width * .08),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  debtrepaymentError ?? "",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
              Visibility(
                replacement: SizedBox.shrink(),
                maintainSize: false,
                visible: _showdebtrepaymentdescription,
                child: ETextForm(
                  hintText: 'Create a new label',
                  controller: newdebtrepaymentlabel,
                  symbol: ' ',
                  // ignore: missing_return
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Please enter label';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                ),
              ),

              SizedBox(height: height * .005),
              E2TextForm(
                name: "Amount",
                hintText: ' 0.00',
                controller: expenditureAmount,
                symbol: '$currency',
                // ignore: missing_return
                validator: (value) {
                  if (value!.trim().isEmpty) {
                    return 'Please enter your Amount';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: height * .01),
              E2TextForm(
                name: "Note",
                hintText: '',
                controller: savingNote,
                keyboardType: TextInputType.text,
                symbol: '',
                maxLines: 4,
              ),
              SizedBox(height: height * .03),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: width * .08),
                    child: Row(
                      children: [
                        Text(
                          "Recurring",
                          style: TextStyle(
                            fontSize: width * .05,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: width * .12),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AdvancedSwitch(
                        activeColor: Colors.red,
                        inactiveColor: Colors.grey,
                        activeChild: Text('On'),
                        inactiveChild: Text('Off'),
                        width: 70.0,
                        height: 30.0,
                        controller: _controller,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: height * .03),
              Visibility(
                replacement: SizedBox.shrink(),
                maintainSize: false,
                visible: showrecurring,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: width * .08,
                    top: width * .01,
                    right: width * .08,
                  ),
                  child: TextFormField(
                    controller:
                        savdateinput, //editing controller of this TextField
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return 'Please enter date';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.calendar_month),
                      labelText: "Select your preferred date",
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(width * .02),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 196, 196, 196),
                        ),
                        borderRadius: BorderRadius.circular(width * .02),
                      ),
                    ),
                    readOnly:
                        true, //set it true, so that user will not able to edit text
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(
                          2000,
                        ), //DateTime.now() - not to allow to choose before today.
                        lastDate: DateTime.now(),
                      );

                      if (pickedDate != null) {
                        print(
                          pickedDate,
                        ); //pickedDate output format => 2021-03-10 00:00:00.000
                        String formattedDate = DateFormat(
                          'yyyy-MM-dd',
                        ).format(pickedDate);
                        print(
                          formattedDate,
                        ); //formatted date output using intl package =>  2021-03-16
                        //you can implement different kind of Date Format here according to your requirement

                        setState(() {
                          savdateinput.text =
                              formattedDate; //set output date to TextField value.
                        });
                      } else {
                        print("Date is not selected");
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: height * .03),

              /* Visibility(
                replacement: SizedBox.shrink(),
                maintainSize: false,
                visible: showrecurring,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: width * .08, top: height * .02, right: width * .08),
                  child: TextFormField(
                    controller:
                        savdateinput, //editing controller of this TextField
                    validator: (value) {
                      if (value.trim().isEmpty) {
                        return 'Please enter date';
                      }
                    },
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.calendar_month),
                      labelText: "Select your preferred date",
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(width * .02)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 196, 196, 196),
                          ),
                          borderRadius: BorderRadius.circular(width * .02)),
                    ),
                    readOnly:
                        true, //set it true, so that user will not able to edit text
                    onTap: () async {
                      DateTime pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(
                              2000), //DateTime.now() - not to allow to choose before today.
                          lastDate: DateTime(2101));

                      if (pickedDate != null) {
                        print(
                            pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                        print(
                            formattedDate); //formatted date output using intl package =>  2021-03-16
                        //you can implement different kind of Date Format here according to your requirement

                        setState(() {
                          savdateinput.text =
                              formattedDate; //set output date to TextField value.
                          print(savdateinput.text);
                        });
                      } else {
                        print("Date is not selected");
                      }
                    },
                  ),
                ),
              ), */
              SizedBox(height: height * .06),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.only(
                    left: width * .10,
                    right: width * .10,
                  ),
                ),
                onPressed: () async {
                  try {
                    bool isValid = _key.currentState!.validate();
                    if (expenditurevalue == '-Select-') {
                      setState(() => dropdownError = "Please select an option");
                      isValid = false;
                    } else {
                      //recurring

                      //debtrepayment
                      if (expenditurevalue == expenditure[5]) {
                        if (debtrepaymentvalue == '-Select-') {
                          setState(
                            () =>
                                debtrepaymentError = "Please select an option",
                          );
                          isValid = false;
                          print('acc');
                          return;
                        }
                      }
                      if (expenditurevalue == expenditure[5]) {
                        if (debtrepaymentvalue != '-Select-') {
                          setState(() => debtrepaymentError = " ");
                          isValid = true;
                          print('aok');
                        }
                      }

                      //utilities
                      if (expenditurevalue == expenditure[4]) {
                        if (utilitiesvalue == '-Select-') {
                          setState(
                            () => utilitiesError = "Please select an option",
                          );
                          isValid = false;
                          print('acc');
                          return;
                        }
                      }
                      if (expenditurevalue == expenditure[4]) {
                        if (utilitiesvalue != '-Select-') {
                          setState(() => utilitiesError = " ");
                          isValid = true;
                          print('aok');
                        }
                      }

                      //Home and Family
                      if (expenditurevalue == expenditure[3]) {
                        if (homefamilyvalue == '-Select-') {
                          setState(
                            () => homefamilyError = "Please select an option",
                          );
                          isValid = false;
                          print('acc');
                          return;
                        }
                      }
                      if (expenditurevalue == expenditure[3]) {
                        if (homefamilyvalue != '-Select-') {
                          setState(() => homefamilyError = " ");
                          isValid = true;
                          print('aok');
                        }
                      }

                      //transportation
                      if (expenditurevalue == expenditure[2]) {
                        if (transportationvalue == '-Select-') {
                          setState(
                            () =>
                                transportationError = "Please select an option",
                          );
                          isValid = false;
                          print('acc');
                          return;
                        }
                      }
                      if (expenditurevalue == expenditure[2]) {
                        if (transportationvalue != '-Select-') {
                          setState(() => transportationError = " ");
                          isValid = true;
                          print('aok');
                        }
                      }

                      //accommodation
                      if (expenditurevalue == expenditure[1]) {
                        if (accommodationvalue == '-Select-') {
                          setState(
                            () =>
                                accommodationError = "Please select an option",
                          );
                          isValid = false;
                          print('acc');
                          return;
                        }
                      }
                      if (expenditurevalue == expenditure[1]) {
                        if (accommodationvalue != '-Select-') {
                          setState(() => accommodationError = " ");
                          isValid = true;
                        }
                      }

                      if (expenditurevalue == expenditure[1]) {
                        if (accommodationvalue != accommodation[4]) {
                          setState(() {
                            label = accommodationvalue.toString();
                          });
                        } else if (accommodationvalue == accommodation[4]) {
                          setState(() {
                            label = newaccommodationlabel.text.trim();
                          });
                        }
                      } else if (expenditurevalue == expenditure[2]) {
                        if (transportationvalue != transportation[8]) {
                          setState(() {
                            label = transportationvalue.toString();
                          });
                        } else if (transportationvalue == transportation[8]) {
                          setState(() {
                            label = newtransportationlabel.text.trim();
                          });
                        }
                      } else if (expenditurevalue == expenditure[3]) {
                        if (homefamilyvalue != homefamily[12]) {
                          setState(() {
                            label = homefamilyvalue.toString();
                          });
                        } else if (homefamilyvalue == homefamily[12]) {
                          setState(() {
                            label = newhomefamilylabel.text.trim();
                          });
                        }
                      } else if (expenditurevalue == expenditure[4]) {
                        if (utilitiesvalue != utilities[8]) {
                          setState(() {
                            label = utilitiesvalue.toString();
                          });
                        } else if (utilitiesvalue == utilities[8]) {
                          setState(() {
                            label = newutilitieslabel.text.trim();
                          });
                        }
                      } else if (expenditurevalue == expenditure[5]) {
                        if (debtrepaymentvalue != debtrepayment[3]) {
                          setState(() {
                            label = debtrepaymentvalue.toString();
                          });
                        } else if (debtrepaymentvalue == debtrepayment[3]) {
                          setState(() {
                            label = newdebtrepaymentlabel.text.trim();
                          });
                        }
                      }

                      if (expenditurevalue != '-Select-') {
                        setState(() => dropdownError = " ");
                        isValid = true;

                        const one = "1";
                        const zero = "0";
                        if (_key.currentState!.validate()) {
                          EasyLoading.show(
                            status: 'Loading',
                            dismissOnTap: false,
                          );
                          // bool result = await isInternetAvailable();
                          // if (!result) {
                          //   dialogBox.information(context, 'Status',
                          //       'Check your Internet Connection');
                          //   EasyLoading.dismiss();
                          //   return;
                          // }
                          int amun = int.parse(expenditureAmount.text);
                          if (num.parse(allocationamount) < amun) {
                            EasyLoading.dismiss();
                            Fluttertoast.showToast(
                              backgroundColor: Color.fromARGB(
                                255,
                                255,
                                187,
                                51,
                              ),
                              textColor: Colors.black,
                              msg:
                                  'You have used up all Available Allocation or Your Saving amount is more than your Availabel Allocation  , Please Set Budget Amount ',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                            return;
                          }
                          var recurring;
                          var dateinput;
                          int? amountValue = int.tryParse(savdateinput.text);
                          print('a:$amountValue');
                          if (_checked == true) {
                            setState(() {
                              recurring = amountValue;
                              dateinput = savdateinput.text;
                            });
                          } else {
                            setState(() {
                              recurring = 0;
                              dateinput = 0;
                            });
                          }

                          var expenditure;
                          var acc = expenditurevalue.toLowerCase();
                          if (acc == 'home and family') {
                            setState(() {
                              expenditure = 'family';
                            });
                          } else if (acc == 'debt repayment') {
                            setState(() {
                              expenditure = 'debt_repayment';
                            });
                          } else {
                            setState(() {
                              expenditure = expenditurevalue.toLowerCase();
                            });
                          }
                          print('Expenditure: $expenditurevalue');
                          print('Accommodation: $transportationvalue');
                          print('AccomodationLabel: $label');
                          print('state: $recurring');

                          var _url = Uri.parse(
                            "$baseUrl/app/seed/allocate/budget?category=expenditure",
                          );
                          var _url2 = Uri.parse(
                            "$baseUrl/app/seed/allocate/budget",
                          );
                          var _url3 = Uri.parse("$baseUrl/app/seed/");
                          var _urlbudget = Uri.parse(
                            "$baseUrl/app/seed/store/budget",
                          );
                          final prefs = await SharedPreferences.getInstance();
                          var token = prefs.getString('tokenDB');
                          int all = int.parse(allocationamount.toString());
                          var setbudget = (all - amun);
                          print("Setbudget: $setbudget");
                          print('Expenditure: $expenditure');
                          print('Expenditure: $acc');
                          print("Setbudget: $setbudget");
                          print("dateinput:$dateinput");
                          final responsebudget = await http.post(
                            _urlbudget,
                            body: {'budget': setbudget.toString()},
                            headers: {
                              "Authorization": 'Bearer $token',
                              "Accept": "application/json",
                              "Content-Type":
                                  "application/x-www-form-urlencoded",
                            },
                            encoding: Encoding.getByName("utf-8"),
                          );
                          if (responsebudget.statusCode == 200) {
                            final response = await http.post(
                              _url,
                              body: {
                                'category': 'expenditure',
                                'label': label,
                                'code': 'rjkhbhfhdhbd',
                                'amount': expenditureAmount.text.trim(),
                                'note': savingNote.text.trim() == ''
                                    ? ''
                                    : savingNote.text.trim(),
                                'recuring': _checked == true ? one : zero,
                                'expenditure': expenditure,
                                'date': dateinput,
                              },
                              headers: {
                                "Authorization": 'Bearer $token',
                                "Accept": "application/json",
                                "Content-Type":
                                    "application/x-www-form-urlencoded",
                              },
                              encoding: Encoding.getByName("utf-8"),
                            );

                            if (response.statusCode == 200) {
                              var responseExpen = await http.get(
                                _url2,
                                headers: {
                                  "Authorization": 'Bearer $token',
                                  "Accept": "application/json",
                                  "Content-Type":
                                      "application/x-www-form-urlencoded",
                                },
                              );
                              if (responseExpen.statusCode == 200) {
                                var body = jsonDecode(responseExpen.body);
                                var expendituredata =
                                    body["data"]['budget_allocations'];
                                int length = expendituredata.length;
                                print('Expenditure:$length');

                                var dataExpen =
                                    body["data"]['budget_expenditures'];
                                List res = dataExpen;
                                print('data:$data');
                                setState(() {
                                  _dataExpen = res
                                      .map(
                                        (dataExpen) =>
                                            SavingAllexpenditure.fromJson(
                                              dataExpen,
                                            ),
                                      )
                                      .toList();
                                });
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FSExpenditureAllocationSummary(
                                          data: _dataExpen,
                                        ),
                                  ),
                                );
                                EasyLoading.dismiss();
                                Fluttertoast.showToast(
                                  backgroundColor: Color(0xffD13B56),
                                  msg:
                                      'Expenditure Allocation has been created',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              }
                            } else {
                              print('Error');
                            }
                          } else {
                            EasyLoading.dismiss();
                            Fluttertoast.showToast(
                              backgroundColor: Colors.red,
                              //textColor: Colors.white,
                              msg:
                                  'Amount is greater than Available allocation',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                          }
                        }
                      }
                    }
                  } catch (e) {
                    print(e);
                    EasyLoading.dismiss();
                    //Navigator.pop(context);
                  }
                },
                child: Text(
                  "Submit",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SavAllocation {
  String token;
  SavAllocation(this.token);

  factory SavAllocation.fromJSON(dynamic json) {
    //return Token(json['access_token'] as String);
    return SavAllocation(json['data']['access_token'] as String);
  }

  @override
  String toString() {
    return ' { ${this.token} } ';
  }
}
