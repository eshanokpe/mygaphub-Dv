import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:flutter/material.dart';

class ShareUnitWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final PropertyDetailModel propertyDetail;

  const ShareUnitWidget({
    super.key,
    this.width,
    this.height,
    required this.propertyDetail,
  });

  @override
  Widget build(BuildContext context) {
    // Convert string values to integers
    final totalShareUnit = propertyDetail.totalShareUnit ?? 0;
    final remainingShareUnit = propertyDetail.remainingShareUnit ?? 0;
    final filledUnits =
        totalShareUnit - remainingShareUnit; // Units that have been taken

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 30.0,
            width: width! * .30,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Row(
              children: List.generate(totalShareUnit, (index) {
                // Apply color based on the filled units
                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: index < filledUnits
                          ? const Color(0xff8EA2CC) // Filled units
                          : Colors.white, // Remaining units
                      // border: Border.all(width: 0.1, color: Color(0xff808080)),
                      borderRadius: index == 0
                          ? const BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              bottomLeft: Radius.circular(15.0),
                            )
                          : index == totalShareUnit - 1
                          ? const BorderRadius.only(
                              topRight: Radius.circular(15.0),
                              bottomRight: Radius.circular(15.0),
                            )
                          : null,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$remainingShareUnit of ${totalShareUnit == 0 ? 10 : totalShareUnit} units left',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              color: const Color(0xff808080),
              fontSize: width! * .038,
            ),
          ),
        ],
      ),
    );
  }
}
