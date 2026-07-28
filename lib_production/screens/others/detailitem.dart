import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:GapHub/screens/authentication/login/login.dart';

class DetailItem extends StatefulWidget {
  final Map<String, dynamic> item;

  const DetailItem({super.key, required this.item});

  @override
  _DetailItemState createState() => _DetailItemState();
}

class _DetailItemState extends State<DetailItem>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupMethodChannel();
  }

  void _initializeAnimations() {
    controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    scaleAnimation = Tween<double>(
      begin: 0.35,
      end: 0.45,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));
    controller.addListener(() => setState(() {}));
    controller.forward();
  }

  void _setupMethodChannel() {
    const methodChannel = MethodChannel("com.prismcheck.GapHub.goToLogin");
    methodChannel.setMethodCallHandler((MethodCall call) async {
      if (call.method == "goToLoginFromVerification") {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Timer(const Duration(seconds: 40), () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Login(fromAppLink: true)),
            );
          });
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final item = widget.item;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: size.width * .08,
      ),
      child: Column(
        children: [
          _buildImage(size),
          SizedBox(height: size.height * .045),
          _buildTitle(context, size, item),
          const SizedBox(height: 10),
          _buildSubtitle(context, size, item),
        ],
      ),
    );
  }

  Widget _buildImage(Size size) {
    return Image.asset(
      widget.item['image'] ?? '', // Fallback for null image
      height: size.height * scaleAnimation.value,
      fit: BoxFit.contain,
    );
  }

  Widget _buildTitle(
    BuildContext context,
    Size size,
    Map<String, dynamic> item,
  ) {
    return Text(
      item['title'] ?? 'No Title', // Fallback for null title
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: size.width * .08,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubtitle(
    BuildContext context,
    Size size,
    Map<String, dynamic> item,
  ) {
    return Text(
      item['subtitle'] ?? 'No Subtitle', // Fallback for null subtitle
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Theme.of(context).colorScheme.secondary.withOpacity(.8),
        fontSize: size.width * .05,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
