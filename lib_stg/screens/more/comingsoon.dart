import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Comingsoon extends StatelessWidget {
  const Comingsoon({super.key});

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'GAPhub',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: width * .05,
            color: Colors.white,
          ),
        ),
      ),
      body: const ComingsoonWid(),
    );
  }
}

class ComingsoonWid extends StatelessWidget {
  const ComingsoonWid({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(child: Image.asset('assets/images/comingsoon.png')),
    );
  }
}
