import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../provider/essential_video_state.dart';

class EssentialVideoController extends Notifier<EssentialVideoState> {
  YoutubePlayerController? _youtubeController;

  YoutubePlayerController? get youtubeController => _youtubeController;

  @override
  EssentialVideoState build() {
    ref.onDispose(() {
      _youtubeController?.dispose();
    });
    return const EssentialVideoState();
  }

  Future<void> initVideo(String videoUrl) async {
    state = state.copyWith(isLoading: true);
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    if (videoId == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: false,
        hideControls: false,
      ),
    );

    _youtubeController!.addListener(_onVideoUpdate);
    state = state.copyWith(isLoading: false);
  }

  void _onVideoUpdate() {
    if (_youtubeController == null) return;
    final isPlaying = _youtubeController!.value.isPlaying;
    state = state.copyWith(isPlaying: isPlaying);
  }

  Future<void> play() async {
    if (_youtubeController == null) return;
    state = state.copyWith(isLoading: true);
    _youtubeController!.play();
    state = state.copyWith(isLoading: false);

    // ⏱️ Enable Skip button after 5 seconds
    await Future.delayed(const Duration(seconds: 5));
    if (state.isPlaying) {
      state = state.copyWith(skipEnabled: true);
    }
  }

  Future<void> onContinuePressed() async {
    state = state.copyWith(isNavigating: true);
    await Future.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(isNavigating: false);
  }
}

final essentialVideoControllerProvider =
    NotifierProvider<EssentialVideoController, EssentialVideoState>(
      EssentialVideoController.new,
    );
