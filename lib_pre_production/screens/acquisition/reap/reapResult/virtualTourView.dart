import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VirtualTourView extends StatefulWidget {
  final PropertyDetailModel propertyDetail;

  const VirtualTourView({super.key, required this.propertyDetail});

  @override
  _VirtualTourViewState createState() => _VirtualTourViewState();
}

class _VirtualTourViewState extends State<VirtualTourView> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('No virtual tour available')),
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
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textSize = size.width * 0.04;

    return Stack(
      children: [
        _buildBackgroundImage(size),
        _buildOverlayContent(size, textSize),
      ],
    );
  }

  Widget _buildBackgroundImage(Size size) {
    return Image.asset(
      'assets/images/acquisition/virtualTour.png',
      width: size.width,
      height: size.height,
      fit: BoxFit.cover,
    );
  }

  Widget _buildOverlayContent(Size size, double textSize) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTitle(textSize),
              SizedBox(height: size.height * 0.02),
              _buildPlayButton(),
              SizedBox(height: size.height * 0.02),
              _buildExploreText(textSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(double textSize) {
    return Text(
      'Montrose Street, Detroit, United States',
      style: TextStyle(
        fontFamily: 'Nunito',
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: textSize,
      ),
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(10.0),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.black,
          size: 20.0,
        ),
      ),
    );
  }

  void _togglePlayPause() {
    setState(() {
      if (widget.controller.value.isPlaying) {
        widget.controller.pause();
        isPlaying = false;
      } else {
        widget.controller.play();
        isPlaying = true;
      }
    });
  }

  Widget _buildExploreText(double textSize) {
    return Text(
      'Explore 3D Space',
      style: TextStyle(
        fontFamily: 'Nunito',
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: textSize,
      ),
    );
  }
}
