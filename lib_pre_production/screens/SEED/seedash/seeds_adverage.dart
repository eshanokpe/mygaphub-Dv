import 'dart:convert';
import 'package:GapHub/models/savingAllocationexpenditure.dart';
import 'package:GapHub/models/savingAllocationserver.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'seedtabs.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:provider/provider.dart';

class SeedsAverage extends StatefulWidget {
  final List list;
  const SeedsAverage(this.list, {super.key});
  @override
  _SeedsAverageState createState() => _SeedsAverageState();
}

class _SeedsAverageState extends State<SeedsAverage> {
  Map data = {};
  final List<SavingAllserver> _data = [];
  final List<SavingAllexpenditure> _dataExpen = [];
  @override
  void initState() {
    super.initState();
    data = context.read<Providers>().seedata;
  }

  @override
  Widget build(BuildContext context) {
    String currency = context.watch<Providers>().snapshotmodel.currency;

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * .04,
        vertical: height * .03,
      ),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SeedRow(
              color: 0xff00B050,
              name: "Savings",
              value: "$currency${widget.list[0].toStringAsFixed(2)}",
            ),
            const Divider(thickness: 1.5),
            SeedRow(
              color: 0xffE6C069,
              name: "Education",
              value: "$currency${widget.list[1].toStringAsFixed(2)}",
            ),
            const Divider(thickness: 1.5),
            SeedRow(
              color: 0xffD13B56,
              name: "Expenditure",
              value: "$currency${widget.list[2].toStringAsFixed(2)}",
            ),
            const Divider(thickness: 1.5),
            SeedRow(
              name: "Discretionary",
              value: "$currency${widget.list[3].toStringAsFixed(2)}",
              color: 0xff77A2BB,
            ),
            const Divider(thickness: 1.5),
          ],
        ),
      ),
    );
  }
}
