import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// For Android-specific features
import 'package:webview_flutter_android/webview_flutter_android.dart';
// For iOS-specific features
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

  @override
  void initState() {
    super.initState();
    _initializeWebViewController();
  }

  Future<void> _initializeWebViewController() async {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: false,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params);

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setBackgroundColor(Colors.black);

    setState(() {
      _controller = controller;
      _isInitialized = true;
    });
  }

  String _getCleanEmbedUrl(String url) {
    final regExp = RegExp(
      r'^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    final videoId = (match != null && match.groupCount >= 2)
        ? match.group(2)
        : '';
    return 'https://www.youtube.com/embed/$videoId?'
        'autoplay=1&'
        'mute=0&'
        'controls=1&'
        'disablekb=1&'
        'fs=1&'
        'rel=0&'
        'showinfo=0&'
        'modestbranding=1&'
        'playsinline=0&'
        'iv_load_policy=3&'
        'widget_referrer=1&'
        'enablejsapi=1';
  }

  @override
  Widget build(BuildContext context) {
    final embedUrl = _getCleanEmbedUrl(widget.videoUrl);
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
                      WebViewWidget(
                        controller: _controller
                          ..loadRequest(Uri.parse(embedUrl))
                          ..runJavaScript("""
                            function removeTitle() {
                              try {
                                var player = document.querySelector('ytd-player');
                                if (player && player.shadowRoot) {
                                  var topBar = player.shadowRoot.querySelector('.ytp-chrome-top');
                                  if (topBar) topBar.style.display = 'none';
                                }
                                var iframe = document.querySelector('iframe');
                                if (iframe) {
                                  iframe.contentDocument.querySelector('.ytp-title').style.display = 'none';
                                }
                              } catch (e) {
                                console.log('Error removing title:', e);
                              }
                            }
                            removeTitle();
                            setInterval(removeTitle, 1000);
                          """),
                      ),
                      Positioned(
                        top: 50,
                        left: 50,
                        right: 50,
                        child: IconButton(
                          icon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
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
                          onPressed: () => Navigator.pop(context),
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
