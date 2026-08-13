import 'package:GapHub/provider/acquisiProvider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../reapResult/reapResult.dart';

class AcquisitionList extends StatefulWidget {
  final String category;

  const AcquisitionList({super.key, required this.category});

  @override
  _AcquisitionListState createState() => _AcquisitionListState();
}

class _AcquisitionListState extends State<AcquisitionList> {
  @override
  void initState() {
    super.initState();
    print('category:${widget.category}');
    _fetchProperties();
  }

  void _fetchProperties() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AcquisiProvider>(
        context,
        listen: false,
      ).fetchProperties(widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<Providers>().snapshotmodel.currency;

    Orientation orientation = MediaQuery.of(context).orientation;
    final screenHeight = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final screenWidth = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Consumer<AcquisiProvider>(
      builder: (context, acquisitionProvider, child) {
        if (acquisitionProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }
        final properties = acquisitionProvider.properties;
        if (properties.isEmpty) {
          return const Center(child: Text('No properties found'));
        }
        return Column(
          children: properties.map((property) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  final provider = Provider.of<AcquisiProvider>(
                    context,
                    listen: false,
                  );

                  // provider.fetchPropertyDetails(
                  //   property.propertyId,
                  // );
                  provider.fetchProperties(widget.category);
                  navigateWithSlideTransition(
                    context: context,
                    destinationScreen: ReapResult(
                      propertyId: property.propertyId,
                      category: widget.category,
                    ),
                    transitionDuration: const Duration(milliseconds: 200),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0.0),
                  width: double.infinity,
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
                      Column(
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
                                  height: 200,
                                  width: double.infinity,
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                              Positioned(
                                top: screenHeight * .01,
                                right: screenWidth * .010,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image.asset('assets/images/deal.png'),
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
                                      height: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Text('${property.propertyId}'),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  property.propertyName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$currency${property.propertyTotalPrice}'
                                          .replaceAllMapped(
                                            RegExp(
                                              r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                            ),
                                            (Match m) => '${m[1]},',
                                          ),
                                      style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.blackColor,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '$currency${property.pricePerMonth} / '
                                              .replaceAllMapped(
                                                RegExp(
                                                  r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                                ),
                                                (Match m) => '${m[1]},',
                                              ),
                                          style: const TextStyle(
                                            fontFamily: 'Nunito',
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.w600,
                                            color: Color.fromARGB(
                                              255,
                                              39,
                                              39,
                                              39,
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          'Month',
                                          style: TextStyle(
                                            fontFamily: 'Nunito',
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w600,
                                            color: Color.fromARGB(
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
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.grayColor,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/icons/bed_room.png',
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        Text(
                                          property.noOfBedroom,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Nunito',
                                            color: AppColors.grayColor,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: screenWidth * 0.03),
                                    Row(
                                      children: [
                                        Image.asset('assets/icons/bathtub.png'),
                                        SizedBox(width: screenWidth * 0.01),
                                        Text(
                                          property.noOfBathroom,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Nunito',
                                            color: AppColors.grayColor,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: screenWidth * 0.03),
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/icons/measurement.png',
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        Text(
                                          property.propertyArea,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Nunito',
                                            color: AppColors.grayColor,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: screenHeight * .21,
                        left: screenWidth * .75,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: AppColors.grayColor,
                          ),
                          child:
                              acquisitionProvider.isPropertyFavorited(
                                property.propertyId,
                              )
                              ? Icon(
                                  Icons.favorite,
                                  size: screenWidth * .07,
                                  color: AppColors.primaryColor,
                                )
                              : Icon(
                                  Icons.favorite_border_outlined,
                                  size: screenWidth * .07,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
