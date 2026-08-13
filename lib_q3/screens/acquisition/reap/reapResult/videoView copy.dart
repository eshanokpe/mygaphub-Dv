import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  final PropertyDetailModel propertyDetail;
  const VideoView({super.key, required this.propertyDetail});

  @override
  _VideoViewState createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  List<VideoPlayerController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _initializeAllVideoPlayers();
  }

  void _initializeAllVideoPlayers() {
    final dynamic rawVideoList = widget.propertyDetail.propertyVideoList;

    if (rawVideoList is! List || rawVideoList.isEmpty) {
      // If not a list or is empty, trigger a rebuild if initState has already run
      // to ensure "No videos" message is shown if needed.
      if (mounted) setState(() {});
      return;
    }

    final List<VideoPlayerController> newControllers = [];
    for (final item in rawVideoList) {
      if (item is Map && item.containsKey('property_videos')) {
        final dynamic videoUrlDynamic = item['property_videos'];
        if (videoUrlDynamic is String && videoUrlDynamic.isNotEmpty) {
          Uri? videoUri;
          try {
            videoUri = Uri.parse(videoUrlDynamic);
            if (videoUri.scheme != 'http' && videoUri.scheme != 'https') {
              print(
                'Invalid video URL scheme: $videoUrlDynamic. Must be http or https.',
              );
              continue;
            }
          } catch (e) {
            print('Invalid video URL format: $videoUrlDynamic. Error: $e');
            continue;
          }

          final controller = VideoPlayerController.networkUrl(videoUri);
          controller
              .initialize()
              .then((_) {
                if (mounted) {
                  setState(() {}); // Triggers ValueListenableBuilder update
                }
              })
              .catchError((error) {
                print('Error initializing video $videoUrlDynamic: $error');
                if (mounted) {
                  setState(() {}); // Triggers ValueListenableBuilder update
                }
              });
          controller.setLooping(true);
          newControllers.add(controller);
        } else {
          print('Video URL is not a valid string or is empty in item: $item');
        }
      } else {
        print('Invalid video list item format: $item');
      }
    }

    if (mounted) {
      setState(() {
        _controllers = newControllers;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  Widget _buildNoVideosAvailable() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No videos available for this property.',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            color: AppColors.grayColor, // Or a suitable color from your theme
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildVideoLoadingPlaceholder() {
    return AspectRatio(
      aspectRatio: 16 / 9, // Common video aspect ratio
      child: Container(
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      ),
    );
  }

  Widget _buildVideoErrorPlaceholder() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.grey[300],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 8),
              Text(
                'Error loading video',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controllers.isEmpty) {
      return _buildNoVideosAvailable();
    }

    return ListView.builder(
      itemCount: _controllers.length,
      itemBuilder: (context, index) {
        final controller = _controllers[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              if (value.hasError) {
                return _buildVideoErrorPlaceholder();
              }
              if (value.isInitialized) {
                return CustomVideoPlayer(controller: controller);
              }
              return _buildVideoLoadingPlaceholder();
            },
          ),
        );
      },
    );
  }
}

class CustomVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;

  const CustomVideoPlayer({super.key, required this.controller});

  @override
  _CustomVideoPlayerState createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: widget.controller.value.aspectRatio,
          child: VideoPlayer(widget.controller),
        ),
        // Play/Pause Overlay Button
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (widget.controller.value.isPlaying) {
                  widget.controller.pause();
                } else {
                  widget.controller.play();
                }
              });
            },
            child: Container(
              // Show a subtle scrim when paused to make the play button more visible
              color: widget.controller.value.isPlaying
                  ? Colors.transparent
                  : Colors.black26,
              child: Center(
                child: Icon(
                  widget.controller.value.isPlaying
                      ? Icons
                            .pause_circle_filled // Updated icon
                      : Icons.play_circle_filled, // Updated icon
                  color: Colors.white,
                  size: 64.0, // Slightly larger icon
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
