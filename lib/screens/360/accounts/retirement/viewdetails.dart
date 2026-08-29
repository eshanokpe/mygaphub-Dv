import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'graph.dart';

class Viewdetails extends StatefulWidget {
  final Map data;
  final bool isNotRetirement;
  const Viewdetails(this.data, {super.key, this.isNotRetirement = false});
  @override
  _ViewdetailsState createState() => _ViewdetailsState();
}

enum Average { seed, expenditure }

class _ViewdetailsState extends State<Viewdetails> {
  final Average _selectedAverage = Average.seed;
  // Define a function to convert a string to the corresponding enum value
  Average stringToAverage(String value) {
    switch (value) {
      case 'seed':
        return Average.seed;
      case 'expenditure':
        return Average.expenditure;
      // Handle other cases as needed
      default:
        return Average.seed; // Default value
    }
  }

  @override
  void initState() {
    super.initState();
    //_selectedAverage = stringToAverage('expenditure');
    stringToAverage(widget.data["improve_status"]["seed_type"]);
  }

  @override
  Widget build(BuildContext context) {
    String current = context
        .watch<Providers>()
        .snapshotmodel
        .snapshot["currentper"]
        .toString();
    double currentPer = double.parse(current) / 100;
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    String currency = context.watch<Providers>().snapshotmodel.currency;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: widget.isNotRetirement
            ? const Text('Financial Independence ')
            : RichText(
                text: TextSpan(
                  children: const [
                    TextSpan(text: 'Financial Independence (Not '),
                    TextSpan(
                      text: 'Retirement',
                      style: TextStyle(
                        // decoration: TextDecoration.lineThrough,
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
      bottomNavigationBar: widget.isNotRetirement
          ? const BottomNav(0)
          : const BottomNav(4),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * .02,
            vertical: height * .02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              currentPer > 1
                  ? Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        border: Border.all(color: const Color(0xffED3237)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Congratulations! You are Financially Independent!!',
                        style: TextStyle(
                          fontSize: width * .04,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Container(),
              SizedBox(height: height * .02),
              Text(
                "Monthly Asset Portfolio Income (API) needed",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontSize: width * .04,
                ),
              ),
              SizedBox(height: height * .01),
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "$currency${double.parse(widget.data["improve_status"]["monthly_asset"].toString()).toStringAsFixed(2)}"
                        .replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        ),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                      fontSize: width * .04,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * .01),
              SizedBox(
                height: height * .05,
                child: const Divider(thickness: 1.5),
              ),
              Text(
                "Your current monthly Asset Portfolio Income",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: width * .04,
                ),
              ),
              SizedBox(height: height * .01),
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "$currency${double.parse(widget.data["improve_status"]["portfolio"].toString()).toStringAsFixed(2)}"
                        .replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        ),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                      fontSize: width * .04,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: height * .05,
                child: const Divider(thickness: 1.5),
              ),
              Text(
                "How much can you set aside monthly for investments?",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: width * .04,
                ),
              ),
              SizedBox(height: height * .01),
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "$currency${double.parse(widget.data["improve_status"]["investment"].toString()).toStringAsFixed(2)}"
                        .replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        ),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                      fontSize: width * .04,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: height * .05,
                child: const Divider(thickness: 1.5),
              ),
              Text(
                "What is your expected Return on Capital Employed (ROCE)",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: width * .04,
                ),
              ),
              SizedBox(height: height * .01),
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${widget.data["improve_status"]["roce"]}%",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                      fontSize: width * .04,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: height * .05,
                child: const Divider(thickness: 1.5),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Time to Financial Independence:",
                      style: TextStyle(
                        fontSize: width * .045,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(width: width * .03),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(width * .01),
                          ),
                          child: Text(
                            "${double.parse(widget.data["roi_detail"]["time_finiancial"].toString()).round()}",
                            style: TextStyle(
                              fontSize: width * .05,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          " Years",
                          style: TextStyle(
                            fontSize: width * .05,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: height * .05,
                child: const Divider(thickness: 1.5),
              ),
              Card(
                elevation: 5,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * .02,
                    vertical: height * .01,
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Summary & Recommendations",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: width * .05,
                        ),
                      ),
                      SizedBox(height: height * .01),
                      Text(
                        "You are financially independent of $currency${double.parse(widget.data["roi_detail"]["shortfall"].toString()).toStringAsFixed(2)} in your asset portfolio income. In order to become financially independent, you will need to acquire assets to the value of $currency${double.parse(widget.data["roi_detail"]["asset_require"].toString()).toStringAsFixed(2)} generating income at ${double.tryParse(widget.data["improve_status"]["roce"] ?? '0')?.round() ?? 0}% ROCE to make up this shortfall. Setting aside $currency${double.parse(widget.data["improve_status"]["investment"].toString()).toStringAsFixed(2)} monthly for investment will allow you become financially independent in ${widget.data["roi_detail"]["time_finiancial"].round()} years. Explore the opportunities listed by our partners from your your GAPhub account. Also, visit the acquisition section of your account and start using My GAPhub to build a profitable asset portfolio globally."
                            .replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            ),
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: width * .04,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              double.parse(
                        widget.data["roi_detail"]["time_finiancial"].toString(),
                      ).round() >=
                      0
                  ? Column(
                      children: [
                        SizedBox(
                          height: height * .05,
                          child: const Divider(thickness: 1.5),
                        ),
                        Center(
                          child: Text(
                            "Financial Independence Journey",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: width * .05,
                            ),
                          ),
                        ),
                        SizedBox(height: height * .03),
                        LineChartSample1(widget.data, currency),
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
