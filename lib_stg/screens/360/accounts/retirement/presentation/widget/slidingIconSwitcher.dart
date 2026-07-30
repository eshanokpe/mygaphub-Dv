import 'dart:ui';

import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



class SlidingActionIcon extends StatefulWidget {
  final int selectedIndex;
  final VoidCallback onTapTab0;
  final VoidCallback onTapTab1;

  const SlidingActionIcon({
    super.key,
    required this.selectedIndex,
    required this.onTapTab0,
    required this.onTapTab1,
  });

  @override
  State<SlidingActionIcon> createState() => _SlidingActionIconState();
}

class _SlidingActionIconState extends State<SlidingActionIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  late int _previousIndex;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.selectedIndex;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(covariant SlidingActionIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _previousIndex = oldWidget.selectedIndex;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildIcon(int index) {
    if (index == 0) {
      // Keep Icons.add for tab index 0
      return Icon(
        Icons.add,
        color: AppColors.primaryColor,
        size: 24.sp,
      );
    } else {
      // Use Image.asset for tab index 1 instead of Icons.add_circle_outline
      return Image.asset(
        'assets/wheel_segments/pencil-alt.png',
        width: 20.w,
        height: 20.w,
        color: AppColors.primaryColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const double iconWidth = 56.0;

    return SizedBox(
      width: iconWidth,
      height: kToolbarHeight,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isForward = widget.selectedIndex > _previousIndex;

          final slideOutOffset = lerpDouble(0, isForward ? -iconWidth : iconWidth, _animation.value)!;
          final slideInOffset = lerpDouble(isForward ? iconWidth : -iconWidth, 0, _animation.value)!;

          return Stack(
            children: [
              Positioned(
                left: slideOutOffset,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    if (_previousIndex == 0) widget.onTapTab0();
                    else widget.onTapTab1();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right:16.w),
                    child: _buildIcon(_previousIndex),
                  ),
                ),
              ),
              Positioned(
                left: slideInOffset,
                top:0,
                bottom:0,
                child: GestureDetector(
                  onTap: () {
                    if (widget.selectedIndex == 0) widget.onTapTab0();
                    else widget.onTapTab1();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right:16.w),
                    child: _buildIcon(widget.selectedIndex),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}