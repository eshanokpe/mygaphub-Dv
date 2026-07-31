import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class Carouselfull extends StatefulWidget {
  final List<Widget> imageList;

  const Carouselfull(this.imageList, {super.key});
  @override
  _CarouselfullState createState() => _CarouselfullState();
}

class _CarouselfullState extends State<Carouselfull> {
  int current = 1;
  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          bottom: MediaQuery.of(context).padding.top,
        ),
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            CarouselSlider(
              items: widget.imageList,
              options: CarouselOptions(
                height: height,
                onScrolled: (value) {},
                // aspectRatio: 16 / 9,
                initialPage: 0,
                enlargeCenterPage: false,
                viewportFraction: 1.0,
                enableInfiniteScroll: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    current = index + 1;
                  });
                },
                reverse: false,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 1500),
                autoPlayCurve: Curves.fastOutSlowIn,
                scrollDirection: Axis.horizontal,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$current of ${widget.imageList.length}',
                  style: TextStyle(color: Colors.white, fontSize: width * .05),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/swipe_left.png',
                      height: height * .03,
                    ),
                    SizedBox(width: width * .01),
                    Text(
                      'Swipe to view more ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * .05,
                      ),
                    ),
                    SizedBox(width: width * .01),
                    Image.asset(
                      'assets/images/swipe_right.png',
                      height: height * .03,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
