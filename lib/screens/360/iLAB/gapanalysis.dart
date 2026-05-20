import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';

class DiffTable extends StatelessWidget {
  const DiffTable({
    super.key,
    required this.width,
    this.npi,
    this.api,
    this.lia,
    this.asset,
    this.budget,
  });

  final double width;
  final num? npi;
  final num? api;
  final num? lia;
  final num? asset;
  final num? budget;
  @override
  Widget build(BuildContext context) {
    String currency = context.watch<Providers>().snapshotmodel.currency;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * .15),
      child: Table(
        border: TableBorder.all(color: Colors.white),
        children: [
          TableRow(
            children: [
              Container(
                padding: EdgeInsets.all(width * .02),
                color: Theme.of(context).colorScheme.secondary,
                child: Text(
                  "iLAB",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: width * .035,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(width * .02),
                color: Theme.of(context).colorScheme.secondary,
                child: Text(
                  "Difference",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: width * .045,
                  ),
                ),
              ),
            ],
          ),
          TableRow(
            children: [
              Container(
                padding: EdgeInsets.all(width * .02),
                color: Colors.grey[400],
                child: Text(
                  "INCOME (NPi)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: width * .045,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(width * .02),
                color: npi! > 0 ? Colors.green : Theme.of(context).primaryColor,
                child: Text(
                  "$currency$npi".replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: width * .045,
                  ),
                ),
              ),
            ],
          ),
          TableRow(
            children: [
              Container(
                padding: EdgeInsets.all(width * .02),
                color: Colors.grey[200],
                child: Text(
                  "INCOME (APi)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: width * .045,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(width * .02),
                color: api! > 0 ? Colors.green : Theme.of(context).primaryColor,
                child: Text(
                  "$currency$api".replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: width * .045,
                  ),
                ),
              ),
            ],
          ),
          TableRow(
            children: [
              Container(
                padding: EdgeInsets.all(width * .02),
                color: Colors.grey[400],
                child: Text(
                  "LIABILITIES",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: width * .045,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(width * .02),
                color: lia! > 0 ? Colors.green : Theme.of(context).primaryColor,
                child: Text(
                  "$currency$lia".replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: width * .045,
                  ),
                ),
              ),
            ],
          ),
          TableRow(
            children: [
              Container(
                padding: EdgeInsets.all(width * .02),
                color: Colors.grey[200],
                child: Text(
                  "ASSET",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: width * .045,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(width * .02),
                color: asset! > 0
                    ? Colors.green
                    : Theme.of(context).primaryColor,
                child: Text(
                  "$currency$asset".replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: width * .045,
                  ),
                ),
              ),
            ],
          ),
          TableRow(
            children: [
              Container(
                padding: EdgeInsets.all(width * .02),
                color: Colors.grey[400],
                child: Text(
                  "BUDGET",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: width * .045,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(width * .02),
                color: budget! > 0
                    ? Colors.green
                    : Theme.of(context).primaryColor,
                child: Text(
                  "$currency$budget".replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: width * .045,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
