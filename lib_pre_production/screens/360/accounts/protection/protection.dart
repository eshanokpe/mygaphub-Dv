import 'dart:io';
import 'dart:convert'; // Added for json.decode
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:http_parser/http_parser.dart'; // Added for MediaType
import 'package:path/path.dart' as p;

class Protection extends StatefulWidget {
  const Protection({super.key});

  @override
  _ProtectionState createState() => _ProtectionState();
}

class _ProtectionState extends State<Protection> with WidgetsBindingObserver {
  //bool _isPaused = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("DidChangeDependencies");
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.removeObserver(this);

    print("InitState");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        null;
        //print('appLifeCycleState inactive');
        // _showLockScreenStream.add(true);
        break;
      case AppLifecycleState.resumed:
        null;
        //print('appLifeCycleState resumed');
        // _showLockScreenStream.add(true);
        break;
      case AppLifecycleState.paused:
        null;
        //print('appLifeCycleState paused');

        break;
      case AppLifecycleState.detached:
        null;
        //print('appLifeCycleState detached');
        break;
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
    }
  }

  @override
  void deactivate() {
    WidgetsBinding.instance.removeObserver(this);
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  var key = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController details = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController provider = TextEditingController();
  TextEditingController sumAssured = TextEditingController();
  TextEditingController premium = TextEditingController();
  TextEditingController startCon = TextEditingController();
  TextEditingController endCon = TextEditingController();

  FilePickerResult? result;
  File? _file;
  Dio dio = Dio();
  // FileType pickingType;
  String? path;
  String? dirPath;
  Directory? rootPath;
  DialogBox dialogBox = DialogBox();
  bool show = false;
  var startDB = "";
  var endDB = "";
  DateTime? start;
  DateTime? end;
  // File document;
  static const subUnits1 = <String>[
    '-Select-',
    'Life Insurance',
    'Home Insurance (including Building & Content)',
    'Car Insurance',
    'Emergency Cover',
    'Critical Illness Cover',
    'Income Protection',
    'Gadget/Device Protection',
    'Health Insurance',
    'Others',
  ];
  String category = '-Select-';
  final List<DropdownMenuItem<String>> categoryList = subUnits1
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
      )
      .toList();

  static const subUnits2 = <String>[
    '-Select-',
    'Whole of Life',
    'Term Assurance',
    'Endowment Policy',
    'Annuity Plan',
    'Comprehensive Cover',
    'Third Party Cover',
    'Others',
  ];
  String type = '-Select-';
  final List<DropdownMenuItem<String>> typeList = subUnits2
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
      )
      .toList();

  static const subUnits3 = <String>['-Select-', 'Annually', 'Monthly'];
  String frequency = '-Select-';

  final List<DropdownMenuItem<String>> frequencyList = subUnits3
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
      )
      .toList();

  static const subUnits4 = <String>[
    '-Select-',
    'Direct Debit',
    'Debit/Credit Card',
    'Standing Order',
  ];
  String paymentType = '-Select-';

  final List<DropdownMenuItem<String>> paymentTypeList = subUnits4
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
      )
      .toList();

  // Helper to determine MediaType based on file extension
  MediaType? _getContentTypeForExtension(String extension) {
    switch (extension.toLowerCase()) {
      case ".pdf":
        return MediaType('application', 'pdf');
      case ".doc":
        return MediaType('application', 'msword');
      case ".docx":
        return MediaType(
          'application',
          'vnd.openxmlformats-officedocument.wordprocessingml.document',
        );
      default:
        return MediaType('application', 'octet-stream'); // Generic fallback
    }
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

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Add Account: Protection",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(4),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[200],
          padding: EdgeInsets.symmetric(vertical: height * .02),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .04),
                child: Form(
                  key: key,
                  child: Column(
                    children: [
                      Text(
                        "(Complete the form and attach your documentation)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              const TextSpan(
                                text: 'What Category of Protection:',
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                          color: Colors.white,
                          border: Border.all(),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  Colors.white, // Set background color to white
                              borderRadius: BorderRadius.circular(
                                8,
                              ), // Optional: Add border radius
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ), // Optional: Add border
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButton<String>(
                              focusColor: Theme.of(context).primaryColor,
                              value: category,
                              isExpanded: true,
                              items: categoryList,
                              dropdownColor: Colors.white,
                              onChanged: (subval) {
                                setState(() {
                                  category = subval!;
                                });
                                FocusScope.of(
                                  context,
                                ).requestFocus(FocusNode());
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              const TextSpan(
                                text: 'What type of protection is this:',
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                          color: Colors.white,
                          border: Border.all(),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            focusColor: Theme.of(context).primaryColor,
                            value: type,
                            items: typeList,
                            dropdownColor: Colors.white,
                            onChanged: (subval) {
                              setState(() {
                                type = subval!;
                              });
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Details of the protection:',
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      TextFormField(
                        controller: details,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: 'E.g. Life Cover for myself',
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: TextStyle(fontSize: width * .03),
                          contentPadding: EdgeInsets.all(width * .03),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter details';
                          }
                          // if (value.length < 5) {
                          //   Fluttertoast.showToast(
                          //       msg:
                          //           "Details must be at least 5 characters long");
                          //   return 'Details must be at least 5 characters long';
                          // }
                          return null; // No error
                        },
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Who is the provider of the policy:',
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      TextFormField(
                        controller: provider,
                        keyboardType: TextInputType.name,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: 'E.g. Legal & General',
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: TextStyle(fontSize: width * .03),
                          contentPadding: EdgeInsets.all(width * .03),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter details';
                          }
                          // if (value.length < 5) {
                          //   Fluttertoast.showToast(
                          //       msg:
                          //           "Details must be at least 5 characters long");
                          //   return 'Details must be at least 5 characters long';
                          // }
                          return null; // No error
                        },
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'What is the provider’s contact: ',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      TextFormField(
                        controller: contact,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'E.g. www.landg.com',
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: TextStyle(fontSize: width * .03),
                          contentPadding: EdgeInsets.all(width * .03),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter details';
                          }
                          if (value.length < 5) {
                            Fluttertoast.showToast(
                              msg: "Details must be at least 5 characters long",
                            );

                            return 'Details must be at least 5 characters long';
                          }
                          return null; // No error
                        },
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              const TextSpan(text: 'What’s the sum assured:'),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      TextFormField(
                        controller: sumAssured,
                        inputFormatters: [amountValidator],
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: 'E.g. £250,000.00',
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: TextStyle(fontSize: width * .03),
                          contentPadding: EdgeInsets.all(width * .03),
                          border: const OutlineInputBorder(),
                        ),
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return 'Please enter details';
                        //   }
                        //   if (value.length < 5) {
                        //     return 'Details must be at least 5 characters long';
                        //   }
                        //   return null; // No error
                        // },
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              const TextSpan(
                                text: 'What is the premium you pay:',
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      TextFormField(
                        controller: premium,
                        inputFormatters: [amountValidator],
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: 'E.g. £500',
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: TextStyle(fontSize: width * .03),
                          contentPadding: EdgeInsets.all(width * .03),
                          border: const OutlineInputBorder(),
                        ),
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return 'Please enter details';
                        //   }
                        //   if (value.length < 5) {
                        //     return 'Details must be at least 5 characters long';
                        //   }
                        //   return null; // No error
                        // },
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              const TextSpan(
                                text: 'What’s your payment frequency:',
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                          color: Colors.white,
                          border: Border.all(),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            focusColor: Theme.of(context).primaryColor,
                            value: frequency,
                            hint: const Text('-Select-'),
                            items: frequencyList,
                            dropdownColor: Colors.white,
                            onChanged: (subval) {
                              setState(() {
                                frequency = subval!;
                              });
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Payment Type:',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
                          color: Colors.white,
                          border: Border.all(),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            focusColor: Theme.of(context).primaryColor,
                            value: paymentType,
                            items: paymentTypeList,
                            dropdownColor: Colors.white,
                            onChanged: (subval) {
                              setState(() {
                                paymentType = subval!;
                              });
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              const TextSpan(text: 'Cover Start/End:'),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                FocusScope.of(
                                  context,
                                ).requestFocus(FocusNode());
                                // var datez = DateTime.parse(start.text);
                                showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                ).then((value) {
                                  setState(() {
                                    if (value != null) {
                                      startDB = DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(value);
                                      startCon.text = startDB;
                                      start = value;
                                    }
                                  });
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(FocusNode());
                                });
                              },
                              child: TextFormField(
                                controller: startCon,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  enabled: false,
                                  fillColor: Colors.white,
                                  suffixIcon: Icon(
                                    Icons.date_range,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  hintStyle: TextStyle(fontSize: width * .03),
                                  contentPadding: EdgeInsets.all(width * .03),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: width * .05),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                FocusScope.of(
                                  context,
                                ).requestFocus(FocusNode());
                                // var datez = DateTime.parse(end.text);
                                showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                ).then((value) {
                                  setState(() {
                                    if (value != null) {
                                      endDB = DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(value);
                                      endCon.text = endDB;
                                      end = value;
                                    }
                                  });
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(FocusNode());
                                });
                              },
                              child: TextFormField(
                                controller: endCon,
                                enabled: false,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  suffixIcon: Icon(
                                    Icons.date_range,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  hintStyle: TextStyle(fontSize: width * .03),
                                  contentPadding: EdgeInsets.all(width * .03),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * .03),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors
                                        .black, //Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  children: const [
                                    TextSpan(text: 'Attach Document:'),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      width * .015,
                                    ),
                                  ),
                                  backgroundColor: Colors.blueAccent,
                                ),
                                child: Text(
                                  "Select File",
                                  style: TextStyle(
                                    fontSize: width * .035,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    result = await FilePicker.platform.pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: [
                                        'pdf',
                                        'doc',
                                        'docx',
                                      ], // Extensions without dots for picker
                                    );

                                    if (result == null ||
                                        result!.files.isEmpty) {
                                      Fluttertoast.showToast(
                                        msg:
                                            "File selection cancelled or no file chosen.",
                                      );
                                      // Optionally clear _file if a previous file was selected and user cancels:
                                      // setState(() { _file = null; });
                                      return;
                                    }

                                    final pickedFile = result!.files.single;
                                    final filePath = pickedFile.path;

                                    if (filePath == null) {
                                      Fluttertoast.showToast(
                                        msg: "Selected file has no path.",
                                      );
                                      return;
                                    }

                                    // Use p.basename to safely get filename from path for extension
                                    final actualFileNameForExtension = p
                                        .basename(filePath);
                                    final ext = p
                                        .extension(actualFileNameForExtension)
                                        .toLowerCase();

                                    const allowedFileExtensions = [
                                      ".pdf",
                                      ".doc",
                                      ".docx",
                                    ]; // Extensions with dots for validation

                                    if (!allowedFileExtensions.contains(ext)) {
                                      Fluttertoast.showToast(
                                        msg:
                                            "Unsupported file type: $ext. Allowed: .pdf, .doc, .docx",
                                      );
                                      // Clear _file if an unsupported file was somehow picked
                                      // setState(() { _file = null; result = null; }); // result is already updated by FilePicker
                                      return;
                                    }

                                    setState(() {
                                      _file = File(filePath);
                                      // The UI text `result!.files.single.name` will update automatically due to `setState`
                                    });
                                  } catch (e) {
                                    print("Error picking file: $e");
                                    Fluttertoast.showToast(
                                      msg:
                                          "Error picking file: ${e.toString()}",
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              _file ==
                                      null // Check _file instead of result for display consistency
                                  ? "No file selected yet"
                                  : result!.files.single.name,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Text(
                            'Document must be .doc, .docx, .pdf',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * .05),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(width * .01),
                          ),
                        ),
                        onPressed: () {
                          // print('Selected startCon: ${_file}');
                          if (frequency == '-Select-') {
                            Fluttertoast.showToast(
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              msg: 'Please select a frequency',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                            return;
                          }
                          if (paymentType == '-Select-') {
                            Fluttertoast.showToast(
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              msg: 'Please select a Payment Type',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                            return;
                          }
                          if (startCon.text.isEmpty || endCon.text.isEmpty) {
                            // Changed from && to ||
                            Fluttertoast.showToast(
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              msg:
                                  'Please select both cover start and end dates',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                            return;
                          }
                          // if (_file == null) { // Removed mandatory file check
                          //   // Check if a file is selected
                          //   Fluttertoast.showToast(
                          //       backgroundColor: Colors.red,
                          //       textColor: Colors.white,
                          //       msg:
                          //           'Please attach a document. It is mandatory.',
                          //       toastLength: Toast.LENGTH_SHORT,
                          //       gravity: ToastGravity.BOTTOM);
                          //   return;
                          // }
                          if (key.currentState!.validate()) {
                            saveCash(_file); // Pass _file, which can be null
                          }
                        },
                        child: Text(
                          "Submit",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: height * .01),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              TextSpan(
                                text: "* ",
                                style: TextStyle(
                                  fontSize: width * .035,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const TextSpan(text: 'Fields are mandatory'),
                            ],
                          ), // Consider if this text needs updating if document is optional
                        ),
                      ),
                      SizedBox(height: height * .05),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveCash(File? filePath) async {
    // filePath is now nullable
    print(
      "File path being processed: ${filePath?.path}",
    ); // Use null-safe access
    try {
      FocusScope.of(context).requestFocus(FocusNode());

      // Validate mandatory fields
      // Date and file presence are checked before calling saveCash
      if (category == "-Select-" ||
          type == "-Select-" ||
          frequency == "-Select-" ||
          paymentType == "-Select-") {
        // dialogBox.information might pop the loading dialog if not careful.
        // Fluttertoast is simpler here as loading dialog is shown after this.
        Fluttertoast.showToast(
          msg: "Please select an option for all mandatory dropdown fields.",
        );
        return;
      }
      // startDB and endDB should be filled if date checks passed before calling saveCash

      // Show loading dialog
      dialogBox.waiting(context, "Saving");

      // Retrieve token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null || token.isEmpty) {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: "Authentication token is missing.");
        return;
      }

      // Build the form data
      final formDataMap = {
        "category": category,
        "type": type,
        "contact": contact.text,
        "details": details.text,
        "sum_assured": sumAssured.text,
        "premium": premium.text,
        "pay_freq": frequency,
        "pay_type": paymentType,
        "cover_start": startDB,
        "cover_end": endDB,
      };

      // Convert the map to FormData
      final formData = FormData.fromMap(formDataMap);
      print("Checking222:$formDataMap");

      String? filename;
      String? ext;

      if (filePath != null) {
        filename = p.basename(filePath.path); // Safely get filename
        ext = p.extension(filename).toLowerCase();

        // This check is a safeguard; primary validation is in the picker.
        // final List<String> allowedUploadExtensions = [".doc", ".docx", ".pdf"];
        // if (!allowedUploadExtensions.contains(ext)) {
        //   Fluttertoast.showToast(msg: "Internal error: Invalid file type for upload. Please re-select.");
        //   return; // Finally block will dismiss dialog
        // }

        formData.files.add(
          MapEntry(
            "document",
            await MultipartFile.fromFile(
              filePath.path,
              filename: filename,
              contentType: _getContentTypeForExtension(
                ext,
              ), // Explicitly set Content-Type
            ),
          ),
        );
      }
      // Define API endpoints
      const url = "$baseUrl/app/360/protection";
      const urlr = "$baseUrl/app/360/tiles";

      // Debug: Print request data before sending
      // print( "Request data being sent (form fields): $formDataMap, Filename: $filename, ContentType: ${_getContentTypeForExtension(ext)}");

      // Make the POST request
      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {"Authorization": 'Bearer $token'},
          validateStatus: (status) {
            return status! < 500; // Accept all responses except 500+ errors
          },
        ),
      );

      // Log server response details for debugging
      print("SaveCash Response StatusCode: ${response.statusCode}");
      print("SaveCash Response Headers: ${response.headers}");

      Map<String, dynamic> responseBody;

      if (response.data is String) {
        try {
          responseBody =
              json.decode(response.data as String) as Map<String, dynamic>;
        } catch (e) {
          // Catches JSONDecodeError
          String responseDataString = response.data as String;
          print(
            "Failed to decode JSON response: $e. Response data snippet: ${responseDataString.substring(0, responseDataString.length > 200 ? 200 : responseDataString.length)}",
          );

          // Check if the response is HTML, which often indicates a redirect or auth issue
          if (responseDataString.trim().toLowerCase().startsWith(
                "<!doctype html",
              ) ||
              responseDataString.trim().toLowerCase().startsWith("<html>")) {
            Fluttertoast.showToast(
              msg:
                  "Unexpected server response (HTML received). This might be due to a session timeout or a server redirect. Please try again or re-login. (Status: ${response.statusCode})",
              toastLength: Toast.LENGTH_LONG,
            );
          } else {
            Fluttertoast.showToast(
              msg:
                  "Error processing server response (invalid format). (Status: ${response.statusCode})",
              toastLength: Toast.LENGTH_LONG,
            );
          }
          return; // Exit saveCash, finally block will dismiss dialog
        }
      } else if (response.data is Map) {
        responseBody = Map<String, dynamic>.from(response.data as Map);
      } else {
        print("Unexpected response data type: ${response.data.runtimeType}");
        Fluttertoast.showToast(msg: "Unexpected server response format.");
        return; // Exit saveCash, finally block will dismiss dialog
      }

      // Now use responseBody to access fields like 'cover_start'
      print("Parsed Response Body: $responseBody");
      var coverStartField = responseBody['cover_start'];

      if (coverStartField is List) {
        print("Field 'cover_start' is a List: $coverStartField");
        try {
          List<String> errors = coverStartField
              .map((item) => item.toString())
              .toList();
          print("List errors for cover_start: $errors");
          Fluttertoast.showToast(msg: errors.join('\n'));
          // If cover_start errors mean the whole request failed, and status is not 200, return.
          if (response.statusCode != 200) {
            return; // Exit saveCash, finally block will dismiss dialog
          }
        } catch (e) {
          print("Error processing list items for cover_start: $e");
          Fluttertoast.showToast(
            msg: "Error in 'cover_start' field format (list).",
          );
        }
      } else if (coverStartField is String) {
        print("Field 'cover_start' is a String: $coverStartField");
        Fluttertoast.showToast(msg: coverStartField);
        return; // Exit saveCash, finally block will dismiss dialog
      } else if (coverStartField != null) {
        print(
          "Field 'cover_start' has an unexpected type: ${coverStartField.runtimeType}. Value: $coverStartField",
        );
        // You might want to show a generic error or handle this specific type if it's valid in some cases
      } else {
        print("Field 'cover_start' is missing or null in the response.");
        // If 'cover_start' being absent is an error condition for non-200 responses,
        // this path might be taken. For 200 responses, it means the field isn't there.
      }

      // Handle the response
      if (response.statusCode == 200) {
        // Fetch updated data
        final response2 = await dio.get(
          url,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );

        Map<String, dynamic> protectionData;
        if (response2.data is String) {
          protectionData =
              json.decode(response2.data as String) as Map<String, dynamic>;
        } else if (response2.data is Map) {
          protectionData = Map<String, dynamic>.from(response2.data as Map);
        } else {
          Fluttertoast.showToast(
            msg: "Error fetching updated protection data (format error).",
          );
          return; // Exit saveCash, finally block will dismiss dialog
        }

        final response3 = await dio.get(
          urlr,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );

        Map<String, dynamic> tilesData;
        if (response3.data is String) {
          tilesData =
              json.decode(response3.data as String) as Map<String, dynamic>;
        } else if (response3.data is Map) {
          tilesData = Map<String, dynamic>.from(response3.data as Map);
        } else {
          Fluttertoast.showToast(
            msg: "Error fetching updated tiles data (format error).",
          );
          return; // Exit saveCash, finally block will dismiss dialog
        }

        // Update the provider state
        final mapList = protectionData["protection"];
        final mapListLite = protectionData["protection_detail"];

        context.read<Providers>().setRecent(tilesData["tiles"]);
        context.read<Providers>().setProtectionList(mapList);
        context.read<Providers>().setProtectionListLite(mapListLite);

        // Navigate back and show success message  Protectiondetails
        Navigator.popUntil(context, ModalRoute.withName('Protectiondetails'));
        // Navigator.of(context).pushNamed('Protectiondetails');
        Fluttertoast.showToast(msg: 'Account saved successfully');
      } else {
        // Handle non-200 status for the initial POST, using responseBody for error messages
        String errorMessage = "Failed to save account.";
        if (responseBody.containsKey('message') &&
            responseBody['message'] != null) {
          errorMessage = responseBody['message'].toString();
        } else if (coverStartField is String) {
          // If the error was specifically in cover_start
          errorMessage = coverStartField;
        }
        // Show a general error toast only if a more specific one (HTML error, cover_start error) wasn't already shown.
        bool specificErrorShown =
            (response.data is String &&
                ((response.data as String).trim().toLowerCase().startsWith(
                      "<!doctype html",
                    ) ||
                    (response.data as String).trim().toLowerCase().startsWith(
                      "<html>",
                    ))) ||
            (coverStartField is List || coverStartField is String);

        if (!specificErrorShown) {
          Fluttertoast.showToast(
            msg: "$errorMessage (Status: ${response.statusCode})",
          );
        }
      }
    } catch (e) {
      print("Error: $e");
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
    } finally {
      // Safely dismiss the "Saving" dialog if it's still active
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context);
      }
    }
  }
}
