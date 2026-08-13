import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';

class Viewnotes extends StatelessWidget {
  const Viewnotes({super.key});

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    String days = context
        .watch<Providers>()
        .snapshotmodel
        .snapshot["currenttime"]
        .toString();
    String percent = context
        .watch<Providers>()
        .snapshotmodel
        .snapshot["currentper"]
        .toString();
    return Scaffold(
      bottomNavigationBar: const BottomNav(4),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: RichText(
          text: TextSpan(
            children: const [
              TextSpan(text: 'Financial Independence (Not '),
              TextSpan(
                text: 'Retirement',
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.red,
                ),
              ),
              TextSpan(text: ')'),
            ],
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: width * .04,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(width * .02),
          child: Column(
            children: [
              Table(
                border: TableBorder.all(),
                columnWidths: const {0: const FlexColumnWidth(0.35)},
                children: [
                  TableRow(
                    children: [
                      Container(
                        child: Column(
                          children: [
                            SizedBox(height: width * .04),
                            Row(
                              children: [
                                SizedBox(width: width * .02),
                                Container(
                                  height: width * .04,
                                  width: width * .04,
                                  color: const Color(0xffff0000),
                                ),
                                SizedBox(width: width * .02),
                                Text(
                                  'Red Zone',
                                  style: TextStyle(
                                    fontSize: width * .03,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: width * .04),
                            Text(
                              "(0-25%)",
                              style: TextStyle(
                                fontSize: width * .03,
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(width * .01),
                        child: const Text(
                          "This is an undesirable state. It means if you were to lose your job, you have savings to cover you only for a period between 0-90 days. It also means you have an asset portfolio income that is 25% or less of your cost of living.",
                          style: TextStyle(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        child: Column(
                          children: [
                            SizedBox(height: width * .04),
                            Row(
                              children: [
                                SizedBox(width: width * .005),
                                Container(
                                  height: width * .04,
                                  width: width * .04,
                                  color: const Color(0xffffc200),
                                ),
                                SizedBox(width: width * .02),
                                Text(
                                  'Amber Zone',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: width * .03,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: width * .04),
                            Text(
                              "(26-50%)",
                              style: TextStyle(
                                fontSize: width * .03,
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(width * .01),
                        child: const Text(
                          "This is an progressive state. It means if you were to lose your job, you have savings to cover you only for a period between 91-180 days. It also means you have an asset portfolio income that is 26-50% or less of your cost of living.",
                          style: TextStyle(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        child: Column(
                          children: [
                            SizedBox(height: width * .04),
                            Row(
                              children: [
                                SizedBox(width: width * .01),
                                Container(
                                  height: width * .04,
                                  width: width * .04,
                                  color: const Color(0xff00ff00),
                                ),
                                SizedBox(width: width * .02),
                                Text(
                                  'Green Zone',
                                  style: TextStyle(
                                    fontSize: width * .03,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: width * .04),
                            Text(
                              "(51-75%)",
                              style: TextStyle(
                                fontSize: width * .03,
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(width * .01),
                        child: const Text(
                          "This is an comfortable state. It means if you were to lose your job, you have savings to cover you only for a period between 181-270 days. It also means you have an asset portfolio income that is 51-75% or less of your cost of living.",
                          style: TextStyle(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        child: Column(
                          children: [
                            SizedBox(height: width * .04),
                            Row(
                              children: [
                                SizedBox(width: width * .02),
                                Container(
                                  height: width * .04,
                                  width: width * .04,
                                  color: const Color(0xff65B8E8),
                                ),
                                SizedBox(width: width * .02),
                                Text(
                                  'Blue Zone',
                                  style: TextStyle(
                                    fontSize: width * .03,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: width * .04),
                            Text(
                              "(76-100+%)",
                              style: TextStyle(
                                fontSize: width * .03,
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(width * .01),
                        child: const Text(
                          "This is an desirable state. It means if you were to lose your job, you have savings to cover you only for a period between 271-360 days. It also means you have an asset portfolio income that is 76-100+% or less of your cost of living.",
                          style: TextStyle(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: height * .05),
              Text(
                "YOUR FINANCIAL INDEPENDENCE STATUS NOTE",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: width * .04,
                  decoration: TextDecoration.underline,
                ),
              ),
              SizedBox(height: height * .01),
              Table(
                columnWidths: const {0: const FlexColumnWidth(0.6)},
                children: [
                  TableRow(
                    children: [
                      Container(
                        child: Column(
                          children: [
                            SizedBox(height: width * .04),
                            const Center(
                              child: Text(
                                "CURRENT",
                                style: TextStyle(fontWeight: FontWeight.w900),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            SizedBox(height: width * .02),
                            Image.asset(
                              'assets/images/location.png',
                              color: Theme.of(context).primaryColor,
                              height: width * .1,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(width * .01),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text:
                                    'Your current rainy day savings can only last you ',
                              ),
                              TextSpan(
                                text: '$days days.',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(
                                text: ' Are you comfortable with this?',
                              ),
                            ],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(width * .01),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            children: [
                              const TextSpan(
                                text: 'You are currently meeting ',
                              ),
                              TextSpan(
                                text: '$percent%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(
                                text: int.parse(percent) <= 100
                                    ? ' of your monthly expenses from your portfolio income. What happens if you lose your main source of income?'
                                    : 'You are currently meeting $percent% of your monthly expenses from your portfolio income. Well done! You are financially independent. Always remember to increase your means before increasing the cost of your lifestyle',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        child: Column(
                          children: [
                            SizedBox(height: width * .04),
                            const Center(
                              child: Text(
                                "TARGET",
                                style: TextStyle(fontWeight: FontWeight.w900),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            SizedBox(height: width * .02),
                            Image.asset(
                              'assets/images/desired.png',
                              color: Theme.of(context).primaryColor,
                              height: width * .1,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(width * .01),
                        child: const Text(
                          "With a 360-day target, you are secure for one whole year.",
                          style: TextStyle(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(width * .01),
                        child: RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    'With a target of 100% of your cost of living coming from your Asset Portfolio, you become ',
                              ),
                              TextSpan(
                                style: TextStyle(fontWeight: FontWeight.w900),
                                text: "Financially Independent.",
                              ),
                            ],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                border: TableBorder.all(),
              ),
              SizedBox(height: height * .05),
            ],
          ),
        ),
      ),
    );
  }
}
