import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class HandwrittenDivider extends StatelessWidget {
  final double height;
  final Color? color;

  const HandwrittenDivider({
    super.key,
    this.height = 2,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: SketchyLinePainter(color: color ?? AppColors.inkFaded),
    );
  }
}

class SketchyLinePainter extends CustomPainter {
  final Color color;

  SketchyLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height / 2);

    for (double i = 0; i < size.width; i += 5) {
      final y = size.height / 2 + (i % 10 == 0 ? 0.5 : -0.5);
      path.lineTo(i, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
