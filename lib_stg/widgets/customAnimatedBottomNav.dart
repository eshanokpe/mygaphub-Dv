import 'package:flutter/material.dart';

class CustomAnimatedBottomNav extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final VoidCallback? onTap;

  const CustomAnimatedBottomNav({
    super.key,
    required this.child,
    this.isActive = false,
    this.onTap,
  });

  @override
  __CustomAnimatedBottomNavState createState() =>
      __CustomAnimatedBottomNavState();
}

class __CustomAnimatedBottomNavState extends State<CustomAnimatedBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(CustomAnimatedBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward().then((_) {
        _controller.reverse();
      });
    }
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
