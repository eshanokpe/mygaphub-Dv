import 'package:flutter/material.dart';

class Savingsdropdown1 extends StatefulWidget {
  const Savingsdropdown1({super.key});

  @override
  _Savingsdropdown1State createState() => _Savingsdropdown1State();
}

class _Savingsdropdown1State extends State<Savingsdropdown1> {
  static const subUnits = <String>[
    '-Select-',
    'Savings Account',
    'Term Deposit',
    'Fixed Deposit',
    'Others',
  ];
  String sub = '-Select-';
  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.only(left: width * .015, right: width * .015),
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * .01),
        color: Colors.grey[100],
        border: Border.all(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          focusColor: Theme.of(context).primaryColor,
          value: sub,
          items: [
            DropdownMenuItem(
              value: '-Select-',
              child: Text(
                subUnits[0],
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .03,
                  color: Colors.black,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Savings Account',
              child: Text(
                subUnits[1],
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .03,
                  color: Colors.black,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Term Deposit',
              child: Text(
                subUnits[2],
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .03,
                  color: Colors.black,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Fixed Deposit',
              child: Text(
                subUnits[3],
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .03,
                  color: Colors.black,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Others',
              child: Text(
                subUnits[4],
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .03,
                  color: Colors.black,
                ),
              ),
            ),
          ],
          onChanged: (subval) {
            setState(() {
              sub = subval!;
            });
          },
        ),
      ),
    );
  }
}

class Savingsdropdown2 extends StatefulWidget {
  const Savingsdropdown2({super.key});

  @override
  _Savingsdropdown2State createState() => _Savingsdropdown2State();
}

class _Savingsdropdown2State extends State<Savingsdropdown2> {
  static const subUnits = <String>[
    '-Select-',
    'Investment Pool Fund',
    'Rainy-Day Fund',
    'Personal Project Fund',
    'Family Project Fund',
    'Holiday Fund',
    'Car Purchase Fund',
    'Children Education Fund',
    'Home Purchase Savings',
    'Others',
  ];
  String sub = '-Select-';
  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.only(left: width * .015, right: width * .015),
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * .01),
        color: Colors.grey[100],
        border: Border.all(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          focusColor: Theme.of(context).primaryColor,
          value: sub,
          items: [
            DropdownMenuItem(
              value: '-Select-',
              child: Text(
                subUnits[0],
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .03,
                  color: Colors.black,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Investment Pool Fund',
              child: Text(
                subUnits[1],
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .03,
                  color: Colors.black,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Rainy-Day Fund',
              child: Text(
                subUnits[2],
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .03,
                  color: Colors.black,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Personal Project Fund',
              child: Text(
                subUnits[3],
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .03,
                  color: Colors.black,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Family Project Fund',
              child: Text(
                subUnits[4],
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .03,
                  color: Colors.black,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Holiday Fund',
              child: Text(
                subUnits[5],
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .03,
                  color: Colors.black,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Car Purchase Fund',
              child: Text(
                subUnits[6],
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .03,
                  color: Colors.black,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Children Education Fund',
              child: Text(
                subUnits[7],
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .03,
                  color: Colors.black,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Home Purchase Savings',
              child: Text(
                subUnits[8],
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .03,
                  color: Colors.black,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Others',
              child: Text(
                subUnits[9],
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .03,
                  color: Colors.black,
                ),
              ),
            ),
          ],
          onChanged: (subval) {
            setState(() {
              sub = subval!;
            });
          },
        ),
      ),
    );
  }
}

class Debtdropdown extends StatefulWidget {
  const Debtdropdown({super.key});

  @override
  _DebtdropdownState createState() => _DebtdropdownState();
}

class _DebtdropdownState extends State<Debtdropdown> {
  static const subUnits = <String>[
    '-Select-',
    'Credit Card',
    'Overdraft',
    'Loans',
    'Delayed Payment',
    'Hire Purchase',
    'Others',
  ];
  String sub = '-Select-';
  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.only(left: width * .015, right: width * .015),
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * .01),
        color: Colors.grey[100],
        border: Border.all(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          focusColor: Theme.of(context).primaryColor,
          value: sub,
          items: [
            DropdownMenuItem(
              value: '-Select-',
              child: Text(
                subUnits[0],
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .03,
                  color: Colors.black,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Credit Card',
              child: Text(
                subUnits[1],
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .03,
                  color: Colors.black,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Overdraft',
              child: Text(
                subUnits[2],
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .03,
                  color: Colors.black,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Loans',
              child: Text(
                subUnits[3],
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .03,
                  color: Colors.black,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Delayed Payment',
              child: Text(
                subUnits[4],
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .03,
                  color: Colors.black,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Hire Purchase',
              child: Text(
                subUnits[5],
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .03,
                  color: Colors.black,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Others',
              child: Text(
                subUnits[6],
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: width * .03,
                  color: Colors.black,
                ),
              ),
            ),
          ],
          onChanged: (subval) {
            setState(() {
              sub = subval!;
            });
          },
        ),
      ),
    );
  }
}
