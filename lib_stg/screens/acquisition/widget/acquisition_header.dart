import 'package:GapHub/widgets/customBottomSheet.dart';
import 'package:flutter/material.dart';

class AcquisitionHeader extends StatelessWidget {
  final bool backArrow;
  const AcquisitionHeader({super.key, this.backArrow = true});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(
                  right: width * 0.06,
                  left: width * 0.06,
                ),
                height: height * 0.05,
                color: Colors.white,
              ),
            ],
          ),
        ),
        backArrow == true
            ? Positioned(
                left: 15,
                top: 30,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              )
            : Positioned(
                left: 15,
                top: 25,
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0),
                        ),
                      ),
                      builder: (BuildContext context) {
                        return const CustomBottomSheet(
                          title: 'Disclaimer',
                          content:
                              'The information provided in our asset acquisition content is intended solely for informational purposes. It should not be considered as financial advice, investment recommendations, or a solicitation to buy or sell any financial products. Always conduct your own research and consult with a qualified financial advisor before making any investment decisions.',
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.asset(
                      'assets/icons/red_zone.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
              ),
        Positioned(
          right: 15,
          top: 25,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/avatar.png',
              width: 30,
              height: 30,
            ),
          ),
        ),
      ],
    );
  }
}
