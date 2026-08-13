import 'dart:async';
import 'package:GapHub/models/calculatormodel.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'financial_snapshot/financial_independent_snapshot.dart';
import 'costoflivingcalc.dart';

class Savingsincomecalc extends StatefulWidget {
  final Calculatormodel parameters;
  const Savingsincomecalc(this.parameters, {super.key});
  @override
  _SavingsincomecalcState createState() => _SavingsincomecalcState(parameters);
}

class _SavingsincomecalcState extends State<Savingsincomecalc> {
  Calculatormodel parameters;
  _SavingsincomecalcState(this.parameters);
  final TextEditingController _otherWages = TextEditingController();
  final TextEditingController _rainyDays = TextEditingController();
  DialogBox dialogBox = DialogBox();
  double total = 0;

  increment() {
    setState(() {
      double a = _otherWages.text.isEmpty ? 0 : double.parse(_otherWages.text);
      double b = _rainyDays.text.isEmpty
          ? 0
          : double.parse(_rainyDays.text.trim());

      total = a + b;
    });
  }

  @override
  void initState() {
    super.initState();
    _otherWages.addListener(increment);
    _rainyDays.addListener(increment);
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

    String symbo = context.watch<Providers>().currencySymbol;
    var symboll = symbo.split(" ").toList();
    String symbol = symboll[0];

    return Scaffold(
      backgroundColor: const Color(0xfff3f3f4),
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: const Text(
          'Savings and Portfolio Income',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * .02,
          vertical: width * .04,
        ),
        child: Column(
          children: [
            Fiforms(
              name:
                  "How much Monthly income do you earn from sources (assets) other than your wages?",
              controller: _otherWages,
              height: height,
              width: width,
              symbol: symbol,
            ),
            Spaces(height: height),
            Fiforms(
              name: "How much do you have in savings for rainy day?",
              controller: _rainyDays,
              height: height,
              width: width,
              symbol: symbol,
            ),
            Spaces(height: height),
            SizedBox(height: height * .03),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(width * .02),
                ),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                if (_rainyDays.text.isEmpty) {
                  _rainyDays.text = '0';
                }
                if (_otherWages.text.isEmpty) {
                  _otherWages.text = '0';
                }

                parameters.extraSave = _rainyDays.text;
                parameters.otherIncome = _otherWages.text;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FinancialIndependentSnapshot(false),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.zero,
                height: height * .06,
                width: width * .8,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'View Result',
                    style: TextStyle(
                      color: const Color(0xfff3f3f4),
                      fontWeight: FontWeight.w700,
                      fontSize: width * .05,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
