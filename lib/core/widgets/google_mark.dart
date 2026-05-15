import 'package:flutter/material.dart';

class GoogleMark extends StatelessWidget {
  const GoogleMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE3E8EF)),
      ),
      child: const CustomPaint(size: Size(15, 15), painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  const _GooglePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.18;
    final rect =
        Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    Paint segment(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -0.05, 1.35, false, segment(const Color(0xFF4285F4)));
    canvas.drawArc(rect, 1.30, 1.30, false, segment(const Color(0xFF34A853)));
    canvas.drawArc(rect, 2.60, 0.90, false, segment(const Color(0xFFFBBC05)));
    canvas.drawArc(rect, 3.50, 1.35, false, segment(const Color(0xFFEA4335)));

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final midY = size.height * 0.53;
    canvas.drawLine(
      Offset(size.width * 0.52, midY),
      Offset(size.width * 0.86, midY),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
