import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Tnc extends StatefulWidget {
  final bool tnc;

  const Tnc({super.key, required this.tnc});

  @override
  _TncState createState() => _TncState();
}

class _TncState extends State<Tnc> {
  final Completer<InAppWebViewController> _controller =
      Completer<InAppWebViewController>();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: widget.tnc
            ? Text(
                "Terms and Conditions",
                style: GoogleFonts.nunitoSans(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              )
            : Text(
                "Privacy Policy",
                style: GoogleFonts.nunitoSans(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
      body: InAppWebView(
        initialUrlRequest: widget.tnc
            ? _returnUrl("https://www.mygaphub.com/terms-conditions")
            : _returnUrl("https://www.mygaphub.com/privacy-policy"),
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
