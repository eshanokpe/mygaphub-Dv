import 'package:GapHub/models/propertyModel.dart';
import 'package:GapHub/screens/acquisition/reap/reap.dart';
import 'package:GapHub/screens/homepage/widget/row_view_details.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/material.dart';
import 'slider_acquisition.dart';

class Acquisitioncard extends StatefulWidget {
  final String? identifier;
  final List<PropertyModel>? properties;
  const Acquisitioncard({super.key, this.properties, this.identifier});

  @override
  _AcquisitioncardState createState() => _AcquisitioncardState();
}

class _AcquisitioncardState extends State<Acquisitioncard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        RowViewDetails(
          mainText:
              ' ${widget.identifier == "360" ? '' : 'Latest '}acquisition opportunities',
          detailText: 'View',
          onTap: () {
            return navigateWithSlideTransition(
              context: context,
              destinationScreen: const Reap(),
              transitionDuration: const Duration(milliseconds: 200),
            );
          },
          arrowTap: true,
        ),
        SizedBox(height: height * .02),
        if (widget.properties!.isEmpty)
          const Center(child: CircularProgressIndicator())
        else
          SliderAcquisition(properties: widget.properties),
      ],
    );
  }
}
