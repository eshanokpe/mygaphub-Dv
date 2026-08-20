// widgets/active_card_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/wheel_controller.dart';
import '../models/wheel_item.dart';

class ActiveCardWidget extends ConsumerWidget {
  final WheelItem item;
  final int index;
  final WheelController controller;

  const ActiveCardWidget({
    super.key,
    required this.item,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => controller.handleItemTap(index, isActiveCard: true),
      child: Center(
        child: OverflowBox(
          alignment: Alignment.center,
          maxWidth: double.infinity,
          child: SizedBox(
            width: 210.w,
            height: 254.h,
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: item.gradienColor,
                  stops: const [0.0, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Title
                  Padding(
                    padding: EdgeInsets.only(left: 10.w, top: 25.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          softWrap: true,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 27.sp,
                            height: 1.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Gradient overlay for text readability
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.r),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Multitone noise overlay
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: MultitoneNoisePainter(
                          size: 0.004,
                          density: 0.8,
                          opacity: 0.1,
                        ),
                      ),
                    ),
                  ),

                  // View button
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 0.w,
                      vertical: 16.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12.w,
                                color: Colors.white,
                                weight: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom-right icon image
                  Positioned(
                    bottom: -25.h,
                    right: -20.w,
                    child: SizedBox(
                      width: 140.w,
                      height: 140.h,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.asset(
                          item.centerIconPath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Painters (unchanged) ────────────────────────────────────────────────────

class MultitoneNoisePainter extends CustomPainter {
  final double size;
  final double density;
  final double opacity;

  MultitoneNoisePainter({
    required this.size,
    required this.density,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = _SeededRandom(92);

    final particleCount = (size.width * size.height * density / 20).toInt();
    final particleSize = this.size * size.width;

    for (int i = 0; i < particleCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      paint.color = Color.fromRGBO(
        255,
        255,
        255,
        opacity * (0.3 + random.nextDouble() * 0.7),
      );

      canvas.drawCircle(
        Offset(x, y),
        particleSize * (0.5 + random.nextDouble() * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SeededRandom {
  int _seed;
  _SeededRandom(this._seed);

  double nextDouble() {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed / 0x7fffffff;
  }
}
