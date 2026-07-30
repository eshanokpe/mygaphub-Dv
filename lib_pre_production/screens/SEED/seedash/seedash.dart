import 'dart:async';
import 'dart:convert';

import 'package:GapHub/screens/SEED/seedash/seedtabs.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:GapHub/utils/extensions.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Seedash extends StatefulWidget {
  const Seedash({super.key});

  @override
  _SeedashState createState() => _SeedashState();
}

class _SeedashState extends State<Seedash> {
  Map data = {};
  var d = DateFormat.yMMMM();
  var datez = "";
  double savings = 0;
  Map seedData = {};

  @override
  void initState() {
    seedData = context.read<Providers>().seedata;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = context.read<Providers>().seedata;

    if (data.containsKey('data')) {
      if (data['data'] != null && data['data'].containsKey('current_seed')) {
        if (data['data']["current_seed"] != null &&
            data['data']["current_seed"].containsKey("period")) {
          DateTime date = DateTime.parse(
            data['data']["current_seed"]["period"],
          );
          datez = d.format(date);
        } else {
          DateTime currentDate = DateTime.now();
          datez = DateFormat('MMMM, yyyy').format(currentDate);
        }
      }
    }

    return Scaffold(
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
      body: SingleChildScrollView(child: Seedtabs(datez: datez)),
    );
  }
}
