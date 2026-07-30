import 'package:GapHub/utils/extensions.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'reports/periodicData.dart';
import 'transaction/transactionPeriodicData.dart';

class TransactionDetials extends StatefulWidget {
  final String? date;
  final String historicdate;
  final List list;
  final List transdata;

  TransactionDetials({
    Key? key,
    this.date,
    required this.historicdate,
    required this.list,
    required this.transdata,
  });

  @override
  State<TransactionDetials> createState() => _TransactionDetialsState();
}

class _TransactionDetialsState extends State<TransactionDetials> {
  String historicdate = '';

  @override
  Widget build(BuildContext context) {
    String currency = context.watch<Providers>().snapshotmodel.currency;
    Orientation orientation = MediaQuery.of(context).orientation;
    double screenWidth = MediaQuery.of(context).size.width;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.withOpacity(.05),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Historic Seed ',
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: height * .05),
            TransactionPeriodicData(
              date: widget.date ?? '',
              historicdate: historicdate ?? '',
              list: widget.list ?? [],
            ),
            SizedBox(height: height * .02),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Table(
                border: const TableBorder(
                  horizontalInside: BorderSide(color: Colors.blue, width: 0.5),
                ),
                children: [
                  TableRow(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "SEED Category",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: context.width(.035),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "Budget Item",
                            style: TextStyle(
                              fontSize: context.width(.035),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "Budget Amount",
                            style: TextStyle(
                              fontSize: context.width(.035),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "Actual Amount",
                            style: TextStyle(
                              fontSize: context.width(.035),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "Differences",
                            style: TextStyle(
                              fontSize: context.width(.035),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "Signal",
                            style: TextStyle(
                              fontSize: context.width(.035),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...widget.transdata.asMap().entries.map((data) {
                    return TableRow(
                      decoration: const BoxDecoration(color: Colors.white10),
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child:
                                  data.value['seed_category'].toString() ==
                                      'expenditure'
                                  ? Center(
                                      child: Container(
                                        height: width * .04,
                                        width: width * .04,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xffD13B56),
                                              blurRadius: 0,
                                              offset: Offset(
                                                width * .006,
                                                width * .005,
                                              ),
                                            ),
                                          ],
                                          borderRadius: BorderRadius.circular(
                                            width * .005,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xffD13B56),
                                          ),
                                        ),
                                      ),
                                    )
                                  : data.value['seed_category'].toString() ==
                                        'savings'
                                  ? Center(
                                      child: Container(
                                        height: width * .04,
                                        width: width * .04,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xff00B050),
                                              blurRadius: 0,
                                              offset: Offset(
                                                width * .006,
                                                width * .005,
                                              ),
                                            ),
                                          ],
                                          borderRadius: BorderRadius.circular(
                                            width * .005,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xff00B050),
                                          ),
                                        ),
                                      ),
                                    )
                                  : data.value['seed_category'].toString() ==
                                        'education'
                                  ? Center(
                                      child: Container(
                                        height: width * .04,
                                        width: width * .04,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xffE6C069),
                                              blurRadius: 0,
                                              offset: Offset(
                                                width * .006,
                                                width * .005,
                                              ),
                                            ),
                                          ],
                                          borderRadius: BorderRadius.circular(
                                            width * .005,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xffE6C069),
                                          ),
                                        ),
                                      ),
                                    )
                                  : data.value['seed_category'].toString() ==
                                        'discretionary'
                                  ? Center(
                                      child: Container(
                                        height: width * .04,
                                        width: width * .04,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color.fromARGB(
                                                255,
                                                77,
                                                125,
                                                153,
                                              ),
                                              blurRadius: 0,
                                              offset: Offset(
                                                width * .006,
                                                width * .005,
                                              ),
                                            ),
                                          ],
                                          borderRadius: BorderRadius.circular(
                                            width * .005,
                                          ),
                                          border: Border.all(
                                            color: const Color.fromARGB(
                                              255,
                                              77,
                                              125,
                                              153,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const Text('data'),
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text('${data.value['label']}'),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              '$currency${num.parse(data.value['amount']).toStringAsFixed(2)}'
                                  .replaceAllMapped(
                                    new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]},',
                                  ),
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              '$currency${num.parse(data.value['actual'].toString()).toStringAsFixed(2)}'
                                  .replaceAllMapped(
                                    new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]},',
                                  ),
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${currency}${(num.parse(data.value['amount'].toString()) - num.parse(data.value['actual'].toString())).toStringAsFixed(2)}'
                                        .replaceAllMapped(
                                          RegExp(
                                            r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                          ),
                                          (Match m) => '${m[1]},',
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 3.0),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child:
                              (num.parse(data.value['amount'].toString()) -
                                      num.parse(
                                        data.value['actual'].toString(),
                                      ) <
                                  0)
                              ? Container(
                                  width: width * 0.05,
                                  height: height * 0.03,
                                  margin: const EdgeInsets.only(top: 10),
                                  color: Colors.red,
                                  child: const Icon(
                                    Icons.arrow_drop_down,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                )
                              : (num.parse(
                                              data.value['amount'].toString() ??
                                                  '0',
                                            ) -
                                            num.parse(
                                              data.value['actual'].toString() ??
                                                  '0',
                                            ) >
                                        0 ||
                                    num.parse(
                                              data.value['amount'].toString() ??
                                                  '0',
                                            ) -
                                            num.parse(
                                              data.value['actual'].toString() ??
                                                  '0',
                                            ) ==
                                        0)
                              ? Container(
                                  width: width * 0.05,
                                  height: height * 0.03,
                                  margin: const EdgeInsets.only(top: 10),
                                  color: Colors.green,
                                  child: const Icon(
                                    Icons.arrow_drop_up,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                )
                              : const SizedBox(), // Use SizedBox instead of an empty string
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
