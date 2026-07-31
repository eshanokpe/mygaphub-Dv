import 'package:flutter/material.dart';

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;
  final bool doiwant;

  const Indicator({
    super.key,
    required this.color,
    required this.text,
    this.isSquare = false,
    this.size = 16.0,
    this.doiwant = false,
    this.textColor = const Color(0xff505050),
  });

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
              color: color,
            ),
          ),
          SizedBox(width: width * .008),
          doiwant
              ? Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: width * .035,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                )
              : text.length < 8
              ? Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: width * .03,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                )
              : Text(
                  "${text.substring(0, 5)}..",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: width * .03,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
          SizedBox(width: width * .03),
        ],
      ),
    );
  }
}
