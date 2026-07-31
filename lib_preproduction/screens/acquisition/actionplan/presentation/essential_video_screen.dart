import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../controller/essential_video_controller.dart';
import '../provider/essential_video_state.dart';
import 'strategy_intro_screen.dart';
import 'widgets/welcome_strategy_subwidgets.dart';

class EssentialVideoScreen extends ConsumerWidget {
  const EssentialVideoScreen({
    super.key,
    this.thumbnailAssetPath,
    this.videoUrl,
  });

  /// Path to a local thumbnail asset (e.g. 'assets/video_thumbnail.jpg').
  final String? thumbnailAssetPath;

  /// URL of the actual video to play (YouTube link, mp4, etc.).
  final String? videoUrl;

  static const _defaultVideoUrl = 'https://youtu.be/a02tWufmsos';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(essentialVideoControllerProvider);
    final controller = ref.read(essentialVideoControllerProvider.notifier);

    /// Loads the YouTube controller on first tap (if not already loaded),
    /// then starts playback. This is the piece that was missing before —
    /// `play()` is a no-op until `initVideo()` has run.
    Future<void> handlePlayTap() async {
      if (controller.youtubeController == null) {
        await controller.initVideo(videoUrl ?? _defaultVideoUrl);
      }
      await controller.play();
    }

    /// Handles navigation after controller logic
    Future<void> handleContinue() async {
      controller.youtubeController?.pause();
      await controller.onContinuePressed();
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StrategyIntroScreen()),
        );
      }
    }

    final bool hasVideo = controller.youtubeController != null;
    final bool ctaEnabled =
        !state.isNavigating && (!hasVideo || state.skipEnabled);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- Top bar ----------------
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, size: 24.w),
                    color: AppColors.blackColor,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: const BrandLogo(),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),
            const _Title(),
            SizedBox(height: 16.h),
            const _Subtitle(),
            SizedBox(height: 80.h),

            // ---------------- Video player area ----------------
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _VideoPlayerArea(
                state: state,
                youtubeController: controller.youtubeController,
                onTapPlay: handlePlayTap,
                thumbnailAssetPath: 'assets/action_plan/video_img.png',
              ),
            ),

            const Spacer(),
            // ---------------- Bottom CTA (hidden until video is playing) ----------------
            if (state.isPlaying)
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.contentColorWhite,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                        side: BorderSide(
                          color: AppColors.borderColor,
                          width: 1.0.w,
                        ),
                      ),
                    ),
                    onPressed: ctaEnabled ? handleContinue : handleContinue,
                    child: state.isNavigating
                        ? SizedBox(
                            height: 22.h,
                            width: 22.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4.w,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Skip',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: ctaEnabled
                                      ? Colors.black
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.nunitoSans(
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.blackColor,
        ),
        children: const [
          TextSpan(
            text: 'Essential ',
            style: TextStyle(color: AppColors.primaryColor),
          ),
          TextSpan(text: 'Video'),
        ],
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Text(
        'Please watch this video to help you understand '
        'how to formulate a good strategy',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16.sp,
          height: 1.4,
          color: AppColors.blackColor,
        ),
      ),
    );
  }
}

/// Renders either:
/// - A loading spinner (while the video is initializing)
/// - The live YouTube player (once a controller exists)
/// - A thumbnail with a centered play button (idle state)
class _VideoPlayerArea extends StatelessWidget {
  const _VideoPlayerArea({
    required this.state,
    required this.onTapPlay,
    this.youtubeController,
    this.thumbnailAssetPath,
  });

  final EssentialVideoState state;
  final VoidCallback onTapPlay;
  final YoutubePlayerController? youtubeController;
  final String? thumbnailAssetPath;

  @override
  Widget build(BuildContext context) {
    if (youtubeController != null) {
      return YoutubePlayer(
        controller: youtubeController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.primaryColor,
      );
    }

    return GestureDetector(
      onTap: state.isLoading ? null : onTapPlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail background
          thumbnailAssetPath != null
              ? Image.asset(thumbnailAssetPath!, fit: BoxFit.cover)
              : Container(color: Colors.black87),

          // Center play button / loading spinner
          Center(
            child: state.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.black87,
                      size: 32,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
