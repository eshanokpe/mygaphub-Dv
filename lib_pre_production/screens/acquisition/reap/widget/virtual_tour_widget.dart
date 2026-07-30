import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class VirtualTourIcon extends StatefulWidget {
  final PropertyDetailModel? propertyDetail;
  const VirtualTourIcon({super.key, this.propertyDetail});

  @override
  _VirtualTourIconState createState() => _VirtualTourIconState();
}

class _VirtualTourIconState extends State<VirtualTourIcon> {
  VideoPlayerController? _controller;
  bool _isVideoReady = false;
  bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
    // `Uri.parse` throws FormatException on a malformed string, and this
    // ran synchronously in initState -- an uncaught throw there crashes the
    // app outright instead of showing Flutter's red error screen.
    // Uri.tryParse returns null instead of throwing, so a bad link just
    // falls through to "no video" instead of taking the app down.
    final tourLink = widget.propertyDetail?.propertyVirtualTourLink;
    if (tourLink != null && tourLink.isNotEmpty) {
      final uri = Uri.tryParse(tourLink);
      if (uri != null && uri.isAbsolute) {
        _initializeVideoPlayer(tourLink);
      }
    }
  }

  void _initializeVideoPlayer(String videoUrl) {
    _controller = VideoPlayerController.network(videoUrl)
      ..addListener(() {
        if (mounted) {
          setState(() {
            _isBuffering = _controller?.value.isBuffering ?? false;
          });
        }
      })
      ..initialize()
          .then((_) {
            if (mounted) {
              setState(() {
                _isVideoReady = true; // Set flag to indicate video is ready
              });
              _controller?.play();
            }
          })
          .catchError((error) {
            print("Error initializing video: $error");
          });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // propertyDetail (and its string fields) may be null -- read them into
    // safe local defaults once instead of force-unwrapping with `!`
    // throughout build().
    final tourLink = widget.propertyDetail?.propertyVirtualTourLink ?? '';
    final tourVideo = widget.propertyDetail?.virtualTourVideo ?? '';
    final featuredImage = widget.propertyDetail?.propertyFeaturedImage ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.20,
        height: MediaQuery.of(context).size.height * 0.06,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Stack(
          children: [
            if (_isVideoReady &&
                _controller != null &&
                _controller!.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              )
            // Fallback image when no video link is available
            else if (tourLink.isEmpty)
              CachedNetworkImage(
                imageUrl: featuredImage,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )
            else
              const Center(child: CircularProgressIndicator()),

            // Overlay with virtual tour icon and count
            Positioned(
              top: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.23,
                height: MediaQuery.of(context).size.height * 0.12,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),

            // Display virtual tour icon and link length
            Positioned(
              top: 14,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/acquisition/virtualtouricon.png',
                    ),
                    const SizedBox(width: 5),
                    Text(
                      (tourLink.isNotEmpty || tourVideo.isNotEmpty) ? "1" : "0",
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
