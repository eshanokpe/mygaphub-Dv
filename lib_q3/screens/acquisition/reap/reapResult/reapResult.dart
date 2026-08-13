import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:GapHub/provider/acquisiProvider.dart';
import 'package:GapHub/screens/acquisition/reap/widget/video_player_widget.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/avatarImage.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widget/floorPlanWidget.dart';
import '../widget/virtual_tour_widget.dart';
import 'viewAll.dart';
import 'widget/build_factfeature_section.dart';
import 'widget/build_investmentInterest_section.dart';
import 'widget/build_investment_section.dart';
import 'widget/build_virtualTour_section.dart';
import 'widget/build_neighbourhood_section.dart';
import 'widget/build_specification_section.dart';
import 'widget/build_header_section.dart';
import 'widget/build_description_section.dart';

class ReapResult extends StatefulWidget {
  final int propertyId;
  final String category;

  const ReapResult({
    super.key,
    required this.propertyId,
    required this.category,
  });

  @override
  State<ReapResult> createState() => _ReapResultState();
}

class _ReapResultState extends State<ReapResult> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  int _current = 0;

  @override
  void initState() {
    super.initState();
    _loadPropertyDetails();
  }

  void _loadPropertyDetails() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AcquisiProvider>(context, listen: false);
      provider.fetchPropertyDetails(widget.propertyId);
    });
  }

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Assets Details',
          style: TextStyle(
            fontSize: width * .040,
            fontFamily: 'Nunito',
            color: AppColors.grayColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        actions: const [AvatarImage()],
      ),
      body: SingleChildScrollView(
        child: Consumer<AcquisiProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              );
            }
            final propertyDetail = provider.propertyDetail;

            if (propertyDetail == null) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: [
                Stack(
                  children: [
                    CarouselSlider.builder(
                      carouselController: _carouselController,
                      itemCount:
                          (propertyDetail.propertyGalleryImages.isNotEmpty)
                          ? propertyDetail.propertyGalleryImages.length
                          : 1,
                      itemBuilder:
                          (BuildContext context, int index, int pageViewIndex) {
                            if (propertyDetail.propertyGalleryImages.isEmpty) {
                              return SizedBox(
                                width: width,
                                child: CachedNetworkImage(
                                  imageUrl:
                                      propertyDetail.propertyFeaturedImage,
                                  width: width,
                                  height: height * .29,
                                  fit: BoxFit.cover,
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
                              );
                            }

                            // Ensure index is within bounds
                            if (index >=
                                propertyDetail.propertyGalleryImages.length) {
                              return const SizedBox.shrink();
                            }

                            return SizedBox(
                              width: width,
                              child: CachedNetworkImage(
                                imageUrl:
                                    propertyDetail.propertyGalleryImages[index],
                                width: width,
                                height: height * .29,
                                fit: BoxFit.cover,
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
                            );
                          },
                      options: CarouselOptions(
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        enlargeCenterPage: false,
                        viewportFraction: 1.0,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _current = index;
                          });
                        },
                      ),
                    ),
                    Positioned(
                      top: height * .22,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: propertyDetail.propertyGalleryImages
                            .asMap()
                            .entries
                            .map((entry) {
                              return GestureDetector(
                                onTap: () =>
                                    _carouselController.jumpToPage(entry.key),
                                child: Container(
                                  width: 8.0,
                                  height: 8.0,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        (Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : const Color(0xffe8e8e8))
                                            .withOpacity(
                                              _current == entry.key ? 0.9 : 0.4,
                                            ),
                                  ),
                                ),
                              );
                            })
                            .toList(),
                      ),
                    ),
                    Positioned(
                      top: height * .03,
                      right: width * .05,
                      child: InkWell(
                        onTap: () {
                          navigateWithSlideTransition(
                            context: context,
                            destinationScreen: ViewAll(
                              initialTabIndex: 0,
                              propertyDetail: propertyDetail,
                            ),
                            transitionDuration: const Duration(
                              milliseconds: 200,
                            ),
                          );
                        },
                        child: Container(
                          height: height * .04,
                          decoration: BoxDecoration(
                            color: const Color(0xffF5F5F5).withOpacity(.50),
                            border: Border.all(
                              color: const Color(0xffE5E5E5),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Image.asset(
                                    width: 30.h,
                                    'assets/icons/images_icon.png',
                                  ),
                                  SizedBox(width: width * .02),
                                  Text(
                                    (propertyDetail
                                                .propertyGalleryImages
                                                .length >
                                            12
                                        ? '12 +'
                                        : propertyDetail
                                              .propertyGalleryImages
                                              .length
                                              .toString()),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontFamily: 'Nunito',
                                      color: AppColors.blackColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * .04),
                  child: Consumer<AcquisiProvider>(
                    builder: (context, provider, child) {
                      final propertyDetail = provider.propertyDetail;
                      if (propertyDetail == null) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: height * .02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  VideoPlayerWidget(
                                    propertyDetail: propertyDetail,
                                  ),
                                  SizedBox(width: width * .02),
                                  VirtualTourIcon(
                                    propertyDetail: propertyDetail,
                                  ),
                                  SizedBox(width: width * .02),
                                  FloorPlanWidget(
                                    propertyDetail: propertyDetail,
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  navigateWithSlideTransition(
                                    context: context,
                                    destinationScreen: ViewAll(
                                      initialTabIndex: 0,
                                      propertyDetail: propertyDetail,
                                    ),
                                    transitionDuration: const Duration(
                                      milliseconds: 200,
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      'View all',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 10.sp,
                                      color: AppColors.primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height * .02),
                          BuildHeaderSection(
                            propertyDetail: propertyDetail,
                            width: width,
                            height: height,
                            currency: '£',
                          ),
                          BuildDescriptionSection(
                            propertyDetail: propertyDetail,
                            width: width,
                            height: height,
                            currency: '£',
                          ),
                          BuildSpecificationSection(
                            propertyDetail: propertyDetail,
                            width: width,
                            height: height,
                            currency: '£',
                          ),
                          BuildInvestmentSection(
                            propertyDetail: propertyDetail,
                            width: width,
                            height: height,
                            currency: '£',
                          ),
                          BuildFactFeaturesSection(
                            propertyDetail: propertyDetail,
                            width: width,
                            height: height,
                            currency: '£',
                          ),
                          BuildNeighbourhoodSection(
                            propertyDetail: propertyDetail,
                            width: width,
                            height: height,
                            currency: '£',
                          ),
                          // BuildVirtualTourSection(
                          //   propertyDetail: propertyDetail,
                          //   width: width,
                          //   height: height,
                          //   currency: '£',
                          // ),
                          BuildInvestmentInterestSection(
                            propertyDetail: propertyDetail,
                            width: width,
                            height: height,
                            currency: '£',
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: height * .02),
                SizedBox(height: height * .08),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _launchBrochure(
    BuildContext context,
    PropertyDetailModel propertyDetail,
  ) async {
    // Safe null check for brochure
    final brochureUrl = propertyDetail.brochure;
    if (brochureUrl == null || brochureUrl.isEmpty) {
      Fluttertoast.showToast(
        backgroundColor: AppColors.primaryColor,
        textColor: Colors.white,
        msg: 'No brochure document uploaded.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    // Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        );
      },
    );

    try {
      final Uri url = Uri.parse(brochureUrl);

      // Use launchUrl with mode for better iOS compatibility
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode
              .externalApplication, // Forces opening in Safari/External app on iOS
        );
      } else {
        throw Exception('Could not launch $brochureUrl');
      }
    } catch (e) {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'Failed to open brochure.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      print('Error launching URL: $e');
    } finally {
      // Dismiss the loading spinner safely
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    }
  }
}
