import 'package:GapHub/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DisplayImage extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;
  final bool icon;

  const DisplayImage({
    super.key,
    required this.imagePath,
    this.icon = true,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          buildImage(context),
          icon
              ? Positioned(right: 17, bottom: 10, child: buildEditIcon())
              : Container(),
        ],
      ),
    );
  }

  // Builds Profile Image
  Widget buildImage(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageSize = size.width * 0.24;

    return CircleAvatar(
      radius: 75,
      backgroundColor: Colors.transparent,
      child: CircleAvatar(
        radius: 60,
        backgroundImage: imagePath != imgPrefixAssets
            ? CachedNetworkImageProvider(imagePath)
            : const AssetImage('assets/images/add_photo.jpg') as ImageProvider,
        onBackgroundImageError: (error, stackTrace) {
          debugPrint('Error loading image: $error');
        },
      ),
    );
  }

  // Builds Edit Icon on Profile Picture
  Widget buildEditIcon() {
    return buildCircle(
      all: 8,
      child: InkWell(onTap: onPressed, child: const Icon(Icons.edit, size: 20)),
    );
  }

  // Builds Circle for Edit Icon on Profile Picture
  Widget buildCircle({required Widget child, required double all}) {
    return ClipOval(
      child: Container(
        padding: EdgeInsets.all(all),
        color: const Color(0xffe9e9e9),
        child: child,
      ),
    );
  }
}
