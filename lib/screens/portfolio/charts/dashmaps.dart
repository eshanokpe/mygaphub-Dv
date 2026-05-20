import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Dashmaps extends StatelessWidget {
  const Dashmaps({
    super.key,
    this.SA = "0",
    this.A = "0",
    this.AP = "0",
    this.E = "0",
    this.Au = "0",
    this.NA = "0",
  });

  final SA;
  final A;
  final AP;
  final E;
  final Au;
  final NA;

  //   @override
  //   _Dashmaps createState() => _Dashmaps();
  // }

  // class _Dashmaps extends State<Dashmaps> {

  // var _SA;
  // var _A;
  // var _AP;
  // var _E;
  // var _Au;
  // var _NA;

  // @override
  // void initState(){
  //   super.initState();

  //   _SA = widget.SA;
  //   _A = widget.A;
  //   _AP = widget.AP;
  //   _E = widget.E;
  //   _Au = widget.Au;
  //   _NA = widget.NA;

  // }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    return Column(
      children: [
        Stack(
          children: [
            Column(
              children: [
                SizedBox(height: height * .05),
                Image(
                  image: const AssetImage('assets/images/worldmap.png'),
                  width: width * 1.00,
                ),
                // CachedNetworkImage(
                //   imageUrl: 'assets/images/worldmap.png',
                //   width: width * 0.90,
                //   placeholder: (context, url) => CircularProgressIndicator(),
                //   errorWidget: (context, url, error) => Icon(Icons.error),
                // ),
                SizedBox(height: height * .007),
              ],
            ),
            Positioned(
              bottom: height * .16,
              left: width * .1,
              child: Marker(NA, "N.America", const Color(0xffEC7E7F), .26),
            ),
            Positioned(
              bottom: width * .33,
              left: width * .40,
              child: Marker(E, "Europe", const Color(0xffB2D985), 0.20),
            ),
            Positioned(
              bottom: width * .33,
              right: width * .10,
              child: Marker(AP, "Asia/Pacific", const Color(0xff6DC0EC), .26),
            ),
            Positioned(
              top: width * .53,
              left: width * .41,
              child: BottomMarker(A, "Africa", const Color(0xffEFEDB7), .11),
            ),
            Positioned(
              top: width * .59,
              left: width * .23,
              child: BottomMarker(
                SA,
                "S/America",
                const Color(0xff40D3B7),
                .05,
              ),
            ),
            Positioned(
              top: width * .60,
              right: width * .10,
              child: BottomMarker(
                Au,
                "Australia",
                const Color(0xffEDAC5C),
                .03,
              ),
            ),
            SizedBox(height: height * .35),
          ],
        ),
      ],
    );
  }
}

class Marker extends StatelessWidget {
  final String percent;
  final String continent;
  final Color color;
  final double height;

  const Marker(
    this.percent,
    this.continent,
    this.color,
    this.height, {
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: width * .035, left: width * .005),
              child: Text(
                continent,
                style: TextStyle(
                  color: const Color(0xff676767),
                  fontSize: width * .030,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Text(
                  "$percent%",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * .025,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Container(
              height: width * .025,
              width: width * .025,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black, // Border color
                  width: 1, // Border width
                ),
              ),
            ),
            Container(
              color: Colors.black,
              height: width * height,
              width: width * .002,
            ),
            Container(
              height: width * .020,
              width: width * .020,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black, // Border color
                  width: 1, // Border width
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class BottomMarker extends StatelessWidget {
  final String percent;
  final String continent;
  final Color color;
  final double height;

  const BottomMarker(
    this.percent,
    this.continent,
    this.color,
    this.height, {
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              height: width * .020,
              width: width * .020,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black, // Border color
                  width: 1, // Border width
                ),
              ),
            ),
            Container(
              color: Colors.black,
              height: width * height,
              width: width * .002,
            ),
            Container(
              height: width * .025,
              width: width * .025,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black, // Border color
                  width: 1, // Border width
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: width * .005, left: width * .005),
              child: Text(
                continent,
                style: TextStyle(
                  color: const Color(0xff676767),
                  fontSize: width * .030,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Text(
                  "$percent%",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * .025,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
