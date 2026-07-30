import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final PropertyDetailModel? propertyDetail;
  const VideoPlayerWidget({super.key, this.propertyDetail});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();

    final videoList = widget.propertyDetail?.propertyVideoList;

    if (videoList != null &&
        videoList.isNotEmpty &&
        videoList.first is Map &&
        videoList.first['property_videos'] is String) {
      final videoUrl = videoList.first['property_videos'];

      _controller = VideoPlayerController.network(videoUrl)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
          }
        })
        ..setLooping(true)
        ..pause();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoList = widget.propertyDetail?.propertyVideoList;

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: MediaQuery.of(context).size.width * .20,
        height: MediaQuery.of(context).size.height * 0.06,
        decoration: BoxDecoration(
          color: const Color(0xff000000).withOpacity(0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Stack(
          children: [
            // Display the video if available and initialized
            if (videoList != null &&
                videoList.isNotEmpty &&
                _controller != null &&
                _controller!.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              )
            // Display the featured image if video is not available
            else if (videoList == null || videoList.isEmpty)
              CachedNetworkImage(
                imageUrl: widget.propertyDetail?.propertyFeaturedImage ?? '',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * .06,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )
            // Default loading state
            else
              const Center(child: CircularProgressIndicator()),

            // Black overlay
            Positioned(
              top: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * .23,
                height: MediaQuery.of(context).size.height * .12,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),

            // Video icon and count
            Positioned(
              top: 14,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam, size: 20.w, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      videoList != null && videoList.isNotEmpty
                          ? "${videoList.length}"
                          : "0",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
