import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nimble_charts/flutter.dart' as charts;

class NonPorfolioIncome extends StatefulWidget {
  final Map data;
  const NonPorfolioIncome({super.key, required this.data});

  @override
  State<NonPorfolioIncome> createState() => _NonPorfolioIncomeState();
}

class _NonPorfolioIncomeState extends State<NonPorfolioIncome> {
  Map nonporfolioData = {};
  Map incomeData = {};
  List<String> chartData = [];
  String selectedLabelAsset = "";
  Map<String, int> valuesMap = {};
  Map<String, int> valuesTithe = {};
  Map<String, int> valuesTaxes = {};
  Map<String, int> valuesNet = {};
  Map<String, int> valuesOther = {};
  List<double> values = [];
  List<double> titheValues = [];
  List<double> taxValues = [];
  List<double> netValues = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nonporfolioData = context.read<Providers>().nonporfolioData;
    incomeData = nonporfolioData["income"];
    chartData = nonporfolioData["chart"]['label_asset'].cast<String>();

    print("incomeData:$chartData");
    if (chartData.isNotEmpty) {
      selectedLabelAsset = chartData[0];
    }

    // Example: Iterating through the list and casting each element to int
    // Populate valuesMap dynamically based on chartData
    for (int i = 0; i < chartData.length; i++) {
      valuesMap[chartData[i]] = nonporfolioData["chart"]["values"][i];
      valuesTithe[chartData[i]] = nonporfolioData["chart"]["tithe_values"][i];
      valuesTaxes[chartData[i]] = nonporfolioData["chart"]["taxes_values"][i];
      valuesNet[chartData[i]] = nonporfolioData["chart"]["net_values"][i];
      valuesOther[chartData[i]] = nonporfolioData["chart"]["other_values"][i];
      // You can add mappings for tithe values, taxes values, and net values in a similar manner
    }
  }

  final charts.Color greenColor = charts.ColorUtil.fromDartColor(Colors.green);
  final charts.Color grayColor = charts.ColorUtil.fromDartColor(Colors.grey);
  final charts.Color blueColor = charts.ColorUtil.fromDartColor(Colors.blue);
  final charts.Color deepPurple = charts.ColorUtil.fromDartColor(
    Colors.deepPurple,
  );
  final charts.Color redColor = charts.ColorUtil.fromDartColor(Colors.red);

  @override
  Widget build(BuildContext context) {
    String currency = context.watch<Providers>().snapshotmodel.currency;

    final formattedGrossIncome = (valuesMap[selectedLabelAsset] ?? 0)
        .toStringAsFixed(2);

    final formattedNetIncome = (valuesNet[selectedLabelAsset] ?? 0)
        .toStringAsFixed(2);

    final formattedTithePaid = (valuesTithe[selectedLabelAsset] ?? 0)
        .toStringAsFixed(2);

    final formattedTaxesPaid = (valuesTaxes[selectedLabelAsset] ?? 0)
        .toStringAsFixed(2);

    final formattedOthersPaid = (valuesOther[selectedLabelAsset] ?? 0)
        .toStringAsFixed(2);

    final chartdata = [
      BarChartData(
        'Gross Income',
        double.parse(formattedGrossIncome),
        greenColor,
      ),
      BarChartData('Tithe Paid', double.parse(formattedTithePaid), blueColor),
      BarChartData('Taxes Paid', double.parse(formattedTaxesPaid), redColor),
      BarChartData('Others', double.parse(formattedOthersPaid), deepPurple),
      BarChartData('Net Income', double.parse(formattedNetIncome), grayColor),
    ];

    final series = [
      charts.Series<BarChartData, String>(
        id: 'Income',
        domainFn: (BarChartData data, _) => data.label,
        measureFn: (BarChartData data, _) => data.value,
        colorFn: (BarChartData data, _) => data.color,
        domainLowerBoundFn: (datum, index) => datum.label,
        labelAccessorFn: (BarChartData kpi, _) =>
            '$currency${(kpi.value).toInt()}'.replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            ),
        data: chartdata,
      ),
    ];
    final chart = charts.BarChart(
      series,
      barRendererDecorator: charts.BarLabelDecorator<String>(
        labelPosition: charts.BarLabelPosition.outside,
      ),
      animate: true,
    );
    //var data = widget.data;
    //final date = new DateFormat("MMM, yyyy");
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          "${incomeData["income_name"]} ".replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          ),
          style: TextStyle(fontSize: width * .06, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: ListView(
          children: [
            SizedBox(height: height * .03),
            Center(
              child: Text(
                "Avearage Income $currency${incomeData["amount"].toStringAsFixed(2)}"
                    .replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    ),
                style: TextStyle(
                  fontSize: width * .06,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(height: height * .01),
            Container(
              padding: EdgeInsets.symmetric(horizontal: width * .02),
              child: Text(
                "Income Period".replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},',
                ),
                style: TextStyle(
                  fontSize: width * .05,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(height: height * .01),
            Container(
              padding: EdgeInsets.only(left: width * .02, right: width * .02),
              //width: width,
              margin: EdgeInsets.only(left: width * .03, right: width * .03),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white,
                border: Border.all(
                  color: const Color.fromARGB(255, 196, 196, 196),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: const Text('-select-'),
                  value: selectedLabelAsset,
                  items: chartData
                      .map(
                        (data) => DropdownMenuItem<String>(
                          value: data.toString(),
                          child: Text(data),
                        ),
                      )
                      .toList(),
                  onChanged: (value) async {
                    if (value != null) {
                      setState(() => selectedLabelAsset = value);
                    }
                    //print('itemsssdate:$historicdate');
                  },
                ),
              ),
            ),
            SizedBox(height: height * .03),
            Padding(
              padding: EdgeInsets.only(left: width * .02, right: width * .02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gross Income:',
                    style: TextStyle(
                      fontSize: width * .05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$currency${(valuesMap[selectedLabelAsset] ?? 0).toStringAsFixed(2)}'
                        .replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        ),
                    style: TextStyle(
                      fontSize: width * .05,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * .02),
            Padding(
              padding: EdgeInsets.only(left: width * .02, right: width * .02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Net Income:',
                    style: TextStyle(
                      fontSize: width * .05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$currency${(valuesNet[selectedLabelAsset] ?? 0).toStringAsFixed(2)}'
                        .replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        ),
                    style: TextStyle(
                      fontSize: width * .05,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * .04),
            Padding(
              padding: EdgeInsets.only(left: width * .02, right: width * .02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tithe Paid:',
                    style: TextStyle(
                      fontSize: width * .05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$currency ${(valuesTithe[selectedLabelAsset] ?? 0).toStringAsFixed(2)}'
                        .replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        ),
                    style: TextStyle(
                      fontSize: width * .05,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * .02),
            Padding(
              padding: EdgeInsets.only(left: width * .02, right: width * .02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Taxes Paid:',
                    style: TextStyle(
                      fontSize: width * .05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    //formattedTaxesPaid,
                    ' $currency${(valuesTaxes[selectedLabelAsset] ?? 0).toStringAsFixed(2)}'
                        .replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        ),
                    style: TextStyle(
                      fontSize: width * .05,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * .01),
            Padding(
              padding: EdgeInsets.only(left: width * .02, right: width * .02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Others:',
                    style: TextStyle(
                      fontSize: width * .05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    //formattedTaxesPaid,
                    ' $currency${(valuesOther[selectedLabelAsset] ?? 0).toStringAsFixed(2)}'
                        .replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        ),
                    style: TextStyle(
                      fontSize: width * .05,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.grey, // You can set the color of the divider
              thickness: 1.0, // You can adjust the thickness of the divider
            ),
            SizedBox(height: height * .02),
            Center(
              child: Text(
                'Monthly Income Chart',
                style: TextStyle(
                  fontSize: width * .05,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: width * .02, right: width * .02),
              height: 300, // Set the desired height of the chart
              child: chart,
            ),
          ],
        ),
      ),
    );
  }
}

class BarChartData {
  final String label;
  final double value;
  final charts.Color color;

  BarChartData(this.label, this.value, this.color);
}
