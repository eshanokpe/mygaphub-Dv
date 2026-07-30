import 'package:GapHub/provider/acquisiProvider.dart';
import 'package:GapHub/provider/acquisitionProvider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MonthlyIncome extends StatefulWidget {
  const MonthlyIncome({super.key});

  @override
  _MonthlyIncomeState createState() => _MonthlyIncomeState();
}

class _MonthlyIncomeState extends State<MonthlyIncome> {
  double start = 100;
  double end = 85000;

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<Providers>().snapshotmodel.currency;

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$currency${start.round()}".replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              ),
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w400,
                fontSize: width * .045,
              ),
            ),
            Text(
              "$currency${end.round()}".replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              ),
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w400,
                fontSize: width * .045,
              ),
            ),
          ],
        ),
        RangeSlider(
          values: RangeValues(start, end),
          labels: RangeLabels(start.toInt().toString(), end.toInt().toString()),
          activeColor: Colors.black,
          inactiveColor: const Color(0xffe0e0e0),
          // divisions: 1000,
          onChanged: (value) {
            setState(() {
              start = value.start.roundToDouble();
              end = value.end.roundToDouble();
            });
            context.read<AcquisiProvider>().onPriceRangeChanged(start, end);
          },
          min: 0.0,
          max: 100000.0,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
