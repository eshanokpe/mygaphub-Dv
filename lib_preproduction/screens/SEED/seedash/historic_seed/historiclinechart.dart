import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:nimble_charts/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HistoricLineChart extends StatefulWidget {
  Map historicSeedData;

  HistoricLineChart({super.key, required this.historicSeedData});

  @override
  State<HistoricLineChart> createState() => _HistoricLineChartState();
}

class _HistoricLineChartState extends State<HistoricLineChart> {
  List<Map<String, dynamic>> historicSeedData = [];

  @override
  void initState() {
    super.initState();
    historicSeedData = widget.historicSeedData.entries
        .map((entry) => {'period': entry.key, 'table': entry.value['table']})
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grouped Line Chart')),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: 300,
        padding: const EdgeInsets.all(16),
        child: charts.LineChart(
          _createSeriesData(),
          animate: true,
          animationDuration: const Duration(milliseconds: 500),
          behaviors: [
            charts.ChartTitle(
              'Period',
              behaviorPosition: charts.BehaviorPosition.bottom,
            ),
            charts.ChartTitle(
              'Amount',
              behaviorPosition: charts.BehaviorPosition.start,
            ),
            charts.SeriesLegend(position: charts.BehaviorPosition.end),
          ],
        ),
      ),
    );
  }

  final date = DateFormat("MMM");
  List<charts.Series<dynamic, num>> _createSeriesData() {
    List<ChartData> savingsData = [];
    List<ChartData> educationData = [];
    List<ChartData> expenditureData = [];
    List<ChartData> discretionaryData = [];
    String currency = context.read<Providers>().snapshotmodel.currency;

    // Extract data from historicSeedData
    for (var entry in widget.historicSeedData.entries) {
      //  final periods = data.keys.first;
      //String period = DateTime.parse(periods).millisecondsSinceEpoch as String,
      String period = date.format(DateTime.parse(entry.key));
      Map<String, dynamic> data = entry.value;

      savingsData.add(ChartData(period, data['table']['savings']));
      educationData.add(ChartData(period, data['table']['education']));
      expenditureData.add(ChartData(period, data['table']['expenditure']));
      discretionaryData.add(ChartData(period, data['table']['discretionary']));
    }

    return [
      charts.Series<ChartData, int>(
        id: 'Savings',
        data: savingsData,
        domainFn: (ChartData sales, _) => sales.period as int,
        measureFn: (ChartData sales, _) => sales.amount as num,
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(const Color(0xff00B050)),
        labelAccessorFn: (ChartData data, _) =>
            '$currency${data.amount.toInt()}',
      ),
      charts.Series<ChartData, int>(
        id: 'Education',
        data: educationData,
        domainFn: (ChartData sales, _) => sales.period as int,
        measureFn: (ChartData sales, _) => sales.amount as num,
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(const Color(0xffE6C069)),
        labelAccessorFn: (ChartData data, _) =>
            '$currency${data.amount.toInt()}',
      ),
      charts.Series<ChartData, int>(
        id: 'Expenditure',
        data: expenditureData,
        domainFn: (ChartData sales, _) => sales.period as int,
        measureFn: (ChartData sales, _) => sales.amount as num,
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(const Color(0xffD13B56)),
        labelAccessorFn: (ChartData data, _) =>
            '$currency${data.amount.toInt()}',
      ),
      charts.Series<ChartData, int>(
        id: 'Discretionary',
        data: discretionaryData,
        domainFn: (ChartData sales, _) => sales.period as int,
        measureFn: (ChartData sales, _) => sales.amount as num,
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(const Color(0xff4D7D99)),
        labelAccessorFn: (ChartData data, _) =>
            '$currency${data.amount.toInt()}',
      ),
    ];
  }
}

class ChartData {
  final String period;
  var amount;

  ChartData(this.period, this.amount);
}
