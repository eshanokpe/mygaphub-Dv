import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SeelAllocationWidget extends StatelessWidget {
  final VoidCallback? onClick;
  final double amount;
  final Color color;
  final String title;

  const SeelAllocationWidget({
    super.key,
    required this.onClick,
    required this.amount,
    required this.color,
    required this.title,
  });

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

    return Container(
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onClick!.call(),
            // onTap: () async {},
            child: Card(
              color: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              // elevation: 5,
              child: Container(
                width: width * .90,
                padding: EdgeInsets.all(width * .05),
                child: Column(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: width * .07,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$currency $amount'.replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        fontSize: width * .05,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
