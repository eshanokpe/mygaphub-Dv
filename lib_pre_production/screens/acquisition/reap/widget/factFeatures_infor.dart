import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:flutter/material.dart';

class FactFeaturesInfor extends StatelessWidget {
  final PropertyDetailModel propertyDetail;
  final double width;
  final double height;

  const FactFeaturesInfor({
    super.key,
    required this.propertyDetail,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < propertyDetail.factAndFeatures.length; i += 2)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    propertyDetail.factAndFeatures[i]['name'] ?? '',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
              if (i + 1 < propertyDetail.factAndFeatures.length)
                const SizedBox(width: 8.0), // Space between items
              if (i + 1 < propertyDetail.factAndFeatures.length)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      propertyDetail.factAndFeatures[i + 1]['name'] ?? '',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        fontSize: width * .043,
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
