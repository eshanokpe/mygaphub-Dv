import 'package:GapHub/utils/extensions.dart';
import 'package:flutter/material.dart';

import 'seedallocation/seedallocation.dart';

class Setbudget extends StatefulWidget {
  final bool month;
  const Setbudget(this.month, {super.key});

  @override
  State<Setbudget> createState() => _SetbudgetState();
}

class _SetbudgetState extends State<Setbudget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.withOpacity(.05),
      appBar: AppBar(
        backgroundColor: Colors.blue.withOpacity(.0),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.0),
          child: Divider(
            thickness: 0.5,
            color: Color.fromARGB(253, 196, 196, 196),
          ),
        ),
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
      body: SingleChildScrollView(child: SeedAllocation(true)),
    );
  }
}
