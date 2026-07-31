import 'dart:convert';
import 'package:GapHub/models/360income.dart';
import 'package:flutter/material.dart';

// Widget classes
class Incometab extends StatefulWidget {
  final List incomes;

  const Incometab(this.incomes, {super.key});

  @override
  _IncometabState createState() => _IncometabState();
}

class _IncometabState extends State<Incometab> {
  late Income incomes;
  List<TableRow> mainList = [];

  @override
  void initState() {
    super.initState();
    incomes = Income.fromJson({"data": widget.incomes});
    _buildTableRows();
  }

  void _buildTableRows() {
    List<TableRow> tempList = [
      const TableRow(
        children: [
          Tabledata2(text: 'Channel', thick: true),
          Tabledata2(text: 'Currency', thick: true),
          Tabledata2(text: 'Amount', thick: true),
          Tabledata2(text: 'Date', thick: true),
        ],
      ),
    ];

    for (var i = 0; i < incomes.incomeList.length && i < 6; i++) {
      tempList.add(
        TableRow(
          children: [
            Tabledata2(text: incomes.incomeList[i].channel, thick: false),
            Tabledata2(
              text: incomes.incomeList[i].income_currency,
              thick: false,
            ),
            Tabledata2(
              text: incomes.incomeList[i].amount.toStringAsFixed(2),
              thick: false,
            ),
            Tabledata2(
              text: incomes.incomeList[i].income_date.toString(),
              thick: false,
            ),
          ],
        ),
      );
    }

    setState(() => mainList.addAll(tempList));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * .04),
      child: Card(
        color: const Color(0xffC9D7E1),
        child: Container(
          padding: EdgeInsets.all(width * .02),
          child: Table(children: mainList),
        ),
      ),
    );
  }
}

class Tabledata2 extends StatelessWidget {
  const Tabledata2({super.key, required this.text, required this.thick});

  final String text;
  final bool thick;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(vertical: width * .02),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: thick ? width * .04 : width * .03,
          fontWeight: thick ? FontWeight.w700 : FontWeight.w300,
        ),
      ),
    );
  }
}
