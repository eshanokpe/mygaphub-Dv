import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientCircularIndicator extends StatelessWidget {
  final double radius;
  final double lineWidth;
  final Color backgroundColor;
  final Widget center;
  final double percent;
  final List<Color> gradientColors;

  const GradientCircularIndicator({
    super.key,
    required this.radius,
    required this.lineWidth,
    required this.backgroundColor,
    required this.center,
    required this.percent,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: backgroundColor, width: lineWidth),
            ),
          ),
          // Gradient progress arc - BOLD COLORS
          CustomPaint(
            size: Size(radius * 2, radius * 2),
            painter: _GradientCircularProgressPainter(
              percent: percent.clamp(0, 1),
              gradientColors: gradientColors,
              lineWidth: lineWidth,
              strokeCap: StrokeCap.round, // Rounded caps for bolder look
            ),
          ),
          // Center content
          center,
        ],
      ),
    );
  }

   // Helper method to create gradient text - BOLD COLORS
  Widget _buildGradientText({
    required String text,
    required List<Color> gradientColors,
    required double fontSize,
    FontWeight fontWeight =
        FontWeight.w900, // Made bolder (was FontWeight.normal)
    TextStyle? style,
  }) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bounds);
      },
      child: Text(
        text,
        style:
            (style ??
            GoogleFonts.nunitoSans(
              fontSize: fontSize,
              fontWeight: fontWeight, // Now using FontWeight.w900 for boldness
              color: Colors.white,
            )),
      ),
    );
  }

}

class GradientText extends StatelessWidget {
  final String text;
  final List<Color> gradientColors;
  final double fontSize;
  final FontWeight fontWeight;
  final TextStyle? style;

  const GradientText({
    super.key,
    required this.text,
    required this.gradientColors,
    required this.fontSize,
    this.fontWeight =
        FontWeight.w900,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bounds);
      },
      child: Text(
        text,
        style:
            (style ??
            GoogleFonts.nunitoSans(
              fontSize: fontSize,
              fontWeight: fontWeight, // Now using FontWeight.w900 for boldness
              color: Colors.white,
            )),
      ),
    );
  }
}

class _GradientCircularProgressPainter extends CustomPainter {
  final double percent;
  final List<Color> gradientColors;
  final double lineWidth;
  final StrokeCap strokeCap;

  _GradientCircularProgressPainter({
    required this.percent,
    required this.gradientColors,
    required this.lineWidth,
    this.strokeCap = StrokeCap.round,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - lineWidth) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = strokeCap;

    // Create gradient shader with bold colors
    const startAngle = -90 * 3.14159 / 180;
    final sweepAngle = 360 * percent * 3.14159 / 180;

    // Create a rect for the gradient
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Create sweep gradient with bold colors
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: gradientColors,
      stops: const [0.0, 1.0],
      tileMode: TileMode.clamp,
    ).createShader(rect);

    paint.shader = gradient;

    // Draw the progress arc with bold colors
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientCircularProgressPainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.gradientColors != gradientColors ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.strokeCap != strokeCap;
  }
}
