import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../widget/map_widget.dart';
import '../../widget/virtualTour_widget.dart';

class BuildVirtualTourSection extends StatelessWidget {
  final PropertyDetailModel propertyDetail;
  final double height;
  final double width;
  final String currency;

  const BuildVirtualTourSection({ 
    super.key,
    required this.propertyDetail,
    required this.height,
    required this.width,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Virtual Tour',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: width * .045,
            )),
        SizedBox(height: height * .01),
        Text(
            'Take a virtual tour to get a sense of the property and envision your experience',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w500,
              fontSize: width * .040,
            )),
        SizedBox(height: height * .01),
        VirtualTourWidget(
            propertyDetail: propertyDetail, width: width, height: height),
        const Divider(
          color: Color(0xffe2e2e2),
          thickness: 0.8,
        ),
        SizedBox(height: height * .01),
        Text('Map',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: width * .045,
            )),
        SizedBox(height: height * .01),
        SizedBox(
          width: width,
          height: height * 0.30,
          child:  MapWidget(
            propertyDetail: propertyDetail,
            currentLocation: const LatLng(42.4051, -83.1783),
          ),
        ),
        SizedBox(height: height * .01),
        const Divider(
          color: Color(0xffe2e2e2),
          thickness: 0.8, 
        ),
        SizedBox(height: height * .01),
      ],
    );
  }
}
