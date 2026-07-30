// widgets/carousel_slider_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../controllers/wheel_controller.dart';
import '../providers/carousel_provider.dart';
import 'active_card_widget.dart';
import 'side_card_widget.dart';

class CarouselSliderWidget extends ConsumerStatefulWidget {
  final void Function(int index)? onActiveTap;
  final WheelController controller;

  const CarouselSliderWidget({
    super.key,
    this.onActiveTap,
    required this.controller,
  });

  @override
  ConsumerState<CarouselSliderWidget> createState() =>
      _CarouselSliderWidgetState();
}

class _CarouselSliderWidgetState extends ConsumerState<CarouselSliderWidget> {
  // ── Card dimensions ────────────────────────────────────────────────────────
  static const double _activeW         = 200.0;
  static const double _activeH         = 254.0;
  static const double _sideW           = 140.0;
  static const double _sideH           = 205.0;
  static const double _gapBetweenCards = 3.0;

  double _dragStartX = 0;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final state         = ref.watch(carouselProvider);
    final total         = state.wheelItems.length;

    final int leftIndex  = (selectedIndex - 1 + total) % total;
    final int rightIndex = (selectedIndex + 1) % total;
    final double sideTop = (_activeH.h - _sideH.h) / 2;

    return GestureDetector(
      onHorizontalDragStart: (d) => _dragStartX = d.globalPosition.dx,
      onHorizontalDragEnd: (d) {
        final vel = d.velocity.pixelsPerSecond.dx;
        if (vel < -200) {
          HapticFeedback.lightImpact();
          ref.read(carouselProvider.notifier).next();
        } else if (vel > 200) {
          HapticFeedback.lightImpact();
          ref.read(carouselProvider.notifier).previous();
        }
      },
      child: SizedBox(
        height: _activeH.h,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenW  = constraints.maxWidth;
            final double activeCX = screenW / 2;
            final double sideOffset =
                (_activeW.w / 2) + _gapBetweenCards.w + (_sideW.w / 2);
            final double leftCX  = activeCX - sideOffset;
            final double rightCX = activeCX + sideOffset;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // ── Left side card ────────────────────────────────────────
                Positioned(
                  left: leftCX - (_sideW.w / 2),
                  top: sideTop,
                  width: _sideW.w,
                  height: _sideH.h,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 280),
                    opacity: 0.65,
                    child: SideCardWidget(
                      key: ValueKey('left_$leftIndex'),
                      item: state.sideCardItems[leftIndex],
                      index: leftIndex,
                      isLeft: true,
                      controller: widget.controller,
                    ),
                  ),
                ),

                // ── Right side card ───────────────────────────────────────
                Positioned(
                  left: rightCX - (_sideW.w / 2),
                  top: sideTop,
                  width: _sideW.w,
                  height: _sideH.h,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 280),
                    opacity: 0.65,
                    child: SideCardWidget(
                      key: ValueKey('right_$rightIndex'),
                      item: state.sideCardItems[rightIndex],
                      index: rightIndex,
                      isLeft: false,
                      controller: widget.controller,
                    ),
                  ),
                ),

                // ── Active card (always on top) ───────────────────────────
                Positioned(
                  left: activeCX - (_activeW.w / 2),
                  top: 0,
                  width: _activeW.w,
                  height: _activeH.h,
                  child: ActiveCardWidget(
                    key: ValueKey('active_$selectedIndex'),
                    item: state.wheelItems[selectedIndex],
                    index: selectedIndex,
                    controller: widget.controller,
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