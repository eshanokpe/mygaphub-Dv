import 'package:GapHub/utils/extensions.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AverageSeed extends StatefulWidget {
  Map data;
  AverageSeed({super.key, required this.data});

  @override
  State<AverageSeed> createState() => _AverageSeedState();
}

class _AverageSeedState extends State<AverageSeed> {
  Map dashData = {};
  Map seedData = {};
  num total = 0;
  num saving = 0;
  num education = 0;
  num expenditure = 0;
  num discretionary = 0;

  @override
  void initState() {
    dashData = context.read<Providers>().dashdata;
    seedData = context.read<Providers>().seedata;
    total = seedData['data']['average_detail']['total'];
    saving = seedData['data']['average_detail']['table']['savings'];
    education = seedData['data']['average_detail']['table']['education'];
    expenditure = seedData['data']['average_detail']['table']['education'];
    discretionary =
        seedData['data']['average_detail']['table']['discretionary'];
    print('seedData:${seedData['data']['average_detail']}');
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.withOpacity(.05),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Average Seed',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: context.width(.045),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: height * .04),
            Padding(
              padding: EdgeInsets.only(left: width * .05, bottom: height * .01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Total : $currency ${total.toStringAsFixed(2) ?? '0'}"
                        .replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        ),
                    style: TextStyle(
                      fontSize: width * .04,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * .02),
            Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  child: Card(
                    color: const Color(0xff00B050),
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
                            'Savings',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: width * .09,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '$currency${saving.toStringAsFixed(2)}'
                                .replaceAllMapped(
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
            SizedBox(height: height * .02),
            Center(
              child: GestureDetector(
                child: Card(
                  color: const Color(0xffE6C069),
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
                          'Education',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: width * .09,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '$currency${education.toStringAsFixed(2)}'
                              .replaceAllMapped(
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
            SizedBox(height: height * .02),
            Center(
              child: GestureDetector(
                child: Card(
                  color: const Color(0xffD13B56),
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
                          'Expenditure',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: width * .09,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '$currency${(expenditure).toStringAsFixed(2)}'
                              .replaceAllMapped(
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
            SizedBox(height: height * .02),
            Center(
              child: GestureDetector(
                child: Card(
                  color: const Color.fromARGB(255, 77, 125, 153),
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
                          'Discretionary',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: width * .09,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '$currency${(discretionary).toStringAsFixed(2)}'
                              .replaceAllMapped(
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
            SizedBox(height: height * .02),
          ],
        ),
      ),
    );
  }
}
