import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/models/IncomeChannels.dart';

class Channels extends StatelessWidget {
  final IncomeChannelsValues channelsValues;
  final IncomeChannelsPercent channelsPercent;

  const Channels({
    super.key,
    required this.channelsValues,
    required this.channelsPercent,
  });
  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    final currency = context.watch<Providers>().snapshotmodel.currency;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * .04),
      child: Card(
        color: const Color(0xffC9D7E1),
        child: Container(
          padding: EdgeInsets.all(width * .04),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Income Channels",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: width * .04,
                  ),
                ),
              ),
              SizedBox(height: height * .03),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Primary Employment"),
                      Text(
                        "$currency${toTwoDecimal(channelsValues.primary, value: true)}",
                      ),
                    ],
                  ),
                  SizedBox(height: height * .005),
                  Linearindicator(
                    value: toTwoDecimal(channelsPercent.primary),
                    width: width,
                  ),
                ],
              ),
              SizedBox(height: height * .03),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Side Hustle"),
                      Text(
                        "$currency${toTwoDecimal(channelsValues.hustle, value: true)}",
                      ),
                    ],
                  ),
                  SizedBox(height: height * .005),
                  Linearindicator(
                    value: toTwoDecimal(channelsPercent.hustle),
                    width: width,
                  ),
                ],
              ),
              SizedBox(height: height * .03),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Business Asset"),
                      Text(
                        "$currency${toTwoDecimal(channelsValues.business, value: true)}",
                      ),
                    ],
                  ),
                  SizedBox(height: height * .005),
                  Linearindicator(
                    value: toTwoDecimal(channelsPercent.business),
                    width: width,
                  ),
                ],
              ),
              SizedBox(height: height * .03),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Risk Asset"),
                      Text(
                        "$currency${toTwoDecimal(channelsValues.risk, value: true)}",
                      ),
                    ],
                  ),
                  SizedBox(height: height * .005),
                  Linearindicator(
                    value: toTwoDecimal(channelsPercent.risk),
                    width: width,
                  ),
                ],
              ),
              SizedBox(height: height * .03),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Appreciating Asset"),
                      Text(
                        "$currency${toTwoDecimal(channelsValues.appreciating, value: true)}",
                      ),
                    ],
                  ),
                  SizedBox(height: height * .005),
                  Linearindicator(
                    value: toTwoDecimal(channelsPercent.appreciating),
                    width: width,
                  ),
                ],
              ),
              SizedBox(height: height * .03),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Intellectual Asset"),
                      Text(
                        "$currency${toTwoDecimal(channelsValues.intellectual, value: true)}",
                      ),
                    ],
                  ),
                  SizedBox(height: height * .005),
                  Linearindicator(
                    value: toTwoDecimal(channelsPercent.intellectual),
                    width: width,
                  ),
                ],
              ),
              SizedBox(height: height * .03),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Depreciating Asset"),
                      Text(
                        "$currency${toTwoDecimal(channelsValues.depreciating, value: true)}",
                      ),
                    ],
                  ),
                  SizedBox(height: height * .005),
                  Linearindicator(
                    value: toTwoDecimal(channelsPercent.depreciating),
                    width: width,
                  ),
                ],
              ),
              SizedBox(height: height * .03),
            ],
          ),
        ),
      ),
    );
  }

  toTwoDecimal(nums, {bool value = false}) {
    if (value == true) {
      return double.parse(nums.toStringAsFixed(2));
    }
    return double.parse((nums / 100).toStringAsFixed(2));
  }
}

class Linearindicator extends StatelessWidget {
  const Linearindicator({super.key, required this.value, required this.width});

  final double value;
  final double width;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      backgroundColor: Colors.grey[300],
      minHeight: width * .02,
      valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
      value: value,
    );
  }
}
