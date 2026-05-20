import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:GapHub/provider/acquisiProvider.dart';
import 'package:GapHub/screens/acquisition/reap/reapResult/share_property.dart';
import 'package:GapHub/screens/acquisition/reap/reapResult/share_units_widget.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/customBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class BuildHeaderSection extends StatelessWidget {
  final PropertyDetailModel propertyDetail;
  final double height;
  final double width;
  final String currency;

  const BuildHeaderSection({
    super.key,
    required this.propertyDetail,
    required this.height,
    required this.width,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AcquisiProvider>(context, listen: false);

    // Normalize country code to uppercase with a fallback
    final countryCode = (propertyDetail.propertyCountrie ?? 'US').toUpperCase();

    // Determine flag asset based on country code
    String flagAsset;
    switch (countryCode) {
      case 'US':
        flagAsset = 'assets/images/acquisition/usaflag.png';
        break;
      case 'UK':
        flagAsset = 'assets/images/acquisition/ukflag.jpeg';
        break;
      case 'NIGERIA':
        flagAsset = 'assets/images/ngflag.png';
        break;
      default:
        flagAsset = 'assets/images/acquisition/usaflag.png';
    }

    return Column(
      children: [
        // Country and favorite row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Country flag and name
            Row(
              children: [
                Image.asset(
                  flagAsset,
                  width: 24.w,
                  height: 14.h,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.flag, size: 24),
                ),
                SizedBox(width: width * .005),
                Text(
                  ' REAP ${propertyDetail.propertyCountrie ?? 'Unknown'}',
                  style: TextStyle(
                    fontFamily: 'NunitoSan',
                    fontWeight: FontWeight.w900,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),

            // Favorite and share buttons
            Row(
              children: [
                // Favorite button
                InkWell(
                  onTap: () {
                    if (provider.isPropertyFavorited(
                      propertyDetail.propertyId,
                    )) {
                      provider.removeFromFavorite(propertyDetail.propertyId);
                    } else {
                      provider.addToFavorite(propertyDetail.propertyId);
                    }
                  },
                  child: Consumer<AcquisiProvider>(
                    builder: (context, provider, _) {
                      return provider.isPropertyFavorited(
                            propertyDetail.propertyId,
                          )
                          ? Icon(
                              Icons.favorite,
                              size: width * .06,
                              color: AppColors.primaryColor,
                            )
                          : Image.asset(
                              'assets/images/acquisition/heart.svg',
                              width: 24.w,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.favorite_border, size: 24),
                            );
                    },
                  ),
                ),
                SizedBox(width: width * .03),

                // Share button (assuming SharedProperty is another widget)
                SharedProperty(propertyDetail: propertyDetail, currency: '£'),
              ],
            ),
          ],
        ),
        SizedBox(height: height * .01),

        // Price information row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Total price with split deal option
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  SizedBox(width: width * .01),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          '$currency${propertyDetail.propertyTotalPrice}'
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              ),
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(width: width * .02),
                        propertyDetail.propertySaleOptions == 'Split Deal'
                            ? InkWell(
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
                                        title: 'Split Deal',
                                        content:
                                            'This represents the cost per unit in the division of the total property price',
                                      );
                                    },
                                  );
                                },
                                child: Image.asset(
                                  'assets/icons/red_zone.png',
                                  width: 20.w,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.info_outline, size: 20.w),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Monthly price
            Row(
              children: [
                Text(
                  '$currency${propertyDetail.pricePerMonth}'.replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  ),
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(width: width * .01),
                Text(
                  '/ Month',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff272727),
                    fontSize: width * .035,
                  ),
                ),
              ],
            ),
          ],
        ),
        propertyDetail.propertySaleOptions == 'Split Deal'
            ?
              // Share unit widget (assuming this is another component)
              ShareUnitWidget(
                width: width,
                height: height,
                propertyDetail: propertyDetail,
              )
            : SizedBox(height: height * .01),
      ],
    );
  }
}
