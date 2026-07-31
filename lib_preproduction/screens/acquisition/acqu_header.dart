import 'dart:async';
import 'package:GapHub/screens/more/settings/settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CustomAcquisitionHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  const CustomAcquisitionHeader({super.key, required this.title});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;
    final screenHeight = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final screenWidth = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    String imgurl = context.watch<Providers>().details[7];
    String imgurl_;
    imgurl_ = imgurl.replaceFirst(
      // 'https://mygaphub.com/assets/storage',
      'https://appstaging.mygaphub.com/assets/storage',
      '/app/assets/storage/',
    );
    imgurl = '$imgPrefix$imgurl_';
    // Check if imgurl_ contains a specific link in imgPrefix
    if (imgurl_.contains('$imgPrefix')) {
      imgurl = imgurl_;
    }
    print("image__DashboardHeader: $imgurl");
    Future getImg() async {
      return Image.network(
        imgurl,
        width: width * .3,
        height: width * .3,
        fit: BoxFit.cover,
      );
    }

    const paddingValue = 16.0;
    const topValue = 10.0;
    final double percentagePadding = paddingValue / screenWidth * 100;
    final double topValueP = topValue / screenWidth * 100;

    return AppBar(
      backgroundColor: const Color(0XFFF6F6F6),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w600,
          fontSize: width * .040,
          color: const Color(0xff808080),
        ),
      ),
      centerTitle: true,
      elevation: 0,
      leading: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back_ios, color: Colors.black),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 16.w, 0),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const Settings(baseCurrency: 'baseCurrency'),
              ),
            ),
            child: CircleAvatar(
              radius: width * .04,
              backgroundColor: Colors.white,
              child: FutureBuilder(
                future: getImg(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(width * .07),
                      child: CachedNetworkImage(
                        imageUrl: imgurl,
                        progressIndicatorBuilder: (context, url, progress) =>
                            CircularProgressIndicator(
                              strokeWidth: .5,
                              value: progress.progress,
                            ),
                        errorWidget: (context, url, error) =>
                            CircularProgressIndicator(strokeWidth: .2),
                        width: width * .14,
                        height: width * .14,
                        fit: BoxFit.cover,
                      ),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
