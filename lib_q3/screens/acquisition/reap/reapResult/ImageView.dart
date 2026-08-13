import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  final PropertyDetailModel propertyDetail;

  const ImageView({super.key, required this.propertyDetail});

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    final bool hasGalleryImages =
        propertyDetail.propertyGalleryImages.isNotEmpty;

    final int itemCount = hasGalleryImages
        ? propertyDetail.propertyGalleryImages.length
        : 1;

    return Container(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 0.0,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final imageNumber = index + 1;
          final totalImages = hasGalleryImages
              ? propertyDetail.propertyGalleryImages.length
              : 1;
          final imageUrl = hasGalleryImages
              ? propertyDetail.propertyGalleryImages[index]
              : propertyDetail.propertyFeaturedImage;

          return Container(
            color: Colors.grey[300],
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
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
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                Positioned(
                  top: 10,
                  left: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xfff5f5f5), // Background color
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12.0),
                        bottomLeft: Radius.circular(12.0),
                      ), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      '$imageNumber of $totalImages',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
