import 'package:flutter/material.dart';

class Hspace extends StatelessWidget {
  final double height;
  const Hspace(this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}

class Wspace extends StatelessWidget {
  final double width;
  const Wspace(this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width);
  }
}
