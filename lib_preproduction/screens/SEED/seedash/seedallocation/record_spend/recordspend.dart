import 'package:GapHub/utils/extensions.dart';
import 'package:flutter/material.dart';

import 'recorsSpenddata.dart';

class RecordSpend extends StatefulWidget {
  final bool month;
  const RecordSpend(this.month, {super.key});

  @override
  State<RecordSpend> createState() => _RecordSpendState();
}

class _RecordSpendState extends State<RecordSpend> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.withOpacity(.05),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'SEED',
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
      body: const SingleChildScrollView(child: RecordSpendData(true)),
    );
  }
}
