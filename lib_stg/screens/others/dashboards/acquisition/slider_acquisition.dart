import 'package:GapHub/models/propertyModel.dart';
import 'package:GapHub/provider/acquisiProvider.dart';
import 'package:GapHub/screens/acquisition/reap/reapResult/reapResult.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SliderAcquisition extends StatelessWidget {
  final List<PropertyModel>? properties;

  const SliderAcquisition({super.key, this.properties});

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    Orientation orientation = MediaQuery.of(context).orientation;
    final screenHeight = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final screenWidth = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return CarouselSlider(
      options: CarouselOptions(
        height: isTablet ? 340.h : 320.h,
        enableInfiniteScroll: false,
        enlargeCenterPage: true,
        viewportFraction: 1.0,
        aspectRatio: 16 / 9,
        autoPlay: true,
        enlargeStrategy: CenterPageEnlargeStrategy.scale,
      ),
      items: properties!.map((property) {
        return InkWell(
          onTap: () {
            print('Property propertyCountrie: ${property.propertyCountrie}');
            final provider = Provider.of<AcquisiProvider>(
              context,
              listen: false,
            );

            provider.fetchProperties(property.propertyCountrie);
            navigateWithSlideTransition(
              context: context,
              destinationScreen: ReapResult(
                propertyId: property.propertyId,
                category: property.propertyCountrie,
              ),
              transitionDuration: const Duration(milliseconds: 200),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 0.0),
            width: double.infinity,
            // height: 400.h,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 253, 253, 253),
              border: Border.all(
                color: Colors.grey.withOpacity(0.5),
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                ListView(
                  shrinkWrap:
                      true, // Allows the ListView to take the height of its content.
                  physics:
                      const NeverScrollableScrollPhysics(), // Disables scrolling within the ListView itself.
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: property.propertyFeaturedImage,
                            fit: BoxFit.cover,
                            height: 200.h,
                            width: double.infinity,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                width: 30.0,
                                height: 30.0,
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: property.propertySaleOptions == 'Split Deal'
                                ? Image.asset('assets/images/deal.png')
                                : Container(),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.asset(
                                property.propertyCountrie == "US"
                                    ? 'assets/images/usa.png'
                                    : property.propertyCountrie == "UK"
                                    ? 'assets/images/ukflag.jpeg'
                                    : 'assets/images/ngflag.png',
                                width: 30.w,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.propertyName,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '£${property.propertyPrice}'.replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (Match m) => '${m[1]},',
                                ),
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.blackColor,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '£${property.propertyPrice} / '
                                        .replaceAllMapped(
                                          RegExp(
                                            r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                          ),
                                          (Match m) => '${m[1]},',
                                        ),
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color.fromARGB(
                                        255,
                                        39,
                                        39,
                                        39,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Month',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color.fromARGB(
                                        255,
                                        39,
                                        39,
                                        39,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            property.propertyAddress,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w400,
                              color: AppColors.grayColor,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              _buildPropertyFeature(
                                'assets/icons/bed_room1.jpg',
                                property.noOfBedroom,
                                screenWidth,
                              ),
                              _buildPropertyFeature(
                                'assets/icons/bathtub1.jpg',
                                property.noOfBathroom,
                                screenWidth,
                              ),
                              _buildPropertyFeature(
                                'assets/icons/measurement1.jpg',
                                property.propertyArea,
                                screenWidth,
                              ),
                            ],
                          ),
                          SizedBox(height: 5.h),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 180.h,
                  left: 300.w,
                  child: Container(
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      'assets/images/favoritee.png',
                      width: 34.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPropertyFeature(
    String assetPath,
    String text,
    double screenWidth,
  ) {
    return Row(
      children: [
        Image.asset(assetPath, width: 13.h),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'Nunito',
            color: AppColors.grayColor,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(width: 6.w),
      ],
    );
  }
}
