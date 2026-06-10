import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    this.size = 88,
    this.showShadow = true,
    super.key,
  });

  final double size;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.86,
            height: size * 0.86,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEDEDF0), width: 1.2),
              boxShadow: showShadow
                  ? const [
                      BoxShadow(
                        color: AppColors.shadowSoft,
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ]
                  : null,
            ),
          ),
          SizedBox(
            width: size * 0.42,
            height: size * 0.66,
            child: CustomPaint(painter: const _JourneyMarkPainter()),
          ),
        ],
      ),
    );
  }
}

class _JourneyMarkPainter extends CustomPainter {
  const _JourneyMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final markPaint = Paint()
      ..color = AppColors.textDark
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final mainMark = Path()
      ..moveTo(size.width * 0.72, size.height * 0.02)
      ..cubicTo(
        size.width * 0.60,
        size.height * 0.18,
        size.width * 0.48,
        size.height * 0.31,
        size.width * 0.42,
        size.height * 0.47,
      )
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.65,
        size.width * 0.55,
        size.height * 0.70,
        size.width * 0.54,
        size.height * 0.79,
      )
      ..cubicTo(
        size.width * 0.48,
        size.height * 0.70,
        size.width * 0.29,
        size.height * 0.63,
        size.width * 0.29,
        size.height * 0.49,
      )
      ..cubicTo(
        size.width * 0.30,
        size.height * 0.31,
        size.width * 0.54,
        size.height * 0.13,
        size.width * 0.72,
        size.height * 0.02,
      )
      ..close();

    final sideMark = Path()
      ..moveTo(size.width * 0.30, size.height * 0.63)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.49,
        size.width * 0.28,
        size.height * 0.32,
        size.width * 0.62,
        size.height * 0.09,
      )
      ..cubicTo(
        size.width * 0.48,
        size.height * 0.30,
        size.width * 0.39,
        size.height * 0.50,
        size.width * 0.42,
        size.height * 0.68,
      )
      ..cubicTo(
        size.width * 0.38,
        size.height * 0.66,
        size.width * 0.34,
        size.height * 0.64,
        size.width * 0.30,
        size.height * 0.63,
      )
      ..close();

    canvas.drawPath(sideMark, markPaint);
    canvas.drawPath(mainMark, markPaint);
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.88),
      size.width * 0.155,
      markPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
