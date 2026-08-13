import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class VideoDisplayPage extends StatefulWidget {
  final String videoUrl;

  const VideoDisplayPage({required this.videoUrl, super.key});

  @override
  _VideoDisplayPageState createState() => _VideoDisplayPageState();
}

class _VideoDisplayPageState extends State<VideoDisplayPage> {
  late final WebViewController _controller;
  bool _isInitialized = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebViewController();
  }

  Future<void> _initializeWebViewController() async {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true, // Changed to true for better playback
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params);

    // Platform-specific settings
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setBackgroundColor(Colors.black);

    // Set navigation delegate to handle loading state
    controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        },
      ),
    );

    setState(() {
      _controller = controller;
      _isInitialized = true;
    });

    // Load the video URL (works with both watch and embed URLs)
    _controller.loadRequest(Uri.parse(widget.videoUrl));
  }

  String _getDisplayUrl(String url) {
    // If it's already a watch URL, use it directly
    if (url.contains('watch?v=') || url.contains('youtu.be/')) {
      return url;
    }

    // If it's an embed URL, convert to watch URL
    final regExp = RegExp(
      r'^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    final videoId = (match != null && match.groupCount >= 2)
        ? match.group(2)
        : '';

    if (videoId!.isNotEmpty) {
      return 'https://www.youtube.com/watch?v=$videoId';
    }

    return url;
  }

  @override
  Widget build(BuildContext context) {
    final displayUrl = _getDisplayUrl(widget.videoUrl);
    final orientation = MediaQuery.of(context).orientation;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: !_isInitialized
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : OrientationBuilder(
                builder: (context, orientation) {
                  return Stack(
                    children: [
                      WebViewWidget(controller: _controller),
                      if (_isLoading)
                        const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      Positioned(
                        top: 50,
                        left: 90,
                        right: 90,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Close Video',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: width * .040,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
