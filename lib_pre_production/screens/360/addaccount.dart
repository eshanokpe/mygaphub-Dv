import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:GapHub/screens/360/decider.dart';
import 'package:dio/dio.dart';

class Addaccount extends StatefulWidget {
  const Addaccount({super.key});

  @override
  _AddaccountState createState() => _AddaccountState();
}

class _AddaccountState extends State<Addaccount> {
  Dio dio = Dio();
  static const items = <String>[
    '-Select-',
    'Liabilities',
    "Retirement(Pension)",
    'Income',
    'Protection',
    'Cash',
    'Mortgage',
    'Assets',
  ];
  String item = '-Select-';
  final List<DropdownMenuItem<String>> itemList = items
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
      )
      .toList();
  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return AlertDialog(
      actionsPadding: EdgeInsets.zero,
      elevation: 5,
      title: Text(
        'Add Account',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: width * .06,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
      content: StatefulBuilder(
        builder: (context, StateSetter setState) {
          return Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("What category would you like to add account to?"),
                SizedBox(height: height * .01),
                Container(
                  padding: EdgeInsets.only(
                    left: width * .015,
                    right: width * .015,
                  ),
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * .01),
                    color: Colors.grey[100],
                    border: Border.all(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      focusColor: Theme.of(context).primaryColor,
                      value: item,
                      items: itemList,
                      onChanged: (itemv) {
                        setState(() {
                          item = itemv!;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: height * .03),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * .01),
                    ),
                  ),
                  onPressed: () async {
                    if (item == "-Select-") {
                      Fluttertoast.showToast(msg: 'Select an account type');
                    } else {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) =>
                      //           Cashdetails(mapList, mapListLite),
                      //     ));
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Decider(item)),
                      );
                    }
                  },
                  child: Text(
                    "Next",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: width * .045,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
