import 'package:flutter/material.dart';

class CustomAnimatedBottomNav extends StatefulWidget {
  const CustomAnimatedBottomNav({
    super.key,
    required this.child,
    this.isActive = false,
    // onTap intentionally removed — BottomNavigationBar.onTap handles this.
    // Keeping a local onTap here creates a competing gesture recognizer that
    // adds 100-300 ms of gesture arena resolution delay on every tap.
  });

  final Widget child;
  final bool isActive;

  @override
  State<CustomAnimatedBottomNav> createState() =>
      _CustomAnimatedBottomNavState();
}

class _CustomAnimatedBottomNavState extends State<CustomAnimatedBottomNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200), // was 500 ms — snappier
    );

    // Scale: 1.0 → 1.20 → 1.0  (pop-out instead of shrink-in)
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.20,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.20,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    // Subtle brightness pulse: 0.7 → 1.0
    _opacity = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(CustomAnimatedBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animation fires AFTER the page switch — purely cosmetic, never blocking.
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No GestureDetector — taps are handled entirely by BottomNavigationBar.
    // This eliminates the gesture arena competition that caused the delay.
    return ScaleTransition(
      scale: _scale,
      child: FadeTransition(
        opacity: _opacity,
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
