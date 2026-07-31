import 'package:GapHub/screens/more/settings/settings.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../provider/currencyProvider.dart';

class AvatarImage extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  const AvatarImage({super.key});

  // Default asset constant
  static const String _defaultAsset = 'assets/settings/avatar.png';

  // List of invalid/default server avatar paths
  static const List<String> _invalidServerPaths = [
    'null',
    '$imgPrefix/assets/storage/avatar/default.png',
    '$imgPrefix/assets/storage/avatar/Avatar_Male 1.png',
  ];

  String _getValidImageUrl(String? imgurl) {
    // Handle null or empty
    if (imgurl == null || imgurl.isEmpty) {
      return _defaultAsset;
    }

    // Check against invalid server paths
    if (_invalidServerPaths.contains(imgurl)) {
      return _defaultAsset;
    }

    // Handle URL replacements
    if (imgurl.contains('/user/')) {
      imgurl = imgurl.replaceFirst('//app/', '/');
    } else if (imgurl.contains('/avatar/')) {
      imgurl = imgurl.replaceFirst(
        "$imgPrefix/app/assets/storage/app",
        "app/assets/storage/",
      );
    }

    return imgurl;
  }

  Widget _buildFallbackImage(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, size: 20.sp, color: Colors.grey[400]),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    String? rawImgUrl = context.watch<Providers>().details[7];
    String baseCurrency = context.watch<CurrencyProvider>().baseCurrency;

    // Get validated image URL
    String imgurl = _getValidImageUrl(rawImgUrl);

    // Determine if it's a network image
    bool isNetwork = imgurl.startsWith("http") || imgurl.startsWith("https");

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 16.w, 0),
      child: GestureDetector(
        onTap: () async {
          if (baseCurrency.isEmpty) {
            await context.read<CurrencyProvider>().fetchBaseCurrency();
          }
          print("baseCurrency in AvatarImage: $baseCurrency");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Settings(baseCurrency: baseCurrency),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(0.sp),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color.fromRGBO(0, 0, 0, 0.08),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(width * .06),
            child: SizedBox(
              width: 28.w,
              height: 28.h,
              child: isNetwork
                  ? CachedNetworkImage(
                      imageUrl: imgurl,
                      width: 28.w,
                      height: 28.h,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder: (context, url, progress) =>
                          Center(
                            child: SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                value: progress.progress,
                              ),
                            ),
                          ),
                      errorWidget: (context, url, error) {
                        print('Network image error: $error for URL: $url');
                        return _buildFallbackImage(28.w, 28.h);
                      },
                    )
                  : Image.asset(
                      imgurl,
                      width: 28.w,
                      height: 28.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Asset error: $error for path: $imgurl');
                        return _buildFallbackImage(28.w, 28.h);
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
