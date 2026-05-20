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
    // Check if propertyVirtualTourLink is a valid URL and initialize video player if valid
    if (widget.propertyDetail!.propertyVirtualTourLink.isNotEmpty &&
        Uri.parse(widget.propertyDetail!.propertyVirtualTourLink).isAbsolute) {
      _initializeVideoPlayer(widget.propertyDetail!.propertyVirtualTourLink);
    }
  }

  void _initializeVideoPlayer(String videoUrl) {
    _controller = VideoPlayerController.network(videoUrl)
      ..addListener(() {
        setState(() {
          _isBuffering = _controller!.value.isBuffering;
        });
      })
      ..initialize()
          .then((_) {
            if (mounted) {
              setState(() {
                _isVideoReady = true; // Set flag to indicate video is ready
              });
              _controller!.play();
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
            if (_isVideoReady && _controller!.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              )
            // Fallback image when no video link is available
            else if (widget.propertyDetail!.propertyVirtualTourLink.isEmpty)
              CachedNetworkImage(
                imageUrl: widget.propertyDetail!.propertyFeaturedImage,
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
                      widget
                                  .propertyDetail!
                                  .propertyVirtualTourLink
                                  .isNotEmpty ||
                              widget.propertyDetail!.virtualTourVideo.isNotEmpty
                          ? "1"
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
