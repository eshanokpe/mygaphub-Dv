import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class DataSharingScreen extends StatefulWidget {
  const DataSharingScreen({super.key});

  @override
  _DataSharingScreenState createState() => _DataSharingScreenState();
}

class _DataSharingScreenState extends State<DataSharingScreen> {
  final Completer<InAppWebViewController> _controller =
      Completer<InAppWebViewController>();

  @override
  void initState() {
    super.initState();
    // if (Platform.isAndroid) {
    //   AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Sharing Policy")),
      body: InAppWebView(
        initialUrlRequest: _returnUrl(
          "https://www.mygaphub.com/terms-conditions",
        ),
        initialOptions: InAppWebViewGroupOptions(
          android: AndroidInAppWebViewOptions(
            useHybridComposition: true,
            mixedContentMode:
                AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
          ),
        ),
        onWebViewCreated: (controller) {
          _controller.complete(controller);
        },
      ),
    );
  }

  URLRequest _returnUrl(String url) {
    return URLRequest(url: WebUri(url));
  }
}
