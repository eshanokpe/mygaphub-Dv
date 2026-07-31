import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../controller/essential_video_controller.dart';
import '../../provider/essential_video_state.dart';
import '../strategy_intro_screen.dart';
import 'welcome_strategy_subwidgets.dart';

class EssentialVideoShowModalBottomSheet extends ConsumerWidget {
  const EssentialVideoShowModalBottomSheet({
    super.key,
    this.thumbnailAssetPath,
    this.videoUrl,
  });

  final String? thumbnailAssetPath;
  final String? videoUrl;

  static const _defaultVideoUrl = 'https://youtu.be/a02tWufmsos';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(essentialVideoControllerProvider);
    final controller = ref.read(essentialVideoControllerProvider.notifier);

    Future<void> handlePlayTap() async {
      if (controller.youtubeController == null) {
        await controller.initVideo(videoUrl ?? _defaultVideoUrl);
      }
      await controller.play();
    }

    Future<void> handleContinue() async {
      controller.youtubeController?.pause();
      await controller.onContinuePressed();

      // Close the bottom sheet first
      Navigator.of(context).pop();
    }

    // Note: No Scaffold here, as it's inside a BottomSheet
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          // ---------------- Drag Handle & Top Bar ----------------
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 8.h),
            child: Column(
              children: [
                // Small drag handle indicator
                Container(
                  width: 40.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),

          SizedBox(height: 10.h),
          const _Title(),
          SizedBox(height: 16.h),
          const _Subtitle(),
          SizedBox(height: 40.h), // Reduced spacing for sheet view
          // ---------------- Video player area ----------------
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _VideoPlayerArea(
              state: state,
              youtubeController: controller.youtubeController,
              onTapPlay: handlePlayTap,
              thumbnailAssetPath:
                  thumbnailAssetPath ?? 'assets/action_plan/video_img.png',
            ),
          ),

          const Spacer(),

          // ---------------- Bottom CTA ----------------
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
                onPressed: handleContinue,
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
                            'Close',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          // Add some bottom padding to ensure content isn't hidden by sheet curve
          SizedBox(height: 20.h),
        ],
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
          TextSpan(text: 'Watch'),
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
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Text(
        'This video to help you understand how to formulate a good strategy',
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
